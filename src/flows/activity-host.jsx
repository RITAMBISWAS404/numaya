// Activity hosting and lists: create / edit (publish or draft) and My activities.
import { useState } from "react";
import {
  ActivityCard,
  Button,
  ConsequenceList,
  EmptyState,
  FilterChips,
  IconButton,
  ListGroup,
  ListRow,
  OptionCards,
  ResultPanel,
  Sheet,
  Switch,
  TextArea,
  TextField,
  TopBar,
} from "../design-system/index.js";
import { ACTIVITY_CATEGORIES, AREAS, PROTOTYPE_NOW } from "./data.js";
import { ActivityTabs } from "./activity.jsx";
import { Frame } from "./frame.jsx";
import { activityById, areaOf, cardProps, categoryLabel, myActivities, validateActivity } from "./model.js";
import { useStore } from "./store.js";

const DURATIONS = [
  { id: "60", label: "1 hour" },
  { id: "90", label: "1.5 hours" },
  { id: "120", label: "2 hours" },
  { id: "180", label: "3 hours" },
];
const pad = (n) => String(n).padStart(2, "0");
const isoDate = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;

/** Form values from a stored record (or a blank new activity). */
function toDraft(a, area) {
  if (!a) return { title: "", category: "", venue: "", area: area ?? "hackney", date: "", time: "", duration: "120", description: "", visibility: "public", capacity: "", approval: false };
  const [date, time] = a.start.split("T");
  return { title: a.title, category: a.category, venue: a.venue, area: a.area, date, time, duration: String(a.durationMin), description: a.description ?? "", visibility: a.visibility, capacity: a.capacity ?? "", approval: a.approval };
}

/** Stored record from form values. Coordinates come from the chosen area (no precise location). */
function toRecord(d, status) {
  const area = areaOf(d.area) ?? AREAS[0];
  return {
    title: d.title.trim(),
    category: d.category || "food",
    venue: d.venue.trim(),
    area: area.id,
    x: area.x,
    y: area.y,
    start: `${d.date || isoDate(PROTOTYPE_NOW)}T${d.time || "12:00"}`,
    durationMin: Number(d.duration),
    description: d.description.trim(),
    visibility: d.visibility,
    capacity: d.capacity === "" ? null : Number(d.capacity),
    approval: d.approval,
    tone: null,
    status,
  };
}

export function ActivityForm({ go }) {
  const [state, dispatch] = useStore();
  const editing = state.editingActivity ? activityById(state, state.editingActivity) : null;
  const [draft, setDraft] = useState(() => toDraft(editing, state.prefs.area));
  const [initial] = useState(draft);
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(null);
  const [done, setDone] = useState(null);
  const [picker, setPicker] = useState(null); // "category" | "area"
  const [discarding, setDiscarding] = useState(false);
  const set = (patch) => {
    setDraft((d) => ({ ...d, ...patch }));
    // Clear a field's error as soon as it changes.
    setErrors((e) => Object.fromEntries(Object.entries(e).filter(([k]) => !(k in patch) && !(k === "date" && "time" in patch))));
  };
  const dirty = JSON.stringify(draft) !== JSON.stringify(initial);
  const wasPublished = editing?.status === "published";
  const leave = () => go(editing ? "activity-detail" : "activity");

  const submit = (status) => {
    const found = status === "draft" ? (draft.title.trim() ? {} : { title: "Give your draft a name so you can find it." }) : validateActivity(draft);
    setErrors(found);
    if (Object.keys(found).length) return;
    setSaving(status);
    setTimeout(() => {
      const id = editing?.id ?? `m-${Object.keys(state.own).length + 1}-${draft.title.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 24)}`;
      dispatch({ type: "saveActivity", id, record: toRecord(draft, status) });
      setSaving(null);
      setDone({ id, status });
    }, 600);
  };

  if (done) {
    return (
      <Frame tone="page" top={<TopBar onBack={() => go("my-activities")} />}>
        <div className="fl-center fl-fill">
          <ResultPanel
            tone="success"
            icon={done.status === "draft" ? "draft" : "event"}
            title={done.status === "draft" ? "Draft saved" : wasPublished ? "Changes saved" : "Your activity is published"}
            footer={
              <div className="fl-stack fl-stack--full">
                <Button onClick={() => { dispatch({ type: "openActivity", id: done.id, from: "my-activities" }); go("activity-detail"); }}>View activity</Button>
                <Button variant="quiet" onClick={() => go("my-activities")}>
                  Go to My activities
                </Button>
              </div>
            }
          >
            <p>{done.status === "draft" ? "Only you can see drafts. Publish it from My activities when you’re ready." : "People nearby can find it in Explore. Requests and guests show under Hosting."}</p>
          </ResultPanel>
        </div>
      </Frame>
    );
  }

  return (
    <Frame
      tone="page"
      top={<TopBar onBack={() => (dirty ? setDiscarding(true) : leave())} title={editing ? "Edit activity" : "New activity"} />}
      footer={
        <div className="fl-stack fl-stack--full">
          <Button loading={saving === "published"} disabled={Boolean(saving)} onClick={() => submit("published")}>
            {wasPublished ? "Save changes" : "Publish"}
          </Button>
          {!wasPublished && (
            <Button variant="quiet" loading={saving === "draft"} disabled={Boolean(saving)} onClick={() => submit("draft")}>
              Save as draft
            </Button>
          )}
        </div>
      }
    >
      <form className="fl-stack fl-gap-lg fl-sections" noValidate onSubmit={(e) => { e.preventDefault(); submit("published"); }}>
        {Object.keys(errors).length > 0 && (
          <p className="fl-form-error" role="alert">
            Check the {Object.keys(errors).length === 1 ? "highlighted field" : `${Object.keys(errors).length} highlighted fields`} before publishing.
          </p>
        )}
        <TextField label="Activity name" placeholder="Sunday sea swim" value={draft.title} maxLength={80} error={errors.title} onChange={(e) => set({ title: e.target.value })} />
        <ListGroup title="Category">
          <ListRow label={draft.category ? categoryLabel(draft.category) : "Choose a category"} kind="value" onPress={() => setPicker("category")} />
        </ListGroup>
        {errors.category && (
          <p className="field__note is-error" role="alert">
            {errors.category}
          </p>
        )}
        <TextField label="Place or venue" placeholder="The café by the lido" hint={errors.venue ? undefined : "A public place. Never add a home address."} error={errors.venue} value={draft.venue} maxLength={80} onChange={(e) => set({ venue: e.target.value })} />
        <ListGroup title="Area" footnote="Shown with the venue so people know roughly where it is.">
          <ListRow label={areaOf(draft.area)?.name ?? "Choose an area"} kind="value" onPress={() => setPicker("area")} />
        </ListGroup>
        <div className="fl-form-pair">
          <TextField label="Date" type="date" min={isoDate(PROTOTYPE_NOW)} value={draft.date} error={errors.date} onChange={(e) => set({ date: e.target.value })} />
          <TextField label="Start time" type="time" value={draft.time} error={errors.time} onChange={(e) => set({ time: e.target.value })} />
        </div>
        <div className="fl-stack fl-gap-sm">
          <p className="field__label">How long?</p>
          <FilterChips label="Duration" value={draft.duration} onChange={(duration) => set({ duration })} options={DURATIONS} />
        </div>
        <TextArea label="Description (optional)" value={draft.description} maxLength={500} rows={4} onChange={(e) => set({ description: e.target.value })} />
        <OptionCards
          legend="Who can see it"
          value={draft.visibility}
          onChange={(visibility) => set({ visibility })}
          options={[
            { value: "public", label: "Public", description: "Anyone on Numaya can find it in Explore" },
            { value: "private", label: "Private", description: "Only people you invite can find it" },
          ]}
        />
        <TextField label="Guest limit (optional)" type="number" inputMode="numeric" min={2} max={50} placeholder="No limit" hint={errors.capacity ? undefined : "Including you. When it’s full, people can join a waitlist."} error={errors.capacity} value={draft.capacity} onChange={(e) => set({ capacity: e.target.value })} />
        <ListGroup>
          <li className="list-row">
            <div className="list-row__hit">
              <Switch label="Approve each request" description={draft.approval ? "People ask to join; you approve them" : "People join straight away"} checked={draft.approval} onChange={(approval) => set({ approval })} />
            </div>
          </li>
        </ListGroup>
      </form>

      <Sheet open={picker === "category"} onClose={() => setPicker(null)} labelledBy="fl-cat-title">
        <div className="sheet__header">
          <h2 id="fl-cat-title" className="sheet__title">
            Category
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setPicker(null)} />
        </div>
        <OptionCards legend="Category" value={draft.category} onChange={(category) => { set({ category }); setPicker(null); }} options={ACTIVITY_CATEGORIES.map((c) => ({ value: c.id, label: c.label }))} />
      </Sheet>
      <Sheet open={picker === "area"} onClose={() => setPicker(null)} labelledBy="fl-farea-title">
        <div className="sheet__header">
          <h2 id="fl-farea-title" className="sheet__title">
            Area
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setPicker(null)} />
        </div>
        <OptionCards legend="Area" value={draft.area} onChange={(area) => { set({ area }); setPicker(null); }} options={AREAS.map((a) => ({ value: a.id, label: a.name }))} />
      </Sheet>
      <Sheet open={discarding} onClose={() => setDiscarding(false)} labelledBy="fl-discard-title">
        <div className="sheet__header">
          <h2 id="fl-discard-title" className="sheet__title">
            Discard your changes?
          </h2>
          <IconButton icon="close" label="Close" variant="flat" size="sm" onClick={() => setDiscarding(false)} />
        </div>
        <div className="fl-stack fl-sheet-body">
          <ConsequenceList items={[{ icon: "trash", text: "What you’ve entered won’t be saved" }]} />
          <Button variant="destructive-solid" onClick={() => { setDiscarding(false); dispatch({ type: "editActivity", id: null }); leave(); }}>
            Discard
          </Button>
          <Button variant="quiet" data-autofocus onClick={() => setDiscarding(false)}>
            Keep editing
          </Button>
        </div>
      </Sheet>
    </Frame>
  );
}

/* My activities -------------------------------------------------------- */

const SECTIONS = [
  { id: "upcoming", label: "Upcoming", empty: ["Nothing coming up", "Activities you join show here.", "Explore activities"] },
  { id: "hosting", label: "Hosting", empty: ["You’re not hosting anything", "Create an activity and people nearby can join.", "Create an activity"] },
  { id: "requests", label: "Requests", empty: ["No requests waiting", "When you ask to join an activity that needs approval, it shows here.", "Explore activities"] },
  { id: "past", label: "Past", empty: ["No past activities", "Activities you went to or hosted stay here afterwards.", "Explore activities"] },
];

export function MyActivities({ go }) {
  const [state, dispatch] = useStore();
  const [section, setSection] = useState("upcoming");
  const lists = myActivities(state);
  const list = lists[section];
  const meta = SECTIONS.find((s) => s.id === section);
  const create = () => {
    dispatch({ type: "editActivity", id: null });
    go("activity-form");
  };
  return (
    <Frame
      tone="page"
      top={<TopBar largeTitle="Activity" actions={<IconButton icon="plus" label="Create an activity" variant="floating" size="sm" onClick={create} />} />}
      tab="activity"
      go={go}
    >
      <div className="fl-stack fl-gap-md fl-sections">
        <ActivityTabs current="my-activities" go={go} />
        <FilterChips label="Show" value={section} onChange={setSection} options={SECTIONS.map((s) => ({ id: s.id, label: s.label, count: lists[s.id].length }))} />
        {list.length ? (
          <ul className="fl-card-list">
            {list.map((a) => (
              <li key={a.id}>
                <ActivityCard
                  {...cardProps(state, a)}
                  compact
                  onOpen={() => {
                    dispatch({ type: "openActivity", id: a.id, from: "my-activities" });
                    go("activity-detail");
                  }}
                />
                {section === "hosting" && a.requests?.length > 0 && <p className="fl-caption fl-card-note">{a.requests.length} {a.requests.length === 1 ? "request" : "requests"} waiting</p>}
                {(a.status === "draft" || a.status === "cancelled" || state.joins[a.id] === "waitlisted") && (
                  <p className="fl-caption fl-card-note">{a.status === "draft" ? "Draft · only you can see it" : a.status === "cancelled" ? "Cancelled" : "On the waitlist"}</p>
                )}
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState icon="event" title={meta.empty[0]} action={meta.empty[2]} onAction={() => (section === "hosting" ? create() : go("activity"))}>
            {meta.empty[1]}
          </EmptyState>
        )}
      </div>
    </Frame>
  );
}
