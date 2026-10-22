import { cx } from "../../lib/cx.js";

/**
 * One emphasised word or short phrase in a hero headline, set in the exact brand pink (the letters
 * themselves: no underline, marker or outline). Display-size hero headlines only: pink is 2.51:1 on
 * white, so never for body copy, labels, instructions or anything a person must read to act.
 */
export function Emphasis({ children, className }) {
  return <em className={cx("emphasis", className)}>{children}</em>;
}

/*
 * Ribbon paths: one broad warm off-white band and a narrower light-pink band beside it, drawn in a
 * wide, short space and scaled to cover the strip their parent gives them (xMidYMid slice). Each
 * variant sits in a strip of genuine whitespace (see expressive.css), never behind content.
 */
const RIBBONS = {
  // Welcome hero: the empty strip below the prompt cards, above the panel.
  welcome: {
    viewBox: "0 0 400 140",
    band: "M-40 96C56 64 132 124 222 102S352 76 440 90",
    tint: "M-40 126C70 104 150 144 248 124S364 104 440 116",
  },
  // Match: the empty space between the supporting line and the composer.
  match: {
    viewBox: "0 0 400 140",
    band: "M-40 70C64 116 140 46 230 76S360 128 440 92",
    tint: "M-40 104C70 138 160 80 250 104S368 140 440 120",
  },
};

/**
 * Decorative flowing ribbon in a strip of whitespace (Happn-inspired, in warm off-white with a light
 * pink touch). aria-hidden, never focusable or clickable; draws once on entrance, static under
 * reduced motion. Its variant class places it (expressive.css); it never sits behind content.
 */
export function Ribbon({ variant, className }) {
  const r = RIBBONS[variant];
  if (!r) return null;
  return (
    <svg className={cx("ribbon", `ribbon--${variant}`, className)} viewBox={r.viewBox} preserveAspectRatio="xMidYMid slice" aria-hidden="true" focusable="false">
      <path className="ribbon__band" d={r.band} pathLength="1" />
      <path className="ribbon__tint" d={r.tint} pathLength="1" />
    </svg>
  );
}
