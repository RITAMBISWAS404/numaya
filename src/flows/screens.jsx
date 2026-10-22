import { useEffect, useRef, useState } from "react";
import {
  ActionBar,
  ActionSheet,
  Avatar,
  Badge,
  Banner,
  Button,
  Card,
  ChipGroup,
  Composer,
  ConsequenceList,
  ConversationRow,
  Dialog,
  EmptyState,
  Fab,
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
  Icon,
  IconButton,
  ImagePlaceholder,
  VerifiedBadge,
  Wordmark,
} from "../design-system/index.js";
import { INTERESTS, PEOPLE, REPORT_REASONS } from "./data.js";
import { conversations, discoveryQueue, hiddenByFilters, newMatches, useStore } from "./store.js";

const TABS = [
  { id: "discover", label: "Discover", icon: "cards" },
  { id: "chats", label: "Chats", icon: "message" },
  { id: "profile", label: "Profile", icon: "user" },
];
const TAB_TARGET = { discover: "discovery", chats: "chats", profile: "profile" };
const ageOf = (year) => (year.length === 4 ? new Date().getFullYear() - Number(year) : null);

/** Shared screen scaffold inside a preview frame. */
function Frame({ top, footer, tab, go, children, tone, kind }) {
  return (
    <div className={`fl-screen${tone ? ` fl-screen--${tone}` : ""}${kind ? ` fl-screen--${kind}` : ""}`}>
      {top}
      <div className="fl-screen__body">{children}</div>
      {footer && <div className="fl-screen__footer">{footer}</div>}
      {tab && <TabBar items={TABS} current={tab} onChange={(id) => go(TAB_TARGET[id])} />}
    </div>
  );
}

/** Short-lived toast message. */
function useFlash() {
  const [msg, setMsg] = useState(null);
  useEffect(() => {
    if (!msg) return;
    const id = setTimeout(() => setMsg(null), 1400);
    return () => clearTimeout(id);
  }, [msg]);
  return [msg, setMsg];
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
  const [state, dispatch] = useStore();
  const { name, year, gender, looking } = state.profile;
  const set = (patch) => dispatch({ type: "profile", patch });
  const age = ageOf(year);
  const yearError = age !== null && age < 18 ? "You need to be 18 or older to use Numaya." : null;
  const valid = name.trim() && age !== null && age >= 18 && age <= 100;
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
        <TextField label="First name" value={name} onChange={(e) => set({ name: e.target.value })} autoComplete="given-name" />
        <TextField
          label="Year you were born"
          inputMode="numeric"
          maxLength={4}
          value={year}
          onChange={(e) => set({ year: e.target.value.replace(/\D/g, "") })}
          error={yearError}
          hint="We show your age, never your birthday."
        />
        <OptionCards
          legend="I’m a"
          value={gender}
          onChange={(v) => set({ gender: v })}
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
          onChange={(v) => set({ looking: v })}
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
  const [state, dispatch] = useStore();
  const { interests } = state.profile;
  return (
    <Frame
      top={<TopBar onBack={() => go("basics")} step={4} steps={6} />}
      footer={
        <>
          <span className="fl-caption">{interests.length < 3 ? `Pick ${3 - interests.length} more` : `${interests.length}/5 interests`}</span>
          <Fab disabled={interests.length < 3} onClick={() => go("photos")} />
        </>
      }
    >
      <ScreenHeader title="What are you into?" lede="Pick 3 to 5. They start conversations and help us find people like you." />
      <div className="fl-stack fl-gap-lg">
        <ChipGroup label="Interests" options={INTERESTS} value={interests} onChange={(v) => dispatch({ type: "profile", patch: { interests: v } })} max={5} />
        <Section title="Your prompt" description="Matches reply to this. More prompts arrive in a later step.">
          <PromptCard prompt="A perfect first date" answer="A record shop, a long walk, and nowhere to be after." />
        </Section>
      </div>
    </Frame>
  );
}

export function Photos({ go }) {
  const [state, dispatch] = useStore();
  const { photos } = state.profile;
  const setPhotos = (fn) => dispatch({ type: "profile", patch: { photos: fn(photos) } });
  const add = () => {
    if (photos.length >= 6) return;
    setPhotos((p) => [...p, { id: Date.now(), tone: p.length % 4 }]);
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
        <PhotoGrid photos={photos} onAdd={add} onRemove={(id) => setPhotos((p) => p.filter((x) => x.id !== id))} hint="Tap + to add a sample photo. The first photo is your main one." />
      </div>
    </Frame>
  );
}

/* 3 · Discovery ------------------------------------------------------------- */
const SWIPE_THRESHOLD = 96;

/** Horizontal drag on the card: past the threshold, right likes and left passes. Buttons remain the accessible path. */
function useSwipe(onDecide) {
  const start = useRef(null);
  const [dx, setDx] = useState(0);
  const handlers = {
    onPointerDown: (e) => {
      // Buttons inside the card (pass, like) keep their own clicks.
      if (e.button !== 0 || e.target.closest("button")) return;
      start.current = e.clientX;
      e.currentTarget.setPointerCapture?.(e.pointerId);
    },
    onPointerMove: (e) => {
      if (start.current !== null) setDx(e.clientX - start.current);
    },
    onPointerUp: () => {
      if (start.current === null) return;
      start.current = null;
      if (Math.abs(dx) >= SWIPE_THRESHOLD) onDecide(dx > 0);
      setDx(0);
    },
    onPointerCancel: () => {
      start.current = null;
      setDx(0);
    },
  };
  return { dx, handlers };
}

export function Discovery({ go }) {
  const [state, dispatch] = useStore();
  const [toast, flash] = useFlash();
  const queue = discoveryQueue(state);
  const hidden = hiddenByFilters(state);
  const id = queue[0];
  const person = id && PEOPLE[id];
  const { age, distance } = state.prefs;

  const decide = (liked) => {
    if (!person) return;
    dispatch({ type: "decide", id, liked });
    if (liked && person.likesYou) go("match");
    else flash(liked ? `You liked ${person.name}` : null);
  };
  const { dx, handlers } = useSwipe(decide);
  const snoozed = state.prefs.snooze;
  const intent = dx >= SWIPE_THRESHOLD / 2 ? "like" : dx <= -SWIPE_THRESHOLD / 2 ? "pass" : null;

  return (
    <Frame
      tone="page"
      kind="discover"
      top={
        <TopBar
          largeTitle="Discover"
          actions={
            !snoozed && (
              <Button
                variant="secondary"
                size="sm"
                block={false}
                icon="filter"
                className="fl-filter-btn"
                aria-label={`Filters: ages ${age[0]}–${age[1]}, within ${distance} km. Change`}
                onClick={() => go("settings")}
              >
                Ages {age[0]}–{age[1]} · {distance} km
              </Button>
            )
          }
        />
      }
      tab="discover"
      go={go}
    >
      {snoozed ? (
        <div className="fl-center fl-fill">
          <EmptyState icon="eyeOff" title="Discover is paused" action="Resume" onAction={() => dispatch({ type: "prefs", patch: { snooze: false } })}>
            You’re snoozed, so you won’t see new people and they won’t see you. Your matches and chats are still here.
          </EmptyState>
        </div>
      ) : (
      <>
      {person ? (
        <div className="fl-stack">
          <div
            className={`fl-swipe${dx ? " is-dragging" : ""}`}
            style={{ "--dx": `${dx}px`, "--rot": `${dx / 24}deg` }}
            {...handlers}
            aria-label={`${person.name}. Swipe right to like, left to pass, or use the Pass and Like buttons.`}
            role="group"
          >
            <ProfileCard
              key={id}
              {...person}
              details={[...person.details, { icon: "location", text: `${person.distanceKm} km away` }]}
              actions={<ActionBar onPass={() => decide(false)} onSuper={() => decide(true)} onLike={() => decide(true)} />}
            />
            {intent && <span className={`fl-swipe__stamp fl-swipe__stamp--${intent}`}>{intent === "like" ? "Like" : "Pass"}</span>}
          </div>
          <PromptCard prompt={person.prompt.q} answer={person.prompt.a} />
          <ListGroup footnote="Sample profiles. Distances are illustrative, not real locations.">
            {person.facts.map((f) => (
              <ListRow key={f.label} icon={f.icon} label={f.label} kind="info" value={f.value} />
            ))}
          </ListGroup>
        </div>
      ) : (
        <div className="fl-center fl-fill">
          {hidden > 0 ? (
            <EmptyState icon="filter" title="No one fits your filters" action="Widen age and distance" onAction={() => dispatch({ type: "broaden" })}>
              {hidden} {hidden === 1 ? "person is" : "people are"} just outside ages {age[0]}–{age[1]} or {distance} km.
            </EmptyState>
          ) : (
            <EmptyState title="You’ve seen everyone for now" action="Show them again" onAction={() => dispatch({ type: "resetDiscovery" })}>
              New people join every day. People you passed on can come back around.
            </EmptyState>
          )}
        </div>
      )}
      </>
      )}
      <Toast open={Boolean(toast)} placement="bottom" icon="heart">
        {toast}
      </Toast>
    </Frame>
  );
}

/* 4 · Matching -------------------------------------------------------------- */
export function Match({ go }) {
  const [state, dispatch] = useStore();
  const [text, setText] = useState("");
  const id = state.lastMatch;
  const person = id && PEOPLE[id];

  if (!person || state.ended[id]) {
    return (
      <Frame tone="page" top={<TopBar onBack={() => go("discovery")} />}>
        <div className="fl-center fl-fill">
          <EmptyState icon="heart" title="No new match yet" action="Go to Discover" onAction={() => go("discovery")}>
            Like someone who has already liked you and you’ll see it here.
          </EmptyState>
        </div>
      </Frame>
    );
  }

  const send = (value) => {
    const msgId = Date.now();
    dispatch({ type: "send", id, text: value, msgId });
    setTimeout(() => dispatch({ type: "delivered", id, msgId }), 700);
    setText("");
    go("chat");
  };

  return (
    <Frame
      tone="page"
      top={<TopBar onBack={() => go("discovery")} />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Composer value={text} onChange={setText} placeholder={person.opener ?? "Say hello…"} onSend={send} />
          <Button variant="quiet" onClick={() => go("discovery")}>
            Keep browsing
          </Button>
        </div>
      }
    >
      <div className="fl-center fl-fill">
        <MatchCelebration names={[state.profile.name || "You", person.name]} title="It’s a match">
          You and {person.name} liked each other. They answered “{person.prompt.q}”. Start there.
        </MatchCelebration>
      </div>
    </Frame>
  );
}

/* 5 · Messaging ------------------------------------------------------------- */
export function Chats({ go }) {
  const [state, dispatch] = useStore();
  const open = (id) => {
    dispatch({ type: "openChat", id });
    go("chat");
  };
  const fresh = newMatches(state).map((id) => ({ id, name: PEOPLE[id].name }));
  const rows = conversations(state);
  return (
    <Frame tone="page" top={<TopBar largeTitle="Chats" />} tab="chats" go={go}>
      <div className="fl-stack fl-gap-lg">
        {!state.prefs.messages && (
          <Banner tone="info" title="New message alerts are off" action="Turn on" onAction={() => dispatch({ type: "prefs", patch: { messages: true } })}>
            You’ll still see new messages here.
          </Banner>
        )}
        {fresh.length > 0 && (
          <section>
            <p className="fl-label">New matches</p>
            <MatchQueue matches={fresh} onSelect={open} />
          </section>
        )}
        <section>
          <p className="fl-label">Conversations</p>
          {rows.length ? (
            <ul className="fl-list fl-inbox">
              {rows.map((c) => (
                <ConversationRow key={c.id} {...c} onPress={() => open(c.id)} />
              ))}
            </ul>
          ) : (
            <p className="fl-caption">No conversations yet.</p>
          )}
        </section>
      </div>
    </Frame>
  );
}

export function Chat({ go }) {
  const [state, dispatch] = useStore();
  const id = state.activeChat;
  const person = PEOPLE[id];
  const messages = state.threads[id] ?? [];
  const ended = state.ended[id];
  const [text, setText] = useState("");
  const [menu, setMenu] = useState(false);
  const [report, setReport] = useState(false);
  const [confirm, setConfirm] = useState(false);
  const [reason, setReason] = useState(null);

  const send = (value) => {
    const msgId = Date.now();
    dispatch({ type: "send", id, text: value, msgId });
    setText("");
    setTimeout(() => dispatch({ type: "delivered", id, msgId }), 700);
  };

  if (ended) {
    return (
      <Frame tone="page" top={<TopBar onBack={() => go("chats")} />}>
        <div className="fl-center fl-fill">
          <ResultPanel
            title={ended === "blocked" ? `You’ve blocked and reported ${person.name}` : `You’ve unmatched ${person.name}`}
            footer={<Button onClick={() => go("chats")}>Back to chats</Button>}
          >
            <p>
              {ended === "blocked"
                ? `${reason ? `Reason: ${reason}. ` : ""}${person.name} won’t be told. You won’t see each other again, and we’ll follow up in Help.`
                : `The conversation is closed for both of you and ${person.name} won’t appear in Discover.`}
            </p>
          </ResultPanel>
        </div>
      </Frame>
    );
  }

  return (
    <Frame
      tone="page"
      top={
        <header className="fl-chat-head">
          <IconButton icon="chevronLeft" label="Back to chats" variant="plain" onClick={() => go("chats")} />
          <Avatar name={person.name} size="sm" decorative />
          <span className="fl-chat-head__name">
            {person.name}
            {person.verified && <VerifiedBadge compact />}
          </span>
          <IconButton icon="more" label="Conversation options" variant="plain" onClick={() => setMenu(true)} />
        </header>
      }
      footer={<Composer value={text} onChange={setText} onSend={send} placeholder={`Message ${person.name}`} />}
    >
      <div className="fl-messages">
        <SystemMessage>You matched with {person.name}</SystemMessage>
        {messages.map((m, i) => (
          <MessageBubble
            key={m.id}
            from={m.from}
            status={m.from === "me" && i === messages.length - 1 ? m.status : undefined}
            grouped={i > 0 && messages[i - 1].from === m.from}
          >
            {m.text}
          </MessageBubble>
        ))}
      </div>

      <ActionSheet
        open={menu}
        onClose={() => setMenu(false)}
        actions={[
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
            <ListRow
              key={label}
              icon={icon}
              label={label}
              onPress={() => {
                setReport(false);
                setReason(label);
                dispatch({ type: "end", id, reason: "blocked" });
              }}
            />
          ))}
        </ListGroup>
      </Sheet>
      <Dialog
        open={confirm}
        onClose={() => setConfirm(false)}
        title={`Unmatch ${person.name}?`}
        tone="destructive"
        confirmLabel="Unmatch"
        onConfirm={() => {
          setConfirm(false);
          dispatch({ type: "end", id, reason: "unmatched" });
        }}
      >
        <ConsequenceList
          items={[
            { icon: "eyeOff", text: "You won’t see each other again" },
            { icon: "message", text: "This conversation will be closed" },
          ]}
        />
      </Dialog>
    </Frame>
  );
}

/* 6 · Profile and settings -------------------------------------------------- */
export function MyProfile({ go }) {
  const [state] = useStore();
  const { name, year, interests, photos } = state.profile;
  const age = ageOf(year);
  const completion = Math.min(1, 0.4 + Math.min(photos.length, 4) * 0.1 + Math.min(interests.length, 5) * 0.04);
  return (
    <Frame
      tone="page"
      top={<TopBar largeTitle="Profile" actions={<IconButton icon="settings" label="Settings" variant="plain" onClick={() => go("settings")} />} />}
      tab="profile"
      go={go}
    >
      <div className="fl-stack fl-gap-lg">
        <div className="fl-me-card">
          <div className="fl-me">
            <Avatar name={name || "You"} size="xl" ring={{ value: completion }} />
            <div>
              <p className="fl-me__name">
                {name || "You"}
                {age ? `, ${age}` : ""}
              </p>
              <span className="fl-badges">
                <Badge tone="neutral">Profile {Math.round(completion * 100)}% complete</Badge>
                {state.prefs.snooze && (
                  <Badge tone="warning" icon="eyeOff">
                    Snoozed
                  </Badge>
                )}
              </span>
            </div>
          </div>
          <Button variant="secondary" icon="user" onClick={() => go("basics")}>
            Edit profile
          </Button>
        </div>
        <Card>
          <Section
            title="Photos"
            description={`${photos.length} of 6 added`}
            action={
              <button type="button" className="text-button" aria-label="Edit photos" onClick={() => go("photos")}>
                Edit
              </button>
            }
          >
            <div className="fl-photo-strip">
              {Array.from({ length: 4 }, (_, i) =>
                photos[i] ? (
                  <ImagePlaceholder key={photos[i].id} tone={photos[i].tone} ratio="3 / 4" label={`Photo ${i + 1}`} />
                ) : (
                  <span key={`empty-${i}`} className="fl-photo-strip__empty" aria-hidden="true">
                    <Icon name="plus" size={18} />
                  </span>
                ),
              )}
            </div>
          </Section>
        </Card>
        <PromptCard prompt="A perfect first date" answer="A record shop, a long walk, and nowhere to be after." />
        <Card>
          <Section
            title="Interests"
            action={
              <button type="button" className="text-button" aria-label="Edit interests" onClick={() => go("interests")}>
                Edit
              </button>
            }
          >
            <div className="fl-chip-row">
              {interests.length ? (
                interests.map((i) => (
                  <span key={i} className="chip chip--static">
                    {i}
                  </span>
                ))
              ) : (
                <p className="fl-caption">Pick a few so people have something to ask about.</p>
              )}
            </div>
          </Section>
        </Card>
        <ListGroup title="Trust">
          <ListRow icon="shield" label="Verification" kind="info" value="Phone verified" />
        </ListGroup>
      </div>
    </Frame>
  );
}

const FEEDBACK = {
  snooze: ["Snoozed. Discover is paused.", "Welcome back. Discover is on."],
  messages: ["New message alerts on", "New message alerts off"],
  likes: ["New like alerts on", "New like alerts off"],
};
const DESCRIBE = {
  snooze: (on) => (on ? "You’re hidden. Resume any time." : "Take a break without losing matches"),
  messages: (on) => (on ? "On" : "Off: you’ll still see them in Chats"),
  likes: (on) => (on ? "On" : "Off"),
};

export function Settings({ go }) {
  const [state, dispatch] = useStore();
  const { prefs } = state;
  const setPrefs = (patch) => dispatch({ type: "prefs", patch });
  const [pending, setPending] = useState(null);
  const [deleting, setDeleting] = useState(false);
  const [toast, flash] = useFlash();
  const blocked = Object.values(state.ended).filter((r) => r === "blocked").length;
  const toggle = (key, value) => {
    setPending(key);
    setTimeout(() => {
      setPrefs({ [key]: value });
      setPending(null);
      flash(FEEDBACK[key][value ? 0 : 1]);
    }, 700);
  };
  const switchRow = (k, label) => (
    <li className="list-row" key={k}>
      <div className="list-row__hit">
        <Switch label={label} description={DESCRIBE[k](prefs[k])} checked={prefs[k]} pending={pending === k} onChange={(v) => toggle(k, v)} />
      </div>
    </li>
  );
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("profile")} title="Settings" />}>
      <div className="fl-stack fl-gap-lg">
        <ListGroup title="Who you see">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <RangeSlider label="Age" min={18} max={70} value={prefs.age} onChange={(v) => setPrefs({ age: v })} />
            </div>
          </li>
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <Slider label="Distance" min={1} max={100} value={prefs.distance} onChange={(v) => setPrefs({ distance: v })} format={(v) => `${v} km`} />
            </div>
          </li>
        </ListGroup>
        <ListGroup title="Visibility" footnote="Snooze hides your profile and pauses Discover. Matches and chats stay.">
          {switchRow("snooze", "Snooze")}
        </ListGroup>
        <ListGroup title="Notifications" footnote="In this preview, alerts are simulated. Your browser is never asked for permission.">
          {switchRow("messages", "New messages")}
          {switchRow("likes", "New likes")}
        </ListGroup>
        <ListGroup title="Privacy and safety" footnote="Blocking and reporting happen from a conversation’s options menu.">
          <ListRow icon="shield" label="Blocked people" kind="info" value={String(blocked)} />
        </ListGroup>
        <ListGroup>
          <ListRow label="Log out" kind="action" onPress={() => go("intro")} />
        </ListGroup>
        <ListGroup footnote="Deleting removes your profile, matches and messages.">
          <ListRow label="Delete account" kind="destructive" onPress={() => setDeleting(true)} />
        </ListGroup>
      </div>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
      <Dialog
        open={deleting}
        onClose={() => setDeleting(false)}
        title="Delete your account?"
        tone="destructive"
        confirmLabel="Delete account"
        onConfirm={() => {
          setDeleting(false);
          dispatch({ type: "reset" });
          go("intro");
        }}
      >
        Your profile, matches and messages will be removed. In this preview, saved data is cleared and the demo restarts.
      </Dialog>
    </Frame>
  );
}
