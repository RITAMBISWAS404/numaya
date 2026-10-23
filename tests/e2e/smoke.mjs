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

    const heading = await p.evaluate(() => {
      const t = document.querySelector(".welcome__title");
      const parts = [t, ...t.querySelectorAll("*")].map((e) => getComputedStyle(e).color);
      return { colours: [...new Set(parts)], em: t.querySelectorAll("em, .emphasis, [class*='emphasis']").length, text: t.textContent };
    });
    check("welcome: the headline is one colour (near-black), no coloured-word emphasis", heading.colours.length === 1 && heading.colours[0] === "rgb(20, 19, 22)" && heading.em === 0 && /Better first dates/.test(heading.text), JSON.stringify(heading));

    const hero = await p.evaluate(() => {
      const h = document.querySelector(".welcome__hero");
      const slot = h.querySelector("[data-illustration='welcome-hero']");
      return { logo: h.querySelectorAll(".wordmark").length, ribbon: h.querySelectorAll(".ribbon").length, bg: getComputedStyle(slot).backgroundColor, w: Math.round(slot.getBoundingClientRect().width) };
    });
    check("welcome: the hero holds an invisible reserved slot (no logo, ribbon or grey box)", hero.logo === 0 && hero.ribbon === 0 && hero.bg === "rgba(0, 0, 0, 0)" && hero.w >= 200, JSON.stringify(hero));
    const welcome = await p.evaluate(() => {
      const a = document.querySelector(".legal a");
      return { slot: !!document.querySelector("[data-illustration='welcome-hero']"), stack: document.querySelectorAll(".prompt-card").length, link: { color: getComputedStyle(a).color, line: getComputedStyle(a).textDecorationColor } };
    });
    check("welcome: the hero is a reserved illustration slot (no prompt-card stack)", welcome.slot && welcome.stack === 0);
    check("welcome: legal links are brand purple with a thin purple underline", welcome.link.color === "rgb(114, 98, 199)" && /0\.447059 0\.384314 0\.780392|114, 98, 199/.test(welcome.link.line), JSON.stringify(welcome.link));

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
    const otp = await p.evaluate(() => {
      const cells = [...document.querySelectorAll(".code__cell")];
      const active = document.querySelector(".code__cell.is-active");
      return { n: cells.length, radius: getComputedStyle(cells[0]).borderTopLeftRadius, w: cells.map((c) => Math.round(c.getBoundingClientRect().width)), ring: active && getComputedStyle(active).boxShadow };
    });
    check("OTP: six softly rounded 18px cells of equal width; the active cell has a purple stroke and halo, no ink", otp.n === 6 && otp.radius === "18px" && new Set(otp.w).size === 1 && otp.ring?.includes("114, 98, 199") && !otp.ring.includes("20, 19, 22"), JSON.stringify(otp));
    await p.locator(".keypad__suggestion").click({ timeout: 5000 });
    await wait(3200);
    const verified = await p.evaluate(() => {
      const art = document.querySelector(".sheet .result__art[data-scene='verified']");
      return { art: !!art, hidden: art?.getAttribute("aria-hidden"), brand: art && getComputedStyle(art.querySelector(".ill__brand")).fill, stack: document.querySelectorAll(".result__badge, .result__shape, [data-illustration='verified-success']").length };
    });
    check("verified sheet: one illustration (phone with a purple message) and no badge stacked on a shape", verified.art && verified.hidden === "true" && verified.brand === "rgb(114, 98, 199)" && verified.stack === 0, JSON.stringify(verified));
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
  /* Single-screen mode: one screen fills the phone viewport and navigates */
  /* ---------------------------------------------------------------- */
  {
    const p = await page({ width: 375, height: 667 }, { isMobile: true, hasTouch: true });
    await p.goto(`${base}flows.html?screen=profile`);
    await wait(1200);
    const single = await p.evaluate(() => ({
      frames: document.querySelectorAll(".fl-frame").length,
      screen: document.querySelector(".fl-frame")?.id,
      fills: Math.abs(document.querySelector(".fl-frame__screen").getBoundingClientRect().height - innerHeight) < 1,
      overflow: document.documentElement.scrollWidth - innerWidth,
    }));
    check("single screen: ?screen= shows one screen filling the viewport", single.frames === 1 && single.screen === "profile" && single.fills && single.overflow <= 0, JSON.stringify(single));
    await p.getByRole("button", { name: "Edit profile" }).click();
    await wait(500);
    check("single screen: navigation moves to the next screen and the URL follows", (await p.locator(".fl-frame").getAttribute("id")) === "edit" && p.url().endsWith("?screen=edit"));
    await p.goto(`${base}flows.html?screen=nope`);
    await wait(800);
    check("single screen: an unknown screen falls back to the full gallery", (await p.locator(".fl-frame").count()) > 1);
    check("single screen: no console errors", p.errors.length === 0, p.errors.join(" | "));
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
    await wait(600);
    const deco = await p.evaluate(() => {
      const headings = [...document.querySelectorAll("h1, h2, .result__title, .match__title, .screen-header__title")];
      return {
        accentWords: headings.filter((h) => [...h.querySelectorAll("*")].some((c) => /[a-z]{2}/i.test(c.textContent) && getComputedStyle(c).color !== getComputedStyle(h).color && !c.closest("svg, .count-badge, .sr-only, .visually-hidden"))).map((h) => h.textContent.slice(0, 30)),
        ribbons: document.querySelectorAll(".ribbon, [class*='ribbon__']").length,
        setup: (() => {
          const steps = [...document.querySelectorAll("#intro .setup-step")];
          const box = steps.map((x) => x.getBoundingClientRect());
          return {
            states: steps.map((x) => x.className.match(/is-(\w+)/)?.[1]).join(),
            current: steps.findIndex((x) => x.getAttribute("aria-current") === "step"),
            icons: steps.every((x) => x.querySelectorAll("svg.setup-step__icon[data-fill='1']").length === 1),
            eyebrows: steps.map((x) => x.querySelector(".setup-step__eyebrow").textContent).join(),
            stacked: box.every((b, i) => !i || b.top >= box[i - 1].bottom) && box.every((b) => b.width > b.height),
            bars: document.querySelectorAll("#intro .progress, #intro [role='progressbar'], #intro .setup-progress").length,
            active: getComputedStyle(steps[0]).boxShadow,
          };
        })(),
      };
    });
    check("expressive: no decorative ribbons or threads anywhere in the flows", deco.ribbons === 0, String(deco.ribbons));
    check("setup progress: a fresh intro shows Basics next and Interests, Photos upcoming, with filled icons", deco.setup.states === "active,upcoming,upcoming" && deco.setup.current === 0 && deco.setup.icons, JSON.stringify(deco.setup));
    check("setup: three stacked horizontal step cards (Step N of 3), no progress bar, the next step outlined in purple", deco.setup.eyebrows === "Step 1 of 3,Step 2 of 3,Step 3 of 3" && deco.setup.stacked && deco.setup.bars === 0 && deco.setup.active.includes("114, 98, 199"), JSON.stringify(deco.setup));
    check("headings: no flow heading colours individual words", deco.accentWords.length === 0, deco.accentWords.join(" | "));
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
    const frames = await p.locator(".fl-frame").count();
    const listed = (await p.locator(".fl-nav__link").count()) - 2; // minus the prototype and design-system links
    check(`flows ${name}: every listed preview screen renders (${frames})`, frames === listed && frames >= 19, `${frames} of ${listed}`);
    const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    check(`flows ${name}: no horizontal overflow`, overflow <= 0, `${overflow}px`);
    if (name === "375") {
      const long = await p.evaluate(() => {
        const chip = document.querySelector("#interests .chip");
        const frame = chip.closest(".fl-frame").getBoundingClientRect();
        chip.firstChild.textContent = "Experimental electronic music festivals and late-night record fairs";
        const r = chip.getBoundingClientRect();
        const fit = r.right <= frame.right + 0.5 && document.documentElement.scrollWidth <= innerWidth;
        chip.firstChild.textContent = "Natural wine";
        return { fit, h: Math.round(r.height) };
      });
      check("chips 375: a very long interest label wraps inside its pill without widening the screen", long.fit && long.h > 40, JSON.stringify(long));
    }
    if (name === "desktop") {
      const f = (id) => p.locator(`#${id}`);
      const textOf = async (id) => (await f(id).innerText()).replace(/\s+/g, " ");
      const header = await p.evaluate(() => getComputedStyle(document.querySelector(".fl-top")).position);
      check("flows: navigation strip is not sticky", header !== "sticky" && header !== "fixed", header);

      // Brand purple in real interactive states (computed styles), and no legacy colours anywhere on the page.
      const BRAND = "rgb(114, 98, 199)";
      const INK = "rgb(20, 19, 22)";
      const WHITE = "rgb(255, 255, 255)";
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
          introArt: !!document.querySelector("#intro .result__art[data-scene='verified']"),
          introStack: document.querySelectorAll("#intro .result__badge, #intro .result__shape").length,
          chipFg: cs("#interests .chip.is-selected").color,
          chipTick: cs("#interests .chip.is-selected .chip__affordance").color,
          chipIcons: [...document.querySelectorAll("#interests .chip")].map((c) => [c.querySelectorAll(".chip__icon").length, c.querySelector(".chip__affordance")?.dataset.icon, !!c.querySelector(".chip__affordance")?.closest("[class*='circle']")]),
          slotFilled: cs("#photos .photo-slot .image-placeholder").backgroundColor,
          slotEmpty: cs("#photos .photo-slot--empty").backgroundColor,
          slotEmptyEdge: cs("#photos .photo-slot--empty").boxShadow,
          switchOn: cs("#settings .switch:checked").backgroundColor,
          switchOff: (() => { const s = document.querySelector("#settings .switch:not(:checked)"); const st = getComputedStyle(s); return { bg: st.backgroundColor, edge: st.boxShadow, thumb: getComputedStyle(s, "::after").backgroundColor }; })(),
          slider: (() => { const t = document.querySelector("#settings .slider__track"); // The native thumb's pseudo-element has no computed style: read its rule instead.
            const rule = [...document.styleSheets].flatMap((s) => [...s.cssRules]).find((r) => r.selectorText === ".slider__track input::-webkit-slider-thumb");
            const thumb = rule && getComputedStyle(document.documentElement).getPropertyValue(rule.style.background.match(/var\((--[\w-]+)\)/)?.[1] ?? "").trim();
            return { track: getComputedStyle(t, "::before").backgroundImage, thumb: thumb === "#ffffff" ? "rgb(255, 255, 255)" : thumb }; })(),
          tabIdleIcon: cs("#discovery .tab-bar__item:not(.is-current) .tab-bar__icon").color,
          tabIdleLabel: cs("#discovery .tab-bar__item:not(.is-current)").color,
          tabActive: cs("#discovery .tab-bar__item.is-current").backgroundColor,
          tabActiveFg: cs("#discovery .tab-bar__item.is-current").color,
          tabActiveIcon: cs("#discovery .tab-bar__item.is-current .tab-bar__icon").color,
          progress: cs("#basics .progress__segment.is-done .progress__fill").backgroundColor,
          verified: [...document.querySelectorAll("#chats .avatar__badge, #chat .verified__mark")].map((e) => ({ tag: e.tagName, icon: e.dataset.icon, fg: getComputedStyle(e).color, bg: getComputedStyle(e).backgroundColor })),
        };
      });
      check("flows: like is an ink action (Meetup primary sheen) with a white glyph", states.likeBg.includes(INK) && states.likeFg === "rgb(255, 255, 255)", `${states.likeBg.slice(0, 60)} / ${states.likeFg}`);
      check("flows: SuperSwipe is the single brand-purple action, with a white star", states.superBg === BRAND && states.superFg === WHITE, `${states.superBg} / ${states.superFg}`);
      check("flows: selected interest is a brand-purple pill with white text and a white minus-circle (Meetup)", states.chipBg === BRAND && states.chipRing === "none" && states.chipFg === WHITE && states.chipTick === WHITE, `${states.chipBg} / ${states.chipFg} / ${states.chipTick}`);
      check("chips: interest pills are text-first with a plain add / remove glyph (no leading icon, no circle)", states.chipIcons.length > 0 && states.chipIcons.every(([lead, aff, circled]) => lead === 0 && (aff === "plus" || aff === "minus") && !circled), JSON.stringify(states.chipIcons.slice(0, 4)));
      check("flows: selecting a chip keeps its size (no reflow)", states.chipSizes[0] === states.chipSizes[1] && states.chipSizes[2] === states.chipSizes[3], states.chipSizes.join(" / "));
      check("flows: the verified intro leads with the shared illustration, no badge-on-shape stack", states.introArt && states.introStack === 0, `${states.introArt} / ${states.introStack}`);
      check("photos: empty slots (white, hairline) are distinct from filled photo placeholders (grey)", states.slotEmpty === "rgb(255, 255, 255)" && /inset/.test(states.slotEmptyEdge) && states.slotFilled !== states.slotEmpty, `${states.slotFilled} vs ${states.slotEmpty}`);
      const pinkFg = await p.evaluate(() => {
        const disc = (sel) => { const e = document.querySelector(sel); return e && { inset: getComputedStyle(e, "::before").content, bg: getComputedStyle(e).backgroundColor, fg: getComputedStyle(e).color }; };
        const cb = document.querySelector("#basics .choice__input--checkbox:checked");
        return {
          discs: [disc("#discovery .action-bar__btn--super"), disc("#chat .composer__send:not(:disabled)")].filter(Boolean),
          checkbox: cb && getComputedStyle(cb).backgroundColor,
          phoneRadius: getComputedStyle(document.querySelector("#basics .input")).borderTopLeftRadius,
          infoCards: document.querySelectorAll("#photos .info-card, #settings .info-card").length,
          shared: (() => {
            const c = document.querySelector("#discovery .shared-interests");
            if (!c) return null;
            const st = getComputedStyle(c);
            const pills = [...c.querySelectorAll(".shared-interests__pill")];
            return { bg: st.backgroundColor, radius: st.borderTopLeftRadius, mark: c.querySelectorAll(".profile-section__title svg, .shared-interests__mark").length, section: c.classList.contains("profile-section"), pills: pills.length, icons: pills.every((x) => x.querySelector(".chip__icon")), pillBg: pills[0] && getComputedStyle(pills[0]).backgroundColor };
          })(),
          portrait: (() => {
            const e = document.querySelector("#chats .match-queue__image");
            if (!e) return null;
            const r = e.getBoundingClientRect();
            const q = document.querySelector("#chats .match-queue");
            const qr = q.getBoundingClientRect();
            return { w: Math.round(r.width), h: Math.round(r.height), radius: getComputedStyle(e).borderTopLeftRadius, ring: getComputedStyle(e).boxShadow, clear: r.top - 5 >= qr.top && r.left - 5 >= qr.left };
          })(),
          actions: [...document.querySelectorAll("#discovery .action-bar .action-bar__btn")].map((b) => { const r = b.getBoundingClientRect(); return `${Math.round(r.width)}x${Math.round(r.height)}/${getComputedStyle(b).borderTopLeftRadius}`; }),
          floating: getComputedStyle(document.querySelector("#discovery .profile-card .action-bar__btn--super")).borderTopLeftRadius,
          send: getComputedStyle(document.querySelector("#chat .composer__send")).borderTopLeftRadius,
          field: getComputedStyle(document.querySelector("#chat .composer__field")).borderTopLeftRadius,
        };
      });
      check("brand: purple actions and marks are solid #7262C7 with white glyphs, no inset disc", pinkFg.discs.length >= 1 && pinkFg.discs.every((d) => d.inset === "none" && d.bg === BRAND && d.fg === WHITE), JSON.stringify(pinkFg.discs));
      check("verified: the mark is the single purple Material verified seal, never a check on a disc", states.verified.length >= 2 && states.verified.every((v) => v.tag === "svg" && v.icon === "verified" && v.fg === BRAND && v.bg === "rgba(0, 0, 0, 0)"), JSON.stringify(states.verified));
      check("selection: a checked checkbox is the purple selected control with a white tick", pinkFg.checkbox === BRAND, pinkFg.checkbox);
      check("fields: form fields are 16px rounded rectangles, not pills", pinkFg.phoneRadius === "16px", pinkFg.phoneRadius);
      check("info cards: photo guidance and blocking help use the shared information card", pinkFg.infoCards === 2, String(pinkFg.infoCards));
      check("you both like: the shared white 24px profile section, no heart or mark, grey text-only pills", pinkFg.shared?.bg === WHITE && pinkFg.shared.radius === "24px" && pinkFg.shared.mark === 0 && pinkFg.shared.section && pinkFg.shared.pills > 0 && !pinkFg.shared.icons && pinkFg.shared.pillBg === "rgb(242, 242, 242)", JSON.stringify(pinkFg.shared));
      check("match queue: new matches are 72x96 portrait previews (20px corner) with an unclipped purple ring", pinkFg.portrait?.w === 72 && pinkFg.portrait.h === 96 && pinkFg.portrait.radius === "20px" && pinkFg.portrait.ring.includes(BRAND) && pinkFg.portrait.clear, JSON.stringify(pinkFg.portrait));
      check("actions: Pass / Super / Like and the floating SuperSwipe are 72x56 pills; send is a circle (Meetup composer)", pinkFg.actions.length === 3 && pinkFg.actions.every((a) => a === "72x56/28px") && pinkFg.floating === "28px" && pinkFg.send === "50%", `${pinkFg.actions.join(" ")} / ${pinkFg.floating} / ${pinkFg.send}`);
      check("composer: the field is a 20px rounded rectangle, never a pill", pinkFg.field === "20px", pinkFg.field);
      const grow = [];
      for (const text of ["One line", "Two\nlines", "Six\nlines\nof\ntext\nin\ntotal", "https://example.com/" + "a".repeat(120)]) {
        await p.locator("#chat textarea").fill(text);
        grow.push(await p.evaluate(() => { const t = document.querySelector("#chat textarea"); return { h: Math.round(t.getBoundingClientRect().height), scroll: t.scrollWidth <= t.clientWidth }; }));
      }
      await p.locator("#chat textarea").fill("");
      check("composer: grows from one line to two, caps at 120px for longer text, and wraps long URLs", grow[0].h === 44 && grow[1].h > grow[0].h && grow[2].h === 120 && grow.every((g) => g.scroll), JSON.stringify(grow));
      check("flows: switch on is the purple selected track; off is a plain grey track, no outline, white thumb", states.switchOn === BRAND && states.switchOff.bg === "rgb(218, 218, 221)" && states.switchOff.edge === "none" && states.switchOff.thumb === "rgb(255, 255, 255)", `${states.switchOn} / ${JSON.stringify(states.switchOff)}`);
      check("flows: sliders have white thumbs on a brand-purple interval over a grey rail (no ink)", states.slider.thumb === WHITE && states.slider.track.includes(BRAND) && states.slider.track.includes("rgb(218, 218, 221)") && !states.slider.track.includes(INK), JSON.stringify(states.slider));
      check("navigation: idle tabs are ink line icons with an ink label (Meetup)", states.tabIdleIcon === "rgb(60, 59, 64)" && states.tabIdleLabel === "rgb(60, 59, 64)", `${states.tabIdleIcon} / ${states.tabIdleLabel}`);
      check("flows: active tab sits on a grey pill with a purple icon and a deep-purple label (Meetup)", states.tabActive === "rgb(233, 232, 235)" && states.tabActiveFg === "rgb(79, 66, 150)" && states.tabActiveIcon === BRAND, `${states.tabActive} / ${states.tabActiveFg} / ${states.tabActiveIcon}`);
      check("flows: progress fill uses brand purple", states.progress === BRAND, states.progress);
      // Geometry, elevation, icons and bottom navigation.
      const geo = await p.evaluate(() => {
        const cs = (sel) => getComputedStyle(document.querySelector(sel));
        const alpha = (v) => Math.max(0, ...[...v.matchAll(/rgba\(\d+, \d+, \d+, ([0-9.]+)\)/g)].map((m) => parseFloat(m[1])));
        const tab = document.querySelector("#discovery .tab-bar");
        const items = [...tab.querySelectorAll(".tab-bar__item")].map((i) => i.getBoundingClientRect());
        return {
          btnRadius: parseFloat(cs("#settings .btn--secondary, #basics .btn, .btn").borderTopLeftRadius),
          // No element anywhere may use a non-round corner-shape (no squircles or superellipses).
          shaped: [...document.querySelectorAll("*")].filter((e) => { const c = getComputedStyle(e).cornerShape; return c && c !== "round"; }).length,
          avatarRadius: [cs("#chat .top-bar .avatar__image, #chat .avatar__image").borderTopLeftRadius, cs("#profile .avatar__image").borderTopLeftRadius],
          ring: (() => {
            const r = document.querySelector("#profile .avatar__ring");
            const v = r.querySelector(".avatar__ring-value");
            const box = r.getBoundingClientRect(), av = r.parentElement.getBoundingClientRect(), vb = v.getBoundingClientRect();
            return { cap: getComputedStyle(v).strokeLinecap, stroke: getComputedStyle(v).stroke, width: getComputedStyle(v).strokeWidth, rounded: /A/.test(v.getAttribute("d")), inside: vb.left >= av.left - 0.5 && vb.top >= av.top - 0.5 && Math.abs(box.width - av.width) < 0.5 };
          })(),
          promptShadowAlpha: alpha(cs("#profile .prompt").boxShadow),
          promptBg: cs("#profile .prompt").backgroundColor,
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
          actionsAfterSections: (() => { const secs = document.querySelectorAll("#discovery .profile-section"); const bar = document.querySelector("#discovery .fl-pf > .action-bar"); return secs.length >= 2 && [...secs].every((s) => s.compareDocumentPosition(bar) & Node.DOCUMENT_POSITION_FOLLOWING); })(),
          tabItemMin: Math.min(...items.map((r) => Math.min(r.width, r.height))),
          tabCurrent: tab.querySelectorAll(".tab-bar__item[aria-current='page']").length,
          icons: document.querySelectorAll("#discovery svg.icon[data-icon][viewBox='0 -960 960 960']").length,
          foreignIcons: document.querySelectorAll("svg[class*='solar'], svg[class*='phosphor'], svg.ph, svg[viewBox='0 0 24 24']:not(.result__shape):not([class*='ring']), svg[viewBox='0 0 256 256']").length,
          tabWeights: [...document.querySelectorAll("#discovery .tab-bar__item")].map((t) => `${t.classList.contains("is-current") ? "on" : "off"}:${t.querySelector("svg").dataset.fill}`),
          lineGlyphs: [...document.querySelectorAll("#settings .top-bar svg, #chat .top-bar svg")].map((s) => s.dataset.icon).filter(Boolean),
          legacyStrokeIcons: document.querySelectorAll("#discovery svg[stroke-linecap='round'][viewBox='0 0 24 24']").length,
          icons24: [...document.querySelectorAll("svg[viewBox='0 0 24 24']")].map((s) => s.getAttribute("class")),
        };
      });
      check("geometry: buttons are pills (Meetup)", geo.btnRadius >= 999, `${geo.btnRadius}px`);
      check("geometry: no squircle or superellipse corner-shape anywhere (plain border-radius only)", geo.shaped === 0, `${geo.shaped} shaped elements`);
      check("shape: avatars are circles, as in Meetup (plain and ringed)", geo.avatarRadius[0] === "50%" && geo.avatarRadius[1] === "50%", geo.avatarRadius.join(" / "));
      check("shape: the completion ring traces a rounded rectangle with round caps in brand purple", geo.ring.rounded && geo.ring.cap === "round" && geo.ring.stroke === BRAND && geo.ring.width === "4px" && geo.ring.inside, JSON.stringify(geo.ring));
      check("surfaces: prompt answers are flat grey quote cards (Meetup 'About me'), no shadow", geo.promptShadowAlpha === 0 && geo.promptBg === "rgb(242, 242, 242)", `alpha ${geo.promptShadowAlpha} / ${geo.promptBg}`);
      const m2 = await p.evaluate(() => {
        const cs = (sel) => document.querySelector(sel) && getComputedStyle(document.querySelector(sel));
        const groups = [...document.querySelectorAll("#settings .fl-sections > *")].map((e) => e.getBoundingClientRect());
        const fields = [...document.querySelectorAll("#basics .fl-gap-lg > *")].map((e) => e.getBoundingClientRect());
        return {
          segSel: cs("#edit .segmented__item.is-selected") && [cs("#edit .segmented__item.is-selected").backgroundColor, cs("#edit .segmented__item.is-selected").color, cs("#edit .segmented__item.is-selected").borderTopLeftRadius],
          sectionGap: Math.round(groups[1].top - groups[0].bottom),
          fieldGap: Math.round(fields[1].top - fields[0].bottom),
          tones: [...document.querySelectorAll(".avatar__image")].map((e) => getComputedStyle(e).backgroundColor).filter((c, i, a) => a.indexOf(c) === i).length,
          info: cs("#photos .info-card").backgroundColor,
        };
      });
      check("selection: the segmented control uses Meetup filter pills (purple selected, white text)", m2.segSel?.[0] === BRAND && m2.segSel[1] === WHITE && m2.segSel[2] === "999px", JSON.stringify(m2.segSel));
      check("spacing: sections separate at 28px, wider than the 20px between form fields", m2.sectionGap === 28 && m2.fieldGap === 20, `${m2.sectionGap} / ${m2.fieldGap}`);
      check("identity: initial avatars carry more than one Meetup pastel framing", m2.tones >= 2, String(m2.tones));
      check("surfaces: guidance cards use the light lavender wash", m2.info === "rgb(243, 240, 253)", m2.info);
      const tabAlpha = Math.max(0, ...[...geo.tabShadow.matchAll(/rgba\(\d+, \d+, \d+, ([0-9.]+)\)/g)].map((m) => parseFloat(m[1])));
      check("navigation: floating capsule inset from the edges with a soft shadow (Meetup)", geo.tabInset >= 8 && geo.tabRadius >= 999 && tabAlpha > 0 && tabAlpha <= 0.14, `inset ${geo.tabInset} / radius ${geo.tabRadius} / alpha ${tabAlpha}`);
      check("navigation: bar sits below the scrolling content, never over it", geo.tabBelowBody);
      check("discover: SuperSwipe sits on the photo, above the tab bar, without scrolling", geo.superTop);
      check("discover: Pass and Like follow the profile, after its sections (reference)", geo.actionsAfterSections);
      check("discover: the photo dominates the screen (≥ 90% width, ≥ 55% height)", geo.photoShare.w >= 0.9 && geo.photoShare.h >= 0.55, `${geo.photoShare.w.toFixed(2)} × ${geo.photoShare.h.toFixed(2)}`);
      const cardEdge = await p.evaluate(() => getComputedStyle(document.querySelector("#discovery .profile-section")).boxShadow);
      check("surfaces: white page; section cards separate with a hairline, not a heavy shadow (Meetup)", geo.pageBg === "rgb(255, 255, 255)" && geo.cardBorder === "0px" && /inset/.test(cardEdge), `${geo.pageBg} / ${cardEdge.slice(0, 60)}`);
      const imagery = await p.evaluate(() => {
        const media = document.querySelector("#discovery .profile-card__media");
        const s = getComputedStyle(media);
        const r = (sel) => parseFloat(getComputedStyle(document.querySelector(sel)).borderTopLeftRadius);
        return { radius: parseFloat(s.borderTopLeftRadius), card: r("#discovery .profile-section"), input: r("#basics .input"), textarea: r("#prompt .textarea__input"), bg: s.backgroundColor, ext: [...document.querySelectorAll("#discovery img")].filter((i) => /^https?:\/\/(?!localhost)/.test(i.src)).length, placeholders: document.querySelectorAll("#discovery .fl-pf__photo").length };
      });
      check("discover: photo areas are neutral grey placeholders and no images are hotlinked", imagery.bg === "rgb(218, 218, 221)" && imagery.ext === 0 && imagery.placeholders >= 1, JSON.stringify(imagery));
      check("geometry: corner hierarchy photo 32 > card 24 > text area 20 > form field 16", imagery.radius === 32 && imagery.card === 24 && imagery.textarea === 20 && imagery.input === 16, `${imagery.radius} / ${imagery.card} / ${imagery.textarea} / ${imagery.input}`);
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
          theirsFg: cs("#chat .message--them .message__bubble").color,
          chip: cs("#interests .chip:not(.is-selected)").boxShadow,
          lastVisible: last.bottom <= body.bottom + 0.5,
          profileReady: document.querySelectorAll("#profile .fl-ready-card [role='meter']").length,
          inboxRows: document.querySelectorAll("#chats .conversation").length,
          inboxBoxed: [...document.querySelectorAll("#chats .conversation, #chats .fl-list")].some((el) => getComputedStyle(el).boxShadow !== "none" || getComputedStyle(el).backgroundColor !== "rgba(0, 0, 0, 0)"),
        };
      });
      check("surfaces: tab roots, chat, match and settings share the page tint", roll.pages.every((c) => c === roll.page), roll.pages.join(" | "));
      check("chat: outgoing bubbles are solid brand purple with white text, incoming light grey with ink (Meetup)", roll.mine === BRAND && roll.mineFg === WHITE && roll.theirs === "rgb(242, 242, 242)" && roll.theirsFg === INK, `${roll.mine} / ${roll.mineFg} / ${roll.theirs}`);
      check("selection: unselected chips are white pills with a hairline (Meetup)", /inset/.test(roll.chip) && roll.chip.includes("1px"), roll.chip);
      check("chat: the last message sits above the composer", roll.lastVisible);
      const art = await p.evaluate(() => {
        const slots = [...document.querySelectorAll("[data-illustration], svg.ill")];
        const fab = document.querySelector("#basics .fab").getBoundingClientRect();
        const screen = document.querySelector("#basics .fl-frame__screen").getBoundingClientRect();
        return {
          ids: slots.map((el) => el.dataset.illustration ?? el.dataset.scene).sort(),
          blank: [...document.querySelectorAll(".illustration:not(.illustration--reserved):not(img)")].length,
          hidden: slots.every((el) => el.getAttribute("aria-hidden") === "true" || el.getAttribute("alt") === ""),
          photoIsArt: document.querySelectorAll(".profile-card__media .ill, .photo-slot .ill, .organic-portrait .ill, .profile-card__media [data-illustration], .photo-slot [data-illustration], .organic-portrait [data-illustration]").length,
          fabVisible: fab.bottom <= screen.bottom,
        };
      });
      check("illustrations: the drawn scenes are present and decorative; no blank placeholder blocks remain", ["hello", "interests", "verified"].every((id) => art.ids.includes(id)) && art.hidden && art.blank === 0, art.ids.join(", "));
      check("illustrations: photo placeholders are never illustration slots", art.photoIsArt === 0);
      const empties = await p.evaluate(() => [...document.querySelectorAll(".empty-state")].map((e) => ({ scene: e.querySelector("svg.ill")?.dataset.scene, discs: [...e.querySelectorAll("*")].filter((c) => !c.closest("svg, .btn") && getComputedStyle(c).borderTopLeftRadius === "50%").length })));
      check("empty states: each leads with its own drawn scene or a plain glyph, never a disc", empties.length > 0 && empties.every((x) => x.discs === 0) && new Set(empties.map((x) => x.scene).filter(Boolean)).size === empties.filter((x) => x.scene).length, JSON.stringify(empties));
      check("illustrations: the onboarding next button stays on screen", art.fabVisible);
      check("layout: profile leads with one readiness summary; inbox rows are plain, not boxed (Bumble)", roll.profileReady === 1 && roll.inboxRows > 0 && !roll.inboxBoxed, `${roll.profileReady} meter / ${roll.inboxRows} rows / boxed ${roll.inboxBoxed}`);
      check("navigation: tab targets are at least 44px", geo.tabItemMin >= 44, `${Math.round(geo.tabItemMin)}px`);
      check("navigation: exactly one current tab", geo.tabCurrent === 1);
      check("icons: Material Symbols Rounded glyphs render and no other icon family remains", geo.icons > 0 && geo.foreignIcons === 0 && geo.legacyStrokeIcons === 0, `${geo.icons} material / ${geo.foreignIcons} other / ${geo.legacyStrokeIcons} legacy / ${geo.icons24.join(",")}`);
      check("icons: the current tab uses the filled glyph, the others the line glyph (Meetup)", geo.tabWeights.every((w) => w === "on:1" || w === "off:0") && geo.tabWeights.filter((w) => w === "on:1").length === 1, geo.tabWeights.join(" "));

      await f("basics").getByLabel("First name").focus();
      await wait(500); // let the focus-ring transition finish before reading computed styles
      const focus = await p.evaluate(() => getComputedStyle(document.querySelector("#basics .input:focus")).boxShadow);
      const others = {};
      await f("prompt").getByLabel("Your answer").focus();
      await wait(500);
      others.textarea = await p.evaluate(() => getComputedStyle(document.querySelector("#prompt .textarea__input")).boxShadow);
      await f("chat").locator("textarea").first().focus();
      await wait(500);
      others.composer = await p.evaluate(() => getComputedStyle(document.querySelector("#chat .composer__field")).boxShadow);
      check("focus: multiline answers and the chat composer share the purple focus (no ink ring)", Object.values(others).every((v) => v.includes("114, 98, 199") && !v.includes(INK)), JSON.stringify(others).slice(0, 160));
      await f("basics").getByLabel("First name").focus();
      await wait(500);
      check("flows: field focus is one brand-purple 2px stroke with a lavender halo, no ink ring", focus.includes(`${BRAND} 0px 0px 0px 2px inset`) && focus.includes("rgba(114, 98, 199") && !focus.includes(INK), focus.slice(0, 90));
      for (const [name, path] of [["prototype", ""], ["flows", "flows.html"], ["showcase", "showcase.html"]]) {
        const q = await page({ width: 1440, height: 900 });
        await q.goto(base + path);
        await wait(1200);
        const legacy = await q.evaluate(() => {
          // Legacy blue and the retired #F770E3 pink theme (and its tints).
          const re = /99, 175, 233|31, 111, 176|23, 80, 127|63, 146, 212|247, 112, 227|253, 212, 247|254, 238, 252|255, 246, 253/;
          let n = 0;
          for (const el of document.querySelectorAll("*")) {
            const s = getComputedStyle(el);
            if ([s.color, s.backgroundColor, s.borderColor, s.boxShadow, s.outlineColor, s.fill, s.stroke].some((v) => re.test(v))) n++;
          }
          return n;
        });
        check(`${name}: no legacy blue or retired pink is rendered`, legacy === 0, `${legacy} elements`);
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
      await p.getByRole("button", { name: "Report", exact: true }).click();
      await wait(600);
      await p.getByRole("dialog").getByText("Fake profile", { exact: true }).click();
      await p.getByRole("dialog").getByRole("button", { name: "Send report" }).click();
      await wait(600);
      check("flows: report (with block, the default) ends in an honest outcome", (await textOf("chat")).includes("You’ve reported and blocked Maya") && (await textOf("chat")).includes("kept on this device only"));
      const outcome = await p.evaluate(() => { const r = document.querySelector("#chat .result"); const art = r.querySelector(".result__art"); return { neutral: r.classList.contains("result--neutral"), scene: art?.dataset.scene, brand: art?.querySelectorAll(".ill__brand").length, checks: r.querySelectorAll("[data-icon='check'], [data-icon='verified'], .result__badge").length }; });
      check("flows: blocking ends on its own neutral illustration (shield and flag), no purple and no success check", outcome.neutral && outcome.scene === "blocked" && outcome.brand === 0 && outcome.checks === 0, JSON.stringify(outcome));
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
      check("flows: snooze gives feedback", (await textOf("settings")).includes("Snoozed. Home is paused."));
      check("flows: snooze pauses Discover", (await textOf("discovery")).includes("Home is paused") && (await textOf("profile")).includes("Snoozed"));
      await p.reload();
      await wait(1200);
      check("flows: snooze persists across reload", (await textOf("discovery")).includes("Home is paused"));
      await f("discovery").getByRole("button", { name: "Resume" }).click();
      await wait(300);
      check("flows: Resume restores Discover", (await f("discovery").getByRole("button", { name: /^Filters:/ }).count()) === 1 && !(await textOf("discovery")).includes("Home is paused") && !(await textOf("profile")).includes("Snoozed"));

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

      // Discover filters sheet: opens from the header, previews the count, applies on confirm.
      await f("discovery").getByRole("button", { name: /^Filters:/ }).click();
      await wait(500);
      const filters = p.getByRole("dialog", { name: "Filters" });
      await filters.getByLabel("Distance").fill("40");
      await wait(200);
      const applyLabel = (await filters.getByRole("button", { name: /^Show|^Apply/ }).textContent()) ?? "";
      check("discover: filters open in a sheet from the header and preview how many people fit", (await filters.count()) === 1 && /^Show \d+ (person|people)$/.test(applyLabel), applyLabel);
      check("discover: filter changes wait for Apply", (await filterName()).includes("within 100 km"), await filterName());
      await filters.getByRole("button", { name: /^Show|^Apply/ }).click();
      await wait(500);
      check("discover: Apply updates the filters and closes the sheet", (await filterName()).includes("within 40 km") && (await p.getByRole("dialog").count()) === 0 && (await f("settings").getByLabel("Distance").inputValue()) === "40", await filterName());
      await f("settings").getByLabel("Distance").fill("100");
      await wait(200);

      // Edit profile: reached from Profile, edits save, Preview shows the profile as others see it.
      await f("profile").getByRole("button", { name: "Edit profile" }).click();
      await wait(400);
      await f("edit").getByLabel("First name").fill("Jordan Lee");
      check("edit: name edits save to the profile", (await textOf("profile")).includes("Jordan Lee"));
      await f("edit").getByLabel("First name").fill("");
      check("edit: an empty name explains what to do", (await textOf("edit")).includes("Add your first name"));
      await f("edit").getByLabel("First name").fill("Jordan");
      await f("edit").getByRole("button", { name: "Climbing" }).click();
      await f("edit").getByRole("tab", { name: "Preview" }).click();
      await wait(300);
      check("edit: interests edit in place and reach the profile preview", (await textOf("edit")).includes("Climbing"));
      await f("edit").getByRole("tab", { name: "Edit" }).click();
      await wait(300);
      // Photo options: make photo 2 the main one; removing stops at 2 photos.
      const firstId = await p.evaluate(() => JSON.parse(localStorage.getItem("numaya.preview.v1")).state.profile.photos.map((x) => x.id));
      await f("edit").getByRole("button", { name: "Photo 2: options" }).click();
      await wait(500);
      await p.getByRole("button", { name: "Make main photo" }).click();
      await wait(500);
      const afterIds = await p.evaluate(() => JSON.parse(localStorage.getItem("numaya.preview.v1")).state.profile.photos.map((x) => x.id));
      check("edit: Make main photo moves the photo to the front", afterIds[0] === firstId[1] && afterIds[1] === firstId[0] && (await textOf("edit")).includes("Main photo updated"));
      for (let i = 0; i < 3; i++) {
        const n = await f("edit").locator(".photo-slot__remove").count();
        if (n <= 2) break;
        await f("edit").getByRole("button", { name: `Remove photo ${n}` }).click();
        await wait(200);
      }
      await f("edit").getByRole("button", { name: "Remove photo 2" }).click();
      await wait(300);
      check("edit: photos cannot drop below 2", (await f("edit").locator(".photo-slot__remove").count()) === 2 && (await textOf("edit")).includes("Keep at least 2 photos"));
      await f("edit").getByRole("tab", { name: "Preview" }).click();
      await wait(400);
      check("edit: Preview shows your card, prompt and interests as others see them", (await f("edit").locator(".profile-card").getAttribute("aria-label"))?.startsWith("Jordan,") && (await textOf("edit")).includes("Climbing"));
      await f("edit").getByRole("tab", { name: "Edit" }).click();
      await wait(300);

      // Prompt editor: reached from Edit profile, Save needs a change and an answer, result shows everywhere.
      await f("edit").getByRole("button", { name: /^Edit answer to/ }).click();
      await wait(400);
      const save = f("prompt").getByRole("button", { name: "Save prompt" });
      check("prompt: Save waits for a change", await save.isDisabled());
      await f("prompt").getByText("My Sunday ritual").click();
      await f("prompt").getByLabel("Your answer").fill("   ");
      check("prompt: an empty answer cannot be saved", (await save.isDisabled()) && (await textOf("prompt")).includes("Write an answer to save"));
      await f("prompt").getByLabel("Your answer").fill("Farmers market, then a very long lunch.");
      await save.click();
      await wait(300);
      check("prompt: a saved prompt shows on Profile, Edit profile and onboarding", (await textOf("profile")).includes("My Sunday ritual") && (await textOf("edit")).includes("Farmers market") && (await textOf("interests")).includes("My Sunday ritual"));

      // Persistence: reload keeps the session; delete account clears it.
      await p.reload();
      await wait(1200);
      check("flows: reload restores the session", (await textOf("profile")).includes("Jordan") && (await textOf("settings")).includes("Blocked people 1"));
      check("flows: reload keeps the edited prompt and main photo", (await textOf("profile")).includes("Farmers market, then a very long lunch."));
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

      for (const id of ["basics", "discovery", "match", "chats", "chat", "profile", "edit", "prompt", "settings"]) {
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
