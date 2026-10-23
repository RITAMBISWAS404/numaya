#!/usr/bin/env node
/**
 * End-to-end journeys for the product expansion (Activity, Likes, Messages, Profile insights,
 * account features), driven in single-screen mode (`flows.html?screen=<id>`) like the app on a
 * phone. Run by `npm run test:e2e` after the smoke test.
 */
import { mkdirSync } from "node:fs";
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";

const ROOT = resolve(import.meta.dirname, "../..");
const OUT = resolve(import.meta.dirname, "artifacts");
mkdirSync(OUT, { recursive: true });

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}

const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();

async function phone(width = 393, height = 852) {
  const ctx = await browser.newContext({ viewport: { width, height }, deviceScaleFactor: 1, reducedMotion: "reduce" });
  const p = await ctx.newPage();
  p.errors = [];
  p.on("pageerror", (e) => p.errors.push(e.message));
  p.on("console", (m) => m.type() === "error" && p.errors.push(m.text()));
  return p;
}

/** Fresh session on a screen. */
async function open(p, screen) {
  await p.goto(`${base}flows.html?screen=${screen}`);
  await p.evaluate(() => localStorage.clear());
  await p.goto(`${base}flows.html?screen=${screen}`);
  await wait(900);
}
const screenId = (p) => new URL(p.url()).searchParams.get("screen");
const body = (p) => p.locator(".fl-screen").first().innerText().then((t) => t.replace(/\s+/g, " "));
const tap = async (p, name, opts = {}) => {
  await p.getByRole("button", { name, ...opts }).first().click();
  await wait(500);
};

try {
  /* 1 · Five sections ---------------------------------------------- */
  {
    const p = await phone();
    await open(p, "discovery");
    const tabs = await p.locator(".tab-bar__item").allInnerTexts();
    check("nav: five sections in PRD order", tabs.map((t) => t.replace(/\d+/g, "").trim()).join(",") === "Home,Activity,Likes,Messages,Profile", tabs.join(","));
    const reached = [];
    for (const [label, id] of [["Activity", "activity"], ["Likes", "likes"], ["Messages", "chats"], ["Profile", "profile"], ["Home", "discovery"]]) {
      await p.locator(".tab-bar__item", { hasText: label }).click();
      await wait(700);
      reached.push(screenId(p) === id && (await p.locator(".tab-bar__item.is-current", { hasText: label }).count()) === 1);
    }
    check("nav: every tab opens its own screen and marks itself current", reached.every(Boolean), reached.join(","));
    const sizes = await p.locator(".tab-bar__item").evaluateAll((els) => els.map((e) => Math.round(e.getBoundingClientRect().width)));
    check("nav: tab targets stay at least 44px wide at 393", sizes.every((w) => w >= 44), sizes.join(","));
    check("nav: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }
  {
    const p = await phone(375, 667);
    await open(p, "activity");
    const sizes = await p.locator(".tab-bar__item").evaluateAll((els) => els.map((e) => e.getBoundingClientRect()).map((r) => `${Math.round(r.width)}x${Math.round(r.height)}`));
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    check("nav 375: five tabs fit with 44px targets and no overflow", sizes.every((s) => s.split("x").every((n) => +n >= 44)) && overflow <= 0, sizes.join(" "));
  }

  /* 2 · Discover, open, join / request / waitlist ------------------ */
  {
    const p = await phone();
    await open(p, "activity");
    const cards = await p.locator(".activity-card").count();
    check("activity: Explore lists published, upcoming activities by others", cards === 6, String(cards));
    const first = await p.locator(".activity-card").first().innerText();
    check("activity: an activity under way is first, marked Live now", first.includes("Live now") && first.includes("Parkrun"), first.slice(0, 60));
    await tap(p, /Late jazz/);
    check("activity: a card opens the matching details", screenId(p) === "activity-detail" && (await body(p)).includes("Vortex Jazz Club"));
    const before = await body(p);
    await tap(p, "Join", { exact: true });
    await wait(700);
    const after = await body(p);
    check("activity: Join confirms and updates the head count", before.includes("5 of 8 going") && after.includes("6 of 8 going") && after.includes("You’re going") && after.includes("Leave activity"), after.match(/\d of 8 going/)?.[0]);
    await tap(p, "Back");
    const jazz = await p.locator(".activity-card", { hasText: "Late jazz" }).innerText();
    check("activity: the card in Explore shows the same state", jazz.includes("You’re going") && jazz.includes("6 going"));
    await tap(p, /Bouldering/);
    await tap(p, "Request to join");
    await wait(700);
    check("activity: approval activities take a request, not a seat", (await body(p)).includes("Requested") && (await body(p)).includes("3 of 6 going") && (await body(p)).includes("Withdraw request"));
    await tap(p, "Withdraw request");
    await p.getByRole("dialog").getByRole("button", { name: "Withdraw request" }).click();
    await wait(600);
    check("activity: withdrawing a request confirms first and restores Request to join", (await p.getByRole("button", { name: "Request to join" }).count()) === 1);
    await tap(p, "Back");
    await tap(p, /Board games/);
    check("activity: a full activity offers the waitlist", (await body(p)).includes("Full") && (await p.getByRole("button", { name: "Join the waitlist" }).count()) === 1);
    await tap(p, "Join the waitlist");
    await wait(700);
    check("activity: waitlisting does not change the head count", (await body(p)).includes("On the waitlist") && (await body(p)).includes("6 of 6 going"));
    await tap(p, "Back");
    await p.getByRole("tab", { name: "My activities" }).click();
    await wait(700);
    const upcoming = await body(p);
    check("activity: My activities › Upcoming lists joined and waitlisted activities", upcoming.includes("Late jazz") && upcoming.includes("Board games") && upcoming.includes("On the waitlist"));
    await tap(p, /^Past/);
    check("activity: Past keeps attended activities", (await body(p)).includes("Sunday roast club"));
    check("activity: no console errors in the participant journey", p.errors.length === 0, p.errors.join(" | "));
  }

  /* 3 · Create, validate, publish, find it; 4 · edit and cancel ---- */
  {
    const p = await phone();
    await open(p, "activity");
    await tap(p, "Create an activity");
    await tap(p, "Publish");
    const errs = await p.locator(".field__note.is-error, .fl-form-error").allInnerTexts();
    check("create: Publish with empty fields explains every required field", errs.some((e) => e.includes("name")) && errs.some((e) => e.includes("category")) && errs.some((e) => e.includes("public place")) && errs.some((e) => e.includes("date")), errs.join(" | "));
    await p.getByLabel("Activity name").fill("Sunday sea swim");
    await tap(p, /Choose a category/);
    await p.getByRole("dialog").getByText("Sport", { exact: true }).click();
    await wait(400);
    check("create: the category picker keeps what was typed", (await p.getByLabel("Activity name").inputValue()) === "Sunday sea swim" && (await body(p)).includes("Sport"));
    await p.getByLabel("Place or venue").fill("London Fields Lido café");
    await p.getByLabel("Date").fill("2026-10-20");
    await p.getByLabel("Start time").fill("08:00");
    await tap(p, "Publish");
    check("create: a date in the past cannot be published", (await body(p)).includes("Pick a date and time in the future"));
    await p.getByLabel("Date").fill("2026-11-01");
    await tap(p, "Publish");
    await wait(700);
    check("create: publishing confirms", (await body(p)).includes("Your activity is published"));
    await tap(p, "Go to My activities");
    await tap(p, /^Hosting/);
    check("create: the new activity is under Hosting", (await body(p)).includes("Sunday sea swim"));
    await tap(p, /Sunday sea swim/);
    await tap(p, "Edit");
    await p.getByLabel("Activity name").fill("Sunday sea swim and breakfast");
    await tap(p, "Save changes");
    await wait(700);
    await tap(p, "View activity");
    check("edit: changes are saved to the same activity", (await body(p)).includes("Sunday sea swim and breakfast"));
    await tap(p, "Activity options");
    await tap(p, "Cancel activity");
    const sheet = await p.getByRole("dialog", { name: "Cancel this activity?" }).count();
    await p.getByRole("dialog").getByRole("button", { name: "Cancel activity" }).click();
    await wait(700);
    check("edit: cancelling confirms first and the activity shows Cancelled", sheet === 1 && (await body(p)).includes("Cancelled") && (await body(p)).includes("You cancelled this activity"));
    await tap(p, "Back");
    await p.getByRole("tab", { name: "Explore" }).click();
    await wait(600);
    check("edit: a cancelled activity is not listed in Explore", !(await body(p)).includes("Sunday sea swim"));
    // Host requests
    await p.getByRole("tab", { name: "My activities" }).click();
    await wait(600);
    await tap(p, /^Hosting/);
    await tap(p, /Sourdough/);
    await tap(p, /2 requests/);
    await tap(p, "Approve");
    const guests = await body(p);
    check("host: approving a request moves the person onto the guest list", guests.includes("Requests (1)") && guests.includes("3 of 8 going"), guests.slice(0, 80));
    check("create: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }

  /* Draft, safety and failure -------------------------------------- */
  {
    const p = await phone();
    await open(p, "activity-form");
    await p.getByLabel("Activity name").fill("Half-formed idea");
    await tap(p, "Save as draft");
    await wait(700);
    check("draft: a draft saves with just a name", (await body(p)).includes("Draft saved"));
    await tap(p, "Go to My activities");
    await tap(p, /^Hosting/);
    check("draft: drafts are marked and only in My activities", (await body(p)).includes("Draft · only you can see it"));
    await p.getByRole("tab", { name: "Explore" }).click();
    await wait(600);
    check("draft: drafts never appear in Explore", !(await body(p)).includes("Half-formed idea"));

    await tap(p, /Late jazz/);
    await tap(p, "Activity options");
    await tap(p, "Report activity");
    const send = p.getByRole("dialog").getByRole("button", { name: "Send report" });
    const disabled = await send.isDisabled();
    await p.getByRole("dialog").getByText("Spam or selling something").click();
    await send.click();
    await wait(400);
    const outcome = await p.getByRole("dialog").innerText();
    check("report: needs a reason, then says it is kept on this device only", disabled && outcome.includes("kept on this device only") && !/investigat|action taken|removed/i.test(outcome));
    await p.getByRole("dialog").getByRole("button", { name: "Done" }).click();
    await wait(700);
    check("report: the reported activity is hidden from Explore", screenId(p) === "activity" && !(await body(p)).includes("Late jazz"));

    await tap(p, /Bouldering/);
    await tap(p, "Activity options");
    await tap(p, "Block Inés");
    await p.getByRole("dialog").getByRole("button", { name: "Block" }).click();
    await wait(700);
    check("block: blocking a host hides their activities", !(await body(p)).includes("Bouldering"));

    await p.evaluate(() => {
      const s = JSON.parse(localStorage.getItem("numaya.preview.v1"));
      s.state.prefs.simulateErrors = true;
      localStorage.setItem("numaya.preview.v1", JSON.stringify(s));
    });
    await p.reload();
    await wait(1000);
    check("error: a failed load explains itself and offers a retry", (await body(p)).includes("Couldn’t load activities") && (await p.getByRole("button", { name: "Try again" }).count()) === 1);
    await p.goto(`${base}flows.html?screen=activity-detail`);
    await wait(800);
    await tap(p, /Join|Request|waitlist/);
    await wait(700);
    check("error: a failed join changes nothing and offers a retry", (await body(p)).includes("Nothing changed") && !(await body(p)).includes("You’re going"));
    check("safety: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }

  /* Area and filters ----------------------------------------------- */
  {
    const p = await phone();
    await open(p, "activity");
    const all = await p.locator(".activity-card").count();
    await p.getByRole("button", { name: "Music", exact: true }).click();
    await wait(300);
    const music = await p.locator(".activity-card").count();
    await p.getByRole("button", { name: "All", exact: true }).click();
    await tap(p, /^Filters/);
    await p.getByRole("dialog").getByText("Today", { exact: true }).click();
    await p.getByRole("dialog").getByRole("button", { name: "Show activities" }).click();
    await wait(400);
    const today = await p.locator(".activity-card").allInnerTexts();
    check("filters: category and date change the list", music === 1 && all === 6 && today.length === 2 && today.every((t) => t.includes("Today")), `${all}/${music}/${today.length}`);
    await tap(p, /^Filters/);
    await p.getByRole("dialog").getByText("Any day", { exact: true }).click();
    await p.getByRole("dialog").getByText("Within 2 km", { exact: true }).click();
    await p.getByRole("dialog").getByRole("button", { name: "Show activities" }).click();
    await wait(400);
    const near = await p.locator(".activity-card").count();
    check("filters: distance narrows the list", near > 0 && near < all, String(near));
    await tap(p, /Near Hackney/);
    await p.getByRole("dialog").getByText("No area", { exact: true }).click();
    await wait(500);
    const t = await body(p);
    check("location: without an area, distances hide and the screen says why", t.includes("No area chosen") && !t.includes(" km") && (await p.locator(".activity-card").count()) === all);
  }

  /* 5 · Likes ------------------------------------------------------ */
  {
    const p = await phone();
    await open(p, "likes");
    const counts = {};
    for (const f of ["All", "Activity", "New", "Nearby"]) {
      await p.getByRole("button", { name: new RegExp(`^${f}`) }).first().click();
      await wait(250);
      counts[f] = (await p.locator(".person-tile").allInnerTexts()).map((t) => t.split(",")[0].replace(/New|Matched/, "").trim()).join("|");
    }
    check("likes: each filter shows a different, correct set", counts.All.split("|").length === 6 && counts.Activity === "Kemi|Rafa" && counts.New === "Kemi|Maya|Noor" && !counts.Nearby.includes("Tomás") && counts.Nearby !== counts.All, JSON.stringify(counts));
    await p.getByRole("button", { name: /^All/ }).first().click();
    await tap(p, /Rafa, 33/);
    check("likes: an already-matched like is handled, with Message instead of Like back", (await body(p)).includes("already matched") && (await p.getByRole("button", { name: "Like back" }).count()) === 0);
    await tap(p, "Back");
    await tap(p, /Inés, 24/);
    await tap(p, "Pass");
    await wait(900);
    check("likes: Pass removes that person (and only that person)", screenId(p) === "likes" && !(await body(p)).includes("Inés") && (await body(p)).includes("Maya"));
    await tap(p, /Maya, 29/);
    await tap(p, "Like back");
    check("likes: Like back matches the right person", screenId(p) === "match" && (await body(p)).includes("You and Maya liked each other"));
    await p.goto(`${base}flows.html?screen=likes`);
    await wait(800);
    check("likes: handled likes leave the list", !(await body(p)).includes("Maya"));
    check("likes: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }
  /* 6 · Search and open; 7 · opener, multiline, send -------------- */
  {
    const p = await phone();
    await open(p, "chats");
    const rows = () => p.locator(".conversation").allInnerTexts();
    check("messages: conversations list with unread state", (await rows()).length === 2 && (await p.locator(".conversation__unread").count()) === 1);
    await p.getByRole("searchbox", { name: "Search messages" }).fill("bakery");
    await wait(300);
    const byText = await rows();
    await p.getByRole("searchbox", { name: "Search messages" }).fill("raf");
    await wait(300);
    const byName = await rows();
    check("messages: search matches message text and names", byText.length === 1 && byText[0].includes("Priya") && byName.length === 1 && byName[0].includes("Rafa"));
    await p.getByRole("button", { name: /^Unread/ }).click();
    await wait(300);
    check("messages: search and filter combine (Rafa has no unread)", (await rows()).length === 0 && (await body(p)).includes("You’re all caught up"));
    await p.getByRole("button", { name: "Clear search" }).click();
    await wait(300);
    check("messages: clearing search keeps the filter", (await rows()).length === 1 && (await rows())[0].includes("Priya"));
    await p.locator(".conversation", { hasText: "Priya" }).click();
    await wait(600);
    check("messages: a row opens the right conversation", screenId(p) === "chat" && (await body(p)).includes("That bakery was unreal"));
    await tap(p, "Back to messages");
    check("messages: opening a conversation marks it read", (await p.locator(".conversation__unread").count()) === 0 && (await p.locator(".tab-bar__item", { hasText: "Messages" }).locator(".count-badge").count()) === 0);
    await p.getByRole("button", { name: /^All/ }).click();
    await p.locator(".match-queue__item", { hasText: "Jo" }).click();
    await wait(600);
    const openers = await p.locator(".fl-opener").allInnerTexts();
    await p.locator(".fl-opener").first().click();
    const inserted = await p.locator("textarea").inputValue();
    const focused = await p.evaluate(() => document.activeElement?.tagName);
    check("chat: openers insert into the composer and focus it", openers.length === 3 && inserted === openers[0] && focused === "TEXTAREA", inserted);
    await p.locator("textarea").press("End");
    await p.locator("textarea").press("Shift+Enter");
    await p.locator("textarea").type("Also, coffee this week?");
    const h = await p.locator(".composer__field").evaluate((e) => e.getBoundingClientRect().height);
    await p.locator("textarea").press("Enter");
    await wait(1000);
    const sent = await p.locator(".message--me .message__bubble").last().innerText();
    check("chat: a multiline message sends whole and the composer empties", sent.includes(openers[0]) && sent.includes("coffee this week") && (await p.locator("textarea").inputValue()) === "" && h > 44, `${Math.round(h)}px`);
    check("messages: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }

  /* 8 · Unmatch, block and report keep their meaning --------------- */
  {
    const outcome = async (action, steps) => {
      const p = await phone();
      await open(p, "chat");
      await tap(p, "Conversation options");
      await p.getByRole("button", { name: action, exact: true }).click();
      await wait(500);
      await steps(p);
      await wait(700);
      const text = await body(p);
      await p.goto(`${base}flows.html?screen=chats`);
      await wait(700);
      const inbox = await body(p);
      await p.goto(`${base}flows.html?screen=settings`);
      await wait(700);
      const settings = await body(p);
      const reports = await p.evaluate(() => JSON.parse(localStorage.getItem("numaya.preview.v1")).state.reports.length);
      await p.context().close();
      return { text, gone: !inbox.includes("Priya"), blockedCount: settings.match(/Blocked people (\d)/)?.[1], reports };
    };
    const u = await outcome("Unmatch", (p) => p.getByRole("dialog").getByRole("button", { name: "Unmatch" }).click());
    check("unmatch: closes the conversation without blocking or reporting", u.text.includes("You’ve unmatched Priya") && u.gone && u.blockedCount === "0" && u.reports === 0, JSON.stringify(u).slice(0, 160));
    const b = await outcome("Block", (p) => p.getByRole("dialog").getByRole("button", { name: "Block Priya" }).click());
    check("block: blocks without filing a report", b.text.includes("You’ve blocked Priya") && b.gone && b.blockedCount === "1" && b.reports === 0, JSON.stringify(b).slice(0, 160));
    const r = await outcome("Report", async (p) => {
      await p.getByRole("dialog").getByText("Scam or selling something", { exact: true }).click();
      await p.getByRole("dialog").getByRole("button", { name: "Send report" }).click();
    });
    check("report: records the report, blocks by default and says nothing was sent", r.text.includes("You’ve reported and blocked Priya") && r.text.includes("nothing is sent or reviewed") && r.blockedCount === "1" && r.reports === 1, JSON.stringify(r).slice(0, 160));
    const keep = await outcome("Report", async (p) => {
      await p.getByRole("dialog").getByText("Fake profile", { exact: true }).click();
      await p.getByRole("dialog").getByText("Also block Priya").click();
      await p.getByRole("dialog").getByRole("button", { name: "Send report" }).click();
    });
    check("report: without blocking, the conversation stays", !keep.gone && keep.reports === 1 && keep.blockedCount === "0", JSON.stringify(keep).slice(0, 160));
  }

  /* Home: undo, share, report, block -------------------------------- */
  {
    const p = await phone();
    await open(p, "discovery");
    const first = (await p.locator(".profile-card__name").first().innerText()).split(",")[0];
    check("home: no undo before a pass", (await p.getByRole("button", { name: /^Undo/ }).count()) === 0);
    await p.locator(".fl-screen__body").evaluate((e) => (e.scrollTop = e.scrollHeight));
    await tap(p, "Pass");
    await wait(400);
    const second = (await p.locator(".profile-card__name").first().innerText()).split(",")[0];
    await tap(p, new RegExp(`^Undo: bring back ${first}`));
    const back = (await p.locator(".profile-card__name").first().innerText()).split(",")[0];
    check("home: undo brings back the person just passed, once", first !== second && back === first && (await p.getByRole("button", { name: /^Undo/ }).count()) === 0, `${first} → ${second} → ${back}`);
    await tap(p, "Profile options");
    await tap(p, /Share/);
    check("home: share says honestly that nothing is shared in the preview", (await p.getByRole("dialog").innerText()).includes("nothing is shared"));
    await p.getByRole("dialog").getByRole("button", { name: "Close", exact: true }).first().click();
    await wait(400);
    await tap(p, "Profile options");
    await tap(p, new RegExp(`^Block ${first}`));
    await p.getByRole("alertdialog").getByRole("button", { name: "Block" }).click();
    await wait(600);
    const now = (await p.locator(".profile-card__name").first().innerText()).split(",")[0];
    check("home: blocking moves on and hides that person", now !== first);
    check("home: no console errors", p.errors.length === 0, p.errors.join(" | "));
  }
} catch (err) {
  check("product journeys completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} product checks passed.`);
process.exit(failed.length ? 1 : 0);
