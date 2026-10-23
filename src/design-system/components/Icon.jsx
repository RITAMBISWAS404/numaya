import { GLYPHS } from "../icons/material-symbols.js";

/**
 * Numaya icon wrapper over Material Symbols Rounded (Google, Apache-2.0; see THIRD_PARTY_NOTICES.md),
 * weight 500, optical size 24. The drawings are extracted at build time by scripts/icons.mjs from the
 * version-pinned official SVG distribution, so the app ships no icon font and makes no remote request.
 *
 * - Filled (FILL 1) by default, as specified for Numaya.
 * - `weight="outline"` (FILL 0) only where the unfilled drawing carries a different state: inactive
 *   tabs beside the filled current tab, an unliked heart. Legacy values map: "regular" → outline;
 *   "fill", "bold", "duotone" → filled.
 * - `size` sets the rendered size (20 compact, 24 standard, 28 large actions); the glyph sits in a
 *   square box, aligned to the text baseline by its container.
 * Icons are decorative (aria-hidden); icon-only controls carry their own accessible label.
 */
export const ICON_NAMES = Object.keys(GLYPHS);

export function Icon({ name, size = 24, weight, className, stroke, strokeWidth, ...rest }) {
  const glyph = GLYPHS[name];
  if (!glyph) return null;
  const outline = weight === "outline" || weight === "regular";
  return (
    <svg
      className={className ? `icon ${className}` : "icon"}
      width={size}
      height={size}
      viewBox="0 -960 960 960"
      fill="currentColor"
      data-icon={name}
      data-fill={outline ? "0" : "1"}
      aria-hidden="true"
      focusable="false"
      {...rest}
    >
      <path d={outline ? glyph[1] : glyph[0]} />
    </svg>
  );
}
