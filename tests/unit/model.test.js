import { describe, expect, it } from "vitest";
import { PROTOTYPE_NOW } from "../../src/flows/data.js";
import {
  activityById,
  cardProps,
  distanceKm,
  exploreList,
  goingCount,
  joinModeOf,
  likesList,
  myActivities,
  openersFor,
  phaseOf,
  promptsOf,
  readiness,
  validateActivity,
  whenLabel,
} from "../../src/flows/model.js";
import { initialState, reducer } from "../../src/flows/store.js";

const run = (...actions) => actions.reduce(reducer, initialState);

describe("activity rules", () => {
  it("derives phase from the prototype clock and the record's status", () => {
    const s = initialState;
    expect(phaseOf(activityById(s, "a-run"))).toBe("live");
    expect(phaseOf(activityById(s, "a-jazz"))).toBe("upcoming");
    expect(phaseOf(activityById(s, "a-roast"))).toBe("past");
    expect(phaseOf(activityById(s, "a-poetry"))).toBe("cancelled");
    expect(whenLabel(activityById(s, "a-jazz"))).toBe("Today, 19:30–22:00");
    expect(whenLabel(activityById(s, "a-climb"))).toBe("Tomorrow, 10:00–12:00");
  });

  it("Explore shows others' live and upcoming activities, live first, then soonest", () => {
    const ids = exploreList(initialState).map((a) => a.id);
    expect(ids).toEqual(["a-run", "a-jazz", "a-climb", "a-market", "a-board", "a-film"]);
    expect(ids).not.toContain("m-sourdough");
  });

  it("joins directly, by request or onto the waitlist, and never twice", () => {
    const s = run({ type: "join", id: "a-jazz" }, { type: "join", id: "a-climb" }, { type: "join", id: "a-board" }, { type: "join", id: "a-jazz" });
    expect(s.joins).toMatchObject({ "a-jazz": "joined", "a-climb": "requested", "a-board": "waitlisted" });
    expect(goingCount(s, activityById(s, "a-jazz"))).toBe(6);
    expect(goingCount(s, activityById(s, "a-board"))).toBe(6); // waitlist is not a seat
    expect(joinModeOf(s, activityById(s, "a-roast"))).toBe("unavailable");
    expect(run({ type: "leave", id: "a-run" }).joins["a-run"]).toBeUndefined();
  });

  it("hosts approve requests onto the guest list and cancel their own activities only", () => {
    const s = run({ type: "respondRequest", id: "m-sourdough", person: "jo", accept: true }, { type: "respondRequest", id: "m-sourdough", person: "kemi", accept: false });
    expect(s.own["m-sourdough"]).toMatchObject({ attendees: ["priya", "jo"], requests: [] });
    expect(run({ type: "cancelActivity", id: "m-sourdough" }).own["m-sourdough"].status).toBe("cancelled");
    expect(run({ type: "cancelActivity", id: "a-jazz" })).toBe(initialState);
  });

  it("validates required fields, future dates and the guest limit", () => {
    const ok = { title: "Swim", category: "sport", venue: "Lido", date: "2026-11-01", time: "08:00", capacity: "" };
    expect(validateActivity(ok)).toEqual({});
    expect(Object.keys(validateActivity({}))).toEqual(expect.arrayContaining(["title", "category", "venue", "date", "time"]));
    expect(validateActivity({ ...ok, date: "2026-10-23", time: "11:00" }).date).toMatch(/future/);
    expect(validateActivity({ ...ok, capacity: "1" }).capacity).toBeDefined();
  });

  it("reports hide an activity; blocks hide a host's activities", () => {
    const reported = run({ type: "report", target: "activity", targetId: "a-jazz", reason: "Spam", at: PROTOTYPE_NOW.toISOString() });
    expect(exploreList(reported).map((a) => a.id)).not.toContain("a-jazz");
    expect(reported.reports[0]).toMatchObject({ target: "activity", targetId: "a-jazz", reason: "Spam" });
    const blocked = run({ type: "end", id: "ines", reason: "blocked" });
    expect(exploreList(blocked).map((a) => a.id)).not.toContain("a-climb");
  });

  it("distance needs an area, and cards never show more than venue and area", () => {
    expect(distanceKm(null, activityById(initialState, "a-jazz"))).toBeNull();
    const card = cardProps(initialState, activityById(initialState, "a-jazz"));
    expect(card.place).toBe("Vortex Jazz Club, Dalston · Hackney · about 1.5 km");
    expect(myActivities(initialState).past.map((a) => a.id)).toEqual(["a-roast"]);
  });
});

describe("likes and messages rules", () => {
  it("filters likes and drops handled ones", () => {
    expect(likesList(initialState, "activity").map((l) => l.person)).toEqual(["kemi", "rafa"]);
    expect(likesList(initialState, "nearby").every((l) => l.km <= 5)).toBe(true);
    const s = run({ type: "likeBack", id: "maya", liked: true }, { type: "likeBack", id: "ines", liked: false });
    expect(likesList(s).map((l) => l.person)).not.toContain("maya");
    expect(likesList(s).map((l) => l.person)).not.toContain("ines");
    expect(s.matches).toContain("maya");
    expect(s.matches).not.toContain("ines");
  });

  it("openers start from the person's own prompt or shared interests", () => {
    expect(openersFor("maya")[0]).toContain("A perfect first date");
    expect(openersFor("jo")).toHaveLength(3);
  });
});

describe("profile readiness", () => {
  it("scores only visible profile elements, with documented weights", () => {
    const r = readiness(initialState.profile);
    // basics 20 + photos 3×7.5 + interests 15 + bio 0 + prompt 15
    expect(r.score).toBe(73);
    expect(r.recommendations.map((x) => x.id)).toEqual(["bio", "photos"]);
    const full = readiness({ ...initialState.profile, bio: "Cook, climber and occasional poet. Ask me about the best croissant in town.", photos: [1, 2, 3, 4] });
    expect(full.score).toBe(100);
    expect(full.recommendations).toEqual([]);
  });
});

describe("profile prompts", () => {
  const a = { q: "A perfect first date", a: "A record shop." };
  const b = { q: "My Sunday ritual", a: "A sea swim." };
  const c = { q: "A green flag", a: "Postcards." };
  const d = { q: "Let’s debate this", a: "Croissants." };

  it("shows the one prompt a profile holds today", () => {
    expect(promptsOf(initialState.profile)).toEqual([initialState.profile.prompt]);
  });

  it("shows up to three answered prompts, in order, and never invents one", () => {
    expect(promptsOf({ prompt: a, prompts: [a, b] })).toEqual([a, b]);
    expect(promptsOf({ prompt: a, prompts: [a, b, c, d] })).toEqual([a, b, c]);
    expect(promptsOf({ prompt: a, prompts: [a, { q: "Unanswered", a: "  " }, c] })).toEqual([a, c]);
    expect(promptsOf({ prompt: { q: "Unanswered", a: "" } })).toEqual([]);
    expect(promptsOf({})).toEqual([]);
  });
});
