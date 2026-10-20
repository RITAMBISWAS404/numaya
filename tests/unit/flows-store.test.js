import { describe, expect, it } from "vitest";
import { conversations, discoveryQueue, initialState, newMatches, reducer } from "../../src/flows/store.js";

const run = (...actions) => actions.reduce(reducer, initialState);

describe("flow preview store", () => {
  it("liking someone who likes you creates a match; passing does not", () => {
    const s = run({ type: "decide", id: "maya", liked: true }, { type: "decide", id: "sam", liked: true });
    expect(s.lastMatch).toBe("maya");
    expect(s.matches).toContain("maya");
    expect(s.matches).not.toContain("sam");
    expect(discoveryQueue(s)).toEqual(["noor"]);
  });

  it("sending opens the conversation and keeps the message", () => {
    const s = run({ type: "decide", id: "maya", liked: true }, { type: "send", id: "maya", text: "Hi", msgId: 1e12 });
    expect(s.activeChat).toBe("maya");
    expect(s.threads.maya.at(-1)).toMatchObject({ from: "me", text: "Hi", status: "sending" });
    expect(conversations(s)[0]).toMatchObject({ id: "maya", preview: "You: Hi" });
    expect(newMatches(s)).toEqual(["jo"]);
  });

  it("blocking or unmatching removes the person everywhere", () => {
    const s = run({ type: "end", id: "priya", reason: "blocked" }, { type: "end", id: "jo", reason: "unmatched" });
    expect(conversations(s)).toEqual([]);
    expect(newMatches(s)).toEqual([]);
  });

  it("profile edits merge and reset restores the start", () => {
    const s = run({ type: "profile", patch: { name: "Jordan" } });
    expect(s.profile).toMatchObject({ name: "Jordan", year: "1995" });
    expect(reducer(s, { type: "reset" })).toBe(initialState);
  });
});

import { BROAD, STORAGE_KEY, hiddenByFilters, loadState, saveState } from "../../src/flows/store.js";

const memory = () => {
  const m = new Map();
  return { getItem: (k) => m.get(k) ?? null, setItem: (k, v) => m.set(k, v), removeItem: (k) => m.delete(k), map: m };
};

describe("discovery filters", () => {
  it("default age and distance hide people outside them", () => {
    expect(discoveryQueue(initialState)).toEqual(["maya", "sam", "noor"]);
    expect(hiddenByFilters(initialState)).toBe(3);
  });

  it("narrow filters can empty the queue; broaden restores everyone", () => {
    const narrow = run({ type: "prefs", patch: { distance: 1 } });
    expect(discoveryQueue(narrow)).toEqual([]);
    const broad = reducer(narrow, { type: "broaden" });
    expect(broad.prefs).toMatchObject(BROAD);
    expect(discoveryQueue(broad)).toHaveLength(6);
  });
});

describe("persistence", () => {
  it("round-trips state and finishes interrupted sends", () => {
    const store = memory();
    const s = run({ type: "profile", patch: { name: "Jordan" } }, { type: "send", id: "priya", text: "Hi", msgId: 5 });
    saveState(s, store);
    const restored = loadState(store);
    expect(restored.profile.name).toBe("Jordan");
    expect(restored.threads.priya.at(-1)).toMatchObject({ text: "Hi", status: "delivered" });
  });

  it("falls back safely on bad data or unavailable storage", () => {
    const store = memory();
    store.setItem(STORAGE_KEY, "{not json");
    expect(loadState(store)).toBe(initialState);
    const throwing = { getItem: () => { throw new Error("blocked"); }, setItem: () => { throw new Error("blocked"); }, removeItem: () => {} };
    expect(loadState(throwing)).toBe(initialState);
    expect(() => saveState(run({ type: "profile", patch: { name: "X" } }), throwing)).not.toThrow();
  });

  it("reset clears saved data", () => {
    const store = memory();
    saveState(run({ type: "profile", patch: { name: "Jordan" } }), store);
    saveState(reducer(initialState, { type: "reset" }), store);
    expect(store.map.has(STORAGE_KEY)).toBe(false);
  });
});

describe("snooze and notification settings", () => {
  it("persist through storage and clear on reset", () => {
    const store = memory();
    const s = run({ type: "prefs", patch: { snooze: true, messages: false } });
    saveState(s, store);
    const restored = loadState(store);
    expect(restored.prefs).toMatchObject({ snooze: true, messages: false, likes: true, age: [27, 38] });
    const reset = reducer(restored, { type: "reset" });
    expect(reset.prefs).toMatchObject({ snooze: false, messages: true });
    saveState(reset, store);
    expect(loadState(store).prefs.snooze).toBe(false);
  });

  it("changing one setting keeps the others", () => {
    const s = run({ type: "prefs", patch: { distance: 40 } }, { type: "prefs", patch: { snooze: true } });
    expect(s.prefs).toMatchObject({ distance: 40, snooze: true, age: [27, 38] });
  });
});
