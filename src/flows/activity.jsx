// Activity: Explore (discovery) and activity details with participation, sharing and safety.
import { useEffect, useState } from "react";
import {
  ActionSheet,
  ActivityCard,
  ActivityMedia,
  ActivityStatus,
  AttendeeStack,
  Banner,
  Button,
  Checkbox,
  ConsequenceList,
  EmptyState,
  FilterChips,
  Icon,
  IconButton,
  IdentityRow,
  InfoCard,
  ListGroup,
  ListRow,
  MetaRow,
  OptionCards,
  ResultPanel,
  SegmentedControl,
  Sheet,
  Skeleton,
  TextArea,
  Toast,
  TopBar,
} from "../design-system/index.js";
import { ACTIVITY_CATEGORIES, ACTIVITY_REPORT_REASONS, AREAS, PEOPLE, PROTOTYPE_NOW } from "./data.js";
import { Frame, useFlash } from "./frame.jsx";
import {
  DATE_FILTERS,
  DISTANCE_FILTERS,
  activityById,
  areaOf,
  attendeeNames,
  cardProps,
  categoryIcon,
  categoryLabel,
  exploreList,
  goingCount,
  hostOf,
  joinModeOf,
  participationOf,
  phaseOf,
  placeLabel,
  whenLabel,
} from "./model.js";
import { useStore } from "./store.js";

const NO_FILTERS = { category: "all", when: "any", distance: "any" };

/** Bottom sheet listing the preview's areas. No device location is read. */
export function AreaSheet({ open, onClose }) {
  const [state, dispatch] = useStore();
  return (
    <Sheet open={open} onClose={onClose} labelledBy="fl-area-title">
      <div className="sheet__header">
        <h2 id="fl-area-title" className="sheet__title">
          Where are you looking?
        </h2>
        <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={onClose} />
      </div>
      <p className="fl-caption fl-mb">Pick an area. Numaya never reads your device’s location in this preview.</p>
      <OptionCards
        legend="Area"
        value={state.prefs.area ?? "none"}
        onChange={(v) => {
          dispatch({ type: "prefs", patch: { area: v === "none" ? null : v } });
          onClose();
        }}
        options={[...AREAS.map((a) => ({ value: a.id, label: a.name })), { value: "none", label: "No area", description: "Distances and the distance filter turn off" }]}
      />
    </Sheet>
  );
}

/** Date and distance filters, applied together. */
function ActivityFiltersSheet({ open, onClose, filters, onApply, hasArea }) {
  const [draft, setDraft] = useState(filters);
  useEffect(() => setDraft(filters), [open, filters]);
  return (
    <Sheet open={open} onClose={onClose} labelledBy="fl-afilters-title">
      <div className="sheet__header">
        <h2 id="fl-afilters-title" className="sheet__title">
          Filters
        </h2>
        <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={onClose} />
      </div>
      <div className="fl-stack fl-sheet-body">
        <OptionCards legend="When" value={draft.when} onChange={(when) => setDraft({ ...draft, when })} options={DATE_FILTERS.map((d) => ({ value: d.id, label: d.label }))} />
        {hasArea ? (
          <OptionCards legend="Distance" value={draft.distance} onChange={(distance) => setDraft({ ...draft, distance })} options={DISTANCE_FILTERS.map((d) => ({ value: d.id, label: d.label }))} />
        ) : (
          <p className="fl-caption">Choose an area to filter by distance.</p>
        )}
        <Button onClick={() => { onApply(draft); onClose(); }}>Show activities</Button>
      </div>
    </Sheet>
  );
}

/** Explore / My activities switch shared by both Activity screens. */
export function ActivityTabs({ current, go }) {
  return (
    <SegmentedControl
      label="Activity"
      value={current}
      onChange={(id) => id !== current && go(id)}
      options={[
        { value: "activity", label: "Explore" },
        { value: "my-activities", label: "My activities" },
      ]}
    />
  );
}

export function ActivityExplore({ go }) {
  const [state, dispatch] = useStore();
  const [filters, setFilters] = useState(NO_FILTERS);
  const [attempt, setAttempt] = useState(0);
  const [load, setLoad] = useState("loading");
  const [areaOpen, setAreaOpen] = useState(false);
  const [filtersOpen, setFiltersOpen] = useState(false);
  const area = areaOf(state.prefs.area);
  // A short simulated load, so the loading state is real; Prototype tools can make it fail.
  useEffect(() => {
    setLoad("loading");
    const t = setTimeout(() => setLoad(state.prefs.simulateErrors ? "error" : "ready"), 500);
    return () => clearTimeout(t);
  }, [attempt, state.prefs.simulateErrors]);
  // The distance filter only means something with an area.
  const effective = area ? filters : { ...filters, distance: "any" };
  const list = exploreList(state, effective);
  const extra = (effective.when !== "any") + (effective.distance !== "any");
  const filtered = effective.category !== "all" || extra > 0;
  const open = (id) => {
    dispatch({ type: "openActivity", id, from: "activity" });
    go("activity-detail");
  };
  return (
    <Frame
      tone="page"
      top={
        <TopBar
          largeTitle="Activity"
          actions={<IconButton icon="plus" label="Create an activity" variant="floating" size="sm" onClick={() => { dispatch({ type: "editActivity", id: null }); go("activity-form"); }} />}
        />
      }
      tab="activity"
      go={go}
    >
      <div className="fl-stack fl-gap-md fl-sections">
        <ActivityTabs current="activity" go={go} />
        <div className="fl-row fl-row--between">
          <button type="button" className="fl-area" onClick={() => setAreaOpen(true)}>
            <Icon name={area ? "location" : "nearby"} size={20} />
            <span>{area ? `Near ${area.name}` : "Choose an area"}</span>
            <Icon name="chevronDown" size={18} />
          </button>
          <button type="button" className="fl-filter-button" onClick={() => setFiltersOpen(true)} aria-label={`Filters${extra ? `, ${extra} on` : ""}`}>
            <Icon name="filter" size={20} />
            Filters{extra ? ` (${extra})` : ""}
          </button>
        </div>
        <FilterChips
          label="Category"
          value={filters.category}
          onChange={(category) => setFilters({ ...filters, category })}
          options={[{ id: "all", label: "All" }, ...ACTIVITY_CATEGORIES.map((c) => ({ id: c.id, label: c.label }))]}
        />
        {!area && (
          <InfoCard icon="nearby" title="No area chosen">
            Distances are hidden until you pick an area. Activities still show their venue.
          </InfoCard>
        )}
        {load === "loading" ? (
          <div className="fl-stack fl-gap-md" aria-busy="true" aria-label="Loading activities">
            {[0, 1].map((i) => (
              <div key={i} className="fl-skeleton-card">
                <Skeleton height={180} radius="var(--radius-lg)" />
                <Skeleton width="40%" />
                <Skeleton width="80%" height={22} />
                <Skeleton width="60%" />
              </div>
            ))}
          </div>
        ) : load === "error" ? (
          <EmptyState tone="error" icon="wifiOff" title="Couldn’t load activities" action="Try again" onAction={() => setAttempt((n) => n + 1)}>
            Check your connection and try again. (Network errors are switched on in Settings › Prototype tools.)
          </EmptyState>
        ) : list.length ? (
          <>
            <p className="fl-caption" aria-live="polite">
              {list.length} {list.length === 1 ? "activity" : "activities"}
              {filtered ? " match your filters" : area ? ` near ${area.name}` : ""}
            </p>
            <ul className="fl-card-list">
              {list.map((a) => (
                <li key={a.id}>
                  <ActivityCard {...cardProps(state, a)} onOpen={() => open(a.id)} />
                </li>
              ))}
            </ul>
          </>
        ) : (
          <EmptyState art={filtered ? undefined : "empty-activities"} icon="filter" title={filtered ? "Nothing matches these filters" : "No activities nearby yet"} action={filtered ? "Clear filters" : "Choose another area"} onAction={() => (filtered ? setFilters(NO_FILTERS) : setAreaOpen(true))}>
            {filtered ? "Try another day, a wider distance or a different category." : "Try another area, or host one yourself."}
          </EmptyState>
        )}
      </div>
      <AreaSheet open={areaOpen} onClose={() => setAreaOpen(false)} />
      <ActivityFiltersSheet open={filtersOpen} onClose={() => setFiltersOpen(false)} filters={filters} onApply={setFilters} hasArea={Boolean(area)} />
    </Frame>
  );
}

/* Activity details ----------------------------------------------------- */

const JOIN_LABEL = { join: "Join", request: "Request to join", waitlist: "Join the waitlist" };
const JOINED_TOAST = { joined: "You’re going", requested: "Request sent to the host", waitlisted: "You’re on the waitlist" };
const LEAVE = {
  joined: { title: "Leave this activity?", action: "Leave activity", items: [{ icon: "groups", text: "Your spot opens for someone else" }, { icon: "message", text: "The host isn’t sent a message in this preview" }] },
  requested: { title: "Withdraw your request?", action: "Withdraw request", items: [{ icon: "pending", text: "The host won’t see your request any more" }] },
  waitlisted: { title: "Leave the waitlist?", action: "Leave waitlist", items: [{ icon: "waitlist", text: "You’ll lose your place on the waitlist" }] },
};

const durationText = (min) => (min >= 60 ? `${Math.floor(min / 60)} h${min % 60 ? ` ${min % 60} min` : ""}` : `${min} min`);

/** Share sheet: honest about the preview (no link is created). */
export function ShareSheet({ open, onClose, title }) {
  return (
    <Sheet open={open} onClose={onClose} labelledBy="fl-share-title">
      <div className="sheet__header">
        <h2 id="fl-share-title" className="sheet__title">
          Share
        </h2>
        <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={onClose} />
      </div>
      <div className="fl-stack fl-sheet-body">
        <p className="fl-sheet-text">
          In the app, this opens your phone’s share sheet for “{title}”. This preview doesn’t create a link, so nothing is shared.
        </p>
        <Button variant="secondary" data-autofocus onClick={onClose}>
          Close
        </Button>
      </div>
    </Sheet>
  );
}

/** Report flow for an activity or a person: reason, optional details, honest outcome. */
export function ReportSheet({ open, onClose, subject, reasons, onSubmit, blockOption }) {
  const [reason, setReason] = useState(null);
  const [details, setDetails] = useState("");
  const [block, setBlock] = useState(true);
  const [done, setDone] = useState(false);
  useEffect(() => {
    if (open) {
      setReason(null);
      setDetails("");
      setBlock(true);
      setDone(false);
    }
  }, [open]);
  return (
    <Sheet open={open} onClose={onClose} labelledBy="fl-report2-title">
      {done ? (
        <ResultPanel
          tone="neutral"
          art="safety-confirmation"
          compact
          title={<span id="fl-report2-title">Report saved</span>}
          footer={<Button onClick={() => onClose(true)}>Done</Button>}
        >
          <p>
            Thanks for telling us. In this preview the report is kept on this device only; nothing is sent or reviewed.
            {blockOption && block ? ` ${blockOption} is blocked.` : ""}
          </p>
        </ResultPanel>
      ) : (
        <>
          <div className="sheet__header">
            <h2 id="fl-report2-title" className="sheet__title">
              Report {subject}
            </h2>
            <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => onClose(false)} />
          </div>
          <div className="fl-stack fl-sheet-body">
            <OptionCards legend="What’s wrong?" value={reason} onChange={setReason} options={reasons.map((r) => ({ value: r, label: r }))} />
            <TextArea label="Anything else? (optional)" value={details} maxLength={300} rows={3} onChange={(e) => setDetails(e.target.value)} />
            {blockOption && (
              <Checkbox label={`Also block ${blockOption}`} description="You won’t see each other again" checked={block} onChange={setBlock} />
            )}
            <Button
              disabled={!reason}
              onClick={() => {
                onSubmit({ reason, details, block: Boolean(blockOption) && block });
                setDone(true);
              }}
            >
              Send report
            </Button>
          </div>
        </>
      )}
    </Sheet>
  );
}

export function ActivityDetail({ go }) {
  const [state, dispatch] = useStore();
  const a = activityById(state, state.activeActivity);
  const [busy, setBusy] = useState(false);
  const [failed, setFailed] = useState(false);
  const [leaving, setLeaving] = useState(false);
  const [cancelling, setCancelling] = useState(false);
  const [menu, setMenu] = useState(false);
  const [sharing, setSharing] = useState(false);
  const [reporting, setReporting] = useState(false);
  const [blocking, setBlocking] = useState(false);
  const [toast, flash] = useFlash(1800);
  const back = () => go(state.activityBack ?? "activity");

  if (!a) {
    return (
      <Frame tone="page" top={<TopBar onBack={back} />}>
        <div className="fl-center fl-fill">
          <EmptyState icon="eventBusy" title="This activity isn’t available" action="Back to Explore" onAction={() => go("activity")}>
            It may have been removed or hidden after a report.
          </EmptyState>
        </div>
      </Frame>
    );
  }

  const phase = phaseOf(a);
  const me = participationOf(state, a);
  const mode = joinModeOf(state, a);
  const host = hostOf(a);
  const going = goingCount(state, a);
  const names = attendeeNames(state, a);
  const card = cardProps(state, a);
  const hostName = PEOPLE[a.host]?.name;

  const join = () => {
    setFailed(false);
    setBusy(true);
    setTimeout(() => {
      setBusy(false);
      // Prototype tools can make the request fail: nothing changes and the user can retry.
      if (state.prefs.simulateErrors) return setFailed(true);
      const next = mode === "waitlist" ? "waitlisted" : mode === "request" ? "requested" : "joined";
      dispatch({ type: "join", id: a.id });
      flash(JOINED_TOAST[next]);
    }, 600);
  };

  const footer =
    me === "host" ? (
      phase === "upcoming" || phase === "live" || phase === "draft" ? (
        <div className="fl-row">
          <Button variant="secondary" icon="groups" onClick={() => go("activity-people")}>
            {a.requests?.length ? `${a.requests.length} ${a.requests.length === 1 ? "request" : "requests"}` : "Guests"}
          </Button>
          <Button icon="edit" onClick={() => { dispatch({ type: "editActivity", id: a.id }); go("activity-form"); }}>
            Edit
          </Button>
        </div>
      ) : (
        <p className="fl-caption fl-center">{phase === "cancelled" ? "You cancelled this activity. Guests can still see that it’s off." : "This activity has ended."}</p>
      )
    ) : phase === "past" ? (
      <p className="fl-caption fl-center">This activity has ended.</p>
    ) : phase === "cancelled" ? (
      <p className="fl-caption fl-center">The host cancelled this activity.{me !== "none" ? " You don’t need to do anything." : ""}</p>
    ) : me === "none" ? (
      <div className="fl-stack fl-stack--full">
        <Button loading={busy} onClick={join}>
          {JOIN_LABEL[mode]}
        </Button>
        <p className="fl-caption fl-center">
          {mode === "request" ? `${hostName ?? "The host"} approves each request.` : mode === "waitlist" ? "It’s full. You’ll get a spot if someone leaves." : "You can leave any time."}
        </p>
      </div>
    ) : (
      <div className="fl-stack fl-stack--full">
        <Button variant="secondary" onClick={() => setLeaving(true)}>
          {LEAVE[me].action}
        </Button>
      </div>
    );

  return (
    <Frame
      tone="page"
      top={<TopBar onBack={back} actions={<IconButton icon="more" label="Activity options" variant="floating" size="sm" onClick={() => setMenu(true)} />} />}
      footer={footer}
    >
      <article className="fl-stack fl-gap-md fl-activity">
        <ActivityMedia tone={a.tone} icon={categoryIcon(a.category)} label={a.tone != null ? `${a.title} (placeholder image)` : undefined}>
          <ActivityStatus status={card.status} />
          <ActivityStatus participation={card.participation} />
        </ActivityMedia>
        <div className="fl-stack fl-gap-xs">
          <h1 className="fl-activity__title">{a.title}</h1>
          <p className="activity-card__category">{categoryLabel(a.category)}</p>
        </div>
        {failed && (
          <Banner tone="error" title="Couldn’t send that" action="Try again" onAction={join}>
            Nothing changed. Check your connection and try again.
          </Banner>
        )}
        <IdentityRow name={host.me ? "You" : host.name} verified={host.verified} caption={host.me ? "You’re hosting" : "Host"} size="md" />
        <div className="fl-stack fl-gap-sm">
          <MetaRow icon="calendar">
            {whenLabel(a)} · {durationText(a.durationMin)}
          </MetaRow>
          <MetaRow icon="location">{placeLabel(state, a)}</MetaRow>
          <MetaRow icon="groups">
            {a.capacity ? `${going} of ${a.capacity} going` : `${going} going · no limit`}
            {a.approval ? " · host approves requests" : ""}
          </MetaRow>
          <MetaRow icon={a.visibility === "private" ? "lock" : "public"}>
            {a.visibility === "private" ? "Private: only people with an invite can find it" : "Public: anyone on Numaya can see it"}
          </MetaRow>
        </div>
        {a.description && <p className="fl-activity__description">{a.description}</p>}
        <section className="fl-stack fl-gap-sm" aria-labelledby="fl-going-title">
          <h2 id="fl-going-title" className="fl-section-title">
            Who’s going
          </h2>
          <button type="button" className="card fl-edit-card" onClick={() => go("activity-people")}>
            <AttendeeStack names={names} total={going} max={5} />
            <span className="fl-caption">{names.length ? names.slice(0, 3).join(", ") + (going > 3 ? " and others" : "") : "Be the first"}</span>
            <Icon name="chevronRight" size={20} className="fl-edit-card__chevron" />
          </button>
        </section>
        {me !== "host" && (
          <InfoCard icon="shield" title="Meeting new people">
            Meet at the listed venue, tell a friend where you’re going and leave whenever you like. You can report or block from the options menu.
          </InfoCard>
        )}
      </article>

      <ActionSheet
        open={menu}
        onClose={() => setMenu(false)}
        actions={[
          { label: "Share", icon: "share", onSelect: () => { setMenu(false); setSharing(true); } },
          ...(me === "host"
            ? phase === "upcoming" || phase === "live"
              ? [{ label: "Cancel activity", icon: "eventBusy", tone: "destructive", onSelect: () => { setMenu(false); setCancelling(true); } }]
              : []
            : [
                { label: "Report activity", icon: "flag", tone: "destructive", onSelect: () => { setMenu(false); setReporting(true); } },
                { label: `Block ${host.name}`, icon: "block", tone: "destructive", onSelect: () => { setMenu(false); setBlocking(true); } },
              ]),
        ]}
      />
      <ShareSheet open={sharing} onClose={() => setSharing(false)} title={a.title} />
      <ReportSheet
        open={reporting}
        subject="activity"
        reasons={ACTIVITY_REPORT_REASONS}
        onClose={(submitted) => {
          setReporting(false);
          if (submitted === true) go("activity");
        }}
        onSubmit={({ reason, details }) => dispatch({ type: "report", target: "activity", targetId: a.id, reason, details, at: PROTOTYPE_NOW.toISOString() })}
      />
      {me !== "none" && LEAVE[me] && (
        <Sheet open={leaving} onClose={() => setLeaving(false)} labelledBy="fl-leave-title">
          <div className="sheet__header">
            <h2 id="fl-leave-title" className="sheet__title">
              {LEAVE[me].title}
            </h2>
            <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setLeaving(false)} />
          </div>
          <div className="fl-stack fl-sheet-body">
            <ConsequenceList items={LEAVE[me].items} />
            <Button
              variant="destructive-solid"
              onClick={() => {
                setLeaving(false);
                dispatch({ type: "leave", id: a.id });
                flash(me === "requested" ? "Request withdrawn" : "You’ve left");
              }}
            >
              {LEAVE[me].action}
            </Button>
            <Button variant="quiet" data-autofocus onClick={() => setLeaving(false)}>
              Keep my spot
            </Button>
          </div>
        </Sheet>
      )}
      <Sheet open={cancelling} onClose={() => setCancelling(false)} labelledBy="fl-cancel-title">
        <div className="sheet__header">
          <h2 id="fl-cancel-title" className="sheet__title">
            Cancel this activity?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setCancelling(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <ConsequenceList
            items={[
              { icon: "eventBusy", text: "It shows as cancelled to everyone going" },
              { icon: "lock", text: "Nobody can join or request any more" },
            ]}
          />
          <Button variant="destructive-solid" onClick={() => { setCancelling(false); dispatch({ type: "cancelActivity", id: a.id }); flash("Activity cancelled"); }}>
            Cancel activity
          </Button>
          <Button variant="quiet" data-autofocus onClick={() => setCancelling(false)}>
            Keep it
          </Button>
        </div>
      </Sheet>
      <Sheet open={blocking} onClose={() => setBlocking(false)} labelledBy="fl-blockhost-title">
        <div className="sheet__header">
          <h2 id="fl-blockhost-title" className="sheet__title">
            Block {host.name}?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setBlocking(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <ConsequenceList
            items={[
              { icon: "eyeOff", text: `You won’t see ${host.name} or their activities` },
              { icon: "message", text: "They can’t message you" },
              { icon: "info", text: `${host.name} isn’t told` },
            ]}
          />
          <Button variant="destructive-solid" onClick={() => { setBlocking(false); dispatch({ type: "end", id: a.host, reason: "blocked" }); go("activity"); }}>
            Block
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

/* Who's going (and requests, for hosts) -------------------------------- */

export function ActivityPeople({ go }) {
  const [state, dispatch] = useStore();
  const a = activityById(state, state.activeActivity);
  const [toast, flash] = useFlash();
  if (!a) return null;
  const me = participationOf(state, a);
  const going = goingCount(state, a);
  const full = a.capacity != null && going >= a.capacity;
  const named = a.attendees.map((id) => ({ id, ...PEOPLE[id] }));
  const hidden = a.othersGoing ?? 0;
  return (
    <Frame tone="page" top={<TopBar onBack={() => go("activity-detail")} title="Guests" />}>
      <div className="fl-stack fl-gap-lg fl-sections">
        <p className="fl-caption">
          {a.capacity ? `${going} of ${a.capacity} going` : `${going} going`} · {a.title}
        </p>
        {me === "host" && (
          <ListGroup title={`Requests (${a.requests?.length ?? 0})`} footnote={full ? "The activity is full. Raise the limit in Edit to approve more people." : "Approving adds them to the guest list. In this preview, nobody is notified."}>
            {a.requests?.length ? (
              a.requests.map((id) => (
                <li key={id} className="list-row">
                  <div className="list-row__hit">
                    <IdentityRow
                      name={PEOPLE[id].name}
                      verified={PEOPLE[id].verified}
                      caption="Wants to join"
                      trailing={
                        <span className="fl-row fl-row--tight">
                          <Button variant="secondary" size="sm" block={false} onClick={() => { dispatch({ type: "respondRequest", id: a.id, person: id, accept: false }); flash(`Declined ${PEOPLE[id].name}`); }}>
                            Decline
                          </Button>
                          <Button size="sm" block={false} disabled={full} onClick={() => { dispatch({ type: "respondRequest", id: a.id, person: id, accept: true }); flash(`${PEOPLE[id].name} is going`); }}>
                            Approve
                          </Button>
                        </span>
                      }
                    />
                  </div>
                </li>
              ))
            ) : (
              <li className="list-row">
                <div className="list-row__hit">
                  <span className="fl-caption">No requests waiting.</span>
                </div>
              </li>
            )}
          </ListGroup>
        )}
        <ListGroup title="Going" footnote={hidden ? `${hidden} more ${hidden === 1 ? "person is" : "people are"} going. Only first names are shown, and only to people who can see the activity.` : "Only first names are shown."}>
          {(me === "joined" || me === "host") && (
            <li className="list-row">
              <div className="list-row__hit">
                <IdentityRow name="You" caption={me === "host" ? "Host" : "Going"} />
              </div>
            </li>
          )}
          {a.host !== "me" && (
            <li className="list-row">
              <div className="list-row__hit">
                <IdentityRow name={PEOPLE[a.host]?.name} verified={PEOPLE[a.host]?.verified} caption="Host" />
              </div>
            </li>
          )}
          {named.map((p) => (
            <li key={p.id} className="list-row">
              <div className="list-row__hit">
                <IdentityRow name={p.name} verified={p.verified} caption="Going" />
              </div>
            </li>
          ))}
          {!named.length && me !== "joined" && me !== "host" && (
            <ListRow label="Nobody has shared their name yet" kind="info" />
          )}
        </ListGroup>
      </div>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}
