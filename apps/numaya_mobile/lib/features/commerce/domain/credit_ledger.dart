import 'package:flutter/foundation.dart';

/// Compliment credit ledger (PRD 01 delegated defaults, PRD 02 "Ledger append-only").
///
/// - Three buckets: **weekly** (Premium allowance, 3 a week, no rollover), **earned** (welcome
///   credits and streak rewards, capped at 5) and **purchased** (kept until used while the account
///   exists).
/// - Spending takes weekly first, then earned, then purchased.
/// - Every entry has a unique idempotency key and a source; replaying a key returns the original
///   outcome and never moves a balance twice.
/// - Entries are never edited or removed: corrections are new `reversal` entries.
///
/// This is the client mirror of the server ledger (`backend/migrations/0001_mvp_schema.sql`
/// `credit_ledger`). In a live build the client never computes a balance it acts on; the server's
/// transactional endpoints do (`sendCompliment`, `verifyPurchase`, streak award job).
enum CreditBucket { weekly, earned, purchased }

enum LedgerKind { grant, spend, expiry, reversal }

@immutable
class LedgerEntry {
  const LedgerEntry({
    required this.key,
    required this.kind,
    required this.bucket,
    required this.amount,
    required this.at,
    required this.source,
    this.ref,
  });

  /// Idempotency key (unique).
  final String key;
  final LedgerKind kind;
  final CreditBucket bucket;

  /// Signed change to [bucket]'s balance.
  final int amount;
  final DateTime at;

  /// What caused it: `welcome`, `streak:<cycle>`, `premium_week:<n>`, `purchase:<txn>`,
  /// `compliment:<id>` and so on.
  final String source;

  /// The entry this one reverses, for reversals.
  final String? ref;

  @override
  String toString() => 'LedgerEntry($key ${kind.name} ${bucket.name} $amount)';
}

/// Why a grant gave fewer credits than asked.
enum GrantStatus { granted, partiallyCapped, skippedAtCap, duplicate }

@immutable
class GrantOutcome {
  const GrantOutcome(this.status, this.granted, this.ledger);
  final GrantStatus status;
  final int granted;
  final CreditLedger ledger;
}

enum SpendStatus { spent, insufficient, duplicate }

@immutable
class SpendOutcome {
  const SpendOutcome(this.status, this.ledger, {this.bucket});
  final SpendStatus status;
  final CreditLedger ledger;

  /// Where the credit came from, when spent.
  final CreditBucket? bucket;
}

@immutable
class CreditLedger {
  const CreditLedger({this.entries = const [], this.earnedCap = 5});

  final List<LedgerEntry> entries;
  final int earnedCap;

  int balance(CreditBucket bucket) => entries
      .where((e) => e.bucket == bucket)
      .fold(0, (sum, e) => sum + e.amount);

  int get weekly => balance(CreditBucket.weekly);
  int get earned => balance(CreditBucket.earned);
  int get purchased => balance(CreditBucket.purchased);
  int get total => weekly + earned + purchased;

  LedgerEntry? entry(String key) =>
      entries.where((e) => e.key == key).firstOrNull;

  bool has(String key) => entry(key) != null;

  CreditLedger _add(LedgerEntry e) =>
      CreditLedger(entries: [...entries, e], earnedCap: earnedCap);

  /// Grants [amount] to [bucket]. The earned bucket is capped: an award at the cap is skipped (the
  /// UI explains it; no purchase is needed).
  GrantOutcome grant({
    required CreditBucket bucket,
    required int amount,
    required String key,
    required String source,
    required DateTime at,
  }) {
    final existing = entry(key);
    if (existing != null) {
      return GrantOutcome(GrantStatus.duplicate, 0, this);
    }
    var give = amount;
    if (bucket == CreditBucket.earned) {
      final room = (earnedCap - earned).clamp(0, earnedCap);
      give = amount.clamp(0, room);
    }
    if (give <= 0) return GrantOutcome(GrantStatus.skippedAtCap, 0, this);
    final next = _add(
      LedgerEntry(
        key: key,
        kind: LedgerKind.grant,
        bucket: bucket,
        amount: give,
        at: at,
        source: source,
      ),
    );
    return GrantOutcome(
      give < amount ? GrantStatus.partiallyCapped : GrantStatus.granted,
      give,
      next,
    );
  }

  /// Spends one credit: weekly first, then earned, then purchased.
  SpendOutcome spend({
    required String key,
    required String source,
    required DateTime at,
  }) {
    final existing = entry(key);
    if (existing != null) {
      return SpendOutcome(SpendStatus.duplicate, this, bucket: existing.bucket);
    }
    final bucket = [
      CreditBucket.weekly,
      CreditBucket.earned,
      CreditBucket.purchased,
    ].where((b) => balance(b) > 0).firstOrNull;
    if (bucket == null) return SpendOutcome(SpendStatus.insufficient, this);
    return SpendOutcome(
      SpendStatus.spent,
      _add(
        LedgerEntry(
          key: key,
          kind: LedgerKind.spend,
          bucket: bucket,
          amount: -1,
          at: at,
          source: source,
        ),
      ),
      bucket: bucket,
    );
  }

  /// Returns a spent credit after a technical failure (never after a dismissal). Idempotent per
  /// spend: a second reversal of the same spend does nothing.
  CreditLedger reverseSpend(String spendKey, {required DateTime at}) {
    final spent = entry(spendKey);
    final key = 'reversal:$spendKey';
    if (spent == null || spent.kind != LedgerKind.spend || has(key)) {
      return this;
    }
    return _add(
      LedgerEntry(
        key: key,
        kind: LedgerKind.reversal,
        bucket: spent.bucket,
        amount: -spent.amount,
        at: at,
        source: 'technical_failure',
        ref: spendKey,
      ),
    );
  }

  /// Weekly credits do not roll over: the remaining weekly balance expires. Touches the weekly
  /// bucket only.
  CreditLedger expireWeekly({required String key, required DateTime at}) {
    final left = weekly;
    if (left <= 0 || has(key)) return this;
    return _add(
      LedgerEntry(
        key: key,
        kind: LedgerKind.expiry,
        bucket: CreditBucket.weekly,
        amount: -left,
        at: at,
        source: 'weekly_rollover',
      ),
    );
  }

  /// A store refund of a Compliment pack: removes what is left of those credits from the purchased
  /// bucket (never below zero). Conversations already opened are untouched.
  CreditLedger refundPurchase(String grantKey, {required DateTime at}) {
    final granted = entry(grantKey);
    final key = 'refund:$grantKey';
    if (granted == null || has(key)) return this;
    final take = granted.amount.clamp(0, purchased);
    if (take == 0) return this;
    return _add(
      LedgerEntry(
        key: key,
        kind: LedgerKind.reversal,
        bucket: CreditBucket.purchased,
        amount: -take,
        at: at,
        source: 'store_refund',
        ref: grantKey,
      ),
    );
  }
}
