import { cx } from "../lib/cx.js";
import { Icon } from "./Icon.jsx";

export function Spinner({ className }) {
  return <span className={cx("spinner", className)} aria-hidden="true" />;
}

/** Full-width action. Variants: primary (ink), secondary (outlined), quiet (text). */
export function Button({ variant = "primary", loading = false, className, children, ...rest }) {
  return (
    <button
      type="button"
      className={cx("btn", `btn--${variant}`, loading && "is-loading", className)}
      aria-busy={loading || undefined}
      {...rest}
    >
      <span className="btn__label">{children}</span>
      {loading && <Spinner />}
    </button>
  );
}

/** Circular forward action anchored bottom-right of each step. */
export function NextButton({ label = "Continue", loading = false, disabled, ...rest }) {
  return (
    <button
      type="button"
      className={cx("fab", loading && "is-loading")}
      aria-label={label}
      aria-busy={loading || undefined}
      disabled={disabled || loading}
      {...rest}
    >
      {loading ? <Spinner /> : <Icon name="arrowRight" size={22} stroke={2} />}
    </button>
  );
}

export function BackButton({ label = "Back", ...rest }) {
  return (
    <button type="button" className="nav-button" aria-label={label} {...rest}>
      <Icon name="chevronLeft" size={22} stroke={2} />
    </button>
  );
}

export function TextButton({ className, children, ...rest }) {
  return (
    <button type="button" className={cx("text-button", className)} {...rest}>
      {children}
    </button>
  );
}
