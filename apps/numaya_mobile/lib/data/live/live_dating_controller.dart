import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/connectivity/connectivity.dart';
import '../../core/logging/app_logger.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/application/session_expiry.dart';
import '../../features/dating/application/dating_controller.dart';
import '../../features/dating/data/media_picker.dart';
import '../../features/dating/domain/live_directory.dart';
import '../../features/dating/domain/sample_people.dart';
import 'live_config.dart';
import 'live_errors.dart';
import 'live_people.dart';
import 'live_profile_repository.dart' show sanitizePhoto;
import 'live_providers.dart';

/// Something the server decided that the UI should react to (pushed by an app-level listener so
/// the approved screens stay unchanged).
sealed class LiveEvent {
  const LiveEvent();
}

/// The server confirmed a mutual match (the match screen opens only after this).
class LiveMatched extends LiveEvent {
  const LiveMatched(this.personId);
  final String personId;
}

/// The server refused a like because today's allowance is used.
class LiveOutOfLikes extends LiveEvent {
  const LiveOutOfLikes();
}

final liveEventsProvider = StreamProvider<LiveEvent>(
  (ref) => ref.watch(liveEventBusProvider).stream,
);
final liveEventBusProvider = Provider<StreamController<LiveEvent>>((ref) {
  final c = StreamController<LiveEvent>.broadcast();
  ref.onDispose(c.close);
  return c;
});

/// [DatingController] on the live backend (backend V1). Discover, decisions, matches, messages,
/// block, unmatch and report go to Supabase; the derived UI rules (timers, unread, archive) are
/// the controller's own, fed with server data. No sample person is ever shown in this mode.
class LiveDatingController extends DatingController {
  static const _log = AppLogger('LiveDating');
  static const _localIdBase = 1 << 30;

  SupabaseClient get _db => ref.read(supabaseClientProvider);
  String? get _me => _db.auth.currentUser?.id;

  final Map<String, String> _convByPerson = {};
  final Map<String, String> _personByConv = {};
  final Map<int, String> _clientIdByLocal = {};
  final Set<String> _knownClientIds = {};
  final Map<String, int> _lastSeq = {};
  List<SamplePerson> _feed = const [];
  int? _likesLeft;
  int _serverLikes = 0;
  RealtimeChannel? _channel;
  Timer? _poll;
  final _rng = Random.secure();

  @override
  DatingState build() {
    final session = ref.watch(sessionProvider);
    ref.listen(connectivityProvider, (was, online) {
      if (online && was == false) unawaited(_retryWaiting());
    });
    ref.onDispose(() {
      _poll?.cancel();
      final ch = _channel;
      if (ch != null) unawaited(_db.removeChannel(ch));
    });
    if (session == null) return const DatingState();
    Future.microtask(refresh);
    _subscribe();
    // A safety net next to realtime: picks up matches and state changes if a socket drops.
    _poll = Timer.periodic(
      const Duration(seconds: 45),
      (_) => unawaited(refresh()),
    );
    return const DatingState(coachDone: true, nextMessageId: _localIdBase);
  }

  @override
  List<SamplePerson> get deck => _feed;

  /// Reloads the feed, wallet and conversations from the server.
  Future<void> refresh() async {
    if (_me == null || !ref.mounted) return;
    try {
      final wallet =
          await guardLive(() => _db.rpc<dynamic>('my_wallet')) as Map;
      _likesLeft = wallet['likes_left_today'] as int?;
      final likes =
          await guardLive(() => _db.rpc<dynamic>('likes_summary')) as Map;
      _serverLikes = likes['count'] as int? ?? 0;
      final feed = await guardLive(
        () => _db.rpc<dynamic>('discovery_feed', params: {'p_limit': 20}),
      ) as List;
      final people = <SamplePerson>[];
      for (final card in feed.cast<Map<String, dynamic>>()) {
        people.add(await livePersonFromCard(_db, card));
      }
      _feed = people;
      await _syncConversations();
    } on LiveFailure catch (e) {
      _log.warning('Refresh failed: ${e.code}');
      if (e.sessionExpired) ref.read(sessionExpiryProvider.notifier).expire();
    }
  }

  Future<void> _syncConversations() async {
    final rows =
        await guardLive(() => _db.rpc<dynamic>('list_conversations')) as List;
    final matches = <String>[...state.matches];
    final matchedAt = {...state.matchedAt};
    final extendedUntil = {...state.extendedUntil};
    final threads = {...state.threads};
    final lastRead = {...state.lastRead};
    for (final row in rows.cast<Map<String, dynamic>>()) {
      final convId = row['conversation_id'] as String;
      final otherId = row['other_id'] as String;
      final st = row['state'] as String;
      if (st.startsWith('pending')) {
        continue; // Compliment requests: see UI_INTEGRATION (gap).
      }
      if (!liveDirectory.containsKey(otherId)) {
        await livePersonById(_db, otherId);
      }
      _convByPerson[otherId] = convId;
      _personByConv[convId] = otherId;
      if (!matches.contains(otherId)) matches.add(otherId);
      final deadline = DateTime.tryParse(row['deadline'] as String? ?? '');
      if (deadline != null) {
        final extended = row['extended'] == true;
        matchedAt[otherId] = deadline.subtract(
          Duration(hours: extended ? 48 : 24),
        );
        if (extended) extendedUntil[otherId] = deadline;
      } else {
        matchedAt.putIfAbsent(otherId, DateTime.now);
      }
      final last = row['last_message'] as Map<String, dynamic>?;
      final lastSeq = (last?['seq'] as int?) ?? 0;
      if (lastSeq > (_lastSeq[convId] ?? 0)) {
        final loaded = await _loadMessages(
          convId,
          after: _lastSeq[convId] ?? 0,
        );
        threads[otherId] = [...?threads[otherId], ...loaded];
        _lastSeq[convId] = lastSeq;
        final unread = row['unread'] as int? ?? 0;
        final thread = threads[otherId]!;
        if (unread == 0) {
          lastRead[otherId] = thread.isEmpty ? DateTime.now() : thread.last.at;
        } else if (thread.length > unread) {
          lastRead[otherId] = thread[thread.length - unread - 1].at;
        }
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      matches: matches,
      matchedAt: matchedAt,
      extendedUntil: extendedUntil,
      threads: threads,
      lastRead: lastRead,
    );
  }

  Future<List<DemoMessage>> _loadMessages(
    String convId, {
    required int after,
  }) async {
    final rows = await guardLive(
      () => _db
          .from('messages')
          .select(
            'seq, sender_id, client_message_id, kind, body, context, created_at, '
            'attachment:attachments(kind, processed_path, duration_ms)',
          )
          .eq('conversation_id', convId)
          .gt('seq', after)
          .order('seq')
          .limit(200),
    );
    final out = <DemoMessage>[];
    for (final m in rows) {
      if (_knownClientIds.contains(m['client_message_id'])) continue;
      out.add(_toDemo(m, attachment: await _attachmentOf(m)));
    }
    return out;
  }

  Future<MessageAttachment?> _attachmentOf(Map<String, dynamic> m) async {
    final a = m['attachment'] as Map<String, dynamic>?;
    final path = a?['processed_path'] as String?;
    if (a == null || path == null) return null;
    try {
      final url = await _db.storage
          .from('chat-media')
          .createSignedUrl(path, LiveConfig.signedUrlSeconds);
      final ms = a['duration_ms'] as int?;
      return MessageAttachment(
        kind: a['kind'] == 'voice'
            ? AttachmentKind.voice
            : AttachmentKind.photo,
        source: url,
        duration: ms == null ? null : Duration(milliseconds: ms),
      );
    } on Object {
      return null; // access revoked (block) or expired: shown as unavailable
    }
  }

  DemoMessage _toDemo(Map<String, dynamic> m, {MessageAttachment? attachment}) {
    final ctx = m['context'] as Map<String, dynamic>?;
    return DemoMessage(
      id: m['seq'] as int,
      text: m['body'] as String? ?? '',
      status: MessageStatus.onDevice,
      at: DateTime.parse(m['created_at'] as String).toLocal(),
      mine: m['sender_id'] == _me,
      attachment: attachment,
      context: ctx == null
          ? null
          : ctx['kind'] == 'prompt'
          ? ctx['question'] as String?
          : kComplimentPhotoContext,
    );
  }

  void _subscribe() {
    final ch = _db.channel('numaya-live-${_rng.nextInt(1 << 30)}');
    ch
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (p) => _onMessage(p.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) => unawaited(refresh()),
        )
        .subscribe();
    _channel = ch;
  }

  void _onMessage(Map<String, dynamic> m) {
    final convId = m['conversation_id'] as String?;
    final person = _personByConv[convId];
    if (person == null) {
      unawaited(refresh()); // A conversation this device has not seen yet.
      return;
    }
    if (_knownClientIds.contains(m['client_message_id'])) {
      return; // our own send, already shown
    }
    if (m['attachment_id'] != null) {
      unawaited(
        _syncConversations(),
      ); // needs a signed URL: fetched with the history
      return;
    }
    final seq = m['seq'] as int;
    if (seq <= (_lastSeq[convId] ?? 0)) return; // duplicate delivery
    if (seq > (_lastSeq[convId] ?? 0) + 1) {
      unawaited(_syncConversations()); // a gap: fetch what was missed, in order
      return;
    }
    _lastSeq[convId!] = seq;
    state = state.copyWith(
      threads: {
        ...state.threads,
        person: [...?state.threads[person], _toDemo(m)],
      },
    );
  }

  // Discover ---------------------------------------------------------------------------------
  @override
  DecisionResult decide(String id, {required bool liked}) {
    if (!_feed.any((p) => p.id == id)) return DecisionResult.passed;
    if (liked && (_likesLeft ?? 1) <= 0) return DecisionResult.outOfLikes;
    if (liked) _likesLeft = (_likesLeft ?? 1) - 1;
    state = state.copyWith(
      seen: {...state.seen, id},
      liked: liked ? {...state.liked, id} : null,
      lastPass: liked ? null : id,
      clearLastPass: liked,
      coachDone: true,
    );
    unawaited(_sendDecision(id, liked: liked, key: _uuid()));
    return liked ? DecisionResult.liked : DecisionResult.passed;
  }

  Future<void> _sendDecision(
    String id, {
    required bool liked,
    required String key,
  }) async {
    try {
      final r = await guardLive(
        () => _db.rpc<dynamic>(
          'decide',
          params: {
            'p_target': id,
            'p_kind': liked ? 'like' : 'pass',
            'p_key': key,
          },
        ),
      ) as Map;
      if (r['likes_left'] is int) _likesLeft = r['likes_left'] as int;
      if (r['result'] == 'matched') {
        await _syncConversations();
        ref.read(liveEventBusProvider).add(LiveMatched(id));
      }
    } on LiveFailure catch (e) {
      _log.warning('Decision refused: ${e.code}');
      if (e.code == 'quota_exhausted') {
        _likesLeft = 0;
        // Nothing was recorded on the server: bring them back to the front of the deck.
        state = state.copyWith(
          seen: {...state.seen}..remove(id),
          liked: {...state.liked}..remove(id),
          front: id,
        );
        ref.read(liveEventBusProvider).add(const LiveOutOfLikes());
      } else if (e.offline) {
        state = state.copyWith(seen: {...state.seen}..remove(id), front: id);
      }
      // Other refusals (unavailable, already decided) mean the person is gone: keep them hidden.
    }
  }

  @override
  int unansweredLikes() => _serverLikes;

  @override
  void resetDiscovery() {
    super.resetDiscovery();
    unawaited(refresh());
  }

  // Messages ---------------------------------------------------------------------------------
  @override
  Future<void> send(
    String id,
    String text, {
    MessageAttachment? attachment,
    int? replyToId,
  }) async {
    final body = text.trim();
    final conv = _convByPerson[id];
    // Attachments are not on the server yet (PROVIDER_STATUS); the live build hides them.
    if ((body.isEmpty && attachment == null) ||
        conv == null ||
        !state.isActive(id)) {
      return;
    }
    if (attachment != null && !LiveConfig.attachmentsEnabled) return;
    if (!status(id).canSend || !canSendMore(id)) return;
    final localId = state.nextMessageId;
    final clientId = _uuid();
    _clientIdByLocal[localId] = clientId;
    _knownClientIds.add(clientId);
    final message = DemoMessage(
      id: localId,
      text: body,
      at: DateTime.now(),
      attachment: attachment,
      status: ref.read(connectivityProvider)
          ? MessageStatus.sending
          : MessageStatus.waiting,
    );
    state = state.copyWith(nextMessageId: localId + 1);
    _put(id, message);
    if (message.status == MessageStatus.waiting) return;
    await _deliver(id, conv, message);
  }

  Future<void> _deliver(String id, String conv, DemoMessage message) async {
    if (message.attachment != null) {
      return _deliverAttachment(id, conv, message);
    }
    try {
      final r = await guardLive(
        () => _db.rpc<dynamic>(
          'send_message',
          params: {
            'p_conversation': conv,
            'p_client_message_id': _clientIdByLocal[message.id],
            'p_body': message.text,
          },
        ),
      ) as Map;
      final seq = r['seq'] as int;
      if (seq > (_lastSeq[conv] ?? 0)) _lastSeq[conv] = seq;
      _put(id, message.withStatus(MessageStatus.onDevice));
    } on LiveFailure catch (e) {
      _log.warning('Send failed: ${e.code}');
      _put(
        id,
        message.withStatus(
          e.offline ? MessageStatus.waiting : MessageStatus.failed,
        ),
      );
    }
  }

  final Map<int, String> _attachmentByLocal = {};

  /// Upload -> register -> wait for server processing (backoff, about a minute) -> send.
  /// Every step is retry-safe: the attachment id is kept per local message and the send reuses
  /// the same client message id.
  Future<void> _deliverAttachment(
    String id,
    String conv,
    DemoMessage message,
  ) async {
    final a = message.attachment!;
    try {
      var attId = _attachmentByLocal[message.id];
      if (attId == null) {
        if (a.kind == AttachmentKind.video || a.source == null) {
          throw const LiveFailure('kind_not_supported');
        }
        final raw = await File(a.source!).readAsBytes();
        final isVoice = a.kind == AttachmentKind.voice;
        final bytes = isVoice ? raw : await compute(sanitizePhoto, raw);
        if (bytes == null) throw const LiveFailure('type_not_allowed');
        final ogg = a.source!.toLowerCase().endsWith('.ogg');
        final ext = isVoice ? (ogg ? 'ogg' : 'm4a') : 'jpg';
        final mime = isVoice ? (ogg ? 'audio/ogg' : 'audio/mp4') : 'image/jpeg';
        final path = '$conv/$_me/${_uuid()}.$ext';
        await guardLive(
          () => _db.storage
              .from('chat-media')
              .uploadBinary(
                path,
                bytes,
                fileOptions: FileOptions(contentType: mime),
              ),
        );
        final r = await guardLive(
          () => _db.rpc<dynamic>(
            'register_attachment',
            params: {
              'p_conversation': conv,
              'p_object_path': path,
              'p_kind': isVoice ? 'voice' : 'image',
              'p_duration_ms': a.duration?.inMilliseconds,
            },
          ),
        ) as Map;
        attId = r['attachment_id'] as String;
        _attachmentByLocal[message.id] = attId;
      }
      for (var i = 0; ; i++) {
        final st = await guardLive(
          () => _db.rpc<dynamic>(
            'attachment_status',
            params: {'p_attachment': attId},
          ),
        ) as Map;
        if (st['processing'] == 'ready') break;
        if (st['processing'] == 'failed') {
          throw LiveFailure('attachment_${st['failure_reason'] ?? 'failed'}');
        }
        if (i >= 20) throw const LiveFailure('offline'); // still processing
        await Future<void>.delayed(
          Duration(milliseconds: 500 * (i < 6 ? i + 1 : 6)),
        );
      }
      final r = await guardLive(
        () => _db.rpc<dynamic>(
          'send_attachment',
          params: {
            'p_conversation': conv,
            'p_client_message_id': _clientIdByLocal[message.id],
            'p_attachment': attId,
            'p_caption': message.text.isEmpty ? null : message.text,
          },
        ),
      ) as Map;
      final seq = r['seq'] as int;
      if (seq > (_lastSeq[conv] ?? 0)) _lastSeq[conv] = seq;
      _put(id, message.withStatus(MessageStatus.onDevice));
    } on LiveFailure catch (e) {
      _log.warning('Attachment send failed: ${e.code}');
      _put(
        id,
        message.withStatus(
          e.offline ? MessageStatus.waiting : MessageStatus.failed,
        ),
      );
    }
  }

  @override
  Future<void> retry(String id, int messageId) async {
    final message = state.threads[id]
        ?.where((m) => m.id == messageId)
        .firstOrNull;
    final conv = _convByPerson[id];
    if (message == null || conv == null) return;
    // The same client message id: a retry after a lost answer can never create a duplicate.
    _put(id, message.withStatus(MessageStatus.sending));
    await _deliver(id, conv, message);
  }

  Future<void> _retryWaiting() async {
    for (final MapEntry(key: id, value: thread) in state.threads.entries) {
      for (final m
          in thread.where((m) => m.status == MessageStatus.waiting).toList()) {
        if (!ref.mounted) return;
        await retry(id, m.id);
      }
    }
  }

  @override
  void openChat(String id) {
    super.openChat(id);
    final conv = _convByPerson[id];
    final seq = conv == null ? null : _lastSeq[conv];
    if (conv != null && seq != null) {
      unawaited(
        guardLive(
          () => _db.rpc<dynamic>(
            'mark_read',
            params: {'p_conversation': conv, 'p_seq': seq},
          ),
        ).catchError((Object _) => null),
      );
    }
  }

  void _put(String id, DemoMessage message) {
    final thread = [...?state.threads[id]];
    final i = thread.indexWhere((m) => m.id == message.id);
    if (i < 0) {
      thread.add(message);
    } else {
      thread[i] = message;
    }
    state = state.copyWith(
      threads: {...state.threads, id: thread},
      openedMatches: {...state.openedMatches, id},
      lastRead: {...state.lastRead, id: DateTime.now()},
    );
  }

  @override
  ExtendResult extend(String id) {
    final result = super.extend(id);
    final conv = _convByPerson[id];
    if (result == ExtendResult.extended && conv != null) {
      // The server is authoritative; a refusal is corrected by the next sync (real deadline).
      unawaited(
        guardLive(
          () => _db.rpc<dynamic>(
            'extend_match',
            params: {'p_conversation': conv},
          ),
        ).then((_) => _syncConversations()).catchError((Object e) {
          _log.warning('Extension refused: $e');
          return _syncConversations();
        }),
      );
    }
    return result;
  }

  // Safety (always free) -------------------------------------------------------------------
  @override
  void end(String id, EndReason reason) {
    super.end(id, reason);
    final conv = _convByPerson[id];
    unawaited(
      _safety(
        reason == EndReason.unmatched && conv != null
            ? () =>
                  _db.rpc<dynamic>('unmatch', params: {'p_conversation': conv})
            : () => _db.rpc<dynamic>('block_member', params: {'p_other': id}),
      ),
    );
  }

  @override
  void report(
    String id,
    String reason, {
    required bool block,
    String? part,
    String details = '',
  }) {
    super.report(id, reason, block: block, part: part, details: details);
    unawaited(
      _safety(
        () => _db.rpc<dynamic>(
          'report_member',
          params: {
            'p_subject': id,
            'p_category': 'other',
            'p_note': [
              reason,
              ?part,
              if (details.isNotEmpty) details,
            ].join(' · '),
            'p_conversation': _convByPerson[id],
          },
        ),
      ),
    );
    if (block) {
      unawaited(
        _safety(
          () => _db.rpc<dynamic>('block_member', params: {'p_other': id}),
        ),
      );
    }
  }

  @override
  void unblock(String id) {
    super.unblock(id);
    unawaited(
      _safety(
        () => _db.rpc<dynamic>('unblock_member', params: {'p_other': id}),
      ),
    );
  }

  Future<void> _safety(Future<dynamic> Function() call) async {
    // Safety actions are applied locally at once and retried until the server has them.
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        await guardLive(call);
        return;
      } on LiveFailure catch (e) {
        if (!e.offline) {
          _log.warning('Safety action refused: ${e.code}');
          return;
        }
        await Future<void>.delayed(Duration(seconds: 2 << attempt));
      }
    }
  }

  String _uuid() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
