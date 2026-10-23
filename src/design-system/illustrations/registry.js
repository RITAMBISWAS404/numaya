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
 * fallback: an Illustration scene name, "heart" (the joining-heart mark) or "reserved" (empty space).
 */
export const ILLUSTRATIONS = {
  "match-hands-heart": { file: "numaya-match-hands-heart.png", ratio: "5 / 2", fit: "contain", fallback: "heart", priority: "P0", animation: "planned" },
};

/** URL of the supplied PNG for a slot, or null while the artwork has not been supplied. */
export const illustrationSrc = (id) => URLS[ILLUSTRATIONS[id]?.file] ?? null;
