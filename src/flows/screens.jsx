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
  IllustrationPlaceholder,
  ImagePlaceholder,
  VerifiedBadge,
  Wordmark,
} from "../design-system/index.js";
import { INTERESTS, PEOPLE, REPORT_REASONS } from "./data.js";
import { conversations, discoveryQueue, hiddenByFilters, newMatches, useStore } from "./store.js";

// Order follows the reference tab bar: Profile first, then browsing, then chats.
const TABS = [
  { id: "profile", label: "Profile", icon: "user" },
  { id: "discover", label: "Discover", icon: "cards" },
  { id: "chats", label: "Chats", icon: "message" },
];
const TAB_TARGET = { discover: "discovery", chats: "chats", profile: "profile" };
const ageOf = (year) => (year.length === 4 ? new Date().getFullYear() - Number(year) : null);

/** Shared screen scaffold inside a preview frame. */
function Frame({ top, footer, tab, go, children, tone, kind, onBodyScroll, bodyRef }) {
  return (
    <div className={`fl-screen${tone ? ` fl-screen--${tone}` : ""}${kind ? ` fl-screen--${kind}` : ""}`}>
      {top}
      <div className="fl-screen__body" onScroll={onBodyScroll} ref={bodyRef}>
        {children}
      </div>
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
      tone="page"
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
      <ScreenHeader title="Let’s start with the basics" art={<IllustrationPlaceholder id="basics-spot" ratio="1 / 1" width="72px" size="sm" />} />
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
      <ScreenHeader
        title="What are you into?"
        lede="Pick 3 to 5. They start conversations and help us find people like you."
        art={<IllustrationPlaceholder id="interests-spot" ratio="1 / 1" width="72px" size="sm" />}
      />
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

/** Discover header (reference: centred wordmark, filter icon right, scroll-progress track below). */
function DiscoverHeader({ age, distance, progress, onFilters, showFilters }) {
  return (
    <header className="fl-disc-head">
      <div className="fl-disc-head__bar">
        <span className="fl-disc-head__side" aria-hidden="true" />
        <h1 className="fl-disc-head__title">
          <Wordmark size="sm" />
          <span className="visually-hidden">Discover</span>
        </h1>
        <span className="fl-disc-head__side fl-disc-head__side--end">
          {showFilters && (
            <IconButton icon="filter" variant="floating" size="sm" label={`Filters: Ages ${age[0]}–${age[1]}, within ${distance} km. Change`} onClick={onFilters} />
          )}
        </span>
      </div>
      <div className="fl-disc-head__progress" aria-hidden="true">
        <span style={{ "--p": progress }} />
      </div>
    </header>
  );
}

export function Discovery({ go }) {
  const [state, dispatch] = useStore();
  const [toast, flash] = useFlash();
  const [progress, setProgress] = useState(0);
  const bodyRef = useRef(null);
  const queue = discoveryQueue(state);
  const hidden = hiddenByFilters(state);
  const id = queue[0];
  const person = id && PEOPLE[id];
  const { age, distance } = state.prefs;
  // No licensed photography is bundled yet: every photo slot is a neutral grey placeholder.
  const photoCount = person?.photoCount ?? 0;

  const decide = (liked) => {
    if (!person) return;
    dispatch({ type: "decide", id, liked });
    if (liked && person.likesYou) go("match");
    else flash(liked ? `You liked ${person.name}` : null);
  };
  const { dx, handlers } = useSwipe(decide);
  const snoozed = state.prefs.snooze;
  // Pass and Like sit at the end of the profile: the next person starts at their photo, not mid-scroll.
  useEffect(() => {
    bodyRef.current?.scrollTo({ top: 0 });
    setProgress(0);
  }, [id]);
  const intent = dx >= SWIPE_THRESHOLD / 2 ? "like" : dx <= -SWIPE_THRESHOLD / 2 ? "pass" : null;
  const onScroll = (e) => {
    const el = e.currentTarget;
    const max = el.scrollHeight - el.clientHeight;
    setProgress(max > 0 ? el.scrollTop / max : 0);
  };
  const photo = (i) =>
    i < photoCount && <ImagePlaceholder key={`p${i}`} tone={0} ratio="4 / 5" className="fl-pf__photo" label={`${person.name}, photo ${i + 1} (placeholder)`} />;
  const [lookingFor, livesIn, ...otherFacts] = person?.facts ?? [];

  return (
    <Frame
      tone="page"
      kind="discover"
      top={<DiscoverHeader age={age} distance={distance} progress={progress} showFilters={!snoozed} onFilters={() => go("settings")} />}
      tab="discover"
      go={go}
      onBodyScroll={onScroll}
      bodyRef={bodyRef}
    >
      {snoozed ? (
        <div className="fl-center fl-fill">
          <EmptyState art="discover-paused" title="Discover is paused" action="Resume" onAction={() => dispatch({ type: "prefs", patch: { snooze: false } })}>
            You’re snoozed, so you won’t see new people and they won’t see you. Your matches and chats are still here.
          </EmptyState>
        </div>
      ) : person ? (
        <div className="fl-pf" key={id}>
          <div
            className={`fl-swipe${dx ? " is-dragging" : ""}`}
            style={{ "--dx": `${dx}px`, "--rot": `${dx / 24}deg` }}
            {...handlers}
            aria-label={`${person.name}. Swipe right to like, left to pass, or use the buttons at the end of the profile.`}
            role="group"
          >
            <ProfileCard
              {...person}
              actions={
                <button type="button" className="action-bar__btn action-bar__btn--super" aria-label="SuperSwipe" onClick={() => decide(true)}>
                  <Icon name="star" size={26} weight="fill" />
                </button>
              }
            />
            {intent && <span className={`fl-swipe__stamp fl-swipe__stamp--${intent}`}>{intent === "like" ? "Like" : "Pass"}</span>}
          </div>

          <section className="card fl-pf__section">
            <h2 className="fl-pf__title">{person.prompt.q}</h2>
            <p className="fl-pf__body">{person.prompt.a}</p>
          </section>

          {lookingFor && (
            <section className="card fl-pf__section">
              <h2 className="fl-pf__title">About me</h2>
              <div className="fl-chip-row">
                {[lookingFor, ...otherFacts].map((f) => (
                  <span key={f.label} className="chip chip--static" title={f.label}>
                    <Icon name={f.icon} size={16} /> {f.value}
                  </span>
                ))}
              </div>
            </section>
          )}

          {photo(1)}

          {person.shared?.length > 0 && (
            <section className="card fl-pf__section fl-pf__section--tint">
              <h2 className="fl-pf__title">You both like</h2>
              <div className="fl-chip-row">
                {person.shared.map((s) => (
                  <span key={s} className="chip chip--static chip--shared">
                    {s}
                  </span>
                ))}
              </div>
            </section>
          )}

          {photo(2)}

          <section className="card fl-pf__section">
            <h2 className="fl-pf__title">My location</h2>
            <p className="fl-pf__meta">
              <Icon name="location" size={20} /> ~{person.distanceKm} km away
            </p>
            {livesIn && (
              <div className="fl-chip-row">
                <span className="chip chip--static">
                  {livesIn.label} {livesIn.value}
                </span>
              </div>
            )}
          </section>

          {Array.from({ length: Math.max(0, photoCount - 3) }, (_, i) => photo(i + 3))}

          <ActionBar onPass={() => decide(false)} onSuper={() => decide(true)} onLike={() => decide(true)} />
          <p className="fl-caption fl-center">Sample profiles. Photos are placeholders; distances are illustrative.</p>
        </div>
      ) : (
        <div className="fl-center fl-fill">
          {hidden > 0 ? (
            <EmptyState icon="filter" title="No one fits your filters" action="Widen age and distance" onAction={() => dispatch({ type: "broaden" })}>
              {hidden} {hidden === 1 ? "person is" : "people are"} just outside ages {age[0]}–{age[1]} or {distance} km.
            </EmptyState>
          ) : (
            <EmptyState art="discover-seen-everyone" title="You’ve seen everyone for now" action="Show them again" onAction={() => dispatch({ type: "resetDiscovery" })}>
              New people join every day. People you passed on can come back around.
            </EmptyState>
          )}
        </div>
      )}
      <Toast open={Boolean(toast)} placement="bottom" icon="heart">
        {toast}
      </Toast>
    </Frame>
  );
}

/* 4 · Matching -------------------------------------------------------------- */
/** Close-only header (Bumble match screen: X top-left). */
function CloseHeader({ onClose, label = "Close" }) {
  return (
    <header className="fl-close-head">
      <IconButton icon="close" label={label} variant="floating" onClick={onClose} />
    </header>
  );
}

export function Match({ go }) {
  const [state, dispatch] = useStore();
  const [text, setText] = useState("");
  const id = state.lastMatch;
  const person = id && PEOPLE[id];

  if (!person || state.ended[id]) {
    return (
      <Frame tone="page" top={<CloseHeader label="Back to Discover" onClose={() => go("discovery")} />}>
        <div className="fl-center fl-fill">
          <EmptyState art="match-empty" title="No new match yet" action="Go to Discover" onAction={() => go("discovery")}>
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
      top={<CloseHeader label="Back to Discover" onClose={() => go("discovery")} />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Composer value={text} onChange={setText} placeholder={person.opener ?? "Send a message…"} onSend={send} />
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
          <section className="fl-stack">
            <h2 className="fl-section-title">
              Your matches <span className="fl-section-title__count">({fresh.length})</span>
            </h2>
            <MatchQueue matches={fresh} onSelect={open} />
          </section>
        )}
        {rows.length ? (
          <section className="fl-stack">
            <h2 className="fl-section-title">Chats</h2>
            <ul className="fl-list">
              {rows.map((c) => (
                <ConversationRow key={c.id} {...c} onPress={() => open(c.id)} />
              ))}
            </ul>
          </section>
        ) : (
          <EmptyState art="chats-empty" title="Connections start here" action="Find your people" onAction={() => go("discovery")}>
            When you like each other, you’ll match. Here’s where you can chat.
          </EmptyState>
        )}
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
            tone="neutral"
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
          <IconButton icon="chevronLeft" label="Back to chats" variant="floating" size="sm" onClick={() => go("chats")} />
          <Avatar name={person.name} size="sm" decorative />
          <span className="fl-chat-head__name">
            {person.name}
            {person.verified && <VerifiedBadge compact />}
          </span>
          <IconButton icon="more" label="Conversation options" variant="floating" size="sm" onClick={() => setMenu(true)} />
        </header>
      }
      footer={<Composer value={text} onChange={setText} onSend={send} placeholder={`Message ${person.name}`} />}
    >
      {messages.length === 0 ? (
        /* Bumble new-match conversation: the person is centred until the first message. */
        <div className="fl-chat-intro">
          <Avatar name={person.name} size="xl" verified={person.verified} />
          <p className="fl-chat-intro__name">
            {person.name}, {person.age}
          </p>
          <p className="fl-caption">You matched. Say hello and make it personal.</p>
        </div>
      ) : (
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
      )}

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
        <ListGroup plain>
          {REPORT_REASONS.map(([, label]) => (
            <ListRow
              key={label}
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
      {/* Unmatch confirmation as a bottom sheet (Bumble "Unmatch {name}"). */}
      <Sheet open={confirm} onClose={() => setConfirm(false)} labelledBy="fl-unmatch-title">
        <div className="sheet__header">
          <h2 id="fl-unmatch-title" className="sheet__title">
            Unmatch {person.name}?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setConfirm(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <ConsequenceList
            items={[
              { icon: "eyeOff", text: "You won’t see each other again" },
              { icon: "message", text: "This conversation will be closed" },
            ]}
          />
          <button
            type="button"
            className="fl-sheet-note"
            onClick={() => {
              setConfirm(false);
              setReport(true);
            }}
          >
            <Icon name="flag" size={20} />
            <span>
              <strong>Think they’ve broken our guidelines?</strong>
              <span>Report them instead. Reporting also blocks them.</span>
            </span>
          </button>
          <Button
            onClick={() => {
              setConfirm(false);
              dispatch({ type: "end", id, reason: "unmatched" });
            }}
          >
            Unmatch
          </Button>
        </div>
      </Sheet>
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
      top={<TopBar largeTitle="Profile" actions={<IconButton icon="settings" label="Settings" variant="floating" size="sm" onClick={() => go("settings")} />} />}
      tab="profile"
      go={go}
    >
      <div className="fl-stack fl-gap-lg">
        {/* Bumble profile tab: avatar with completion ring and % pill, name, edit action. */}
        <div className="fl-me">
          <div className="fl-me__avatar">
            <Avatar name={name || "You"} size="xl" ring={{ value: completion }} />
            <span className="fl-me__pct" aria-label={`Profile ${Math.round(completion * 100)}% complete`}>
              {Math.round(completion * 100)}%
            </span>
          </div>
          <div className="fl-me__text">
            <p className="fl-me__name">
              {name || "You"}
              {age ? `, ${age}` : ""}
            </p>
            <div className="fl-badges">
              <Button variant="secondary" size="sm" block={false} icon="user" onClick={() => go("basics")}>
                Edit profile
              </Button>
              {state.prefs.snooze && (
                <Badge tone="warning" icon="eyeOff">
                  Snoozed
                </Badge>
              )}
            </div>
          </div>
        </div>

        {/* Bumble edit profile: section title, grey helper, then the content to edit. */}
        <Section
          title="Photos"
          description={`${photos.length} of 6 added. Pick some that show the true you.`}
          action={
            <button type="button" className="text-button" aria-label="Edit photos" onClick={() => go("photos")}>
              Edit
            </button>
          }
        >
          <div className="fl-photo-strip">
            {Array.from({ length: 4 }, (_, i) =>
              photos[i] ? (
                <ImagePlaceholder key={photos[i].id} ratio="3 / 4" className="fl-photo-strip__photo" label={`Photo ${i + 1} (placeholder)`} />
              ) : (
                <button key={`empty-${i}`} type="button" className="fl-photo-strip__empty" aria-label={`Add photo ${i + 1}`} onClick={() => go("photos")}>
                  <Icon name="plus" size={20} />
                </button>
              ),
            )}
          </div>
        </Section>

        <Section title="Prompts" description="Let people know what it’s like to date you.">
          <PromptCard prompt="A perfect first date" answer="A record shop, a long walk, and nowhere to be after." onEdit={() => go("interests")} />
        </Section>

        <Section title="Interests" description="Get specific about the things you love.">
          <button type="button" className="card fl-edit-card" aria-label={`Edit interests: ${interests.join(", ") || "none yet"}`} onClick={() => go("interests")}>
            <span className="fl-chip-row">
              {interests.length ? (
                interests.map((i) => (
                  <span key={i} className="chip chip--static">
                    {i}
                  </span>
                ))
              ) : (
                <span className="fl-caption">Pick a few so people have something to ask about.</span>
              )}
            </span>
            <Icon name="chevronRight" size={20} className="fl-edit-card__chevron" />
          </button>
        </Section>

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
        {/* Filters (reference: Bumble filters): a question heading over each white card. */}
        <ListGroup title="How old are they?">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <RangeSlider label="Age" min={18} max={70} value={prefs.age} onChange={(v) => setPrefs({ age: v })} />
            </div>
          </li>
        </ListGroup>
        <ListGroup title="How far away are they?">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <Slider label="Distance" min={1} max={100} value={prefs.distance} onChange={(v) => setPrefs({ distance: v })} format={(v) => `Up to ${v} km`} />
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
      {/* Destructive confirmation as a bottom sheet, like Unmatch (Bumble); Cancel takes focus first. */}
      <Sheet open={deleting} onClose={() => setDeleting(false)} labelledBy="fl-delete-title">
        <div className="sheet__header">
          <h2 id="fl-delete-title" className="sheet__title">
            Delete your account?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setDeleting(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <p className="fl-sheet-text">Your profile, matches and messages will be removed. In this preview, saved data is cleared and the demo restarts.</p>
          <Button
            variant="destructive-solid"
            onClick={() => {
              setDeleting(false);
              dispatch({ type: "reset" });
              go("intro");
            }}
          >
            Delete account
          </Button>
          <Button variant="quiet" data-autofocus onClick={() => setDeleting(false)}>
            Cancel
          </Button>
        </div>
      </Sheet>
    </Frame>
  );
}
