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
      return { color: el && getComputedStyle(el).color, bg: el && getComputedStyle(el).backgroundImage, deco: el && getComputedStyle(el).textDecorationLine, after };
    });
    check("headline emphasis is the word itself in exact #F770E3 (no marker, underline or background)", emphasis.color === "rgb(247, 112, 227)" && emphasis.bg === "none" && emphasis.deco === "none", `${emphasis.color} / ${emphasis.bg} / ${emphasis.deco}`);
    check("headline has no decorative underline", !emphasis.after);

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
    check("welcome: legal links are ink with a brand-pink underline", welcome.link.color === "rgb(20, 23, 31)" && welcome.link.line === "rgb(247, 112, 227)", JSON.stringify(welcome.link));

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
      const fill = el?.querySelector(".result__shape-fill");
      return el && { bg: fill && getComputedStyle(fill).fill, fg: getComputedStyle(el).color };
    });
    check("verified badge fill is exactly #F770E3", badge?.bg === "rgb(247, 112, 227)", badge?.bg);
    check("verified badge check is white, never ink on pink", badge?.fg === "rgb(255, 255, 255)", badge?.fg);
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
      const ribbons = [...document.querySelectorAll(".ribbon")];
      const marker = document.querySelector("#match .emphasis");
      return {
        where: ribbons.map((r) => r.closest(".fl-frame")?.id).sort().join(),
        hidden: ribbons.every((r) => r.getAttribute("aria-hidden") === "true" && getComputedStyle(r).pointerEvents === "none"),
        anim: ribbons.flatMap((r) => [...r.querySelectorAll("svg")].map((x) => getComputedStyle(x).animationName)),
        colours: ribbons.map((r) => `${getComputedStyle(r.querySelector(".ribbon__band path")).stroke}|${getComputedStyle(r.querySelector(".ribbon__accent path")).stroke}`),
        setup: (() => {
          const steps = [...document.querySelectorAll("#intro .setup-progress__step")];
          return { states: steps.map((x) => x.className.match(/is-(\w+)/)?.[1]).join(), current: steps.findIndex((x) => x.getAttribute("aria-current") === "step"), icons: steps.every((x) => x.querySelector(".setup-progress__icon svg[data-weight='fill']")) };
        })(),
        marker: marker && { text: marker.textContent, color: getComputedStyle(marker).color },
      };
    });
    check("expressive: in the flows a ribbon appears only on the match moment (none at the verified badge)", deco.where === "match", deco.where);
    check("expressive: ribbons are aria-hidden and never take pointer input", deco.hidden);
    check("expressive: reduced motion keeps ribbons static", deco.anim.every((a) => a === "none"), deco.anim.join());
    check("expressive: ribbons are a very light neutral band with an exact-#F770E3 accent line", deco.colours.length > 0 && deco.colours.every((c) => c === "rgb(243, 245, 248)|rgb(247, 112, 227)"), deco.colours.join());
    check("setup progress: a fresh intro shows Basics next and Interests, Photos upcoming, with filled icons", deco.setup.states === "active,upcoming,upcoming" && deco.setup.current === 0 && deco.setup.icons, JSON.stringify(deco.setup));
    check("expressive: the match title colours one word brand pink", deco.marker?.text === "match" && deco.marker.color === "rgb(247, 112, 227)", JSON.stringify(deco.marker));
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
    check(`flows ${name}: 12 preview screens render`, (await p.locator(".fl-frame").count()) === 12);
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
          badgeShape: cs("#intro .result__shape-fill")?.fill,
          badgeDisc: cs("#intro .result__badge", "::before").content,
          badgeIcon: cs("#intro .result__badge").color,
          chipFg: cs("#interests .chip.is-selected").color,
          chipTick: cs("#interests .chip.is-selected .chip__affordance").color,
          chipIcons: [...document.querySelectorAll("#interests .chip")].every((c) => c.querySelector(".chip__icon[class*='-bold']")),
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
          verified: cs("#chats .avatar__badge, #discovery .verified__mark").backgroundColor,
        };
      });
      check("flows: like is an ink action (Meetup primary sheen) with a white glyph", states.likeBg.includes(INK) && states.likeFg === "rgb(255, 255, 255)", `${states.likeBg.slice(0, 60)} / ${states.likeFg}`);
      check("flows: SuperSwipe is the single brand-pink action, with a white glyph (never ink on pink)", states.superBg === PINK && states.superFg === "rgb(255, 255, 255)", `${states.superBg} / ${states.superFg}`);
      check("flows: selected interest is an ink pill with white text and a brand-pink tick", states.chipBg === INK && states.chipRing === "none" && states.chipFg === "rgb(255, 255, 255)" && states.chipTick === PINK, `${states.chipBg} / ${states.chipFg} / ${states.chipTick}`);
      check("flows: every interest chip leads with a filled Solar cue", states.chipIcons);
      check("flows: selecting a chip keeps its size (no reflow)", states.chipSizes[0] === states.chipSizes[1] && states.chipSizes[2] === states.chipSizes[3], states.chipSizes.join(" / "));
      check("flows: success badge is a pink cookie shape with a white check and no white disc", states.badgeShape === PINK && states.badgeIcon === "rgb(255, 255, 255)" && states.badgeDisc === "none", `${states.badgeShape} / ${states.badgeIcon} / ${states.badgeDisc}`);
      check("photos: empty slots (white, hairline) are distinct from filled photo placeholders (grey)", states.slotEmpty === "rgb(255, 255, 255)" && /inset/.test(states.slotEmptyEdge) && states.slotFilled !== states.slotEmpty, `${states.slotFilled} vs ${states.slotEmpty}`);
      const pinkFg = await p.evaluate(() => {
        const disc = (sel) => { const e = document.querySelector(sel); return e && { inset: getComputedStyle(e, "::before").content, bg: getComputedStyle(e).backgroundColor, fg: getComputedStyle(e).color }; };
        const cb = document.querySelector("#basics .choice__input--checkbox:checked");
        return {
          discs: [disc("#discovery .action-bar__btn--super"), disc("#chats .avatar__badge"), disc("#chat .verified__mark"), disc("#chat .composer__send:not(:disabled)")].filter(Boolean),
          checkbox: cb && getComputedStyle(cb).backgroundColor,
          phoneRadius: getComputedStyle(document.querySelector("#basics .input")).borderTopLeftRadius,
          infoCards: document.querySelectorAll("#photos .info-card, #settings .info-card").length,
          shared: (() => {
            const c = document.querySelector("#discovery .shared-interests");
            if (!c) return null;
            const st = getComputedStyle(c);
            const pills = [...c.querySelectorAll(".shared-interests__pill")];
            return { bg: st.backgroundColor, radius: st.borderTopLeftRadius, mark: getComputedStyle(c.querySelector(".shared-interests__mark")).color, pills: pills.length, icons: pills.every((x) => x.querySelector(".chip__icon")), pillBg: pills[0] && getComputedStyle(pills[0]).backgroundColor };
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
        };
      });
      check("pink: pink actions and marks carry white glyphs, with no white inset disc and never ink", pinkFg.discs.length >= 3 && pinkFg.discs.every((d) => d.inset === "none" && d.fg === "rgb(255, 255, 255)" && d.fg !== INK), JSON.stringify(pinkFg.discs));
      check("selection: a checked checkbox is ink with a white tick (no glyph on pink)", pinkFg.checkbox === INK, pinkFg.checkbox);
      check("fields: form fields are 16px rounded rectangles, not pills", pinkFg.phoneRadius === "16px", pinkFg.phoneRadius);
      check("info cards: photo guidance and blocking help use the shared information card", pinkFg.infoCards === 2, String(pinkFg.infoCards));
      check("you both like: a white 24px card, pink only on the small heart mark, neutral pills with icons", pinkFg.shared?.bg === "rgb(255, 255, 255)" && pinkFg.shared.radius === "24px" && pinkFg.shared.mark === PINK && pinkFg.shared.pills > 0 && pinkFg.shared.icons && pinkFg.shared.pillBg !== PINK, JSON.stringify(pinkFg.shared));
      check("match queue: new matches are 56x70 portraits at the 16px radius with an unclipped pink ring", pinkFg.portrait?.w === 56 && pinkFg.portrait.h === 70 && pinkFg.portrait.radius === "16px" && pinkFg.portrait.ring.includes(PINK) && pinkFg.portrait.clear, JSON.stringify(pinkFg.portrait));
      check("actions: Pass / Super / Like are 72x56 pills; floating SuperSwipe and send stay circles", pinkFg.actions.length === 3 && pinkFg.actions.every((a) => a === "72x56/28px") && pinkFg.floating === "50%" && pinkFg.send === "50%", `${pinkFg.actions.join(" ")} / ${pinkFg.floating} / ${pinkFg.send}`);
      check("flows: switch on is a brand-pink track; off is a plain grey track, no outline, white thumb", states.switchOn === PINK && states.switchOff.bg === "rgb(215, 219, 225)" && states.switchOff.edge === "none" && states.switchOff.thumb === "rgb(255, 255, 255)", `${states.switchOn} / ${JSON.stringify(states.switchOff)}`);
      check("flows: sliders have white thumbs on a brand-pink interval over a grey rail (no ink)", states.slider.thumb === "rgb(255, 255, 255)" && states.slider.track.includes(PINK) && states.slider.track.includes("rgb(215, 219, 225)") && !states.slider.track.includes(INK), JSON.stringify(states.slider));
      check("navigation: idle tabs are soft grey with a readable label", states.tabIdleIcon === "rgb(154, 161, 172)" && states.tabIdleLabel === "rgb(100, 107, 120)", `${states.tabIdleIcon} / ${states.tabIdleLabel}`);
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
          activeTabFilled: [...document.querySelectorAll("#discovery .tab-bar__item svg")].every((s) => /-bold\b/.test(s.getAttribute("class"))),
          lineGlyphs: [...document.querySelectorAll("#settings .top-bar svg, #chat .top-bar svg")].map((s) => s.getAttribute("class").match(/solar-([\w-]+)/)?.[1]).filter(Boolean),
          legacyStrokeIcons: document.querySelectorAll("#discovery svg[stroke-linecap='round'][viewBox='0 0 24 24']").length,
        };
      });
      check("geometry: buttons are pills (Meetup)", geo.btnRadius >= 999, `${geo.btnRadius}px`);
      check("geometry: no squircle or superellipse corner-shape anywhere (plain border-radius only)", geo.shaped === 0, `${geo.shaped} shaped elements`);
      check("shape: avatars are rounded rectangles, radius 30% of the image (36px → 10.8px; ringed 96px → 26.4px)", geo.avatarRadius[0] === "10.8px" && geo.avatarRadius[1] === "26.4px", geo.avatarRadius.join(" / "));
      check("shape: the completion ring traces a rounded rectangle with round caps in brand pink", geo.ring.rounded && geo.ring.cap === "round" && geo.ring.stroke === PINK && geo.ring.width === "4px" && geo.ring.inside, JSON.stringify(geo.ring));
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
        return { radius: parseFloat(s.borderTopLeftRadius), card: r("#discovery .fl-pf__section"), input: r("#basics .input"), textarea: r("#prompt .textarea__input"), bg: s.backgroundColor, ext: [...document.querySelectorAll("#discovery img")].filter((i) => /^https?:\/\/(?!localhost)/.test(i.src)).length, placeholders: document.querySelectorAll("#discovery .fl-pf__photo").length };
      });
      check("discover: photo areas are neutral grey placeholders and no images are hotlinked", imagery.bg === "rgb(215, 219, 225)" && imagery.ext === 0 && imagery.placeholders >= 1, JSON.stringify(imagery));
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
          chip: cs("#interests .chip:not(.is-selected)").boxShadow,
          lastVisible: last.bottom <= body.bottom + 0.5,
          stripCols: cs("#profile .fl-photo-strip").gridTemplateColumns.split(" ").length,
          inboxRows: document.querySelectorAll("#chats .conversation").length,
          inboxBoxed: [...document.querySelectorAll("#chats .conversation, #chats .fl-list")].some((el) => getComputedStyle(el).boxShadow !== "none" || getComputedStyle(el).backgroundColor !== "rgba(0, 0, 0, 0)"),
        };
      });
      check("surfaces: tab roots, chat, match and settings share the page tint", roll.pages.every((c) => c === roll.page), roll.pages.join(" | "));
      check("chat: outgoing bubbles are a soft brand tint with ink text (not saturated pink), incoming light grey", roll.mine === "rgb(253, 212, 247)" && roll.mineFg === INK && roll.theirs === "rgb(236, 239, 243)", `${roll.mine} / ${roll.mineFg} / ${roll.theirs}`);
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
      check("icons: every tab uses the filled Solar glyph (colour and the pill mark the current one)", geo.activeTabFilled);

      await f("basics").getByLabel("First name").focus();
      await wait(500); // let the focus-ring transition finish before reading computed styles
      const focus = await p.evaluate(() => getComputedStyle(document.querySelector("#basics .input:focus")).boxShadow);
      check("flows: field focus is one brand-pink 2px stroke with a pink halo, no ink ring", focus.includes(`${PINK} 0px 0px 0px 2px inset`) && focus.includes("rgba(247, 112, 227") && !focus.includes(INK), focus.slice(0, 90));
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
      const outcome = await p.evaluate(() => { const b = document.querySelector("#chat .result__badge"); const st = getComputedStyle(b); return { neutral: b.closest(".result").classList.contains("result--neutral"), bg: st.backgroundImage + " " + st.backgroundColor, shadow: st.boxShadow, round: st.borderTopLeftRadius, cookie: !!b.querySelector(".result__shape") }; });
      check("flows: safety outcomes use the round neutral badge (no brand pink, glow or success cookie)", outcome.neutral && !outcome.bg.includes(PINK) && !outcome.shadow.includes("247, 112, 227") && outcome.round === "50%" && !outcome.cookie, JSON.stringify(outcome));
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
      check("edit: interests edit in place and reach the profile", (await textOf("profile")).includes("Climbing"));
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
