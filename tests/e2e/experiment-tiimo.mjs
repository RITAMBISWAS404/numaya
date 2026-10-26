#!/usr/bin/env node
/**
 * The opt-in Tiimo-inspired experiment (`?theme=tiimo`), V9: artifacts/version-9-final-screenshot-preview/,
 * whose design-system.md this file checks (earlier versions: artifacts/tiimo-inspired-experiment/ through
 * artifacts/version-8-final-screenshot-preview/). Its own contract, kept apart from the approved design's
 * checks in smoke.mjs and product.mjs: scoping (only the 15 selected screens, only with the flag), the
 * monochrome palette (a white canvas, neutral greys, purple as the one accent), deliberate surfaces
 * (direct, outlined, secondary, recessed; shadow only for what floats), geometry without circles,
 * the compact navigation, the Discover header and photo fade, filter tabs without checkmarks, status
 * labels, the match composition, contrast, and that the screens still work, fit 393 and 375 px wide
 * and log no errors. Run by `npm run test:e2e`.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity", "profile", "edit", "settings"];
const OUTSIDE = ["insights", "activity-detail", "blocked", "premium", "help"];

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}
// Channels 0–1 from a computed colour: rgb(…) in 0–255, or color(srgb …) in 0–1 (what color-mix gives).
const channels = (c) => {
  const n = c.match(/[\d.]+/g).map(Number);
  return c.startsWith("color(") ? n.slice(0, 3) : n.slice(0, 3).map((v) => v / 255);
};
const lum = (colour) => {
  const [r, g, b] = channels(colour).map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ratio = (a, b) => {
  const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p);
  return (x + 0.05) / (y + 0.05);
};

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
// Opens a flow screen with a seeded session (as the gallery does), e.g. the match right after liking Maya.
async function openSeeded(p, path, patch) {
  await open(p, path);
  await p.evaluate(([key, value]) => localStorage.setItem(key, value), [STORAGE_KEY, JSON.stringify({ version: 1, state: { ...initialState, ...patch } })]);
  await p.reload();
  await wait(700);
}
const MATCHED = { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" };
const themed = (p) => p.evaluate(() => document.querySelectorAll(".theme-tiimo").length > 0);

try {
  // 1. Scoping: without the flag nothing is themed; with it, exactly the selected screens are.
  const p = await phone();
  const off = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}`);
    if (await themed(p)) off.push(s);
  }
  await open(p, "");
  if (await themed(p)) off.push("welcome");
  check("scoping: without ?theme=tiimo no screen carries the experiment", off.length === 0, off.join(", "));

  const missing = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=tiimo`);
    if (!(await themed(p))) missing.push(s);
  }
  await open(p, "?theme=tiimo");
  if (!(await themed(p))) missing.push("welcome");
  check("scoping: with ?theme=tiimo all 15 selected screens carry it", missing.length === 0, missing.join(", "));

  const leaked = [];
  for (const s of OUTSIDE) {
    await open(p, `flows.html?screen=${s}&theme=tiimo`);
    if (await themed(p)) leaked.push(s);
  }
  check("scoping: screens outside the experiment keep the approved design even with the flag", leaked.length === 0, leaked.join(", "));

  // 2. Visual contract on Interests: the white canvas, neutral set headings with a neutral emoji
  // holder, decorative emoji.
  await open(p, "flows.html?screen=interests&theme=tiimo");
  const look = await p.evaluate(() => {
    const cs = (el) => getComputedStyle(el);
    const screen = document.querySelector(".fl-screen");
    const labels = [...document.querySelectorAll(".chip-group__set-label[data-tone]")].map((el) => ({ tone: el.dataset.tone, fg: cs(el).color, bg: cs(el).backgroundColor, holder: getComputedStyle(el, "::after").backgroundColor }));
    const prompt = document.querySelector(".prompt__label");
    const chip = [...document.querySelectorAll(".chip")].find((c) => c.textContent.includes("Natural wine"));
    return {
      canvas: cs(screen).backgroundColor,
      labels,
      prompt: prompt && cs(prompt).color,
      chip: { pressed: chip.getAttribute("aria-pressed"), tone: chip.dataset.tone, bg: cs(chip).backgroundColor, ring: cs(chip).boxShadow, fg: cs(chip).color, emoji: getComputedStyle(chip, "::after").content },
    };
  });
  check("look: themed screens sit on the pure white canvas (#FFFFFF, V9)", look.canvas === "rgb(255, 255, 255)", look.canvas);

  // V9: the monochrome palette as tokens, exact values, and the theme's roles resolve to it.
  const palette = await p.evaluate(() => {
    const root = getComputedStyle(document.documentElement);
    const theme = getComputedStyle(document.querySelector(".theme-tiimo"));
    const v = (cs, n) => cs.getPropertyValue(n).trim().toLowerCase();
    return {
      tokens: Object.fromEntries(["canvas", "surface", "surface-secondary", "surface-inset", "border", "brand", "brand-foreground", "text", "secondary", "muted", "disabled"].map((k) => [k, v(root, `--color-palette-${k}`)])),
      mapped: { page: v(theme, "--color-surface-page"), soft: v(theme, "--color-surface-soft"), text: v(theme, "--color-text-primary"), border: v(theme, "--color-border-subtle"), brand: v(theme, "--color-brand"), brandSurface: v(theme, "--color-surface-brand"), brandTint: v(theme, "--color-brand-tint") },
    };
  });
  const WANT = { canvas: "#ffffff", surface: "#ffffff", "surface-secondary": "#f7f7f8", "surface-inset": "#f0f0f2", border: "#e4e4e7", brand: "#7262c7", "brand-foreground": "#ffffff", text: "#28262d", secondary: "#77737d", muted: "#929099", disabled: "#eaeaed" };
  check("palette: the V9 monochrome tokens have their exact values", Object.entries(WANT).every(([k, hex]) => palette.tokens[k] === hex), JSON.stringify(palette.tokens));
  check("palette: canvas, secondary, inset and border are four distinct greys", new Set([palette.tokens.canvas, palette.tokens["surface-secondary"], palette.tokens["surface-inset"], palette.tokens.border]).size === 4);
  check("palette: the theme's canvas, recessed fill, text, border and brand resolve to the palette; the lavender roles resolve to the inset grey", palette.mapped.page === "#ffffff" && palette.mapped.soft === "#f0f0f2" && palette.mapped.text === "#28262d" && palette.mapped.border === "#e4e4e7" && palette.mapped.brand === "#7262c7" && palette.mapped.brandSurface === "#f0f0f2" && palette.mapped.brandTint === "#f0f0f2", JSON.stringify(palette.mapped));
  // Neutral = no visible hue (Text #28262D is a near-black with a 7-point cool cast).
  const neutral = (c) => { const [r, g, b] = c.match(/\d+/g).map(Number); return Math.max(r, g, b) - Math.min(r, g, b) <= 8; };
  check("look: interest sets keep their categories (peach, lilac, mint) as data", look.labels.map((l) => l.tone).join() === "peach,lilac,mint", look.labels.map((l) => l.tone).join());
  check("look: interest set headings are neutral ink, on no coloured fill", look.labels.every((l) => neutral(l.fg) && l.bg === "rgba(0, 0, 0, 0)"), look.labels.map((l) => `${l.fg} on ${l.bg}`).join(", "));
  check("look: each set's emoji sits in a neutral inset-grey holder (no category pastels in V9)", look.labels.every((l) => l.holder === "rgb(240, 240, 242)"), look.labels.map((l) => l.holder).join(", "));
  const worstLabel = Math.min(...look.labels.map((l) => ratio(l.fg, "rgb(255, 255, 255)")));
  check("contrast: set headings on the white canvas are at least 4.5:1", worstLabel >= 4.5, worstLabel.toFixed(2));
  check("look: the prompt question is a neutral heading, not accent text", look.prompt && neutral(look.prompt), look.prompt);
  check("look: a selected interest is solid brand purple with a white label", look.chip.pressed === "true" && look.chip.bg === "rgb(114, 98, 199)" && look.chip.ring === "none" && look.chip.fg === "rgb(255, 255, 255)", `${look.chip.bg} / ${look.chip.ring} / ${look.chip.fg}`);
  check("contrast: selected interest text on its fill is at least 4.5:1", ratio(look.chip.fg, look.chip.bg) >= 4.5, ratio(look.chip.fg, look.chip.bg).toFixed(2));
  check("a11y: interest emoji are decorative (alt text empty), the name stays the label", /🍷/.test(look.chip.emoji) && /\/\s*""/.test(look.chip.emoji), look.chip.emoji);
  const name = await p.getByRole("button", { name: "Natural wine", exact: true }).count();
  check("a11y: the chip's accessible name is the interest alone", name === 1, String(name));

  // 3. Interactions still work inside the theme, and navigation keeps the flag.
  await p.getByRole("button", { name: "Board games", exact: true }).click();
  await wait(300);
  check("interaction: picking an interest still toggles it", (await p.getByRole("button", { name: "Board games", exact: true }).getAttribute("aria-pressed")) === "true");
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  await p.getByRole("button", { name: "Likes", exact: false }).first().click();
  await wait(700);
  const url = new URL(p.url());
  check("navigation: moving to another tab keeps ?theme=tiimo", url.searchParams.get("screen") === "likes" && url.searchParams.get("theme") === "tiimo", url.search);
  check("navigation: the next screen renders themed", await themed(p));

  // 4. Messages: yours solid brand purple with white text, theirs the inset grey with ink.
  await open(p, "flows.html?screen=chat&theme=tiimo");
  const bubbles = await p.evaluate(() => {
    const style = (sel) => {
      const cs = getComputedStyle(document.querySelector(sel));
      return { fg: cs.color, bg: cs.backgroundColor, image: cs.backgroundImage };
    };
    return { me: style(".message--me .message__bubble"), them: style(".message--them .message__bubble") };
  });
  check("look: your messages are solid brand purple with white text", bubbles.me.bg === "rgb(114, 98, 199)" && bubbles.me.fg === "rgb(255, 255, 255)" && bubbles.me.image === "none", `${bubbles.me.bg} / ${bubbles.me.fg} / ${bubbles.me.image}`);
  check("contrast: your message text on purple is at least 4.5:1", ratio(bubbles.me.fg, bubbles.me.bg) >= 4.5, ratio(bubbles.me.fg, bubbles.me.bg).toFixed(2));
  check("look: their messages are inset-grey bubbles on the white canvas, distinct from yours", bubbles.them.bg === "rgb(240, 240, 242)" && bubbles.them.bg !== bubbles.me.bg, bubbles.them.bg);
  check("contrast: their message text is at least 4.5:1", ratio(bubbles.them.fg, bubbles.them.bg) >= 4.5, ratio(bubbles.them.fg, bubbles.them.bg).toFixed(2));

  // 4b. Recessed controls: fields, search, the composer and text areas are the inset grey, with no
  // shadow and no border; they are controls, not cards.
  const recessed = [];
  for (const [screen, sel] of [["basics", ".input"], ["chats", ".search"], ["chat", ".composer__field"], ["prompt", ".textarea__input"], ["edit", ".input"]]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    recessed.push([screen, await p.evaluate((q) => {
      const cs = getComputedStyle(document.querySelector(q));
      return { bg: cs.backgroundColor, shadow: cs.boxShadow, border: cs.borderTopWidth };
    }, sel)]);
  }
  // A fully transparent ring (the approved field keeps one so focus can animate) is not a shadow.
  const noVisibleShadow = (sh) => sh === "none" || sh.split(/,(?![^(]*\))/).every((x) => /^rgba\(0, 0, 0, 0\)/.test(x.trim()));
  check("surfaces: fields, search, composer and text areas are recessed (#F0F0F2), with no shadow or border", recessed.every(([, r]) => r.bg === "rgb(240, 240, 242)" && noVisibleShadow(r.shadow) && r.border === "0px"), recessed.map(([s, r]) => `${s}: ${r.bg} ${r.shadow} ${r.border}`).join(" | "));

  // 4b'. Elevation is reserved (V9): on every themed screen, only what floats above content casts an
  // outer shadow: the tab bar, sheets, toasts and the SuperSwipe on a photo. Rings that separate an
  // overlapping image or a count (white or brand rings, no blur) are not elevation. Cards, activity
  // cards, buttons, the FAB, icon buttons, the action row, groups, rows and inputs are flat.
  const elevated = [];
  const outlined = [];
  for (const path of FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`)) {
    await open(p, path);
    const r = await p.evaluate(() => {
      const bad = []; const groups = [];
      const floats = (el) => el.matches(".tab-bar, .sheet__panel, .toast") || !!el.closest(".profile-card__actions");
      for (const el of document.querySelectorAll(".theme-tiimo *")) {
        if (el.closest("svg") || !el.getBoundingClientRect().width) continue;
        const cs = getComputedStyle(el);
        const layers = cs.boxShadow === "none" ? [] : cs.boxShadow.split(/,(?![^(]*\))/).map((x) => x.trim()).filter((x) => !/inset/.test(x));
        // A ring is an outer layer with no offset and no blur (only spread).
        const blurred = layers.filter((x) => !/^(rgba?\([^)]*\)|color\([^)]*\)) 0px 0px 0px [\d.]+px$/.test(x));
        const cls = `${el.className.baseVal ?? el.className}`;
        if (blurred.length && !floats(el)) bad.push(cls.split(" ").slice(0, 2).join("."));
        if (el.matches(".list-group__items, .option-card:not(.is-selected), .card:not(.profile-section), .activity-card, .prompt")) groups.push(cs.boxShadow);
      }
      return { bad: [...new Set(bad)], groups };
    });
    if (r.bad.length) elevated.push(`${path}: ${r.bad.join(", ")}`);
    outlined.push(...r.groups);
  }
  check("surfaces: only floating chrome casts a shadow (tab bar, sheets, the SuperSwipe on a photo)", elevated.length === 0, elevated.join(" | "));
  check("surfaces: cards, activity cards, your prompt, groups and selection rows are outlined with the 1px #E4E4E7 Border, not elevated", outlined.length > 10 && outlined.every((b) => b === "rgb(228, 228, 231) 0px 0px 0px 1px inset"), [...new Set(outlined)].join(" | "));

  // 4b2. Monochrome (V9): on every themed screen and the match moment, every light opaque background
  // is a neutral white or grey (no beige, no lavender, no pastel). Colour appears only as brand purple,
  // the approved red for notifications, ink and photo overlays, which are not light.
  const tinted = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const hits = await p.evaluate(() => {
      const out = [];
      for (const el of document.querySelectorAll(".theme-tiimo, .theme-tiimo *")) {
        if (!el.getBoundingClientRect().width) continue;
        for (const pseudo of [null, "::before", "::after"]) {
          const cs = getComputedStyle(el, pseudo);
          if (pseudo && (cs.content === "none" || cs.content === "normal")) continue;
          const m = cs.backgroundColor.match(/[\d.]+/g);
          if (!m || (m[3] !== undefined && +m[3] === 0)) continue;
          const [r, g, b] = m.map(Number);
          if (Math.min(r, g, b) > 200 && Math.max(r, g, b) - Math.min(r, g, b) > 4) out.push(`${el.className.baseVal ?? el.className}${pseudo ?? ""} ${r},${g},${b}`.trim());
        }
      }
      return [...new Set(out)];
    });
    if (hits.length) tinted.push(`${path}: ${hits.slice(0, 3).join(", ")}`);
  }
  check("colour: every light surface is neutral white or grey: no beige, lavender or pastel on any themed screen", tinted.length === 0, tinted.join(" | "));

  // 4b3. Deliberate containers (V9): someone's profile sections and inbox rows are direct content on
  // the canvas; information containers are the secondary grey, flat; inbox rows are a divided list;
  // your own prompt is an outlined white module; the selected row is white with the brand ring.
  const flat = (r) => r.bg === "rgba(0, 0, 0, 0)" && r.shadow === "none" && r.border === "0px";
  const read = (sel) => p.evaluate((q) => [...document.querySelectorAll(q)].map((el) => {
    const cs = getComputedStyle(el);
    return { bg: cs.backgroundColor, shadow: cs.boxShadow, border: cs.borderTopWidth, r: cs.borderTopLeftRadius };
  }), sel);
  const direct = [];
  for (const [screen, sel] of [["discovery", ".profile-section"], ["like-profile", ".profile-section"], ["chats", ".conversation"], ["chats", ".conversation__hit"]]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    const rows = await read(sel);
    direct.push([screen, sel, rows.length, rows.every(flat)]);
  }
  check("containers: someone's profile sections and inbox rows sit directly on the canvas (no fill, shadow or border)", direct.every(([, , n, ok]) => n > 0 && ok), direct.filter(([, , n, ok]) => !n || !ok).map(([s, q, n]) => `${s} ${q} (${n})`).join(", "));
  const infos = [];
  for (const screen of ["photos", "like-profile", "settings"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    infos.push(...(await read(".info-card")).map((r) => ({ screen, ...r })));
  }
  check("containers: information containers (first-photo tip, why they liked you, the blocking note) are the flat secondary grey (#F7F7F8)", infos.length >= 3 && infos.every((r) => r.bg === "rgb(247, 247, 248)" && r.shadow === "none" && r.border === "0px" && r.r === "10px"), infos.map((r) => `${r.screen}: ${r.bg} ${r.shadow} ${r.r}`).join(" | "));
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const dividers = await p.evaluate(() => [...document.querySelectorAll(".conversation")].slice(1).map((li) => {
    const d = getComputedStyle(li, "::before");
    const avatar = li.querySelector(".avatar").getBoundingClientRect();
    return { h: d.height, bg: d.backgroundColor, startsAfterAvatar: li.getBoundingClientRect().left + parseFloat(d.left) >= avatar.right };
  }));
  check("containers: inbox rows are separated by a 1px Border divider that starts after the avatar column", dividers.length > 0 && dividers.every((d) => d.h === "1px" && d.bg === "rgb(228, 228, 231)" && d.startsAfterAvatar), JSON.stringify(dividers));
  const modules = [];
  for (const screen of ["profile", "edit", "interests"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    modules.push(...(await read(".prompt")).map((r) => ({ screen, ...r })));
  }
  check("containers: your prompt is an outlined white module (no tint, no shadow)", modules.length === 3 && modules.every((m) => m.bg === "rgb(255, 255, 255)" && m.shadow === "rgb(228, 228, 231) 0px 0px 0px 1px inset"), modules.map((m) => `${m.screen}: ${m.bg} ${m.shadow}`).join(" | "));
  await open(p, "flows.html?screen=basics&theme=tiimo");
  const chosen = await read(".option-card.is-selected");
  check("colour: a selected row is white with the 2px brand ring, not a tinted wash", chosen.length > 0 && chosen.every((r) => r.bg === "rgb(255, 255, 255)" && /rgb\(114, 98, 199\) 0px 0px 0px 2px inset/.test(r.shadow)), chosen.map((r) => `${r.bg} ${r.shadow}`).join(" | "));

  // 4b4. Bottom navigation (V9): compact (56px, from 64) with the approved icon size, touch targets of
  // at least 44px, a rounded rectangle rather than a capsule, white with a hairline and a single soft
  // shadow layer; the active item is the inset grey (a rounded rectangle) behind the brand-purple icon.
  const navOf = async (theme) => {
    await open(p, `flows.html?screen=likes${theme ? "&theme=tiimo" : ""}`);
    await p.mouse.move(0, 0); // the pointer may still rest on a tab from the navigation check (hover is ink)
    await wait(400); // let the colour transition finish
    return p.evaluate(() => {
      const bar = document.querySelector(".tab-bar");
      const items = [...bar.querySelectorAll(".tab-bar__item")];
      const cur = bar.querySelector(".tab-bar__item.is-current");
      const cs = getComputedStyle(bar);
      return {
        h: bar.getBoundingClientRect().height,
        radius: cs.borderTopLeftRadius,
        shadow: cs.boxShadow,
        bg: cs.backgroundColor,
        icons: items.map((i) => { const s = i.querySelector(".tab-bar__icon svg").getBoundingClientRect(); return `${Math.round(s.width)}x${Math.round(s.height)}`; }),
        targets: items.map((i) => { const r = i.getBoundingClientRect(); return [Math.round(r.width), Math.round(r.height)]; }),
        labels: items.map((i) => i.getAttribute("aria-label") ?? i.textContent.trim()),
        current: { bg: getComputedStyle(cur).backgroundColor, radius: getComputedStyle(cur).borderTopLeftRadius, icon: getComputedStyle(cur.querySelector(".tab-bar__icon")).color, ariaCurrent: cur.getAttribute("aria-current") },
        counts: bar.querySelectorAll(".count-badge").length,
      };
    });
  };
  const navV9 = await navOf(true);
  const navApproved = await navOf(false);
  const outerLayers = navV9.shadow.split(/,(?![^(]*\))/).filter((x) => !/inset/.test(x));
  check("navigation: the bar is compact (56px, from 64) and a rounded rectangle, not a capsule", navV9.h === 56 && navApproved.h === 64 && navV9.radius === "12px", `${navV9.h}px (approved ${navApproved.h}px), radius ${navV9.radius}`);
  check("navigation: icons keep the approved size, and every item keeps a touch target of at least 44 x 44", navV9.icons.join() === navApproved.icons.join() && navV9.targets.every(([w, h]) => w >= 44 && h >= 44), `icons ${navV9.icons.join(" ")} (approved ${navApproved.icons.join(" ")}), targets ${navV9.targets.map(([w, h]) => `${w}x${h}`).join(" ")}`);
  check("navigation: white with a hairline and one soft shadow layer", navV9.bg === "rgb(255, 255, 255)" && outerLayers.length === 1 && /inset/.test(navV9.shadow), navV9.shadow);
  check("navigation: the active item is the inset grey (a rounded rectangle) behind the brand-purple icon, and stays marked for assistive tech", navV9.current.bg === "rgb(240, 240, 242)" && navV9.current.radius === "10px" && navV9.current.icon === "rgb(114, 98, 199)" && navV9.current.ariaCurrent === navApproved.current.ariaCurrent && navV9.labels.join() === navApproved.labels.join() && navV9.counts === navApproved.counts && navV9.counts > 0, JSON.stringify(navV9.current));

  // 4b5. No circles (V9): on every themed screen and the match moment, no visible UI element (one with
  // a fill, border, shadow or image) is a circle, pseudo-elements included (switch thumbs). The match
  // scallop is an SVG mask, not a radius, and stays.
  const circles = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const hits = await p.evaluate(() => {
      const out = [];
      for (const el of document.querySelectorAll(".theme-tiimo *")) {
        if (el.closest("svg")) continue;
        for (const pseudo of [null, "::before", "::after"]) {
          const cs = getComputedStyle(el, pseudo);
          if (pseudo && (cs.content === "none" || cs.content === "normal")) continue;
          const w = pseudo ? parseFloat(cs.width) : el.getBoundingClientRect().width;
          const h = pseudo ? parseFloat(cs.height) : el.getBoundingClientRect().height;
          if (!(w > 4 && h > 4) || cs.display === "none" || cs.visibility === "hidden") continue;
          const visible = !/rgba\(0, 0, 0, 0\)/.test(cs.backgroundColor) || cs.borderTopWidth !== "0px" || cs.boxShadow !== "none" || el.tagName === "IMG" || el.tagName === "INPUT";
          if (!visible) continue;
          const r = cs.borderTopLeftRadius.endsWith("%") ? (parseFloat(cs.borderTopLeftRadius) / 100) * w : parseFloat(cs.borderTopLeftRadius);
          if (Math.abs(w - h) < 2 && r >= w / 2 - 0.5) out.push(`${el.className.baseVal ?? el.className}${pseudo ?? ""} ${Math.round(w)}px`.trim());
        }
      }
      return [...new Set(out)];
    });
    if (hits.length) circles.push(`${path}: ${hits.slice(0, 4).join(", ")}`);
  }
  check("geometry: no circular UI element on any themed screen (avatars, counts, radios, icon buttons, switch thumbs included)", circles.length === 0, circles.join(" | "));

  // 4b6. The Discover header shows the logo and its controls, without the bar under the logo; the
  // onboarding progress elsewhere is untouched.
  const headerBar = [];
  for (const screen of ["discovery", "likes"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    headerBar.push(await p.evaluate(() => [...document.querySelectorAll(".fl-disc-head__progress")].filter((el) => el.getBoundingClientRect().height > 0).length));
  }
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  const headerOk = await p.evaluate(() => !!document.querySelector(".fl-disc-head .wordmark, .fl-disc-head__title") && document.querySelectorAll(".fl-disc-head .nav-button").length >= 2);
  await open(p, "flows.html?screen=basics&theme=tiimo");
  const onboardingProgress = await p.evaluate(() => [...document.querySelectorAll(".progress__segment")].filter((el) => el.getBoundingClientRect().height > 0).length);
  check("header: no bar under the Discover logo; the logo and its controls stay", headerBar.every((n) => n === 0) && headerOk, `bars ${headerBar.join(",")}`);
  check("header: onboarding progress segments are untouched", onboardingProgress >= 5, String(onboardingProgress));

  // 4b7. Filter tabs (Likes, Messages): the active tab is solid brand purple with a white label and
  // count and no checkmark, still aria-pressed; inactive tabs are the inset grey. Checkmarks stay where
  // they mean a choice (the ticked checkbox on Basics, the Activity category rail).
  const tabs = [];
  for (const screen of ["likes", "chats"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    tabs.push(...(await p.evaluate((screen) => [...document.querySelectorAll(".filter-chips .chip")].map((c) => {
      const cs = getComputedStyle(c);
      const tick = c.querySelector(".chip__affordance");
      return { screen, label: c.textContent.trim(), selected: c.classList.contains("is-selected"), pressed: c.getAttribute("aria-pressed"), bg: cs.backgroundColor, fg: cs.color, shadow: cs.boxShadow, tick: !!tick && tick.getBoundingClientRect().width > 0 && getComputedStyle(tick).display !== "none", count: c.querySelector(".chip__count") && getComputedStyle(c.querySelector(".chip__count")).color };
    }), screen)));
  }
  const active = tabs.filter((t) => t.selected);
  const idle = tabs.filter((t) => !t.selected);
  check("filters: the active Likes and Messages tab has no checkmark and is solid purple with a white label and count, still aria-pressed", active.length === 2 && active.every((t) => !t.tick && t.bg === "rgb(114, 98, 199)" && t.fg === "rgb(255, 255, 255)" && (!t.count || t.count === "rgb(255, 255, 255)") && t.pressed === "true"), active.map((t) => `${t.screen} ${t.label}: tick ${t.tick}, ${t.bg}, ${t.pressed}`).join(" | "));
  check("filters: inactive tabs are the inset grey with no outline", idle.length >= 4 && idle.every((t) => t.bg === "rgb(240, 240, 242)" && t.shadow === "none" && t.pressed === "false"), [...new Set(idle.map((t) => `${t.bg} ${t.shadow} ${t.pressed}`))].join(" | "));
  await open(p, "flows.html?screen=basics&theme=tiimo");
  const ticked = await p.evaluate(() => [...document.querySelectorAll(".choice__input--checkbox:checked")].map((c) => getComputedStyle(c).backgroundImage));
  await open(p, "flows.html?screen=activity&theme=tiimo");
  const railTick = await p.evaluate(() => { const t = document.querySelector(".filter-chips .chip.is-selected .chip__affordance"); return !!t && t.getBoundingClientRect().width > 0; });
  check("filters: checkmarks remain where they mean a choice (the ticked checkbox, the Activity category rail)", ticked.length > 0 && ticked.every((b) => /svg/.test(b)) && railTick, `${ticked.length} ticked, rail ${railTick}`);

  // 4b8. Status labels: one shape (6px corner) in semantic tones. "Your move" neutral grey with ink;
  // "New" on a like white with deep purple; the unread count solid purple; tab notification counts
  // keep the approved red. None is a capsule.
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const labelsChats = await p.evaluate(() => {
    const s = (q) => { const el = document.querySelector(q); const cs = getComputedStyle(el); return { bg: cs.backgroundColor, fg: cs.color, r: cs.borderTopLeftRadius, h: el.getBoundingClientRect().height }; };
    return { move: s(".conversation__move"), unread: s(".conversation__unread"), count: s(".tab-bar .count-badge") };
  });
  await open(p, "flows.html?screen=likes&theme=tiimo");
  const labelNew = await p.evaluate(() => { const cs = getComputedStyle(document.querySelector(".person-tile__badge .badge")); return { bg: cs.backgroundColor, fg: cs.color, r: cs.borderTopLeftRadius }; });
  check("labels: \"Your move\" is the neutral grey with ink text", labelsChats.move.bg === "rgb(240, 240, 242)" && labelsChats.move.fg === "rgb(40, 38, 45)" && labelsChats.move.r === "6px", JSON.stringify(labelsChats.move));
  check("labels: \"New\" on a like is white with deep-purple text (emphasis, not a fill)", labelNew.bg === "rgb(255, 255, 255)" && labelNew.fg === "rgb(79, 66, 150)" && labelNew.r === "6px", JSON.stringify(labelNew));
  check("labels: the unread count is solid brand purple with white text; tab counts keep the approved red", labelsChats.unread.bg === "rgb(114, 98, 199)" && labelsChats.unread.fg === "rgb(255, 255, 255)" && labelsChats.count.bg === "rgb(185, 58, 54)" && labelsChats.unread.r === "6px" && labelsChats.count.r === "6px", `${JSON.stringify(labelsChats.unread)} ${JSON.stringify(labelsChats.count)}`);

  // 4b9. Profile readiness is a bar, not a ring: the meter keeps role="meter" and its value; the ring
  // around your avatar is gone.
  await open(p, "flows.html?screen=profile&theme=tiimo");
  const meter = await p.evaluate(() => {
    const m = document.querySelector(".fl-ready-card .readiness-meter");
    const fill = getComputedStyle(m, "::after"); const track = getComputedStyle(m, "::before");
    return { role: m.getAttribute("role"), now: Number(m.getAttribute("aria-valuenow")), svg: getComputedStyle(m.querySelector("svg")).display, fillW: parseFloat(fill.width), trackW: parseFloat(track.width), fillH: fill.height, ring: [...document.querySelectorAll(".avatar__ring")].filter((r) => getComputedStyle(r).display !== "none").length };
  });
  check("readiness: a bar filled to the score (no ring), still a meter with its value; no ring around the avatar", meter.role === "meter" && meter.svg === "none" && meter.fillH === "4px" && Math.abs(meter.fillW / meter.trackW - meter.now / 100) < 0.02 && meter.ring === 0, JSON.stringify(meter));

  // 4c. Gradients: the only one allowed is the black fade over a real profile photograph that carries
  // text (the ::before layer of a photo container that holds an <img>). Every other element
  // and ::before/::after, on every themed screen, computes no gradient; the sample profiles only have
  // grey placeholders, which take no gradient. Photographs are images, not gradients, so never match.
  const gradients = [];
  const overlays = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const found = await p.evaluate(() => {
      const hits = [];
      const allowed = [];
      for (const root of document.querySelectorAll(".theme-tiimo")) {
        for (const el of [root, ...root.querySelectorAll("*")]) {
          for (const pseudo of [null, "::before", "::after"]) {
            const cs = getComputedStyle(el, pseudo);
            if (!(/gradient/.test(cs.backgroundImage) || /gradient/.test(cs.borderImageSource) || /gradient/.test(cs.maskImage))) continue;
            const onPhoto = pseudo === "::before" && el.classList.contains("profile-card__media") && el.querySelector(":scope > .profile-card__img");
            if (onPhoto) allowed.push(cs.backgroundImage);
            else hits.push(`${el.tagName.toLowerCase()}.${[...el.classList].join(".")}${pseudo ?? ""}`);
          }
        }
      }
      return { hits: [...new Set(hits)], allowed };
    });
    if (found.hits.length) gradients.push(`${path}: ${found.hits.slice(0, 3).join(", ")}`);
    overlays.push(...found.allowed);
  }
  check("look: no gradient on the 15 themed screens and the match moment, placeholders included (elements and ::before/::after)", gradients.length === 0 && overlays.length === 0, [...gradients, ...overlays].join(" | "));

  // 4d. With a real photograph the card gets the fade. The repo has no photography, so a test image
  // is put into the card: pure white, the worst case for white text.
  const withPhoto = async (screen) => {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    return p.evaluate(() => {
      const media = document.querySelector(".profile-card__media");
      const c = Object.assign(document.createElement("canvas"), { width: 300, height: 400 });
      const x = c.getContext("2d");
      x.fillStyle = "#ffffff";
      x.fillRect(0, 0, 300, 400);
      media.querySelector(".profile-card__stand-in")?.remove();
      media.prepend(Object.assign(document.createElement("img"), { className: "profile-card__img", alt: "", src: c.toDataURL() }));
      const fade = getComputedStyle(media, "::before");
      const g = fade.backgroundImage;
      const stops = [...g.matchAll(/(rgba?\([^)]*\)|color\(srgb [^)]*\)) ([\d.]+)%/g)].map((m) => [Number(m[2]) / 100, Number(m[1].match(/[,/] ([\d.]+)\)$/)?.[1] ?? 1)]);
      const mediaBox = media.getBoundingClientRect();
      const h = parseFloat(fade.height);
      const box = { bottom: mediaBox.bottom, top: mediaBox.bottom - h, height: h };
      // Layering: the fade sits above the photo and below the text and the SuperSwipe.
      const z = (el) => Number(getComputedStyle(el).zIndex) || 0;
      const layered = Number(fade.zIndex) > z(media.querySelector(".profile-card__img")) && z(media.querySelector(".profile-card__overlay")) > Number(fade.zIndex) && (!media.querySelector(".profile-card__actions") || z(media.querySelector(".profile-card__actions")) > Number(fade.zIndex));
      // Opacity of the fade at a height: 0 at its bottom edge, 1 at its top edge.
      const alphaAt = (y) => {
        const t = (box.bottom - y) / box.height;
        for (let i = 1; i < stops.length; i++) if (t <= stops[i][0]) {
          const [t0, a0] = stops[i - 1]; const [t1, a1] = stops[i];
          return a0 + ((t - t0) / (t1 - t0)) * (a1 - a0);
        }
        return 0;
      };
      // Each text line at its lightest point: its top edge.
      const line = (sel) => alphaAt(document.querySelector(sel).getBoundingClientRect().top);
      return {
        gradient: g,
        name: line(".profile-card__name"),
        detail: document.querySelector(".profile-card__detail") ? line(".profile-card__detail") : null,
        clear: (box.top - mediaBox.top) / mediaBox.height, // share of the photo above the fade
        clipped: getComputedStyle(media).overflow === "hidden" && parseFloat(getComputedStyle(media).borderTopLeftRadius) > 0,
        layered,
        overlayBg: getComputedStyle(media.querySelector(".profile-card__overlay")).backgroundImage,
      };
    });
  };
  for (const screen of ["discovery", "like-profile"]) overlays.push({ screen, ...(await withPhoto(screen)) });

  // The rendered fade, read from pixels (Discover with the pure-white test image): down a column clear
  // of text and of the SuperSwipe, the photo stays pure white above the fade, then darkens smoothly
  // and steadily to the bottom, with no band edge (no jump of more than a few levels between rows).
  await withPhoto("discovery");
  const media = p.locator(".profile-card__media");
  const shot = (await media.screenshot()).toString("base64");
  const column = await p.evaluate(async (b64) => {
    const img = new Image();
    img.src = `data:image/png;base64,${b64}`;
    await img.decode();
    const c = Object.assign(document.createElement("canvas"), { width: img.width, height: img.height });
    const x = c.getContext("2d");
    x.drawImage(img, 0, 0);
    const media = document.querySelector(".profile-card__media").getBoundingClientRect();
    // The first text on the photo: the badges (or the name). The overlay box itself starts higher,
    // with empty padding, so it is not the reference.
    const text = (document.querySelector(".profile-card__pills") ?? document.querySelector(".profile-card__name")).getBoundingClientRect();
    const col = Math.round(img.width * 0.75); // right of the name block
    const end = Math.round(((text.top - media.top) / media.height) * img.height) - 4; // just above the text and SuperSwipe
    const v = [];
    for (let y = 0; y < end; y++) v.push(x.getImageData(col, y, 1, 1).data[0]);
    return { v, height: img.height };
  }, shot);
  const fadeTop = column.v.findIndex((v) => v < 254);
  const jumps = column.v.slice(1).map((v, i) => column.v[i] - v);
  const steady = jumps.every((d) => d >= -1);
  const maxJump = Math.max(...jumps);
  check("look: the rendered fade starts below the upper photo, darkens steadily and has no band edge", fadeTop > column.height * 0.38 && steady && maxJump <= 3 && column.v.at(-1) < 200, `starts ${(fadeTop / column.height * 100).toFixed(0)}% down, largest step ${maxJump} levels per row, ${column.v.at(-1)} just above the text`);
  // Stops compute as rgba(…) or, for color-mix, color(srgb r g b / a).
  const colours = (g) => [...g.matchAll(/rgba?\([^)]*\)|color\(srgb [^)]*\)/g)].map((m) => m[0]);
  const isBlack = (c) => /^rgba?\(0, 0, 0(, [\d.]+)?\)$/.test(c) || /^color\(srgb 0 0 0( \/ [\d.]+)?\)$/.test(c);
  const alphaOf = (c) => Number(c.match(/[,/] ([\d.]+)\)$/)?.[1] ?? 1);
  const blackOnly = overlays.length === 2 && overlays.every((o) => /gradient/.test(o.gradient) && colours(o.gradient).every(isBlack));
  check("look: with a photo, Discover and Like back get a black fade (no purple or ink tint)", blackOnly, overlays.map((o) => `${o.screen}: ${o.gradient.slice(0, 60)}`).join(" | "));
  const fades = overlays.every((o) => {
    const a = colours(o.gradient).map(alphaOf);
    return /to top/.test(o.gradient) && a[0] >= 0.8 && a.at(-1) === 0 && a.every((v, i) => i === 0 || v <= a[i - 1]);
  });
  check("look: the fade is darkest at the bottom (at least 80% black) and clear at the top", fades);
  check("look: the fade sits above the photo and below the text and actions; the text block adds no second scrim", overlays.every((o) => o.layered && o.overlayBg === "none"), overlays.map((o) => `${o.screen}: ${o.layered} ${o.overlayBg}`).join(", "));
  check("look: the fade covers only the photo's lower part (its upper 40% has none) and is clipped by its corners", overlays.every((o) => o.clear >= 0.399 && o.clipped), overlays.map((o) => `${o.screen}: ${(o.clear * 100).toFixed(0)}% of the photo clear`).join(", "));

  // Text stays readable over a pure white photo: the fade's opacity at each line composited over white.
  const overWhite = (a) => { const v = Math.round(255 * (1 - a)); return `rgb(${v}, ${v}, ${v})`; };
  for (const o of overlays) {
    const nameRatio = ratio("rgb(255, 255, 255)", overWhite(o.name));
    check(`contrast (${o.screen}): the name (large text) over a white photo is at least 3:1`, nameRatio >= 3, `${nameRatio.toFixed(2)} at ${(o.name * 100).toFixed(0)}% black`);
    if (o.detail !== null) {
      const detailRatio = ratio("rgb(255, 255, 255)", overWhite(o.detail));
      check(`contrast (${o.screen}): the detail line over a white photo is at least 4.5:1`, detailRatio >= 4.5, `${detailRatio.toFixed(2)} at ${(o.detail * 100).toFixed(0)}% black`);
    }
  }

  // 4e. Shapes (V9). Every rendered instance on the listed screens is checked against the V9 scale
  // (tag 6, pill 8, control and item 10, feature 12, photo 14), applied per component; nothing on
  // these screens is a circle (see 4b5), and your match photo stays a rounded square.
  const SHAPES = {
    ".btn--primary": "10px", ".btn--secondary": "10px", ".btn--quiet": "10px",
    ".nav-button": "10px", ".fab": "12px", ".composer__send": "10px",
    ".input": "10px", ".search": "10px", ".composer__field": "10px", ".option-card": "10px",
    ".chip[data-emoji]": "8px", ".filter-chips:not(:has(.chip[data-emoji])) .chip": "8px", ".chip--static:not([data-emoji])": "8px", ".segmented__item": "8px",
    ".conversation__move": "6px", ".profile-card__pill": "6px", ".person-tile__badge .badge": "6px", ".activity-card__category": "6px",
    ".choice__input--checkbox": "6px", ".choice__input--radio": "6px", ".count-badge": "6px", ".conversation__unread": "6px",
    ".activity-card": "12px", ".activity-card__media": "4px", ".person-tile__photo": "12px", ".message__bubble": "12px", ".match-queue__image": "10px",
    ".profile-card__media": "14px", ".fl-pf__photo": "14px", ".action-bar__btn": "12px", ".tab-bar": "12px", ".tab-bar__item": "10px",
    ".avatar--xs .avatar__image": "6px", ".avatar--sm .avatar__image": "8px", ".avatar--lg:not(.match__you) .avatar__image": "12px", ".avatar--xl .avatar__image": "14px",
    ".match__you .avatar__image": "12px", ".switch": "9px",
  };
  const shapeErrors = [];
  const seen = new Set();
  for (const s of ["basics", "interests", "discovery", "like-profile", "likes", "chats", "chat", "match", "activity", "prompt", "profile", "settings"]) {
    if (s === "match") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, `flows.html?screen=${s}&theme=tiimo`);
    const found = await p.evaluate((shapes) => Object.entries(shapes).map(([sel, want]) => {
      const got = [...document.querySelectorAll(`.theme-tiimo ${sel}`)].map((el) => getComputedStyle(el).borderTopLeftRadius);
      return [sel, want, got];
    }), SHAPES);
    for (const [sel, want, got] of found) {
      if (got.length) seen.add(sel);
      for (const g of new Set(got)) if (g !== want) shapeErrors.push(`${s} ${sel}: ${g} (want ${want})`);
    }
  }
  check("shapes: buttons, icon buttons, fields, chips, tags, counts, cards, bubbles, avatars, navigation and photos follow the V9 radius scale", shapeErrors.length === 0, shapeErrors.slice(0, 6).join(" | "));

  // The scale is scoped: without the flag the same components keep the approved shapes.
  const APPROVED = { ".btn--primary": "999px", ".nav-button": "50%", ".search": "999px", ".input": "16px", ".fab": "50%", ".chip--filter": "999px", ".profile-card__media": "32px", ".message__bubble": "20px" };
  const approvedErrors = [];
  for (const s of ["basics", "discovery", "chats", "chat", "like-profile"]) {
    await open(p, `flows.html?screen=${s}`);
    const got = await p.evaluate((shapes) => Object.entries(shapes).flatMap(([sel, want]) => [...document.querySelectorAll(sel)].map((el) => getComputedStyle(el).borderTopLeftRadius).filter((r) => r !== want).map((r) => `${sel} ${r} (want ${want})`)), APPROVED);
    approvedErrors.push(...got.map((g) => `${s} ${g}`));
  }
  check("shapes: without ?theme=tiimo the approved shapes are unchanged", approvedErrors.length === 0, approvedErrors.slice(0, 4).join(" | "));
  check("shapes: every pinned component was found and measured", seen.size === Object.keys(SHAPES).length, Object.keys(SHAPES).filter((k) => !seen.has(k)).join(", "));

  // 4f. The match moment: their photo fills and is clipped by the scalloped silhouette; yours is a
  // smaller rounded square on its lower-left edge; no heart, no halo, no confetti.
  await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
  const match = await p.evaluate(() => {
    const m = document.querySelector(".match");
    const halo = document.querySelector(".organic-portrait__backdrop");
    const frame = document.querySelector(".match .organic-portrait");
    const photo = frame.querySelector(".organic-portrait__photo");
    const image = photo.querySelector("img, .organic-portrait__fallback");
    const you = document.querySelector(".match__you");
    const f = frame.getBoundingClientRect();
    const ph = photo.getBoundingClientRect();
    const i = image.getBoundingClientRect();
    const y = you.getBoundingClientRect();
    const pcs = getComputedStyle(photo);
    const yi = getComputedStyle(you.querySelector(".avatar__image"));
    const art = document.querySelector(".match__art .illustration-slot");
    const yc = { x: y.left + y.width / 2, y: y.top + y.height / 2 };
    const fc = { x: f.left + f.width / 2, y: f.top + f.height / 2 };
    return {
      confetti: [getComputedStyle(m, "::before").content, getComputedStyle(m, "::after").content],
      halo: halo ? getComputedStyle(halo).display : "none",
      // The photo layer is masked by the scallop path and the image fills it edge to edge.
      clipped: /svg/.test(pcs.maskImage || pcs.webkitMaskImage) && pcs.backgroundColor === "rgba(0, 0, 0, 0)" && Math.abs(i.width - ph.width) < 1 && Math.abs(i.height - ph.height) < 1 && Math.abs(ph.width - f.width) < 1,
      youRadius: yi.borderTopLeftRadius,
      rounded: parseFloat(yi.borderTopLeftRadius) >= 10 && parseFloat(yi.borderTopLeftRadius) < y.width / 2 - 8,
      // Lower-left: its centre is left of and below their centre, and the two overlap.
      lowerLeft: yc.x < fc.x - f.width * 0.2 && yc.y > fc.y + f.height * 0.2 && y.right > f.left + f.width * 0.15 && y.top < f.bottom - f.height * 0.15,
      clearOfFace: Math.hypot(yc.x - fc.x, yc.y - fc.y) > f.width * 0.35,
      dominant: f.width > 2.5 * y.width,
      heart: art ? [...art.querySelectorAll("*")].some((el) => getComputedStyle(el).visibility === "visible" && el.getBoundingClientRect().width > 0) : false,
      artSpace: art ? Math.round(art.getBoundingClientRect().height) : 0,
      detail: `frame ${Math.round(f.width)}px, yours ${Math.round(y.width)}px at radius ${yi.borderTopLeftRadius}, centres ${Math.round(Math.hypot(yc.x - fc.x, yc.y - fc.y))}px apart`,
    };
  });
  check("match: no confetti or particles around the photos", match.confetti.every((c) => c === "none" || c === "normal"), match.confetti.join(" "));
  check("match: no lavender halo or outline around their photo", match.halo === "none", match.halo);
  check("match: their photo fills the scalloped silhouette and is clipped by it", match.clipped, match.detail);
  check("match: your smaller photo is a rounded square, not a circle", match.rounded, match.youRadius);
  check("match: your photo overlaps the lower-left edge of theirs, clear of its centre", match.lowerLeft && match.clearOfFace && match.dominant, match.detail);
  check("match: the temporary purple heart is gone; its slot stays, empty, for the hand illustrations", !match.heart && match.artSpace > 0, `slot ${match.artSpace}px tall`);

  // 4g. Pills: only the emoji-and-text pills. Unselected: the inset grey, no border; selected: solid
  // brand purple; an 8px rounded rectangle (V9); no gradient.
  const pillStyle = (sel) => p.evaluate((q) => [...document.querySelectorAll(q)].map((c) => {
    const cs = getComputedStyle(c);
    const inCard = !!c.closest(".card:not(.profile-section), .activity-card, .list-group__items, .option-card, .prompt");
    return { selected: c.classList.contains("is-selected"), locked: c.classList.contains("is-unavailable"), inCard, r: parseFloat(cs.borderTopLeftRadius), h: c.getBoundingClientRect().height, bg: cs.backgroundColor, image: cs.backgroundImage, ring: cs.boxShadow, border: cs.borderTopWidth, fg: cs.color };
  }), sel);
  const pills = [];
  await open(p, "flows.html?screen=interests&theme=tiimo");
  pills.push(...(await pillStyle(".chip[data-emoji]")));
  await open(p, "flows.html?screen=activity&theme=tiimo");
  pills.push(...(await pillStyle(".filter-chips:has(.chip[data-emoji]) .chip")));
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  pills.push(...(await pillStyle(".shared-interests__pill")));
  await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
  pills.push(...(await pillStyle(".match__shared-chip")));
  const unselected = pills.filter((c) => !c.selected);
  const selected = pills.filter((c) => c.selected);
  check("pills: every emoji-and-text pill is an 8px rounded rectangle, not a capsule", pills.length > 10 && pills.every((c) => c.r === 8 && c.h >= 32), [...new Set(pills.map((c) => `${c.r}px on ${Math.round(c.h)}px`))].join(", "));
  const onCanvas = unselected.filter((c) => !c.inCard);
  // Inside white: the activity category (the pill at tag size) on its activity card.
  await open(p, "flows.html?screen=activity&theme=tiimo");
  const onCard = [...unselected.filter((c) => c.inCard), ...(await pillStyle(".activity-card .activity-card__category[data-emoji]"))];
  check("pills: unselected pills on the canvas are the inset grey #F0F0F2, with no border or outline", onCanvas.length > 0 && onCanvas.every((c) => c.bg === "rgb(240, 240, 242)" && c.ring === "none" && c.border === "0px"), [...new Set(onCanvas.map((c) => `${c.bg} ${c.ring} ${c.border}`))].join(" | "));
  check("pills: the category tag inside a white activity card is the same inset grey, with no border", onCard.length > 0 && onCard.every((c) => c.bg === "rgb(240, 240, 242)" && c.ring === "none" && c.border === "0px"), [...new Set(onCard.map((c) => `${c.bg} ${c.ring} ${c.border}`))].join(" | "));
  check("pills: selected pills are solid brand purple, no outline, with a white label", selected.length >= 2 && selected.every((c) => c.bg === "rgb(114, 98, 199)" && c.ring === "none" && c.fg === "rgb(255, 255, 255)"), [...new Set(selected.map((c) => `${c.bg} ${c.ring} ${c.fg}`))].join(" | "));
  check("pills: no gradient on any pill", pills.every((c) => c.image === "none"));
  await open(p, "flows.html?screen=interests&theme=tiimo");
  const glyph = await p.evaluate(() => getComputedStyle(document.querySelector(".chip.is-selected .chip__affordance")).color);
  check("pills: the selection indicator (minus or check) is white on the purple pill (4.90:1)", glyph === "rgb(255, 255, 255)", glyph);

  // 4h. Rendered contrast on every themed screen: each visible text element against the first solid
  // background behind it (text over photos and translucent scrims is checked separately above).
  const lowContrast = [];
  let textCount = 0;
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const r = await p.evaluate(() => {
      const parse = (c) => { const n = c.match(/[\d.]+/g).map(Number); return c.startsWith("color(") ? { rgb: n.slice(0, 3).map((v) => v * 255), a: n[3] ?? 1 } : { rgb: n.slice(0, 3), a: n[3] ?? 1 }; };
      const lum = ([r, g, b]) => { const f = (v) => { v /= 255; return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b); };
      const out = []; let n = 0;
      for (const el of document.querySelectorAll(".theme-tiimo *")) {
        if (![...el.childNodes].some((t) => t.nodeType === 3 && t.textContent.trim())) continue;
        const cs = getComputedStyle(el);
        if (!el.getBoundingClientRect().width || cs.visibility !== "visible" || el.closest("[aria-hidden=true], .visually-hidden, [aria-disabled=true], :disabled")) continue;
        let bg = null;
        for (let a = el; a; a = a.parentElement) {
          const ac = getComputedStyle(a);
          if (ac.backgroundImage !== "none" || a.matches(".profile-card__media")) break;
          const c = parse(ac.backgroundColor);
          if (c.a === 0) continue;
          if (c.a === 1) bg = c.rgb;
          break;
        }
        const fg = parse(cs.color);
        if (!bg || fg.a < 1) continue;
        n++;
        const [x, y] = [lum(fg.rgb), lum(bg)].sort((p, q) => q - p);
        const ratio = (x + 0.05) / (y + 0.05);
        const size = parseFloat(cs.fontSize);
        const need = size >= 24 || (+cs.fontWeight >= 700 && size >= 18.66) ? 3 : 4.5;
        if (ratio < need) out.push(`"${el.textContent.trim().slice(0, 20)}" ${ratio.toFixed(2)}`);
      }
      return { n, out };
    });
    textCount += r.n;
    lowContrast.push(...r.out.map((o) => `${path}: ${o}`));
  }
  check(`contrast: all ${textCount} text elements on the themed screens meet AA against their actual background`, textCount > 150 && lowContrast.length === 0, lowContrast.slice(0, 4).join(" | "));
  const worstPill = Math.min(...pills.filter((c) => !c.locked).map((c) => ratio(c.fg, c.bg)));
  check("contrast: pill text is at least 4.5:1, selected and unselected", worstPill >= 4.5, worstPill.toFixed(2));

  // 5. Welcome stickers are decoration only.
  await open(p, "?theme=tiimo");
  const stickers = await p.evaluate(() => ({ n: document.querySelectorAll(".welcome__sticker").length, hidden: document.querySelector(".welcome__stickers")?.getAttribute("aria-hidden") }));
  check("a11y: welcome stickers are hidden from assistive tech", stickers.n === 4 && stickers.hidden === "true", JSON.stringify(stickers));

  // 6. Every selected screen fits 393 and 375 px wide and logs no errors.
  for (const [w, h] of [[393, 852], [375, 667]]) {
    const q = await phone(w, h);
    const wide = [];
    for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`)]) {
      await open(q, path);
      const over = await q.evaluate(() => document.documentElement.scrollWidth - innerWidth);
      if (over > 0) wide.push(`${path} +${over}px`);
    }
    check(`responsive ${w}: no horizontal overflow on the 15 themed screens`, wide.length === 0, wide.join(", "));
    check(`console ${w}: no errors on the 15 themed screens`, q.errors.length === 0, q.errors.slice(0, 3).join(" | "));
    await q.context().close();
  }
  check("console: no errors during the scoping and interaction checks", p.errors.length === 0, p.errors.slice(0, 3).join(" | "));
} catch (err) {
  check("experiment checks completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} experiment checks passed.`);
process.exit(failed.length ? 1 : 0);
