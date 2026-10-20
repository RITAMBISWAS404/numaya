import { useState } from "react";
import { OverlayRootProvider } from "../design-system/index.js";
import { cx } from "../lib/cx.js";

/** Showcase section with an anchor id. */
export function Section({ id, title, intro, children }) {
  return (
    <section id={id} className="sc-section" aria-labelledby={`${id}-title`}>
      <header className="sc-section__header">
        <h2 id={`${id}-title`} className="sc-section__title">
          {title}
        </h2>
        {intro && <p className="sc-section__intro">{intro}</p>}
      </header>
      {children}
    </section>
  );
}

/** A labelled specimen: one component, variant or state. */
export function Specimen({ title, note, wide = false, tone = "surface", children }) {
  return (
    <figure className={cx("sc-specimen", wide && "sc-specimen--wide")}>
      <div className={cx("sc-specimen__stage", `sc-specimen__stage--${tone}`)}>{children}</div>
      <figcaption className="sc-specimen__caption">
        <span className="sc-specimen__title">{title}</span>
        {note && <span className="sc-specimen__note">{note}</span>}
      </figcaption>
    </figure>
  );
}

export function Grid({ children, min = 280 }) {
  return (
    <div className="sc-grid" style={{ "--sc-min": `${min}px` }}>
      {children}
    </div>
  );
}

export function Row({ children, gap = 12, wrap = true }) {
  return (
    <div className="sc-row" style={{ gap, flexWrap: wrap ? "wrap" : "nowrap" }}>
      {children}
    </div>
  );
}

/**
 * Phone-width frame (393 wide) that scopes overlays to itself, so sheets,
 * dialogs and toasts behave as they would on a device.
 */
export function PhoneFrame({ height = 720, title, note, children }) {
  const [root, setRoot] = useState(null);
  return (
    <figure className="sc-phone">
      <div className="sc-phone__screen" style={{ height }}>
        <OverlayRootProvider root={root}>{children}</OverlayRootProvider>
        <div className="sc-phone__overlay" ref={setRoot} />
      </div>
      {title && (
        <figcaption className="sc-specimen__caption">
          <span className="sc-specimen__title">{title}</span>
          {note && <span className="sc-specimen__note">{note}</span>}
        </figcaption>
      )}
    </figure>
  );
}

/** Small control bar to switch a demo between states. */
export function StatePicker({ label = "State", options, value, onChange }) {
  return (
    <div className="sc-states" role="radiogroup" aria-label={label}>
      {options.map((o) => (
        <button
          key={o}
          type="button"
          role="radio"
          aria-checked={o === value}
          className={cx("sc-states__item", o === value && "is-selected")}
          onClick={() => onChange(o)}
        >
          {o}
        </button>
      ))}
    </div>
  );
}
