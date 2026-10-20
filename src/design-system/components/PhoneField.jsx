import { forwardRef, useEffect, useMemo, useState } from "react";
import { cx } from "../../lib/cx.js";
import { COUNTRIES, formatNational, placeholderFor } from "../../data/countries.js";
import { Field } from "./Field.jsx";
import { SearchField } from "./Field.jsx";
import { IconButton } from "./Button.jsx";
import { Icon } from "./Icon.jsx";
import { Sheet } from "./Overlays.jsx";

/**
 * Country selector + national number input. Digits are the value; display is
 * formatted from the country pattern. The selector opens CountryPicker.
 */
export const PhoneField = forwardRef(function PhoneField(
  { country, digits, onDigitsChange, onCountryPress, countryExpanded = false, inputMode = "tel", onKeyDown, describedBy, error },
  ref,
) {
  return (
    <div className="phone-row">
      <Field label="Country" htmlFor="phone-country" className="phone-row__country">
        <button
          id="phone-country"
          type="button"
          className="input input--select"
          aria-haspopup="dialog"
          aria-expanded={countryExpanded}
          aria-label={`Country: ${country.name} ${country.dial}`}
          onClick={onCountryPress}
        >
          <span className="input__code">{country.iso}</span>
          <span>{country.dial}</span>
          <Icon name="chevronDown" size={18} stroke={1.8} className="input__chevron" />
        </button>
      </Field>

      <Field
        label="Phone number"
        htmlFor="phone-number"
        className="phone-row__number"
        note={error}
        noteId="phone-number-error"
        tone={error ? "error" : undefined}
      >
        <input
          ref={ref}
          id="phone-number"
          className={cx("input", digits.length > 0 && "has-value", error && "is-invalid")}
          type="tel"
          inputMode={inputMode}
          autoComplete="tel-national"
          placeholder={placeholderFor(country)}
          value={formatNational(country, digits)}
          onChange={(e) => onDigitsChange(e.target.value)}
          onKeyDown={onKeyDown}
          aria-invalid={error ? true : undefined}
          aria-describedby={cx(describedBy, error && "phone-number-error") || undefined}
        />
      </Field>
    </div>
  );
});

/** Searchable country list in a tall sheet. */
export function CountryPicker({ open, selected, onSelect, onClose, countries = COUNTRIES }) {
  const [query, setQuery] = useState("");

  useEffect(() => {
    if (!open) setQuery("");
  }, [open]);

  const results = useMemo(() => {
    const q = query.trim().toLowerCase().replace(/^\+/, "");
    if (!q) return countries;
    return countries.filter(
      (c) => c.name.toLowerCase().includes(q) || c.iso.toLowerCase() === q || c.dial.slice(1).startsWith(q),
    );
  }, [query, countries]);

  return (
    <Sheet open={open} onClose={onClose} labelledBy="country-title" className="sheet--tall">
      <div className="sheet__header">
        <h2 id="country-title" className="sheet__title">
          Country or region
        </h2>
        <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={onClose} />
      </div>

      <SearchField
        label="Search countries"
        data-autofocus
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onClear={() => setQuery("")}
      />

      <ul className="country-list">
        {results.map((c) => {
          const isSelected = c.iso === selected.iso;
          return (
            <li key={c.iso}>
              <button
                type="button"
                className={cx("country-row", isSelected && "is-selected")}
                aria-current={isSelected || undefined}
                onClick={() => onSelect(c)}
              >
                <span className="country-row__code">{c.iso}</span>
                <span className="country-row__name">{c.name}</span>
                <span className="country-row__dial">{c.dial}</span>
                <span className="country-row__check">{isSelected && <Icon name="check" size={20} stroke={2.2} />}</span>
              </button>
            </li>
          );
        })}
        {results.length === 0 && <li className="country-list__empty">No matches for “{query}”</li>}
      </ul>
    </Sheet>
  );
}
