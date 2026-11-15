import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/commerce/application/economy_controller.dart';
import '../../features/compliments/application/compliments_controller.dart';
import '../../features/compliments/domain/compliment.dart';
import '../../features/dating/application/dating_controller.dart';
import 'live_dating_controller.dart';
import 'live_economy_controller.dart';
import 'live_errors.dart';
import 'live_people.dart';
import 'live_providers.dart';

/// [ComplimentsController] on the live backend (backend V1). A Compliment is a pending
/// conversation on the server: `send_compliment` debits one credit and creates the request and
/// message one atomically (idempotent per key); `reply_compliment` opens the chat for both;
/// `dismiss_compliment` hides it for the recipient (no refund; the sender is not told).
class LiveComplimentsController extends ComplimentsController {
  static const _log = AppLogger('LiveCompliments');
  final _rng = Random.secure();
  final Map<String, String> _convById = {};
  final Map<String, String> _keyByPerson = {};
  final Set<String> _inFlight = {};

  SupabaseClient get _db => ref.read(supabaseClientProvider);

  @override
  List<Compliment> build() {
    final session = ref.watch(sessionProvider);
    if (session != null) Future.microtask(refreshRequests);
    return const [];
  }

  /// Loads pending Compliments (both directions) from the conversation list.
  Future<void> refreshRequests() async {
    if (_db.auth.currentUser == null || !ref.mounted) return;
    try {
      final rows =
          await guardLive(() => _db.rpc<dynamic>('list_conversations')) as List;
      final out = <Compliment>[];
      ({List<String> photos, List<String> prompts})? own;
      for (final row in rows.cast<Map<String, dynamic>>()) {
        final c = row['compliment'] as Map<String, dynamic>?;
        if (c == null) continue;
        final convId = row['conversation_id'] as String;
        final other = row['other_id'] as String;
        await livePersonById(_db, other);
        final first = await guardLive(
          () => _db
              .from('messages')
              .select('body, context, created_at')
              .eq('conversation_id', convId)
              .eq('seq', 1)
              .maybeSingle(),
        );
        if (first == null) continue;
        final ctx = first['context'] as Map<String, dynamic>?;
        final isPrompt = c['target_kind'] == 'prompt';
        final fromMe = c['from_me'] == true;
        // PR-007: the exact photo or prompt, from the immutable snapshot the server stored with
        // the Compliment (`photo_id` / `prompt_id`). Sent: it is on their profile; received: on
        // mine. Was always index 0 (the first photo or prompt).
        final refs = fromMe
            ? liveTargets[other]
            : (own ??= await _ownTargets());
        final status = switch (c['status'] as String?) {
          'pending' => ComplimentStatus.pending,
          'accepted' => ComplimentStatus.converted,
          'dismissed' => ComplimentStatus.dismissed,
          _ => ComplimentStatus.blocked,
        };
        final id = c['id'] as String;
        _convById[id] = convId;
        out.add(
          Compliment(
            id: id,
            personId: other,
            fromMe: fromMe,
            target: resolveLiveComplimentTarget(
              isPrompt: isPrompt,
              context: ctx,
              refs: refs,
            ),
            text: first['body'] as String? ?? '',
            sentAt: DateTime.parse(first['created_at'] as String).toLocal(),
            referenceText: isPrompt
                ? '${ctx?['question']}: ${ctx?['answer']}'
                : null,
            status: status,
          ),
        );
      }
      if (ref.mounted) state = out;
    } on LiveFailure catch (e) {
      _log.warning('Requests refresh failed: ${e.code}');
    }
  }

  /// My own approved photos and prompts, in display order (received Compliments point at them).
  Future<({List<String> photos, List<String> prompts})> _ownTargets() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) {
      return (photos: const <String>[], prompts: const <String>[]);
    }
    final photos = await guardLive(
      () => _db
          .from('photos')
          .select('id')
          .eq('user_id', uid)
          .eq('status', 'approved')
          .order('position'),
    ) as List;
    final prompts = await guardLive(
      () =>
          _db.from('prompts').select('id').eq('user_id', uid).order('position'),
    ) as List;
    return (
      photos: [
        for (final r in photos.cast<Map<String, dynamic>>()) r['id'] as String,
      ],
      prompts: [
        for (final r in prompts.cast<Map<String, dynamic>>()) r['id'] as String,
      ],
    );
  }

  @override
  Future<ComplimentSendResult> send({
    required String personId,
    required ComplimentTarget target,
    required String text,
    String? referenceText,
  }) async {
    if (complimentProblem(text, maxLength) != null) {
      return ComplimentSendResult.invalid;
    }
    if (blockFor(personId) != null || _inFlight.contains(personId)) {
      return ComplimentSendResult.notAllowed;
    }
    final ids = liveTargets[personId];
    final list = target.kind == ComplimentTargetKind.photo
        ? ids?.photos
        : ids?.prompts;
    if (list == null || target.index >= list.length) {
      return ComplimentSendResult.notAllowed;
    }
    // One key per person for this attempt: a retry after a lost answer is never charged twice.
    final key = _keyByPerson.putIfAbsent(personId, _uuid);
    _inFlight.add(personId);
    try {
      final r = await guardLive(
        () => _db.rpc<dynamic>(
          'send_compliment',
          params: {
            'p_target': personId,
            'p_target_kind': target.kind.name,
            'p_target_ref': list[target.index],
            'p_body': text.trim(),
            'p_key': key,
          },
        ),
      ) as Map;
      _keyByPerson.remove(personId);
      ref.read(datingProvider.notifier).markDecided(personId);
      await refreshRequests();
      await _refreshOthers();
      _log.info('Compliment ${r['result']}');
      return ComplimentSendResult.sent;
    } on LiveFailure catch (e) {
      _log.warning('Compliment refused: ${e.code}');
      return switch (e.code) {
        'no_credits' => ComplimentSendResult.insufficientCredits,
        'body_invalid' || 'target_invalid' => ComplimentSendResult.invalid,
        'offline' ||
        'server_error' ||
        'rate_limited' => ComplimentSendResult.failed,
        _ => ComplimentSendResult.notAllowed,
      };
    } finally {
      _inFlight.remove(personId);
    }
  }

  @override
  bool reply(String complimentId, String text) {
    final c = byId(complimentId);
    final conv = _convById[complimentId];
    if (c == null ||
        conv == null ||
        c.fromMe ||
        c.status != ComplimentStatus.pending) {
      return false;
    }
    if (text.trim().isEmpty) return false;
    state = [
      for (final x in state)
        x.id == c.id ? x.withStatus(ComplimentStatus.replied) : x,
    ];
    unawaited(() async {
      try {
        await guardLive(
          () => _db.rpc<dynamic>(
            'reply_compliment',
            params: {
              'p_conversation': conv,
              'p_client_message_id': _uuid(),
              'p_body': text.trim(),
            },
          ),
        );
        await _refreshOthers();
      } on LiveFailure catch (e) {
        _log.warning('Reply refused: ${e.code}');
        await refreshRequests(); // shows the real state again
      }
    }());
    return true;
  }

  @override
  void dismiss(String complimentId) {
    super.dismiss(complimentId);
    final conv = _convById[complimentId];
    if (conv == null) return;
    unawaited(
      guardLive(
        () => _db.rpc<dynamic>(
          'dismiss_compliment',
          params: {'p_conversation': conv},
        ),
      ).catchError((Object e) {
        _log.warning('Dismiss failed: $e');
        return null;
      }),
    );
  }

  Future<void> _refreshOthers() async {
    final dating = ref.read(datingProvider.notifier);
    if (dating is LiveDatingController) await dating.refresh();
    final wallet = ref.read(economyProvider.notifier);
    if (wallet is LiveEconomyController) await wallet.refreshWallet();
  }

  String _uuid() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}

/// PR-007: maps a Compliment's stored target snapshot (`context.photo_id` or `context.prompt_id`)
/// to its current position in [refs] (the owner's photos or prompts, in display order). A target
/// that is no longer there resolves to [ComplimentTarget.unavailableIndex], never to another photo.
ComplimentTarget resolveLiveComplimentTarget({
  required bool isPrompt,
  required Map<String, dynamic>? context,
  required ({List<String> photos, List<String> prompts})? refs,
}) {
  final ref = context?[isPrompt ? 'prompt_id' : 'photo_id'] as String?;
  final list = refs == null ? null : (isPrompt ? refs.prompts : refs.photos);
  final i = (ref == null || list == null) ? -1 : list.indexOf(ref);
  final index = i < 0 ? ComplimentTarget.unavailableIndex : i;
  return isPrompt
      ? ComplimentTarget.prompt(index)
      : ComplimentTarget.photo(index);
}
