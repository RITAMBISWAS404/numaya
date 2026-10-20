import { useEffect, useMemo, useRef, useState } from "react";
import { NextButton } from "../components/Controls.jsx";
import { useKeypad } from "../components/DeviceContext.jsx";
import { Field } from "../components/Field.jsx";
import { Icon } from "../components/Icon.jsx";
import {
  Reassurance,
  Screen,
  ScreenBody,
  ScreenFooter,
  ScreenHeader,
  TopBar,
} from "../components/Layout.jsx";
import { Pill, Sheet } from "../components/Overlays.jsx";
import { COUNTRIES, digitCount, formatNational, placeholderFor } from "../data/countries.js";
import { cx } from "../lib/cx.js";

const COPY = {
  signup: {
    title: "Can we get your number, please?",
    lede: "We only use phone numbers to make sure everyone on Numaya is real.",
  },
  signin: {
    title: "Welcome back. What’s your number?",
    lede: "We’ll text you a code to sign in. No password to remember.",
  },
};

export function PhoneNumber({
  active,
  intent,
  country,
  digits,
  onCountryChange,
  onDigitsChange,
  onBack,
  onSubmit,
}) {
  const inputRef = useRef(null);
  const onSubmitRef = useRef(onSubmit);
  onSubmitRef.current = onSubmit;

  const [sheetOpen, setSheetOpen] = useState(false);
  const [sending, setSending] = useState(false);

  const max = digitCount(country);
  const valid = digits.length === max;
  const copy = COPY[intent];

  const setDigits = (next) => {
    if (sending) return;
    onDigitsChange(next.replace(/\D/g, "").slice(0, max));
  };

  const usesKeypad = useKeypad(active && !sheetOpen, {
    variant: "phone",
    onDigit: (d) => setDigits(digits + d),
    onDelete: () => setDigits(digits.slice(0, -1)),
  });

  useEffect(() => {
    if (!active) return;
    const id = setTimeout(() => inputRef.current?.focus({ preventScroll: true }), 380);
    return () => clearTimeout(id);
  }, [active]);

  useEffect(() => {
    if (!sending) return;
    const id = setTimeout(() => {
      setSending(false);
      onSubmitRef.current();
    }, 1100);
    return () => clearTimeout(id);
  }, [sending]);

  const submit = () => {
    if (valid && !sending) setSending(true);
  };

  const chooseCountry = (next) => {
    onCountryChange(next);
    onDigitsChange(digits.slice(0, digitCount(next)));
    setSheetOpen(false);
  };

  return (
    <Screen withKeypad={usesKeypad} aria-labelledby="phone-title">
      <TopBar onBack={onBack} step={intent === "signup" ? 1 : null} steps={intent === "signup" ? 4 : null} />

      <ScreenBody>
        <ScreenHeader id="phone-title" title={copy.title} lede={copy.lede} />

        <div className="phone-row">
          <Field label="Country" htmlFor="phone-country" className="phone-row__country">
            <button
              id="phone-country"
              type="button"
              className="input input--select"
              aria-haspopup="dialog"
              aria-expanded={sheetOpen}
              aria-label={`Country: ${country.name} ${country.dial}`}
              onClick={() => setSheetOpen(true)}
            >
              <span className="input__code">{country.iso}</span>
              <span>{country.dial}</span>
              <Icon name="chevronDown" size={18} stroke={1.8} className="input__chevron" />
            </button>
          </Field>

          <Field label="Phone number" htmlFor="phone-number" className="phone-row__number">
            <input
              ref={inputRef}
              id="phone-number"
              className={cx("input", digits.length > 0 && "has-value")}
              type="tel"
              inputMode={usesKeypad ? "none" : "tel"}
              autoComplete="tel-national"
              placeholder={placeholderFor(country)}
              value={formatNational(country, digits)}
              onChange={(e) => setDigits(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && submit()}
              aria-describedby="phone-reassurance"
            />
          </Field>
        </div>
      </ScreenBody>

      <ScreenFooter>
        <span id="phone-reassurance" className="screen__footer-text">
          <Reassurance icon={<Icon name="lock" size={18} stroke={1.7} />}>
            We never share this with anyone and it won’t be on your profile.
          </Reassurance>
        </span>
        <NextButton label="Send code" disabled={!valid} loading={sending} onClick={submit} />
      </ScreenFooter>

      {active && (
        <>
          <Pill open={sending} busy>
            Sending code
          </Pill>
          <CountrySheet
            open={sheetOpen}
            selected={country}
            onSelect={chooseCountry}
            onClose={() => setSheetOpen(false)}
          />
        </>
      )}
    </Screen>
  );
}

function CountrySheet({ open, selected, onSelect, onClose }) {
  const [query, setQuery] = useState("");

  useEffect(() => {
    if (!open) setQuery("");
  }, [open]);

  const results = useMemo(() => {
    const q = query.trim().toLowerCase().replace(/^\+/, "");
    if (!q) return COUNTRIES;
    return COUNTRIES.filter(
      (c) =>
        c.name.toLowerCase().includes(q) ||
        c.iso.toLowerCase() === q ||
        c.dial.slice(1).startsWith(q),
    );
  }, [query]);

  return (
    <Sheet open={open} onClose={onClose} labelledBy="country-title" className="sheet--tall">
      <div className="sheet__header">
        <h2 id="country-title" className="sheet__title">
          Country or region
        </h2>
        <button type="button" className="nav-button nav-button--flat" aria-label="Close" onClick={onClose}>
          <Icon name="close" size={20} stroke={1.9} />
        </button>
      </div>

      <label className="search">
        <Icon name="search" size={20} stroke={1.8} className="search__icon" />
        <span className="visually-hidden">Search countries</span>
        <input
          data-autofocus
          type="search"
          className="search__input"
          placeholder="Search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          autoComplete="off"
        />
      </label>

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
                <span className="country-row__check">
                  {isSelected && <Icon name="check" size={20} stroke={2.2} />}
                </span>
              </button>
            </li>
          );
        })}
        {results.length === 0 && <li className="country-list__empty">No matches for “{query}”</li>}
      </ul>
    </Sheet>
  );
}
