// Mock data for the flow previews. No backend.
export const ME = { name: "Alex", age: 30 };

export const MAYA = {
  name: "Maya",
  age: 29,
  verified: true,
  isNew: true,
  tone: 0,
  photoCount: 4,
  details: [
    { icon: "user", text: "Product designer" },
    { icon: "location", text: "2 km away" },
  ],
  shared: ["Jazz", "Natural wine"],
  prompt: { q: "A perfect first date", a: "Natural wine, a record shop, and nowhere to be after." },
  facts: [
    { icon: "heart", label: "Looking for", value: "Long-term" },
    { icon: "location", label: "Lives in", value: "Hackney" },
    { icon: "message", label: "Languages", value: "English, Spanish" },
  ],
};

export const MATCHES = [
  { id: 1, name: "Maya", remaining: 0.85 },
  { id: 2, name: "Sam", remaining: 0.4 },
  { id: 3, name: "Ari", remaining: 0.12 },
  { id: 4, name: "Noor" },
];

export const CONVERSATIONS = [
  { name: "Maya", preview: "Obviously. Saturday afternoon?", time: "21:04", unread: 1, verified: true },
  { name: "Jo", preview: "You matched 2 hours ago", yourMove: true },
  { name: "Priya", preview: "That bakery was unreal. Thank you!", time: "Tue" },
];

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
