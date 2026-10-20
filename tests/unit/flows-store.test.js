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
