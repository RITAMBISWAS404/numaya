import { cx } from "../../lib/cx.js";

/**
 * Marker emphasis for one word or short phrase in a hero headline: ink text over a light brand-pink
 * marker stroke that draws in once. Replaces pink text, which is only 2.51:1 on white. Use on a
 * handful of hero messages only, never on body text, labels or instructions.
 */
export function Marker({ children, className }) {
  return <em className={cx("marker", className)}>{children}</em>;
}

/*
 * Ribbon paths, drawn in a 400-unit-wide space and scaled uniformly to cover their container
 * (xMidYMid slice), so strokes keep their proportions. Each variant is one broad, soft band and one
 * or two hairline paths that cross it: "crossed paths", kept low-contrast and behind the content.
 */
const RIBBONS = {
  // Welcome hero: a band sweeps up behind the prompt cards; a hairline crosses it.
  welcome: {
    viewBox: "0 0 400 420",
    band: "M-40 352C60 330 96 214 196 214S330 128 440 70",
    lines: ["M-40 260C70 250 132 344 236 300S350 168 440 198"],
  },
  // Match: two paths rise from either side and meet under the heart mark; a band runs behind both photos.
  match: {
    viewBox: "0 0 400 300",
    band: "M-40 214C58 236 112 148 200 150S332 66 440 92",
    lines: ["M-40 300C40 306 120 300 200 268", "M440 300C360 306 280 300 200 268"],
  },
  // Verified: one band arcs behind the badge and fades off to the right.
  verified: {
    viewBox: "0 0 400 220",
    band: "M-40 160C70 176 120 80 200 84S320 150 440 118",
    lines: ["M-40 96C64 84 120 150 202 146S334 58 440 70"],
  },
};

/**
 * Decorative flowing ribbon behind a hero composition (Happn-inspired, in Numaya's tints).
 * aria-hidden, never focusable or clickable; draws once on entrance, static under reduced motion.
 * The parent positions it (it fills its nearest positioned ancestor).
 */
export function Ribbon({ variant, className }) {
  const r = RIBBONS[variant];
  if (!r) return null;
  return (
    <svg className={cx("ribbon", `ribbon--${variant}`, className)} viewBox={r.viewBox} preserveAspectRatio="xMidYMid slice" aria-hidden="true" focusable="false">
      <path className="ribbon__band" d={r.band} pathLength="1" />
      {r.lines.map((d, i) => (
        <path key={d} className="ribbon__line" d={d} pathLength="1" style={{ "--i": i }} />
      ))}
    </svg>
  );
}
