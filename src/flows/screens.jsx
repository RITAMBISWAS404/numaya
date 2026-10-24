import { useEffect, useRef, useState } from "react";
import {
  ActionBar,
  ActionSheet,
  Avatar,
  Badge,
  Banner,
  Button,
  Card,
  Chip,
  ChipGroup,
  Composer,
  ConsequenceList,
  ConversationRow,
  Dialog,
  EmptyState,
  Fab,
  FilterChips,
  Icon,
  IconButton,
  Illustration,
  IllustrationSlot,
  ImagePlaceholder,
  InfoCard,
  SetupProgress,
  SharedInterests,
  ListGroup,
  ListRow,
  MatchCelebration,
  MatchQueue,
  MessageBubble,
  OptionCards,
  PhotoGrid,
  ProfileCard,
  ProfilePrompt,
  ProfileSection,
  PromptCard,
  ReadinessMeter,
  RangeSlider,
  ResultPanel,
  ScreenHeader,
  SearchField,
  Section,
  SegmentedControl,
  Sheet,
  Slider,
  Switch,
  SystemMessage,
  TabBar,
  TextArea,
  TextField,
  Toast,
  TopBar,
  VerifiedBadge,
  Wordmark,
} from "../design-system/index.js";
import { INTEREST_GROUPS, INTERESTS, PEOPLE, PROMPT_QUESTIONS, REPORT_REASONS } from "./data.js";
import { conversations, discoveryQueue, hiddenByFilters, newMatches, useStore } from "./store.js";
import { Frame, useFlash } from "./frame.jsx";
import { ReportSheet, ShareSheet } from "./activity.jsx";
import { myActivities, openersFor, readiness } from "./model.js";
import { accountStatus, useFixAction } from "./account.jsx";

const ageOf = (year) => (year.length === 4 ? new Date().getFullYear() - Number(year) : null);

/* 1 · Onboarding → profile setup -------------------------------------------- */
/* Profile setup steps, in order. A step is done once its next button has been pressed; the first
   step not done is the current one. */
const SETUP_STEPS = [
  { id: "basics", label: "The basics", detail: "Name, age and who you’d like to meet", icon: "user", screen: "basics" },
  { id: "interests", label: "Interests and prompt", detail: "Three interests and one answer", icon: "interests", screen: "interests" },
  { id: "photos", label: "Photos", detail: "At least two, ideally four", icon: "camera", screen: "photos" },
];

export function SetupIntro({ go }) {
  const [state] = useStore();
  const done = state.setupDone ?? [];
  const next = SETUP_STEPS.find((s) => !done.includes(s.id));
  const steps = SETUP_STEPS.map((s) => ({ ...s, status: done.includes(s.id) ? "done" : s === next ? "active" : "upcoming" }));
  return (
    <Frame
      tone="page"
      footer={
        <div className="fl-stack fl-stack--full">
          <Button onClick={() => go(next ? next.screen : "discovery")}>{!done.length ? "Build my profile" : next ? "Continue my profile" : "Go to Home"}</Button>
          <p className="fl-caption fl-center">{next ? "About two minutes. You can finish later." : "Your profile is ready."}</p>
        </div>
      }
    >
      <div className="fl-center fl-intro">
        <Wordmark />
        <ResultPanel art="verification-success" compact title="You’re verified">
          <p>+1 (415) 555-0132 is confirmed. Now let’s make a profile people actually want to reply to.</p>
        </ResultPanel>
        <SetupProgress title="Your profile" steps={steps} />
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
          <Fab disabled={!valid} onClick={() => { dispatch({ type: "setupDone", step: "basics" }); go("interests"); }} />
        </>
      }
    >
      <ScreenHeader title="Let’s start with the basics" art={<IllustrationSlot id="spot-basics" width="72px" />} />
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
          <Fab disabled={interests.length < 3} onClick={() => { dispatch({ type: "setupDone", step: "interests" }); go("photos"); }} />
        </>
      }
    >
      <ScreenHeader
        title="What are you into?"
        lede="Pick 3 to 5. They start conversations and help us find people like you."
        art={<IllustrationSlot id="spot-interests" width="72px" />}
      />
      <div className="fl-stack fl-gap-lg fl-sections">
        <ChipGroup label="Interests" options={INTERESTS} groups={INTEREST_GROUPS} value={interests} onChange={(v) => dispatch({ type: "profile", patch: { interests: v } })} max={5} />
        <Section title="Your prompt" description="Matches reply to this. You can change it any time from your profile.">
          <PromptCard prompt={state.profile.prompt.q} answer={state.profile.prompt.a} />
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
          <Fab disabled={photos.length < 2} onClick={() => { dispatch({ type: "setupDone", step: "photos" }); go("discovery"); }} />
        </>
      }
    >
      <ScreenHeader title="Add your photos" lede="At least 2, ideally 4. Clear, recent, and just you in the first one." />
      <div className="fl-gap-lg">
        <div className="fl-stack fl-gap-lg">
          <PhotoGrid photos={photos} onAdd={add} onRemove={(id) => setPhotos((p) => p.filter((x) => x.id !== id))} hint={null} />
          <InfoCard icon="camera" title="Your first photo leads your profile">
            Tap + to add a sample photo. You can choose a different main photo later in Edit profile.
          </InfoCard>
        </div>
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
function DiscoverHeader({ age, distance, progress, onFilters, showFilters, onUndo, undoName, onMore }) {
  return (
    <header className="fl-disc-head">
      <div className="fl-disc-head__bar">
        <span className="fl-disc-head__side">
          {onUndo && <IconButton icon="undo" variant="floating" size="sm" label={`Undo: bring back ${undoName}`} onClick={onUndo} />}
        </span>
        <h1 className="fl-disc-head__title">
          <Wordmark size="sm" />
          <span className="visually-hidden">Home</span>
        </h1>
        <span className="fl-disc-head__side fl-disc-head__side--end">
          {showFilters && (
            <IconButton icon="filter" variant="floating" size="sm" label={`Filters: Ages ${age[0]}–${age[1]}, within ${distance} km. Change`} onClick={onFilters} />
          )}
          {onMore && <IconButton icon="more" variant="floating" size="sm" label="Profile options" onClick={onMore} />}
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
  const [filtering, setFiltering] = useState(false);
  const [options, setOptions] = useState(false);
  const [sharing, setSharing] = useState(false);
  const [reporting, setReporting] = useState(false);
  const [blocking, setBlocking] = useState(false);
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
      top={
        <DiscoverHeader
          age={age}
          distance={distance}
          progress={progress}
          showFilters={!snoozed}
          onFilters={() => setFiltering(true)}
          onUndo={!snoozed && state.lastPass ? () => dispatch({ type: "undo" }) : null}
          undoName={state.lastPass && PEOPLE[state.lastPass]?.name}
          onMore={!snoozed && person ? () => setOptions(true) : null}
        />
      }
      tab="home"
      go={go}
      onBodyScroll={onScroll}
      bodyRef={bodyRef}
    >
      {snoozed ? (
        <div className="fl-center fl-fill">
          <EmptyState art="home-paused" title="Home is paused" action="Resume" onAction={() => dispatch({ type: "prefs", patch: { snooze: false } })}>
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
                  <Icon name="star" size={22} />
                </button>
              }
            />
            {intent && <span className={`fl-swipe__stamp fl-swipe__stamp--${intent}`}>{intent === "like" ? "Like" : "Pass"}</span>}
          </div>

          <ProfilePrompt prompt={person.prompt.q} answer={person.prompt.a} />

          {lookingFor && (
            <ProfileSection title="About me">
              <div className="fl-chip-row">
                {[lookingFor, ...otherFacts].map((f) => (
                  <span key={f.label} className="chip chip--static" title={f.label}>
                    <Icon name={f.icon} size={16} className="chip__icon" /> {f.value}
                  </span>
                ))}
              </div>
            </ProfileSection>
          )}

          {photo(1)}

          <SharedInterests items={person.shared?.map((label) => ({ label }))} />

          {photo(2)}

          <ProfileSection title="My location">
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
          </ProfileSection>

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
            <EmptyState art="home-caught-up" title="You’ve seen everyone for now" action="Show them again" onAction={() => dispatch({ type: "resetDiscovery" })}>
              New people join every day. People you passed on can come back around.
            </EmptyState>
          )}
        </div>
      )}
      <Toast open={Boolean(toast)} placement="bottom" icon="heart">
        {toast}
      </Toast>
      <FiltersSheet open={filtering} onClose={() => setFiltering(false)} />
      {person && (
        <>
          <ActionSheet
            open={options}
            onClose={() => setOptions(false)}
            actions={[
              { label: `Share ${person.name}’s profile`, icon: "share", onSelect: () => { setOptions(false); setSharing(true); } },
              { label: "Report", icon: "flag", tone: "destructive", onSelect: () => { setOptions(false); setReporting(true); } },
              { label: `Block ${person.name}`, icon: "block", tone: "destructive", onSelect: () => { setOptions(false); setBlocking(true); } },
            ]}
          />
          <ShareSheet open={sharing} onClose={() => setSharing(false)} title={`${person.name}’s profile`} />
          <ReportSheet
            open={reporting}
            subject={person.name}
            reasons={REPORT_REASONS.map(([, label]) => label)}
            blockOption={person.name}
            onClose={() => setReporting(false)}
            onSubmit={({ reason, details, block }) => dispatch({ type: "report", target: "person", targetId: id, reason, details, block, at: new Date(2026, 9, 23, 12).toISOString() })}
          />
          <Dialog
            open={blocking}
            onClose={() => setBlocking(false)}
            title={`Block ${person.name}?`}
            confirmLabel="Block"
            tone="destructive"
            onConfirm={() => {
              setBlocking(false);
              dispatch({ type: "end", id, reason: "blocked" });
              flash(`${person.name} is blocked`);
            }}
          >
            They won’t see you, can’t message you, and aren’t told. Unblock any time in Settings › Blocked people.
          </Dialog>
        </>
      )}
    </Frame>
  );
}

/**
 * Discover filters (reference: Bumble filters, opened from the Discover header): question headings
 * over white cards, ink sliders, and an Apply pill that shows how many people the draft would let
 * through. Settings edits the same preferences.
 */
function FiltersSheet({ open, onClose }) {
  const [state, dispatch] = useStore();
  const [draft, setDraft] = useState(state.prefs);
  useEffect(() => {
    if (open) setDraft(state.prefs);
  }, [open]); // eslint-disable-line react-hooks/exhaustive-deps
  const count = discoveryQueue({ ...state, prefs: draft }).length;
  return (
    <Sheet open={open} onClose={onClose} labelledBy="fl-filters-title">
      <div className="sheet__header">
        <h2 id="fl-filters-title" className="sheet__title">
          Filters
        </h2>
        <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={onClose} />
      </div>
      <div className="fl-stack fl-sheet-body">
        <ListGroup title="How old are they?">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <RangeSlider label="Age" min={18} max={70} value={draft.age} onChange={(v) => setDraft((d) => ({ ...d, age: v }))} />
            </div>
          </li>
        </ListGroup>
        <ListGroup title="How far away are they?">
          <li className="list-row">
            <div className="list-row__hit fl-slider-row">
              <Slider label="Distance" min={1} max={100} value={draft.distance} onChange={(v) => setDraft((d) => ({ ...d, distance: v }))} format={(v) => `Up to ${v} km`} />
            </div>
          </li>
        </ListGroup>
        <Button
          onClick={() => {
            dispatch({ type: "prefs", patch: { age: draft.age, distance: draft.distance } });
            onClose();
          }}
        >
          {count ? `Show ${count} ${count === 1 ? "person" : "people"}` : "Apply filters"}
        </Button>
        {!count && <p className="fl-caption fl-center">No one new fits these filters yet.</p>}
      </div>
    </Sheet>
  );
}

/* 4 · Matching -------------------------------------------------------------- */
/** Close-only header (Bumble match screen: X top-left). */
function CloseHeader({ onClose, label = "Close", align }) {
  return (
    <header className={`fl-close-head${align === "end" ? " fl-close-head--end" : ""}`}>
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
      <Frame tone="page" top={<CloseHeader label="Back to Home" align="end" onClose={() => go("discovery")} />}>
        <div className="fl-center fl-fill">
          <EmptyState art="empty-likes" title="No new match yet" action="Go to Home" onAction={() => go("discovery")}>
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
      kind="match"
      top={<CloseHeader label="Close and keep browsing" align="end" onClose={() => go("discovery")} />}
      footer={
        <div className="fl-stack fl-stack--full fl-match__actions">
          <Composer value={text} onChange={setText} placeholder={person.opener ?? `Say hello to ${person.name}`} onSend={send} />
          <Button variant="quiet" onClick={() => go("discovery")}>
            Keep browsing
          </Button>
        </div>
      }
    >
      <div className="fl-center fl-fill fl-match">
        <MatchCelebration name={person.name} src={person.src} illustration={<IllustrationSlot id="match-hands-heart" />}>
          You and <strong>{person.name}</strong> liked each other. Now say hello.
        </MatchCelebration>
      </div>
    </Frame>
  );
}

/* 5 · Messaging ------------------------------------------------------------- */
const MESSAGE_FILTERS = [
  { id: "all", label: "All" },
  { id: "unread", label: "Unread" },
  { id: "move", label: "Your move" },
];

export function Chats({ go }) {
  const [state, dispatch] = useStore();
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("all");
  const open = (id) => {
    dispatch({ type: "openChat", id });
    go("chat");
  };
  const q = query.trim().toLowerCase();
  // Search matches names and message text; the filter then narrows conversations.
  const fresh = newMatches(state)
    .map((id) => ({ id, name: PEOPLE[id].name }))
    .filter((m) => !q || m.name.toLowerCase().includes(q));
  const all = conversations(state).filter((c) => !q || c.name.toLowerCase().includes(q) || c.text.toLowerCase().includes(q));
  const rows = all.filter((c) => filter === "all" || (filter === "unread" && c.unread > 0) || (filter === "move" && c.yourMove));
  const counts = { all: all.length, unread: all.filter((c) => c.unread > 0).length, move: all.filter((c) => c.yourMove).length };
  const nothingYet = !newMatches(state).length && !conversations(state).length;
  return (
    <Frame tone="page" top={<TopBar largeTitle="Messages" />} tab="messages" go={go}>
      <div className="fl-stack fl-gap-lg fl-sections">
        {!state.prefs.messages && (
          <Banner tone="info" title="New message alerts are off" action="Turn on" onAction={() => dispatch({ type: "prefs", patch: { messages: true } })}>
            You’ll still see new messages here.
          </Banner>
        )}
        {nothingYet ? (
          <EmptyState art="empty-conversations" title="Connections start here" action="Find your people" onAction={() => go("discovery")}>
            When you like each other, you’ll match. Here’s where you can chat.
          </EmptyState>
        ) : (
          <>
            <SearchField label="Search messages" placeholder="Search names and messages" value={query} onChange={(e) => setQuery(e.target.value)} onClear={() => setQuery("")} />
            {fresh.length > 0 && (
              <section className="fl-stack">
                <h2 className="fl-section-title">
                  New matches <span className="fl-section-title__count">({fresh.length})</span>
                </h2>
                <MatchQueue matches={fresh} onSelect={open} />
              </section>
            )}
            <section className="fl-stack" aria-labelledby="fl-convos-title">
              <h2 id="fl-convos-title" className="fl-section-title">
                Conversations
              </h2>
              <FilterChips label="Filter conversations" value={filter} onChange={setFilter} options={MESSAGE_FILTERS.map((f) => ({ ...f, count: counts[f.id] }))} />
              {rows.length ? (
                <ul className="fl-list">
                  {rows.map((c) => (
                    <ConversationRow key={c.id} {...c} onPress={() => open(c.id)} />
                  ))}
                </ul>
              ) : (
                /* Blame the search only when the search itself found nothing; otherwise the filter. */
                <EmptyState
                  icon={q && !all.length ? "search" : "message"}
                  title={q && !all.length ? `Nothing matches “${query.trim()}”` : filter === "unread" ? "You’re all caught up" : filter === "move" ? "No one is waiting on you" : "No conversations yet"}
                  action={q && !all.length ? "Search everything again" : filter !== "all" ? "Show all" : undefined}
                  onAction={() => (q && !all.length ? setQuery("") : setFilter("all"))}
                >
                  {q && !all.length ? "Search looks at names and messages." : filter === "all" ? "Say hello to a new match to start one." : "Conversations show here when they need you."}
                </EmptyState>
              )}
            </section>
          </>
        )}
      </div>
    </Frame>
  );
}

/* Outcome copy per action. Each is honest about what the preview did; nothing is "reviewed". */
const ENDED = {
  unmatched: { art: "unmatch-outcome", title: (n) => `You’ve unmatched ${n}`, body: (n) => `The conversation is closed for both of you and ${n} won’t appear in Home.` },
  blocked: { art: "safety-confirmation", title: (n) => `You’ve blocked ${n}`, body: (n) => `${n} isn’t told. You won’t see each other again, and they can’t message you. Unblock any time in Settings › Blocked people.` },
  reported: { art: "safety-confirmation", title: (n) => `You’ve reported and blocked ${n}`, body: (n) => `${n} isn’t told. In this preview the report is kept on this device only; nothing is sent or reviewed.` },
};

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
  const [blocking, setBlocking] = useState(false);
  const [toast, flash] = useFlash(1800);
  const composer = useRef(null);

  const send = (value) => {
    const msgId = Date.now();
    dispatch({ type: "send", id, text: value, msgId });
    setText("");
    setTimeout(() => dispatch({ type: "delivered", id, msgId }), 700);
  };

  if (ended) {
    const e = ENDED[ended];
    return (
      <Frame tone="page" top={<TopBar onBack={() => go("chats")} />}>
        <div className="fl-center fl-fill">
          <ResultPanel tone="neutral" art={e.art} title={e.title(person.name)} footer={<Button onClick={() => go("chats")}>Back to messages</Button>}>
            <p>{e.body(person.name)}</p>
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
          <IconButton icon="chevronLeft" label="Back to messages" variant="floating" size="sm" onClick={() => go("chats")} />
          <Avatar name={person.name} size="sm" decorative />
          <span className="fl-chat-head__name">
            {person.name}
            {person.verified && <VerifiedBadge compact />}
          </span>
          <IconButton icon="more" label="Conversation options" variant="floating" size="sm" onClick={() => setMenu(true)} />
        </header>
      }
      footer={<Composer ref={composer} value={text} onChange={setText} onSend={send} placeholder={`Message ${person.name}`} />}
    >
      {messages.length === 0 ? (
        /* Bumble new-match conversation: the person is centred until the first message, with openers. */
        <div className="fl-chat-intro">
          <Avatar name={person.name} size="xl" verified={person.verified} />
          <p className="fl-chat-intro__name">
            {person.name}, {person.age}
          </p>
          <p className="fl-caption">You matched. Say hello and make it personal.</p>
          <div className="fl-openers" role="group" aria-label="Opening ideas">
            <p className="fl-label">Need an opener? Tap one to edit it first.</p>
            {openersFor(id).map((o) => (
              <button
                key={o}
                type="button"
                className="fl-opener"
                onClick={() => {
                  setText(o);
                  composer.current?.focus();
                }}
              >
                {o}
              </button>
            ))}
          </div>
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
          { label: "Unmatch", icon: "userMinus", onSelect: () => { setMenu(false); setConfirm(true); } },
          { label: "Block", icon: "block", tone: "destructive", onSelect: () => { setMenu(false); setBlocking(true); } },
          { label: "Report", icon: "flag", tone: "destructive", onSelect: () => { setMenu(false); setReport(true); } },
        ]}
      />
      <ReportSheet
        open={report}
        subject={person.name}
        reasons={REPORT_REASONS.map(([, label]) => label)}
        blockOption={person.name}
        onClose={() => setReport(false)}
        onSubmit={({ reason, details, block }) => {
          dispatch({ type: "report", target: "person", targetId: id, reason, details, block, at: new Date(2026, 9, 23, 12).toISOString() });
        }}
      />
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
              <span>Report them instead. You can block them at the same time.</span>
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
      <Sheet open={blocking} onClose={() => setBlocking(false)} labelledBy="fl-block-title">
        <div className="sheet__header">
          <h2 id="fl-block-title" className="sheet__title">
            Block {person.name}?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setBlocking(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <ConsequenceList
            items={[
              { icon: "block", text: `${person.name} can’t message you or see you` },
              { icon: "eyeOff", text: "You won’t see their profile or activities" },
              { icon: "info", text: `${person.name} isn’t told` },
            ]}
          />
          <Button variant="destructive-solid" onClick={() => { setBlocking(false); dispatch({ type: "end", id, reason: "blocked" }); }}>
            Block {person.name}
          </Button>
          <Button variant="quiet" data-autofocus onClick={() => setBlocking(false)}>
            Cancel
          </Button>
        </div>
      </Sheet>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}

/* 6 · Profile and settings -------------------------------------------------- */
export function MyProfile({ go }) {
  const [state] = useStore();
  const { name, year, gender, looking, interests } = state.profile;
  const age = ageOf(year);
  const facts = [GENDER_LABEL[gender], looking?.length ? LOOKING_LABEL[looking[0]] : null].filter(Boolean);
  const { score, recommendations } = readiness(state.profile);
  const fix = useFixAction(go);
  const status = accountStatus(state);
  const mine = myActivities(state);
  const connected = Object.values(state.social).filter(Boolean).length;
  const next = recommendations[0];
  return (
    <Frame
      tone="page"
      top={<TopBar largeTitle="Profile" actions={<IconButton icon="settings" label="Settings" variant="floating" size="sm" onClick={() => go("settings")} />} />}
      tab="profile"
      go={go}
    >
      <div className="fl-stack fl-gap-lg fl-sections">
        {/* Identity: the avatar with its readiness ring, then the person (name, what they are looking
            for, their interests), then the one edit action. Centred: this block is about one person. */}
        <div className="fl-me">
          <div className="fl-me__avatar">
            <Avatar name={name || "You"} size="xl" ring={{ value: score / 100 }} />
            <span className="fl-me__pct" aria-label={`Profile readiness ${score} out of 100`}>
              {score}
            </span>
          </div>
          <p className="fl-me__name">
            {name || "You"}
            {age ? `, ${age}` : ""}
          </p>
          {facts.length > 0 && <p className="fl-me__facts">{facts.join(" · ")}</p>}
          {interests.length > 0 && (
            <ul className="fl-me__interests" aria-label="Your interests">
              {interests.map((s) => (
                <li key={s} className="chip chip--static">
                  {s}
                </li>
              ))}
            </ul>
          )}
          <div className="fl-badges fl-me__actions">
            <Button variant="secondary" size="sm" block={false} icon="edit" onClick={() => go("edit")}>
              Edit profile
            </Button>
            {state.prefs.snooze && (
              <Badge tone="warning" icon="eyeOff">
                Snoozed
              </Badge>
            )}
          </div>
        </div>

        {/* Compact readiness summary leading to the full dashboard. */}
        <section className="card fl-ready-card" aria-labelledby="fl-ready-title">
          <div className="fl-ready-card__top">
            <ReadinessMeter value={score} size={56} />
            <div className="fl-stack fl-gap-xs">
              <h2 id="fl-ready-title" className="fl-ready-card__title">
                Profile readiness
              </h2>
              <p className="fl-caption">{next ? `Next: ${next.action.toLowerCase()} (up to ${next.max - next.points} points)` : "Everything visible on your profile is filled in."}</p>
            </div>
          </div>
          <div className="fl-row fl-row--tight">
            {next && (
              <Button size="sm" block={false} onClick={() => fix(next)}>
                {next.action}
              </Button>
            )}
            <Button variant="quiet" size="sm" block={false} onClick={() => go("insights")}>
              See insights
            </Button>
          </div>
        </section>

        <div className="list-group">
          <p className="list-group__title">Your prompt</p>
          <PromptCard prompt={state.profile.prompt.q} answer={state.profile.prompt.a} onEdit={() => go("prompt")} />
          <p className="list-group__footnote">Matches reply to this.</p>
        </div>

        <ListGroup title="Activity">
          <ListRow icon="event" label="My activities" value={`${mine.upcoming.length + mine.hosting.length} upcoming`} kind="value" onPress={() => go("my-activities")} />
        </ListGroup>
        <ListGroup title="Account">
          <ListRow icon="bell" label="Notifications" value={state.prefs.messages || state.prefs.likes || state.prefs.activity ? "On" : "Off"} kind="value" onPress={() => go("settings")} />
          <ListRow icon="settings" label="Settings and privacy" value={status.label} kind="value" onPress={() => go("settings")} />
          <ListRow icon="premium" label="Premium" value={state.plan === "plus" ? "Plus" : "Free"} kind="value" onPress={() => go("premium")} />
          <ListRow icon="link" label="Connected accounts" value={connected ? `${connected} connected` : "None"} kind="value" onPress={() => go("connections")} />
          <ListRow icon="help" label="Help and support" onPress={() => go("help")} />
        </ListGroup>
        <ListGroup title="Trust">
          <ListRow icon="shield" label="Verification" kind="info" value="Phone verified" />
        </ListGroup>
      </div>
    </Frame>
  );
}

/** Your profile as others see it in Discover (Bumble edit profile → Preview). */
function ProfilePreview({ profile }) {
  const age = ageOf(profile.year);
  return (
    <div className="fl-pf fl-preview">
      <ProfileCard name={profile.name || "You"} age={age ?? "–"} details={[]} />
      {profile.bio?.trim() && (
        <ProfileSection title="About me">
          <p className="fl-pf__body">{profile.bio}</p>
        </ProfileSection>
      )}
      <ProfilePrompt prompt={profile.prompt.q} answer={profile.prompt.a} />
      {profile.interests.length > 0 && (
        <ProfileSection title="Interests">
          <div className="fl-chip-row">
            {profile.interests.map((s) => (
              <Chip key={s} kind="static">
                {s}
              </Chip>
            ))}
          </div>
        </ProfileSection>
      )}
      {profile.photos.slice(1, 3).map((p, i) => (
        <ImagePlaceholder key={p.id} tone={0} ratio="4 / 5" className="fl-pf__photo" label={`Your photo ${i + 2} (placeholder)`} />
      ))}
      <p className="fl-caption fl-center">This is how people see you in Home. Changes save as you make them.</p>
    </div>
  );
}

const GENDER_LABEL = { woman: "Woman", man: "Man", nonbinary: "Nonbinary" };
const LOOKING_LABEL = { "long-term": "Looking for long-term", open: "Seeing where it goes", casual: "Something casual" };

/**
 * Edit profile (reference: Bumble edit profile): photos with options, the prompt, interests and
 * About you, with an Edit / Preview switch at the top. Changes save immediately, as in the reference.
 */
export function EditProfile({ go }) {
  const [state, dispatch] = useStore();
  const { profile } = state;
  const [view, setView] = useState("edit");
  const [photoId, setPhotoId] = useState(null);
  const [toast, flash] = useFlash();
  const set = (patch) => dispatch({ type: "profile", patch });
  const photos = profile.photos;
  const index = photos.findIndex((p) => p.id === photoId);
  const age = ageOf(profile.year);
  const add = () => photos.length < 6 && set({ photos: [...photos, { id: Date.now(), tone: photos.length % 4 }] });
  const [orienting, setOrienting] = useState(false);
  const formRef = useRef(null);
  // A readiness recommendation opens Edit profile on its field: scroll to it and focus it once.
  useEffect(() => {
    const field = state.editFocus;
    if (!field) return;
    setView("edit");
    const t = setTimeout(() => {
      const el = formRef.current?.querySelector(`[data-focus="${field}"]`);
      el?.scrollIntoView({ block: "center" });
      (el?.matches("input, textarea, button") ? el : el?.querySelector("input, textarea, button"))?.focus({ preventScroll: true });
      dispatch({ type: "editFocus", field: null });
    }, 150);
    return () => clearTimeout(t);
  }, [state.editFocus, dispatch]);
  const remove = (id) => {
    if (photos.length <= 2) return flash("Keep at least 2 photos");
    set({ photos: photos.filter((p) => p.id !== id) });
  };
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("profile")} title="Edit profile" />}>
      <div className="fl-stack fl-gap-lg fl-sections" ref={formRef}>
        <SegmentedControl
          label="Profile view"
          value={view}
          onChange={setView}
          options={[
            { value: "edit", label: "Edit" },
            { value: "preview", label: "Preview" },
          ]}
        />
        {view === "preview" ? (
          <ProfilePreview profile={profile} />
        ) : (
          <>
            <div data-focus="photos">
              <Section title="Photos" description="Tap a photo to make it your main one. Keep at least 2.">
                <PhotoGrid photos={photos} onAdd={add} onRemove={remove} onSelect={setPhotoId} hint="Your main photo leads your profile in Home." />
              </Section>
            </div>
            <Section title="Prompt" description="Matches reply to this.">
              <PromptCard prompt={profile.prompt.q} answer={profile.prompt.a} onEdit={() => go("prompt")} />
            </Section>
            <div data-focus="bio">
              <TextArea label="Bio" placeholder="A few lines about you: what you love, what you’re looking for." value={profile.bio ?? ""} maxLength={300} rows={4} onChange={(e) => set({ bio: e.target.value })} />
            </div>
            <div data-focus="interests">
              <ChipGroup label="Interests" options={INTERESTS} groups={INTEREST_GROUPS} value={profile.interests} onChange={(v) => set({ interests: v })} max={5} />
            </div>
            <TextField
              data-focus="name"
              label="First name"
              value={profile.name}
              onChange={(e) => set({ name: e.target.value })}
              autoComplete="given-name"
              error={profile.name.trim() ? null : "Add your first name so people know what to call you."}
            />
            <ListGroup title="About you" footnote="Age and gender come from sign-up. Contact support to change your birth year.">
              <ListRow label="Age" kind="info" value={age ? String(age) : "Not set"} />
              <ListRow label="Gender" kind="info" value={GENDER_LABEL[profile.gender] ?? "Not set"} />
            </ListGroup>
            <ListGroup title="Sexual orientation (optional)" footnote="Optional and private: in this preview it isn’t shown on your profile or used to rank you.">
              <ListRow label="Orientation" value={ORIENTATIONS.find((o) => o.value === (profile.orientation || ""))?.label} kind="value" onPress={() => setOrienting(true)} />
            </ListGroup>
          </>
        )}
      </div>
      <ActionSheet
        open={photoId !== null}
        onClose={() => setPhotoId(null)}
        actions={[
          ...(index > 0
            ? [
                {
                  label: "Make main photo",
                  icon: "star",
                  onSelect: () => {
                    set({ photos: [photos[index], ...photos.filter((p) => p.id !== photoId)] });
                    setPhotoId(null);
                    flash("Main photo updated");
                  },
                },
              ]
            : []),
          {
            label: "Remove photo",
            icon: "trash",
            tone: "destructive",
            onSelect: () => {
              remove(photoId);
              setPhotoId(null);
            },
          },
        ]}
      />
      <Sheet open={orienting} onClose={() => setOrienting(false)} labelledBy="fl-orient-title">
        <div className="sheet__header">
          <h2 id="fl-orient-title" className="sheet__title">
            Sexual orientation
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setOrienting(false)} />
        </div>
        <OptionCards legend="Orientation" value={profile.orientation || ""} onChange={(orientation) => { set({ orientation }); setOrienting(false); }} options={ORIENTATIONS} />
      </Sheet>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}

const ORIENTATIONS = [
  { value: "", label: "Prefer not to say" },
  { value: "straight", label: "Straight" },
  { value: "gay", label: "Gay" },
  { value: "lesbian", label: "Lesbian" },
  { value: "bisexual", label: "Bisexual" },
  { value: "queer", label: "Queer" },
  { value: "asexual", label: "Asexual" },
  { value: "other", label: "Another orientation" },
];

const ANSWER_MAX = 150;

/** Prompt editor (reference: Bumble prompts): pick a question, write the answer, save. */
export function PromptEditor({ go }) {
  const [state, dispatch] = useStore();
  const saved = state.profile.prompt;
  const [q, setQ] = useState(saved.q);
  const [a, setA] = useState(saved.a);
  // Another frame (or a reset) changed the saved prompt: start from it.
  useEffect(() => {
    setQ(saved.q);
    setA(saved.a);
  }, [saved.q, saved.a]);
  const answer = a.trim();
  const changed = q !== saved.q || answer !== saved.a;
  return (
    <Frame
      tone="page"
      top={<TopBar onBack={() => go("edit")} title="Your prompt" />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Button
            disabled={!answer || !changed}
            onClick={() => {
              dispatch({ type: "profile", patch: { prompt: { q, a: answer } } });
              go("edit");
            }}
          >
            Save prompt
          </Button>
          <p className="fl-caption fl-center">{answer ? (changed ? "Saved prompts show on your profile straight away." : "No changes yet.") : "Write an answer to save."}</p>
        </div>
      }
    >
      <div className="fl-stack fl-gap-lg">
        <OptionCards legend="Pick a prompt" value={q} onChange={setQ} options={PROMPT_QUESTIONS.map((p) => ({ value: p, label: p }))} />
        <TextArea label="Your answer" value={a} maxLength={ANSWER_MAX} onChange={(e) => setA(e.target.value)} placeholder="Be specific. It gives people something to reply to." />
      </div>
    </Frame>
  );
}

const FEEDBACK = {
  snooze: ["Snoozed. Home is paused.", "Welcome back. Home is on."],
  messages: ["New message alerts on", "New message alerts off"],
  likes: ["New like alerts on", "New like alerts off"],
  activity: ["Activity updates on", "Activity updates off"],
  simulateErrors: ["Network errors simulated", "Network errors off"],
};
const DESCRIBE = {
  snooze: (on) => (on ? "You’re hidden. Resume any time." : "Take a break without losing matches"),
  messages: (on) => (on ? "On" : "Off: you’ll still see them in Chats"),
  likes: (on) => (on ? "On" : "Off"),
  activity: (on) => (on ? "On: requests, approvals and changes" : "Off: you’ll still see them in Activity"),
  simulateErrors: (on) => (on ? "On: the Activity feed and joining fail" : "Off"),
};

export function Settings({ go }) {
  const [state, dispatch] = useStore();
  const { prefs } = state;
  const setPrefs = (patch) => dispatch({ type: "prefs", patch });
  const [pending, setPending] = useState(null);
  const [deleting, setDeleting] = useState(false);
  const [toast, flash] = useFlash();
  const blocked = Object.values(state.ended).filter((r) => r === "blocked" || r === "reported").length;
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
      <div className="fl-stack fl-gap-lg fl-sections">
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
        <ListGroup title="Visibility" footnote="Snooze hides your profile and pauses Home. Matches and chats stay.">
          {switchRow("snooze", "Snooze")}
        </ListGroup>
        <ListGroup title="Notifications" footnote="In this preview, alerts are simulated. Your browser is never asked for permission.">
          {switchRow("messages", "New messages")}
          {switchRow("likes", "New likes")}
          {switchRow("activity", "Activity updates")}
        </ListGroup>
        <ListGroup title="Privacy and safety">
          <ListRow icon="shield" label="Blocked people" kind="value" value={String(blocked)} onPress={() => go("blocked")} />
        </ListGroup>
        <InfoCard icon="flag" title="Blocking and reporting">
          Use the options menu on a conversation, profile or activity to unmatch, block or report. In this preview, reports stay on this device.
        </InfoCard>
        <ListGroup title="Prototype tools" footnote="For trying failure states in this preview. Real Numaya has no such switches.">
          {switchRow("simulateErrors", "Simulate network errors")}
          <ListRow icon="maintenance" label="Preview the maintenance screen" onPress={() => go("maintenance")} />
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
