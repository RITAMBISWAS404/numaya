import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/domain/sample_people.dart';
import 'package:numaya_mobile/features/dating/presentation/person_profile.dart';
import 'package:numaya_mobile/features/events/domain/event.dart';
import 'package:numaya_mobile/features/events/presentation/event_parts.dart';
import 'package:numaya_mobile/l10n/l10n.dart';

/// Worst-case data for the refined components (docs/mobile/UI_REFINEMENT_QA.md): a long name and
/// job with every badge, a long event title, venue and badges, and both completion states.
final DateTime kBoardNow = DateTime(2026, 10, 28, 12);

const SamplePerson kLongPerson = SamplePerson(
  id: 'long',
  name: 'Maximiliana-Josephine',
  age: 34,
  distanceKm: 2,
  job: 'Senior landscape architect and part-time ceramics teacher',
  verified: true,
  isNew: true,
);

const SamplePerson kNoJobPerson = SamplePerson(
  id: 'nojob',
  name: 'Bo',
  age: 22,
  distanceKm: 1,
);

DemoEvent boardEvent() => DemoEvent(
  id: 'long',
  title:
      'Saturday morning sourdough, natural wine and record-swapping social for '
      'absolute beginners',
  category: EventCategory.food,
  description: '',
  hostId: 'priya',
  start: kBoardNow.add(const Duration(days: 3)),
  duration: const Duration(hours: 2),
  venue: 'The Old Haberdashery Community Rooms, 22 Columbia Road',
  area: 'Bethnal Green, London',
  capacity: 12,
  attendees: const [kMe, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'],
  changeNote: 'Moved to the back room.',
  tone: 2,
);

/// The board at [width] logical pixels and [textScale].
Widget refinementBoard({required double width, required double textScale}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      backgroundColor: AppColors.canvas,
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppLayout.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PersonHeroCard(person: kLongPerson),
                const SizedBox(height: AppLayout.itemGap),
                DecisionBar(
                  passLabel: 'Pass',
                  superLabel: 'SuperSwipe',
                  likeLabel: 'Like',
                  onPass: () {},
                  onSuper: () {},
                  onLike: () {},
                ),
                const SizedBox(height: AppLayout.itemGap),
                const PersonHeroCard(person: kNoJobPerson),
                const SizedBox(height: AppLayout.sectionGap),
                EventCard(
                  event: boardEvent(),
                  now: kBoardNow,
                  area: 'Hackney, London',
                  saved: true,
                  reason: 'Food and drink',
                  onOpen: () {},
                  onToggleSave: () {},
                ),
                const SizedBox(height: AppLayout.sectionGap),
                CompletionCard(
                  percent: 28,
                  title: 'Profile 28% complete',
                  body:
                      'Profiles with more to talk about get more matches. Pick '
                      'up where you like.',
                  actionLabel: 'Complete profile',
                  onAction: () {},
                ),
                const SizedBox(height: AppLayout.itemGap),
                const CompletionCard(
                  percent: 100,
                  title: 'Profile 100% complete',
                  body: 'Your profile is complete. Nice work.',
                  actionLabel: 'Complete profile',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
