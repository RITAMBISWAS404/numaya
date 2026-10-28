import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/account_health/application/visibility_report.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/domain/profile_details.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/test_app.dart';

const _ready = ProfileDraft(
  firstName: 'Ana',
  interests: ['Jazz', 'Poetry', 'Travel'],
  prompt: PromptAnswer(question: 'Q', answer: 'A real answer'),
  photos: [DraftPhoto(id: 1, tone: 0), DraftPhoto(id: 2, tone: 1)],
);

VisibilityReport _report({
  ProfileDraft draft = _ready,
  ProfileDetails details = const ProfileDetails(area: 'Hackney, London'),
  bool hasProfile = true,
  bool paused = false,
  bool incognito = false,
  int fit = 5,
  int deck = 7,
  PhotoVerificationState photo = const PhotoVerificationState(),
  AccountSignals signals = const AccountSignals(),
  ActivityCounts counts = const ActivityCounts(
    likes: 3,
    matches: 1,
    conversations: 1,
  ),
}) => VisibilityReport.of(
  hasProfile: hasProfile,
  signedIn: true,
  paused: paused,
  pausedUntil: null,
  incognito: incognito,
  draft: draft,
  details: details,
  filtersFit: fit,
  deckSize: deck,
  photo: photo,
  signals: signals,
  counts: counts,
  now: testNow,
);

void main() {
  group('Visibility status (METRICS §1)', () {
    test('ready profile, no notices: visible', () {
      expect(_report().status, VisibilityStatus.visible);
      expect(_report().missing, isEmpty);
    });

    test('paused says paused, and Resume is the first suggestion', () {
      final r = _report(paused: true);
      expect(r.status, VisibilityStatus.paused);
      expect(r.suggestions.first, Suggestion.resume);
    });

    test('a restriction from the notice source wins over everything', () {
      final r = _report(
        paused: true,
        signals: const AccountSignals(notice: NoticeState.restricted),
      );
      expect(r.status, VisibilityStatus.actionNeeded);
      expect(r.suggestions.first, Suggestion.reviewRestriction);
    });

    test('missing Discover requirements are named', () {
      final r = _report(
        draft: const ProfileDraft(photos: [DraftPhoto(id: 1, tone: 0)]),
        hasProfile: false,
      );
      expect(r.status, VisibilityStatus.actionNeeded);
      expect(r.missing, [
        Requirement.profile,
        Requirement.photos,
        Requirement.interests,
        Requirement.prompt,
      ]);
    });

    test(
      'an unanswered notice source is "can’t check", never an all-clear',
      () {
        final r = _report(
          signals: const AccountSignals(notice: NoticeState.unavailable),
        );
        expect(r.status, VisibilityStatus.cantCheck);
      },
    );

    test('Incognito is limited', () {
      expect(_report(incognito: true).status, VisibilityStatus.limited);
    });

    test('a notice that doesn’t hide the profile keeps it visible', () {
      final r = _report(
        signals: const AccountSignals(notice: NoticeState.notice),
      );
      expect(r.status, VisibilityStatus.visible);
      expect(r.suggestions.first, Suggestion.readNotice);
    });
  });

  group('Activity never decides status (METRICS §7)', () {
    test('zero activity: still visible, and shown as "not enough data"', () {
      final r = _report(
        counts: const ActivityCounts(likes: 0, matches: 0, conversations: 0),
      );
      expect(r.status, VisibilityStatus.visible);
      expect(r.activity!.empty, isTrue);
      expect(r.suggestions, isNot(contains(Suggestion.reviewFilters)));
    });

    test('unavailable insights hide the numbers instead of inventing them', () {
      final r = _report(
        signals: const AccountSignals(insights: InsightsState.unavailable),
      );
      expect(r.activity, isNull);
      expect(r.status, VisibilityStatus.visible);
    });

    test('stale insights keep the numbers with the state', () {
      final r = _report(
        signals: const AccountSignals(insights: InsightsState.stale),
      );
      expect(r.activity!.likes, 3);
      expect(r.insights, InsightsState.stale);
    });
  });

  group('Completeness and suggestions (METRICS §3, §8)', () {
    test('completeness is the shared ProfileCompletion value', () {
      final a = _report().completion.percent;
      final b = _report(
        details: const ProfileDetails(
          area: 'Hackney, London',
          bio: 'Designer by day.',
        ),
      ).completion.percent;
      expect(b, greaterThan(a));
      expect(b - a, (1 / 6 * 100).round());
    });

    test('suggestions are capped at five and say nothing about activity', () {
      final r = _report(details: const ProfileDetails(), fit: 0, paused: true);
      expect(r.suggestions, hasLength(VisibilityReport.maxSuggestions));
      expect(r.suggestions.first, Suggestion.resume);
    });

    test('filters are only flagged when nobody fits', () {
      expect(
        _report(
          details: const ProfileDetails(bio: 'x', area: 'Bristol'),
          fit: 1,
        ).suggestions,
        isNot(contains(Suggestion.reviewFilters)),
      );
      final r = VisibilityReport.of(
        hasProfile: true,
        signedIn: true,
        paused: false,
        pausedUntil: null,
        incognito: false,
        draft: _ready,
        details: const ProfileDetails(area: 'Bristol'),
        filtersFit: 0,
        deckSize: 6,
        photo: const PhotoVerificationState(
          status: PhotoVerificationStatus.verified,
        ),
        signals: const AccountSignals(),
        counts: const ActivityCounts(likes: 0, matches: 0, conversations: 0),
        now: testNow,
      );
      expect(r.suggestions, contains(Suggestion.reviewFilters));
    });

    test('verification is suggested only when not started or retryable', () {
      expect(_report().suggestions, contains(Suggestion.verifyPhoto));
      expect(
        _report(
          photo: const PhotoVerificationState(
            status: PhotoVerificationStatus.verified,
          ),
        ).suggestions,
        isNot(contains(Suggestion.verifyPhoto)),
      );
      expect(
        _report(
          photo: const PhotoVerificationState(
            status: PhotoVerificationStatus.rejected,
            attempts: 3,
          ),
        ).suggestions,
        isNot(contains(Suggestion.verifyPhoto)),
      );
    });
  });

  test('no copy claims a shadowban, a penalty or a ranking', () {
    final arb = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final vis = [
      for (final e in arb.entries)
        if (e.key.startsWith('vis') && e.value is String) e.value as String,
    ];
    expect(vis, isNotEmpty);
    for (final s in vis) {
      final t = s.toLowerCase();
      expect(t, isNot(contains('shadowban')), reason: s);
      // The only mention of a score says there isn't one.
      if (!t.contains('there is no combined score')) {
        expect(t, isNot(contains('score')), reason: s);
      }
      expect(
        RegExp(r'\branked\b|\bdeprioriti').hasMatch(t),
        isFalse,
        reason: s,
      );
    }
  });
}
