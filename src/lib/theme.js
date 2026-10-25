/**
 * Opt-in visual experiments. `?theme=tiimo` turns on the Tiimo-inspired direction for the screens
 * that take part in it (artifacts/tiimo-inspired-experiment/); without the parameter every screen
 * renders the approved design.
 */
export const EXPERIMENT_THEMES = ["tiimo"];

export function experimentTheme() {
  if (typeof window === "undefined") return null;
  const t = new URLSearchParams(window.location.search).get("theme");
  return EXPERIMENT_THEMES.includes(t) ? t : null;
}

/**
 * Data attributes that let a themed screen decorate an item (an emoji and a category tone) without
 * changing how it renders anywhere else. `mark` is `{ emoji, tone }`; both are optional.
 */
export function markAttrs(mark) {
  if (!mark) return {};
  return { "data-emoji": mark.emoji, "data-tone": mark.tone };
}
