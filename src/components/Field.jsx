import { cx } from "../lib/cx.js";

export function Field({ label, htmlFor, labelId, note, tone, className, children }) {
  return (
    <div className={cx("field", className)}>
      <label className="field__label" htmlFor={htmlFor} id={labelId}>
        {label}
      </label>
      {children}
      {note && (
        <p className={cx("field__note", tone && `is-${tone}`)} role={tone === "error" ? "alert" : undefined}>
          {note}
        </p>
      )}
    </div>
  );
}
