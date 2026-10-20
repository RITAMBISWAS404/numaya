import { forwardRef, useId } from "react";
import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";

/** Label + control + note. Errors are announced and linked via aria-describedby. */
export function Field({ label, htmlFor, labelId, note, tone, noteId, className, children }) {
  return (
    <div className={cx("field", className)}>
      {label && (
        <label className="field__label" htmlFor={htmlFor} id={labelId}>
          {label}
        </label>
      )}
      {children}
      {note && (
        <p
          id={noteId}
          className={cx("field__note", tone && `is-${tone}`)}
          role={tone === "error" ? "alert" : undefined}
        >
          {note}
        </p>
      )}
    </div>
  );
}

/** Single-line text input with label, hint and error. */
export const TextField = forwardRef(function TextField(
  { label, hint, error, id, className, inputClassName, ...rest },
  ref,
) {
  const autoId = useId();
  const inputId = id ?? autoId;
  const noteId = `${inputId}-note`;
  const note = error || hint;
  return (
    <Field label={label} htmlFor={inputId} note={note} noteId={noteId} tone={error ? "error" : undefined} className={className}>
      <input
        ref={ref}
        id={inputId}
        className={cx("input", error && "is-invalid", inputClassName)}
        aria-invalid={error ? true : undefined}
        aria-describedby={note ? noteId : undefined}
        {...rest}
      />
    </Field>
  );
});

/** Multi-line input with an optional remaining-characters counter. */
export const TextArea = forwardRef(function TextArea(
  { label, hint, error, id, maxLength, value = "", rows = 4, className, ...rest },
  ref,
) {
  const autoId = useId();
  const inputId = id ?? autoId;
  const noteId = `${inputId}-note`;
  const remaining = maxLength ? maxLength - value.length : null;
  return (
    <Field label={label} htmlFor={inputId} note={error || hint} noteId={noteId} tone={error ? "error" : undefined} className={className}>
      <div className="textarea">
        <textarea
          ref={ref}
          id={inputId}
          className={cx("input", "textarea__input", error && "is-invalid")}
          rows={rows}
          maxLength={maxLength}
          value={value}
          aria-invalid={error ? true : undefined}
          aria-describedby={cx(error || hint ? noteId : null, maxLength ? `${inputId}-count` : null) || undefined}
          {...rest}
        />
        {maxLength && (
          <span id={`${inputId}-count`} className={cx("textarea__count", remaining <= 10 && "is-low")} aria-live="polite">
            {remaining} characters left
          </span>
        )}
      </div>
    </Field>
  );
});

/** Search input with leading icon and clear button. */
export const SearchField = forwardRef(function SearchField(
  { label = "Search", value = "", onChange, onClear, placeholder = "Search", className, ...rest },
  ref,
) {
  return (
    <label className={cx("search", className)}>
      <Icon name="search" size={20} stroke={1.8} className="search__icon" />
      <span className="visually-hidden">{label}</span>
      <input
        ref={ref}
        type="search"
        className="search__input"
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        autoComplete="off"
        {...rest}
      />
      {value && onClear && (
        <button type="button" className="search__clear" aria-label="Clear search" onClick={onClear}>
          <Icon name="close" size={14} stroke={2.4} />
        </button>
      )}
    </label>
  );
});
