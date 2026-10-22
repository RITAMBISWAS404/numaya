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
 * Ribbon paths, drawn in a 100 x 100 box stretched to the area their parent gives them
 * (preserveAspectRatio none); vector-effect keeps the stroke widths in screen pixels, so the band
 * stays broad and the accent thin at any size. One broad light-grey band; the exact-pink accent is a
 * short stretch of the same curve (split out of it), shifted in CSS to ride the band's upper edge.
 * Each variant sits in whitespace (see expressive.css).
 */
const RIBBONS = {
  // Welcome: enters on the left, runs beneath the illustration slot and rises on the right.
  welcome: { band: "M-12 52C10 64 22 94 50 93S90 66 112 56", accent: "M86 75.5C93.3 69 100.3 62.2 108.8 57.6" },
  // Match: a slow wave through the empty space between the copy and the actions.
  match: { band: "M-12 64C16 30 40 92 66 58S96 30 112 52", accent: "M-5.4 57.6C3.4 51.2 11.8 53.1 20.1 57" },
};

/**
 * Decorative flowing ribbon in whitespace (Happn-inspired): a broad, very light neutral band with a
 * short exact-pink accent. aria-hidden, never focusable or clickable; fades in once, static under
 * reduced motion. Its variant class places it (expressive.css); it never sits over content.
 */
export function Ribbon({ variant, className }) {
  const r = RIBBONS[variant];
  if (!r) return null;
  const svg = (cls, d) => (
    <svg className={cls} viewBox="0 0 100 100" preserveAspectRatio="none" focusable="false">
      <path d={d} vectorEffect="non-scaling-stroke" />
    </svg>
  );
  return (
    <span className={cx("ribbon", `ribbon--${variant}`, className)} aria-hidden="true">
      {svg("ribbon__band", r.band)}
      {svg("ribbon__accent", r.accent)}
    </span>
  );
}
