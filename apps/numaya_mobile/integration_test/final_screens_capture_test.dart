// Capture-only tooling: every distinct member-facing screen of the current default candidate, for
// the owner's screen-by-screen review. Not part of the product or the CI suite; changes no app code.
//
// Run with tool/capture_visual_lab.sh and TEST=integration_test/final_screens_capture_test.dart. At
// each point it prints `@@CAP@@|<flow>__<name>.png|<flow>|<screen>|<state>|1.0|<nav path>|<title>`
// and waits for the host's real `adb screencap`. Scrolling screens are captured top to bottom in
// overlapping sections. Demo world, fixed demo clock (2026-10-27 12:00), Lab defaults.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/auth/application/session_expiry.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events_mvp/application/events_mvp_controller.dart';
import 'package:numaya_mobile/features/help/domain/help_articles.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/l10n/generated/app_localizations.dart';

import '../test/helpers/journeys.dart';
import '../test/helpers/test_app.dart';

const _onboarding = '01-Onboarding';
const _discover = '02-Discover';
const _likes = '03-Likes-Compliments';
const _messages = '04-Messages';
const _chat = '05-Chat';
const _profile = '06-Profile';
const _events = '07-Events';
const _streak = '08-Streaks';
const _wallet = '09-Wallet-Store';
const _premium = '10-Premium';
const _settings = '11-Settings';
const _safety = '12-Safety-Help-Legal';
const _account = '13-Account-States';

const _only = String.fromEnvironment('ONLY');
final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');
final _counts = <String, int>{};
final _l = lookupAppLocalizations(const Locale('en'));

String _two(int n) => n.toString().padLeft(2, '0');

class _H {
  _H(this.t, this.c);
  final WidgetTester t;
  final ProviderContainer c;

  Future<void> wait(int ms) async {
    for (var e = 0; e < ms; e += 100) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  /// One step; a failure is reported (it feeds the coverage list) and the run continues.
  Future<void> step(String name, Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (e) {
      // ignore: avoid_print
      print('@@SKIP@@|$name|${e.toString().split('\n').first}');
      await closeAll();
    }
  }

  Future<void> go(String path) async {
    await goTo(c, t, path);
    await wait(900);
  }

  Future<void> tapText(String text) async {
    await tapOn(t, find.text(text).last);
    await wait(900);
  }

  Future<void> tapContaining(String text) async {
    await tapOn(t, find.textContaining(text).last);
    await wait(900);
  }

  Future<void> tapLabel(Pattern label) async {
    await tapOn(t, find.bySemanticsLabel(label));
    await wait(900);
  }

  Future<void> tapKey(String key) async {
    await tapOn(t, find.byKey(ValueKey(key)));
    await wait(900);
  }

  /// Types as the keyboard would (the real text path, so `onChanged` runs).
  Future<void> type(Finder field, String text) async {
    final s = t.state<EditableTextState>(
      find.descendant(of: field, matching: find.byType(EditableText)).last,
    );
    s.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
    await wait(300);
  }

  Future<void> pop() async {
    await t.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await wait(800);
  }

  /// Closes anything a failed step left open.
  Future<void> closeAll() async {
    for (var i = 0; i < 3; i++) {
      if (find.byType(BottomSheet).evaluate().isEmpty) break;
      await pop();
    }
  }

  ScrollableState? _target(bool sheet) {
    final inSheet = t
        .stateList<ScrollableState>(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          ),
        )
        .toSet();
    final all = t
        .stateList<ScrollableState>(find.byType(Scrollable))
        .where((s) => sheet ? inSheet.contains(s) : !inSheet.contains(s))
        .where(
          (s) =>
              s.position.axis == Axis.vertical &&
              s.position.hasContentDimensions &&
              s.position.maxScrollExtent > 4,
        )
        .toList();
    if (all.isEmpty) return null;
    all.sort(
      (a, b) =>
          b.position.viewportDimension.compareTo(a.position.viewportDimension),
    );
    return all.first;
  }

  Future<void> _keyboard({required bool shown}) async {
    for (var i = 0; i < 60; i++) {
      await t.pump(const Duration(milliseconds: 100));
      final open = t.view.viewInsets.bottom > 0;
      if (open == shown) break;
    }
  }

  Future<void> _cap(
    String flow,
    String file,
    String screen,
    String state,
    String nav,
    String title,
    bool keepFocus,
  ) async {
    await wait(keepFocus ? 1500 : 1000);
    if (_ack.existsSync()) _ack.deleteSync();
    // ignore: avoid_print
    print('@@CAP@@|${flow}__$file.png|$flow|$screen|$state|1.0|$nav|$title');
    for (var i = 0; i < 150; i++) {
      await t.pump(const Duration(milliseconds: 100));
      if (_ack.existsSync()) {
        _ack.deleteSync();
        return;
      }
    }
    // ignore: avoid_print
    print('@@MISS@@|$file');
  }

  /// A numbered capture; scrolling content becomes separate overlapping sections.
  Future<void> shot(
    String flow,
    String name,
    String state,
    String nav, {
    bool sheet = false,
    bool keepFocus = false,
    bool scroll = true,
    String? title,
  }) async {
    if (keepFocus) {
      await _keyboard(shown: true);
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      await _keyboard(shown: false);
    }
    await wait(500);
    final n = (_counts[flow] ?? 0) + 1;
    _counts[flow] = n;
    final base = '${_two(n)}-$name';
    final screen = title ?? name.replaceAll('-', ' ');
    final s = scroll ? _target(sheet) : null;
    if (s == null) {
      await _cap(flow, base, base, state, nav, screen, keepFocus);
      return;
    }
    final p = s.position;
    final max = p.maxScrollExtent;
    final viewport = p.viewportDimension;
    final step = sheet
        ? viewport * 0.75
        : (viewport - 240).clamp(240.0, viewport);
    final count = ((max / step).ceil() + 1).clamp(2, 14);
    final up = s.axisDirection == AxisDirection.up;
    final start = p.pixels;
    for (var i = 0; i < count; i++) {
      final along = i == count - 1 ? max : i * step;
      p.jumpTo(up ? max - along : along);
      await wait(700);
      final where = i == 0
          ? 'top'
          : i == count - 1
          ? 'bottom'
          : 'middle';
      await _cap(
        flow,
        '$base-${_two(i + 1)}-$where',
        base,
        '$state ($where, section ${i + 1} of $count)',
        nav,
        screen,
        false,
      );
    }
    p.jumpTo(start);
    await wait(200);
  }

  /// Opens a sheet, captures it, closes it.
  Future<void> sheet(
    String flow,
    String name,
    String state,
    String nav,
    Future<void> Function() open,
  ) => step(name, () async {
    await open();
    await shot(flow, name, state, nav, sheet: true);
    await pop();
  });

  Future<void> page(
    String flow,
    String name,
    String state,
    String path,
    String nav,
  ) => step(name, () async {
    await go(path);
    await shot(flow, name, state, nav);
  });
}

bool _wants(String part) => _only.isEmpty || _only == part;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  setUpAll(DemoPhotoLibrary.load);

  testWidgets('signed out and onboarding', (tester) async {
    if (!_wants('onboarding')) return;
    await tester.pumpWidget(testApp(auth: testAuth()));
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    final h = _H(tester, c);
    await h.wait(2500);
    const f = _onboarding;
    await h.step(
      'Welcome',
      () => h.shot(f, 'Welcome', 'Signed out', 'App launch'),
    );
    await h.step('Phone', () async {
      await h.go(Routes.phone);
      await h.type(find.byType(TextField).last, '4155550132');
      await h.shot(
        f,
        'Phone-number',
        'Number entered',
        'Welcome > Create an account',
      );
    });
    await h.sheet(
      f,
      'Country-picker-sheet',
      'Sheet open',
      'Phone > Country',
      () async {
        await tapOn(tester, find.textContaining('+1').first);
        await h.wait(800);
      },
    );
    await h.step('Verify', () async {
      await tapNext(tester);
      await h.wait(1200);
      await h.shot(
        f,
        'Verification-code',
        'Code requested, resend timer',
        'Phone > Send code',
      );
    });

    c.read(sessionProvider.notifier).quickStartOnboarding();
    await h.wait(500);
    await h.page(
      f,
      'Setup-hub',
      'New account, nothing done',
      Routes.setup,
      'Code verified > Setup hub',
    );
    c.read(onboardingProvider.notifier).loadSample();
    c.read(economyProvider.notifier).grantWelcome();
    await h.wait(300);
    await h.page(
      f,
      'Setup-hub-in-progress',
      'Sample answers filled',
      Routes.setup,
      'Setup hub',
    );
    await h.page(
      f,
      'Name-and-birthday',
      'Filled',
      Routes.setupName,
      'Setup > Name and birthday',
    );
    await h.sheet(
      f,
      'Confirm-age-sheet',
      'Sheet open',
      'Name and birthday > Next',
      () async {
        await h.go(Routes.setupName);
        await tapNext(tester);
        await h.wait(800);
      },
    );
    await h.page(
      f,
      'Under-18',
      'Blocked from creating a profile',
      Routes.setupUnderage,
      'Name and birthday > under 18',
    );
    await h.page(f, 'Gender', 'Selected', Routes.setupGender, 'Setup > Gender');
    await h.sheet(
      f,
      'Gender-detail-sheet',
      'Sheet open',
      'Gender > Add more',
      () async {
        await h.go(Routes.setupGender);
        await h.tapText(_l.obGenderMore);
      },
    );
    await h.page(
      f,
      'Who-to-meet',
      'Selected',
      Routes.setupMeet,
      'Setup > Who to meet',
    );
    await h.page(
      f,
      'Intentions',
      'Selected',
      Routes.setupIntentions,
      'Setup > Intentions',
    );
    await h.page(f, 'Height', 'Default', Routes.setupHeight, 'Setup > Height');
    await h.page(
      f,
      'Location',
      'Not set',
      Routes.setupLocation,
      'Setup > Location',
    );
    await h.sheet(
      f,
      'Location-permission-prompt',
      'In-app primer open',
      'Location > Use my location',
      () async {
        await h.go(Routes.setupLocation);
        await h.tapText(_l.obLocationUse);
      },
    );
    await h.sheet(
      f,
      'Choose-area-sheet',
      'Sheet open',
      'Location > Choose my area',
      () async {
        await h.go(Routes.setupLocation);
        await h.tapText(_l.obLocationChoose);
      },
    );
    await h.page(f, 'Photos', 'Three photos', Routes.photos, 'Setup > Photos');
    await h.sheet(f, 'Add-photo-sheet', 'Sheet open', 'Photos > +', () async {
      await h.go(Routes.photos);
      await h.tapLabel('Add a photo');
    });
    await h.sheet(
      f,
      'Photo-tips-sheet',
      'Sheet open',
      'Photos > Photo tips',
      () async {
        await h.go(Routes.photos);
        await h.tapText(_l.photoTipsLink);
      },
    );
    await h.page(
      f,
      'Interests',
      'Three chosen',
      Routes.interests,
      'Setup > Interests',
    );
    await h.page(
      f,
      'Prompts',
      'One answered',
      Routes.setupPrompts,
      'Setup > Prompts',
    );
    await h.page(
      f,
      'Prompt-browser',
      'Choosing a prompt',
      '${Routes.prompt}?slot=1',
      'Prompts > Add a prompt',
    );
    await h.sheet(
      f,
      'Prompt-answer-sheet',
      'Sheet open',
      'Prompt browser > A prompt',
      () async {
        await h.go('${Routes.prompt}?slot=1');
        await h.tapText('A green flag');
      },
    );
    c
        .read(profileDetailsProvider.notifier)
        .setBio('Weekend baker, weekday map nerd. Always up for a long walk.');
    await h.page(f, 'Bio', 'Filled', Routes.setupBio, 'Setup > Bio');
    await h.page(
      f,
      'Verify-offer',
      'Offer',
      Routes.setupVerify,
      'Setup > Verify your photos',
    );
    await h.page(
      f,
      'Notifications',
      'Primer',
      Routes.setupNotifications,
      'Setup > Notifications',
    );
    await h.page(f, 'Review', 'Complete', Routes.setupReview, 'Setup > Review');
    await h.page(
      f,
      'All-set',
      'Welcome credits',
      Routes.setupDone,
      'Review > Create my profile',
    );
    // ignore: avoid_print
    print('@@DONE@@');
  });

  testWidgets('signed-in product', (tester) async {
    if (!_wants('product')) return;
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    c
        .read(profileDetailsProvider.notifier)
        .setBio('Weekend baker, weekday map nerd. Always up for a long walk.');
    final h = _H(tester, c);
    await h.wait(1500);
    Future<void> premium(bool on) async {
      c.read(premiumProvider.notifier).setActive(on);
      await h.wait(400);
    }

    // Discover.
    {
      const f = _discover;
      await h.page(
        f,
        'Discover-profile',
        'Populated card',
        Routes.home,
        'Tab: Discover',
      );
      await h.sheet(
        f,
        'Filters-sheet-basic',
        'Basic tab',
        'Discover > Filters',
        () async {
          await h.go(Routes.home);
          await h.tapLabel('Filters');
        },
      );
      await h.sheet(
        f,
        'Filters-sheet-advanced',
        'Advanced tab, free member',
        'Discover > Filters > Advanced',
        () async {
          await h.go(Routes.home);
          await h.tapLabel('Filters');
          await h.tapText(_l.filtersAdvanced);
        },
      );
      await h.sheet(
        f,
        'Profile-options-menu',
        'Action sheet',
        'Discover > ...',
        () async {
          await h.go(Routes.home);
          await h.tapLabel(_l.discoverOptions);
        },
      );
      await h.page(
        f,
        'For-you',
        'Populated',
        Routes.forYou,
        'Discover > For you',
      );
      await h.page(
        f,
        'Person-profile-decide',
        'Like and pass available',
        '${Routes.person}/noor?decide=1',
        'Discover > Open profile',
      );
      await h.page(
        f,
        'Person-profile-view',
        'View only',
        '${Routes.person}/maya',
        'Chats or Likes > View profile',
      );
      await h.page(
        f,
        'Photo-viewer',
        'Photo 1',
        Routes.personPhotos('maya'),
        'Profile > Photo',
      );
      await h.page(
        f,
        'Allowance-used',
        'Free likes used',
        Routes.allowance,
        'Discover > Like limit reached',
      );
      await h.step('empty', () async {
        c
            .read(discoveryFiltersProvider.notifier)
            .save(const DiscoveryFilters(minAge: 60, maxAge: 60));
        await h.go(Routes.home);
        await h.shot(
          f,
          'Discover-no-one-fits',
          'Empty, filters too narrow',
          'Discover with narrow filters',
        );
        c.read(discoveryFiltersProvider.notifier).reset();
      });
    }

    // Likes and Compliments.
    {
      const f = _likes;
      await h.page(
        f,
        'Likes-free-locked',
        'Free member, blurred',
        Routes.likes,
        'Tab: Likes',
      );
      await h.step('Likes premium', () async {
        await premium(true);
        await h.go(Routes.home);
        await h.go(Routes.likes);
        await h.shot(
          f,
          'Likes-premium-grid',
          'Premium member',
          'Tab: Likes (Premium)',
        );
        await h.go('${Routes.like}/kemi');
        await h.shot(
          f,
          'Incoming-like-profile',
          'Like back available',
          'Likes > A person',
        );
        await premium(false);
      });
      await h.step('Compliments', () async {
        await h.go(Routes.home);
        await h.go('${Routes.likes}?tab=compliments');
        await h.shot(
          f,
          'Compliments-populated',
          'Three requests',
          'Tab: Likes > Compliments',
        );
      });
      await h.page(
        f,
        'Compliment-request-photo',
        'On a photo',
        '${Routes.request}/seed-sam',
        'Compliments > Sam',
      );
      await h.page(
        f,
        'Compliment-request-prompt',
        'On a prompt',
        '${Routes.request}/seed-chloe',
        'Compliments > Chloe',
      );
      await h.sheet(
        f,
        'Compliment-options-menu',
        'Action sheet',
        'Compliment > ...',
        () async {
          await h.go('${Routes.request}/seed-sam');
          await h.tapLabel(_l.discoverOptions);
        },
      );
      await h.sheet(
        f,
        'Dismiss-compliment-sheet',
        'Confirm',
        'Compliment > Dismiss',
        () async {
          await h.go('${Routes.request}/seed-sam');
          await h.tapKey('request-dismiss');
        },
      );
      await h.page(
        f,
        'Send-compliment-prompt',
        'Empty, on a prompt',
        '${Routes.compliment}/noor?kind=prompt&index=0',
        'Discover > Compliment on a prompt',
      );
      await h.page(
        f,
        'Send-compliment-photo',
        'Empty, on a photo',
        '${Routes.compliment}/lea?kind=photo&index=0',
        'Discover > Compliment on a photo',
      );
      await h.step('Compliment typed', () async {
        await h.go('${Routes.compliment}/noor?kind=prompt&index=0');
        await h.type(
          find.byKey(const ValueKey('compliment-field')),
          'Your answer is exactly my kind of Sunday.',
        );
        await h.shot(
          f,
          'Send-compliment-typed',
          'Text entered, Send enabled',
          'Compliment composer',
        );
      });
      await h.page(
        f,
        'Match',
        'New match',
        '${Routes.match}/maya',
        'Discover > Mutual like',
      );
    }

    // Messages list.
    {
      const f = _messages;
      await h.page(
        f,
        'Messages-all',
        'Populated, All filter',
        Routes.messages,
        'Tab: Chats',
      );
      await h.step('Unread', () async {
        await h.go(Routes.messages);
        await h.tapContaining(_l.convFilterUnread);
        await h.shot(f, 'Messages-unread', 'Unread filter', 'Chats > Unread');
      });
      await h.step('Your move', () async {
        await h.go(Routes.messages);
        await h.tapContaining(_l.convFilterMove);
        await h.shot(
          f,
          'Messages-your-move',
          'Your move filter',
          'Chats > Your move',
        );
        await h.tapContaining(_l.convFilterAll);
      });
      await h.step('Search', () async {
        await h.go(Routes.messages);
        await h.tapLabel(_l.messagesSearch);
        await h.shot(f, 'Messages-search', 'Search open', 'Chats > Search');
        await h.go(Routes.home);
      });
      await h.page(
        f,
        'Archive',
        'Populated',
        Routes.archive,
        'Chats > Archive',
      );
    }

    // Chat.
    {
      const f = _chat;
      const priya = '${Routes.chat}/priya';
      await h.page(
        f,
        'Chat-active',
        'Conversation history',
        priya,
        'Chats > Priya',
      );
      await h.step('Keyboard', () async {
        await h.go(priya);
        await tester.tap(find.byType(TextField).last);
        await h.shot(
          f,
          'Chat-keyboard-open',
          'Intentional: on-screen keyboard open',
          'Chat > Tap message field',
          keepFocus: true,
          scroll: false,
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await h.wait(1500);
      });
      await h.page(
        f,
        'Chat-new-match',
        'First message',
        '${Routes.chat}/jo',
        'Chats > New match',
      );
      await h.page(
        f,
        'Chat-expiring',
        'Match about to run out',
        '${Routes.chat}/lina',
        'Chats > Expiring match',
      );
      await h.page(
        f,
        'Chat-archived',
        'Quiet chat',
        '${Routes.chat}/ade',
        'Archive > Ade',
      );
      await h.page(
        f,
        'Chat-expired',
        'Match ran out',
        '${Routes.chat}/ollie',
        'Archive > Ollie',
      );
      Future<void> options() async {
        await h.go(priya);
        await h.tapLabel('Conversation options');
      }

      await h.sheet(
        f,
        'Chat-options-menu',
        'Action sheet',
        'Chat > ...',
        options,
      );
      await h.sheet(
        f,
        'Share-date-details-sheet',
        'Sheet open',
        'Chat > ... > Share date details',
        () async {
          await options();
          await h.tapText(_l.optionShareDate);
        },
      );
      await h.sheet(
        f,
        'Did-you-meet-sheet',
        'Sheet open',
        'Chat > ... > Did you meet?',
        () async {
          await options();
          await h.tapText(_l.optionDidYouMeet);
        },
      );
      await h.sheet(
        f,
        'Unmatch-sheet',
        'Sheet open',
        'Chat > ... > Unmatch',
        () async {
          await options();
          await h.tapText(_l.optionUnmatch);
        },
      );
      await h.sheet(
        f,
        'Message-actions-menu',
        'Long press on a message',
        'Chat > Long press message',
        () async {
          await h.go(priya);
          await tester.longPress(
            find
                .byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith('message-'),
                )
                .last,
          );
          await h.wait(900);
        },
      );
      await h.step('Reply', () async {
        await h.go(priya);
        await tester.longPress(
          find
              .byWidgetPredicate(
                (w) =>
                    w.key is ValueKey<String> &&
                    (w.key! as ValueKey<String>).value.startsWith('message-'),
              )
              .last,
        );
        await h.wait(900);
        await h.tapText(_l.chatReply);
        await h.shot(
          f,
          'Chat-replying',
          'Reply preview above the composer',
          'Chat > Long press > Reply',
          scroll: false,
        );
        await h.go(Routes.messages);
      });
    }

    // Profile.
    {
      const f = _profile;
      await h.page(
        f,
        'Profile-hub',
        'Populated',
        Routes.profile,
        'Tab: Profile',
      );
      await h.page(
        f,
        'Edit-profile',
        'Populated',
        Routes.editProfile,
        'Profile > Edit profile',
      );
      await h.page(
        f,
        'Edit-basics',
        'Populated',
        Routes.editBasics,
        'Edit profile > The basics',
      );
      await h.page(
        f,
        'Edit-interests',
        'Populated',
        Routes.editInterests,
        'Edit profile > Interests',
      );
      await h.page(
        f,
        'Edit-photos',
        'Populated',
        Routes.editPhotos,
        'Edit profile > Photos',
      );
      await h.page(
        f,
        'Edit-prompt',
        'Choosing a prompt',
        '${Routes.editPrompt}?slot=1',
        'Edit profile > Add a prompt',
      );
      await h.sheet(
        f,
        'Edit-bio-sheet',
        'Sheet open',
        'Edit profile > Bio',
        () async {
          await h.go(Routes.editProfile);
          await h.tapContaining('Weekend baker');
        },
      );
      await h.sheet(
        f,
        'Height-sheet',
        'Sheet open',
        'Edit profile > Height',
        () async {
          await h.go(Routes.editProfile);
          await h.tapText(_l.editHeight);
        },
      );
      await h.sheet(
        f,
        'Languages-sheet',
        'Sheet open',
        'Edit profile > Languages',
        () async {
          await h.go(Routes.editProfile);
          await h.tapText(_l.editLanguages);
        },
      );
      await h.sheet(
        f,
        'Work-sheet',
        'Text field sheet',
        'Edit profile > Work',
        () async {
          await h.go(Routes.editProfile);
          await h.tapText('Work');
        },
      );
      await h.sheet(
        f,
        'Exercise-choice-sheet',
        'Choice sheet',
        'Edit profile > Exercise',
        () async {
          await h.go(Routes.editProfile);
          await h.tapText('Exercise');
        },
      );
      await h.page(
        f,
        'Profile-setup-hub',
        'Five of six done',
        Routes.completion,
        'Profile > Profile setup',
      );
      await h.page(
        f,
        'Profile-preview',
        'As others see you',
        Routes.preview,
        'Edit profile > Preview',
      );
      await h.step('Verify', () async {
        await h.go(Routes.verifyPhoto);
        await h.shot(
          f,
          'Photo-verification-intro',
          'Before starting',
          'Profile > Verify my profile',
        );
        await h.tapText(_l.verifyStart);
        await h.wait(800);
        await h.shot(
          f,
          'Photo-verification-pose',
          'Pose prompt',
          'Photo verification > Start',
        );
      });
    }

    // Events.
    {
      const f = _events;
      const board = 'ev-board-games-bandra';
      await h.page(
        f,
        'Events-feed',
        'Mumbai, populated',
        Routes.events,
        'Tab: Events',
      );
      await h.sheet(
        f,
        'City-picker-sheet',
        'Sheet open',
        'Events > City',
        () async {
          await h.go(Routes.events);
          await h.tapKey('ev-city');
        },
      );
      await h.step('Empty city', () async {
        c.read(eventsMvpProvider.notifier).setCity('Jaipur');
        await h.go(Routes.home);
        await h.go(Routes.events);
        await h.shot(
          f,
          'Events-empty-city',
          'No events in Jaipur',
          'Events > City > Jaipur',
        );
        c.read(eventsMvpProvider.notifier).setCity('Mumbai');
      });
      await h.page(
        f,
        'Event-detail',
        'Places available',
        '${Routes.evEvent}/$board',
        'Events > Board games',
      );
      await h.page(
        f,
        'Event-detail-full',
        'Full',
        '${Routes.evEvent}/ev-coffee-indiranagar',
        'Events > Saturday coffee',
      );
      await h.page(
        f,
        'Event-detail-cancelled',
        'Cancelled',
        '${Routes.evEvent}/ev-pottery-hauz-khas',
        'Events > Pottery',
      );
      await h.page(
        f,
        'Event-detail-reserved',
        'Already reserved',
        '${Routes.evEvent}/ev-sunrise-walk',
        'My events > Sunrise walk',
      );
      await h.sheet(
        f,
        'Report-event-sheet',
        'Sheet open',
        'Event > Report or get help',
        () async {
          await h.go('${Routes.evEvent}/$board');
          await h.tapLabel('Report or get help');
        },
      );
      await h.step('Reserve', () async {
        await h.go('${Routes.evEvent}/$board/reserve');
        await h.shot(
          f,
          'Reserve',
          'Before acknowledging',
          'Event > Reserve a free place',
        );
        await h.tapKey('ev-ack');
        await h.shot(
          f,
          'Reserve-acknowledged',
          'Ready to confirm',
          'Reserve > Tick acknowledgement',
        );
        await h.tapKey('ev-confirm');
        await h.wait(900);
        await h.shot(
          f,
          'Reserve-confirmed',
          'Place reserved',
          'Reserve > Confirm',
        );
      });
      await h.page(
        f,
        'My-events-upcoming',
        'Upcoming',
        Routes.evMine,
        'Events > My events',
      );
      await h.page(
        f,
        'Reservation',
        'Confirmed',
        '${Routes.evReservation}/$board',
        'My events > An event',
      );
      await h.page(
        f,
        'Notice-time-or-place-change',
        'Reconfirm needed',
        '${Routes.evNotice}/n-walk-v2',
        'My events > Updates',
      );
      await h.step('Reconfirmed', () async {
        await h.go('${Routes.evNotice}/n-walk-v2');
        await h.tapKey('ev-reconfirm');
        await h.shot(
          f,
          'Notice-reconfirmed',
          'Place kept',
          'Update > Keep my place',
        );
      });
      await h.page(
        f,
        'Notice-announcement',
        'Ordinary update',
        '${Routes.evNotice}/n-cycle-1',
        'Reservation > Update',
      );
      await h.page(
        f,
        'Notice-event-cancelled',
        'Event cancelled',
        '${Routes.evNotice}/n-pottery-cancel',
        'My events > Update',
      );
      await h.step('Cancel', () async {
        await h.go('${Routes.evReservation}/$board');
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('ev-cancel')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await h.tapKey('ev-cancel');
        await h.shot(
          f,
          'Cancel-reservation-sheet',
          'Confirm',
          'Reservation > Cancel reservation',
          sheet: true,
        );
        await h.tapKey('ev-cancel-confirm');
        await h.go(Routes.evMine);
        await h.tapKey('ev-mine-cancelled');
        await h.shot(
          f,
          'My-events-cancelled',
          'Cancelled tab',
          'My events > Cancelled',
        );
        await h.tapKey('ev-mine-past');
        await h.shot(f, 'My-events-past', 'Past tab', 'My events > Past');
      });
      await h.step('Met', () async {
        await h.go('${Routes.evMet}/ev-book-swap');
        await h.shot(
          f,
          'People-I-met',
          'Populated',
          'Past event > People I met',
        );
        await h.tapKey('ev-interested-tomas');
        await h.shot(
          f,
          'People-I-met-interest-sent',
          'Interest sent',
          'People I met > Interested',
        );
        await h.tapKey('ev-interested-sam');
        await h.shot(
          f,
          'Mutual-interest-sheet',
          'Mutual',
          'People I met > Interested in Sam',
          sheet: true,
        );
        await h.pop();
      });
      await h.page(
        f,
        'Event-proposals',
        'Pending decision O1',
        Routes.evProposals,
        'Events > Propose an event',
      );
      await h.page(
        f,
        'Event-proposal-form',
        'Returned with a note',
        '${Routes.evPropose}/p-chess',
        'Proposals > Chess',
      );
    }

    // Streak, wallet, store.
    await h.page(
      _streak,
      'Streak',
      'Recovery open',
      Routes.streak,
      'Profile > Streak',
    );
    await h.page(
      _streak,
      'Streak-repair-purchase',
      'Before buying',
      Routes.storeRecovery,
      'Streak > Repair',
    );
    {
      const f = _wallet;
      await h.page(
        f,
        'Wallet-free',
        'Free member',
        Routes.wallet,
        'Profile > Compliment credits',
      );
      await h.step('Wallet premium', () async {
        await premium(true);
        await h.go(Routes.home);
        await h.go(Routes.wallet);
        await h.shot(
          f,
          'Wallet-premium',
          'Premium member',
          'Profile > Compliment credits',
        );
        await premium(false);
      });
      await h.page(
        f,
        'Compliment-pack',
        'Before buying',
        Routes.storeCompliments,
        'Wallet > Get more',
      );
      for (final r in [
        'success',
        'pending',
        'failed',
        'cancelled',
        'unavailable',
      ]) {
        await h.page(
          f,
          'Purchase-$r',
          'Purchase outcome',
          '${Routes.storeOutcome}?kind=complimentPack&result=$r',
          'Store > Purchase result',
        );
      }
    }

    // Premium.
    {
      const f = _premium;
      await h.page(
        f,
        'Premium-overview-free',
        'Free member',
        Routes.premium,
        'Profile > Numaya Premium',
      );
      await h.step('Premium active', () async {
        await premium(true);
        await h.go(Routes.home);
        await h.go(Routes.premium);
        await h.shot(
          f,
          'Premium-overview-active',
          'Premium member',
          'Profile > Numaya Premium',
        );
        await premium(false);
      });
      await h.page(
        f,
        'Paywall',
        'Plans',
        Routes.paywall,
        'Any Premium feature',
      );
      await h.step('Yearly', () async {
        await h.go(Routes.home);
        await h.go(Routes.paywall);
        await h.tapKey('plan-premiumYearly');
        await h.shot(
          f,
          'Paywall-yearly-selected',
          'Yearly selected',
          'Paywall > Yearly',
        );
        await h.tapContaining('Continue with');
        await h.shot(
          f,
          'Checkout-sheet',
          'Demo checkout',
          'Paywall > Continue',
          sheet: true,
        );
        await h.pop();
      });
    }

    // Settings.
    {
      const f = _settings;
      await h.page(
        f,
        'Settings',
        'Populated',
        Routes.settings,
        'Profile > Settings',
      );
      await h.sheet(
        f,
        'Snooze-sheet',
        'Sheet open',
        'Settings > Snooze',
        () async {
          await h.go(Routes.settings);
          await tapOn(tester, find.byType(NumayaSwitch).first);
          await h.wait(800);
        },
      );
      await h.sheet(
        f,
        'Recovery-email-sheet',
        'Sheet open',
        'Settings > Recovery email',
        () async {
          await h.go(Routes.settings);
          await h.tapText(_l.recoveryEmailLabel);
        },
      );
      await h.sheet(
        f,
        'Travel-sheet',
        'Premium member',
        'Settings > Travel',
        () async {
          await premium(true);
          await h.go(Routes.home);
          await h.go(Routes.settings);
          await h.tapText(_l.travelTitle);
        },
      );
      await premium(false);
      await h.sheet(
        f,
        'Sign-out-sheet',
        'Confirm',
        'Settings > Sign out',
        () async {
          await h.go(Routes.settings);
          await h.tapText(_l.settingsSignOut);
        },
      );
      await h.page(
        f,
        'Notification-settings',
        'Populated',
        Routes.notifications,
        'Settings > Notifications',
      );
      await h.page(
        f,
        'Privacy',
        'Populated',
        Routes.privacy,
        'Settings > Privacy',
      );
      await h.step('Blocked', () async {
        c.read(datingProvider.notifier).end('sasha', EndReason.blocked);
        await h.go(Routes.blocked);
        await h.shot(
          f,
          'Blocked-people',
          'One blocked',
          'Settings > Blocked people',
        );
      });
      await h.page(
        f,
        'Delete-account',
        'Before confirming',
        Routes.deleteAccount,
        'Settings > Delete account',
      );
    }

    // Safety, help, legal.
    {
      const f = _safety;
      await h.page(
        f,
        'Safety-centre',
        'Populated',
        Routes.safety,
        'Settings > Safety and wellbeing',
      );
      await h.sheet(
        f,
        'Report-person-sheet',
        'Sheet open',
        'Chat > ... > Report',
        () async {
          await h.go('${Routes.chat}/priya');
          await h.tapLabel('Conversation options');
          await h.tapText(_l.optionReport);
        },
      );
      await h.sheet(
        f,
        'Block-person-sheet',
        'Sheet open',
        'Chat > ... > Block',
        () async {
          await h.go('${Routes.chat}/priya');
          await h.tapLabel('Conversation options');
          await h.tapText(_l.optionBlockShort);
        },
      );
      await h.page(
        f,
        'Help-centre',
        'Populated',
        Routes.help,
        'Settings > Help centre',
      );
      await h.page(
        f,
        'Help-article',
        'First article',
        '${Routes.help}/${kHelpArticles.first.id.name}',
        'Help centre > An article',
      );
      await h.page(
        f,
        'Contact-support',
        'Empty form',
        Routes.helpContact,
        'Help centre > Contact support',
      );
      await h.page(
        f,
        'Support-requests',
        'Populated',
        Routes.supportRequests,
        'Settings > Support requests',
      );
      await h.page(f, 'Legal', 'Index', Routes.legal, 'Settings > Legal');
      for (final (d, n) in [
        ('privacy', 'Privacy'),
        ('terms', 'Terms'),
        ('community', 'Community'),
        ('safety', 'Safety'),
      ]) {
        await h.page(
          f,
          'Legal-$n',
          'Document',
          '${Routes.legal}/$d',
          'Legal > $n',
        );
      }
    }

    // Account states, then the two that change the session.
    {
      const f = _account;
      await h.page(
        f,
        'Account-restricted',
        'Appeal available',
        Routes.accountBlocked,
        'Server restriction',
      );
      await h.page(
        f,
        'Page-not-found',
        'Unknown link',
        '/this-page-does-not-exist',
        'Unknown deep link',
      );
      await h.step('Out of likes', () async {
        c.read(economyProvider.notifier).exhaustLikes();
        await h.go(Routes.profile);
        await h.go(Routes.home);
        await h.shot(
          _discover,
          'Discover-out-of-likes',
          'Daily likes used',
          'Discover after the last like',
        );
      });
      await h.step('Reauth', () async {
        c.read(sessionExpiryProvider.notifier).expire();
        await h.wait(1500);
        await h.shot(f, 'Session-expired', 'Sign in again', 'Session expiry');
      });
    }
    // ignore: avoid_print
    print('@@DONE@@');
  });

  // Run with ONLY=fix after the full pass: states that need a reset first or a side effect, numbered
  // to land in their flow folders.
  testWidgets('supplementary states', (tester) async {
    if (_only != 'fix') return;
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    final h = _H(tester, c);
    await h.wait(1500);
    _counts[_onboarding] = 23;
    await h.sheet(
      _onboarding,
      'Prompt-answer-sheet',
      'Sheet open',
      'Prompt browser > A prompt',
      () async {
        await h.go('${Routes.prompt}?slot=1');
        await h.tapText('A green flag');
      },
    );
    _counts[_onboarding] = 29;
    await h.sheet(
      _onboarding,
      'Photo-options-menu',
      'Action sheet',
      'Photos > A photo',
      () async {
        await h.go(Routes.photos);
        await h.tapLabel('Photo 2 options');
      },
    );
    _counts[_chat] = 11;
    await h.step('Reply', () async {
      await h.go(Routes.messages);
      await h.go('${Routes.chat}/priya');
      await h.wait(1200);
      final bubble = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('message-'),
      );
      await tester.longPress(bubble.at(bubble.evaluate().length - 2));
      await h.wait(1200);
      await h.tapText(_l.chatReply);
      await h.wait(800);
      await h.shot(
        _chat,
        'Chat-replying',
        'Reply preview above the composer',
        'Chat > Long press > Reply',
        scroll: false,
      );
      await h.go(Routes.messages);
    });
    _counts[_settings] = 9;
    await h.step('Delete confirm', () async {
      await h.go(Routes.deleteAccount);
      await h.tapText('I met someone');
      await h.tapText('Continue');
      await h.shot(
        _settings,
        'Delete-confirm-sheet',
        'Final confirmation, not confirmed',
        'Delete account > Continue',
        sheet: true,
      );
      await h.pop();
    });
    _counts[_safety] = 4;
    await h.page(
      _safety,
      'Help-article',
      'First article',
      '${Routes.help}/${kHelpArticles.first.id.name}',
      'Help centre > An article',
    );
    _counts[_safety] = 12;
    await h.step('Support populated', () async {
      await h.go(Routes.helpContact);
      await h.tapText('My account');
      await h.type(
        find.byType(TextField).last,
        'I need help updating my phone number.',
      );
      await h.tapText('Send message');
      await h.wait(1200);
      await h.go(Routes.supportRequests);
      await h.shot(
        _safety,
        'Support-requests-populated',
        'One open request',
        'Contact support > Send > Support requests',
      );
    });
    // ignore: avoid_print
    print('@@DONE@@');
  });
}
