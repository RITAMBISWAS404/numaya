// Pure rules for activities, likes and profile readiness. No React, no storage: the screens and
// the unit tests use the same functions. All dates are measured against PROTOTYPE_NOW.
import { ACTIVITIES, ACTIVITY_CATEGORIES, AREAS, LIKES, OPENERS, PEOPLE, PROTOTYPE_NOW } from "./data.js";

const MIN = 60 * 1000;
const DAY = 24 * 60 * MIN;
const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export const areaOf = (id) => AREAS.find((a) => a.id === id) ?? null;
export const categoryLabel = (id) => ACTIVITY_CATEGORIES.find((c) => c.id === id)?.label ?? "Other";

/** Straight-line km from the chosen area to an activity, or null without an area. */
export function distanceKm(areaId, activity) {
  const area = areaOf(areaId);
  if (!area) return null;
  return Math.max(0.5, Math.round(Math.hypot(area.x - activity.x, area.y - activity.y) * 2) / 2);
}

const startOf = (a) => new Date(a.start);
const endOf = (a) => new Date(startOf(a).getTime() + (a.durationMin ?? 60) * MIN);
const midnight = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
const pad = (n) => String(n).padStart(2, "0");
export const timeOf = (d) => `${pad(d.getHours())}:${pad(d.getMinutes())}`;

/** "Today", "Tomorrow" or "Sat 31 Oct". */
export function dayLabel(d, now = PROTOTYPE_NOW) {
  const days = Math.round((midnight(d) - midnight(now)) / DAY);
  if (days === 0) return "Today";
  if (days === 1) return "Tomorrow";
  if (days === -1) return "Yesterday";
  return `${WEEKDAYS[d.getDay()]} ${d.getDate()} ${MONTHS[d.getMonth()]}`;
}

/** "Today, 19:30–22:00". */
export function whenLabel(a, now = PROTOTYPE_NOW) {
  return `${dayLabel(startOf(a), now)}, ${timeOf(startOf(a))}–${timeOf(endOf(a))}`;
}

/** upcoming | live | past | cancelled | draft */
export function phaseOf(a, now = PROTOTYPE_NOW) {
  if (a.status === "cancelled") return "cancelled";
  if (a.status === "draft") return "draft";
  if (endOf(a) <= now) return "past";
  if (startOf(a) <= now) return "live";
  return "upcoming";
}

/** Every activity: seeded ones plus the user's own (host "me"), keyed by id. */
export function allActivities(state) {
  const seeded = Object.fromEntries(Object.entries(ACTIVITIES).map(([id, a]) => [id, { id, ...a }]));
  const own = Object.fromEntries(Object.entries(state.own ?? {}).map(([id, a]) => [id, { id, ...a, host: "me" }]));
  return { ...seeded, ...own };
}

export const activityById = (state, id) => allActivities(state)[id] ?? null;

/** Head count including the user when they have joined. Requests and waitlist are not counted. */
export function goingCount(state, a) {
  const me = a.host === "me" || state.joins?.[a.id] === "joined" ? 1 : 0;
  return a.attendees.length + (a.othersGoing ?? 0) + me;
}

export const isFull = (state, a) => a.capacity != null && goingCount(state, a) >= a.capacity;

/** The user's relationship with an activity: host | joined | requested | waitlisted | none. */
export const participationOf = (state, a) => (a.host === "me" ? "host" : state.joins?.[a.id] ?? "none");

/** What joining does now: join | request | waitlist | unavailable. */
export function joinModeOf(state, a) {
  const phase = phaseOf(a);
  if (phase === "past" || phase === "cancelled" || phase === "draft") return "unavailable";
  if (isFull(state, a)) return "waitlist";
  return a.approval ? "request" : "join";
}

const hiddenHost = (state, a) => a.host !== "me" && Boolean(state.ended?.[a.host] && state.ended[a.host] !== "unmatched");

export const DATE_FILTERS = [
  { id: "any", label: "Any day" },
  { id: "today", label: "Today" },
  { id: "weekend", label: "This weekend" },
  { id: "week", label: "Next 7 days" },
];
export const DISTANCE_FILTERS = [
  { id: "any", label: "Any distance", km: Infinity },
  { id: "2", label: "Within 2 km", km: 2 },
  { id: "5", label: "Within 5 km", km: 5 },
  { id: "10", label: "Within 10 km", km: 10 },
];

function fitsDate(a, when, now = PROTOTYPE_NOW) {
  const start = startOf(a);
  const days = (midnight(start) - midnight(now)) / DAY;
  if (when === "today") return days === 0;
  if (when === "week") return days >= 0 && days < 7;
  if (when === "weekend") {
    const toSat = (6 - now.getDay() + 7) % 7;
    return days >= toSat && days <= toSat + 1;
  }
  return true;
}

/**
 * Explore: published, upcoming or live activities hosted by other people, not hidden by a report
 * or a block. Live first, then soonest, then nearest. filters: { category, when, distance }.
 */
export function exploreList(state, filters = {}) {
  const area = state.prefs?.area;
  const maxKm = DISTANCE_FILTERS.find((d) => d.id === filters.distance)?.km ?? Infinity;
  return Object.values(allActivities(state))
    .filter((a) => a.host !== "me" && !state.hiddenActivities?.includes(a.id) && !hiddenHost(state, a))
    .filter((a) => ["upcoming", "live"].includes(phaseOf(a)))
    .filter((a) => !filters.category || filters.category === "all" || a.category === filters.category)
    .filter((a) => fitsDate(a, filters.when ?? "any"))
    .filter((a) => maxKm === Infinity || (area && distanceKm(area, a) <= maxKm))
    .sort((x, y) => (phaseOf(y) === "live") - (phaseOf(x) === "live") || startOf(x) - startOf(y) || (distanceKm(area, x) ?? 0) - (distanceKm(area, y) ?? 0));
}

/** My activities, in four sections. Cancelled activities stay where the user would look for them. */
export function myActivities(state) {
  const all = Object.values(allActivities(state));
  const byStart = (x, y) => startOf(x) - startOf(y);
  const past = (a) => phaseOf(a) === "past";
  return {
    upcoming: all.filter((a) => a.host !== "me" && ["joined", "waitlisted"].includes(state.joins?.[a.id]) && !past(a)).sort(byStart),
    hosting: all.filter((a) => a.host === "me" && !past(a)).sort(byStart),
    requests: all.filter((a) => state.joins?.[a.id] === "requested" && !past(a)).sort(byStart),
    past: all.filter((a) => past(a) && (a.host === "me" || state.joins?.[a.id] === "joined")).sort((x, y) => byStart(y, x)),
  };
}

/** Validation for the create / edit form. Returns { field: message }. */
export function validateActivity(d, now = PROTOTYPE_NOW) {
  const e = {};
  if (!d.title?.trim()) e.title = "Give your activity a name.";
  else if (d.title.trim().length > 80) e.title = "Keep the name under 80 characters.";
  if (!d.category) e.category = "Pick a category.";
  if (!d.venue?.trim()) e.venue = "Add a public place to meet.";
  if (!d.date) e.date = "Pick a date.";
  if (!d.time) e.time = "Pick a start time.";
  if (d.date && d.time && new Date(`${d.date}T${d.time}`) <= now) e.date = "Pick a date and time in the future.";
  if (d.capacity !== "" && d.capacity != null) {
    const n = Number(d.capacity);
    if (!Number.isInteger(n) || n < 2 || n > 50) e.capacity = "Between 2 and 50 people, or leave empty for no limit.";
  }
  return e;
}

/* Likes ---------------------------------------------------------------- */

export const LIKE_FILTERS = [
  { id: "all", label: "All" },
  { id: "activity", label: "Activity" },
  { id: "new", label: "New" },
  { id: "nearby", label: "Nearby" },
];

/** Likes still waiting for a response, plus those already matched (shown as handled). */
export function likesList(state, filter = "all", now = PROTOTYPE_NOW) {
  return LIKES.filter((l) => !state.likesHandled?.[l.person] && !(state.ended?.[l.person]))
    .map((l) => ({ ...l, matched: state.matches.includes(l.person), isNew: now - new Date(l.at) < DAY, km: PEOPLE[l.person].distanceKm }))
    .filter((l) => filter === "all" || (filter === "activity" && l.via === "activity") || (filter === "new" && l.isNew && !l.matched) || (filter === "nearby" && l.km != null && l.km <= 5))
    .sort((a, b) => a.matched - b.matched || new Date(b.at) - new Date(a.at));
}

/** Pending likes (not handled, not matched) for the tab badge. */
export const pendingLikes = (state) => likesList(state).filter((l) => !l.matched).length;

/* Messages -------------------------------------------------------------- */

/** Unread incoming messages in a thread. */
export function unreadCount(state, id) {
  const thread = state.threads[id] ?? [];
  const read = state.read?.[id] ?? 0;
  return thread.slice(read).filter((m) => m.from === "them").length;
}

/** The answered prompts a profile shows, at most three, in order. A profile holds one `prompt` today;
    an optional `prompts` list (whose first entry is that prompt) is shown in full. Unanswered entries
    are skipped, so nothing is shown that the person did not write. */
export const MAX_PROMPTS = 3;
export function promptsOf(profile) {
  const list = Array.isArray(profile?.prompts) && profile.prompts.length ? profile.prompts : [profile?.prompt];
  return list.filter((p) => p?.q && p?.a?.trim()).slice(0, MAX_PROMPTS);
}

/** Suggested first messages for a person: their prompt first, then shared interests, then generic. */
export function openersFor(id) {
  const p = PEOPLE[id];
  const list = [];
  if (p?.prompt) list.push(`I liked your answer to “${p.prompt.q}”. What’s the story?`);
  for (const s of p?.shared ?? []) list.push(`We both like ${s.toLowerCase()}. What got you into it?`);
  for (const o of OPENERS) if (list.length < 3) list.push(o);
  return list.slice(0, 3);
}

/* Profile readiness ---------------------------------------------------- */

/** The readiness rules, in display order. Each returns { points, max, done, hint, action }. */
export function readiness(profile) {
  const photos = profile.photos?.length ?? 0;
  const interests = profile.interests?.length ?? 0;
  const bio = profile.bio?.trim() ?? "";
  const basics = [profile.name?.trim(), profile.year?.length === 4, profile.gender, profile.looking?.length].filter(Boolean).length;
  const items = [
    { id: "basics", label: "The basics", points: basics * 5, max: 20, detail: `${basics} of 4 filled in`, hint: "Name, birth year, gender and what you’re looking for help people know who they’re meeting.", action: "Finish the basics", focus: "name" },
    { id: "photos", label: "Photos", points: Math.min(photos, 4) * 7.5, max: 30, detail: `${photos} of 4 recommended`, hint: "Add another photo to give people more to learn about you.", action: "Add a photo", focus: "photos" },
    { id: "interests", label: "Interests", points: Math.min(interests, 3) * 5, max: 15, detail: `${interests} added`, hint: "Add a few interests to help surface shared topics.", action: "Add interests", focus: "interests" },
    { id: "bio", label: "Bio", points: bio.length >= 40 ? 20 : bio ? 10 : 0, max: 20, detail: bio ? `${bio.length} characters` : "Not written yet", hint: bio ? "A couple more sentences make your bio easier to reply to." : "Write a short bio so people know what you’re about.", action: bio ? "Expand your bio" : "Write a bio", focus: "bio" },
    { id: "prompt", label: "Prompt", points: (profile.prompt?.a?.trim().length ?? 0) >= 10 ? 15 : 0, max: 15, detail: profile.prompt?.a ? "Answered" : "Not answered", hint: "Answer a prompt to help start conversations.", action: "Answer a prompt", focus: "prompt" },
  ].map((i) => ({ ...i, done: i.points >= i.max }));
  const score = Math.round(items.reduce((n, i) => n + i.points, 0));
  const recommendations = items.filter((i) => !i.done).sort((a, b) => b.max - b.points - (a.max - a.points)).slice(0, 3);
  return { score, items, recommendations };
}

/* Presentation mapping shared by cards, details and lists ------------- */

export const categoryIcon = (id) => ACTIVITY_CATEGORIES.find((c) => c.id === id)?.icon ?? "event";
export const categoryMark = (id) => ACTIVITY_CATEGORIES.find((c) => c.id === id)?.mark;

/** Display name and trust flag for an activity host. */
export function hostOf(a) {
  if (a.host === "me") return { name: "You", verified: false, me: true };
  const p = PEOPLE[a.host];
  return { name: p?.name ?? "Someone", verified: Boolean(p?.verified), me: false };
}

/** "Victoria Park, Crown Gate East · Hackney · about 2 km". Venue and area only, never a precise location. */
export function placeLabel(state, a) {
  const km = distanceKm(state.prefs?.area, a);
  return [a.venue, areaOf(a.area)?.name, km != null ? `about ${km} km` : null].filter(Boolean).join(" · ");
}

/** First names of the identified attendees (the user first when going). */
export function attendeeNames(state, a) {
  const me = participationOf(state, a);
  const names = a.attendees.map((id) => PEOPLE[id]?.name).filter(Boolean);
  return me === "joined" || me === "host" ? ["You", ...names] : names;
}

/** Props for ActivityCard. */
export function cardProps(state, a) {
  const phase = phaseOf(a);
  return {
    id: a.id,
    title: a.title,
    category: categoryLabel(a.category),
    categoryIcon: categoryIcon(a.category),
    categoryMark: categoryMark(a.category),
    host: hostOf(a),
    when: whenLabel(a),
    place: placeLabel(state, a),
    going: goingCount(state, a),
    capacity: a.capacity,
    attendees: attendeeNames(state, a),
    status: phase === "upcoming" ? (isFull(state, a) ? "full" : undefined) : phase,
    participation: participationOf(state, a) === "none" ? undefined : participationOf(state, a),
    tone: a.tone,
  };
}
