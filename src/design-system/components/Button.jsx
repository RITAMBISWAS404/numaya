import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";

export function Spinner({ size = "md", label, className }) {
  return (
    <span
      className={cx("spinner", size === "sm" && "spinner--sm", className)}
      role={label ? "status" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : "true"}
    />
  );
}

/**
 * Text action. Variants: primary (ink), secondary (outlined), quiet (text),
 * destructive (danger text), destructive-solid (white on danger), brand (soft lavender with a
 * deep-purple label, Meetup "Sign up with email").
 */
export function Button({
  variant = "primary",
  size = "md",
  loading = false,
  block = true,
  icon,
  className,
  children,
  ...rest
}) {
  return (
    <button
      type="button"
      {...rest}
      className={cx(
        "btn",
        `btn--${variant}`,
        size === "sm" && "btn--sm",
        !block && "btn--inline",
        loading && "is-loading",
        className,
      )}
      aria-busy={loading || undefined}
      disabled={rest.disabled || loading}
    >
      {icon && <Icon name={icon} size={20} stroke={2} className="btn__icon" />}
      <span className="btn__label">{children}</span>
      {loading && <Spinner />}
    </button>
  );
}

/** Circular forward action anchored bottom-right of data-entry steps. */
export function Fab({ label = "Continue", icon = "arrowRight", loading = false, disabled, className, ...rest }) {
  return (
    <button
      type="button"
      className={cx("fab", loading && "is-loading", className)}
      aria-label={label}
      aria-busy={loading || undefined}
      disabled={disabled || loading}
      {...rest}
    >
      {loading ? <Spinner /> : <Icon name={icon} size={22} stroke={2} />}
    </button>
  );
}

/**
 * Icon-only action. Variants: floating (white, lifted, over content),
 * flat (soft fill, inside surfaces), plain (no fill).
 * `label` is required: it is the accessible name.
 */
export function IconButton({ icon, label, variant = "floating", size = "md", pressed, className, ...rest }) {
  return (
    <button
      type="button"
      className={cx("nav-button", `nav-button--${variant}`, size === "sm" && "nav-button--sm", className)}
      aria-label={label}
      aria-pressed={pressed}
      {...rest}
    >
      <Icon name={icon} size={size === "sm" ? 18 : 22} stroke={2} />
    </button>
  );
}

export function BackButton({ label = "Back", ...rest }) {
  return <IconButton icon="chevronLeft" label={label} {...rest} />;
}

/** Inline text action styled as a link (navigation or in-place action). */
export function TextButton({ className, tone = "brand", children, ...rest }) {
  return (
    <button type="button" className={cx("text-button", tone !== "brand" && `text-button--${tone}`, className)} {...rest}>
      {children}
    </button>
  );
}

/** Real hyperlink with the same treatment as TextButton. */
export function Link({ className, tone = "brand", children, ...rest }) {
  return (
    <a className={cx("text-button", tone !== "brand" && `text-button--${tone}`, className)} {...rest}>
      {children}
    </a>
  );
}
