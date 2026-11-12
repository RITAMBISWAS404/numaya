import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/logging/app_logger.dart';
import '../../../data/live/live_compliments_controller.dart';
import '../../../data/live/live_config.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/domain/credit_ledger.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../premium/application/premium_controller.dart';
import '../domain/compliment.dart';

enum ComplimentSendResult {
  sent,
  insufficientCredits,
  invalid,
  notAllowed,
  failed,
}

/// Compliments: sending (S14), the recipient's Requests (S20/S21), reply/dismiss/block, and the
/// conversion of a pending request when the pair match. Demo implementation of the server's
/// `sendCompliment` and `replyToRequest` endpoints (atomic, idempotent by key).
class ComplimentsController extends Notifier<List<Compliment>> {
  static const _log = AppLogger('Compliments');

  DateTime get _now => ref.read(clockProvider)();
  int _next = 1;
  final _sending = <String>{};

  @override
  List<Compliment> build() {
    final world = ref.watch(demoWorldProvider);
    if (world == DemoWorld.fresh) return const [];
    final now = ref.read(clockProvider)();
    Compliment seed(
      String id,
      String person,
      bool fromMe,
      ComplimentTarget target,
      String text,
      Duration ago,
    ) {
      final p = personById(person)!;
      return Compliment(
        id: id,
        personId: person,
        fromMe: fromMe,
        target: target,
        text: text,
        sentAt: now.subtract(ago),
        referenceText: target.kind == ComplimentTargetKind.prompt
            ? '${p.prompt?.question}: ${p.prompt?.answer}'
            : null,
      );
    }

    return [
      seed(
        'seed-sam',
        'sam',
        false,
        const ComplimentTarget.photo(0),
        'That light in your first photo is unreal. Where was it taken?',
        const Duration(hours: 5),
      ),
      seed(
        'seed-chloe',
        'chloe',
        false,
        const ComplimentTarget.prompt(0),
        'Your answer made me laugh out loud on the metro.',
        const Duration(hours: 30),
      ),
      seed(
        'seed-finn',
        'finn',
        true,
        const ComplimentTarget.prompt(0),
        'I have strong opinions about this too. Coffee and a debate?',
        const Duration(days: 1),
      ),
    ];
  }

  int get maxLength => ref.read(catalogProvider).policy.complimentMaxLength;

  List<Compliment> requests() => [
    for (final c in state.reversed)
      if (!c.fromMe &&
          c.status == ComplimentStatus.pending &&
          ref.read(datingProvider).isActive(c.personId))
        c,
  ];

  Compliment? byId(String id) => state.where((c) => c.id == id).firstOrNull;

  Compliment? pendingFrom(String personId) => state
      .where(
        (c) =>
            !c.fromMe &&
            c.personId == personId &&
            c.status == ComplimentStatus.pending,
      )
      .firstOrNull;

  Compliment? sentTo(String personId) =>
      state.where((c) => c.fromMe && c.personId == personId).firstOrNull;

  /// Why nobody can send to [personId] now, or null.
  ComplimentBlock? blockFor(String personId) {
    final dating = ref.read(datingProvider);
    return complimentBlock(
      state,
      personId,
      connected: dating.matches.contains(personId),
      available: dating.isActive(personId) && personById(personId) != null,
    );
  }

  /// Sends a Compliment. The credit is spent only once the send is accepted, so a failure or a
  /// cancel spends nothing, and repeated taps cannot send or charge twice.
  Future<ComplimentSendResult> send({
    required String personId,
    required ComplimentTarget target,
    required String text,
    String? referenceText,
  }) async {
    if (complimentProblem(text, maxLength) != null) {
      return ComplimentSendResult.invalid;
    }
    if (blockFor(personId) != null) return ComplimentSendResult.notAllowed;
    if (_sending.contains(personId)) return ComplimentSendResult.notAllowed;
    if (ref.read(creditBalanceProvider) <= 0) {
      return ComplimentSendResult.insufficientCredits;
    }
    _sending.add(personId);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } finally {
      _sending.remove(personId);
    }
    if (!ref.mounted) return ComplimentSendResult.failed;
    final failed =
        !ref.read(connectivityProvider) ||
        ref.read(datingProvider).simulateErrors;
    if (failed) return ComplimentSendResult.failed;
    // Accepted: the one debit. The key is per pair, so it can never charge twice.
    final id = 'c${_now.microsecondsSinceEpoch}-${_next++}';
    final spend = ref
        .read(economyProvider.notifier)
        .spendCredit(key: 'compliment:$personId', source: 'compliment:$id');
    if (spend.status == SpendStatus.insufficient) {
      return ComplimentSendResult.insufficientCredits;
    }
    state = [
      ...state,
      Compliment(
        id: id,
        personId: personId,
        fromMe: true,
        target: target,
        text: text.trim(),
        sentAt: _now,
        referenceText: referenceText,
      ),
    ];
    // Sending is a decision on the profile: it leaves the deck and counts toward the streak.
    ref.read(datingProvider.notifier).markDecided(personId);
    _log.info('Compliment sent');
    return ComplimentSendResult.sent;
  }

  /// Replying opens a reciprocal conversation atomically, with their Compliment first. Free.
  bool reply(String complimentId, String text) {
    final c = byId(complimentId);
    if (c == null || c.status != ComplimentStatus.pending || c.fromMe) {
      return false;
    }
    if (text.trim().isEmpty) return false;
    ref
        .read(datingProvider.notifier)
        .openFromRequest(
          c.personId,
          their: c.text,
          theirAt: c.sentAt,
          context: c.referenceText,
          reply: text.trim(),
        );
    _set(c.withStatus(ComplimentStatus.replied));
    return true;
  }

  /// Dismissing does not refund the sender and cannot be undone (one introduction per pair).
  void dismiss(String complimentId) {
    final c = byId(complimentId);
    if (c == null || c.status != ComplimentStatus.pending) return;
    _set(c.withStatus(ComplimentStatus.dismissed));
  }

  /// A block hides every request from that person.
  void hideFrom(String personId) {
    state = [
      for (final c in state)
        c.personId == personId && c.status == ComplimentStatus.pending
            ? c.withStatus(ComplimentStatus.blocked)
            : c,
    ];
  }

  /// The pair matched while a request was pending: it becomes the first message of that same
  /// conversation. Returns the converted request.
  Compliment? convertOnMatch(String personId) {
    final c = state
        .where(
          (c) => c.personId == personId && c.status == ComplimentStatus.pending,
        )
        .firstOrNull;
    if (c == null) return null;
    _set(c.withStatus(ComplimentStatus.converted));
    return c;
  }

  void _set(Compliment c) =>
      state = [for (final x in state) x.id == c.id ? c : x];
}

final complimentsProvider =
    NotifierProvider<ComplimentsController, List<Compliment>>(
      // Live backend builds send and answer Compliments on the server (backend V1).
      () => LiveConfig.enabled
          ? LiveComplimentsController()
          : ComplimentsController(),
    );

/// Credits the member can spend on Compliments now.
final creditBalanceProvider = Provider<int>((ref) {
  final e = ref.watch(economyProvider);
  ref.watch(premiumProvider);
  return e.ledger.total;
});
