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
  /* Motion: reduced-motion fallbacks and keyboard activation           */
  /* ---------------------------------------------------------------- */
  {
    const p = await page({ width: 1440, height: 900 }, { reducedMotion: "reduce" });
    await p.goto(`${base}flows.html`);
    await wait(1200);
    const rm = await p.evaluate(() => {
      const cs = (sel) => getComputedStyle(document.querySelector(sel));
      const secs = (v) => Math.max(...v.split(",").map((x) => parseFloat(x) * (x.includes("ms") ? 0.001 : 1)));
      return {
        profile: cs("#discovery .fl-pf").animationName,
        chip: cs("#interests .chip.is-selected").animationName,
        profileDur: secs(cs("#discovery .fl-pf").animationDuration),
        btnDur: secs(cs(".btn").transitionDuration),
      };
    });
    check("motion: reduced motion turns entrances into fades and drops the chip pop", rm.profile === "fade-in" && rm.chip === "none", `${rm.profile} / ${rm.chip}`);
    check("motion: reduced motion collapses transition and entrance durations", rm.profileDur <= 0.12 && rm.btnDur <= 0.12, `${rm.profileDur}s / ${rm.btnDur}s`);
    // Keyboard: Space toggles an interest chip; Enter on Like decides.
    const chip = p.locator("#interests .chip", { hasText: "Climbing" });
    await chip.focus();
    await p.keyboard.press("Space");
    await wait(200);
    check("keyboard: Space toggles an interest chip", (await chip.getAttribute("aria-pressed")) === "true");
    await p.keyboard.press("Space");
    await wait(200);
    const like = p.locator("#discovery").getByRole("button", { name: "Like", exact: true });
    await like.focus();
    const focusVisible = await p.evaluate(() => getComputedStyle(document.activeElement).outlineStyle !== "none");
    await p.keyboard.press("Enter");
    await wait(800);
    check("keyboard: Like has a visible focus ring and Enter opens the match", focusVisible && (await p.locator("#match").innerText()).includes("You and Maya liked each other"));
    check("motion: no console errors with reduced motion", p.errors.length === 0, p.errors.join(" | "));
    await p.evaluate(() => localStorage.clear());
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
          chipBg: cs("#interests .chip.is-selected").backgroundColor,
          chipRing: cs("#interests .chip.is-selected").boxShadow,
          chipSizes: (() => { const sel = document.querySelector("#interests .chip.is-selected"), un = document.querySelector("#interests .chip:not(.is-selected)"); const a = getComputedStyle(sel), b = getComputedStyle(un); return [sel.getBoundingClientRect().height, un.getBoundingClientRect().height, a.paddingLeft, b.paddingLeft]; })(),
          badgeDisc: cs("#intro .result__badge", "::before").backgroundColor,
          badgeIcon: cs("#intro .result__badge").color,
          chipFg: cs("#interests .chip.is-selected").color,
          slotFilled: cs("#photos .photo-slot .image-placeholder").backgroundColor,
          slotEmpty: cs("#photos .photo-slot--empty").backgroundColor,
          slotEmptyEdge: cs("#photos .photo-slot--empty").boxShadow,
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
      check("flows: selected chip is a light brand tint with a brand-pink ring and ink text", states.chipBg === "rgb(254, 238, 252)" && states.chipRing.includes(PINK) && states.chipFg === INK, `${states.chipBg} / ${states.chipFg}`);
      check("flows: selecting a chip keeps its size (no reflow)", states.chipSizes[0] === states.chipSizes[1] && states.chipSizes[2] === states.chipSizes[3], states.chipSizes.join(" / "));
      check("flows: success badge puts an ink check on a white inset disc", states.badgeDisc === "rgb(255, 255, 255)" && states.badgeIcon === INK, `${states.badgeDisc} / ${states.badgeIcon}`);
      check("photos: empty slots (white, hairline) are distinct from filled photo placeholders (grey)", states.slotEmpty === "rgb(255, 255, 255)" && /inset/.test(states.slotEmptyEdge) && states.slotFilled !== states.slotEmpty, `${states.slotFilled} vs ${states.slotEmpty}`);
      check("flows: switch on is ink (Meetup settings)", states.switchOn === INK, states.switchOn);
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
          chipCorner: cs("#interests .chip").cornerShape,
          identitySupported: CSS.supports("corner-shape", "superellipse(1.5)"),
          avatarShape: ["#chats .conversation .avatar__image", "#chats .match-queue .avatar__image", "#profile .avatar__image"].map((sel) => cs(sel).cornerShape),
          avatarRadius: cs("#chats .avatar__image").borderTopLeftRadius,
          ring: (() => {
            const r = document.querySelector("#profile .avatar__ring");
            const shown = [...r.querySelectorAll(".avatar__ring-shape")].filter((g) => getComputedStyle(g).display !== "none");
            const v = shown[0]?.querySelector(".avatar__ring-value");
            const box = r.getBoundingClientRect(), av = r.parentElement.getBoundingClientRect(), vb = v?.getBoundingClientRect();
            return { shown: shown.map((g) => g.classList[1]).join(), cap: v && getComputedStyle(v).strokeLinecap, stroke: v && getComputedStyle(v).stroke, width: v && getComputedStyle(v).strokeWidth, img: getComputedStyle(r.nextElementSibling).cornerShape, inside: vb && vb.left >= av.left - 0.5 && vb.top >= av.top - 0.5 && Math.abs(box.width - av.width) < 0.5 };
          })(),
          roundCorners: [".action-bar__btn", ".nav-button", ".avatar__badge", ".result__badge", ".composer__send"].map((sel) => document.querySelector(sel) && cs(sel).cornerShape).filter(Boolean),
          cardCorner: cs("#discovery .fl-pf__section").cornerShape,
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
          icons: document.querySelectorAll("#discovery svg.solar").length,
          foreignIcons: document.querySelectorAll("svg.ph, [class*='phosphor'], svg[viewBox='0 0 256 256']").length,
          activeTabFilled: !!document.querySelector("#discovery .tab-bar__item.is-current svg[class*='-bold']") && !document.querySelector("#discovery .tab-bar__item:not(.is-current) svg[class*='-bold']"),
          legacyStrokeIcons: document.querySelectorAll("#discovery svg[stroke-linecap='round'][viewBox='0 0 24 24']").length,
        };
      });
      check("geometry: buttons are pills (Meetup)", geo.btnRadius >= 999, `${geo.btnRadius}px`);
      check("geometry: squircle corners apply to cards where supported", !geo.squircleSupported || geo.cardCorner.includes("squircle"), `${geo.squircleSupported} / ${geo.cardCorner}`);
      check("shape: identity avatars use the soft superellipse where supported (circle fallback)", geo.avatarRadius === "50%" && (!geo.identitySupported || geo.avatarShape.every((c) => c.includes("superellipse(1.5)"))), `${geo.avatarShape.join(" / ")} / r ${geo.avatarRadius}`);
      check("shape: the completion ring traces the avatar shape (squircle, or circle fallback) with round caps in brand pink", geo.ring.shown === (geo.ring.img.includes("superellipse") ? "avatar__ring-shape--identity" : "avatar__ring-shape--round") && geo.ring.cap === "round" && geo.ring.stroke === PINK && geo.ring.width === "4px" && geo.ring.inside, JSON.stringify(geo.ring));
      check("shape: action circles, icon buttons, the verified dot and the success badge stay round", geo.roundCorners.length >= 4 && geo.roundCorners.every((c) => c === "round"), geo.roundCorners.join(" / "));
      check("geometry: pill buttons and chips stay true pills (no squircle)", !geo.btnCorner.includes("squircle") && !geo.chipCorner.includes("squircle"), `${geo.btnCorner} / ${geo.chipCorner}`);
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
        const r = (sel) => parseFloat(getComputedStyle(document.querySelector(sel)).borderTopLeftRadius);
        return { radius: parseFloat(s.borderTopLeftRadius), card: r("#discovery .fl-pf__section"), input: r("#basics .input"), bg: s.backgroundColor, ext: [...document.querySelectorAll("#discovery img")].filter((i) => /^https?:\/\/(?!localhost)/.test(i.src)).length, placeholders: document.querySelectorAll("#discovery .fl-pf__photo").length };
      });
      check("discover: photo areas are neutral grey placeholders and no images are hotlinked", imagery.bg === "rgb(215, 219, 225)" && imagery.ext === 0 && imagery.placeholders >= 1, JSON.stringify(imagery));
      check("geometry: corner hierarchy photo > card > input (32 / 24 / 16)", imagery.radius === 32 && imagery.card === 24 && imagery.input === 16, `${imagery.radius} / ${imagery.card} / ${imagery.input}`);
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
      const art = await p.evaluate(() => {
        const slots = [...document.querySelectorAll("[data-illustration]")];
        const fab = document.querySelector("#basics .fab").getBoundingClientRect();
        const screen = document.querySelector("#basics .fl-frame__screen").getBoundingClientRect();
        return {
          ids: slots.map((el) => el.dataset.illustration).sort(),
          hidden: slots.every((el) => el.getAttribute("aria-hidden") === "true" || el.getAttribute("alt") === ""),
          photoIsArt: document.querySelectorAll(".profile-card__media [data-illustration], .photo-slot [data-illustration], .match__photos [data-illustration]").length,
          fabVisible: fab.bottom <= screen.bottom,
        };
      });
      check("illustrations: planned slots are present and decorative", ["basics-spot", "interests-spot"].every((id) => art.ids.includes(id)) && art.hidden, art.ids.join(", "));
      check("illustrations: photo placeholders are never illustration slots", art.photoIsArt === 0);
      check("illustrations: the onboarding next button stays on screen", art.fabVisible);
      check("layout: profile photo strip keeps 4 columns; inbox rows are plain, not boxed (Bumble)", roll.stripCols === 4 && roll.inboxRows > 0 && !roll.inboxBoxed, `${roll.stripCols} cols / ${roll.inboxRows} rows / boxed ${roll.inboxBoxed}`);
      check("navigation: tab targets are at least 44px", geo.tabItemMin >= 44, `${Math.round(geo.tabItemMin)}px`);
      check("navigation: exactly one current tab", geo.tabCurrent === 1);
      check("icons: Solar glyphs render and no other icon family or legacy stroke icons remain", geo.icons > 0 && geo.foreignIcons === 0 && geo.legacyStrokeIcons === 0, `${geo.icons} solar / ${geo.foreignIcons} other / ${geo.legacyStrokeIcons} legacy`);
      check("icons: the current tab uses the filled Solar variant of its own symbol, other tabs stay linear", geo.activeTabFilled);

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
      const outcome = await p.evaluate(() => { const b = document.querySelector("#chat .result__badge"); const st = getComputedStyle(b); return { neutral: b.closest(".result").classList.contains("result--neutral"), bg: st.backgroundImage + " " + st.backgroundColor, shadow: st.boxShadow, disc: getComputedStyle(b, "::before").backgroundColor }; });
      check("flows: safety outcomes use the neutral badge (no brand pink or glow), still a white disc", outcome.neutral && !outcome.bg.includes(PINK) && !outcome.shadow.includes("247, 112, 227") && outcome.disc === "rgb(255, 255, 255)", JSON.stringify(outcome));
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
      await f("discovery").getByRole("button", { name: "Pass", exact: true }).click();
      await wait(500);
      const top = await p.evaluate(() => document.querySelector("#discovery .fl-screen__body").scrollTop);
      check("discover: after Pass the next profile starts at its photo, not mid-scroll", top === 0, `scrollTop ${top}`);

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
      await wait(500);
      const delSheet = p.getByRole("dialog", { name: "Delete your account?" });
      const delFocus = await p.evaluate(() => document.activeElement?.textContent);
      check("settings: delete confirms in a sheet with Cancel focused first", (await delSheet.count()) === 1 && delFocus === "Cancel", delFocus);
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
