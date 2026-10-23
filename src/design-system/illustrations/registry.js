/*
 * Illustration registry: the one place that names every illustration slot in Numaya, its future PNG
 * and how it is placed. Screens ask for a slot by id (IllustrationSlot), never by file name.
 *
 * Supplying artwork: export the PNG with the exact `file` name below into
 * src/assets/illustrations/. Vite picks it up at build time (import.meta.glob), and the slot shows
 * the PNG instead of its fallback. A missing file is simply absent: no broken image, no build error.
 * The full catalog with annotated screenshots is docs/illustrations/index.html.
 */

/* Every PNG that exists in src/assets/illustrations/, as { "/path/file.png": url }. */
const FILES = import.meta.glob("../../assets/illustrations/*.png", { eager: true, query: "?url", import: "default" });
const URLS = Object.fromEntries(Object.entries(FILES).map(([path, url]) => [path.split("/").pop(), url]));

/**
 * id → { file, ratio (CSS aspect-ratio of the slot), fit, fallback, priority, animation }.
 * fallback: an Illustration scene name, "heart" (the joining-heart mark), "icon:<name>" (a plain
 * glyph, no reserved box: the slot takes its ratio once the PNG exists) or "reserved" (empty space).
 * Placement, art direction and export specs: docs/illustrations/illustration-manifest.json.
 */
export const ILLUSTRATIONS = {
  "match-hands-heart": { file: "numaya-match-hands-heart.png", ratio: "5 / 2", fit: "contain", fallback: "heart", priority: "P0", animation: "planned" },
  "welcome-hero": { file: "numaya-welcome-hero.png", ratio: "1 / 1", fit: "contain", fallback: "reserved", priority: "P1", animation: "optional" },
  "verification-success": { file: "numaya-verification-success.png", ratio: "4 / 3", fit: "contain", fallback: "verified", priority: "P1", animation: "none" },
  "empty-conversations": { file: "numaya-empty-conversations.png", ratio: "4 / 3", fit: "contain", fallback: "no-chats", priority: "P1", animation: "none" },
  "empty-likes": { file: "numaya-empty-likes.png", ratio: "4 / 3", fit: "contain", fallback: "no-match", priority: "P1", animation: "none" },
  "empty-activities": { file: "numaya-empty-activities.png", ratio: "4 / 3", fit: "contain", fallback: "icon:event", priority: "P1", animation: "none" },
  "home-caught-up": { file: "numaya-home-caught-up.png", ratio: "4 / 3", fit: "contain", fallback: "seen-everyone", priority: "P1", animation: "none" },
  "unmatch-outcome": { file: "numaya-unmatch-outcome.png", ratio: "4 / 3", fit: "contain", fallback: "unmatched", priority: "P1", animation: "none" },
  "safety-confirmation": { file: "numaya-safety-confirmation.png", ratio: "4 / 3", fit: "contain", fallback: "blocked", priority: "P1", animation: "none" },
  "home-paused": { file: "numaya-home-paused.png", ratio: "4 / 3", fit: "contain", fallback: "paused", priority: "P2", animation: "none" },
  "activity-published": { file: "numaya-activity-published.png", ratio: "4 / 3", fit: "contain", fallback: "icon:event", priority: "P2", animation: "none" },
  "maintenance": { file: "numaya-maintenance.png", ratio: "4 / 3", fit: "contain", fallback: "icon:maintenance", priority: "P2", animation: "none" },
  "spot-basics": { file: "numaya-spot-basics.png", ratio: "1 / 1", fit: "contain", fallback: "hello", priority: "P2", animation: "none" },
  "spot-interests": { file: "numaya-spot-interests.png", ratio: "1 / 1", fit: "contain", fallback: "interests", priority: "P2", animation: "none" },
};

/** URL of the supplied PNG for a slot, or null while the artwork has not been supplied. */
export const illustrationSrc = (id) => URLS[ILLUSTRATIONS[id]?.file] ?? null;
