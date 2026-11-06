@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// Overnight v3 component-state board: each shared component family in its states, on the grey
/// page, at 390pt wide (2x). Writes `test/screenshots/comparison/v3/components/<family>.png`.
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
void main() {
  setUpAll(loadAppFonts);

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
    ),
  );

  Future<void> board(
    WidgetTester tester,
    String family,
    List<Widget> children, {
    double height = 900,
  }) async {
    tester.view.physicalSize = Size(780, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('comparison/v3/components/$family.png'),
    );
  }

  testWidgets('v3 components buttons', (tester) async {
    await board(tester, 'buttons', [
      for (final v in NumayaButtonVariant.values) ...[
        label(v.name),
        NumayaButton(label: 'Button', variant: v, onPressed: () {}),
      ],
      label('primary · icon'),
      NumayaButton(
        label: 'Open chat',
        icon: NumayaIcons.message,
        onPressed: () {},
      ),
      label('primary · loading'),
      NumayaButton(label: 'Button', loading: true, onPressed: () {}),
      label('disabled'),
      const NumayaButton(label: 'Button', onPressed: null),
      label('small · primary / secondary'),
      Row(
        children: [
          NumayaButton(
            label: 'Small',
            small: true,
            expand: false,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          NumayaButton(
            label: 'Small',
            small: true,
            expand: false,
            variant: NumayaButtonVariant.secondary,
            onPressed: () {},
          ),
        ],
      ),
    ], height: 1000);
  });

  testWidgets('v3 components banners', (tester) async {
    await board(tester, 'banners', [
      for (final t in BannerTone.values) ...[
        label('StatusBanner · ${t.name}'),
        StatusBanner(
          title: 'Confirm your recovery email',
          body: 'So you can get back into your account.',
          tone: t,
        ),
      ],
      label('InfoCard'),
      const InfoCard(
        icon: NumayaIcons.info,
        title: 'Only you can see this',
        body: 'Nothing here is shared with your matches.',
      ),
      label('InfoCard · tappable (V3-F01)'),
      Pressable(
        onTap: () {},
        child: const InfoCard(
          icon: NumayaIcons.flag,
          title: 'Something wrong?',
          body: 'Report instead and we will look into it.',
          trailingArrow: true,
        ),
      ),
    ]);
  });

  testWidgets('v3 components lists', (tester) async {
    await board(tester, 'lists', [
      ListGroup(
        title: 'Account',
        footnote: 'Your number is never shown on your profile.',
        children: [
          ListRow(
            label: 'Phone number',
            value: '+44 7700 900123',
            onTap: () {},
          ),
          ListRow(
            leading: NumayaIcons.bell,
            label: 'Notifications',
            detail: 'Matches and messages',
            onTap: () {},
          ),
          ListRow(
            label: 'Show me on Discover',
            switchValue: true,
            onSwitch: (_) {},
          ),
          ListRow(label: 'Read receipts', switchValue: false, onSwitch: (_) {}),
        ],
      ),
      const SizedBox(height: 24),
      ListGroup(
        title: 'Danger zone',
        children: [
          ListRow(label: 'Delete account', danger: true, onTap: () {}),
        ],
      ),
      label('OptionCard (separate selectable cards, UI-003)'),
      OptionCard(label: 'Long-term', selected: true, onTap: () {}),
      const SizedBox(height: 8),
      OptionCard(
        label: 'Something casual',
        description: 'Open to seeing where it goes',
        selected: false,
        onTap: () {},
      ),
      const SizedBox(height: 8),
      const OptionCard(
        label: 'Unavailable',
        selected: false,
        enabled: false,
        onTap: null,
      ),
    ], height: 1000);
  });

  testWidgets('v3 components inputs', (tester) async {
    await board(tester, 'inputs', [
      const NumayaTextField(
        label: 'First name',
        placeholder: 'Your first name',
      ),
      const SizedBox(height: 12),
      NumayaTextField(
        label: 'Email',
        controller: TextEditingController(text: 'alex@'),
        error: 'Enter a full email address',
      ),
      const SizedBox(height: 12),
      const NumayaTextField(
        label: 'Disabled',
        enabled: false,
        placeholder: 'Not editable',
      ),
      label('Chips · selected / idle / unavailable'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          NumayaChip(label: 'Jazz', emoji: '🎷', selected: true, onTap: () {}),
          NumayaChip(label: 'Natural wine', selected: false, onTap: () {}),
          NumayaChip(
            label: 'Climbing',
            selected: false,
            available: false,
            onTap: () {},
          ),
        ],
      ),
      label('Switch · on / off'),
      Row(
        children: [
          NumayaSwitch(value: true, onChanged: (_) {}),
          const SizedBox(width: 16),
          NumayaSwitch(value: false, onChanged: (_) {}),
        ],
      ),
      label('ViewTabs'),
      ViewTabs(
        label: 'Filter',
        options: const [
          (label: 'All', count: 7),
          (label: 'New', count: 4),
          (label: 'Nearby', count: 3),
        ],
        selected: 0,
        onSelect: (_) {},
      ),
      label('StatusBadge · neutral / brand'),
      const Row(
        children: [
          StatusBadge(label: 'Not verified', icon: NumayaIcons.verified),
          SizedBox(width: 8),
          StatusBadge(label: 'New', tone: BadgeTone.brand),
        ],
      ),
    ]);
  });

  testWidgets('v3 components empty', (tester) async {
    await board(tester, 'empty', [
      EmptyState(
        title: 'No conversations yet',
        body: 'When you match, you can say hello here.',
        art: const IllustrationView(
          NumayaIllustration.mascotWaiting,
          width: 160,
        ),
        action: NumayaButton(label: 'Discover people', onPressed: () {}),
      ),
    ], height: 600);
  });
}
