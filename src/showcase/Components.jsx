import { useRef, useState } from "react";
import {
  ActionBar,
  ActionSheet,
  Avatar,
  Badge,
  Banner,
  Button,
  Card,
  Checkbox,
  Chip,
  ChipGroup,
  CoachMark,
  CodeInput,
  ComparisonTable,
  Composer,
  ConsequenceList,
  ConversationRow,
  CountBadge,
  CountryPicker,
  Dialog,
  Divider,
  EmptyState,
  Fab,
  IconButton,
  LegalText,
  Link,
  ListGroup,
  ListRow,
  MatchQueue,
  MessageBubble,
  OptionCards,
  PageDots,
  PhoneField,
  PhotoGrid,
  PlanPicker,
  ProfileCard,
  SharedInterests,
  ProgressSegments,
  PromptCard,
  Radio,
  RangeSlider,
  ResultPanel,
  SetupProgress,
  SearchField,
  SegmentedControl,
  Sheet,
  Skeleton,
  Slider,
  Spinner,
  Switch,
  SystemMessage,
  TabBar,
  Tag,
  TextArea,
  TextButton,
  TextField,
  TipCard,
  Toast,
  TopBar,
  VerifiedBadge,
  Wordmark,
} from "../design-system/index.js";
import { DEFAULT_COUNTRY, digitCount } from "../data/countries.js";
import { Grid, PhoneFrame, Row, Section, Specimen, StatePicker } from "./ui.jsx";

/* -------------------------------------------------------------------------- */

function Actions() {
  const [loading, setLoading] = useState(false);
  return (
    <Section id="actions" title="Actions" intro="One primary action per screen. Loading keeps the size, locks the control and announces aria-busy.">
      <Grid>
        <Specimen title="Button · primary">
          <Button onClick={() => { setLoading(true); setTimeout(() => setLoading(false), 1500); }} loading={loading}>
            {loading ? "Saving" : "Tap to load"}
          </Button>
        </Specimen>
        <Specimen title="Button · secondary · quiet">
          <div className="sc-stack">
            <Button variant="secondary">Secondary</Button>
            <Button variant="quiet">Quiet</Button>
          </div>
        </Specimen>
        <Specimen title="Button · brand · destructive" note="Soft lavender with a deep-purple label (Meetup \u201cSign up with email\u201d)">
          <div className="sc-stack">
            <Button variant="brand">Get verified</Button>
            <Button variant="destructive">Report</Button>
          </div>
        </Specimen>
        <Specimen title="Button · disabled · small · inline">
          <div className="sc-stack">
            <Button disabled>Disabled</Button>
            <Row>
              <Button size="sm" block={false} variant="secondary">
                Small
              </Button>
              <Button size="sm" block={false} icon="heart">
                With icon
              </Button>
            </Row>
          </div>
        </Specimen>
        <Specimen title="Fab · enabled · disabled · loading">
          <Row>
            <Fab />
            <Fab disabled />
            <Fab loading />
          </Row>
        </Specimen>
        <Specimen title="IconButton · floating · flat · plain · pressed" tone="soft">
          <Row>
            <IconButton icon="chevronLeft" label="Back" />
            <IconButton icon="close" label="Close" variant="flat" size="sm" />
            <IconButton icon="more" label="More" variant="plain" />
            <IconButton icon="heart" label="Like" variant="flat" pressed />
          </Row>
        </Specimen>
        <Specimen title="Links" note="TextButton for in-place actions, Link for navigation">
          <div className="sc-stack sc-stack--start">
            <TextButton>Change number</TextButton>
            <Link href="#actions">Privacy Policy</Link>
            <TextButton tone="danger">Report instead</TextButton>
            <TextButton disabled>Resend code</TextButton>
          </div>
        </Specimen>
        <Specimen title="Spinner">
          <Row>
            <Spinner label="Loading" />
            <Spinner size="sm" label="Loading" />
          </Row>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Inputs() {
  const [name, setName] = useState("Maya");
  const [bio, setBio] = useState("Natural wine, a record shop, and nowhere to be after.");
  const [query, setQuery] = useState("");
  const [country, setCountry] = useState(DEFAULT_COUNTRY);
  const [digits, setDigits] = useState("415555");
  const [picker, setPicker] = useState(false);
  const [code, setCode] = useState("482");
  const [codeState, setCodeState] = useState("idle");
  const codeRef = useRef(null);

  return (
    <Section id="inputs" title="Inputs" intro="Labels sit above soft-filled fields. Errors replace hints, turn the field red and are announced.">
      <Grid>
        <Specimen title="TextField · default · filled">
          <div className="sc-stack">
            <TextField label="Your first name" placeholder="First name" value={name} onChange={(e) => setName(e.target.value)} hint="This is how you’ll appear." />
          </div>
        </Specimen>
        <Specimen title="TextField · error · disabled">
          <div className="sc-stack">
            <TextField label="Email" defaultValue="maya@" error="Enter a full email address, like name@example.com." />
            <TextField label="Username" defaultValue="maya" disabled />
          </div>
        </Specimen>
        <Specimen title="TextArea · counter">
          <TextArea label="Bio" value={bio} maxLength={160} onChange={(e) => setBio(e.target.value)} />
        </Specimen>
        <Specimen title="SearchField · clear">
          <SearchField value={query} onChange={(e) => setQuery(e.target.value)} onClear={() => setQuery("")} placeholder="What are you into?" />
        </Specimen>
        <PhoneFrame height={420} title="PhoneField + CountryPicker" note="Formatted per country; length gates the next action">
          <div style={{ padding: "24px" }}>
            <PhoneField
              country={country}
              digits={digits}
              onDigitsChange={(v) => setDigits(v.replace(/\D/g, "").slice(0, digitCount(country)))}
              onCountryPress={() => setPicker(true)}
              countryExpanded={picker}
            />
            <p className="sc-caption" style={{ marginTop: 16 }}>
              {digits.length === digitCount(country) ? "Complete: next enabled" : `${digitCount(country) - digits.length} digits to go`}
            </p>
          </div>
          <CountryPicker
            open={picker}
            selected={country}
            onSelect={(c) => {
              setCountry(c);
              setDigits(digits.slice(0, digitCount(c)));
              setPicker(false);
            }}
            onClose={() => setPicker(false)}
          />
        </PhoneFrame>
        <Specimen title="CodeInput" note="Type, paste or autofill; cells reflect status">
          <div className="sc-stack">
            <StatePicker options={["idle", "checking", "error", "success"]} value={codeState} onChange={setCodeState} />
            <CodeInput ref={codeRef} id="sc-code" value={code} onChange={setCode} status={codeState} labelledBy="sc-code-label" />
            <p id="sc-code-label" className="sc-caption">
              Code
            </p>
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

const INTERESTS = ["Natural wine", "Climbing", "Film photography", "Jazz", "Cooking", "Running", "Museums", "Board games"];

function SelectionControls() {
  const [chips, setChips] = useState(["Jazz", "Cooking"]);
  const [notify, setNotify] = useState(true);
  const [pending, setPending] = useState(false);
  const [incognito, setIncognito] = useState(false);
  const [agree, setAgree] = useState(true);
  const [radio, setRadio] = useState("women");
  const [gender, setGender] = useState("woman");
  const [intent, setIntent] = useState(["long-term"]);
  const [seg, setSeg] = useState("basic");
  const [dist, setDist] = useState(25);
  const [age, setAge] = useState([27, 36]);

  return (
    <Section id="selection" title="Selection" intro="Meetup selection: purple pills with white text and a minus-circle; ink switches, checkboxes and radio rows. Every state also has a shape cue (icon, knob, dot, outline): never colour alone.">
      <Grid>
        <Specimen title="ChipGroup · max 3" note="At the quota, others become unavailable" wide>
          <ChipGroup label="Interests" options={INTERESTS} value={chips} onChange={setChips} max={3} />
        </Specimen>
        <Specimen title="Chip · static · remove">
          <Row>
            <Chip kind="static" icon="location">2 km away</Chip>
            <Chip kind="remove" onRemove={() => {}}>Jazz</Chip>
          </Row>
        </Specimen>
        <Specimen title="Switch · on · off · pending · disabled">
          <div className="sc-stack">
            <Switch
              label="New messages"
              checked={notify}
              pending={pending}
              onChange={(v) => {
                setPending(true);
                setTimeout(() => { setNotify(v); setPending(false); }, 900);
              }}
            />
            <Switch label="Incognito" description="Only people you like can see you." checked={incognito} onChange={setIncognito} />
            <Switch label="Travel mode" checked={false} disabled description="Premium" />
          </div>
        </Specimen>
        <Specimen title="Checkbox · Radio">
          <div className="sc-stack">
            <Checkbox label="Show my age on my profile" checked={agree} onChange={setAgree} />
            <Radio name="sc-radio" label="Women" checked={radio === "women"} onChange={() => setRadio("women")} />
            <Radio name="sc-radio" label="Men" checked={radio === "men"} onChange={() => setRadio("men")} />
            <Checkbox label="Disabled" checked={false} disabled />
          </div>
        </Specimen>
        <Specimen title="OptionCards · single">
          <OptionCards
            legend="Which gender best describes you?"
            value={gender}
            onChange={setGender}
            options={[
              { value: "woman", label: "Woman" },
              { value: "man", label: "Man" },
              { value: "nonbinary", label: "Nonbinary" },
            ]}
          />
        </Specimen>
        <Specimen title="OptionCards · multi · max 2">
          <OptionCards
            legend="What are you looking for? Choose up to 2."
            mode="multi"
            max={2}
            value={intent}
            onChange={setIntent}
            options={[
              { value: "long-term", label: "A long-term relationship" },
              { value: "open", label: "Open to seeing where it goes" },
              { value: "marriage", label: "Marriage" },
              { value: "casual", label: "Something casual" },
            ]}
          />
        </Specimen>
        <Specimen title="SegmentedControl" note="Arrow keys move selection">
          <SegmentedControl
            label="Filter type"
            value={seg}
            onChange={setSeg}
            options={[
              { value: "basic", label: "Basic" },
              { value: "advanced", label: "Advanced" },
            ]}
          />
        </Specimen>
        <Specimen title="Slider · RangeSlider">
          <div className="sc-stack">
            <Slider label="Distance" min={1} max={100} value={dist} onChange={setDist} format={(v) => `Up to ${v} km`} />
            <RangeSlider label="Age" min={18} max={80} value={age} onChange={setAge} />
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Identity() {
  return (
    <Section id="identity" title="Identity and status">
      <Grid>
        <Specimen title="Avatar · sizes">
          <Row>
            {["xs", "sm", "md", "lg", "xl"].map((s) => (
              <Avatar key={s} name="Maya" size={s} />
            ))}
          </Row>
        </Specimen>
        <Specimen title="Avatar · ring · verified" note="Completion or time remaining">
          <Row gap={20}>
            <Avatar name="Sam" size="lg" ring={{ value: 0.45 }} />
            <Avatar name="Jo" size="lg" ring={{ value: 0.12, tone: "muted" }} />
            <Avatar name="Ari" size="lg" verified />
          </Row>
        </Specimen>
        <Specimen title="VerifiedBadge" note="Exact brand fill, ink check, text label">
          <Row>
            <VerifiedBadge />
            <VerifiedBadge label="Photo verified" />
          </Row>
        </Specimen>
        <Specimen title="Badge · tones">
          <Row>
            <Badge>Neutral</Badge>
            <Badge tone="brand" icon="star">Premium</Badge>
            <Badge tone="success" icon="check">Approved</Badge>
            <Badge tone="warning">Pending</Badge>
            <Badge tone="danger">Rejected</Badge>
            <Badge tone="inverse">New here</Badge>
          </Row>
        </Specimen>
        <Specimen title="Tag · CountBadge">
          <Row>
            <Tag>Your move</Tag>
            <Tag tone="neutral">Save 53%</Tag>
            <Tag tone="inverse">Most popular</Tag>
            <CountBadge count={3} />
            <CountBadge count={140} />
          </Row>
        </Specimen>
        <Specimen title="Wordmark">
          <Row>
            <Wordmark />
            <Wordmark size="sm" />
          </Row>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Surfaces() {
  return (
    <Section id="surfaces" title="Surfaces and lists">
      <Grid>
        <Specimen title="ListGroup · ListRow kinds" tone="soft" wide>
          <ListGroup title="Account" footnote="Turning these off might mean you miss messages from your matches.">
            <ListRow icon="location" label="Current location" kind="value" value="London, UK" onPress={() => {}} />
            <ListRow icon="bell" label="Notifications" onPress={() => {}} />
            <ListRow icon="eyeOff" label="Travel mode" description="Change your location before a trip" kind="locked" onPress={() => {}} />
            <ListRow label="Log out" kind="action" onPress={() => {}} />
            <ListRow label="Delete account" kind="destructive" onPress={() => {}} />
          </ListGroup>
        </Specimen>
        <Specimen title="Card · TipCard">
          <div className="sc-stack">
            <Card>
              <p className="sc-card-title">Card</p>
              <p className="sc-caption">Hairline border, radius lg. Elevated variant uses shadow.card.</p>
            </Card>
            <TipCard title="Show your personality">Share a quirk, an interest or a bit of humour.</TipCard>
            <TipCard icon="message" title="Need help with the first message?" onPress={() => {}}>
              Try an Opening Move.
            </TipCard>
          </div>
        </Specimen>
        <Specimen title="ConsequenceList · Divider">
          <div className="sc-stack">
            <ConsequenceList
              items={[
                { icon: "eyeOff", text: "You won’t see each other again" },
                { icon: "message", text: "They won’t be able to message you" },
              ]}
            />
            <Divider />
            <p className="sc-caption">Used in unmatch, block and delete confirmations.</p>
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Profile() {
  const [photos, setPhotos] = useState([
    { id: 1, tone: 0 },
    { id: 2, tone: 1 },
    { id: 3, tone: 2, uploading: true },
  ]);
  const add = () => {
    const id = Date.now();
    setPhotos((p) => (p.length >= 6 ? p : [...p, { id, tone: p.length % 4, uploading: true }]));
    setTimeout(() => setPhotos((p) => p.map((x) => (x.id === id ? { ...x, uploading: false } : x))), 1200);
  };
  const [page, setPage] = useState(1);

  return (
    <Section id="profile" title="Profile content">
      <Grid>
        <Specimen title="PromptCard · read · editable" tone="soft">
          <div className="sc-stack">
            <PromptCard prompt="Let’s debate this" answer="Breakfast for dinner is the superior meal." />
            <PromptCard prompt="A perfect first date" answer="Natural wine, a record shop, and nowhere to be after." onEdit={() => {}} onRemove={() => {}} />
          </div>
        </Specimen>
        <Specimen title="PhotoGrid · add · remove · uploading" note="First photo is Main">
          <PhotoGrid photos={photos} onAdd={add} onRemove={(id) => setPhotos((p) => p.filter((x) => x.id !== id))} />
        </Specimen>
        <Specimen title="ProfileCard + ActionBar" note="Photo inset in a white card; identity sits on white, so no scrim. Pass actions to place them on the seam">
          <div className="sc-stack">
            <ProfileCard
              name="Maya"
              age={29}
              verified
              isNew
              tone={1}
              details={[
                { icon: "user", text: "Product designer" },
                { icon: "location", text: "2 km away" },
              ]}
              shared={["Jazz", "Cooking"]}
            />
            <ActionBar onPass={() => {}} onSuper={() => {}} onLike={() => {}} />
          </div>
        </Specimen>
        <Specimen title="SharedInterests" note="“You both like”: white card, small purple mark, grey pills with icons (Meetup “Shared interests”)">
          <SharedInterests
            items={[
              { label: "Jazz" },
              { label: "Natural wine" },
              { label: "Film photography" },
            ]}
          />
        </Specimen>
        <Specimen title="PageDots">
          <div className="sc-stack">
            <PageDots count={5} index={page} />
            <Row>
              <Button size="sm" block={false} variant="secondary" onClick={() => setPage((p) => (p + 4) % 5)}>Prev</Button>
              <Button size="sm" block={false} variant="secondary" onClick={() => setPage((p) => (p + 1) % 5)}>Next</Button>
            </Row>
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Navigation() {
  const [tab, setTab] = useState("discover");
  return (
    <Section id="navigation" title="Navigation">
      <Grid>
        <Specimen title="TopBar · back + progress">
          <div className="sc-bleed">
            <TopBar onBack={() => {}} step={2} steps={4} />
          </div>
        </Specimen>
        <Specimen title="TopBar · title + actions">
          <div className="sc-bleed">
            <TopBar onBack={() => {}} title="Edit profile" actions={<IconButton icon="more" label="More" variant="plain" />} />
          </div>
        </Specimen>
        <Specimen title="TopBar · large title">
          <div className="sc-bleed">
            <TopBar largeTitle="Chats" actions={<IconButton icon="search" label="Search chats" variant="plain" />} />
          </div>
        </Specimen>
        <Specimen title="ProgressSegments">
          <Row>
            <ProgressSegments step={1} steps={4} />
            <ProgressSegments step={3} steps={4} />
          </Row>
        </Specimen>
        <Specimen title="TabBar" note="Floating bar. Active: brand-tint surface, filled icon, ink semibold label" wide>
          <div className="sc-bleed">
            <TabBar
              current={tab}
              onChange={setTab}
              items={[
                { id: "discover", label: "Discover", icon: "cards" },
                { id: "likes", label: "Likes", icon: "heart", badge: 3 },
                { id: "chats", label: "Chats", icon: "message", badge: 12 },
                { id: "profile", label: "Profile", icon: "user" },
              ]}
            />
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Feedback() {
  const [toast, setToast] = useState(false);
  const [busy, setBusy] = useState(false);
  return (
    <Section id="feedback" title="Feedback and states">
      <Grid>
        <PhoneFrame height={300} title="Toast · busy · status" note="Polite live region; bottom placement on content screens">
          <div className="sc-stack" style={{ padding: 24 }}>
            <Button variant="secondary" onClick={() => { setBusy(true); setTimeout(() => setBusy(false), 1600); }}>
              Show busy toast
            </Button>
            <Button variant="secondary" onClick={() => { setToast(true); setTimeout(() => setToast(false), 1600); }}>
              Show status toast
            </Button>
          </div>
          <Toast open={busy} busy>Verifying</Toast>
          <Toast open={toast} placement="bottom" icon="check">Saved</Toast>
        </PhoneFrame>
        <Specimen title="Banner · tones" wide>
          <div className="sc-stack">
            <Banner tone="offline" title="You’re offline">We’ll keep trying and send your messages when you’re back.</Banner>
            <Banner tone="error" title="Couldn’t load matches" action="Try again" onAction={() => {}} />
            <Banner tone="warning" title="Verification pending">Usually takes a few minutes.</Banner>
            <Banner tone="info" title="Profiles with 4 photos get more matches" />
            <Banner tone="success" title="Photo verified" />
          </div>
        </Specimen>
        <Specimen title="Skeleton" note="Matches the final layout; shimmer stops with reduced motion">
          <div className="sc-stack">
            <Row wrap={false}>
              <Skeleton circle height={48} />
              <div className="sc-stack" style={{ flex: 1, gap: 8 }}>
                <Skeleton width="60%" />
                <Skeleton width="85%" height={12} />
              </div>
            </Row>
            <Skeleton height={160} radius="var(--radius-lg)" />
          </div>
        </Specimen>
        <Specimen title="EmptyState · neutral · error">
          <div className="sc-stack">
            <EmptyState title="You’ve seen everyone nearby" action="Widen your filters" onAction={() => {}}>
              New people join every day. Try a larger distance or age range.
            </EmptyState>
            <EmptyState tone="error" icon="wifiOff" title="Something went wrong" action="Try again" onAction={() => {}}>
              We couldn’t load this. Your changes are safe.
            </EmptyState>
          </div>
        </Specimen>
        <Specimen title="ResultPanel" note="Tones: success (brand ring, verification), neutral (safety outcomes), danger. White inset disc, ink check">
          <ResultPanel tone="neutral" title="You’ve blocked and reported Jo" footer={<Button>Done</Button>}>
            <p>Thanks for helping keep Numaya safe. We’ll update you in Help.</p>
          </ResultPanel>
        </Specimen>
        <Specimen title="SetupProgress" note="White card · done (purple tile, white check) · next (ink tile) · upcoming (muted)">
          <SetupProgress
            title="Your profile"
            steps={[
              { label: "The basics", detail: "Name, age and what you’re looking for", icon: "user", status: "done" },
              { label: "Interests and prompt", detail: "What you’re into, in your words", icon: "interests", status: "active" },
              { label: "Photos", detail: "At least two", icon: "camera", status: "upcoming" },
            ]}
          />
        </Specimen>
        <Specimen title="CoachMark" tone="soft">
          <CoachMark title="Or start however you like" step={2} total={2} onDismiss={() => {}}>
            Send any first message. You don’t have to use the prompt.
          </CoachMark>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Overlays() {
  const [sheet, setSheet] = useState(false);
  const [actions, setActions] = useState(false);
  const [dialog, setDialog] = useState(false);
  const [deleting, setDeleting] = useState(false);
  return (
    <Section id="overlays" title="Overlays" intro="Overlays are scoped to the frame. Focus moves in, Tab is trapped, Escape and the scrim dismiss, and focus returns to the trigger.">
      <Grid min={400}>
        <PhoneFrame height={560} title="Sheet · ActionSheet · Dialog">
          <div className="sc-stack" style={{ padding: 24 }}>
            <Button variant="secondary" onClick={() => setSheet(true)}>Open sheet</Button>
            <Button variant="secondary" onClick={() => setActions(true)}>Open action sheet</Button>
            <Button variant="secondary" onClick={() => setDialog(true)}>Open destructive dialog</Button>
          </div>
          <Sheet open={sheet} onClose={() => setSheet(false)} labelledBy="sc-sheet-title">
            <div className="sheet__header">
              <h2 id="sc-sheet-title" className="sheet__title">What do you want from your dates?</h2>
              <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setSheet(false)} />
            </div>
            <p className="sc-caption">Sheets hold one focused task. The footer action saves and closes.</p>
            <div style={{ marginTop: 20 }}>
              <Button onClick={() => setSheet(false)}>Save and close</Button>
            </div>
          </Sheet>
          <ActionSheet
            open={actions}
            onClose={() => setActions(false)}
            actions={[
              { label: "Did you meet?", onSelect: () => setActions(false) },
              { label: "Unmatch", onSelect: () => setActions(false) },
              { label: "Report", tone: "destructive", onSelect: () => setActions(false) },
            ]}
          />
          <Dialog
            open={dialog}
            onClose={() => setDialog(false)}
            title="Delete your account?"
            tone="destructive"
            confirmLabel="Delete account"
            loading={deleting}
            onConfirm={() => {
              setDeleting(true);
              setTimeout(() => { setDeleting(false); setDialog(false); }, 1200);
            }}
          >
            Your profile, matches and messages will be removed. You can restore it within 28 days.
          </Dialog>
        </PhoneFrame>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Chat() {
  const [messages, setMessages] = useState([
    { id: 1, from: "them", text: "Breakfast for dinner. Defend it." },
    { id: 2, from: "me", text: "Pancakes taste better after dark. That’s science.", status: "delivered", time: "21:04" },
  ]);
  const [text, setText] = useState("");
  const [failNext, setFailNext] = useState(false);

  const settle = (id, status) => setMessages((m) => m.map((x) => (x.id === id ? { ...x, status } : x)));
  const send = (value) => {
    const id = Date.now();
    const fail = failNext;
    setMessages((m) => [...m.map((x) => ({ ...x, time: undefined, status: x.status === "delivered" ? undefined : x.status })), { id, from: "me", text: value, status: "sending" }]);
    setText("");
    setTimeout(() => settle(id, fail ? "failed" : "delivered"), 700);
  };

  return (
    <Section id="chat" title="Chat" intro="Optimistic send: bubbles appear immediately, then settle as delivered or failed with retry. Text is never lost.">
      <Grid min={400}>
        <PhoneFrame height={520} title="Conversation · Composer" note="Toggle failure to see the recovery path">
          <div className="sc-chat">
            <div className="sc-chat__messages">
              <SystemMessage>You matched today</SystemMessage>
              {messages.map((m, i) => (
                <MessageBubble
                  key={m.id}
                  from={m.from}
                  status={m.from === "me" ? m.status : undefined}
                  time={m.time}
                  grouped={i > 0 && messages[i - 1].from === m.from}
                  onRetry={() => { settle(m.id, "sending"); setTimeout(() => settle(m.id, "delivered"), 700); }}
                  onDelete={() => setMessages((all) => all.filter((x) => x.id !== m.id))}
                >
                  {m.text}
                </MessageBubble>
              ))}
            </div>
            <div className="sc-chat__composer">
              <Checkbox label="Fail the next send" checked={failNext} onChange={setFailNext} />
              <Composer value={text} onChange={setText} onSend={send} onAttach={() => {}} />
            </div>
          </div>
        </PhoneFrame>
        <Specimen title="MatchQueue · ConversationRow" wide>
          <div className="sc-stack">
            <MatchQueue
              matches={[
                { id: 1, name: "Maya", remaining: 0.8 },
                { id: 2, name: "Jo", remaining: 0.15 },
                { id: 3, name: "Ari" },
                { id: 4, name: "Sam", remaining: 0.5 },
              ]}
            />
            <ul className="sc-list">
              <ConversationRow name="Maya" preview="Pancakes taste better after dark." time="21:04" verified onPress={() => {}} />
              <ConversationRow name="Jo" preview="Matched 2 hours ago" yourMove onPress={() => {}} />
              <ConversationRow name="Ari" preview="Sunday market?" time="Tue" unread={2} onPress={() => {}} />
            </ul>
          </div>
        </Specimen>
      </Grid>
    </Section>
  );
}

/* -------------------------------------------------------------------------- */

function Commerce() {
  const [plan, setPlan] = useState("1m");
  return (
    <Section id="commerce" title="Premium" intro="Selection is always explicit. Price, renewal and cancellation terms stay visible next to the action.">
      <Grid>
        <Specimen title="PlanPicker" wide>
          <div className="sc-stack">
            <PlanPicker
              value={plan}
              onChange={setPlan}
              plans={[
                { id: "1w", title: "1 week", price: "$9.99" },
                { id: "1m", title: "1 month", price: "$24.99", unit: "$5.77 / week", ribbon: "Most popular" },
                { id: "3m", title: "3 months", price: "$49.99", unit: "$3.85 / week", note: "Save 33%" },
              ]}
            />
            <Button>Continue with {plan === "1w" ? "1 week" : plan === "1m" ? "1 month" : "3 months"}</Button>
            <LegalText>Renews automatically at the same price unless cancelled at least 24 hours before the period ends. Manage or cancel in your App Store settings.</LegalText>
          </div>
        </Specimen>
        <Specimen title="ComparisonTable">
          <ComparisonTable
            tiers={["Free", "Plus"]}
            rows={[
              { feature: "Unlimited likes", tiers: [false, true] },
              { feature: "See who liked you", tiers: [false, true] },
              { feature: "Advanced filters", tiers: [false, true] },
              { feature: "Daily picks", tiers: ["3", "10"] },
            ]}
          />
        </Specimen>
      </Grid>
    </Section>
  );
}

export function Components() {
  return (
    <>
      <Actions />
      <Inputs />
      <SelectionControls />
      <Identity />
      <Surfaces />
      <Profile />
      <Navigation />
      <Feedback />
      <Overlays />
      <Chat />
      <Commerce />
    </>
  );
}
