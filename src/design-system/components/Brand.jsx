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

/**
 * Supplied logo asset. The final Numaya logo was not attached when this was built, so the mark above
 * stands in. To use the supplied file: place it at public/brand/numaya-logo.svg (or .png, transparent
 * background) and set LOGO_SRC to "/brand/numaya-logo.svg". Wordmark then renders the asset at its
 * native aspect ratio (height-driven), unrecoloured, with "Numaya" as its accessible name.
 */
export const LOGO_SRC = null;
const LOGO_HEIGHT = { sm: 22, md: 30 };

export function Wordmark({ size = "md", src = LOGO_SRC }) {
  if (src) return <img className={`wordmark wordmark--${size} wordmark--asset`} src={src} alt="Numaya" style={{ height: LOGO_HEIGHT[size], width: "auto" }} />;
  return (
    <span className={`wordmark wordmark--${size}`}>
      <BrandMark size={size === "sm" ? 20 : 26} />
      <span className="wordmark__text">numaya</span>
    </span>
  );
}
