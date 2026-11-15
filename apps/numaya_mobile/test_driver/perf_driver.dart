import 'package:integration_test/integration_test_driver.dart';

/// QR-011 profiling driver: saves the frame-timing report (FrameTiming summaries per scenario)
/// to build/integration_response_data.json.
///   flutter drive --profile --driver=test_driver/perf_driver.dart ///     --target=integration_test/perf_scroll_test.dart -d DEVICE_ID
Future<void> main() => integrationDriver();
