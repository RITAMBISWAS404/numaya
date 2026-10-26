/**
 * Opt-in visual experiments. `?theme=tiimo` turns on the Tiimo-inspired direction for the screens
 * that take part in it (artifacts/tiimo-inspired-experiment/); without the parameter every screen
 * renders the approved design. `?theme=liquid-glass` (V12, artifacts/version-12-liquid-glass-preview/)
 * is the same direction with a restrained Liquid Glass material on selected layers: it renders
 * `.theme-tiimo` plus `.theme-liquid-glass`, so V11 stays its base and the glass rules only add.
 */
export const EXPERIMENT_THEMES = ["tiimo", "liquid-glass"];

/** The classes a themed screen takes for an experiment theme (null: none). */
export function themeClassName(theme) {
  if (theme === "tiimo") return "theme-tiimo";
  if (theme === "liquid-glass") return "theme-tiimo theme-liquid-glass";
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
