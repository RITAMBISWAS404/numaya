import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Which data the app runs on (PRD 05: explicit demo / staging / production; never silently
/// substitute sample data in a live mode).
enum BackendMode { demo, staging, production }

/// The backend configuration from `--dart-define`. Only the public project URL and anon key would
/// ever be bundled; the service-role secret never is.
@immutable
class ApiConfig {
  const ApiConfig({required this.mode, this.baseUrl = '', this.anonKey = ''});

  factory ApiConfig.fromEnvironment({required bool demoAllowed}) {
    const url = String.fromEnvironment('NUMAYA_API_URL');
    const key = String.fromEnvironment('NUMAYA_API_ANON_KEY');
    const env = String.fromEnvironment(
      'NUMAYA_ENV',
      defaultValue: 'development',
    );
    final mode = env == 'production'
        ? BackendMode.production
        : url.isNotEmpty
        ? BackendMode.staging
        : demoAllowed
        ? BackendMode.demo
        : BackendMode.production;
    return ApiConfig(mode: mode, baseUrl: url, anonKey: key);
  }

  final BackendMode mode;
  final String baseUrl;
  final String anonKey;

  /// True when a live backend could be reached. False in every build made so far.
  bool get configured => baseUrl.isNotEmpty && anonKey.isNotEmpty;
}

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(
    demoAllowed: ref.watch(demoAuthProvider) != null,
  ),
);

/// Raised by the live API when it isn't configured. Screens show "not available yet", never a
/// fake success.
class BackendNotConfigured implements Exception {
  const BackendNotConfigured(this.endpoint);
  final String endpoint;

  @override
  String toString() => 'BackendNotConfigured($endpoint)';
}

/// A stable result from a transactional endpoint (backend/functions/CONTRACTS.md).
@immutable
class ApiResult {
  const ApiResult({this.result, this.error, this.data = const {}});
  final String? result;
  final String? error;
  final Map<String, Object?> data;

  bool get ok => error == null;
}

/// The transactional endpoints the live app calls. Each takes an idempotency key (or a client
/// message UUID) and is safe to retry with the same key.
abstract interface class NumayaApi {
  Future<ApiResult> submitLike(
    String key,
    String recipient, {
    required bool positive,
  });
  Future<ApiResult> sendCompliment(
    String key,
    String recipient, {
    required String targetKind,
    required String targetId,
    required String body,
  });
  Future<ApiResult> replyToRequest(
    String key,
    String complimentId,
    String messageId,
    String body,
  );
  Future<ApiResult> sendMessage(
    String messageId,
    String conversationId,
    String body,
  );
  Future<ApiResult> extendMatch(String key, String matchId);
  Future<ApiResult> requestReconnect(String key, String matchId);
  Future<ApiResult> respondReconnect(
    String key,
    String requestId, {
    required bool accept,
  });
  Future<ApiResult> claimRecovery(
    String key,
    String missedDay,
    String purchaseToken,
  );
  Future<ApiResult> verifyPurchase(
    String store,
    String productId,
    String purchaseToken,
  );
}

/// The live API before a backend exists: every call fails with [BackendNotConfigured].
class UnconfiguredNumayaApi implements NumayaApi {
  const UnconfiguredNumayaApi();

  Never _no(String endpoint) => throw BackendNotConfigured(endpoint);

  @override
  Future<ApiResult> submitLike(
    String key,
    String recipient, {
    required bool positive,
  }) async => _no('submitLike');
  @override
  Future<ApiResult> sendCompliment(
    String key,
    String recipient, {
    required String targetKind,
    required String targetId,
    required String body,
  }) async => _no('sendCompliment');
  @override
  Future<ApiResult> replyToRequest(
    String key,
    String complimentId,
    String messageId,
    String body,
  ) async => _no('replyToRequest');
  @override
  Future<ApiResult> sendMessage(
    String messageId,
    String conversationId,
    String body,
  ) async => _no('sendMessage');
  @override
  Future<ApiResult> extendMatch(String key, String matchId) async =>
      _no('extendMatch');
  @override
  Future<ApiResult> requestReconnect(String key, String matchId) async =>
      _no('reconnectRequest');
  @override
  Future<ApiResult> respondReconnect(
    String key,
    String requestId, {
    required bool accept,
  }) async => _no('reconnectRespond');
  @override
  Future<ApiResult> claimRecovery(
    String key,
    String missedDay,
    String purchaseToken,
  ) async => _no('claimRecovery');
  @override
  Future<ApiResult> verifyPurchase(
    String store,
    String productId,
    String purchaseToken,
  ) async => _no('verifyPurchase');
}

/// The live API. Only the unconfigured implementation exists until the backend is provisioned
/// (docs/product/mvp-prd-v1/LIVE_BLOCKERS.md); the demo build runs the same rules locally.
final numayaApiProvider = Provider<NumayaApi>(
  (ref) => const UnconfiguredNumayaApi(),
);
