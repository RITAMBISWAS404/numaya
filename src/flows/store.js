// Session-only preview state shared by the flow screens. Pure reducer, no backend.
import { createContext, createElement, useContext, useEffect, useReducer } from "react";
import { PEOPLE } from "./data.js";
import { activityById, isFull, unreadCount } from "./model.js";

export const initialState = {
  profile: {
    name: "Alex",
    year: "1995",
    gender: "man",
    looking: ["long-term"],
    interests: ["Natural wine", "Jazz", "Cooking"],
    prompt: { q: "A perfect first date", a: "A record shop, a long walk, and nowhere to be after." },
    bio: "",
    orientation: "",
    photos: [
      { id: 1, tone: 0 },
      { id: 2, tone: 1 },
      { id: 3, tone: 2 },
    ],
  },
  prefs: { age: [27, 38], distance: 15, snooze: false, messages: true, likes: true, activity: true, area: "hackney", simulateErrors: false },
  setupDone: [], // profile-setup steps finished with their next button: basics, interests, photos
  seen: [], // discovery ids already liked or passed
  matches: ["rafa", "priya", "jo"], // matched people, newest last
  lastMatch: null, // id shown on the match screen
  threads: {
    priya: [
      { id: 1, from: "me", text: "That bakery on Columbia Road, right?", status: "delivered" },
      { id: 2, from: "them", text: "That bakery was unreal. Thank you!" },
    ],
    rafa: [
      { id: 1, from: "them", text: "Good to meet you at the roast club! Still thinking about those potatoes." },
      { id: 2, from: "me", text: "Same. Board games next week?", status: "delivered" },
    ],
  },
  read: { priya: 1, rafa: 2 }, // messages read per thread (Priya's last one is unread)
  ended: {}, // id → "unmatched" | "blocked" | "reported"
  activeChat: "priya",
  lastPass: null, // the last person passed on Home, for one-step undo
  // Activities: my participation, my own (hosted) activities and what I hid by reporting.
  joins: { "a-run": "joined", "a-roast": "joined" }, // id → "joined" | "requested" | "waitlisted"
  own: {
    "m-sourdough": {
      title: "Sourdough starter swap", category: "food", start: "2026-10-28T18:30", durationMin: 90,
      venue: "Hackney City Farm café", area: "hackney", x: 1, y: -0.5, capacity: 8, approval: true, visibility: "public",
      tone: 2, status: "published", attendees: ["priya"], othersGoing: 0, requests: ["jo", "kemi"],
      description: "Bring a jar of starter (or an empty jar) and swap tips. Coffee on me.",
    },
  },
  hiddenActivities: [],
  activeActivity: "a-jazz",
  activityBack: "activity", // where the details screen returns to
  editingActivity: null, // own activity id being edited, or null for a new one
  likesHandled: {}, // person → "liked" | "passed"
  activeLike: "maya",
  reports: [], // { id, target: "person" | "activity", targetId, reason, details, at } (this device only)
  social: { instagram: false, spotify: false }, // simulated connections
  plan: "free",
  editFocus: null, // the Edit profile field a readiness recommendation opens
};

export function reducer(state, action) {
  switch (action.type) {
    case "setupDone":
      return state.setupDone.includes(action.step) ? state : { ...state, setupDone: [...state.setupDone, action.step] };
    case "profile":
      return { ...state, profile: { ...state.profile, ...action.patch } };
    case "decide": {
      const seen = [...state.seen, action.id];
      const isMatch = action.liked && PEOPLE[action.id]?.likesYou && !state.matches.includes(action.id);
      const likesHandled = action.liked && PEOPLE[action.id]?.likesYou ? { ...state.likesHandled, [action.id]: "liked" } : state.likesHandled;
      return { ...state, seen, likesHandled, lastPass: action.liked ? null : action.id, matches: isMatch ? [...state.matches, action.id] : state.matches, lastMatch: isMatch ? action.id : state.lastMatch };
    }
    case "undo":
      return state.lastPass ? { ...state, seen: state.seen.filter((id) => id !== state.lastPass), lastPass: null } : state;
    case "likeBack": {
      const liked = action.liked;
      const likesHandled = { ...state.likesHandled, [action.id]: liked ? "liked" : "passed" };
      const seen = state.seen.includes(action.id) ? state.seen : [...state.seen, action.id];
      if (!liked) return { ...state, likesHandled, seen };
      const matches = state.matches.includes(action.id) ? state.matches : [...state.matches, action.id];
      return { ...state, likesHandled, seen, matches, lastMatch: action.id };
    }
    case "openLike":
      return { ...state, activeLike: action.id };
    case "join": {
      const a = activityById(state, action.id);
      if (!a || a.host === "me" || state.joins[action.id]) return state; // no duplicate joins
      const mode = isFull(state, a) ? "waitlisted" : a.approval ? "requested" : "joined";
      return { ...state, joins: { ...state.joins, [action.id]: mode } };
    }
    case "leave": {
      const { [action.id]: _, ...joins } = state.joins;
      return { ...state, joins };
    }
    case "openActivity":
      return { ...state, activeActivity: action.id, activityBack: action.from ?? "activity" };
    case "editActivity":
      return { ...state, editingActivity: action.id ?? null };
    case "saveActivity": {
      const prev = state.own[action.id];
      const record = { attendees: [], othersGoing: 0, requests: [], ...prev, ...action.record };
      return { ...state, own: { ...state.own, [action.id]: record }, activeActivity: action.id, editingActivity: null };
    }
    case "cancelActivity":
      return state.own[action.id] ? { ...state, own: { ...state.own, [action.id]: { ...state.own[action.id], status: "cancelled" } } } : state;
    case "deleteDraft": {
      const { [action.id]: _, ...own } = state.own;
      return state.own[action.id]?.status === "draft" ? { ...state, own } : state;
    }
    case "respondRequest": {
      const a = state.own[action.id];
      if (!a?.requests.includes(action.person)) return state;
      const requests = a.requests.filter((p) => p !== action.person);
      const attendees = action.accept ? [...a.attendees, action.person] : a.attendees;
      return { ...state, own: { ...state.own, [action.id]: { ...a, requests, attendees } } };
    }
    case "report": {
      const report = { id: `r${state.reports.length + 1}`, target: action.target, targetId: action.targetId, reason: action.reason, details: action.details ?? "", at: action.at };
      const next = { ...state, reports: [...state.reports, report] };
      if (action.target === "activity") return { ...next, hiddenActivities: [...state.hiddenActivities, action.targetId] };
      return action.block ? { ...next, ended: { ...state.ended, [action.targetId]: "reported" } } : next;
    }
    case "unblock": {
      // Unblocking never restores a match or messages: the person simply stops being hidden.
      const { [action.id]: _, ...ended } = state.ended;
      return { ...state, ended: { ...ended, [action.id]: "unmatched" }, matches: state.matches.filter((m) => m !== action.id) };
    }
    case "social":
      return { ...state, social: { ...state.social, [action.key]: action.value } };
    case "plan":
      return { ...state, plan: action.plan };
    case "editFocus":
      return { ...state, editFocus: action.field ?? null };
    case "prefs":
      return { ...state, prefs: { ...state.prefs, ...action.patch } };
    case "broaden":
      return { ...state, prefs: { ...state.prefs, age: [...BROAD.age], distance: BROAD.distance } };
    case "resetDiscovery":
      return { ...state, seen: [] };
    case "openChat":
      return { ...state, activeChat: action.id, read: { ...state.read, [action.id]: state.threads[action.id]?.length ?? 0 } };
    case "send": {
      const thread = state.threads[action.id] ?? [];
      const msg = { id: action.msgId, from: "me", text: action.text, status: "sending" };
      return { ...state, activeChat: action.id, threads: { ...state.threads, [action.id]: [...thread, msg] }, read: { ...state.read, [action.id]: thread.length + 1 } };
    }
    case "delivered":
      return {
        ...state,
        threads: {
          ...state.threads,
          [action.id]: state.threads[action.id].map((m) => (m.id === action.msgId ? { ...m, status: "delivered" } : m)),
        },
      };
    case "end":
      return { ...state, ended: { ...state.ended, [action.id]: action.reason } };
    case "reset":
      return initialState;
    default:
      return state;
  }
}

/** Whether a person can be messaged or shown (not blocked or unmatched). */
export const isActive = (state, id) => !state.ended[id];

export const BROAD = { age: [18, 70], distance: 100 };

/** Whether a person fits the age and distance preferences. */
export const fitsPrefs = (prefs, person) =>
  person.age >= prefs.age[0] && person.age <= prefs.age[1] && person.distanceKm <= prefs.distance;

/** Everyone who could appear in Discover: has a profile, undecided, not matched, not ended. */
const candidates = (state) =>
  Object.keys(PEOPLE).filter(
    (id) => PEOPLE[id].prompt && !state.seen.includes(id) && !state.matches.includes(id) && isActive(state, id),
  );

/** Discovery queue: candidates that fit the current preferences. */
export const discoveryQueue = (state) => candidates(state).filter((id) => fitsPrefs(state.prefs, PEOPLE[id]));

/** Candidates hidden only by the current filters (used by the empty state). */
export const hiddenByFilters = (state) => candidates(state).length - discoveryQueue(state).length;

/** Matched people with no messages yet (the "new matches" queue). */
export const newMatches = (state) => state.matches.filter((id) => isActive(state, id) && !state.threads[id]?.length);

/** Inbox rows: active matches with at least one message, most recent first. */
export const conversations = (state) =>
  state.matches
    .filter((id) => isActive(state, id) && state.threads[id]?.length)
    .reverse()
    .map((id) => {
      const thread = state.threads[id];
      const last = thread[thread.length - 1];
      return {
        id,
        name: PEOPLE[id].name,
        verified: PEOPLE[id].verified,
        preview: `${last.from === "me" ? "You: " : ""}${last.text}`,
        text: thread.map((m) => m.text).join(" "),
        unread: unreadCount(state, id),
        yourMove: last.from === "them",
        time: last.from === "me" && last.id > 1e9 ? "now" : PEOPLE[id].lastTime,
      };
    });

/* Session persistence: localStorage when available, otherwise in-memory only. */
export const STORAGE_KEY = "numaya.preview.v1";

export function loadState(storage = safeStorage()) {
  try {
    const raw = storage?.getItem(STORAGE_KEY);
    if (!raw) return initialState;
    const saved = JSON.parse(raw);
    if (saved?.version !== 1 || typeof saved.state !== "object") return initialState;
    // Merge so state saved by an older preview gains any new fields.
    const s = saved.state;
    // A send interrupted by a reload has finished from the user's point of view.
    const threads = Object.fromEntries(
      Object.entries(s.threads ?? {}).map(([id, msgs]) => [id, msgs.map((m) => (m.status === "sending" ? { ...m, status: "delivered" } : m))]),
    );
    return {
      ...initialState,
      ...s,
      threads,
      profile: { ...initialState.profile, ...s.profile },
      prefs: { ...initialState.prefs, ...s.prefs },
      social: { ...initialState.social, ...s.social },
    };
  } catch {
    return initialState;
  }
}

export function saveState(state, storage = safeStorage()) {
  try {
    if (state === initialState) storage?.removeItem(STORAGE_KEY);
    else storage?.setItem(STORAGE_KEY, JSON.stringify({ version: 1, state }));
  } catch {
    // Storage full or blocked: the preview keeps working for this tab.
  }
}

function safeStorage() {
  try {
    return typeof window !== "undefined" ? window.localStorage : null;
  } catch {
    return null;
  }
}

const StoreContext = createContext(null);

export function StoreProvider({ children }) {
  const value = useReducer(reducer, undefined, () => loadState());
  const [state] = value;
  useEffect(() => saveState(state), [state]);
  return createElement(StoreContext.Provider, { value }, children);
}

export const useStore = () => useContext(StoreContext);
