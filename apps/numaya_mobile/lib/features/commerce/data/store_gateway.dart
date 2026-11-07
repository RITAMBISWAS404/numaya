import 'package:flutter/foundation.dart';

import '../domain/catalog.dart';

/// What the store (Google Play Billing / App Store) reported, before server verification.
enum StoreResult { purchased, pending, cancelled, failed, unavailable }

/// The native store checkout. A live implementation wraps Google Play Billing and hands the
/// purchase token to the backend `verifyPurchase` endpoint; entitlement is granted only from the
/// server's verified response (PRD 02/05). No store products exist yet (prices are provisional).
abstract interface class StoreGateway {
  /// True when this gateway can take real money. Never true in this build.
  bool get live;

  Future<StoreResult> buy(Product product, {required String idempotencyKey});

  /// Restores previous purchases (subscriptions) from the store account.
  Future<List<String>> restore();
}

/// The demo store: the tester picks the outcome on a sheet that says no payment is taken. The
/// result is applied by the demo verifier, labelled as demo everywhere it shows.
class DemoStoreGateway implements StoreGateway {
  DemoStoreGateway({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  /// The outcome the next purchase will report (set by the demo checkout sheet).
  StoreResult nextResult = StoreResult.purchased;

  @override
  bool get live => false;

  @override
  Future<StoreResult> buy(
    Product product, {
    required String idempotencyKey,
  }) async {
    await Future<void>.delayed(latency);
    return nextResult;
  }

  @override
  Future<List<String>> restore() async {
    await Future<void>.delayed(latency);
    return const [];
  }
}

/// A build with no store configured (staging/production without billing): every purchase reports
/// [StoreResult.unavailable]. It never reports success.
@immutable
class UnconfiguredStoreGateway implements StoreGateway {
  const UnconfiguredStoreGateway();

  @override
  bool get live => false;

  @override
  Future<StoreResult> buy(
    Product product, {
    required String idempotencyKey,
  }) async => StoreResult.unavailable;

  @override
  Future<List<String>> restore() async => const [];
}
