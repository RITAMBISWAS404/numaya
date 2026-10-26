#!/usr/bin/env node
/**
 * V16, the Withings Health Mate reconstruction (`?theme=withings`): artifacts/version-16-design-experiment/,
 * whose design-system/COMPONENT_RULES.md this file checks. Its own contract, kept apart from the approved
 * design's checks (smoke.mjs, product.mjs) and V11's (experiment-tiimo.mjs): scoping (the same 15 screens as
 * V11, only with the flag, and V11 itself untouched), the palette (stone page, white cards without border or
 * shadow, ink primary actions, Withings blue accents, green switches, no V11 purple), the one grotesk, the
 * component geometry (fields, buttons, radios, checkboxes, switches, segmented control, modal headers, tab
 * bar, avatars, bubbles), text contrast, that the screens still work, and that they fit 393 and 375 px wide
 * without errors. Run by `npm run test:e2e`.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity", "profile", "edit", "settings"];
const OUTSIDE = ["insights", "activity-detail", "blocked", "premium", "help"];
const STONE = "rgb(245, 244, 241)";
const WHITE = "rgb(255, 255, 255)";
const INK = "rgb(18, 18, 18)";
const BLUE = "rgb(80, 102, 204)";
const TINT = "rgb(228, 235, 252)";
const ON_TINT = "rgb(62, 74, 143)";
const GREEN = "rgb(60, 120, 60)";
const RED = "rgb(207, 51, 54)";
const OUTLINE = "rgb(109, 108, 106)";
const V11_PURPLE = "rgb(114, 98, 199)";

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
async function open(p, path) {
  await p.goto(`${base}${path}`);
  await p.evaluate(() => localStorage.clear());
  await p.goto(`${base}${path}`);
  await wait(700);
}
const withings = (p) => p.evaluate(() => document.querySelectorAll(".theme-withings").length > 0);
const tiimo = (p) => p.evaluate(() => document.querySelectorAll(".theme-tiimo").length > 0);
const ring = (shadow) => (shadow.match(/rgba?\([^)]*\)/) || [""])[0];

try {
  // 1. Scoping.
  const p = await phone();
  const off = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}`);
    if (await withings(p)) off.push(s);
  }
  check("scoping: without ?theme=withings no screen carries V16", off.length === 0, off.join(", "));

  const missing = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    if (!(await withings(p)) || !(await tiimo(p))) missing.push(s);
  }
  await open(p, "?theme=withings");
  if (!(await withings(p))) missing.push("welcome");
  check("scoping: with ?theme=withings all 15 V11 screens carry .theme-tiimo.theme-withings", missing.length === 0, missing.join(", "));

  const leaked = [];
  for (const s of OUTSIDE) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    if (await withings(p)) leaked.push(s);
  }
  check("scoping: screens outside the experiment keep the approved design even with the flag", leaked.length === 0, leaked.join(", "));

  await open(p, "flows.html?screen=settings&theme=tiimo");
  check("isolation: ?theme=tiimo (V11) does not carry V16", (await tiimo(p)) && !(await withings(p)));

  // 2. Surfaces and type on Settings.
  await open(p, "flows.html?screen=settings&theme=withings");
  const settings = await p.evaluate(() => {
    const cs = (sel) => getComputedStyle(document.querySelector(sel));
    const group = cs(".list-group__items");
    const title = cs(".topbar__title");
    const bar = cs(".topbar");
    const heading = cs(".list-group__title");
    const sw = document.querySelector(".switch:checked");
    const swr = sw.getBoundingClientRect();
    const thumb = getComputedStyle(sw, "::after");
    return {
      page: cs(".fl-screen").backgroundColor,
      card: [group.backgroundColor, group.boxShadow, group.borderTopLeftRadius],
      title: [title.textTransform, title.fontWeight, parseFloat(title.letterSpacing) > 1],
      bar: [bar.backgroundColor, bar.boxShadow],
      heading: [heading.color, heading.fontSize, heading.fontWeight],
      font: getComputedStyle(document.querySelector(".list-row__label")).fontFamily,
      switch: [getComputedStyle(sw).backgroundColor, Math.round(swr.width), Math.round(swr.height), thumb.borderTopLeftRadius, thumb.width],
    };
  });
  check("palette: the page is warm stone #F5F4F1", settings.page === STONE, settings.page);
  check("surfaces: grouped rows are a white card, no border or shadow, 14px corner", settings.card[0] === WHITE && settings.card[1] === "none" && settings.card[2] === "14px", settings.card.join(" / "));
  check("type: the modal header title is tracked bold capitals", settings.title[0] === "uppercase" && Number(settings.title[1]) >= 700 && settings.title[2], settings.title.join(" / "));
  check("surfaces: the modal header is a white bar with a hairline", settings.bar[0] === WHITE && ring(settings.bar[1]) === "rgb(230, 229, 226)", settings.bar.join(" / "));
  check("type: group headings are 22px medium ink", settings.heading[0] === INK && settings.heading[1] === "22px" && settings.heading[2] === "500", settings.heading.join(" / "));
  check("type: text is set in Hanken Grotesk", /Hanken Grotesk/.test(settings.font), settings.font);
  check("controls: a switch that is on is green, 51 × 31, with a round thumb", settings.switch[0] === GREEN && settings.switch[1] === 51 && settings.switch[2] === 31 && settings.switch[3] === "50%", settings.switch.join(" / "));
  const before = await p.evaluate(() => document.querySelector(".switch").checked);
  await p.locator(".switch").first().click();
  const after = await p.evaluate(() => document.querySelector(".switch").checked);
  check("behaviour: a switch still toggles", before !== after);
  const slider = p.locator(".slider__track input").first();
  const v0 = await slider.inputValue();
  await slider.focus();
  await p.keyboard.press("ArrowRight");
  check("behaviour: the keyboard still moves a slider", (await slider.inputValue()) !== v0, `${v0} → ${await slider.inputValue()}`);

  // 3. Fields, radios and checkboxes on Basics.
  await open(p, "flows.html?screen=basics&theme=withings");
  const basics = await p.evaluate(() => {
    const input = document.querySelector(".input");
    const label = document.querySelector(".field__label");
    const radio = document.querySelector(".choice__input--radio:checked");
    const box = document.querySelector(".choice__input--checkbox:checked");
    const card = document.querySelector(".option-card");
    const cs = getComputedStyle;
    return {
      input: [cs(input).backgroundColor, cs(input).boxShadow, cs(input).borderTopLeftRadius, Math.round(input.getBoundingClientRect().height)],
      label: [cs(label).textTransform, cs(label).fontWeight],
      radio: radio && [cs(radio).boxShadow, cs(radio).borderTopLeftRadius],
      box: box && cs(box).backgroundColor,
      card: [cs(card).backgroundColor, cs(card).boxShadow],
      legend: cs(document.querySelector(".option-cards__legend")).textTransform,
      fab: [cs(document.querySelector(".fab")).backgroundColor, cs(document.querySelector(".fab")).borderTopLeftRadius],
    };
  });
  check("fields: white, a 1px #6D6C6A outline, 8px corner, 54px tall", basics.input[0] === WHITE && ring(basics.input[1]) === OUTLINE && /1px/.test(basics.input[1]) && basics.input[2] === "8px" && basics.input[3] === 54, basics.input.join(" / "));
  check("fields: labels are bold capitals", basics.label[0] === "uppercase" && Number(basics.label[1]) >= 700, basics.label.join(" / "));
  check("selection: legends share the field-label capitals", basics.legend === "uppercase", basics.legend);
  check("selection: a selected radio is an ink ring around an ink dot", basics.radio && ring(basics.radio[0]) === INK && basics.radio[1] === "50%", JSON.stringify(basics.radio));
  check("selection: a checked box is Withings blue", basics.box && basics.box.startsWith(BLUE), String(basics.box));
  check("selection: choice rows sit in one white card, no ring on the selected row", basics.card[0] === WHITE && !/2px/.test(basics.card[1]), basics.card.join(" / "));
  check("buttons: the step button is an ink circle", basics.fab[0] === INK && basics.fab[1] === "50%", basics.fab.join(" / "));

  // 4. Buttons on Like back and the filters sheet.
  await open(p, "flows.html?screen=like-profile&theme=withings");
  const pair = await p.evaluate(() => {
    const btns = [...document.querySelectorAll(".btn")];
    const like = btns.find((b) => /Like back/.test(b.textContent));
    const pass = btns.find((b) => /Pass/.test(b.textContent));
    const cs = getComputedStyle;
    return { like: [cs(like).backgroundColor, cs(like).color, cs(like).borderTopLeftRadius, Math.round(like.getBoundingClientRect().height)], pass: [cs(pass).backgroundColor, ring(cs(pass).boxShadow)] };
    function ring(s) { return (s.match(/rgba?\([^)]*\)/) || [""])[0]; }
  });
  check("buttons: primary is ink with white text, 12px corner, 50px tall", pair.like[0] === INK && pair.like[1] === WHITE && pair.like[2] === "12px" && pair.like[3] === 50, pair.like.join(" / "));
  check("buttons: secondary is white with a 1px ink outline", pair.pass[0] === WHITE && pair.pass[1] === INK, pair.pass.join(" / "));

  await open(p, "flows.html?screen=discovery&theme=withings");
  const disc = await p.evaluate(() => {
    const cs = getComputedStyle;
    const sup = document.querySelector(".profile-card__actions .action-bar__btn--super");
    const r = sup.getBoundingClientRect();
    const section = document.querySelector(".profile-section");
    return { sup: [cs(sup).backgroundColor, Math.round(r.width), Math.round(r.height), cs(sup).borderTopLeftRadius], section: [cs(section).backgroundColor, cs(section).borderTopLeftRadius] };
  });
  check("discover: the SuperSwipe is a 56px Withings-blue circle", disc.sup[0] === BLUE && disc.sup[1] === 56 && disc.sup[2] === 56 && disc.sup[3] === "50%", disc.sup.join(" / "));
  check("discover: profile sections are white cards on the page", disc.section[0] === WHITE && disc.section[1] === "14px", disc.section.join(" / "));
  await p.getByRole("button", { name: /^Filters/ }).click();
  await wait(500);
  const sheet = await p.evaluate(() => {
    const cs = getComputedStyle;
    const panel = document.querySelector(".sheet__panel");
    const header = document.querySelector(".sheet__header");
    return [cs(panel).backgroundColor, ring(cs(header).boxShadow), cs(document.querySelector(".sheet__title")).fontWeight];
    function ring(s) { return (s.match(/rgba?\([^)]*\)/) || [""])[0]; }
  });
  check("sheets: a white panel, a hairline under the header, a medium title", sheet[0] === WHITE && sheet[1] === "rgb(230, 229, 226)" && sheet[2] === "500", sheet.join(" / "));

  // 5. Tabs, chips and the segmented control.
  await open(p, "flows.html?screen=likes&theme=withings");
  const likes = await p.evaluate(() => {
    const cs = getComputedStyle;
    const sel = document.querySelector(".filter-chips .chip.is-selected");
    const un = document.querySelector(".filter-chips .chip:not(.is-selected)");
    const cur = document.querySelector(".tab-bar__item.is-current");
    const other = document.querySelector(".tab-bar__item:not(.is-current)");
    const title = document.querySelector(".topbar__large-title, .screen-header__title");
    return {
      sel: [cs(sel).backgroundColor, cs(sel).color], un: cs(un).backgroundColor,
      tab: [cs(cur).color, cs(other).color, getComputedStyle(document.querySelector(".tab-bar .count-badge"), "::after").backgroundColor],
      title: title && [cs(title).fontSize, cs(title).fontWeight],
    };
  });
  check("tabs: the selected view tab is a blue-tint pill with blue text", likes.sel[0] === TINT && likes.sel[1] === ON_TINT, likes.sel.join(" / "));
  check("tabs: unselected view tabs are plain text", likes.un === "rgba(0, 0, 0, 0)", likes.un);
  check("navigation: the active tab is ink, the others grey, dots red", likes.tab[0] === INK && likes.tab[1] === "rgb(107, 105, 102)" && likes.tab[2] === RED, likes.tab.join(" / "));
  check("type: tab-root page titles are 30px bold", likes.title && likes.title[0] === "30px" && likes.title[1] === "700", JSON.stringify(likes.title));
  await p.getByRole("button", { name: /^Messages/ }).click();
  await wait(600);
  const url = new URL(p.url());
  check("navigation: moving to another tab keeps ?theme=withings", url.searchParams.get("screen") === "chats" && url.searchParams.get("theme") === "withings" && (await withings(p)), url.search);

  await open(p, "flows.html?screen=edit&theme=withings");
  const seg = await p.evaluate(() => {
    const cs = getComputedStyle;
    return [cs(document.querySelector(".segmented")).backgroundColor, cs(document.querySelector(".segmented__item.is-selected")).backgroundColor];
  });
  check("segmented: a grey track with a white selected segment", seg[0] === "rgb(234, 233, 230)" && seg[1] === WHITE, seg.join(" / "));

  // 6. Messages.
  await open(p, "flows.html?screen=chat&theme=withings");
  const chat = await p.evaluate(() => {
    const cs = getComputedStyle;
    return [cs(document.querySelector(".message--me .message__bubble")).backgroundColor, cs(document.querySelector(".message--them .message__bubble")).backgroundColor, cs(document.querySelector(".avatar__image")).borderTopLeftRadius];
  });
  check("messages: yours Withings blue, theirs white", chat[0] === BLUE && chat[1] === WHITE, chat.join(" / "));
  check("avatars: circles", chat[2] === "50%", chat[2]);

  // 7. No V11 purple anywhere on a V16 screen, and text contrast.
  const purple = [];
  const low = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    const found = await p.evaluate((pp) => {
      const hits = [];
      for (const el of document.querySelectorAll(".theme-withings, .theme-withings *")) {
        const c = getComputedStyle(el);
        if ([c.color, c.backgroundColor, c.boxShadow, c.borderTopColor, c.fill].some((v) => v && v.includes(pp))) hits.push(el.className.baseVal ?? el.className);
      }
      return hits.slice(0, 3);
    }, V11_PURPLE);
    if (found.length) purple.push(`${s}: ${found.join(", ")}`);
    const bad = await p.evaluate(() => {
      const lum = (c) => {
        const [r, g, b] = c.match(/[\d.]+/g).slice(0, 3).map((v) => v / 255).map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
      };
      const alpha = (c) => { const m = c.match(/[\d.]+/g); return m.length > 3 ? Number(m[3]) : 1; };
      const out = [];
      for (const el of document.querySelectorAll(".theme-withings *")) {
        if (![...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
        if (el.closest(".profile-card__media, [disabled], .is-unavailable, [aria-hidden=true], .visually-hidden, .sheet__scrim, .chip__count")) continue;
        const r = el.getBoundingClientRect();
        if (!r.width || !r.height || getComputedStyle(el).visibility === "hidden") continue;
        let bg = null;
        for (let a = el; a; a = a.parentElement) {
          const b = getComputedStyle(a).backgroundColor;
          if (alpha(b) > 0.9) { bg = b; break; }
          if (getComputedStyle(a).backgroundImage !== "none") { bg = null; break; }
        }
        if (!bg) continue;
        const fg = getComputedStyle(el).color;
        if (alpha(fg) < 0.9) continue;
        const [x, y] = [lum(fg), lum(bg)].sort((p, q) => q - p);
        const ratio = (x + 0.05) / (y + 0.05);
        if (ratio < 4.5) out.push(`${el.textContent.trim().slice(0, 24)} ${ratio.toFixed(2)}`);
      }
      return out;
    });
    low.push(...bad.map((b) => `${s}: ${b}`));
  }
  check("palette: no V11 purple (#7262C7) on any V16 screen", purple.length === 0, purple.join(" | "));
  check("a11y: readable text meets 4.5:1 on its background on the 14 flow screens", low.length === 0, low.slice(0, 6).join(" | "));

  // 8. Every V16 screen fits 393 and 375 px wide and logs no errors.
  for (const [w, h] of [[393, 852], [375, 667]]) {
    const q = await phone(w, h);
    const wide = [];
    for (const path of ["?theme=withings", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=withings`)]) {
      await open(q, path);
      const over = await q.evaluate(() => document.documentElement.scrollWidth - innerWidth);
      if (over > 0) wide.push(`${path} +${over}px`);
    }
    check(`responsive ${w}: no horizontal overflow on the 15 V16 screens`, wide.length === 0, wide.join(", "));
    check(`console ${w}: no errors on the 15 V16 screens`, q.errors.length === 0, q.errors.slice(0, 3).join(" | "));
    await q.context().close();
  }
  check("console: no errors during the scoping and interaction checks", p.errors.length === 0, p.errors.slice(0, 3).join(" | "));
} catch (err) {
  check("V16 checks completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} V16 checks passed.`);
process.exit(failed.length ? 1 : 0);
