import { useEffect, useRef, useState } from "react";
import {
  Button,
  CodeInput,
  Fab,
  Field,
  IllustrationPlaceholder,
  Emphasis,
  ResultPanel,
  Screen,
  ScreenBody,
  ScreenFooter,
  ScreenHeader,
  Sheet,
  TextButton,
  Toast,
  TopBar,
} from "../../design-system/index.js";
import { formatInternational } from "../../data/countries.js";
import { useCountdown } from "../../lib/hooks/useCountdown.js";
import { useKeypad } from "../sim/DeviceContext.jsx";
import { Notification } from "../sim/Notification.jsx";

const LENGTH = 6;
const RESEND_SECONDS = 30;
const SMS_DELAY = 1400;
const SMS_VISIBLE = 6000;

export function VerifyCode({
  active,
  intent,
  country,
  digits,
  code,
  onBack,
  onChangeNumber,
  onResend,
  onVerified,
  onRestart,
}) {
  const inputRef = useRef(null);
  const onVerifiedRef = useRef(onVerified);
  onVerifiedRef.current = onVerified;

  const [value, setValue] = useState("");
  const [status, setStatus] = useState("idle"); // idle | checking | error | success
  const [delivered, setDelivered] = useState(false);
  const [bannerOpen, setBannerOpen] = useState(false);
  const [resent, setResent] = useState(false);
  const [done, setDone] = useState(false);
  const [remaining, restartCountdown] = useCountdown(RESEND_SECONDS);

  const number = formatInternational(country, digits);
  const locked = status === "checking" || status === "success";

  // Simulate the text arriving shortly after each code is sent.
  useEffect(() => {
    if (!active || !code) return;
    setDelivered(false);
    const show = setTimeout(() => {
      setDelivered(true);
      setBannerOpen(true);
    }, SMS_DELAY);
    const hide = setTimeout(() => setBannerOpen(false), SMS_DELAY + SMS_VISIBLE);
    return () => {
      clearTimeout(show);
      clearTimeout(hide);
      setBannerOpen(false);
    };
  }, [active, code]);

  useEffect(() => {
    if (!active) return;
    const id = setTimeout(() => inputRef.current?.focus({ preventScroll: true }), 380);
    return () => clearTimeout(id);
  }, [active]);

  useEffect(() => {
    if (status === "checking") {
      const id = setTimeout(() => {
        if (value === code) {
          setStatus("success");
          setBannerOpen(false);
          onVerifiedRef.current();
        } else {
          setStatus("error");
        }
      }, 1000);
      return () => clearTimeout(id);
    }
    if (status === "error") {
      const id = setTimeout(() => setValue(""), 650);
      return () => clearTimeout(id);
    }
    if (status === "success") {
      inputRef.current?.blur();
      const id = setTimeout(() => setDone(true), 900);
      return () => clearTimeout(id);
    }
  }, [status, value, code]);

  useEffect(() => {
    if (!resent) return;
    const id = setTimeout(() => setResent(false), 1600);
    return () => clearTimeout(id);
  }, [resent]);

  const enter = (next) => {
    if (locked) return;
    const clean = next.replace(/\D/g, "").slice(0, LENGTH);
    setValue(clean);
    setStatus(clean.length === LENGTH ? "checking" : "idle");
  };

  const fillFromMessage = () => {
    setBannerOpen(false);
    inputRef.current?.focus({ preventScroll: true });
    enter(code);
  };

  const resend = () => {
    onResend();
    restartCountdown();
    setValue("");
    setStatus("idle");
    setResent(true);
    inputRef.current?.focus({ preventScroll: true });
  };

  const usesKeypad = useKeypad(active && status !== "success", {
    variant: "code",
    suggestion: delivered ? code : null,
    onDigit: (d) => enter(value + d),
    onDelete: () => enter(value.slice(0, -1)),
    onSuggestion: fillFromMessage,
  });

  const note =
    status === "error"
      ? "That code doesn’t match. Try the latest one we sent."
      : status === "success"
        ? "Number verified"
        : null;

  return (
    <Screen withKeypad={usesKeypad} aria-labelledby="verify-title">
      <TopBar
        onBack={onBack}
        step={intent === "signup" ? 2 : null}
        steps={intent === "signup" ? 4 : null}
      />

      <ScreenBody>
        <ScreenHeader
          id="verify-title"
          title="Verify your number"
          lede={
            <>
              Enter the code we’ve sent by text to <span className="nowrap strong">{number}</span>.
            </>
          }
        />
        <TextButton className="verify__change" onClick={onChangeNumber}>
          Change number
        </TextButton>

        <Field
          label="Code"
          htmlFor="verify-code"
          labelId="verify-code-label"
          className="verify__field"
          note={note}
          tone={status === "error" ? "error" : status === "success" ? "success" : undefined}
        >
          <CodeInput
            ref={inputRef}
            id="verify-code"
            value={value}
            onChange={enter}
            length={LENGTH}
            status={status}
            inputMode={usesKeypad ? "none" : "numeric"}
            labelledBy="verify-code-label"
          />
        </Field>
      </ScreenBody>

      <ScreenFooter>
        <p className="screen__footer-text resend" aria-live="polite">
          <span>Didn’t get a code?</span>{" "}
          {remaining > 0 ? (
            <span className="resend__timer">
              Resend in 0:{String(remaining).padStart(2, "0")}
            </span>
          ) : (
            <TextButton onClick={resend} disabled={locked}>
              Resend code
            </TextButton>
          )}
        </p>
        <Fab
          label="Verify"
          disabled={value.length < LENGTH || status === "error"}
          loading={status === "checking"}
          onClick={() => enter(value)}
        />
      </ScreenFooter>

      {active && (
        <>
          <Notification
            open={bannerOpen}
            app="Messages"
            title="Numaya"
            body={`Your Numaya code is ${code}. Don’t share it with anyone.`}
            onSelect={fillFromMessage}
          />
          <Toast open={status === "checking"} busy>
            Verifying
          </Toast>
          <Toast open={resent}>New code sent</Toast>
          <Sheet open={done} labelledBy="done-title">
            <IllustrationPlaceholder id="verified-success" ratio="5 / 3" width="200px" shape="droplet" className="verify-art" />
            <ResultPanel
              title={<span id="done-title">{intent === "signin" ? "You’re signed in" : <>You’re <Emphasis>verified</Emphasis></>}</span>}
              footer={
                <>
                  <p className="result__caption">This prototype ends here.</p>
                  <Button variant="primary" onClick={onRestart}>
                    Start over
                  </Button>
                </>
              }
            >
              <p>
                <span className="nowrap strong">{number}</span> is confirmed.{" "}
                {intent === "signin"
                  ? "Your matches are right where you left them."
                  : "Next, a few details for your profile. It takes about two minutes."}
              </p>
            </ResultPanel>
          </Sheet>
        </>
      )}
    </Screen>
  );
}
