// Profile insights and account screens: readiness dashboard, blocked people, premium preview,
// connected accounts (simulated), help and support, and the maintenance system state.
import { useState } from "react";
import {
  Badge,
  Button,
  ComparisonTable,
  ConsequenceList,
  Dialog,
  EmptyState,
  Icon,
  IconButton,
  IdentityRow,
  InfoCard,
  ListGroup,
  ListRow,
  MetricCard,
  ProgressBar,
  ReadinessMeter,
  ResultPanel,
  Sheet,
  TipCard,
  Toast,
  TopBar,
} from "../design-system/index.js";
import { PEOPLE } from "./data.js";
import { Frame, useFlash } from "./frame.jsx";
import { myActivities, readiness } from "./model.js";
import { useStore } from "./store.js";

/** Open the field a readiness item points at: the prompt editor, or Edit profile focused on the field. */
export function useFixAction(go) {
  const [, dispatch] = useStore();
  return (item) => {
    if (item.focus === "prompt") return go("prompt");
    dispatch({ type: "editFocus", field: item.focus });
    go("edit");
  };
}

/** Account status from real preview state only: Snooze is the one status the preview has. */
export function accountStatus(state) {
  return state.prefs.snooze
    ? { tone: "warning", icon: "eyeOff", label: "Paused", detail: "Snooze is on: your profile is hidden and Home is paused. Matches and chats stay." }
    : { tone: "success", icon: "check", label: "Active", detail: "Your profile can be shown in Home and Activity." };
}

export function Insights({ go }) {
  const [state] = useStore();
  const fix = useFixAction(go);
  const { score, items, recommendations } = readiness(state.profile);
  const photos = state.profile.photos.length;
  const mine = myActivities(state);
  const status = accountStatus(state);
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("profile")} title="Profile readiness" />}>
      <div className="fl-stack fl-gap-lg fl-sections">
        <section className="card fl-readiness" aria-labelledby="fl-readiness-title">
          <ReadinessMeter value={score} />
          <div className="fl-stack fl-gap-xs">
            <h2 id="fl-readiness-title" className="fl-section-title">
              {score === 100 ? "Your profile is ready" : score >= 70 ? "Nearly ready" : "A few things to add"}
            </h2>
            <p className="fl-caption">
              Based only on what your profile shows: basics, photos, interests, bio and prompt. It doesn’t rate you or how people respond.
            </p>
          </div>
        </section>

        {recommendations.length > 0 && (
          <section className="fl-stack" aria-labelledby="fl-next-title">
            <h2 id="fl-next-title" className="fl-section-title">
              What to do next
            </h2>
            {recommendations.map((r) => (
              <TipCard key={r.id} icon={r.id === "photos" ? "camera" : r.id === "interests" ? "interests" : r.id === "prompt" ? "message" : r.id === "bio" ? "edit" : "user"} title={r.action} onPress={() => fix(r)}>
                {r.hint} Up to {r.max - r.points} more points.
              </TipCard>
            ))}
          </section>
        )}

        <ListGroup title="How the score adds up" footnote="Verification is shown separately and never counted in the score.">
          {items.map((i) => (
            <li key={i.id} className="list-row">
              <button type="button" className="list-row__hit fl-breakdown" onClick={() => fix(i)}>
                <span className="fl-breakdown__text">
                  <span className="fl-breakdown__top">
                    <span className="list-row__label">{i.label}</span>
                    <span className="fl-breakdown__points">
                      {i.points % 1 ? i.points.toFixed(1) : i.points} / {i.max}
                    </span>
                  </span>
                  <ProgressBar value={i.points} max={i.max} label={i.label} />
                  <span className="list-row__description">{i.detail}</span>
                </span>
                <Icon name={i.done ? "check" : "chevronRight"} size={18} className="list-row__trail" />
              </button>
            </li>
          ))}
        </ListGroup>

        <section className="fl-stack" aria-labelledby="fl-metrics-title">
          <h2 id="fl-metrics-title" className="fl-section-title">
            Your profile at a glance
          </h2>
          <div className="fl-metrics">
            <MetricCard icon="camera" label="Photos" value={`${photos} of 4`} detail="Recommended 4; up to 6" progress={{ value: Math.min(photos, 4), max: 4 }} />
            <MetricCard icon="interests" label="Interests" value={`${state.profile.interests.length} of 5`} detail="At least 3 help surface shared topics" progress={{ value: state.profile.interests.length, max: 5 }} />
            <MetricCard icon="verified" label="Verification" value="Phone" detail="Photo and ID checks aren’t available in this preview" />
            <MetricCard icon="event" label="Activities" value={`${mine.upcoming.length + mine.hosting.length}`} detail={`${mine.upcoming.length} joined · ${mine.hosting.length} hosting, from now on`} />
          </div>
        </section>

        <section className="fl-stack" aria-labelledby="fl-status-title">
          <h2 id="fl-status-title" className="fl-section-title">
            Account status
          </h2>
          <div className="card fl-status">
            <Badge tone={status.tone} icon={status.icon}>
              {status.label}
            </Badge>
            <p>{status.detail}</p>
            <p className="fl-caption">This preview has no server account, so the status comes from your settings on this device. In this preview, nothing about your replies or unmatches changes your visibility.</p>
            <Button variant="secondary" size="sm" block={false} onClick={() => go("settings")}>
              Visibility settings
            </Button>
          </div>
        </section>
      </div>
    </Frame>
  );
}

/* Blocked people ------------------------------------------------------- */

export function Blocked({ go }) {
  const [state, dispatch] = useStore();
  const [unblocking, setUnblocking] = useState(null);
  const [toast, flash] = useFlash();
  const ids = Object.entries(state.ended)
    .filter(([, r]) => r === "blocked" || r === "reported")
    .map(([id]) => id);
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("settings")} title="Blocked people" />}>
      <div className="fl-stack fl-gap-lg fl-sections">
        {ids.length ? (
          <ListGroup footnote="Blocked people can’t see you or message you, and they aren’t told.">
            {ids.map((id) => (
              <li key={id} className="list-row">
                <div className="list-row__hit">
                  <IdentityRow
                    name={PEOPLE[id].name}
                    caption={state.ended[id] === "reported" ? "Reported and blocked" : "Blocked"}
                    trailing={
                      <Button variant="secondary" size="sm" block={false} onClick={() => setUnblocking(id)}>
                        Unblock
                      </Button>
                    }
                  />
                </div>
              </li>
            ))}
          </ListGroup>
        ) : (
          <EmptyState icon="block" title="You haven’t blocked anyone">
            Block someone from a conversation, a profile or an activity. They won’t be told.
          </EmptyState>
        )}
      </div>
      <Dialog
        open={Boolean(unblocking)}
        onClose={() => setUnblocking(null)}
        title={`Unblock ${unblocking ? PEOPLE[unblocking].name : ""}?`}
        confirmLabel="Unblock"
        onConfirm={() => {
          const name = PEOPLE[unblocking].name;
          dispatch({ type: "unblock", id: unblocking });
          setUnblocking(null);
          flash(`${name} is unblocked`);
        }}
      >
        They may see you again in Home and Activity. Your match and messages don’t come back.
      </Dialog>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}

/* Premium -------------------------------------------------------------- */

const PLUS_ROWS = [
  { feature: "Like, match and message", tiers: [true, true] },
  { feature: "Explore and join activities", tiers: [true, true] },
  { feature: "See who liked you", tiers: [true, true] },
  { feature: "Undo more than one pass", tiers: [false, true] },
  { feature: "Advanced filters", tiers: [false, true] },
  { feature: "Host more than 3 upcoming activities", tiers: [false, true] },
];

export function Premium({ go }) {
  const [state] = useStore();
  const [previewing, setPreviewing] = useState(false);
  return (
    <Frame
      tone="page"
      top={<TopBar onBack={() => go("profile")} title="Premium" />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Button onClick={() => setPreviewing(true)}>See Plus</Button>
          <p className="fl-caption fl-center">No payment is taken in this preview.</p>
        </div>
      }
    >
      <div className="fl-stack fl-gap-lg fl-sections">
        <div className="fl-stack fl-gap-xs">
          <p className="fl-caption">Your plan</p>
          <p className="fl-section-title">{state.plan === "plus" ? "Plus" : "Free"}</p>
          <p className="fl-caption">Everything you need to meet people is free. Plus adds a few extras.</p>
        </div>
        <ComparisonTable tiers={["Free", "Plus"]} rows={PLUS_ROWS} caption="Free and Plus compared" />
        <InfoCard icon="info" title="Prices aren’t set yet">
          Numaya hasn’t set Plus pricing, so none is shown. When it is, the price, renewal and how to cancel appear before you confirm.
        </InfoCard>
      </div>
      <Sheet open={previewing} onClose={() => setPreviewing(false)} labelledBy="fl-plus-title">
        <ResultPanel
          tone="neutral"
          icon="premium"
          compact
          title={<span id="fl-plus-title">Plus isn’t on sale in this preview</span>}
          footer={
            <Button variant="secondary" data-autofocus onClick={() => setPreviewing(false)}>
              Got it
            </Button>
          }
        >
          <p>There’s no billing here, so nothing is charged and your plan stays Free.</p>
        </ResultPanel>
      </Sheet>
    </Frame>
  );
}

/* Connected accounts (simulated) --------------------------------------- */

const SERVICES = {
  instagram: {
    name: "Instagram",
    icon: "camera",
    shares: [
      { icon: "image", text: "Your most recent public photos, shown on your profile" },
      { icon: "user", text: "Your Instagram username is never shown" },
    ],
  },
  spotify: {
    name: "Spotify",
    icon: "music",
    shares: [
      { icon: "music", text: "Your top artists, shown on your profile" },
      { icon: "lock", text: "Playlists and listening history stay private" },
    ],
  },
};

export function Connections({ go }) {
  const [state, dispatch] = useStore();
  const [connecting, setConnecting] = useState(null);
  const [disconnecting, setDisconnecting] = useState(null);
  const [toast, flash] = useFlash();
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("profile")} title="Connected accounts" />}>
      <div className="fl-stack fl-gap-lg fl-sections">
        <p className="fl-caption">Optional. Connecting adds a little colour to your profile; your profile is complete without it.</p>
        <ListGroup footnote="Simulated in this preview: no account is opened, nothing is imported and no data leaves this device.">
          {Object.entries(SERVICES).map(([key, s]) => (
            <li key={key} className="list-row">
              <div className="list-row__hit">
                <IdentityRow
                  name={s.name}
                  caption={state.social[key] ? "Connected (simulated) · nothing imported" : "Not connected"}
                  trailing={
                    state.social[key] ? (
                      <Button variant="secondary" size="sm" block={false} onClick={() => setDisconnecting(key)}>
                        Disconnect
                      </Button>
                    ) : (
                      <Button size="sm" block={false} onClick={() => setConnecting(key)}>
                        Connect
                      </Button>
                    )
                  }
                />
              </div>
            </li>
          ))}
        </ListGroup>
      </div>
      {connecting && (
        <Sheet open onClose={() => setConnecting(null)} labelledBy="fl-connect-title">
          <div className="sheet__header">
            <h2 id="fl-connect-title" className="sheet__title">
              Connect {SERVICES[connecting].name}?
            </h2>
            <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setConnecting(null)} />
          </div>
          <div className="fl-stack fl-sheet-body">
            <p className="fl-sheet-text">In the app, this would ask {SERVICES[connecting].name} for permission. Here’s what Numaya would show:</p>
            <ConsequenceList items={SERVICES[connecting].shares} />
            <p className="fl-caption">This preview only records the choice. You can disconnect any time.</p>
            <Button
              onClick={() => {
                dispatch({ type: "social", key: connecting, value: true });
                flash(`${SERVICES[connecting].name} connected (simulated)`);
                setConnecting(null);
              }}
            >
              Connect (simulated)
            </Button>
            <Button variant="quiet" data-autofocus onClick={() => setConnecting(null)}>
              Not now
            </Button>
          </div>
        </Sheet>
      )}
      <Dialog
        open={Boolean(disconnecting)}
        onClose={() => setDisconnecting(null)}
        title={`Disconnect ${disconnecting ? SERVICES[disconnecting].name : ""}?`}
        confirmLabel="Disconnect"
        tone="destructive"
        onConfirm={() => {
          dispatch({ type: "social", key: disconnecting, value: false });
          flash(`${SERVICES[disconnecting].name} disconnected`);
          setDisconnecting(null);
        }}
      >
        Nothing from it will show on your profile.
      </Dialog>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}

/* Help and support ----------------------------------------------------- */

const HELP = [
  { id: "dates", icon: "shield", title: "Meeting someone safely", body: ["Meet somewhere public, like the venue listed on an activity.", "Tell a friend where you’re going and when.", "Leave whenever you like. You don’t owe anyone your time."] },
  { id: "report", icon: "flag", title: "Reporting and blocking", body: ["Unmatch ends a match and closes the conversation.", "Block hides you from each other everywhere. They aren’t told.", "Report tells us what happened. In this preview reports stay on this device."] },
  { id: "activities", icon: "event", title: "Activities", body: ["Join straight away, or ask the host when they approve requests.", "Full activities have a waitlist.", "Hosts see guests’ first names only."] },
  { id: "account", icon: "user", title: "Your account and data", body: ["Snooze hides you without losing matches.", "Delete account in Settings removes your profile, matches and messages.", "This preview stores everything on this device only."] },
];

export function Help({ go }) {
  const [topic, setTopic] = useState(null);
  const t = HELP.find((h) => h.id === topic);
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("profile")} title="Help and support" />}>
      <div className="fl-stack fl-gap-lg fl-sections">
        <ListGroup title="Guides">
          {HELP.map((h) => (
            <ListRow key={h.id} icon={h.icon} label={h.title} onPress={() => setTopic(h.id)} />
          ))}
        </ListGroup>
        <ListGroup title="Contact" footnote="Support isn’t connected in this preview, so messages can’t be sent from here.">
          <ListRow icon="message" label="Contact support" kind="info" value="Not available" />
        </ListGroup>
      </div>
      <Sheet open={Boolean(t)} onClose={() => setTopic(null)} labelledBy="fl-help-title">
        {t && (
          <>
            <div className="sheet__header">
              <h2 id="fl-help-title" className="sheet__title">
                {t.title}
              </h2>
              <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setTopic(null)} />
            </div>
            <ul className="fl-help-list">
              {t.body.map((line) => (
                <li key={line}>{line}</li>
              ))}
            </ul>
          </>
        )}
      </Sheet>
    </Frame>
  );
}

/* Maintenance (reusable system state; never in the normal flow) --------- */

export function Maintenance({ go }) {
  const [checking, setChecking] = useState(false);
  return (
    <Frame tone="page">
      <div className="fl-center fl-fill">
        <ResultPanel
          tone="neutral"
          icon="maintenance"
          title="We’ll be right back"
          footer={
            <div className="fl-stack fl-stack--full">
              <Button
                loading={checking}
                onClick={() => {
                  setChecking(true);
                  setTimeout(() => go("discovery"), 700);
                }}
              >
                Try again
              </Button>
              <p className="fl-caption fl-center">Preview of the service-unavailable screen, opened from Settings › Prototype tools.</p>
            </div>
          }
        >
          <p>Numaya is down for maintenance. Your matches, messages and activities are safe. Try again in a few minutes.</p>
        </ResultPanel>
      </div>
    </Frame>
  );
}
