import { cx } from "../lib/cx.js";
import { BackButton } from "./Controls.jsx";

export function Screen({ tone, withKeypad = false, className, children, ...rest }) {
  return (
    <section
      className={cx("screen", tone && `screen--${tone}`, withKeypad && "has-keypad", className)}
      {...rest}
    >
      {children}
    </section>
  );
}

export function ScreenBody({ className, children }) {
  return <div className={cx("screen__body", className)}>{children}</div>;
}

export function ScreenHeader({ id, title, lede }) {
  return (
    <div className="screen-header">
      <h1 id={id} className="screen-header__title">
        {title}
      </h1>
      {lede && <p className="screen-header__lede">{lede}</p>}
    </div>
  );
}

export function ScreenFooter({ className, children }) {
  return <div className={cx("screen__footer", className)}>{children}</div>;
}

export function TopBar({ onBack, step, steps }) {
  return (
    <header className="topbar">
      <BackButton onClick={onBack} />
      {steps ? <Progress step={step} steps={steps} /> : null}
      <span className="topbar__spacer" aria-hidden="true" />
    </header>
  );
}

export function Progress({ step, steps }) {
  return (
    <div
      className="progress"
      role="progressbar"
      aria-label="Sign-up progress"
      aria-valuemin={1}
      aria-valuemax={steps}
      aria-valuenow={step}
      aria-valuetext={`Step ${step} of ${steps}`}
    >
      {Array.from({ length: steps }, (_, i) => (
        <span
          key={i}
          className={cx(
            "progress__segment",
            i < step - 1 && "is-done",
            i === step - 1 && "is-current",
          )}
        >
          <span className="progress__fill" />
        </span>
      ))}
    </div>
  );
}

export function Reassurance({ icon, children }) {
  return (
    <p className="reassurance">
      <span className="reassurance__icon">{icon}</span>
      <span>{children}</span>
    </p>
  );
}
