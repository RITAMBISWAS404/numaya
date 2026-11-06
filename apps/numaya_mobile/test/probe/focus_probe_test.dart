import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadAppFonts);
  for (final (name, route) in [
    ('settings', Routes.settings),
    ('match', '${Routes.match}/maya'),
    ('profile', Routes.profile),
  ]) {
    testWidgets('focus order $name', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final c = await quickStartApp(tester);
      await goTo(c, tester, route);
      await tester.pump(const Duration(seconds: 1));
      final seen = <String>[];
      double lastY = -1;
      var backwards = 0;
      for (var i = 0; i < 14; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump(const Duration(milliseconds: 100));
        final f = FocusManager.instance.primaryFocus;
        final ctx = f?.context;
        if (ctx == null) { seen.add('none'); continue; }
        final box = ctx.findRenderObject() as RenderBox?;
        final y = box == null ? -1.0 : box.localToGlobal(Offset.zero).dy;
        if (y + 1 < lastY && seen.length > 1) backwards++;
        lastY = y;
        seen.add('${y.toStringAsFixed(0)}:${f!.debugLabel ?? ctx.widget.runtimeType}');
      }
      debugPrint('FOCUS $name backwards=$backwards ${seen.join(' | ')}');
      await settle(tester);
    });
  }
}
