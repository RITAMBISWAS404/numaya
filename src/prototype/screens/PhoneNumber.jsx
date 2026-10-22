import { useEffect, useRef, useState } from "react";
import {
  CountryPicker,
  Fab,
  InfoCard,
  PhoneField,
  Screen,
  ScreenBody,
  ScreenFooter,
  ScreenHeader,
  Toast,
  TopBar,
} from "../../design-system/index.js";
import { digitCount } from "../../data/countries.js";
import { useKeypad } from "../sim/DeviceContext.jsx";

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
        <PhoneField
          ref={inputRef}
          country={country}
          digits={digits}
          onDigitsChange={setDigits}
          onCountryPress={() => setSheetOpen(true)}
          countryExpanded={sheetOpen}
          inputMode={usesKeypad ? "none" : "tel"}
          onKeyDown={(e) => e.key === "Enter" && submit()}
          describedBy="phone-reassurance"
        />
        <InfoCard id="phone-reassurance" icon="lock" title="Your number stays private" className="phone-info">
          We never share it, and it won’t be on your profile.
        </InfoCard>
      </ScreenBody>

      <ScreenFooter>
        <span className="screen__footer-text" />
        <Fab label="Send code" disabled={!valid} loading={sending} onClick={submit} />
      </ScreenFooter>

      {active && (
        <>
          <Toast open={sending} busy>
            Sending code
          </Toast>
          <CountryPicker
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
