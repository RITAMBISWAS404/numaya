import { useState } from "react";
import {
  ActionBar,
  ActionSheet,
  Avatar,
  Badge,
  Button,
  ChipGroup,
  Composer,
  ConsequenceList,
  ConversationRow,
  Dialog,
  Fab,
  IconButton,
  ListGroup,
  ListRow,
  MatchCelebration,
  MatchQueue,
  MessageBubble,
  OptionCards,
  PhotoGrid,
  ProfileCard,
  PromptCard,
  RangeSlider,
  ResultPanel,
  ScreenHeader,
  Section,
  Sheet,
  Slider,
  Switch,
  SystemMessage,
  TabBar,
  TextField,
  Toast,
  TopBar,
  VerifiedBadge,
  Wordmark,
} from "../design-system/index.js";
import { ME, MAYA, MATCHES, CONVERSATIONS, INTERESTS, REPORT_REASONS } from "./data.js";

const TABS = [
  { id: "discover", label: "Discover", icon: "sparkle" },
  { id: "likes", label: "Likes", icon: "heart", badge: 4 },
  { id: "chats", label: "Chats", icon: "message", badge: 2 },
  { id: "profile", label: "Profile", icon: "user" },
];
const TAB_TARGET = { discover: "discovery", likes: "discovery", chats: "chats", profile: "profile" };

/** Shared screen scaffold inside a preview frame. */
function Frame({ top, footer, tab, go, children, tone }) {
  return (
    <div className={`fl-screen${tone === "brand" ? " fl-screen--brand" : ""}`}>
      {top}
      <div className="fl-screen__body">{children}</div>
      {footer && <div className="fl-screen__footer">{footer}</div>}
      {tab && <TabBar items={TABS} current={tab} onChange={(id) => go(TAB_TARGET[id])} />}
    </div>
  );
}

/* 1 · Onboarding → profile setup -------------------------------------------- */
export function SetupIntro({ go }) {
  return (
    <Frame
      tone="brand"
      footer={
        <div className="fl-stack fl-stack--full">
          <Button onClick={() => go("basics")}>Build my profile</Button>
          <p className="fl-caption fl-center">About two minutes. You can finish later.</p>
        </div>
      }
    >
      <div className="fl-center fl-intro">
        <Wordmark />
        <ResultPanel title="You’re verified">
          <p>+1 (415) 555-0132 is confirmed. Now let’s make a profile people actually want to reply to.</p>
        </ResultPanel>
        <ol className="fl-steps">
          {["The basics", "What you’re into", "Photos"].map((s, i) => (
            <li key={s}>
              <span className="fl-steps__index">{i + 1}</span>
              {s}
            </li>
          ))}
        </ol>
      </div>
    </Frame>
  );
}

/* 2 · Profile creation ------------------------------------------------------ */
export function Basics({ go }) {
  const [name, setName] = useState("Alex");
  const [year, setYear] = useState("1995");
  const [gender, setGender] = useState("man");
  const [looking, setLooking] = useState(["long-term"]);
  const valid = name.trim() && year.length === 4;
  return (
    <Frame
      top={<TopBar onBack={() => go("intro")} step={3} steps={6} />}
      footer={
        <>
          <span className="fl-caption">Shown on your profile: first name and age</span>
          <Fab disabled={!valid} onClick={() => go("interests")} />
        </>
      }
    >
      <ScreenHeader title="Let’s start with the basics" />
      <div className="fl-stack fl-gap-lg">
        <TextField label="First name" value={name} onChange={(e) => setName(e.target.value)} autoComplete="given-name" />
        <TextField label="Year you were born" inputMode="numeric" maxLength={4} value={year} onChange={(e) => setYear(e.target.value.replace(/\D/g, ""))} hint="We show your age, never your birthday." />
        <OptionCards
          legend="I’m a"
          value={gender}
          onChange={setGender}
          options={[
            { value: "woman", label: "Woman" },
            { value: "man", label: "Man" },
            { value: "nonbinary", label: "Nonbinary" },
          ]}
        />
        <OptionCards
          legend="Looking for (up to 2)"
          mode="multi"
          max={2}
          value={looking}
          onChange={setLooking}
          options={[
            { value: "long-term", label: "A long-term relationship" },
            { value: "open", label: "Open to seeing where it goes" },
            { value: "casual", label: "Something casual" },
          ]}
        />
      </div>
    </Frame>
  );
}

export function InterestsPrompts({ go }) {
  const [interests, setInterests] = useState(["Natural wine", "Jazz", "Cooking"]);
  return (
    <Frame
      top={<TopBar onBack={() => go("basics")} step={4} steps={6} />}
      footer={
        <>
          <span className="fl-caption">{interests.length}/5 interests</span>
          <Fab disabled={interests.length < 3} onClick={() => go("photos")} />
        </>
      }
    >
      <ScreenHeader title="What are you into?" lede="Pick 3 to 5. They start conversations and help us find people like you." />
      <div className="fl-stack fl-gap-lg">
        <ChipGroup label="Interests" options={INTERESTS} value={interests} onChange={setInterests} max={5} />
        <Section title="Your prompts" description="Answer at least one. Matches reply to these.">
          <div className="fl-stack">
            <PromptCard prompt="A perfect first date" answer="A record shop, a long walk, and nowhere to be after." onEdit={() => {}} onRemove={() => {}} />
            <button type="button" className="fl-add-prompt">
              + Add a prompt
            </button>
          </div>
        </Section>
      </div>
    </Frame>
  );
}

export function Photos({ go }) {
  const [photos, setPhotos] = useState([
    { id: 1, tone: 0 },
    { id: 2, tone: 1 },
    { id: 3, tone: 2 },
  ]);
  const add = () => {
    const id = Date.now();
    setPhotos((p) => (p.length >= 6 ? p : [...p, { id, tone: p.length % 4, uploading: true }]));
    setTimeout(() => setPhotos((p) => p.map((x) => (x.id === id ? { ...x, uploading: false } : x))), 1100);
  };
  return (
    <Frame
      top={<TopBar onBack={() => go("interests")} step={5} steps={6} />}
      footer={
        <>
          <span className="fl-caption">{photos.length < 4 ? `Add ${4 - photos.length} more for the best results` : "Looking great"}</span>
          <Fab disabled={photos.length < 2} onClick={() => go("discovery")} />
        </>
      }
    >
      <ScreenHeader title="Add your photos" lede="At least 2, ideally 4. Clear, recent, and just you in the first one." />
      <div className="fl-gap-lg">
        <PhotoGrid photos={photos} onAdd={add} onRemove={(id) => setPhotos((p) => p.filter((x) => x.id !== id))} />
      </div>
    </Frame>
  );
}

/* 3 · Discovery ------------------------------------------------------------- */
export function Discovery({ go }) {
  const [index, setIndex] = useState(0);
  const [toast, setToast] = useState(null);
  const person = index % 2 === 0 ? MAYA : { ...MAYA, name: "Jo", age: 31, tone: 2, details: [{ icon: "location", text: "4 km away" }], shared: [] };
  const act = (liked) => {
    setToast(liked ? `You liked ${person.name}` : null);
    setTimeout(() => setToast(null), 1200);
    if (liked && index === 0) return setTimeout(() => go("match"), 700);
    setIndex((i) => i + 1);
  };
  return (
    <Frame
      top={<TopBar largeTitle="Discover" actions={<IconButton icon="filter" label="Filters" variant="plain" />} />}
      tab="discover"
      go={go}
    >
      <div className="fl-stack">
        <ProfileCard key={index} {...person} />
        <ActionBar onPass={() => act(false)} onSuper={() => act(true)} onLike={() => act(true)} />
        <PromptCard prompt={person.prompt.q} answer={person.prompt.a} />
        <ListGroup>
          {person.facts.map((f) => (
            <ListRow key={f.label} icon={f.icon} label={f.label} kind="value" value={f.value} />
          ))}
        </ListGroup>
      </div>
      <Toast open={Boolean(toast)} placement="bottom" icon="heart">
        {toast}
      </Toast>
    </Frame>
  );
}

/* 4 · Matching -------------------------------------------------------------- */
export function Match({ go }) {
  const [text, setText] = useState("");
  return (
    <Frame
      top={<TopBar onBack={() => go("discovery")} />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Composer value={text} onChange={setText} placeholder="Ask about the record shop…" onSend={() => go("chat")} />
          <Button variant="quiet" onClick={() => go("discovery")}>
            Keep browsing
          </Button>
        </div>
      }
    >
      <div className="fl-center fl-fill">
        <MatchCelebration names={[ME.name, MAYA.name]} title="It’s a match">
          You and Maya liked each other. She answered “A perfect first date”. Start there.
        </MatchCelebration>
      </div>
    </Frame>
  );
}

/* 5 · Messaging ------------------------------------------------------------- */
export function Chats({ go }) {
  return (
    <Frame top={<TopBar largeTitle="Chats" actions={<IconButton icon="search" label="Search chats" variant="plain" />} />} tab="chats" go={go}>
      <div className="fl-stack fl-gap-lg">
        <section>
          <p className="fl-label">New matches</p>
          <MatchQueue matches={MATCHES} onSelect={() => go("chat")} />
        </section>
        <section>
          <p className="fl-label">Conversations</p>
          <ul className="fl-list">
            {CONVERSATIONS.map((c) => (
              <ConversationRow key={c.name} {...c} onPress={() => go("chat")} />
            ))}
          </ul>
        </section>
      </div>
    </Frame>
  );
}

export function Chat({ go }) {
  const [messages, setMessages] = useState([
    { id: 1, from: "them", text: "Okay, which record shop? I need to know your taste first." },
    { id: 2, from: "me", text: "Phonica in Soho. Jazz section, obviously." },
    { id: 3, from: "them", text: "Obviously. Saturday afternoon?" },
  ]);
  const [text, setText] = useState("");
  const [menu, setMenu] = useState(false);
  const [report, setReport] = useState(false);
  const [blocked, setBlocked] = useState(null);
  const [confirm, setConfirm] = useState(false);

  const send = (value) => {
    const id = Date.now();
    setMessages((m) => [...m, { id, from: "me", text: value, status: "sending" }]);
    setText("");
    setTimeout(() => setMessages((m) => m.map((x) => (x.id === id ? { ...x, status: "delivered", time: "now" } : x))), 700);
  };

  if (blocked) {
    return (
      <Frame top={<TopBar onBack={() => go("chats")} />}>
        <div className="fl-center fl-fill">
          <ResultPanel title={`You’ve blocked and reported ${MAYA.name}`} footer={<Button onClick={() => { setBlocked(null); go("chats"); }}>Done</Button>}>
            <p>Reason: {blocked}. She won’t be told, and you won’t see each other again. We’ll update you in Help.</p>
          </ResultPanel>
        </div>
      </Frame>
    );
  }

  return (
    <Frame
      top={
        <header className="fl-chat-head">
          <IconButton icon="chevronLeft" label="Back to chats" variant="plain" onClick={() => go("chats")} />
          <Avatar name={MAYA.name} size="sm" verified decorative />
          <span className="fl-chat-head__name">
            {MAYA.name} <VerifiedBadge compact />
          </span>
          <IconButton icon="more" label="Conversation options" variant="plain" onClick={() => setMenu(true)} />
        </header>
      }
      footer={<Composer value={text} onChange={setText} onSend={send} onAttach={() => {}} />}
    >
      <div className="fl-messages">
        <SystemMessage>You matched with Maya · Today</SystemMessage>
        {messages.map((m, i) => (
          <MessageBubble key={m.id} from={m.from} status={m.status} time={m.time} grouped={i > 0 && messages[i - 1].from === m.from}>
            {m.text}
          </MessageBubble>
        ))}
      </div>

      <ActionSheet
        open={menu}
        onClose={() => setMenu(false)}
        actions={[
          { label: "View profile", onSelect: () => { setMenu(false); go("discovery"); } },
          { label: "Unmatch", onSelect: () => { setMenu(false); setConfirm(true); } },
          { label: "Report or block", tone: "destructive", onSelect: () => { setMenu(false); setReport(true); } },
        ]}
      />
      <Sheet open={report} onClose={() => setReport(false)} labelledBy="fl-report-title">
        <div className="sheet__header">
          <h2 id="fl-report-title" className="sheet__title">
            What’s going on?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setReport(false)} />
        </div>
        <p className="fl-caption fl-mb">Your report is anonymous. Reporting also blocks them.</p>
        <ListGroup>
          {REPORT_REASONS.map(([icon, label]) => (
            <ListRow key={label} icon={icon} label={label} onPress={() => { setReport(false); setBlocked(label); }} />
          ))}
        </ListGroup>
      </Sheet>
      <Dialog open={confirm} onClose={() => setConfirm(false)} title={`Unmatch ${MAYA.name}?`} tone="destructive" confirmLabel="Unmatch" onConfirm={() => { setConfirm(false); go("chats"); }}>
        <ConsequenceList
          items={[
            { icon: "eyeOff", text: "You won’t see each other again" },
            { icon: "message", text: "This conversation will be deleted" },
          ]}
        />
      </Dialog>
    </Frame>
  );
}

/* 6 · Profile and settings -------------------------------------------------- */
export function MyProfile({ go }) {
  return (
    <Frame top={<TopBar largeTitle="Profile" actions={<IconButton icon="settings" label="Settings" variant="plain" onClick={() => go("settings")} />} />} tab="profile" go={go}>
      <div className="fl-stack fl-gap-lg">
        <div className="fl-me">
          <Avatar name={ME.name} size="xl" ring={{ value: 0.8 }} />
          <div>
            <p className="fl-me__name">
              {ME.name}, {ME.age}
            </p>
            <Badge tone="brand">Profile 80% complete</Badge>
          </div>
        </div>
        <Button variant="secondary" icon="user" onClick={() => go("basics")}>
          Edit profile
        </Button>
        <PromptCard prompt="A perfect first date" answer="A record shop, a long walk, and nowhere to be after." />
        <ListGroup title="Your profile">
          <ListRow icon="image" label="Photos" kind="value" value="4 of 6" onPress={() => go("photos")} />
          <ListRow icon="sparkle" label="Interests" kind="value" value="Jazz, Cooking +3" onPress={() => go("interests")} />
          <ListRow icon="shield" label="Verification" kind="value" value="Phone verified" onPress={() => {}} />
        </ListGroup>
      </div>
    </Frame>
  );
}

export function Settings({ go }) {
  const [age, setAge] = useState([27, 38]);
  const [distance, setDistance] = useState(15);
  const [prefs, setPrefs] = useState({ snooze: false, messages: true, likes: true });
  const [pending, setPending] = useState(null);
  const [deleting, setDeleting] = useState(false);
  const toggle = (key, value) => {
    setPending(key);
    setTimeout(() => {
      setPrefs((p) => ({ ...p, [key]: value }));
      setPending(null);
    }, 700);
  };
  const SwitchRow = ({ k, label, description }) => (
    <li className="list-row">
      <div className="list-row__hit">
        <Switch label={label} description={description} checked={prefs[k]} pending={pending === k} onChange={(v) => toggle(k, v)} />
      </div>
    </li>
  );
  return (
    <Frame top={<TopBar onBack={() => go("profile")} title="Settings" />}>
      <div className="fl-stack fl-gap-lg">
        <ListGroup title="Who you see">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <RangeSlider label="Age" min={18} max={70} value={age} onChange={setAge} />
            </div>
          </li>
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <Slider label="Distance" min={1} max={100} value={distance} onChange={setDistance} format={(v) => `${v} km`} />
            </div>
          </li>
        </ListGroup>
        <ListGroup title="Visibility" footnote="Snooze hides your profile. Matches and chats stay.">
          <SwitchRow k="snooze" label="Snooze" />
        </ListGroup>
        <ListGroup title="Notifications">
          <SwitchRow k="messages" label="New messages" />
          <SwitchRow k="likes" label="New likes" />
        </ListGroup>
        <ListGroup title="Privacy and safety">
          <ListRow icon="shield" label="Blocked people" kind="value" value="1" onPress={() => {}} />
          <ListRow icon="lock" label="Data and privacy" onPress={() => {}} />
        </ListGroup>
        <ListGroup>
          <ListRow label="Log out" kind="action" onPress={() => go("intro")} />
          <ListRow label="Delete account" kind="destructive" onPress={() => setDeleting(true)} />
        </ListGroup>
      </div>
      <Dialog open={deleting} onClose={() => setDeleting(false)} title="Delete your account?" tone="destructive" confirmLabel="Delete account" onConfirm={() => setDeleting(false)}>
        Your profile, matches and messages will be removed. You can restore it within 28 days.
      </Dialog>
    </Frame>
  );
}

