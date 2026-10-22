#!/usr/bin/env node
/**
 * Browser smoke test for the prototype and the design-system showcase.
 *
 *   npm run test:e2e
 *
 * Starts a Vite dev server, drives the real UI in Chromium, asserts behaviour,
 * and writes screenshots to tests/e2e/artifacts/ for visual review.
 * Requires a Playwright Chromium (`npx playwright install chromium` on a fresh machine).
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

async function page(viewport, opts = {}) {
  const ctx = await browser.newContext({ viewport, deviceScaleFactor: 2, ...opts });
  const p = await ctx.newPage();
  p.errors = [];
  p.on("pageerror", (e) => p.errors.push(e.message));
  p.on("console", (m) => m.type() === "error" && p.errors.push(m.text()));
  return p;
}

try {
  /* ---------------------------------------------------------------- */
  /* Prototype, desktop simulator                                      */
  /* ---------------------------------------------------------------- */
  {
    const p = await page({ width: 1440, height: 900 });
    await p.goto(base);
    await wait(1500);
    await p.screenshot({ path: `${OUT}/prototype-welcome.png` });

    const emphasis = await p.evaluate(() => {
      const el = document.querySelector(".welcome__emphasis");
      const after = [...document.querySelectorAll(".welcome__title *")].some(
        (e) => !["none", "normal"].includes(getComputedStyle(e, "::after").content),
      );
      return { color: el && getComputedStyle(el).color, after };
    });
    check("headline emphasis is exactly #F770E3", emphasis.color === "rgb(247, 112, 227)", emphasis.color);
    check("headline has no decorative underline", !emphasis.after);

    const mark = await p.evaluate(() => getComputedStyle(document.querySelector(".welcome__lockup .wordmark rect[mask]")).fill);
    check("wordmark mark is the brand pink", mark === "rgb(247, 112, 227)", mark);

    await p.getByRole("button", { name: "Create an account" }).click();
    await wait(900);
    await p.getByRole("button", { name: /^Country:/ }).click();
    await wait(700);
    const geo = await p.evaluate(() => {
      const edges = (el) => {
        const r = el.getBoundingClientRect();
        return [Math.round(r.left), Math.round(r.right)];
      };
      const s = edges(document.querySelector(".search"));
      const rows = [...document.querySelectorAll(".country-row")].map(edges);
      const sel = document.querySelector(".country-row.is-selected");
      const c = sel.querySelector(".country-row__check svg").getBoundingClientRect();
      const r = sel.getBoundingClientRect();
      return { aligned: rows.every((x) => x[0] === s[0] && x[1] === s[1]), inside: c.right <= r.right - 8 };
    });
    check("country rows align with the search field", geo.aligned);
    check("selected check stays inside its row", geo.inside);
    await p.screenshot({ path: `${OUT}/prototype-country.png` });
    await p.keyboard.press("Escape");
    await wait(500);
    const restored = await p.evaluate(() => document.activeElement?.id);
    check("closing the sheet returns focus to the country button", restored === "phone-country", restored);

    await p.locator("#phone-number").click();
    await p.keyboard.type("4155550132");
    check("Send code enabled for a complete number", await p.getByRole("button", { name: "Send code" }).isEnabled());
    await p.keyboard.press("Enter");
    await wait(3300);
    check("verification screen reached", (await p.locator("#verify-title").count()) === 1);
    await p.locator(".keypad__suggestion").click({ timeout: 5000 });
    await wait(3200);
    const badge = await p.evaluate(() => {
      const el = document.querySelector(".result__badge");
      return el && { bg: getComputedStyle(el).backgroundColor, fg: getComputedStyle(el).color };
    });
    check("verified badge fill is exactly #F770E3", badge?.bg === "rgb(247, 112, 227)", badge?.bg);
    check("verified badge check is dark ink, not white", badge?.fg === "rgb(20, 23, 31)", badge?.fg);
    await p.screenshot({ path: `${OUT}/prototype-verified.png` });

    await p.getByRole("button", { name: "Start over" }).first().click();
    await wait(900);
    await p.getByRole("button", { name: "I have an account" }).click();
    await wait(900);
    await p.getByRole("button", { name: "Back" }).click();
    await wait(900);
    check("back navigation returns to welcome", (await p.locator("#welcome-title").count()) === 1);
    check("prototype has no console errors", p.errors.length === 0, p.errors.join(" | "));
  }

  /* ---------------------------------------------------------------- */
  /* Prototype on phones, plus reduced motion                          */
  /* ---------------------------------------------------------------- */
  for (const [name, vp] of [
    ["iphone-15", { width: 393, height: 852 }],
    ["iphone-se", { width: 375, height: 667 }],
  ]) {
    const p = await page(vp, { isMobile: true, hasTouch: true, reducedMotion: name === "iphone-se" ? "reduce" : "no-preference" });
    await p.goto(base);
    await wait(1200);
    await p.screenshot({ path: `${OUT}/prototype-${name}-welcome.png` });
    await p.getByRole("button", { name: "Create an account" }).click();
    await wait(900);
    await p.locator("#phone-number").fill("4155550132");
    await p.getByRole("button", { name: "Send code" }).click();
    await wait(3000);
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    check(`${name}: flow reaches verification`, (await p.locator("#verify-title").count()) === 1);
    check(`${name}: no horizontal overflow`, overflow <= 0, `${overflow}px`);
    await p.screenshot({ path: `${OUT}/prototype-${name}-verify.png` });
  }

  /* ---------------------------------------------------------------- */
  /* Showcase                                                          */
  /* ---------------------------------------------------------------- */
  for (const [name, vp] of [
    ["desktop", { width: 1440, height: 900 }],
    ["mobile", { width: 390, height: 844 }],
  ]) {
    const p = await page(vp);
    await p.goto(`${base}showcase.html`);
    await wait(1200);
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    check(`showcase ${name}: no horizontal overflow`, overflow <= 0, `${overflow}px`);
    const unlabelled = await p.evaluate(
      () =>
        [...document.querySelectorAll("button")].filter(
          (b) => !b.closest("[aria-hidden='true']") && !(b.getAttribute("aria-label") || b.textContent.trim()),
        ).length,
    );
    check(`showcase ${name}: every button has an accessible name`, unlabelled === 0, `${unlabelled} unlabelled`);
    if (name === "desktop") {
      const frame = p.locator(".sc-phone", { hasText: "Settings and system states" });
      await frame.getByRole("button", { name: "Delete account" }).click();
      await wait(400);
      const focused = await p.evaluate(() => document.activeElement?.textContent);
      check("destructive dialog focuses Cancel first", focused === "Cancel", focused);
      await p.keyboard.press("Escape");
      await wait(300);
    }
    await p.screenshot({ path: `${OUT}/showcase-${name}.png`, fullPage: name === "mobile" ? false : true });
    check(`showcase ${name}: no console errors`, p.errors.length === 0, p.errors.join(" | "));
  }

  /* ---------------------------------------------------------------- */
  /* Product flow previews                                             */
  /* ---------------------------------------------------------------- */
  for (const [name, vp] of [
    ["desktop", { width: 1440, height: 900 }],
    ["375", { width: 375, height: 667 }],
  ]) {
    const p = await page(vp);
    await p.goto(`${base}flows.html`);
    await wait(1200);
    check(`flows ${name}: 10 preview screens render`, (await p.locator(".fl-frame").count()) === 10);
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    check(`flows ${name}: no horizontal overflow`, overflow <= 0, `${overflow}px`);
    if (name === "desktop") {
      const f = (id) => p.locator(`#${id}`);
      const textOf = async (id) => (await f(id).innerText()).replace(/\s+/g, " ");
      const header = await p.evaluate(() => getComputedStyle(document.querySelector(".fl-top")).position);
      check("flows: navigation strip is not sticky", header !== "sticky" && header !== "fixed", header);

      // Brand pink in real interactive states (computed styles), and no legacy blue anywhere on the page.
      const PINK = "rgb(247, 112, 227)";
      const INK = "rgb(20, 23, 31)";
      const states = await p.evaluate(() => {
        const cs = (sel, pseudo) => getComputedStyle(document.querySelector(sel), pseudo);
        return {
          likeBg: cs("#discovery .action-bar__btn--like").backgroundImage,
          likeFg: cs("#discovery .action-bar__btn--like").color,
          superBg: cs("#discovery .profile-card .action-bar__btn--super").backgroundColor,
          superFg: cs("#discovery .profile-card .action-bar__btn--super").color,
          chipShadow: cs("#interests .chip.is-selected").boxShadow,
          switchOn: cs("#settings .switch:checked").backgroundColor,
          tabActive: cs("#discovery .tab-bar__item.is-current").backgroundColor,
          tabActiveFg: cs("#discovery .tab-bar__item.is-current").color,
          tabActiveIcon: cs("#discovery .tab-bar__item.is-current .tab-bar__icon > svg").color,
          progress: cs("#basics .progress__segment.is-done .progress__fill").backgroundColor,
          verified: cs("#chats .avatar__badge, #discovery .verified__mark").backgroundColor,
        };
      });
      check("flows: like is an ink circle (Meetup primary sheen) with a white glyph", states.likeBg.includes(INK) && states.likeFg === "rgb(255, 255, 255)", `${states.likeBg.slice(0, 60)} / ${states.likeFg}`);
      check("flows: SuperSwipe is the single brand-pink action, with an ink glyph", states.superBg === PINK && states.superFg === INK, `${states.superBg} / ${states.superFg}`);
      check("flows: selected chip uses the brand pink border", states.chipShadow.includes(PINK), states.chipShadow.slice(0, 60));
      check("flows: switch on uses brand pink", states.switchOn === PINK, states.switchOn);
      check("flows: active tab sits on a grey pill with a pink icon and an ink label (Meetup)", states.tabActive === "rgb(236, 239, 243)" && states.tabActiveFg === INK && states.tabActiveIcon === PINK, `${states.tabActive} / ${states.tabActiveFg} / ${states.tabActiveIcon}`);
      check("flows: progress fill uses brand pink", states.progress === PINK, states.progress);
      // Geometry, elevation, icons and bottom navigation.
      const geo = await p.evaluate(() => {
        const cs = (sel) => getComputedStyle(document.querySelector(sel));
        const alpha = (v) => Math.max(0, ...[...v.matchAll(/rgba\(\d+, \d+, \d+, ([0-9.]+)\)/g)].map((m) => parseFloat(m[1])));
        const tab = document.querySelector("#discovery .tab-bar");
        const items = [...tab.querySelectorAll(".tab-bar__item")].map((i) => i.getBoundingClientRect());
        return {
          btnRadius: parseFloat(cs("#settings .btn--secondary, #basics .btn, .btn").borderTopLeftRadius),
          squircleSupported: CSS.supports("corner-shape", "squircle"),
          btnCorner: cs(".btn").cornerShape,
          promptShadowAlpha: alpha(cs("#profile .prompt").boxShadow),
          tabShadow: getComputedStyle(tab).boxShadow,
          tabRadius: parseFloat(getComputedStyle(tab).borderTopLeftRadius),
          tabPad: parseFloat(getComputedStyle(tab).paddingTop),
          tabItemRadius: parseFloat(getComputedStyle(tab.querySelector(".tab-bar__item")).borderTopLeftRadius),
          photoShare: (() => { const c = document.querySelector("#discovery .profile-card__media").getBoundingClientRect(), s = document.querySelector("#discovery .fl-screen").getBoundingClientRect(); return { w: c.width / s.width, h: c.height / s.height }; })(),
          tabInset: (() => { const f = tab.closest(".fl-screen").getBoundingClientRect(), r = tab.getBoundingClientRect(); return Math.min(r.left - f.left, f.right - r.right, f.bottom - r.bottom); })(),
          tabBelowBody: tab.getBoundingClientRect().top >= document.querySelector("#discovery .fl-screen__body").getBoundingClientRect().bottom - 0.5,
          cardBorder: getComputedStyle(document.querySelector("#discovery .profile-card")).borderTopWidth,
          pageBg: getComputedStyle(document.querySelector("#discovery .fl-screen")).backgroundColor,
          superTop: document.querySelector("#discovery .profile-card .action-bar__btn--super").getBoundingClientRect().bottom <= tab.getBoundingClientRect().top,
          actionsAfterSections: (() => { const secs = document.querySelectorAll("#discovery .fl-pf__section"); const bar = document.querySelector("#discovery .fl-pf > .action-bar"); return secs.length >= 2 && [...secs].every((s) => s.compareDocumentPosition(bar) & Node.DOCUMENT_POSITION_FOLLOWING); })(),
          tabItemMin: Math.min(...items.map((r) => Math.min(r.width, r.height))),
          tabCurrent: tab.querySelectorAll(".tab-bar__item[aria-current='page']").length,
          icons: document.querySelectorAll("#discovery svg.ph, #discovery [class*='phosphor'], #discovery svg[viewBox='0 0 256 256']").length,
          legacyStrokeIcons: document.querySelectorAll("#discovery svg[stroke-linecap='round'][viewBox='0 0 24 24']").length,
        };
      });
      check("geometry: buttons are pills (Meetup)", geo.btnRadius >= 999, `${geo.btnRadius}px`);
      check("geometry: squircle corners apply where supported", !geo.squircleSupported || geo.btnCorner.includes("squircle"), `${geo.squircleSupported} / ${geo.btnCorner}`);
      check("elevation: card shadow is very light", geo.promptShadowAlpha > 0 && geo.promptShadowAlpha <= 0.08, `alpha ${geo.promptShadowAlpha}`);
      const tabAlpha = Math.max(0, ...[...geo.tabShadow.matchAll(/rgba\(\d+, \d+, \d+, ([0-9.]+)\)/g)].map((m) => parseFloat(m[1])));
      check("navigation: floating capsule inset from the edges with a soft shadow (Meetup)", geo.tabInset >= 8 && geo.tabRadius >= 999 && tabAlpha > 0 && tabAlpha <= 0.14, `inset ${geo.tabInset} / radius ${geo.tabRadius} / alpha ${tabAlpha}`);
      check("navigation: bar sits below the scrolling content, never over it", geo.tabBelowBody);
      check("discover: SuperSwipe sits on the photo, above the tab bar, without scrolling", geo.superTop);
      check("discover: Pass and Like follow the profile, after its sections (reference)", geo.actionsAfterSections);
      check("discover: the photo dominates the screen (≥ 90% width, ≥ 55% height)", geo.photoShare.w >= 0.9 && geo.photoShare.h >= 0.55, `${geo.photoShare.w.toFixed(2)} × ${geo.photoShare.h.toFixed(2)}`);
      const cardEdge = await p.evaluate(() => getComputedStyle(document.querySelector("#discovery .fl-pf__section")).boxShadow);
      check("surfaces: white page; section cards separate with a hairline, not a heavy shadow (Meetup)", geo.pageBg === "rgb(255, 255, 255)" && geo.cardBorder === "0px" && /inset/.test(cardEdge), `${geo.pageBg} / ${cardEdge.slice(0, 60)}`);
      const imagery = await p.evaluate(() => {
        const media = document.querySelector("#discovery .profile-card__media");
        const s = getComputedStyle(media);
        return { radius: parseFloat(s.borderTopLeftRadius), bg: s.backgroundColor, ext: [...document.querySelectorAll("#discovery img")].filter((i) => /^https?:\/\/(?!localhost)/.test(i.src)).length, placeholders: document.querySelectorAll("#discovery .fl-pf__photo").length };
      });
      check("discover: photo areas are neutral grey placeholders with 24px corners and no hotlinked images", imagery.radius === 24 && imagery.bg === "rgb(215, 219, 225)" && imagery.ext === 0 && imagery.placeholders >= 1, JSON.stringify(imagery));
      const roll = await p.evaluate(() => {
        const cs = (sel) => getComputedStyle(document.querySelector(sel));
        const body = document.querySelector("#chat .fl-screen__body").getBoundingClientRect();
        const last = [...document.querySelectorAll("#chat .message")].at(-1).getBoundingClientRect();
        return {
          pages: ["chats", "chat", "profile", "settings", "match"].map((id) => cs(`#${id} .fl-screen`).backgroundColor),
          page: cs("#discovery .fl-screen").backgroundColor,
          mine: cs("#chat .message--me .message__bubble").backgroundColor,
          mineFg: cs("#chat .message--me .message__bubble").color,
          theirs: cs("#chat .message--them .message__bubble").backgroundColor,
          chip: cs("#interests .chip:not(.is-selected)").boxShadow,
          lastVisible: last.bottom <= body.bottom + 0.5,
          stripCols: cs("#profile .fl-photo-strip").gridTemplateColumns.split(" ").length,
          inboxRows: document.querySelectorAll("#chats .conversation").length,
          inboxBoxed: [...document.querySelectorAll("#chats .conversation, #chats .fl-list")].some((el) => getComputedStyle(el).boxShadow !== "none" || getComputedStyle(el).backgroundColor !== "rgba(0, 0, 0, 0)"),
        };
      });
      check("surfaces: tab roots, chat, match and settings share the page tint", roll.pages.every((c) => c === roll.page), roll.pages.join(" | "));
      check("chat: outgoing bubbles are brand pink with ink text, incoming light grey (Bumble + Meetup)", roll.mine === PINK && roll.mineFg === INK && roll.theirs === "rgb(236, 239, 243)", `${roll.mine} / ${roll.mineFg} / ${roll.theirs}`);
      check("selection: unselected chips are filled, not outlined", roll.chip === "none", roll.chip);
      check("chat: the last message sits above the composer", roll.lastVisible);
      check("layout: profile photo strip keeps 4 columns; inbox rows are plain, not boxed (Bumble)", roll.stripCols === 4 && roll.inboxRows > 0 && !roll.inboxBoxed, `${roll.stripCols} cols / ${roll.inboxRows} rows / boxed ${roll.inboxBoxed}`);
      check("navigation: tab targets are at least 44px", geo.tabItemMin >= 44, `${Math.round(geo.tabItemMin)}px`);
      check("navigation: exactly one current tab", geo.tabCurrent === 1);
      check("icons: Phosphor glyphs render and no legacy stroke icons remain", geo.icons > 0 && geo.legacyStrokeIcons === 0, `${geo.icons} phosphor / ${geo.legacyStrokeIcons} legacy`);

      await f("basics").getByLabel("First name").focus();
      await wait(500); // let the focus-ring transition finish before reading computed styles
      const focus = await p.evaluate(() => getComputedStyle(document.querySelector("#basics .input:focus")).boxShadow);
      check("flows: field focus is an ink ring with a pink halo", focus.includes(INK) && focus.includes("rgba(247, 112, 227"), focus.slice(0, 80));
      for (const [name, path] of [["prototype", ""], ["flows", "flows.html"], ["showcase", "showcase.html"]]) {
        const q = await page({ width: 1440, height: 900 });
        await q.goto(base + path);
        await wait(1200);
        const legacy = await q.evaluate(() => {
          const re = /99, 175, 233|31, 111, 176|23, 80, 127|63, 146, 212/;
          let n = 0;
          for (const el of document.querySelectorAll("*")) {
            const s = getComputedStyle(el);
            if ([s.color, s.backgroundColor, s.borderColor, s.boxShadow, s.outlineColor, s.fill, s.stroke].some((v) => re.test(v))) n++;
          }
          return n;
        });
        check(`${name}: no legacy blue is rendered`, legacy === 0, `${legacy} elements`);
      }

      await f("basics").getByLabel("First name").fill("Jordan");
      check("flows: profile edits carry to the profile screen", (await textOf("profile")).includes("Jordan"));

      await f("discovery").getByRole("button", { name: "Like", exact: true }).click();
      await wait(600);
      check("flows: liking Maya opens the match screen", (await textOf("match")).includes("You and Maya liked each other"));

      await f("match").getByRole("textbox", { name: "Message" }).fill("Which record shop?");
      await p.keyboard.press("Enter");
      await wait(900);
      check("flows: the match opens Maya’s conversation with the message", (await textOf("chat")).includes("Which record shop?") && (await textOf("chat")).includes("Maya"));
      check("flows: a message sent from the match is delivered", !(await textOf("chat")).includes("Sending"));

      await f("chat").getByRole("textbox", { name: "Message" }).fill("Saturday works.");
      await p.keyboard.press("Enter");
      await wait(900);
      await f("chats").getByRole("button", { name: /Priya/ }).click();
      await wait(400);
      await f("chats").getByRole("button", { name: /Maya/ }).click();
      await wait(400);
      check("flows: sent messages persist after switching chats", (await textOf("chat")).includes("Saturday works."));
      check("flows: inbox preview shows the latest message", (await textOf("chats")).includes("You: Saturday works."));

      // Options menu → Unmatch opens a bottom sheet (Bumble), which can be dismissed without ending the chat.
      await f("chat").getByRole("button", { name: "Conversation options" }).click();
      await wait(500);
      await p.getByRole("button", { name: "Unmatch", exact: true }).click();
      await wait(500);
      const unmatch = p.getByRole("dialog", { name: "Unmatch Maya?" });
      check("chat: unmatch confirms in a sheet that offers reporting instead", (await unmatch.count()) === 1 && (await unmatch.innerText()).includes("Report them instead"));
      await p.keyboard.press("Escape");
      await wait(500);
      check("chat: dismissing the unmatch sheet keeps the conversation", (await textOf("chat")).includes("Saturday works.") && (await p.getByRole("dialog").count()) === 0);
      await f("chat").getByRole("button", { name: "Conversation options" }).click();
      await wait(500);
      await p.getByRole("button", { name: "Report or block" }).click();
      await wait(600);
      await p.getByRole("button", { name: "Fake profile" }).click();
      await wait(600);
      check("flows: report ends in a block confirmation", (await textOf("chat")).includes("You’ve blocked and reported Maya"));
      check("flows: blocked person leaves the inbox", !(await textOf("chats")).includes("Maya"));
      check("flows: settings counts the blocked person", /Blocked people 1/.test(await textOf("settings")));
      await f("chats").getByRole("button", { name: /Jo/ }).first().click();
      await wait(500);
      check("chat: a new match opens on the centred intro before the first message (Bumble)", (await textOf("chat")).includes("Jo, 32") && (await f("chat").locator(".message").count()) === 0);

      const clipped = await p.evaluate(() =>
        [...document.querySelectorAll(".fl-screen__body")].filter((b) => b.scrollWidth > b.clientWidth + 1).map((b) => b.closest(".fl-frame").id),
      );
      check("flows: no screen content overflows sideways", clipped.length === 0, clipped.join(", "));
      // Swipe: drag Sam's card (next after Maya) left past the threshold to pass.
      const before = await textOf("discovery");
      const card = f("discovery").locator(".fl-swipe");
      await card.scrollIntoViewIfNeeded();
      const box = await card.boundingBox();
      const y = box.y + box.height / 3;
      await p.mouse.move(box.x + box.width / 2, y);
      await p.mouse.down();
      await p.mouse.move(box.x + box.width / 2 - 160, y, { steps: 8 });
      await p.mouse.up();
      await wait(500);
      const after = await textOf("discovery");
      check("flows: swiping left passes to the next profile", before.includes("Sam, 31") && after.includes("Noor, 28"));

      // Filters: narrowing distance empties Discover; the empty state widens it again.
      const dist = f("settings").getByLabel("Distance");
      await dist.fill("1");
      await wait(200);
      check("flows: distance filter empties Discover", (await textOf("discovery")).includes("No one fits your filters"));
      await f("discovery").getByRole("button", { name: "Widen age and distance" }).click();
      await wait(300);
      const filterName = async () => (await f("discovery").getByRole("button", { name: /^Filters:/ }).getAttribute("aria-label")) ?? "";
      check("flows: widening filters brings people back", (await filterName()).includes("Ages 18–70") && !(await textOf("discovery")).includes("No one fits your filters"));

      // Snooze pauses Discover, survives reload, and Resume restores it.
      await f("settings").getByRole("switch", { name: /Snooze/ }).check();
      await wait(1000);
      check("flows: snooze gives feedback", (await textOf("settings")).includes("Snoozed. Discover is paused."));
      check("flows: snooze pauses Discover", (await textOf("discovery")).includes("Discover is paused") && (await textOf("profile")).includes("Snoozed"));
      await p.reload();
      await wait(1200);
      check("flows: snooze persists across reload", (await textOf("discovery")).includes("Discover is paused"));
      await f("discovery").getByRole("button", { name: "Resume" }).click();
      await wait(300);
      check("flows: Resume restores Discover", (await f("discovery").getByRole("button", { name: /^Filters:/ }).count()) === 1 && !(await textOf("discovery")).includes("Discover is paused") && !(await textOf("profile")).includes("Snoozed"));

      // Message alerts: off shows feedback and a Chats banner; the banner turns them back on.
      await f("settings").getByRole("switch", { name: /New messages/ }).uncheck();
      await wait(1000);
      check("flows: alerts off gives feedback", (await textOf("settings")).includes("New message alerts off"));
      check("flows: Chats shows alerts-off banner", (await textOf("chats")).includes("New message alerts are off"));
      await f("chats").getByRole("button", { name: "Turn on" }).click();
      await wait(300);
      check("flows: banner turns alerts back on", !(await textOf("chats")).includes("alerts are off") && (await f("settings").getByRole("switch", { name: /New messages/ }).isChecked()));
      await f("settings").getByRole("switch", { name: /New messages/ }).uncheck();
      await wait(1000);

      // Persistence: reload keeps the session; delete account clears it.
      await p.reload();
      await wait(1200);
      check("flows: reload restores the session", (await textOf("profile")).includes("Jordan") && (await textOf("settings")).includes("Blocked people 1"));
      await f("settings").getByRole("button", { name: "Delete account" }).click();
      await wait(400);
      await p.getByRole("button", { name: "Delete account" }).last().click();
      await wait(400);
      await p.reload();
      await wait(1200);
      const saved = await p.evaluate(() => localStorage.getItem("numaya.preview.v1"));
      check("flows: delete account clears saved data", saved === null && (await textOf("profile")).includes("Alex"));
      check(
        "flows: delete account restores default settings",
        !(await textOf("chats")).includes("alerts are off") && (await f("settings").getByRole("switch", { name: /Snooze/ }).isChecked()) === false,
      );

      for (const id of ["basics", "discovery", "match", "chats", "chat", "profile", "settings"]) {
        await f(id).locator(".fl-frame__screen").screenshot({ path: `${OUT}/flows-${id}.png` });
      }
    } else {
      await p.screenshot({ path: `${OUT}/flows-375.png` });
    }
    check(`flows ${name}: no console errors`, p.errors.length === 0, p.errors.join(" | "));
  }
} catch (err) {
  check("smoke run completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} checks passed. Screenshots: tests/e2e/artifacts/`);
process.exit(failed.length ? 1 : 0);
