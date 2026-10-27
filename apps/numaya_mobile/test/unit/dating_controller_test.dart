import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';

void main() {
  late ProviderContainer container;
  DatingController dating() => container.read(datingProvider.notifier);
  DatingState state() => container.read(datingProvider);
  List<String> queueIds([DiscoveryFilters? f]) => [
    for (final p in dating().queue(f)) p.id,
  ];

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('Discover', () {
    test(
      'starts with no matches and the people who fit the default filters',
      () {
        expect(state().matches, isEmpty);
        // Kemi has no prompt (not shown in Discover); Tomás is outside 24–38 / 25 km.
        expect(queueIds(), ['maya', 'sam', 'noor', 'ines', 'lea']);
        expect(dating().hiddenByFilters(), 1);
      },
    );

    test(
      'liking someone who liked you is a match; liking anyone else is not',
      () {
        expect(dating().decide('sam', liked: true), DecisionResult.liked);
        expect(dating().decide('maya', liked: true), DecisionResult.matched);
        expect(state().matches, ['maya']);
        expect(queueIds(), ['noor', 'ines', 'lea']);
        expect(dating().newMatches().map((p) => p.id), ['maya']);
        expect(dating().unopenedMatches(), 1);
      },
    );

    test('undo brings back only the last pass, once', () {
      dating().decide('maya', liked: false);
      dating().decide('sam', liked: false);
      dating().undo();
      expect(queueIds().first, 'sam');
      dating().undo();
      expect(queueIds().first, 'sam');
      expect(queueIds(), isNot(contains('maya')));
    });

    test('a like clears undo', () {
      dating().decide('maya', liked: false);
      dating().decide('sam', liked: true);
      dating().undo();
      expect(queueIds(), isNot(contains('maya')));
    });

    test(
      'widening filters shows the hidden person; show again resets passes',
      () {
        container.read(discoveryFiltersProvider.notifier).broaden();
        expect(queueIds(), contains('tomas'));
        expect(dating().hiddenByFilters(), 0);
        for (final id in queueIds()) {
          dating().decide(id, liked: false);
        }
        expect(queueIds(), isEmpty);
        dating().resetDiscovery();
        expect(queueIds(), hasLength(6));
      },
    );

    test('a draft of filters can be counted before saving', () {
      expect(
        dating()
            .queue(const DiscoveryFilters(minAge: 30, maxAge: 40))
            .map((p) => p.id),
        ['sam', 'lea'],
      );
    });
  });

  group('Likes', () {
    test(
      'lists the sample likes, newest first, with new and nearby filters',
      () {
        expect(dating().likes().map((l) => l.person.id), [
          'maya',
          'kemi',
          'noor',
          'ines',
          'tomas',
        ]);
        expect(dating().likes(LikeFilter.newLikes).map((l) => l.person.id), [
          'maya',
          'kemi',
          'noor',
        ]);
        expect(dating().likes(LikeFilter.nearby).map((l) => l.person.id), [
          'maya',
          'kemi',
        ]);
        expect(dating().unansweredLikes(), 5);
      },
    );

    test(
      'like back matches and stays listed as matched; pass removes the like',
      () {
        expect(dating().likeBack('kemi', liked: true), DecisionResult.matched);
        final kemi = dating().likes().firstWhere((l) => l.person.id == 'kemi');
        expect(kemi.matched, isTrue);
        expect(kemi.isNew, isFalse);
        dating().likeBack('tomas', liked: false);
        expect(
          dating().likes().map((l) => l.person.id),
          isNot(contains('tomas')),
        );
        expect(dating().unansweredLikes(), 3);
      },
    );
  });

  group('Messages', () {
    test(
      'a sent message stays on this device and is never delivered',
      () async {
        dating().decide('maya', liked: true);
        final sending = dating().send('maya', '  Hi Maya  ');
        expect(state().threads['maya']!.single.status, MessageStatus.sending);
        expect(state().threads['maya']!.single.text, 'Hi Maya');
        await sending;
        expect(state().threads['maya']!.single.status, MessageStatus.onDevice);
        expect(dating().conversations().map((p) => p.id), ['maya']);
        expect(dating().newMatches(), isEmpty);
      },
    );

    test('blank messages are ignored', () {
      dating().decide('maya', liked: true);
      dating().send('maya', '   ');
      expect(state().threads['maya'], isNull);
    });

    test('with simulated errors a send fails; retry and delete work', () async {
      dating().decide('maya', liked: true);
      dating().setSimulateErrors(true);
      await dating().send('maya', 'Hi');
      final failed = state().threads['maya']!.single;
      expect(failed.status, MessageStatus.failed);

      dating().setSimulateErrors(false);
      await dating().retry('maya', failed.id);
      expect(state().threads['maya']!.single.status, MessageStatus.onDevice);

      dating().deleteMessage('maya', failed.id);
      expect(state().threads['maya'], isEmpty);
    });
  });

  group('Safety', () {
    test('unmatch ends the match without blocking', () {
      dating().decide('maya', liked: true);
      dating().end('maya', EndReason.unmatched);
      expect(dating().newMatches(), isEmpty);
      expect(dating().blocked(), isEmpty);
      expect(dating().likes().map((l) => l.person.id), isNot(contains('maya')));
    });

    test('report with block saves the report and blocks; unblock never restores the match', () {
      dating().decide('maya', liked: true);
      dating().report('maya', 'Fake profile', block: true);
      expect(state().reports.single.reason, 'Fake profile');
      expect(dating().blocked().map((p) => p.id), ['maya']);
      dating().unblock('maya');
      expect(dating().blocked(), isEmpty);
      expect(state().matches, isEmpty);
    });

    test('report without block keeps the match', () {
      dating().decide('maya', liked: true);
      dating().report('maya', 'Spam', block: false);
      expect(dating().blocked(), isEmpty);
      expect(dating().newMatches().map((p) => p.id), ['maya']);
    });

    test('blocking someone from Discover removes them from the queue', () {
      dating().end('maya', EndReason.blocked);
      expect(queueIds(), isNot(contains('maya')));
    });
  });

  test('snooze is a switch', () {
    dating().setSnoozed(true);
    expect(state().snoozed, isTrue);
    dating().setSnoozed(false);
    expect(state().snoozed, isFalse);
  });
}
