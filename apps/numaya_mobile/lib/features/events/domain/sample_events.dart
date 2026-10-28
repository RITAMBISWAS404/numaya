import 'event.dart';

/// The demo's events, adapted from the web preview's `ACTIVITIES` (src/flows/data.js). Every one is
/// invented and labelled as a sample in the UI. Times are relative to [now] so the states stay the
/// same whatever day the app runs: one event under way, one closing for registration, one past, one
/// cancelled, one full with a waitlist, one changed, one online.
///
/// [full] adds an event the member hosts (the explorable demo world).
List<DemoEvent> sampleEvents(DateTime now, {bool full = false}) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime day(int days, int hour, [int minute = 0]) =>
      DateTime(today.year, today.month, today.day + days, hour, minute);
  return [
    DemoEvent(
      id: 'e-runclub',
      title: 'Lunchtime run club',
      category: EventCategory.sport,
      description:
          'A relaxed 5 km loop of London Fields at chat pace. Meet by the lido gates; bags can go '
          'in the café.',
      hostId: 'finn',
      start: now.subtract(const Duration(minutes: 20)),
      duration: const Duration(hours: 1),
      venue: 'London Fields, lido gates',
      area: 'Hackney, London',
      x: 0.5,
      y: -0.5,
      attendees: const ['kemi'],
      othersGoing: 5,
      tone: 2,
    ),
    DemoEvent(
      id: 'e-swim',
      title: 'Sunset swim at the lido',
      category: EventCategory.outdoors,
      description: 'An evening swim then hot chocolate on the terrace. Swim tickets are bought at the lido.',
      hostId: 'ade',
      start: now.add(const Duration(minutes: 90)),
      duration: const Duration(hours: 2),
      venue: 'Brockwell Lido, Dulwich Road',
      area: 'Brixton, London',
      x: -2,
      y: -10,
      cost: 'Swim ticket at the lido, about £8',
      attendees: const ['amara'],
      othersGoing: 6,
      tone: 1,
    ),
    DemoEvent(
      id: 'e-jazz',
      title: 'Late jazz at the Vortex',
      category: EventCategory.music,
      description:
          'The Friday late set. Tickets are bought at the door; we’ll grab a table together near '
          'the front.',
      hostId: 'tomas',
      start: day(1, 19, 30),
      duration: const Duration(minutes: 150),
      venue: 'Vortex Jazz Club, Dalston',
      area: 'Hackney, London',
      x: 0.5,
      y: 1.5,
      capacity: 8,
      cost: 'Pay at the door, about £12',
      attendees: const ['maya', 'sam'],
      othersGoing: 4,
      tone: 3,
    ),
    DemoEvent(
      id: 'e-books',
      title: 'Online book swap: favourite novels',
      category: EventCategory.arts,
      description:
          'Bring one novel you love and pitch it in two minutes. Leave with a reading list. Cameras '
          'optional.',
      hostId: 'chloe',
      start: day(2, 20),
      duration: const Duration(hours: 1),
      format: EventFormat.online,
      onlineNote:
          'The host sends the video link to people going, an hour before.',
      capacity: 12,
      othersGoing: 5,
      tone: 0,
    ),
    DemoEvent(
      id: 'e-climb',
      title: 'Bouldering for beginners',
      category: EventCategory.sport,
      description:
          'First time on the wall? Same. Shoe hire at the desk. We stick to the easy blocks and '
          'swap tips.',
      hostId: 'ines',
      start: day(2, 10),
      duration: const Duration(hours: 2),
      venue: 'The Castle Climbing Centre',
      area: 'Islington, London',
      x: -1,
      y: 3,
      capacity: 6,
      cost: 'Entry and shoe hire at the desk, about £18',
      question:
          'Have you climbed before? Any injuries the group should know about?',
      attendees: const ['noor'],
      othersGoing: 2,
      tone: 0,
    ),
    DemoEvent(
      id: 'e-market',
      title: 'Columbia Road flower market walk',
      category: EventCategory.outdoors,
      description:
          'Early, before the crowds. Coffee, a slow lap of the stalls, and a bunch of something to '
          'take home.',
      hostId: 'priya',
      start: day(3, 9),
      duration: const Duration(minutes: 90),
      venue: 'Columbia Road, by the corner café',
      area: 'Hackney, London',
      x: 1,
      y: -1,
      attendees: const ['kemi', 'jo'],
      othersGoing: 23,
      tone: 2,
    ),
    DemoEvent(
      id: 'e-poetry',
      title: 'Poetry open mic',
      category: EventCategory.arts,
      description: 'Five-minute slots, sign-up on the night.',
      hostId: 'jo',
      start: day(3, 20),
      duration: const Duration(hours: 2),
      venue: 'The Book Club, Shoreditch',
      area: 'Hackney, London',
      y: -2,
      capacity: 20,
      status: EventStatus.cancelled,
      cancelNote: 'The venue has closed for repairs. Sorry, everyone!',
      tone: 3,
    ),
    DemoEvent(
      id: 'e-board',
      title: 'Board games and natural wine',
      category: EventCategory.games,
      description:
          'Codenames, Wavelength and a bottle or two. This one is full; join the waitlist for a '
          'spot if someone drops out.',
      hostId: 'noor',
      start: day(4, 19),
      duration: const Duration(hours: 3),
      venue: 'Draughts, Hackney',
      area: 'Hackney, London',
      x: -0.5,
      y: -0.5,
      capacity: 6,
      attendees: const ['rafa', 'lea', 'maya'],
      othersGoing: 3,
      waitlist: const ['ben', 'chloe'],
      tone: 1,
    ),
    DemoEvent(
      id: 'e-film',
      title:
          'Film photography walk along the Regent’s Canal, from Broadway Market to King’s Cross, '
          'with a stop for coffee',
      category: EventCategory.arts,
      description:
          'Bring any film camera (or your phone). We walk slowly, shoot the locks and bridges, and '
          'swap tips over coffee halfway.\n\nThe route is flat and about 6 km. Leave whenever you '
          'like.',
      hostId: 'lea',
      start: day(5, 14),
      duration: const Duration(hours: 3),
      venue: 'Broadway Market, canal steps',
      area: 'Islington, London',
      x: -3,
      y: 1,
      capacity: 10,
      othersGoing: 2,
      tone: 0,
    ),
    DemoEvent(
      id: 'e-wine',
      title: 'Natural wine tasting',
      category: EventCategory.food,
      description: 'Six wines from small producers with a short introduction to each. Snacks included.',
      hostId: 'mira',
      start: day(6, 19, 30),
      duration: const Duration(hours: 2),
      venue: 'Diogenes the Dog, Camden',
      area: 'Camden, London',
      x: -5,
      y: 3,
      capacity: 14,
      cost: '£15 tasting, paid to the bar',
      attendees: const [kMe, 'sasha'],
      othersGoing: 7,
      changeNote: 'Moved from 7 pm to 7.30 pm.',
      tone: 3,
    ),
    DemoEvent(
      id: 'e-roast',
      title: 'Sunday roast club',
      category: EventCategory.food,
      description: 'A long table and a proper roast.',
      hostId: 'sam',
      start: day(-6, 13),
      duration: const Duration(minutes: 150),
      venue: 'The Camberwell Arms',
      area: 'Peckham, London',
      x: 1,
      y: -7,
      capacity: 8,
      attendees: const [kMe, 'rafa'],
      othersGoing: 4,
      tone: 0,
    ),
    if (full)
      DemoEvent(
        id: 'e-mine',
        title: 'Coffee and crosswords',
        category: EventCategory.games,
        description:
            'Bring a pen. We do the Saturday cryptic together over flat whites; beginners very '
            'welcome.',
        hostId: kMe,
        start: day(4, 10),
        duration: const Duration(minutes: 90),
        venue: 'Climpson & Sons, Broadway Market',
        area: 'Hackney, London',
        x: 0.5,
        y: 0.5,
        capacity: 4,
        question: 'Cryptic crosswords: new to them or a regular?',
        attendees: const ['sasha', 'amara', 'ollie', 'lina'],
        waitlist: const ['jo'],
        tone: 2,
        sample: false,
      ),
  ];
}

/// Events saved at the start (so My events › Saved isn't empty in the demo).
const Set<String> kSampleSavedEvents = {'e-film'};

const List<String> kEventReportReasons = [
  'Misleading or not a real event',
  'Spam or selling something',
  'Feels unsafe',
  'Hateful or abusive',
  'Something else',
];
