// Mock data for the flow previews. No backend.
export const PEOPLE = {
  maya: {
    name: "Maya", age: 29, verified: true, isNew: true, tone: 0, photoCount: 4, likesYou: true,
    details: [{ icon: "user", text: "Product designer" }, { icon: "location", text: "2 km away" }],
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
    details: [{ icon: "user", text: "Architect" }, { icon: "location", text: "4 km away" }],
    shared: ["Cooking"],
    prompt: { q: "I’m weirdly good at", a: "Finding the one good table in a crowded café." },
    facts: [
      { icon: "heart", label: "Looking for", value: "Open to seeing" },
      { icon: "location", label: "Lives in", value: "Peckham" },
    ],
  },
  noor: {
    name: "Noor", age: 28, verified: true, tone: 3, photoCount: 5, likesYou: true,
    details: [{ icon: "user", text: "Pastry chef" }, { icon: "location", text: "6 km away" }],
    shared: ["Cooking", "Museums"],
    prompt: { q: "Let’s debate this", a: "Croissants are a dinner food." },
    facts: [
      { icon: "heart", label: "Looking for", value: "Long-term" },
      { icon: "location", label: "Lives in", value: "Islington" },
    ],
    opener: "Defend the croissant theory…",
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
