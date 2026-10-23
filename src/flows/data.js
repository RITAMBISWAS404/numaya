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
  priya: { name: "Priya", age: 30, verified: true, tone: 1, lastTime: "Tue" },
  jo: { name: "Jo", age: 32, verified: false, tone: 2 },
};

export const INTERESTS = [
  "Natural wine", "Jazz", "Cooking", "Climbing", "Film photography", "Museums", "Running", "Board games", "Travel", "Poetry",
];

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
