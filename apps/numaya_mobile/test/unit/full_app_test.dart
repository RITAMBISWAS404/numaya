import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/profile/domain/profile_details.dart';
import 'package:numaya_mobile/features/settings/application/account_prefs.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;
  DatingController dating() => container.read(datingProvider.notifier);
  DatingState state() => container.read(datingProvider);

  setUp(
    () => container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => testNow),
        demoWorldProvider.overrideWith(() => FixedWorld(DemoWorld.full)),
      ],
    ),
  );
  tearDown(() => container.dispose());

  group('Full demo world', () {
    test('seeds matches, the queue with expiry and sample conversations', () {
      expect(dating().newMatches().map((p) => p.id), ['jo', 'amara', 'lina']);
      expect(dating().expiredMatches().map((p) => p.id), ['ollie']);
      expect(dating().remaining('jo'), const Duration(hours: 21));
      expect(dating().conversations().map((p) => p.id), [
        'priya',
        'sasha',
        'rafa',
      ]);
      expect(dating().unread('priya'), 2);
      expect(dating().yourMove('priya'), isTrue);
      expect(dating().yourMove('rafa'), isFalse);
      // Seeded messages are marked as samples on both sides.
      expect(state().threads['sasha']!.every((m) => m.sample), isTrue);
      expect(state().threads['sasha']!.any((m) => !m.mine), isTrue);
    });

    test('opening a chat clears unread; sending never adds a reply', () async {
      dating().openChat('priya');
      expect(dating().unread('priya'), 0);
      await dating().send('priya', 'Not yet!');
      final thread = state().threads['priya']!;
      expect(thread.last.mine, isTrue);
      expect(thread.last.sample, isFalse);
      expect(thread.last.status, MessageStatus.onDevice);
      expect(dating().yourMove('priya'), isFalse);
    });

    test('the deck is larger and seeded matches never appear in it', () {
      container.read(discoveryFiltersProvider.notifier).broaden();
      final ids = dating().queue().map((p) => p.id).toList();
      expect(ids, containsAll(['ben', 'chloe', 'ade', 'mira', 'finn']));
      expect(ids, isNot(contains('priya')));
    });
  });

  group('Expiry, Extend and Rematch', () {
    test('one free Extend a day; then Premium is needed', () {
      expect(dating().extend('lina'), ExtendResult.extended);
      expect(dating().remaining('lina'), const Duration(hours: 24));
      expect(dating().freeExtendAvailable, isFalse);
      expect(dating().extend('amara'), ExtendResult.needsPremium);
      container.read(premiumProvider.notifier).setActive(true);
      expect(dating().extend('amara'), ExtendResult.extended);
    });

    test('Rematch needs Premium and restarts the window', () {
      expect(dating().rematch('ollie'), ExtendResult.needsPremium);
      container.read(premiumProvider.notifier).setActive(true);
      expect(dating().rematch('ollie'), ExtendResult.extended);
      expect(dating().isExpired('ollie'), isFalse);
      expect(dating().newMatches().map((p) => p.id), contains('ollie'));
    });

    test('a match with messages never expires', () {
      expect(dating().extend('priya'), ExtendResult.notNeeded);
      expect(dating().isExpired('priya'), isFalse);
    });
  });

  group('SuperSwipe credits', () {
    test('three free, then bought ones, then none', () {
      for (final id in ['sam', 'noor', 'ines']) {
        expect(dating().superSwipe(id), isNotNull);
      }
      expect(dating().superSwipesLeft, 0);
      expect(dating().superSwipe('lea'), isNull);
    });
  });

  group('Filters', () {
    test('verified only and who-to-date narrow the deck', () {
      final all = dating().queue().length;
      final verified = dating().queue(
        const DiscoveryFilters(verifiedOnly: true),
      );
      expect(verified.every((p) => p.verified), isTrue);
      expect(verified.length, lessThan(all));
      final men = dating().queue(const DiscoveryFilters(genders: {Gender.man}));
      expect(men.every((p) => p.gender == Gender.man), isTrue);
    });

    test('advanced filters apply only with Premium', () {
      const tall = DiscoveryFilters(minHeightCm: 180, advancedFallback: false);
      final basic = dating().queue(tall).length;
      container.read(premiumProvider.notifier).setActive(true);
      final advanced = dating().queue(tall);
      expect(advanced.length, lessThan(basic));
      expect(advanced.every((p) => p.heightCm >= 180), isTrue);
    });

    test('a fallback shows people just outside when nobody fits', () {
      const narrow = DiscoveryFilters(minAge: 36, maxAge: 36);
      expect(dating().queue(narrow), isEmpty);
      final widened = dating().queue(narrow.copyWith(ageFallback: true));
      expect(widened.map((p) => p.age), everyElement(inInclusiveRange(34, 38)));
      expect(
        dating().showingFallback(narrow.copyWith(ageFallback: true)),
        isTrue,
      );
    });
  });

  group('For you', () {
    test('picks up to four undecided people, most in common first', () {
      final picks = dating().picks();
      expect(picks.length, 4);
      expect(
        picks.first.shared.length,
        greaterThanOrEqualTo(picks.last.shared.length),
      );
      dating().decide(picks.first.id, liked: false);
      expect(
        dating().picks().map((p) => p.id),
        isNot(contains(picks.first.id)),
      );
    });
  });

  group('Premium (simulated)', () {
    test(
      'a failed purchase changes nothing; a success activates a plan',
      () async {
        final premium = container.read(premiumProvider.notifier);
        expect(
          await premium.purchase(
            kPremiumPlans[0],
            simulate: PurchaseOutcome.failed,
          ),
          PurchaseOutcome.failed,
        );
        expect(container.read(premiumProvider).active, isFalse);
        await premium.purchase(kPremiumPlans[1]);
        final s = container.read(premiumProvider);
        expect(s.active, isTrue);
        expect(s.activeUntil, testNow.add(const Duration(days: 28)));
        expect(s.extraSuperSwipes, 5);
        premium.cancel();
        expect(container.read(premiumProvider).active, isFalse);
      },
    );

    test('Incognito and Travel need Premium', () {
      final premium = container.read(premiumProvider.notifier);
      premium.setIncognito(true);
      premium.setTravel('Lisbon');
      expect(container.read(premiumProvider).incognito, isFalse);
      expect(container.read(premiumProvider).travelCity, isNull);
      premium.setActive(true);
      premium.setTravel('Lisbon');
      expect(container.read(premiumProvider).travelCity, 'Lisbon');
    });
  });

  group('Photo verification (simulated)', () {
    test(
      'approves by default; a declined attempt counts towards support',
      () async {
        final v = container.read(photoVerificationProvider.notifier);
        v.setApproveNext(false);
        await v.submit();
        expect(
          container.read(photoVerificationProvider).status,
          PhotoVerificationStatus.rejected,
        );
        expect(container.read(photoVerificationProvider).attempts, 1);
        v.setApproveNext(true);
        await v.submit();
        expect(container.read(photoVerificationProvider).verified, isTrue);
      },
    );
  });

  group('Profile details and completion', () {
    test('edits raise the completion percentage', () {
      final d = container.read(profileDetailsProvider.notifier);
      const draft = ProfileDraft(
        interests: ['Jazz', 'Cooking', 'Travel'],
        photos: [DraftPhoto(id: 1, tone: 0), DraftPhoto(id: 2, tone: 1)],
        prompt: PromptAnswer(question: 'A green flag', answer: 'Yes'),
      );
      final before = ProfileCompletion.of(
        draft,
        container.read(profileDetailsProvider),
      ).percent;
      d
        ..setBio('Hello there')
        ..setAbout(AboutKey.work, 'Designer')
        ..setHeight(172)
        ..setDetail(DetailKey.drinking, 'Socially')
        ..setExtraPrompt(0, 'My Sunday ritual', 'Long walks');
      final after = ProfileCompletion.of(
        draft,
        container.read(profileDetailsProvider),
      ).percent;
      expect(after, greaterThan(before));
    });

    test('limits: three prompts, three Opening Moves, five languages', () {
      final d = container.read(profileDetailsProvider.notifier);
      for (var i = 0; i < 4; i++) {
        d.setExtraPrompt(i, 'Q$i', 'A$i');
        d.setOpeningMove(i, 'Move $i');
      }
      for (final l in kLanguages) {
        d.toggleLanguage(l);
      }
      final s = container.read(profileDetailsProvider);
      expect(s.extraPrompts.length, DetailRules.maxPrompts - 1);
      expect(s.openingMoves.length, DetailRules.maxOpeningMoves);
      expect(s.languages.length, DetailRules.maxLanguages);
      d.setOpeningMove(0, '');
      expect(container.read(profileDetailsProvider).openingMoves.length, 2);
    });
  });

  group('Account preferences', () {
    test('snooze length sets an end time; indefinite has none', () {
      final p = container.read(accountPrefsProvider.notifier);
      p.startSnooze(SnoozeLength.threeDays);
      expect(
        container.read(accountPrefsProvider).snoozeUntil,
        testNow.add(const Duration(hours: 72)),
      );
      p.setAwayStatus('I’m travelling');
      p.startSnooze(SnoozeLength.indefinite);
      expect(container.read(accountPrefsProvider).snoozeUntil, isNull);
      expect(container.read(accountPrefsProvider).awayStatus, isNull);
      p.endSnooze();
      expect(container.read(accountPrefsProvider).snoozedAt, isNull);
    });

    test('notification channels per category', () {
      final p = container.read(accountPrefsProvider.notifier);
      expect(p.muted(NotificationCategory.matches), isFalse);
      p.setChannel(
        NotificationCategory.matches,
        NotificationChannel.push,
        false,
      );
      p.setChannel(
        NotificationCategory.matches,
        NotificationChannel.inApp,
        false,
      );
      expect(p.muted(NotificationCategory.matches), isTrue);
      p.setCategory(NotificationCategory.matches, true);
      expect(
        container
            .read(accountPrefsProvider)
            .isOn(NotificationCategory.matches, NotificationChannel.push),
        isTrue,
      );
    });
  });
}
