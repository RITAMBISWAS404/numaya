#!/usr/bin/env node
/**
 * Numbered screenshot gallery of every screen and meaningful state.
 *
 *   npm run gallery
 *
 * Starts a Vite dev server and drives the real UI in Chromium. Mobile captures use a 393 × 852 CSS
 * viewport at 2× device pixel ratio: the onboarding prototype (`index.html`) on a phone context,
 * and each flow screen in single-screen mode (`flows.html?screen=<id>`). States are reached by
 * clicking through the UI, or by seeding the preview's own saved session (localStorage) for states
 * that take many steps (empty inbox, long messages). Animations run under reduced motion so every
 * capture shows the settled UI; the demo verification code is fixed (Math.random is seeded).
 *
 * Writes artifacts/ui-gallery/{screens/*.png, contact-sheets/*.png, contact-sheet-all.png,
 * manifest.json, README.md}.
 */
import { mkdirSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "..");
const OUT = resolve(ROOT, "artifacts/ui-gallery");
const SCREENS = resolve(OUT, "screens");
const SHEETS = resolve(OUT, "contact-sheets");
const MOBILE = { width: 393, height: 852 };
const DESKTOP = { width: 1440, height: 900 };
const QA = { width: 375, height: 667 }; // small-phone QA (iPhone SE size)
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

/* Seeded sessions (same shape the preview saves). */
const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });
const ALL_PEOPLE = ["maya", "sam", "noor", "ines", "lea", "tomas"];
const LONG_THREAD = {
  priya: [
    { id: 1, from: "me", text: "That bakery on Columbia Road, right?", status: "delivered" },
    {
      id: 2,
      from: "them",
      text: "That bakery was unreal. Thank you! I went back on Sunday and they had the cardamom buns again, so now I have a problem and it’s your fault. Also: is it true you’ve been to every record shop between Hackney and Peckham?",
    },
    { id: 3, from: "me", text: "Guilty. There’s one under the railway arches with a 50p crate that I will defend with my life.", status: "delivered" },
    { id: 4, from: "them", text: "Okay you have to take me. Saturday?" },
  ],
};

/** Every capture, in the order a person meets it. `group` picks the contact sheet. */
const SHOTS = [
  // 01 · Onboarding
  { group: 1, slug: "welcome", title: "Welcome", app: "proto" },
  { group: 1, slug: "phone-entry", title: "Phone number (empty, field focused)", app: "proto", setup: (p) => p.getByRole("button", { name: "Create an account" }).click() },
  {
    group: 1, slug: "country-selector", title: "Country selector sheet", app: "proto",
    setup: async (p) => { await p.getByRole("button", { name: "Create an account" }).click(); await wait(900); await p.getByRole("button", { name: /^Country:/ }).click(); },
  },
  {
    group: 1, slug: "country-search", title: "Country search results", app: "proto",
    setup: async (p) => { await p.getByRole("button", { name: "Create an account" }).click(); await wait(900); await p.getByRole("button", { name: /^Country:/ }).click(); await wait(600); await p.getByRole("searchbox").fill("ind"); },
  },
  {
    group: 1, slug: "phone-entry-complete", title: "Phone number (complete, Send code enabled)", app: "proto",
    setup: async (p) => { await p.getByRole("button", { name: "Create an account" }).click(); await wait(900); await p.locator("#phone-number").fill("4155550132"); },
  },
  {
    group: 1, slug: "verify-code-sms-banner", title: "Verify code: simulated text-message banner (autofill)", app: "proto", setup: (p) => toVerify(p),
    notes: "The simulated iOS banner is part of the prototype's autofill demo; the other code states are captured after it hides.",
  },
  { group: 1, slug: "verify-code-focused", title: "Verify code: first cell focused", app: "proto", setup: async (p) => { await toVerify(p); await bannerGone(p); } },
  {
    group: 1, slug: "verify-code-typing", title: "Verify code: three digits entered", app: "proto", notes: "298 typed.",
    setup: async (p) => { await toVerify(p); await bannerGone(p); await p.locator(".code__input").fill("298"); },
  },
  {
    group: 1, slug: "verify-code-error", title: "Verify code: wrong code", notes: "Wrong code 111111 typed.", app: "proto",
    setup: async (p) => { await toVerify(p); await bannerGone(p); await p.locator(".code__input").fill("111111"); await wait(2600); },
  },
  {
    group: 1, slug: "verify-success", title: "Verified success sheet", notes: "Code from the simulated text message typed in; the demo code is fixed for captures.", app: "proto",
    setup: async (p) => {
      await toVerify(p);
      // Type the code from the simulated text message, as a person would on a phone.
      const code = (await p.locator("body").innerText()).match(/code is (\d{6})/)?.[1];
      await p.locator(".code__input").fill(code ?? "");
      await wait(3200);
    },
  },
  { group: 1, slug: "verified-intro", title: "You’re verified → profile setup (nothing done yet)", screen: "intro" },
  { group: 1, slug: "verified-intro-progress", title: "Profile setup: basics done, interests next", notes: "Seeded: the basics finished.", screen: "intro", state: session({ setupDone: ["basics"] }) },
  { group: 1, slug: "basics", title: "The basics", screen: "basics" },
  { group: 1, slug: "basics-name-focused", title: "The basics: first-name field focused", screen: "basics", setup: (p) => p.getByLabel("First name").focus() },
  { group: 1, slug: "basics-underage-error", title: "The basics: under-18 error", notes: "Birth year 2012 typed.", screen: "basics", setup: (p) => p.getByLabel("Year you were born").fill("2012") },
  { group: 1, slug: "interests-prompt", title: "Interests and prompt", screen: "interests" },
  {
    group: 1, slug: "interests-max", title: "Interests: five chosen, the rest locked", notes: "Seeded with five interests; unselected chips are disabled at the maximum.", screen: "interests",
    state: session({ profile: { interests: ["Natural wine", "Jazz", "Cooking", "Climbing", "Poetry"] } }),
  },
  { group: 1, slug: "photos", title: "Add photos", screen: "photos" },

  // 02 · Discover, profile and filters
  { group: 2, slug: "discover", title: "Home: profile card", screen: "discovery" },
  { group: 2, slug: "discover", title: "Home: the full profile scroll", screen: "discovery", full: true },
  { group: 2, slug: "discover-you-both-like", title: "Home: “You both like” card", screen: "discovery", scrollToSelector: "#root .shared-interests" },
  { group: 2, slug: "discover-actions", title: "Home: Pass / SuperSwipe / Like at the end of the profile", screen: "discovery", scrollToSelector: "#root .action-bar" },
  { group: 2, slug: "discover-filters-sheet", title: "Home: filters sheet", screen: "discovery", setup: (p) => p.getByRole("button", { name: /^Filters/ }).click() },
  { group: 2, slug: "discover-no-one-fits", title: "Home: no one fits the filters", notes: "Seeded distance 1 km.", screen: "discovery", state: session({ prefs: { distance: 1 } }) },
  { group: 2, slug: "discover-seen-everyone", title: "Home: seen everyone", notes: "Seeded with every sample profile already decided.", screen: "discovery", state: session({ seen: ALL_PEOPLE }) },
  { group: 2, slug: "home-undo", title: "Home: Undo after a pass (top left)", notes: "Seeded: Sam was just passed.", screen: "discovery", state: session({ seen: ["sam"], lastPass: "sam" }) },
  { group: 2, slug: "home-profile-options", title: "Home: profile options (share, report, block)", screen: "discovery", setup: (p) => p.getByRole("button", { name: "Profile options" }).click() },
  { group: 2, slug: "home-share-sheet", title: "Home: share sheet (honest: nothing is shared in the preview)", screen: "discovery", setup: async (p) => { await p.getByRole("button", { name: "Profile options" }).click(); await wait(500); await p.getByRole("button", { name: /Share/ }).click(); } },
  { group: 2, slug: "discover-paused", title: "Home: paused (snoozed)", notes: "Seeded with Snooze on.", screen: "discovery", state: session({ prefs: { snooze: true } }) },

  // 03 · Matches and messaging
  { group: 3, slug: "match", title: "It’s a match", notes: "Seeded as right after liking Maya, who liked you.", screen: "match", state: session({ matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  { group: 3, slug: "match", title: "It’s a match (full page)", notes: "Seeded right after liking Maya back.", screen: "match", full: true, state: session({ matches: ["rafa", "priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  { group: 3, slug: "match-typing", title: "It’s a match: first message typed", screen: "match", state: session({ matches: ["rafa", "priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }), setup: (p) => p.locator("textarea").first().fill("Hi Maya! Which record shop?") },
  { group: 3, slug: "match-empty", title: "No new match yet", screen: "match" },
  { group: 3, slug: "chats", title: "Messages: search, new matches, filters and conversations", screen: "chats" },
  { group: 3, slug: "chats-many-matches", title: "Messages: several new matches (portrait previews, horizontal rail)", notes: "Seeded with four unopened matches.", screen: "chats", state: session({ matches: ["priya", "jo", "maya", "noor", "lea"] }) },
  { group: 3, slug: "chats-alerts-off", title: "Messages: message alerts off banner", notes: "Seeded with new-message alerts off.", screen: "chats", state: session({ prefs: { messages: false } }) },
  { group: 3, slug: "chats-empty", title: "Messages: empty", notes: "Seeded with no matches.", screen: "chats", state: session({ matches: [], threads: {} }) },
  { group: 3, slug: "chat-conversation", title: "Conversation", screen: "chat" },
  { group: 3, slug: "chat-typing", title: "Conversation: typing (send pill active)", screen: "chat", setup: (p) => p.locator("textarea").first().fill("Saturday works. The record shop first?") },
  { group: 3, slug: "chat-composer-multiline", title: "Conversation: composer with four lines (grows to its maximum, then scrolls)", screen: "chat", setup: (p) => p.locator("textarea").first().fill("Saturday works.\nRecord shop first,\nthen the bakery?\nI’ll bring the 50p crate list.") },
  { group: 3, slug: "chat-composer-url", title: "Conversation: composer with a long URL (wraps inside the field)", screen: "chat", setup: (p) => p.locator("textarea").first().fill("Here it is: https://example.com/records/under-the-railway-arches/50p-crate?sort=oldest&ref=numaya-preview") },
  { group: 3, slug: "chat-new-match", title: "Conversation: new match intro with opening prompts", notes: "Seeded with Jo (no messages yet) as the open chat.", screen: "chat", state: session({ activeChat: "jo" }) },
  { group: 3, slug: "chat-long-messages", title: "Conversation: long messages (edge case)", notes: "Edge case: seeded thread with long messages.", screen: "chat", state: session({ threads: LONG_THREAD }) },
  { group: 3, slug: "chat-options-menu", title: "Conversation options menu", screen: "chat", setup: (p) => p.getByRole("button", { name: "Conversation options" }).click() },
  { group: 3, slug: "chat-unmatch-sheet", title: "Unmatch confirmation sheet", screen: "chat", setup: (p) => openMenu(p, "Unmatch") },
  { group: 3, slug: "chat-block-sheet", title: "Block confirmation sheet", screen: "chat", setup: (p) => openMenu(p, "Block") },
  { group: 3, slug: "chat-report-sheet", title: "Report: reason, optional details, also block", screen: "chat", setup: (p) => openMenu(p, "Report") },
  { group: 3, slug: "chat-unmatched", title: "Ended: unmatched", notes: "Seeded: Priya unmatched.", screen: "chat", state: session({ ended: { priya: "unmatched" } }) },
  { group: 3, slug: "chat-blocked", title: "Ended: blocked", notes: "Seeded: Priya blocked.", screen: "chat", state: session({ ended: { priya: "blocked" } }) },
  { group: 3, slug: "chat-reported", title: "Ended: reported and blocked (report kept on this device)", notes: "Seeded: Priya reported.", screen: "chat", state: session({ ended: { priya: "reported" } }) },
  { group: 3, slug: "chats-search", title: "Messages: search by message text", screen: "chats", setup: (p) => p.getByRole("searchbox").fill("bakery") },
  { group: 3, slug: "chats-filter-empty", title: "Messages: search + Unread filter with nothing to show", screen: "chats", setup: async (p) => { await p.getByRole("searchbox").fill("raf"); await p.getByRole("button", { name: /^Unread/ }).click(); } },
  { group: 3, slug: "chat-opener-inserted", title: "Conversation: an opener inserted into the composer", screen: "chat", state: session({ activeChat: "jo" }), setup: (p) => p.locator(".fl-opener").first().click() },
  { group: 3, slug: "likes", title: "Likes: all", screen: "likes" },
  { group: 3, slug: "likes-activity", title: "Likes: Activity filter", screen: "likes", setup: (p) => p.getByRole("button", { name: /^Activity \d+$/ }).click() },
  { group: 3, slug: "likes-new", title: "Likes: New filter", screen: "likes", setup: (p) => p.getByRole("button", { name: /^New \d+$/ }).click() },
  { group: 3, slug: "likes-nearby", title: "Likes: Nearby filter (within 5 km)", screen: "likes", setup: (p) => p.getByRole("button", { name: /^Nearby \d+$/ }).click() },
  { group: 3, slug: "likes-empty", title: "Likes: empty (every like handled)", notes: "Seeded with every like handled.", screen: "likes", state: session({ likesHandled: { maya: "liked", kemi: "passed", noor: "passed", ines: "passed", tomas: "passed", rafa: "liked" }, matches: ["rafa", "priya", "jo", "maya"] }) },
  { group: 3, slug: "like-profile", title: "Likes: a person who liked you (like back or pass)", screen: "like-profile", state: session({ activeLike: "kemi" }) },
  { group: 3, slug: "like-profile-matched", title: "Likes: an already-matched like (handled)", screen: "like-profile", state: session({ activeLike: "rafa" }) },

  // 04 · Activity
  { group: 4, slug: "activity", title: "Activity: Explore", screen: "activity" },
  { group: 4, slug: "activity", title: "Activity: Explore (full page)", screen: "activity", full: true },
  { group: 4, slug: "activity-category", title: "Activity: Music category", screen: "activity", setup: (p) => p.getByRole("button", { name: "Music", exact: true }).click() },
  { group: 4, slug: "activity-filters-sheet", title: "Activity: date and distance filters", screen: "activity", setup: (p) => p.getByRole("button", { name: /^Filters/ }).click() },
  { group: 4, slug: "activity-filtered-empty", title: "Activity: nothing matches the filters", screen: "activity", setup: async (p) => { await p.getByRole("button", { name: "Games", exact: true }).click(); await p.getByRole("button", { name: /^Filters/ }).click(); await wait(500); await p.getByRole("dialog").getByText("Today", { exact: true }).click(); await p.getByRole("dialog").getByRole("button", { name: "Show activities" }).click(); } },
  { group: 4, slug: "activity-area-sheet", title: "Activity: choose an area (no device location)", screen: "activity", setup: (p) => p.getByRole("button", { name: /Near Hackney/ }).click() },
  { group: 4, slug: "activity-no-area", title: "Activity: no area chosen (distances hidden)", notes: "Seeded with no area.", screen: "activity", state: session({ prefs: { area: null } }) },
  { group: 4, slug: "activity-error", title: "Activity: feed failed to load (retry)", notes: "Seeded with Prototype tools › Simulate network errors on.", screen: "activity", state: session({ prefs: { simulateErrors: true } }) },
  { group: 4, slug: "activity-detail", title: "Activity details: open to join", screen: "activity-detail" },
  { group: 4, slug: "activity-detail", title: "Activity details (full page)", screen: "activity-detail", full: true },
  { group: 4, slug: "activity-joined", title: "Activity details: joined", notes: "Seeded: joined.", screen: "activity-detail", state: session({ joins: { "a-jazz": "joined", "a-run": "joined", "a-roast": "joined" } }) },
  { group: 4, slug: "activity-request", title: "Activity details: host approves requests", screen: "activity-detail", state: session({ activeActivity: "a-climb" }) },
  { group: 4, slug: "activity-requested", title: "Activity details: request pending", notes: "Seeded: request sent.", screen: "activity-detail", state: session({ activeActivity: "a-climb", joins: { "a-climb": "requested", "a-run": "joined", "a-roast": "joined" } }) },
  { group: 4, slug: "activity-full", title: "Activity details: full, waitlist offered", screen: "activity-detail", state: session({ activeActivity: "a-board" }) },
  { group: 4, slug: "activity-waitlisted", title: "Activity details: on the waitlist", notes: "Seeded: waitlisted.", screen: "activity-detail", state: session({ activeActivity: "a-board", joins: { "a-board": "waitlisted", "a-run": "joined", "a-roast": "joined" } }) },
  { group: 4, slug: "activity-live", title: "Activity details: live now, joined", screen: "activity-detail", state: session({ activeActivity: "a-run" }) },
  { group: 4, slug: "activity-long-title", title: "Activity details: long title, multi-paragraph description, no image (edge case)", screen: "activity-detail", state: session({ activeActivity: "a-film" }) },
  { group: 4, slug: "activity-large-group", title: "Activity details: large group, no limit (edge case)", screen: "activity-detail", state: session({ activeActivity: "a-market" }) },
  { group: 4, slug: "activity-cancelled", title: "Activity details: cancelled by the host", screen: "activity-detail", state: session({ activeActivity: "a-poetry" }) },
  { group: 4, slug: "activity-past", title: "Activity details: ended", screen: "activity-detail", state: session({ activeActivity: "a-roast" }) },
  { group: 4, slug: "activity-host", title: "Activity details: host view", screen: "activity-detail", state: session({ activeActivity: "m-sourdough" }) },
  { group: 4, slug: "activity-options", title: "Activity details: options (share, report, block host)", screen: "activity-detail", setup: (p) => p.getByRole("button", { name: "Activity options" }).click() },
  { group: 4, slug: "activity-report", title: "Activity: report sheet", screen: "activity-detail", setup: async (p) => { await p.getByRole("button", { name: "Activity options" }).click(); await wait(500); await p.getByRole("button", { name: "Report activity" }).click(); } },
  { group: 4, slug: "activity-leave", title: "Activity: leave confirmation", screen: "activity-detail", state: session({ activeActivity: "a-run" }), setup: (p) => p.getByRole("button", { name: "Leave activity" }).click() },
  { group: 4, slug: "activity-people-host", title: "Guests: host view with requests", screen: "activity-people", state: session({ activeActivity: "m-sourdough" }) },
  { group: 4, slug: "activity-people", title: "Guests: first names only, the rest a count", screen: "activity-people", state: session({ activeActivity: "a-market" }) },
  { group: 4, slug: "activity-form", title: "Create activity: empty form", screen: "activity-form" },
  { group: 4, slug: "activity-form", title: "Create activity (full page)", screen: "activity-form", full: true },
  { group: 4, slug: "activity-form-errors", title: "Create activity: required-field errors", screen: "activity-form", setup: (p) => p.getByRole("button", { name: "Publish" }).click() },
  { group: 4, slug: "activity-form-category", title: "Create activity: category picker (entered text is kept)", screen: "activity-form", setup: async (p) => { await p.getByLabel("Activity name").fill("Sunday sea swim"); await p.getByRole("button", { name: /Choose a category/ }).click(); } },
  { group: 4, slug: "activity-form-past", title: "Create activity: a past date is rejected", screen: "activity-form", setup: async (p) => { await p.getByLabel("Activity name").fill("Sunday sea swim"); await p.getByLabel("Place or venue").fill("London Fields Lido café"); await p.getByLabel("Date").fill("2026-10-20"); await p.getByLabel("Start time").fill("08:00"); await p.getByRole("button", { name: /Choose a category/ }).click(); await wait(500); await p.getByRole("dialog").getByText("Sport", { exact: true }).click(); await wait(400); await p.getByRole("button", { name: "Publish" }).click(); await p.getByText("Pick a date and time in the future.").evaluate((e) => e.scrollIntoView({ block: "center" })); } },
  { group: 4, slug: "activity-form-edit", title: "Edit activity: existing values", screen: "activity-form", state: session({ editingActivity: "m-sourdough" }) },
  { group: 4, slug: "activity-published", title: "Create activity: published", screen: "activity-form", setup: async (p) => { await p.getByLabel("Activity name").fill("Sunday sea swim"); await p.getByRole("button", { name: /Choose a category/ }).click(); await wait(500); await p.getByRole("dialog").getByText("Sport", { exact: true }).click(); await wait(400); await p.getByLabel("Place or venue").fill("London Fields Lido café"); await p.getByLabel("Date").fill("2026-11-01"); await p.getByLabel("Start time").fill("08:00"); await p.getByRole("button", { name: "Publish" }).click(); await wait(900); } },
  { group: 4, slug: "my-activities", title: "My activities: Upcoming", screen: "my-activities" },
  { group: 4, slug: "my-activities-hosting", title: "My activities: Hosting (with a draft)", screen: "my-activities", state: session({ own: { ...initialState.own, "m-draft": { title: "Half-formed idea", category: "food", start: "2026-10-23T12:00", durationMin: 120, venue: "", area: "hackney", x: 0, y: 0, capacity: null, approval: false, visibility: "public", tone: null, status: "draft", attendees: [], othersGoing: 0, requests: [] } } }), setup: (p) => p.getByRole("button", { name: /^Hosting/ }).click() },
  { group: 4, slug: "my-activities-requests", title: "My activities: Requests", screen: "my-activities", state: session({ joins: { "a-climb": "requested", "a-run": "joined", "a-roast": "joined" } }), setup: (p) => p.getByRole("button", { name: /^Requests/ }).click() },
  { group: 4, slug: "my-activities-past", title: "My activities: Past", screen: "my-activities", setup: (p) => p.getByRole("button", { name: /^Past/ }).click() },
  { group: 4, slug: "my-activities-empty", title: "My activities: nothing upcoming", notes: "Seeded with no joins.", screen: "my-activities", state: session({ joins: {} }) },

  // 05 · Profile and settings
  { group: 5, slug: "profile", title: "My profile", screen: "profile" },
  { group: 5, slug: "profile", title: "My profile (full page)", screen: "profile", full: true },
  { group: 5, slug: "profile-long-name", title: "My profile: long name (edge case)", notes: "Edge case: seeded 21-character name.", screen: "profile", state: session({ profile: { name: "Maximiliana-Josephine" } }) },
  { group: 5, slug: "edit-profile", title: "Edit profile", screen: "edit" },
  { group: 5, slug: "edit-profile", title: "Edit profile (full page)", screen: "edit", full: true },
  { group: 5, slug: "edit-photo-options", title: "Edit profile: photo options sheet", screen: "edit", setup: (p) => p.getByRole("button", { name: "Photo 2: options" }).click() },
  {
    group: 5, slug: "edit-name-error", title: "Edit profile: empty name error", screen: "edit", scrollTo: "First name",
    setup: (p) => p.getByLabel("First name").fill(""),
  },
  { group: 5, slug: "edit-preview", title: "Edit profile: Preview", screen: "edit", setup: (p) => p.getByRole("tab", { name: "Preview" }).click() },
  { group: 5, slug: "edit-preview", title: "Edit profile: Preview (full page)", screen: "edit", full: true, setup: (p) => p.getByRole("tab", { name: "Preview" }).click() },
  { group: 5, slug: "prompt-editor", title: "Edit prompt", screen: "prompt" },
  { group: 5, slug: "prompt-editor-focused", title: "Edit prompt: answer field focused", screen: "prompt", setup: (p) => p.getByLabel("Your answer").focus() },
  {
    group: 5, slug: "prompt-editor-changed", title: "Edit prompt: new question and answer, ready to save", screen: "prompt",
    setup: async (p) => { await p.getByText("My Sunday ritual").click(); await p.getByLabel("Your answer").fill("Farmers market, then a very long lunch."); },
  },
  { group: 5, slug: "settings", title: "Settings", screen: "settings" },
  { group: 5, slug: "settings", title: "Settings (full page)", screen: "settings", full: true },
  { group: 5, slug: "settings-snooze-on", title: "Settings: Snooze on", screen: "settings", state: session({ prefs: { snooze: true } }), notes: "Seeded with Snooze on." },
  { group: 5, slug: "insights", title: "Profile readiness dashboard", screen: "insights" },
  { group: 5, slug: "insights", title: "Profile readiness dashboard (full page)", screen: "insights", full: true },
  { group: 5, slug: "insights-complete", title: "Profile readiness: complete profile", notes: "Seeded with a bio and four photos.", screen: "insights", state: session({ profile: { bio: "Cook, climber and occasional poet. Ask me about the best croissant in town.", photos: [{ id: 1, tone: 0 }, { id: 2, tone: 1 }, { id: 3, tone: 2 }, { id: 4, tone: 3 }] } }) },
  { group: 5, slug: "insights-paused", title: "Profile readiness: account status Paused (Snooze on)", screen: "insights", state: session({ prefs: { snooze: true } }), scrollToSelector: "#root .fl-status" },
  { group: 5, slug: "edit-focus-bio", title: "Edit profile: opened from a recommendation, bio focused", screen: "edit", state: session({ editFocus: "bio" }) },
  { group: 5, slug: "settings-prototype-tools", title: "Settings: blocked people and prototype tools", screen: "settings", scrollToSelector: "#root .list-row--destructive" },
  { group: 5, slug: "blocked", title: "Blocked people", screen: "blocked", state: session({ ended: { priya: "reported", sam: "blocked" } }) },
  { group: 5, slug: "blocked-empty", title: "Blocked people: empty", screen: "blocked" },
  { group: 5, slug: "premium", title: "Premium: Free and Plus (no prices, no billing)", screen: "premium" },
  { group: 5, slug: "premium-sheet", title: "Premium: Plus isn’t on sale in this preview", screen: "premium", setup: (p) => p.getByRole("button", { name: "See Plus" }).click() },
  { group: 5, slug: "connections", title: "Connected accounts: none", screen: "connections" },
  { group: 5, slug: "connections-consent", title: "Connected accounts: consent before connecting (simulated)", screen: "connections", setup: (p) => p.getByRole("button", { name: "Connect" }).first().click() },
  { group: 5, slug: "connections-connected", title: "Connected accounts: Spotify connected (simulated)", screen: "connections", state: session({ social: { instagram: false, spotify: true } }) },
  { group: 5, slug: "help", title: "Help and support", screen: "help" },
  { group: 5, slug: "help-topic", title: "Help: a guide", screen: "help", setup: (p) => p.getByRole("button", { name: "Meeting someone safely" }).click() },
  { group: 5, slug: "maintenance", title: "System state: service unavailable", screen: "maintenance" },
  { group: 5, slug: "settings-delete-sheet", title: "Delete account sheet", screen: "settings", setup: (p) => p.getByRole("button", { name: "Delete account" }).click() },

  // 06 · Desktop context
  { group: 6, slug: "desktop-prototype", title: "Desktop: onboarding prototype with brief", app: "proto", viewport: DESKTOP },
  { group: 6, slug: "desktop-flow-previews", title: "Desktop: flow previews gallery", url: "flows.html", viewport: DESKTOP },
  { group: 6, slug: "desktop-edit-profile", title: "Desktop: flow previews, Profile → Edit profile → Edit prompt", url: "flows.html#profile", viewport: DESKTOP, scrollToFrame: "edit" },
  { group: 6, slug: "desktop-design-system", title: "Desktop: design-system showcase", url: "showcase.html", viewport: DESKTOP },
  { group: 6, slug: "desktop-flow-previews-chats", title: "Desktop: flow previews scrolled to Chats and the conversation", url: "flows.html", viewport: DESKTOP, scrollToFrame: "chats" },
  { group: 6, slug: "desktop-flow-previews-activity", title: "Desktop: flow previews scrolled to Activity", url: "flows.html", viewport: DESKTOP, scrollToFrame: "activity" },
  { group: 6, slug: "desktop-flow-previews-likes", title: "Desktop: flow previews scrolled to Likes and Messages", url: "flows.html", viewport: DESKTOP, scrollToFrame: "likes" },
  { group: 6, slug: "desktop-flow-previews-account", title: "Desktop: flow previews scrolled to Profile readiness and account", url: "flows.html", viewport: DESKTOP, scrollToFrame: "insights" },
  { group: 6, slug: "desktop-design-system-illustrations", title: "Desktop: design-system showcase scrolled to the illustrations and result panels", url: "showcase.html", viewport: DESKTOP, scrollToSelector: ".sc-ill-grid" },

  // 07 · Small-phone QA (375 × 667): the screens most at risk of crowding
  { group: 7, slug: "qa-welcome", title: "QA 375: Welcome", app: "proto", viewport: QA },
  {
    group: 7, slug: "qa-phone-entry", title: "QA 375: Phone number with keypad", app: "proto", viewport: QA,
    setup: async (p) => { await p.getByRole("button", { name: "Create an account" }).click(); await wait(900); await p.locator("#phone-number").fill("4155550132"); },
  },
  { group: 7, slug: "qa-verify-code", title: "QA 375: Verify code", app: "proto", viewport: QA, setup: async (p) => { await toVerify(p); await bannerGone(p); } },
  { group: 7, slug: "qa-verified-intro", title: "QA 375: You’re verified → profile setup", screen: "intro", viewport: QA, notes: "Scrolls slightly at this height; the body becomes a tab stop." },
  { group: 7, slug: "qa-interests", title: "QA 375: Interests and prompt", screen: "interests", viewport: QA },
  { group: 7, slug: "qa-discover", title: "QA 375: Home profile card", screen: "discovery", viewport: QA },
  { group: 7, slug: "qa-match", title: "QA 375: It’s a match", screen: "match", viewport: QA, state: session({ matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  { group: 7, slug: "qa-chats", title: "QA 375: Chats", screen: "chats", viewport: QA },
  { group: 7, slug: "qa-chat-long-messages", title: "QA 375: Conversation with long messages", screen: "chat", viewport: QA, state: session({ threads: LONG_THREAD }) },
  { group: 7, slug: "qa-settings", title: "QA 375: Settings", screen: "settings", viewport: QA },
  { group: 7, slug: "qa-verified-intro-bottom", title: "QA 375: profile setup scrolled to the last step card", screen: "intro", viewport: QA, scrollToSelector: "#root .setup-step:last-child" },
  { group: 7, slug: "qa-chats-many-matches", title: "QA 375: Chats with several new matches (horizontal rail)", screen: "chats", viewport: QA, state: session({ matches: ["priya", "jo", "maya", "noor", "lea"] }) },
  { group: 7, slug: "qa-chat-composer-multiline", title: "QA 375: composer at its maximum height", screen: "chat", viewport: QA, setup: (p) => p.locator("textarea").first().fill("Saturday works.\nRecord shop first,\nthen the bakery?\nI’ll bring the 50p crate list.\nAnd snacks.") },
  { group: 7, slug: "qa-activity", title: "QA 375: Activity Explore", screen: "activity", viewport: QA },
  { group: 7, slug: "qa-activity-long-title", title: "QA 375: activity with a long title", screen: "activity-detail", viewport: QA, state: session({ activeActivity: "a-film" }) },
  { group: 7, slug: "qa-activity-form-errors", title: "QA 375: create activity with errors", screen: "activity-form", viewport: QA, setup: (p) => p.getByRole("button", { name: "Publish" }).click() },
  { group: 7, slug: "qa-my-activities", title: "QA 375: My activities", screen: "my-activities", viewport: QA },
  { group: 7, slug: "qa-likes", title: "QA 375: Likes", screen: "likes", viewport: QA },
  { group: 7, slug: "qa-profile", title: "QA 375: Profile home", screen: "profile", viewport: QA },
  { group: 7, slug: "qa-insights", title: "QA 375: readiness dashboard", screen: "insights", viewport: QA },
  { group: 7, slug: "qa-insights-metrics", title: "QA 375: readiness metrics and status", screen: "insights", viewport: QA, scrollToSelector: "#root .fl-metrics" },
  { group: 7, slug: "qa-match-kemi", title: "QA 375: It’s a match with a person who has no prompt", screen: "match", viewport: QA, state: session({ matches: ["rafa", "priya", "jo", "kemi"], lastMatch: "kemi" }) },
  { group: 7, slug: "qa-settings-bottom", title: "QA 375: Settings scrolled to the end", screen: "settings", viewport: QA, scrollToSelector: "#root .list-row--destructive" },
];

const GROUPS = {
  1: { file: "01-onboarding", title: "Onboarding" },
  2: { file: "02-home-profile-filters", title: "Home: profiles and filters" },
  3: { file: "03-likes-matches-messaging", title: "Likes, matches and messages" },
  4: { file: "04-activity", title: "Activity" },
  5: { file: "05-profile-settings", title: "Profile, readiness, settings and account" },
  6: { file: "06-desktop", title: "Desktop context" },
  7: { file: "07-qa-375", title: "Small-phone QA (375 × 667)" },
};

async function toVerify(p) {
  await p.getByRole("button", { name: "Create an account" }).click();
  await wait(900);
  await p.locator("#phone-number").fill("4155550132");
  await p.getByRole("button", { name: "Send code" }).click();
  await wait(3200);
}

/** The simulated text-message banner hides 6 s after it appears. */
async function bannerGone(p) {
  await p.locator(".notification").waitFor({ state: "detached", timeout: 12000 });
  await wait(300);
}

async function openMenu(p, action) {
  await p.getByRole("button", { name: "Conversation options" }).click();
  await wait(500);
  await p.getByRole("button", { name: action }).first().click();
}

const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();

rmSync(OUT, { recursive: true, force: true });
mkdirSync(SCREENS, { recursive: true });
mkdirSync(SHEETS, { recursive: true });

const manifest = [];
const errors = [];
try {
  for (const [i, shot] of SHOTS.entries()) {
    const id = String(i + 1).padStart(3, "0");
    const vp = shot.viewport ?? MOBILE;
    const mobile = vp.width < 600;
    const ctx = await browser.newContext({ viewport: vp, deviceScaleFactor: 2, reducedMotion: "reduce", ...(mobile ? { isMobile: true, hasTouch: true } : {}) });
    const seed = shot.state ? JSON.stringify({ version: 1, state: shot.state }) : null;
    await ctx.addInitScript(
      ([key, value]) => {
        let s = 0.42;
        Math.random = () => (s = (s * 9301 + 49297) % 233280 / 233280); // fixed demo code
        try {
          if (value) localStorage.setItem(key, value);
          else localStorage.removeItem(key);
        } catch {}
      },
      [STORAGE_KEY, seed],
    );
    const p = await ctx.newPage();
    p.on("pageerror", (e) => errors.push(`${id}: ${e.message}`));
    p.on("console", (m) => m.type() === "error" && errors.push(`${id}: ${m.text()}`));
    const url = shot.app === "proto" ? "" : shot.url ?? `flows.html?screen=${shot.screen}`;
    await p.goto(base + url);
    await p.evaluate(() => document.fonts.ready);
    await wait(1200);
    if (shot.setup) {
      await shot.setup(p);
      await wait(900);
    }
    if (shot.scrollToSelector) await p.locator(shot.scrollToSelector).first().evaluate((el) => el.scrollIntoView({ block: "center" }));
    if (shot.scrollTo) await p.getByLabel(shot.scrollTo).evaluate((el) => el.scrollIntoView({ block: "center" }));
    if (shot.scrollToFrame) {
      await p.locator(`#${shot.scrollToFrame}`).scrollIntoViewIfNeeded();
      await p.evaluate(() => window.scrollBy(0, -120));
    }
    let size = `${vp.width}x${vp.height}`;
    let height = vp.height;
    if (shot.full) {
      // Grow the viewport until the screen's scrolling body shows all of its content. Cards sized
      // to the viewport (the Discover photo card) keep the height they have on the phone.
      const extra = await p.evaluate(() => {
        for (const c of document.querySelectorAll(".profile-card")) {
          c.style.setProperty("--profile-card-photo-height", `${c.querySelector(".profile-card__media").getBoundingClientRect().height}px`);
        }
        const b = document.querySelector(".fl-screen__body");
        return b ? b.scrollHeight - b.clientHeight : 0;
      });
      height = vp.height + extra;
      await p.setViewportSize({ width: vp.width, height });
      await wait(600);
      size = `${vp.width}w`;
    }
    const name = `${id}-${shot.slug}${shot.full ? "-fullpage" : ""}-${size}.png`;
    await p.screenshot({ path: resolve(SCREENS, name) });
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    if (overflow > 0) errors.push(`${id}: ${overflow}px horizontal overflow`);
    manifest.push({
      id,
      name: shot.title,
      group: GROUPS[shot.group].title,
      route: shot.app === "proto" ? "index.html (onboarding prototype)" : url,
      state: shot.state ? "seeded session" : shot.setup ? "reached by interaction" : "initial",
      viewport: { width: vp.width, height, deviceScaleFactor: 2 },
      capture: shot.full ? "full-page" : "viewport",
      image: `screens/${name}`,
      ...(shot.notes ? { notes: shot.notes } : {}),
    });
    console.log(`${id} ${name}`);
    await ctx.close();
  }

  // Contact sheets: rendered as HTML so thumbnails keep their aspect ratio and carry a label.
  const sheet = async (title, items, file, thumb) => {
    const html = `<!doctype html><meta charset="utf-8"><style>
      body{margin:0;padding:32px;background:#eceff3;font:14px/1.35 Inter,system-ui,sans-serif;color:#14171f}
      h1{margin:0 0 24px;font:600 22px/1.2 Inter,system-ui,sans-serif}
      .grid{display:flex;flex-wrap:wrap;gap:24px 20px;align-items:flex-start}
      figure{margin:0;width:${thumb}px}
      img{display:block;width:100%;height:auto;border-radius:12px;box-shadow:0 1px 3px rgb(20 23 31/.12);background:#fff}
      figcaption{margin-top:8px}figcaption b{font-variant-numeric:tabular-nums}
    </style><h1>${title}</h1><div class="grid">${items
      .map((m) => `<figure><img src="${pathToFileURL(resolve(OUT, m.image)).href}"><figcaption><b>${m.id}</b> ${m.name}</figcaption></figure>`)
      .join("")}</div>`;
    const tmp = resolve(OUT, `.sheet-${file.replace(/[/.]/g, "-")}.html`);
    writeFileSync(tmp, html);
    const ctx = await browser.newContext({ viewport: { width: 1600, height: 900 }, deviceScaleFactor: 1 });
    const p = await ctx.newPage();
    await p.goto(pathToFileURL(tmp).href);
    await p.evaluate(() => Promise.all([...document.images].map((i) => i.decode().catch(() => {}))));
    const broken = await p.evaluate(() => [...document.images].filter((i) => !i.naturalWidth).map((i) => i.src));
    if (broken.length) errors.push(`${file}: ${broken.length} image(s) did not load`);
    await p.screenshot({ path: resolve(OUT, file), fullPage: true });
    await ctx.close();
    rmSync(tmp);
  };
  for (const [g, { file, title }] of Object.entries(GROUPS)) {
    const items = manifest.filter((m) => m.group === title);
    await sheet(`Numaya · ${title}`, items, `contact-sheets/${file}.png`, g === "6" ? 480 : 220);
  }
  await sheet("Numaya · every screen and state", manifest, "contact-sheet-all.png", 140);
} finally {
  await browser.close();
  await server.close();
}

writeFileSync(resolve(OUT, "manifest.json"), `${JSON.stringify({ generatedBy: "npm run gallery", screens: manifest }, null, 2)}\n`);

// README: every screen in order with a relative link, grouped like the contact sheets.
const sizeOf = (f) => `${Math.round(statSync(resolve(OUT, f)).size / 1024)} KB`;
const lines = [
  "# Numaya UI gallery",
  "",
  "Every designed screen and meaningful state, numbered in the order a person meets them. Generated",
  "by `npm run gallery` (`scripts/gallery.mjs`) from the running prototype, so it can be regenerated",
  "after any change.",
  "",
  "- **Mobile:** 393 × 852 CSS pixels (iPhone 15 size) at 2× pixel density, so each image is 786 × 1704.",
  "  Flow screens are captured in single-screen mode (`flows.html?screen=<id>`); onboarding comes from",
  "  the prototype (`index.html`) on a phone context.",
  "- **Full page** (`-fullpage-393w`): long, scrolling screens captured with all their content.",
  "- **Desktop** (`-1440x900`): the prototype, flow previews and design system at desktop width.",
  "- **Small-phone QA** (`-375x667`): the screens most at risk of crowding, at iPhone SE size.",
  "- States are reached by interaction, or by seeding the preview's saved session for states that take",
  "  many steps (see `state` in [manifest.json](manifest.json)). Captured with reduced motion so",
  "  animations show their settled frame; the demo verification code is fixed.",
  "- Photo areas are neutral placeholders until licensed photography is supplied. Outcome, empty-state",
  "  and spot illustrations are Numaya's own SVG scenes (`Illustration`); the Welcome hero stays a",
  "  reserved, empty slot until its artwork is supplied.",
  "",
  "## Contact sheets",
  "",
  `- [All screens](contact-sheet-all.png)`,
  ...Object.values(GROUPS).map((g) => `- [${g.title}](contact-sheets/${g.file}.png)`),
  "",
];
for (const g of Object.values(GROUPS)) {
  lines.push(`## ${g.title}`, "", "| # | Screen or state | Capture | Notes | Image |", "| --- | --- | --- | --- | --- |");
  for (const m of manifest.filter((x) => x.group === g.title)) {
    lines.push(`| ${m.id} | ${m.name} | ${m.capture === "full-page" ? "Full page" : "Viewport"} · \`${m.route}\` | ${m.notes ?? ""} | [${m.image.replace("screens/", "")}](${m.image}) |`);
  }
  lines.push("");
}
const total = readdirSync(SCREENS).reduce((n, f) => n + statSync(resolve(SCREENS, f)).size, 0);
lines.push(
  `${manifest.length} captures: ${manifest.filter((m) => m.capture === "viewport").length} viewport, ${manifest.filter((m) => m.capture === "full-page").length} full page (${Math.round(total / 1024 / 1024)} MB of screenshots; all-screens sheet ${sizeOf("contact-sheet-all.png")}).`,
  "",
);
writeFileSync(resolve(OUT, "README.md"), lines.join("\n"));

if (errors.length) {
  console.error(`\n${errors.length} problem(s):\n${errors.join("\n")}`);
  process.exit(1);
}
console.log(`\n${manifest.length} captures written to artifacts/ui-gallery/`);
