import 'event_models.dart';

/// Sample Events data (demo only, labelled in the UI). Stable IDs; dates relative to the demo
/// clock so every state exists on any day. Venues are fictional public places; no venue,
/// partner, host or staff named here exists (PRD O2, D2, D3).
const kEvCities = [
  'Mumbai',
  'Bengaluru',
  'Delhi',
  'Pune',
  'Hyderabad',
  'Chennai',
  'Kolkata',
  'Jaipur',
];

/// A person seen at a completed sample event (E07). Attendance and opt-in are per person.
typedef EvPeer = ({
  String personId,
  bool checkedIn,
  bool optedIn,
  bool interestedInMember,
});

DateTime _at(DateTime now, int days, int hour, [int minute = 0]) {
  final d = DateTime(now.year, now.month, now.day).add(Duration(days: days));
  return DateTime(d.year, d.month, d.day, hour, minute);
}

List<NumayaEvent> sampleEventsMvp(DateTime now) => [
  NumayaEvent(
    id: 'ev-board-games-bandra',
    title: 'Board games and chai',
    category: EvCategory.games,
    city: 'Mumbai',
    venue: const EvVenue(
      name: 'Dice and Dine Café (sample)',
      address: '14 Hill Road, Bandra West',
      area: 'Bandra',
      accessibility:
          'Step-free entrance; accessible toilet on the ground floor.',
      transport: '10 minutes’ walk from Bandra station.',
    ),
    start: _at(now, 2, 18, 30),
    end: _at(now, 2, 21),
    capacity: 24,
    othersReserved: 12,
    description: 'Small tables, easy games and a host who keeps things moving. Come alone; everyone does.',
    hostName: 'Sample host A',
    reviewerName: 'Sample reviewer B',
    tone: 0,
  ),
  NumayaEvent(
    id: 'ev-coffee-indiranagar',
    title: 'Saturday coffee social',
    category: EvCategory.coffee,
    city: 'Bengaluru',
    venue: const EvVenue(
      name: 'Third Wave Corner (sample)',
      address: '100 Feet Road, Indiranagar',
      area: 'Indiranagar',
    ),
    start: _at(now, 5, 11),
    end: _at(now, 5, 13),
    capacity: 20,
    othersReserved: 20,
    description: 'An unhurried morning coffee for 20. Conversation prompts on every table.',
    hostName: 'Sample host C',
    reviewerName: 'Sample reviewer D',
    tone: 1,
  ),
  NumayaEvent(
    id: 'ev-sunrise-walk',
    title: 'Sunrise walk and breakfast',
    category: EvCategory.walk,
    city: 'Mumbai',
    venue: const EvVenue(
      name: 'Carter Road Promenade, north gate (sample)',
      address: 'Carter Road, Bandra West',
      area: 'Bandra',
      transport: 'Auto stand at the north gate.',
    ),
    start: _at(now, 3, 7),
    end: _at(now, 3, 9, 30),
    capacity: 25,
    othersReserved: 15,
    version: 2,
    description:
        'A gentle 4 km walk, then breakfast together. Wear comfortable shoes.',
    hostName: 'Sample host A',
    reviewerName: 'Sample reviewer B',
    tone: 2,
  ),
  NumayaEvent(
    id: 'ev-pottery-hauz-khas',
    title: 'Beginner pottery workshop',
    category: EvCategory.workshop,
    city: 'Delhi',
    venue: const EvVenue(
      name: 'Clay Studio (sample)',
      address: 'Hauz Khas Village',
      area: 'Hauz Khas',
    ),
    start: _at(now, 4, 16),
    end: _at(now, 4, 18),
    capacity: 20,
    othersReserved: 9,
    lifecycle: EvLifecycle.cancelled,
    cancelReason: 'The studio is closed for repairs that day.',
    description: 'Make a small bowl at the wheel. Clay and aprons provided.',
    hostName: 'Sample host E',
    reviewerName: 'Sample reviewer F',
    tone: 3,
  ),
  NumayaEvent(
    id: 'ev-book-swap',
    title: 'Book swap and coffee',
    category: EvCategory.coffee,
    city: 'Mumbai',
    venue: const EvVenue(
      name: 'Kitab Café (sample)',
      address: 'Lower Parel',
      area: 'Lower Parel',
    ),
    start: _at(now, -2, 17),
    end: _at(now, -2, 19),
    capacity: 24,
    othersReserved: 20,
    description: 'Bring a book you loved, leave with one you haven’t read.',
    hostName: 'Sample host A',
    reviewerName: 'Sample reviewer B',
    tone: 4,
  ),
  NumayaEvent(
    id: 'ev-comedy-chai',
    title: 'Open mic and chai',
    category: EvCategory.arts,
    city: 'Pune',
    venue: const EvVenue(
      name: 'Koregaon Social (sample)',
      address: 'Koregaon Park',
      area: 'Koregaon Park',
    ),
    start: _at(now, -9, 19),
    end: _at(now, -9, 21),
    capacity: 30,
    othersReserved: 26,
    description: 'Listen, laugh, maybe read a poem.',
    hostName: 'Sample host G',
    reviewerName: 'Sample reviewer H',
    tone: 5,
  ),
  NumayaEvent(
    id: 'ev-cooking-hyderabad',
    title: 'Biryani cooking class',
    category: EvCategory.food,
    city: 'Hyderabad',
    venue: const EvVenue(
      name: 'Banjara Kitchen Studio (sample)',
      address: 'Road No. 12, Banjara Hills',
      area: 'Banjara Hills',
      accessibility: 'Lift to the first floor.',
    ),
    start: _at(now, 10, 12),
    end: _at(now, 10, 15),
    capacity: 20,
    othersReserved: 6,
    description: 'Cook in pairs, eat together. Vegetarian option on request.',
    hostName: 'Sample host I',
    reviewerName: 'Sample reviewer J',
    tone: 0,
  ),
  NumayaEvent(
    id: 'ev-cycle-ride',
    title: 'Early cycle ride',
    category: EvCategory.walk,
    city: 'Mumbai',
    venue: const EvVenue(
      name: 'Marine Drive, NCPA end (sample)',
      address: 'Nariman Point',
      area: 'Nariman Point',
    ),
    start: _at(now, 1, 6, 30),
    end: _at(now, 1, 8, 30),
    capacity: 20,
    othersReserved: 11,
    description:
        'An easy 12 km ride along the sea. Bikes can be rented nearby.',
    hostName: 'Sample host K',
    reviewerName: 'Sample reviewer B',
    tone: 1,
  ),
  NumayaEvent(
    id: 'ev-trivia-night',
    title: 'Trivia night',
    category: EvCategory.games,
    city: 'Mumbai',
    venue: const EvVenue(
      name: 'Quiz House (sample)',
      address: 'Andheri West',
      area: 'Andheri',
    ),
    start: _at(now, -4, 20),
    end: _at(now, -4, 22),
    capacity: 28,
    othersReserved: 22,
    description: 'Teams of four, mixed at the door.',
    hostName: 'Sample host A',
    reviewerName: 'Sample reviewer B',
    tone: 2,
  ),
  NumayaEvent(
    id: 'ev-art-walk-chennai',
    title: 'Gallery walk',
    category: EvCategory.arts,
    city: 'Chennai',
    venue: const EvVenue(
      name: 'Cholamandal entrance (sample)',
      address: 'Injambakkam',
      area: 'ECR',
    ),
    start: _at(now, 6, 16),
    end: _at(now, 6, 18),
    capacity: 22,
    othersReserved: 4,
    description: 'An unhurried walk through three galleries with a short talk.',
    hostName: 'Sample host L',
    reviewerName: 'Sample reviewer M',
    tone: 3,
  ),
];

/// The member's seeded reservations: confirmed (cycle ride, with an ordinary notice), awaiting
/// reconfirmation (sunrise walk moved), cancelled by the event (pottery), attended (book swap,
/// checked in), attended but the window closed (open mic), and a no-show (trivia).
const kSeededReservations = <String, (int acceptedVersion, bool discoverable)>{
  'ev-cycle-ride': (1, false),
  'ev-sunrise-walk': (1, false),
  'ev-pottery-hauz-khas': (1, false),
  'ev-book-swap': (1, true),
  'ev-comedy-chai': (1, true),
  'ev-trivia-night': (1, false),
};

const kSeededAttendance = <String, Attendance>{
  'ev-book-swap': Attendance.checkedIn,
  'ev-comedy-chai': Attendance.checkedIn,
  'ev-trivia-night': Attendance.noShow,
};

/// People at the completed book swap. Only checked-in, opted-in, preference-compatible people
/// appear; interest from them is private until mutual.
const kBookSwapPeers = <EvPeer>[
  (personId: 'sam', checkedIn: true, optedIn: true, interestedInMember: true),
  (
    personId: 'tomas',
    checkedIn: true,
    optedIn: true,
    interestedInMember: false,
  ),
  (personId: 'ben', checkedIn: true, optedIn: true, interestedInMember: false),
  (personId: 'rafa', checkedIn: true, optedIn: true, interestedInMember: true),
  (personId: 'ollie', checkedIn: true, optedIn: true, interestedInMember: true),
  (personId: 'ade', checkedIn: true, optedIn: false, interestedInMember: true),
  (personId: 'kemi', checkedIn: true, optedIn: true, interestedInMember: false),
  (
    personId: 'maya',
    checkedIn: false,
    optedIn: true,
    interestedInMember: false,
  ),
];

/// Sample attendee names for the internal check-in tool (first name and initial only).
const kSampleAttendeeNames = [
  'Aarav S.',
  'Diya K.',
  'Ishaan M.',
  'Kavya R.',
  'Meera P.',
  'Rohan T.',
  'Sana A.',
  'Vikram J.',
];
