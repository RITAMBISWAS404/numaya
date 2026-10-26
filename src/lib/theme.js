/**
 * Opt-in visual experiments. `?theme=tiimo` turns on the Tiimo-inspired direction for the screens
 * that take part in it (artifacts/tiimo-inspired-experiment/); `?theme=withings` turns on V16, the
 * Withings Health Mate reconstruction (artifacts/version-16-design-experiment/), which keeps V11's
 * layouts and restyles them. Without the parameter every screen renders the approved design.
 */
export const EXPERIMENT_THEMES = ["tiimo", "withings"];

export function experimentTheme() {
  if (typeof window === "undefined") return null;
  const t = new URLSearchParams(window.location.search).get("theme");
  return EXPERIMENT_THEMES.includes(t) ? t : null;
}

/**
 * The classes a themed screen carries. V16 builds on V11: its screens keep `.theme-tiimo` (V11's
 * layouts and component markup) and add `.theme-withings`, whose rules restyle them.
 */
export function themeClasses(theme = experimentTheme()) {
  if (theme === "withings") return "theme-tiimo theme-withings";
  if (theme === "tiimo") return "theme-tiimo";
  return null;
}

/**
 * Data attributes that let a themed screen decorate an item (an emoji and a category tone) without
 * changing how it renders anywhere else. `mark` is `{ emoji, tone }`; both are optional.
 */
export function markAttrs(mark) {
  if (!mark) return {};
  return { "data-emoji": mark.emoji, "data-tone": mark.tone };
}
