import { cx } from "../../lib/cx.js";
import { BackButton } from "./Button.jsx";
import { Icon } from "./Icon.jsx";
import { CountBadge } from "./Content.jsx";

/** Full-height screen scaffold. tone: "default" | "brand" (brand-washed background). */
export function Screen({ tone, withKeypad = false, className, children, ...rest }) {
  return (
    <section
      className={cx("screen", tone === "brand" && "screen--wash", withKeypad && "has-keypad", className)}
      {...rest}
    >
      {children}
    </section>
  );
}

export function ScreenBody({ className, children }) {
  return <div className={cx("screen__body", className)}>{children}</div>;
}

/** Display headline + optional lede. One per screen; it labels the screen. */
/** Screen title and lede. `art` places a small spot illustration beside the title. */
export function ScreenHeader({ id, title, lede, eyebrow, art }) {
  const heading = (
    <h1 id={id} className="screen-header__title">
      {title}
    </h1>
  );
  return (
    <div className="screen-header">
      {eyebrow && <p className="screen-header__eyebrow">{eyebrow}</p>}
      {art ? (
        <div className="screen-header__row">
          {heading}
          {art}
        </div>
      ) : (
        heading
      )}
      {lede && <p className="screen-header__lede">{lede}</p>}
    </div>
  );
}

/** Bottom action area: meta text on the left, primary action on the right or full width. */
export function ScreenFooter({ className, children }) {
  return <div className={cx("screen__footer", className)}>{children}</div>;
}

/**
 * Top bar. Default: back + optional centred progress. `title` renders a centred
 * inline title; `largeTitle` a left-aligned display title for tab roots.
 */
export function TopBar({ onBack, step, steps, title, largeTitle, actions }) {
  if (largeTitle) {
    return (
      <header className="topbar topbar--large">
        <h1 className="topbar__large-title">{largeTitle}</h1>
        <div className="topbar__actions">{actions}</div>
      </header>
    );
  }
  return (
    <header className="topbar">
      {onBack ? <BackButton onClick={onBack} /> : <span className="topbar__spacer" aria-hidden="true" />}
      {steps ? <ProgressSegments step={step} steps={steps} /> : null}
      {title && <p className="topbar__title">{title}</p>}
      {actions ? <div className="topbar__actions">{actions}</div> : <span className="topbar__spacer" aria-hidden="true" />}
    </header>
  );
}

/** Onboarding progress: short segments in brand purple (Meetup sign-up steps). */
export function ProgressSegments({ step, steps, label = "Sign-up progress" }) {
  return (
    <div
      className="progress"
      role="progressbar"
      aria-label={label}
      aria-valuemin={1}
      aria-valuemax={steps}
      aria-valuenow={step}
      aria-valuetext={`Step ${step} of ${steps}`}
    >
      {Array.from({ length: steps }, (_, i) => (
        <span
          key={i}
          className={cx("progress__segment", i < step - 1 && "is-done", i === step - 1 && "is-current")}
        >
          <span className="progress__fill" />
        </span>
      ))}
    </div>
  );
}

/** Small icon + caption, e.g. privacy reassurance in a footer. */
export function Note({ icon = "lock", children, id }) {
  return (
    <p className="reassurance" id={id}>
      <span className="reassurance__icon">
        <Icon name={icon} size={18} stroke={1.7} />
      </span>
      <span>{children}</span>
    </p>
  );
}

/** Bottom tab bar. items: [{ id, label, icon, badge? }]. */
export function TabBar({ items, current, onChange }) {
  return (
    <nav className="tab-bar" aria-label="Main">
      {items.map((item) => (
        <button
          key={item.id}
          type="button"
          className={cx("tab-bar__item", item.id === current && "is-current")}
          aria-current={item.id === current ? "page" : undefined}
          onClick={() => onChange(item.id)}
        >
          <span className="tab-bar__icon">
            <Icon name={item.icon} size={24} weight={item.id === current ? "fill" : "regular"} />
            {item.badge ? <CountBadge count={item.badge} label={`${item.badge} new in ${item.label}`} /> : null}
          </span>
          <span className="tab-bar__label">{item.label}</span>
        </button>
      ))}
    </nav>
  );
}
