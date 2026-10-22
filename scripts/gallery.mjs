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
  { group: 1, slug: "phone-entry", title: "Phone number (empty)", app: "proto", setup: (p) => p.getByRole("button", { name: "Create an account" }).click() },
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
  { group: 1, slug: "verify-code", title: "Verify code with the text-message banner", app: "proto", setup: (p) => toVerify(p) },
  {
    group: 1, slug: "verify-code-error", title: "Verify code: wrong code", notes: "Wrong code 111111 typed.", app: "proto",
    setup: async (p) => { await toVerify(p); await p.locator(".code__input").fill("111111"); await wait(2600); },
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
  { group: 1, slug: "verified-intro", title: "You’re verified → profile setup", screen: "intro" },
  { group: 1, slug: "basics", title: "The basics", screen: "basics" },
  { group: 1, slug: "basics-underage-error", title: "The basics: under-18 error", notes: "Birth year 2012 typed.", screen: "basics", setup: (p) => p.getByLabel("Year you were born").fill("2012") },
  { group: 1, slug: "interests-prompt", title: "Interests and prompt", screen: "interests" },
  {
    group: 1, slug: "interests-max", title: "Interests: five chosen, the rest locked", notes: "Seeded with five interests; unselected chips are disabled at the maximum.", screen: "interests",
    state: session({ profile: { interests: ["Natural wine", "Jazz", "Cooking", "Climbing", "Poetry"] } }),
  },
  { group: 1, slug: "photos", title: "Add photos", screen: "photos" },

  // 02 · Discover, profile and filters
  { group: 2, slug: "discover", title: "Discover profile card", screen: "discovery" },
  { group: 2, slug: "discover", title: "Discover: the full profile scroll", screen: "discovery", full: true },
  { group: 2, slug: "discover-filters-sheet", title: "Discover filters sheet", screen: "discovery", setup: (p) => p.getByRole("button", { name: /^Filters/ }).click() },
  { group: 2, slug: "discover-no-one-fits", title: "Discover: no one fits the filters", notes: "Seeded distance 1 km.", screen: "discovery", state: session({ prefs: { distance: 1 } }) },
  { group: 2, slug: "discover-seen-everyone", title: "Discover: seen everyone", notes: "Seeded with every sample profile already decided.", screen: "discovery", state: session({ seen: ALL_PEOPLE }) },
  { group: 2, slug: "discover-paused", title: "Discover paused (snoozed)", notes: "Seeded with Snooze on.", screen: "discovery", state: session({ prefs: { snooze: true } }) },

  // 03 · Matches and messaging
  { group: 3, slug: "match", title: "It’s a match", notes: "Seeded as right after liking Maya, who liked you.", screen: "match", state: session({ matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  { group: 3, slug: "match-empty", title: "No new match yet", screen: "match" },
  { group: 3, slug: "chats", title: "Chats: new matches and conversations", screen: "chats" },
  { group: 3, slug: "chats-alerts-off", title: "Chats: message alerts off banner", notes: "Seeded with new-message alerts off.", screen: "chats", state: session({ prefs: { messages: false } }) },
  { group: 3, slug: "chats-empty", title: "Chats: empty", notes: "Seeded with no matches.", screen: "chats", state: session({ matches: [], threads: {} }) },
  { group: 3, slug: "chat-conversation", title: "Conversation", screen: "chat" },
  { group: 3, slug: "chat-new-match", title: "Conversation: new match intro", notes: "Seeded with Jo (no messages yet) as the open chat.", screen: "chat", state: session({ activeChat: "jo" }) },
  { group: 3, slug: "chat-long-messages", title: "Conversation: long messages (edge case)", notes: "Edge case: seeded thread with long messages.", screen: "chat", state: session({ threads: LONG_THREAD }) },
  { group: 3, slug: "chat-options-menu", title: "Conversation options menu", screen: "chat", setup: (p) => p.getByRole("button", { name: "Conversation options" }).click() },
  { group: 3, slug: "chat-unmatch-sheet", title: "Unmatch confirmation sheet", screen: "chat", setup: (p) => openMenu(p, "Unmatch") },
  { group: 3, slug: "chat-report-sheet", title: "Report or block sheet", screen: "chat", setup: (p) => openMenu(p, "Report or block") },
  { group: 3, slug: "chat-unmatched", title: "Ended: unmatched", notes: "Seeded: Priya unmatched.", screen: "chat", state: session({ ended: { priya: "unmatched" } }) },
  { group: 3, slug: "chat-blocked", title: "Ended: blocked and reported", notes: "Seeded: Priya blocked and reported.", screen: "chat", state: session({ ended: { priya: "blocked" } }) },

  // 04 · Profile and settings
  { group: 4, slug: "profile", title: "My profile", screen: "profile" },
  { group: 4, slug: "profile", title: "My profile (full page)", screen: "profile", full: true },
  { group: 4, slug: "profile-long-name", title: "My profile: long name (edge case)", notes: "Edge case: seeded 21-character name.", screen: "profile", state: session({ profile: { name: "Maximiliana-Josephine" } }) },
  { group: 4, slug: "edit-profile", title: "Edit profile", screen: "edit" },
  { group: 4, slug: "edit-profile", title: "Edit profile (full page)", screen: "edit", full: true },
  { group: 4, slug: "edit-photo-options", title: "Edit profile: photo options sheet", screen: "edit", setup: (p) => p.getByRole("button", { name: "Photo 2: options" }).click() },
  {
    group: 4, slug: "edit-name-error", title: "Edit profile: empty name error", screen: "edit", scrollTo: "First name",
    setup: (p) => p.getByLabel("First name").fill(""),
  },
  { group: 4, slug: "edit-preview", title: "Edit profile: Preview", screen: "edit", setup: (p) => p.getByRole("tab", { name: "Preview" }).click() },
  { group: 4, slug: "edit-preview", title: "Edit profile: Preview (full page)", screen: "edit", full: true, setup: (p) => p.getByRole("tab", { name: "Preview" }).click() },
  { group: 4, slug: "prompt-editor", title: "Edit prompt", screen: "prompt" },
  {
    group: 4, slug: "prompt-editor-changed", title: "Edit prompt: new question and answer, ready to save", screen: "prompt",
    setup: async (p) => { await p.getByText("My Sunday ritual").click(); await p.getByLabel("Your answer").fill("Farmers market, then a very long lunch."); },
  },
  { group: 4, slug: "settings", title: "Settings", screen: "settings" },
  { group: 4, slug: "settings", title: "Settings (full page)", screen: "settings", full: true },
  { group: 4, slug: "settings-delete-sheet", title: "Delete account sheet", screen: "settings", setup: (p) => p.getByRole("button", { name: "Delete account" }).click() },

  // 05 · Desktop context
  { group: 5, slug: "desktop-prototype", title: "Desktop: onboarding prototype with brief", app: "proto", viewport: DESKTOP },
  { group: 5, slug: "desktop-flow-previews", title: "Desktop: flow previews gallery", url: "flows.html", viewport: DESKTOP },
  { group: 5, slug: "desktop-edit-profile", title: "Desktop: flow previews, Profile → Edit profile → Edit prompt", url: "flows.html#profile", viewport: DESKTOP, scrollToFrame: "edit" },
  { group: 5, slug: "desktop-design-system", title: "Desktop: design-system showcase", url: "showcase.html", viewport: DESKTOP },
];

const GROUPS = {
  1: { file: "01-onboarding", title: "Onboarding" },
  2: { file: "02-discover-profile-filters", title: "Discover, profile and filters" },
  3: { file: "03-matches-messaging", title: "Matches and messaging" },
  4: { file: "04-profile-settings", title: "Profile, editing and settings" },
  5: { file: "05-desktop", title: "Desktop context" },
};

async function toVerify(p) {
  await p.getByRole("button", { name: "Create an account" }).click();
  await wait(900);
  await p.locator("#phone-number").fill("4155550132");
  await p.getByRole("button", { name: "Send code" }).click();
  await wait(3200);
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
    const mobile = vp === MOBILE;
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
    await sheet(`Numaya · ${title}`, items, `contact-sheets/${file}.png`, g === "5" ? 480 : 220);
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
  "- States are reached by interaction, or by seeding the preview's saved session for states that take",
  "  many steps (see `state` in [manifest.json](manifest.json)). Captured with reduced motion so",
  "  animations show their settled frame; the demo verification code is fixed.",
  "- Photo areas and illustration slots are neutral placeholders until licensed photography and",
  "  artwork are supplied.",
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
