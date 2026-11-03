@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// The frosted tab bar over the backgrounds that stress glass most (the demo data has only grey
/// photo placeholders): a black photo, a white page, busy saturated stripes, and the High Contrast
/// opaque fallback. Into goldens/fn01-glass-backgrounds.png, for
/// docs/design-experiments/frosted-navigation/. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  const items = [
    TabItem(label: 'Discover', icon: NumayaIcons.home),
    TabItem(label: 'Events', icon: NumayaIcons.event),
    TabItem(label: 'Likes', icon: NumayaIcons.heart, badgeCount: 2),
    TabItem(label: 'Chats', icon: NumayaIcons.message),
    TabItem(label: 'Profile', icon: NumayaIcons.user),
  ];

  Widget stripes() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final c in const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
        Color(0xFF7262C7),
        Color(0xFFE85D4A),
        Color(0xFF1E3A5F),
        Color(0xFFF2C14E),
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ])
        Expanded(child: ColoredBox(color: c)),
    ],
  );

  Widget sample(String name, Widget background, {bool highContrast = false}) =>
      SizedBox(
        height: 120,
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(393, 120),
            highContrast: highContrast,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: background),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: NumayaTabBar(
                  items: items,
                  currentIndex: 0,
                  onSelect: _noop,
                ),
              ),
              Positioned(
                left: 8,
                top: 6,
                child: ColoredBox(
                  color: const Color(0xFFFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(name, style: AppTypography.micro),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  testWidgets('capture frosted bar over stress backgrounds', (tester) async {
    tester.view.physicalSize = const Size(786, 1440);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: Material(
          color: AppColors.canvas,
          child: Column(
            children: [
              sample('black photo', const ColoredBox(color: Color(0xFF000000))),
              sample('white page', const ColoredBox(color: Color(0xFFFFFFFF))),
              sample('page grey', const ColoredBox(color: AppColors.canvas)),
              sample('busy stripes', stripes()),
              sample(
                'purple content',
                const ColoredBox(color: Color(0xFF7262C7)),
              ),
              sample(
                'High Contrast fallback over black',
                const ColoredBox(color: Color(0xFF000000)),
                highContrast: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/fn01-glass-backgrounds.png'),
    );
  });
}

void _noop(int _) {}
