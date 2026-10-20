import { useId } from "react";

/** A soft square with a bite taken out of the corner. */
export function BrandMark({ size = 28, color = "var(--accent)" }) {
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
