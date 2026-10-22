// Session-only preview state shared by the flow screens. Pure reducer, no backend.
import { createContext, createElement, useContext, useEffect, useReducer } from "react";
import { PEOPLE } from "./data.js";

export const initialState = {
  profile: {
    name: "Alex",
    year: "1995",
    gender: "man",
    looking: ["long-term"],
    interests: ["Natural wine", "Jazz", "Cooking"],
    prompt: { q: "A perfect first date", a: "A record shop, a long walk, and nowhere to be after." },
    photos: [
      { id: 1, tone: 0 },
      { id: 2, tone: 1 },
      { id: 3, tone: 2 },
    ],
  },
  prefs: { age: [27, 38], distance: 15, snooze: false, messages: true, likes: true },
  seen: [], // discovery ids already liked or passed
  matches: ["priya", "jo"], // matched people, newest last
  lastMatch: null, // id shown on the match screen
  threads: {
    priya: [
      { id: 1, from: "me", text: "That bakery on Columbia Road, right?", status: "delivered" },
      { id: 2, from: "them", text: "That bakery was unreal. Thank you!" },
    ],
  },
  ended: {}, // id → "blocked" | "unmatched"
  activeChat: "priya",
};

export function reducer(state, action) {
  switch (action.type) {
    case "profile":
      return { ...state, profile: { ...state.profile, ...action.patch } };
    case "decide": {
      const seen = [...state.seen, action.id];
      const isMatch = action.liked && PEOPLE[action.id]?.likesYou && !state.matches.includes(action.id);
      return { ...state, seen, matches: isMatch ? [...state.matches, action.id] : state.matches, lastMatch: isMatch ? action.id : state.lastMatch };
    }
    case "prefs":
      return { ...state, prefs: { ...state.prefs, ...action.patch } };
    case "broaden":
      return { ...state, prefs: { ...state.prefs, age: [...BROAD.age], distance: BROAD.distance } };
    case "resetDiscovery":
      return { ...state, seen: [] };
    case "openChat":
      return { ...state, activeChat: action.id };
    case "send": {
      const thread = state.threads[action.id] ?? [];
      const msg = { id: action.msgId, from: "me", text: action.text, status: "sending" };
      return { ...state, activeChat: action.id, threads: { ...state.threads, [action.id]: [...thread, msg] } };
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
