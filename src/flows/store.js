// Session-only preview state shared by the flow screens. Pure reducer, no backend.
import { createContext, createElement, useContext, useReducer } from "react";
import { PEOPLE } from "./data.js";

export const initialState = {
  profile: {
    name: "Alex",
    year: "1995",
    gender: "man",
    looking: ["long-term"],
    interests: ["Natural wine", "Jazz", "Cooking"],
    photos: [
      { id: 1, tone: 0 },
      { id: 2, tone: 1 },
      { id: 3, tone: 2 },
    ],
  },
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

/** Discovery queue: people not yet decided on and not ended. */
export const discoveryQueue = (state) =>
  Object.keys(PEOPLE).filter(
    (id) => PEOPLE[id].prompt && !state.seen.includes(id) && !state.matches.includes(id) && isActive(state, id),
  );

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

const StoreContext = createContext(null);

export function StoreProvider({ children }) {
  const value = useReducer(reducer, initialState);
  return createElement(StoreContext.Provider, { value }, children);
}

export const useStore = () => useContext(StoreContext);
