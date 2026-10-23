import { useId } from "react";

/** A soft square in brand purple with a bite taken out of the corner, and a small accent-rose dot
    sitting in the bite (the Numaya mark, reconciled with the Meetup-derived palette). */
export function BrandMark({ size = 28, color = "var(--color-brand)", accent = "var(--color-accent-rose)" }) {
  const maskId = useId();
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" aria-hidden="true">
      <defs>
        <mask id={maskId}>
          <rect width="32" height="32" fill="#fff" />
          <circle cx="27" cy="5" r="7" fill="#000" />
        </mask>
      </defs>
      <rect x="2" y="2" width="28" height="28" rx="9" fill={color} mask={`url(#${maskId})`} />
      {accent && <circle className="brand-mark__dot" cx="27" cy="5" r="3.5" fill={accent} />}
    </svg>
  );
}

export function Wordmark({ size = "md" }) {
  return (
    <span className={`wordmark wordmark--${size}`}>
      <BrandMark size={size === "sm" ? 20 : 26} />
      <span className="wordmark__text">numaya</span>
    </span>
  );
}
