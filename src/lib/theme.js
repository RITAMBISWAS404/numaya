/**
 * Opt-in visual experiments. `?theme=tiimo` turns on the Tiimo-inspired direction for the screens
 * that take part in it (artifacts/tiimo-inspired-experiment/); without the parameter every screen
 * renders the approved design. `?theme=withings` (V16, artifacts/version-16-design-experiment/)
 * keeps V11 exactly as laid out and changes only how it looks: it renders `.theme-tiimo` plus
 * `.theme-wth`, whose rules restyle colour, type, edges, radii and states, never geometry.
 */
export const EXPERIMENT_THEMES = ["tiimo", "withings"];

/** The classes a themed screen takes for an experiment theme (null: none). */
export function themeClassName(theme) {
  if (theme === "tiimo") return "theme-tiimo";
  if (theme === "withings") return "theme-tiimo theme-wth";
  return null;
}

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
