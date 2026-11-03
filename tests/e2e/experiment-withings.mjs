#!/usr/bin/env node
/**
 * The opt-in V16 visual layer (`?theme=withings`): artifacts/version-16-design-experiment/. V16 is
 * V11 (`?theme=tiimo`) in the Withings Health Mate visual language with an unchanged layout, so this
 * suite checks both halves of that promise:
 * - layout (design-system/V11_LAYOUT_CONTRACT.md): on 12 screens and states, at 393 × 852 and
 *   375 × 667, every element's box is measured with ?theme=tiimo and ?theme=withings. Every element
 *   that is not a bare text run must match within 1px; a text run (a leaf holding only text) may
 *   change its own width with the new face, but not its height or top (no reflow), and anything it
 *   pushed would move and fail;
 * - appearance: scoping, tokens, no purple (computed colours), the heading face, the reference's roles
 *   (black primary, blue-tint selection, green switch, red counts), contrast, focus, interactions and
 *   the console.
 * Run by `npm run test:e2e`.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity", "profile", "edit", "settings"];
const OUTSIDE = ["insights", "activity-detail", "blocked", "premium", "help"];
const BLUE = "rgb(79, 101, 203)";
const TINT = "rgb(230, 235, 255)";
const DEEP = "rgb(61, 80, 176)";
const INK = "rgb(13, 13, 13)";
const GREEN = "rgb(60, 125, 64)";
const RED = "rgb(204, 48, 52)";
const CANVAS = "rgb(244, 243, 241)";
const MATCHED = { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" };

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}
const lum = ([r, g, b]) => {
  const f = (v) => { v /= 255; return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
};
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));

const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();

async function phone(width = 393, height = 852, seed = null) {
  const ctx = await browser.newContext({ viewport: { width, height }, deviceScaleFactor: 1, reducedMotion: "reduce" });
  await ctx.addInitScript(([k, v]) => { if (v) localStorage.setItem(k, v); else localStorage.removeItem(k); }, [STORAGE_KEY, seed]);
  const p = await ctx.newPage();
  p.errors = [];
  p.on("pageerror", (e) => p.errors.push(e.message));
  p.on("console", (m) => m.type() === "error" && p.errors.push(m.text()));
  return p;
}
async function open(p, path) {
  await p.goto(`${base}${path}`);
  await wait(700);
}
const seeded = (patch) => JSON.stringify({ version: 1, state: { ...initialState, ...patch } });
const wthOn = (p) => p.evaluate(() => !!document.querySelector(".theme-wth"));
const tiimoOn = (p) => p.evaluate(() => !!document.querySelector(".theme-tiimo"));
const style = (p, sel, props, pseudo = null) => p.evaluate(([s, ps, ps2]) => {
  const el = document.querySelector(s);
  if (!el) return null;
  const cs = getComputedStyle(el, ps2);
  return Object.fromEntries(ps.map((k) => [k, cs.getPropertyValue(k)]));
}, [sel, props, pseudo]);

/* Every element's box on a screen (plus open sheets), in document order. */
async function boxes(screen, theme, { width, height, seed = null, filters = false }) {
  const p = await phone(width, height, seed);
  await open(p, `flows.html?screen=${screen}&theme=${theme}`);
  if (filters) { await p.getByRole("button", { name: /^Filters/ }).click(); await wait(800); }
  await p.evaluate(() => document.fonts.ready);
  const list = await p.evaluate(() => {
    const roots = [document.querySelector(".fl-frame__screen"), ...document.querySelectorAll(".sheet__panel")].filter(Boolean);
    const out = [];
    for (const root of roots) for (const el of [root, ...root.querySelectorAll("*")]) {
      const r = el.getBoundingClientRect();
      if (!r.width && !r.height) continue;
      out.push({ tag: `${el.tagName.toLowerCase()}.${[...el.classList].join(".")}`, x: r.left, y: r.top, w: r.width, h: r.height, text: el.children.length === 0 && el.textContent.trim().length > 0 });
    }
    return out;
  });
  await p.context().close();
  return list;
}

/* Purple-hue scan of every painted colour on the themed screen (and open sheets). */
const purpleScan = (p) => p.evaluate(() => {
  const found = new Set();
  const props = ["color", "background-color", "border-top-color", "border-bottom-color", "outline-color", "box-shadow", "fill", "stroke", "background-image"];
  const purple = (r, g, b, a = 1) => {
    if (a === 0) return false;
    const mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn;
    if (d < 18) return false;
    const l = (mx + mn) / 510;
    const s = d / 255 / (1 - Math.abs(2 * l - 1) || 1);
    if (s < 0.15) return false;
    let h = mx === r ? ((g - b) / d) % 6 : mx === g ? (b - r) / d + 2 : (r - g) / d + 4;
    h = (h * 60 + 360) % 360;
    // V11's purple sits at 250°, Withings blue at 229°: the band starts above the blue.
    return h >= 238 && h <= 320;
  };
  const root = document.querySelector(".theme-wth");
  if (!root) return ["no .theme-wth"];
  for (const el of [root, ...root.querySelectorAll("*"), ...document.querySelectorAll(".sheet__panel, .sheet__panel *")]) {
    if (!el.getClientRects().length) continue;
    for (const pseudo of [null, "::before", "::after"]) {
      const cs = getComputedStyle(el, pseudo);
      if (pseudo && (cs.content === "none" || cs.content === "normal")) continue;
      for (const k of props) for (const m of cs.getPropertyValue(k).matchAll(/rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\)/g)) {
        if (purple(+m[1], +m[2], +m[3], m[4] === undefined ? 1 : +m[4])) found.add(`${(el.className.baseVal ?? el.className) || el.tagName}${pseudo ?? ""} ${k} ${m[0]}`);
      }
    }
  }
  return [...found];
});

try {
  // 1. Layout: V11's geometry, element by element.
  const STATES = [
    ["discovery"], ["like-profile"], ["likes"], ["chats"], ["chat"], ["profile"], ["edit"], ["prompt"], ["settings"],
    ["match", { seed: seeded(MATCHED) }], ["match (no match)", { screen: "match" }], ["discovery + filters sheet", { screen: "discovery", filters: true }],
  ];
  const drift = [];
  let measured = 0;
  for (const [label, opts = {}] of STATES) {
    for (const [width, height] of [[393, 852], [375, 667]]) {
      const screen = opts.screen ?? label;
      const a = await boxes(screen, "tiimo", { width, height, ...opts });
      const b = await boxes(screen, "withings", { width, height, ...opts });
      if (a.length !== b.length) { drift.push(`${label}@${width}: ${a.length} vs ${b.length} elements`); continue; }
      measured += a.length;
      a.forEach((e, i) => {
        const f = b[i];
        // A bare text run may change its own width (and so its x when centred); it may not reflow.
        const bad = e.text
          ? Math.abs(e.y - f.y) > 1 || Math.abs(e.h - f.h) > 1
          : Math.max(Math.abs(e.x - f.x), Math.abs(e.y - f.y), Math.abs(e.w - f.w), Math.abs(e.h - f.h)) > 1;
        if (bad) drift.push(`${label}@${width} ${e.tag.slice(0, 50)} dx ${Math.abs(e.x - f.x).toFixed(1)} dy ${Math.abs(e.y - f.y).toFixed(1)} dw ${Math.abs(e.w - f.w).toFixed(1)} dh ${Math.abs(e.h - f.h).toFixed(1)}`);
      });
    }
  }
  check("layout: every element keeps V11's position and size (≤ 1px; text runs keep their line and height) on 12 screens and states at 393 and 375 px", drift.length === 0 && measured > 2000, `${measured} boxes compared${drift.length ? "; " + drift.slice(0, 4).join(" | ") : ""}`);

  const p = await phone();

  // 2. Scoping.
  const missing = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    if (!(await wthOn(p)) || !(await tiimoOn(p))) missing.push(s);
  }
  await open(p, "?theme=withings");
  if (!(await wthOn(p))) missing.push("welcome");
  check("scoping: ?theme=withings renders all 15 selected screens in .theme-tiimo .theme-wth", missing.length === 0, missing.join(", "));
  const leaked = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=tiimo`);
    if (await wthOn(p)) leaked.push(`tiimo:${s}`);
    await open(p, `flows.html?screen=${s}`);
    if ((await wthOn(p)) || (await tiimoOn(p))) leaked.push(`default:${s}`);
  }
  for (const s of OUTSIDE) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    if ((await wthOn(p)) || (await tiimoOn(p))) leaked.push(`outside:${s}`);
  }
  check("scoping: V11 and the default never carry .theme-wth; screens outside the experiment stay approved", leaked.length === 0, leaked.slice(0, 5).join(", "));

  // 3. Tokens.
  await open(p, "flows.html?screen=chats&theme=withings");
  const tokens = await p.evaluate(() => {
    const cs = getComputedStyle(document.querySelector(".theme-wth"));
    return Object.fromEntries(["--wth-canvas", "--wth-surface", "--wth-ink", "--wth-accent", "--wth-accent-tint", "--wth-accent-text", "--wth-positive", "--wth-danger", "--wth-radius-button", "--wth-radius-card", "--wth-radius-check", "--wth-radius-pill"].map((k) => [k, cs.getPropertyValue(k).trim().toLowerCase()]));
  });
  const want = { "--wth-canvas": "#f4f3f1", "--wth-surface": "#ffffff", "--wth-ink": "#0d0d0d", "--wth-accent": "#4f65cb", "--wth-accent-tint": "#e6ebff", "--wth-accent-text": "#3d50b0", "--wth-positive": "#3c7d40", "--wth-danger": "#cc3034", "--wth-radius-button": "12px", "--wth-radius-card": "16px", "--wth-radius-check": "4px", "--wth-radius-pill": "999px" };
  const off = Object.entries(want).filter(([k, v]) => tokens[k] !== v);
  check("tokens: the sampled Health Mate canvas, white, ink, blue, tint, green, red and the 12/16/4/999 radii resolve", off.length === 0, off.map(([k]) => `${k}=${tokens[k]}`).join(", "));

  // 4. No purple: every themed screen, the match, the filters sheet.
  const purple = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=withings`);
    for (const f of await purpleScan(p)) purple.push(`${s}: ${f}`);
  }
  const pm = await phone(393, 852, seeded(MATCHED));
  await open(pm, "flows.html?screen=match&theme=withings");
  for (const f of await purpleScan(pm)) purple.push(`match: ${f}`);
  await pm.context().close();
  await open(p, "flows.html?screen=discovery&theme=withings");
  await p.getByRole("button", { name: /^Filters/ }).click();
  await wait(600);
  for (const f of await purpleScan(p)) purple.push(`filters: ${f}`);
  check("colour: no purple anywhere on the 14 themed screens, the match or the filters sheet (computed colours)", purple.length === 0, purple.slice(0, 4).join(" | "));

  // 5. Type: Hanken Grotesk headings at V11's size and line-height; Inter text; tracked nav titles and eyebrows.
  await open(p, "flows.html?screen=likes&theme=withings");
  const title = await style(p, ".topbar__large-title", ["font-family", "font-weight", "font-size", "line-height"]);
  const caption = await style(p, ".person-tile__caption", ["font-family"]);
  const loaded = await p.evaluate(async () => { await document.fonts.ready; return document.fonts.check('700 26px "Hanken Grotesk Variable"'); });
  await open(p, "flows.html?screen=likes&theme=tiimo");
  const v11Title = await style(p, ".topbar__large-title", ["font-size", "line-height"]);
  check("type: headings are Hanken Grotesk 700 at V11's size and line-height; interface text stays Inter", /Hanken Grotesk/.test(title?.["font-family"]) && title["font-weight"] === "700" && title["font-size"] === v11Title["font-size"] && title["line-height"] === v11Title["line-height"] && /Inter/.test(caption?.["font-family"]) && loaded, `${title?.["font-size"]}/${title?.["line-height"]} w${title?.["font-weight"]}`);
  await open(p, "flows.html?screen=settings&theme=withings");
  const navTitle = await style(p, ".topbar__title", ["text-transform", "letter-spacing", "font-weight"]);
  const eyebrow = await style(p, ".list-group__title", ["text-transform", "font-size", "color"]);
  check("type: navigation titles are bold, uppercase and tracked; group labels are small uppercase grey eyebrows", navTitle?.["text-transform"] === "uppercase" && parseFloat(navTitle["letter-spacing"]) > 1.5 && navTitle["font-weight"] === "700" && eyebrow?.["text-transform"] === "uppercase" && eyebrow["font-size"] === "11px" && eyebrow.color === "rgb(109, 108, 106)", `${JSON.stringify(navTitle)} ${eyebrow?.color}`);

  // 6. Roles from the reference.
  const sw = await p.evaluate(() => [...document.querySelectorAll(".switch")].map((e) => ({ on: e.checked, bg: getComputedStyle(e).backgroundColor })));
  check("switches: on is Health Mate's green, off the light grey track", sw.some((x) => x.on && x.bg === GREEN) && sw.every((x) => x.on ? x.bg === GREEN : x.bg === "rgb(228, 228, 230)"), JSON.stringify(sw.slice(0, 3)));
  const cards = await style(p, ".list-group__items", ["background-color", "box-shadow", "border-top-left-radius"]);
  const page = await style(p, ".fl-screen", ["background-color"]);
  check("surfaces: white 16px cards with no edge or shadow on the warm grey canvas", cards?.["background-color"] === "rgb(255, 255, 255)" && cards["box-shadow"] === "none" && cards["border-top-left-radius"] === "16px" && page?.["background-color"] === CANVAS, `${cards?.["box-shadow"]} ${page?.["background-color"]}`);
  await open(p, "flows.html?screen=like-profile&theme=withings");
  const primary = await style(p, ".btn--primary", ["background-color", "color", "border-top-left-radius"]);
  const secondary = await style(p, ".btn--secondary", ["background-color", "color", "box-shadow"]);
  check("buttons: primary is near-black with white text in a 12px rounded rectangle; secondary white with a 1px black edge", primary?.["background-color"] === INK && primary.color === "rgb(255, 255, 255)" && primary["border-top-left-radius"] === "12px" && secondary?.["background-color"] === "rgb(255, 255, 255)" && /rgb\(13, 13, 13\) 0px 0px 0px 1px inset/.test(secondary["box-shadow"]), `${primary?.["background-color"]} ${primary?.["border-top-left-radius"]}`);
  await open(p, "flows.html?screen=likes&theme=withings");
  const sel = await style(p, ".filter-chips .chip.is-selected", ["background-color", "color"]);
  const idle = await style(p, ".filter-chips .chip:not(.is-selected)", ["background-color"]);
  const tab = await style(p, ".tab-bar__item.is-current", ["color"]);
  const tabIdle = await style(p, ".tab-bar__item:not(.is-current)", ["color"]);
  check("selection: the current filter is the blue tint with deep-blue text, idle filters unfilled; the current tab black, others grey", sel?.["background-color"] === TINT && sel.color === DEEP && idle?.["background-color"] === "rgba(0, 0, 0, 0)" && tab?.color === INK && tabIdle?.color === "rgb(109, 108, 106)", `${sel?.["background-color"]} ${sel?.color} ${tab?.color}`);
  await open(p, "flows.html?screen=chats&theme=withings");
  const unread = await style(p, ".conversation__unread", ["background-color"]);
  await open(p, "flows.html?screen=chat&theme=withings");
  const mine = await style(p, ".message--me .message__bubble", ["background-color", "color"]);
  check("Messages: unread counts in Health Mate's red; my messages in Withings blue with white text", unread?.["background-color"] === RED && mine?.["background-color"] === BLUE && mine.color === "rgb(255, 255, 255)", `${unread?.["background-color"]} ${mine?.["background-color"]}`);
  await open(p, "flows.html?screen=discovery&theme=withings");
  const superBtn = await style(p, ".profile-card__actions .action-bar__btn", ["background-color"]);
  const fade = await p.evaluate(() => {
    const media = document.querySelector(".profile-card__media");
    media.prepend(Object.assign(document.createElement("img"), { className: "profile-card__img", alt: "", src: "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" }));
    return getComputedStyle(media, "::before").backgroundImage;
  });
  check("Discover: the SuperSwipe is the blue accent; over a real photo V11's black fade is kept", superBtn?.["background-color"] === BLUE && /gradient/.test(fade), superBtn?.["background-color"]);
  const pm2 = await phone(393, 852, seeded(MATCHED));
  await open(pm2, "flows.html?screen=match&theme=withings");
  const scallop = await pm2.evaluate(() => { const f = document.querySelector(".organic-portrait__fallback"); const ph = document.querySelector(".organic-portrait__photo"); return { bg: f && getComputedStyle(f).backgroundColor, mask: getComputedStyle(ph).maskImage !== "none" }; });
  await pm2.context().close();
  check("Match: V11's scallop (mask kept) in the blue tint", scallop.bg === TINT && scallop.mask, JSON.stringify(scallop));

  // 7. Contrast of the system's text pairings (and the 3:1 control edge).
  const pairs = [["#0d0d0d", "#f4f3f1"], ["#4a4a4a", "#ffffff"], ["#6d6c6a", "#ffffff"], ["#6d6c6a", "#f4f3f1"], ["#ffffff", "#4f65cb"], ["#4f65cb", "#ffffff"], ["#3d50b0", "#e6ebff"], ["#ffffff", "#cc3034"], ["#ffffff", "#0d0d0d"]];
  const low = pairs.map(([a, b]) => [`${a}/${b}`, ratio(hex(a), hex(b))]).filter(([, r]) => r < 4.5);
  check("contrast: every text pairing keeps 4.5:1; field and control edges keep 3:1", low.length === 0 && ratio(hex("#8e8a85"), hex("#ffffff")) >= 3, low.map(([k, r]) => `${k} ${r.toFixed(2)}`).join(", "));

  // 8. V11 untouched by the V16 stylesheet.
  await open(p, "flows.html?screen=likes&theme=tiimo");
  const v11 = await style(p, ".filter-chips .chip.is-selected", ["background-color"]);
  const v11Font = await style(p, ".topbar__large-title", ["font-family"]);
  check("V11 (?theme=tiimo) unchanged: its purple selected filter and Fraunces titles", v11?.["background-color"] === "rgb(114, 98, 199)" && /Fraunces/.test(v11Font?.["font-family"]), `${v11?.["background-color"]} ${v11Font?.["font-family"].split(",")[0]}`);

  // 9. Interactions, focus, console.
  await open(p, "flows.html?screen=chats&theme=withings");
  await p.getByRole("button", { name: /^Likes/ }).click();
  await wait(400);
  const url = new URL(p.url());
  check("interaction: a tab opens its screen and keeps ?theme=withings", url.searchParams.get("screen") === "likes" && url.searchParams.get("theme") === "withings" && (await wthOn(p)), url.search);
  await p.locator(".filter-chips .chip").nth(2).click();
  await wait(300);
  const picked = await p.evaluate(() => document.querySelectorAll(".filter-chips .chip")[2].classList.contains("is-selected") && getComputedStyle(document.querySelectorAll(".filter-chips .chip")[2]).backgroundColor);
  check("interaction: choosing a filter selects it (blue tint)", picked === TINT, String(picked));
  await p.locator(".tab-bar__item").nth(1).focus();
  await p.keyboard.press("Shift+Tab");
  const ring = await p.evaluate(() => { const cs = getComputedStyle(document.activeElement); return `${cs.outlineStyle} ${cs.outlineColor} ${cs.outlineWidth}`; });
  check("focus: a visible 2px Withings-blue ring", ring === `solid ${BLUE} 2px`, ring);
  await open(p, "flows.html?screen=settings&theme=withings");
  const before = await p.evaluate(() => document.querySelectorAll(".switch")[0].checked);
  await p.locator(".switch").first().click();
  await wait(300);
  const after = await p.evaluate(() => ({ on: document.querySelectorAll(".switch")[0].checked, bg: getComputedStyle(document.querySelectorAll(".switch")[0]).backgroundColor }));
  check("interaction: a switch still toggles, and takes the green when on", after.on !== before && (after.on ? after.bg === GREEN : after.bg === "rgb(228, 228, 230)"), JSON.stringify(after));
  await open(p, "flows.html?screen=discovery&theme=withings");
  await p.locator(".action-bar__btn--like").click();
  await wait(500);
  check("interaction: Like on Discover still decides (Maya liked you, so the match opens)", new URL(p.url()).searchParams.get("screen") === "match", new URL(p.url()).search);
  check("console: no errors", p.errors.length === 0, p.errors.slice(0, 3).join(" | "));
} catch (err) {
  check("withings checks completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} withings checks passed.`);
process.exit(failed.length ? 1 : 0);
