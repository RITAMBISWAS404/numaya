import { cx } from "../../lib/cx.js";

/**
 * One emphasised word or short phrase in a hero headline, set in the accent pink (the letters
 * themselves: no underline, marker or outline), like Meetup's "The people platform". 4.77:1 on
 * white, so never for body copy, labels, instructions or anything a person must read to act.
 */
export function Emphasis({ children, className }) {
  return <em className={cx("emphasis", className)}>{children}</em>;
}
