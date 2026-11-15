import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../test/helpers/journeys.dart';

/// QR-011 (2026-11-15): profile-mode frame timings for the scrolling workloads the audit named
/// (Discover with photos, the Messages list and a chat). Frame build and raster durations come
/// straight from the engine's FrameTiming callbacks, so no VM-service connection is needed (the
/// device refused it in profile mode). The driver writes the report to
/// build/integration_response_data.json. Measures; it does not assert a budget.
///
///     flutter drive --profile --driver=test_driver/perf_driver.dart \
///       --target=integration_test/perf_scroll_test.dart -d DEVICE_ID
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scroll frame timings', (tester) async {
    final c = await quickStartApp(tester, world: DemoWorld.full);
    final report = <String, Object>{};

    Map<String, Object> summarise(List<FrameTiming> frames) {
      double pct(List<double> v, double p) {
        if (v.isEmpty) return 0;
        final s = [...v]..sort();
        return s[((s.length - 1) * p).round()];
      }

      final build = [
        for (final f in frames) f.buildDuration.inMicroseconds / 1000,
      ];
      final raster = [
        for (final f in frames) f.rasterDuration.inMicroseconds / 1000,
      ];
      return {
        'frames': frames.length,
        'build_ms_p50': pct(build, 0.5),
        'build_ms_p90': pct(build, 0.9),
        'build_ms_p99': pct(build, 0.99),
        'raster_ms_p50': pct(raster, 0.5),
        'raster_ms_p90': pct(raster, 0.9),
        'raster_ms_p99': pct(raster, 0.99),
        'frames_over_16ms_build': build.where((d) => d > 16).length,
        'frames_over_16ms_raster': raster.where((d) => d > 16).length,
      };
    }

    Future<void> measure(String name, String route) async {
      await goTo(c, tester, route);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      final frames = <FrameTiming>[];
      void collect(List<FrameTiming> t) => frames.addAll(t);
      SchedulerBinding.instance.addTimingsCallback(collect);
      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 3; i++) {
        await tester.fling(list, const Offset(0, -600), 1500);
        await tester.pumpAndSettle();
        await tester.fling(list, const Offset(0, 600), 1500);
        await tester.pumpAndSettle();
      }
      // Timings arrive in batches; give the engine a moment to deliver the last one.
      await tester.pump(const Duration(seconds: 1));
      SchedulerBinding.instance.removeTimingsCallback(collect);
      report[name] = summarise(frames);
    }

    await measure('discover_scroll', Routes.home);
    await measure('messages_scroll', Routes.messages);
    await measure('chat_scroll', '${Routes.chat}/priya');
    binding.reportData = report;
  });
}
