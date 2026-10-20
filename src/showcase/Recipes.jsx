import { useEffect, useState } from "react";
import {
  ActionBar,
  Banner,
  Button,
  Composer,
  Dialog,
  EmptyState,
  Fab,
  LegalText,
  ListGroup,
  ListRow,
  MatchCelebration,
  PageDots,
  PermissionPrimer,
  PlanPicker,
  ProfileCard,
  ResultPanel,
  ScreenHeader,
  Sheet,
  Switch,
  TextField,
  Toast,
  TopBar,
} from "../design-system/index.js";
import { Grid, PhoneFrame, Section, StatePicker } from "./ui.jsx";

/** Onboarding step: validation gates the Fab; the age gate blocks under-18s with a neutral message. */
function OnboardingStep() {
  const [name, setName] = useState("");
  const [year, setYear] = useState("");
  const [touched, setTouched] = useState(false);
  const age = year.length === 4 ? new Date().getFullYear() - Number(year) : null;
  const yearError = touched && year.length === 4 && (age < 18 || age > 100) ? (age < 18 ? "You need to be 18 or older to use Numaya." : "Check the year you were born.") : null;
  const valid = name.trim().length > 0 && age !== null && age >= 18 && age <= 100;
  const [done, setDone] = useState(false);

  useEffect(() => {
    if (!done) return;
    const id = setTimeout(() => setDone(false), 1400);
    return () => clearTimeout(id);
  }, [done]);

  return (
    <PhoneFrame title="Multi-step form step" note="Fab enables only when the step is valid">
      <div className="sc-screen">
        <TopBar onBack={() => {}} step={3} steps={6} />
        <div className="sc-screen__body">
          <ScreenHeader title="Let’s start with an intro" lede="Your first name and age appear on your profile." />
          <div className="sc-stack" style={{ marginTop: 28 }}>
            <TextField label="First name" value={name} onChange={(e) => setName(e.target.value)} autoComplete="given-name" />
            <TextField
              label="Year you were born"
              inputMode="numeric"
              maxLength={4}
              value={year}
              onChange={(e) => setYear(e.target.value.replace(/\D/g, ""))}
              onBlur={() => setTouched(true)}
              error={yearError}
              hint="We only show your age, never your birthday."
            />
          </div>
        </div>
        <div className="sc-screen__footer">
          <span className="sc-caption">Step 3 of 6</span>
          <Fab disabled={!valid} onClick={() => setDone(true)} />
        </div>
      </div>
      <Toast open={done} placement="bottom" icon="check">
        Saved. Next step.
      </Toast>
    </PhoneFrame>
  );
}

const PEOPLE = [
  { name: "Maya", age: 29, tone: 1, details: [{ icon: "user", text: "Product designer" }], shared: ["Jazz"] },
  { name: "Jo", age: 31, tone: 2, details: [{ icon: "location", text: "4 km away" }], shared: [] },
  { name: "Ari", age: 27, tone: 0, details: [{ icon: "user", text: "Chef" }], shared: ["Cooking", "Natural wine"] },
];

/** Discovery: like / pass advance the stack; super like without credit opens a contextual paywall; end shows an empty state. */
function Discovery() {
  const [index, setIndex] = useState(0);
  const [toast, setToast] = useState(null);
  const [paywall, setPaywall] = useState(false);
  const [plan, setPlan] = useState("1m");

  useEffect(() => {
    if (!toast) return;
    const id = setTimeout(() => setToast(null), 1200);
    return () => clearTimeout(id);
  }, [toast]);

  const person = PEOPLE[index];
  const next = (msg) => {
    setToast(msg);
    setIndex((i) => i + 1);
  };

  return (
    <PhoneFrame height={760} title="Discovery actions" note="Like, pass, super like → paywall, empty stack">
      <div className="sc-screen">
        <TopBar largeTitle="Discover" />
        <div className="sc-screen__body sc-stack">
          {person ? (
            <>
              <ProfileCard {...person} verified={index !== 1} />
              <ActionBar onPass={() => next(null)} onSuper={() => setPaywall(true)} onLike={() => next(`You liked ${person.name}`)} />
            </>
          ) : (
            <EmptyState title="You’ve seen everyone for now" action="Start over" onAction={() => setIndex(0)}>
              Widen your distance or age range, or check back tomorrow.
            </EmptyState>
          )}
        </div>
      </div>
      <Toast open={Boolean(toast)} placement="bottom" icon="heart">
        {toast}
      </Toast>
      <Sheet open={paywall} onClose={() => setPaywall(false)} labelledBy="sc-paywall-title">
        <div className="sc-paywall">
          <p className="screen-header__eyebrow">Numaya Plus</p>
          <h2 id="sc-paywall-title" className="sheet__title">
            Super likes go to the top of their list
          </h2>
          <p className="sc-caption">You’re out of super likes this week. Plus includes 5 every week.</p>
          <PageDots count={4} index={0} label="Benefit" />
          <PlanPicker
            value={plan}
            onChange={setPlan}
            plans={[
              { id: "1w", title: "1 week", price: "$9.99" },
              { id: "1m", title: "1 month", price: "$24.99", ribbon: "Most popular" },
              { id: "3m", title: "3 months", price: "$49.99", note: "Save 33%" },
            ]}
          />
          <Button onClick={() => setPaywall(false)}>Continue</Button>
          <LegalText>Renews automatically unless cancelled 24 hours before the period ends.</LegalText>
        </div>
      </Sheet>
    </PhoneFrame>
  );
}

/** Match feedback: celebration, composer focused, send confirms. */
function Match() {
  const [text, setText] = useState("");
  const [sent, setSent] = useState(false);
  return (
    <PhoneFrame title="Match feedback" note="Composer is the primary action">
      <div className="sc-screen">
        <TopBar onBack={() => {}} />
        <div className="sc-screen__body sc-center">
          <MatchCelebration names={["You", "Maya"]}>You both liked each other. Say something about her prompt.</MatchCelebration>
        </div>
        <div className="sc-screen__footer sc-screen__footer--stack">
          <Composer
            value={text}
            onChange={setText}
            placeholder="Breakfast for dinner? Bold."
            onSend={() => {
              setText("");
              setSent(true);
              setTimeout(() => setSent(false), 1400);
            }}
          />
        </div>
      </div>
      <Toast open={sent} placement="bottom" icon="check">
        Message sent
      </Toast>
    </PhoneFrame>
  );
}

/** Verification: primer → capture → pending → approved or rejected with retry. */
function Verification() {
  const [step, setStep] = useState("primer");
  const [outcome, setOutcome] = useState("approved");
  useEffect(() => {
    if (step !== "pending") return;
    const id = setTimeout(() => setStep(outcome), 1800);
    return () => clearTimeout(id);
  }, [step, outcome]);

  return (
    <PhoneFrame title="Photo verification" note="Choose the review outcome, then run the flow">
      <div className="sc-screen">
        <TopBar onBack={() => setStep("primer")} title="Verification" />
        <div className="sc-screen__body sc-center">
          {step === "primer" && (
            <PermissionPrimer icon="camera" title="Show them it’s really you" allowLabel="Take a selfie" deferLabel="Maybe later" onAllow={() => setStep("pending")} onDefer={() => {}}>
              Copy a quick pose so we can match you to your photos. Your selfie is never shown on your profile.
            </PermissionPrimer>
          )}
          {step === "pending" && (
            <div className="sc-stack" style={{ width: "100%" }}>
              <Banner tone="warning" title="Checking your selfie">Usually takes a few minutes. You can keep using Numaya.</Banner>
            </div>
          )}
          {step === "approved" && (
            <ResultPanel title="You’re verified" footer={<Button onClick={() => setStep("primer")}>Done</Button>}>
              <p>Your profile now shows the verified badge.</p>
            </ResultPanel>
          )}
          {step === "rejected" && (
            <ResultPanel tone="danger" icon="close" title="We couldn’t verify you" footer={<Button onClick={() => setStep("pending")}>Try again</Button>}>
              <p>Make sure your face is well lit and you copy the pose exactly.</p>
            </ResultPanel>
          )}
        </div>
        <div className="sc-screen__footer">
          <StatePicker label="Review outcome" options={["approved", "rejected"]} value={outcome} onChange={setOutcome} />
        </div>
      </div>
    </PhoneFrame>
  );
}

/** Permission: primer before the OS prompt; denied switches to a Settings recovery. */
function Permission() {
  const [state, setState] = useState("not determined");
  return (
    <PhoneFrame title="Permission primer" note="Never loops: 'Not now' defers until the next relevant moment">
      <div className="sc-screen">
        <div className="sc-screen__body sc-center">
          {state === "granted" ? (
            <ResultPanel title="Location on" footer={<Button variant="secondary" onClick={() => setState("not determined")}>Reset demo</Button>}>
              <p>We’ll show people near you.</p>
            </ResultPanel>
          ) : (
            <PermissionPrimer
              icon="location"
              title={state === "denied" ? "Location is off" : "See people near you"}
              denied={state === "denied"}
              onAllow={() => setState("granted")}
              onOpenSettings={() => setState("granted")}
              onDefer={() => {}}
            >
              {state === "denied"
                ? "Turn on location in Settings to see people nearby. We only use your approximate area."
                : "Numaya uses your approximate location to show nearby people. It’s never shown as an exact place."}
            </PermissionPrimer>
          )}
        </div>
        <div className="sc-screen__footer">
          <StatePicker label="OS permission" options={["not determined", "denied"]} value={state === "granted" ? "not determined" : state} onChange={setState} />
        </div>
      </div>
    </PhoneFrame>
  );
}

const REASONS = [
  ["user", "Fake profile"],
  ["image", "Inappropriate photos or text"],
  ["flag", "Scam or selling something"],
  ["alert", "Hateful or abusive behaviour"],
  ["shield", "Might be under 18"],
  ["location", "Something that happened offline"],
];

/** Safety: report always blocks; reasons → confirmation. The other person is never told. */
function Safety() {
  const [open, setOpen] = useState(false);
  const [reported, setReported] = useState(null);
  return (
    <PhoneFrame title="Report and block" note="Anonymous; reporting always blocks">
      <div className="sc-screen">
        <TopBar onBack={() => {}} title="Maya" />
        <div className="sc-screen__body sc-center">
          {reported ? (
            <ResultPanel title="You’ve blocked and reported Maya" footer={<Button onClick={() => setReported(null)}>Done</Button>}>
              <p>Reason: {reported}. We’ll update you in Help. Maya won’t be told.</p>
            </ResultPanel>
          ) : (
            <div className="sc-stack" style={{ width: "100%" }}>
              <Button variant="secondary" icon="flag" onClick={() => setOpen(true)}>
                Report or block
              </Button>
            </div>
          )}
        </div>
      </div>
      <Sheet open={open} onClose={() => setOpen(false)} labelledBy="sc-report-title">
        <div className="sheet__header">
          <h2 id="sc-report-title" className="sheet__title">
            What’s wrong?
          </h2>
        </div>
        <p className="sc-caption" style={{ marginBottom: 16 }}>
          Your report is anonymous. They won’t know you blocked or reported them.
        </p>
        <ListGroup>
          {REASONS.map(([icon, label]) => (
            <ListRow
              key={label}
              icon={icon}
              label={label}
              onPress={() => {
                setOpen(false);
                setReported(label);
              }}
            />
          ))}
        </ListGroup>
      </Sheet>
    </PhoneFrame>
  );
}

/** Settings: switch rows save with a pending state; destructive actions confirm. */
function Settings() {
  const [values, setValues] = useState({ snooze: false, messages: true });
  const [pending, setPending] = useState(null);
  const [confirm, setConfirm] = useState(false);
  const [offline, setOffline] = useState(false);
  const toggle = (key, v) => {
    if (offline) return;
    setPending(key);
    setTimeout(() => {
      setValues((s) => ({ ...s, [key]: v }));
      setPending(null);
    }, 800);
  };
  return (
    <PhoneFrame title="Settings and system states" note="Pending saves, offline banner, destructive confirm">
      <div className="sc-screen">
        <TopBar onBack={() => {}} title="Settings" />
        <div className="sc-screen__body sc-stack">
          {offline && (
            <Banner tone="offline" title="You’re offline" action="Retry" onAction={() => setOffline(false)}>
              Changes will save when you reconnect.
            </Banner>
          )}
          <ListGroup title="Visibility">
            <li className="list-row">
              <div className="list-row__hit">
                <Switch label="Snooze" description="Hide your profile. Your chats stay." checked={values.snooze} pending={pending === "snooze"} onChange={(v) => toggle("snooze", v)} />
              </div>
            </li>
            <li className="list-row">
              <div className="list-row__hit">
                <Switch label="New message alerts" checked={values.messages} pending={pending === "messages"} onChange={(v) => toggle("messages", v)} />
              </div>
            </li>
          </ListGroup>
          <ListGroup>
            <ListRow label={offline ? "Go back online" : "Simulate offline"} kind="action" onPress={() => setOffline((o) => !o)} />
            <ListRow label="Delete account" kind="destructive" onPress={() => setConfirm(true)} />
          </ListGroup>
        </div>
      </div>
      <Dialog open={confirm} onClose={() => setConfirm(false)} title="Delete your account?" tone="destructive" confirmLabel="Delete account" onConfirm={() => setConfirm(false)}>
        Cancel any subscription in the App Store first. You can restore your account within 28 days.
      </Dialog>
    </PhoneFrame>
  );
}

export function Recipes() {
  return (
    <Section id="recipes" title="Interaction recipes" intro="Composed patterns from the UX inventory. Each is a contract for future screens, not a production screen.">
      <Grid min={400}>
        <OnboardingStep />
        <Discovery />
        <Match />
        <Verification />
        <Permission />
        <Safety />
        <Settings />
      </Grid>
    </Section>
  );
}
