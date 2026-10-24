// Mock data for the flow previews. No backend.
export const PEOPLE = {
  maya: {
    name: "Maya", age: 29, verified: true, isNew: true, tone: 0, photoCount: 4, likesYou: true,
    distanceKm: 2,
    details: [{ icon: "user", text: "Product designer" }],
    shared: ["Jazz", "Natural wine"],
    prompt: { q: "A perfect first date", a: "Natural wine, a record shop, and nowhere to be after." },
    facts: [
      { icon: "heart", label: "Looking for", value: "Long-term" },
      { icon: "location", label: "Lives in", value: "Hackney" },
      { icon: "message", label: "Languages", value: "English, Spanish" },
    ],
    opener: "Ask about the record shop…",
  },
  sam: {
    name: "Sam", age: 31, verified: false, tone: 2, photoCount: 3, likesYou: false,
    distanceKm: 4,
    details: [{ icon: "user", text: "Architect" }],
    shared: ["Cooking"],
    prompt: { q: "I’m weirdly good at", a: "Finding the one good table in a crowded café." },
    facts: [
      { icon: "heart", label: "Looking for", value: "Open to seeing" },
      { icon: "location", label: "Lives in", value: "Peckham" },
    ],
  },
  noor: {
    name: "Noor", age: 28, verified: true, tone: 3, photoCount: 5, likesYou: true,
    distanceKm: 6,
    details: [{ icon: "user", text: "Pastry chef" }],
    shared: ["Cooking", "Museums"],
    prompt: { q: "Let’s debate this", a: "Croissants are a dinner food." },
    facts: [
      { icon: "heart", label: "Looking for", value: "Long-term" },
      { icon: "location", label: "Lives in", value: "Islington" },
    ],
    opener: "Defend the croissant theory…",
  },
  ines: {
    name: "Inés", age: 24, verified: true, tone: 1, photoCount: 3, likesYou: true, distanceKm: 9,
    details: [{ icon: "user", text: "Marine biologist" }],
    shared: ["Climbing"],
    prompt: { q: "My Sunday ritual", a: "Sea swim, then the longest breakfast in the city." },
    facts: [{ icon: "heart", label: "Looking for", value: "Long-term" }, { icon: "location", label: "Lives in", value: "Brixton" }],
    opener: "Ask about the sea swim…",
  },
  lea: {
    name: "Léa", age: 35, verified: false, tone: 0, photoCount: 4, likesYou: false, distanceKm: 22,
    details: [{ icon: "user", text: "Documentary editor" }],
    shared: ["Film photography", "Museums"],
    prompt: { q: "A green flag", a: "You still send postcards." },
    facts: [{ icon: "heart", label: "Looking for", value: "Open to seeing" }, { icon: "location", label: "Lives in", value: "Richmond" }],
  },
  tomas: {
    name: "Tomás", age: 41, verified: true, tone: 3, photoCount: 2, likesYou: true, distanceKm: 38,
    details: [{ icon: "user", text: "Cellist" }],
    shared: ["Jazz"],
    prompt: { q: "I’ll never shut up about", a: "Why every city needs more late-night jazz bars." },
    facts: [{ icon: "heart", label: "Looking for", value: "Long-term" }, { icon: "location", label: "Lives in", value: "Kingston" }],
    opener: "Name your favourite jazz bar…",
  },
  priya: { name: "Priya", age: 30, verified: true, tone: 1, lastTime: "Tue", distanceKm: 3 },
  jo: { name: "Jo", age: 32, verified: false, tone: 2, distanceKm: 5 },
  kemi: { name: "Kemi", age: 27, verified: true, tone: 3, lastTime: "Mon", distanceKm: 4, shared: ["Running"] },
  rafa: { name: "Rafa", age: 33, verified: false, tone: 0, lastTime: "Sun", distanceKm: 12, shared: ["Board games"] },
};

export const INTERESTS = [
  "Natural wine", "Jazz", "Cooking", "Climbing", "Film photography", "Museums", "Running", "Board games", "Travel", "Poetry",
];

/**
 * The same interests in three small sets, so the picker reads as a few short rows, not a wall.
 * Variant D: each set has one supporting hue (`tone`), the same wherever an interest appears.
 */
export const INTEREST_GROUPS = [
  { label: "Food and nights in", tone: "apricot", options: ["Natural wine", "Cooking", "Board games"] },
  { label: "Culture", tone: "periwinkle", options: ["Jazz", "Museums", "Poetry", "Film photography"] },
  { label: "Out and about", tone: "mint", options: ["Climbing", "Running", "Travel"] },
];

/** Interest → its set's hue (Profile shows the person's interests in the same colours). */
export const INTEREST_TONE = Object.fromEntries(INTEREST_GROUPS.flatMap((g) => g.options.map((o) => [o, g.tone])));

export const REPORT_REASONS = [
  ["user", "Fake profile"],
  ["image", "Inappropriate photos or text"],
  ["flag", "Scam or selling something"],
  ["alert", "Hateful or abusive behaviour"],
  ["shield", "Might be under 18"],
  ["location", "Something that happened offline"],
];

/** Prompt questions offered by the prompt editor (Bumble-style profile prompts). */
export const PROMPT_QUESTIONS = [
  "A perfect first date",
  "I’m weirdly good at",
  "Let’s debate this",
  "My Sunday ritual",
  "A green flag",
  "I’ll never shut up about",
];

/* -------------------------------------------------------------------------- */
/* Activity, likes and messaging fixtures (prototype data, no backend)         */
/* -------------------------------------------------------------------------- */

/** The preview's fixed "now": Friday 23 October 2026, 12:00 local time. Every date rule uses it. */
export const PROTOTYPE_NOW = new Date(2026, 9, 23, 12, 0);

/** Areas the user can choose (no device location is read). x / y in km on a simple grid. */
export const AREAS = [
  { id: "hackney", name: "Hackney", x: 0, y: 0 },
  { id: "islington", name: "Islington", x: -3, y: 1 },
  { id: "peckham", name: "Peckham", x: 1, y: -8 },
  { id: "brixton", name: "Brixton", x: -3, y: -9 },
  { id: "richmond", name: "Richmond", x: -17, y: -6 },
];

export const ACTIVITY_CATEGORIES = [
  { id: "music", label: "Music", icon: "music" },
  { id: "food", label: "Food and drink", icon: "food" },
  { id: "outdoors", label: "Outdoors", icon: "park" },
  { id: "sport", label: "Sport", icon: "run" },
  { id: "arts", label: "Arts", icon: "palette" },
  { id: "games", label: "Games", icon: "games" },
];

/**
 * Seeded activities hosted by other people. Dates are local ISO strings relative to PROTOTYPE_NOW.
 * `attendees` are named people (first names shown); `othersGoing` is a count with no identities.
 */
export const ACTIVITIES = {
  "a-run": {
    title: "Parkrun and pastries", category: "sport", host: "maya", start: "2026-10-23T11:30", durationMin: 90,
    venue: "Victoria Park, Crown Gate East", area: "hackney", x: 2, y: 1, capacity: null, approval: false, visibility: "public",
    tone: 1, status: "published", attendees: ["kemi"], othersGoing: 4,
    description: "An easy 5 km at chat pace, then pastries at the café by the lake. All speeds welcome.",
  },
  "a-jazz": {
    title: "Late jazz at the Vortex", category: "music", host: "tomas", start: "2026-10-23T19:30", durationMin: 150,
    venue: "Vortex Jazz Club, Dalston", area: "hackney", x: 0.5, y: 1.5, capacity: 8, approval: false, visibility: "public",
    tone: 3, status: "published", attendees: ["maya", "sam"], othersGoing: 3,
    description: "The Friday late set. Tickets are bought at the door; we’ll grab a table together near the front.",
  },
  "a-climb": {
    title: "Bouldering for beginners", category: "sport", host: "ines", start: "2026-10-24T10:00", durationMin: 120,
    venue: "The Castle Climbing Centre", area: "islington", x: -1, y: 3, capacity: 6, approval: true, visibility: "public",
    tone: 0, status: "published", attendees: ["noor"], othersGoing: 2,
    description: "First time on the wall? Same. Shoe hire at the desk. The host approves requests so the group stays small.",
  },
  "a-market": {
    title: "Columbia Road flower market walk", category: "outdoors", host: "priya", start: "2026-10-25T09:00", durationMin: 90,
    venue: "Columbia Road, by the corner café", area: "hackney", x: 1, y: -1, capacity: null, approval: false, visibility: "public",
    tone: 2, status: "published", attendees: ["kemi", "jo"], othersGoing: 23,
    description: "Early, before the crowds. Coffee, a slow lap of the stalls, and a bunch of something to take home.",
  },
  "a-board": {
    title: "Board games and natural wine", category: "games", host: "noor", start: "2026-10-27T19:00", durationMin: 180,
    venue: "Draughts, Hackney", area: "hackney", x: -0.5, y: -0.5, capacity: 6, approval: false, visibility: "public",
    tone: 1, status: "published", attendees: ["rafa", "lea", "maya"], othersGoing: 3,
    description: "Codenames, Wavelength and a bottle or two. This one is full; join the waitlist for a spot if someone drops out.",
  },
  "a-film": {
    title: "Film photography walk along the Regent’s Canal, from Broadway Market to King’s Cross, with a stop for coffee",
    category: "arts", host: "lea", start: "2026-10-31T14:00", durationMin: 180,
    venue: "Broadway Market, canal steps", area: "islington", x: -3, y: 1, capacity: 10, approval: false, visibility: "public",
    tone: null, status: "published", attendees: [], othersGoing: 2,
    description: "Bring any film camera (or your phone). We walk slowly, shoot the locks and bridges, and swap tips over coffee halfway.\n\nThe route is flat and about 6 km. Leave whenever you like.",
  },
  "a-poetry": {
    title: "Poetry open mic", category: "arts", host: "jo", start: "2026-10-29T20:00", durationMin: 120,
    venue: "The Book Club, Shoreditch", area: "hackney", x: 0, y: -2, capacity: 20, approval: false, visibility: "public",
    tone: 3, status: "cancelled", attendees: [], othersGoing: 0,
    description: "Five-minute slots, sign-up on the night.",
  },
  "a-roast": {
    title: "Sunday roast club", category: "food", host: "sam", start: "2026-10-18T13:00", durationMin: 150,
    venue: "The Camberwell Arms", area: "peckham", x: 1, y: -7, capacity: 8, approval: false, visibility: "public",
    tone: 0, status: "published", attendees: ["rafa"], othersGoing: 4,
    description: "A long table and a proper roast.",
  },
};

/**
 * People who liked you. `via: "activity"` means they found you on the guest list of an activity you
 * both joined (`activity`). Rafa is already a match, so his like shows as handled.
 */
export const LIKES = [
  { person: "maya", via: "profile", at: "2026-10-23T09:10" },
  { person: "kemi", via: "activity", activity: "a-run", at: "2026-10-23T11:50" },
  { person: "noor", via: "profile", at: "2026-10-22T18:30" },
  { person: "ines", via: "profile", at: "2026-10-20T21:00" },
  { person: "tomas", via: "profile", at: "2026-10-16T12:00" },
  { person: "rafa", via: "activity", activity: "a-roast", at: "2026-10-19T09:00" },
];

/** Generic opening lines, used when a person's own prompt or shared interests give nothing better. */
export const OPENERS = [
  "What’s the best thing you’ve eaten this week?",
  "Plans for the weekend, or happily none?",
  "What’s a small thing that made your day recently?",
];

export const ACTIVITY_REPORT_REASONS = [
  "Misleading or not a real activity",
  "Spam or selling something",
  "Feels unsafe",
  "Hateful or abusive",
  "Something else",
];
