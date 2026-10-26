#!/usr/bin/env node
/**
 * The opt-in Tiimo-inspired experiment (`?theme=tiimo`), V11: artifacts/version-11-final-screenshot-preview/,
 * whose design-decisions.md this file checks (earlier versions: artifacts/tiimo-inspired-experiment/ through
 * artifacts/version-10-final-screenshot-preview/). Its own contract, kept apart from the approved design's
 * checks in smoke.mjs and product.mjs: scoping (only the 15 selected screens, only with the flag), the
 * monochrome palette (a white canvas, neutral greys, purple as the one accent), deliberate surfaces
 * (direct, outlined, secondary, recessed; shadow only for what floats), V10's balanced geometry (pills
 * and rounded rectangles, circular radios, pill switch and slider handles, nested corners), the
 * full-width tab bar with notification dots, the Discover header and photo fade, filter tabs without
 * checkmarks, status labels, the larger match portrait, and V11's polish (tab labels, the one light
 * purple, the prompt mark and prompt set, settings dividers, activity rhythm, horizontal slider
 * handles, roomier small controls, the deeper fade), contrast, and that the screens still work, fit 393 and 375 px wide
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
          // V11: the one light purple is allowed only on the prompt mark (7b checks where and how big).
          if (!pseudo && el.matches(".prompt__mark") && r === 241 && g === 239 && b === 249) continue;
          if (Math.min(r, g, b) > 200 && Math.max(r, g, b) - Math.min(r, g, b) > 4) out.push(`${el.className.baseVal ?? el.className}${pseudo ?? ""} ${r},${g},${b}`.trim());
        }
      }
      return [...new Set(out)];
    });
    if (hits.length) tinted.push(`${path}: ${hits.slice(0, 3).join(", ")}`);
  }
  check("colour: every light surface is neutral white or grey (the prompt mark's tint aside): no beige, lavender or pastel on any themed screen", tinted.length === 0, tinted.join(" | "));

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
  check("containers: information containers (first-photo tip, why they liked you, the blocking note) are the flat secondary grey (#F7F7F8)", infos.length >= 3 && infos.every((r) => r.bg === "rgb(247, 247, 248)" && r.shadow === "none" && r.border === "0px" && r.r === "16px"), infos.map((r) => `${r.screen}: ${r.bg} ${r.shadow} ${r.r}`).join(" | "));
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

  // 4b4. Bottom navigation (V10): a traditional full-width tab bar. It spans the screen with no outer
  // margin or rounded capsule, is separated by a 1px top divider and no shadow, reaches the bottom edge
  // and pads the home-indicator area; the content scrolls above it and ends where it begins. The icons
  // keep the approved 24px, each item keeps a touch target of at least 44 x 44, and the active item is
  // the brand-purple icon with no background behind it. Checked at 393 x 852 and 375 x 667.
  const navOf = async (q, theme) => {
    await open(q, `flows.html?screen=likes${theme ? "&theme=tiimo" : ""}`);
    await q.mouse.move(0, 0); // the pointer may still rest on a tab from the navigation check (hover is ink)
    await wait(400); // let the colour transition finish
    return q.evaluate(() => {
      const bar = document.querySelector(".tab-bar");
      const screen = document.querySelector(".fl-frame__screen") ?? document.body;
      const body = bar.previousElementSibling;
      const items = [...bar.querySelectorAll(".tab-bar__item")];
      const cur = bar.querySelector(".tab-bar__item.is-current");
      const cs = getComputedStyle(bar);
      const b = bar.getBoundingClientRect(); const s = screen.getBoundingClientRect();
      const safe = parseFloat(getComputedStyle(bar).getPropertyValue("--safe-bottom")) || 0;
      return {
        h: b.height, left: b.left - s.left, right: s.right - b.right, bottomGap: s.bottom - b.bottom,
        radius: cs.borderTopLeftRadius, shadow: cs.boxShadow, bg: cs.backgroundColor,
        padBottom: parseFloat(cs.paddingBottom), safe,
        bodyEnd: body ? Math.round(body.getBoundingClientRect().bottom) : null, barTop: Math.round(b.top),
        bodyScrolls: body ? getComputedStyle(body).overflowY : null,
        icons: items.map((i) => { const r = i.querySelector(".tab-bar__icon svg").getBoundingClientRect(); return `${Math.round(r.width)}x${Math.round(r.height)}`; }),
        targets: items.map((i) => { const r = i.getBoundingClientRect(); return [Math.round(r.width), Math.round(r.height)]; }),
        labels: items.map((i) => i.getAttribute("aria-label") ?? i.textContent.trim()),
        current: { bg: getComputedStyle(cur).backgroundColor, icon: getComputedStyle(cur.querySelector(".tab-bar__icon")).color, ariaCurrent: cur.getAttribute("aria-current") },
        idleIcon: getComputedStyle(items.find((i) => i !== cur).querySelector(".tab-bar__icon")).color,
      };
    });
  };
  const navV10 = await navOf(p, true);
  const navApproved = await navOf(p, false);
  const short = await phone(375, 667);
  const navShort = await navOf(short, true);
  await short.context().close();
  const outerNav = (sh) => sh.split(/,(?![^(]*\))/).filter((x) => x.trim() !== "none" && !/inset/.test(x));
  check("navigation: a full-width bar at the bottom edge, square-cornered, with no outer margin (393 and 375 px)", [navV10, navShort].every((n) => n.left === 0 && n.right === 0 && n.bottomGap <= 0.5 && n.radius === "0px"), [navV10, navShort].map((n) => `left ${n.left} right ${n.right} bottom ${n.bottomGap} radius ${n.radius}`).join(" | "));
  check("navigation: a 1px top divider and no shadow; white", outerNav(navV10.shadow).length === 0 && /rgb\(228, 228, 231\) 0px 1px 0px 0px inset/.test(navV10.shadow) && navV10.bg === "rgb(255, 255, 255)", navV10.shadow);
  check("navigation: 56px of items plus the home-indicator inset; the content scrolls above the bar and ends where it begins", [navV10, navShort].every((n) => n.h === 56 + n.padBottom && n.padBottom === n.safe && n.safe > 0 && n.bodyEnd === n.barTop && n.bodyScrolls === "auto"), [navV10, navShort].map((n) => `${n.h}px = 56 + ${n.padBottom} (safe ${n.safe}); body ends ${n.bodyEnd}, bar ${n.barTop}`).join(" | "));
  check("navigation: icons keep the approved 24px size, and every item keeps a touch target of at least 44 x 44", navV10.icons.join() === navApproved.icons.join() && navV10.icons.every((i) => i === "24x24") && [navV10, navShort].every((n) => n.targets.every(([w, h]) => w >= 44 && h >= 44)), `icons ${navV10.icons.join(" ")}, targets ${navV10.targets.map(([w, h]) => `${w}x${h}`).join(" ")} / ${navShort.targets.map(([w, h]) => `${w}x${h}`).join(" ")}`);
  check("navigation: the active item is the brand-purple icon with no background; inactive icons are the neutral grey; labels and aria-current unchanged", navV10.current.bg === "rgba(0, 0, 0, 0)" && navV10.current.icon === "rgb(114, 98, 199)" && navV10.idleIcon === "rgb(119, 115, 125)" && navV10.current.ariaCurrent === navApproved.current.ariaCurrent && navV10.labels.join() === navApproved.labels.join(), JSON.stringify({ ...navV10.current, idle: navV10.idleIcon }));

  // 4b4'. Notification dots (V10): the tab bar's numeric badges become 8px red dots at the icon's upper
  // right, with no number drawn; the count stays in the badge's accessible label and the tab's name.
  // Numbers stay where they carry meaning: the Likes and Messages filter counts and the unread count.
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const dots = await p.evaluate(() => [...document.querySelectorAll(".tab-bar .count-badge")].map((d) => {
    // V11: the dot is the badge's ::after (the badge itself is visibility-hidden, so its digit is
    // neither drawn nor read).
    const cs = getComputedStyle(d); const dot = getComputedStyle(d, "::after"); const r = d.getBoundingClientRect(); const icon = d.closest(".tab-bar__icon").querySelector("svg").getBoundingClientRect();
    return { w: r.width, h: r.height, bg: dot.backgroundColor, radius: dot.borderTopLeftRadius, inkShown: cs.visibility !== "hidden" && cs.color !== "rgba(0, 0, 0, 0)" && parseFloat(cs.fontSize) > 0, label: d.getAttribute("aria-label"), text: d.textContent, tab: d.closest(".tab-bar__item").getAttribute("aria-label"), upperRight: r.left >= icon.left + icon.width / 2 && r.bottom <= icon.top + icon.height / 2 };
  }));
  const counts = await p.evaluate(() => ({ filters: [...document.querySelectorAll(".filter-chips .chip__count")].map((c) => c.textContent.trim()), unread: document.querySelector(".conversation__unread")?.textContent.trim(), unreadStyle: getComputedStyle(document.querySelector(".conversation__unread")).fontSize }));
  await open(p, "flows.html?screen=likes&theme=tiimo");
  const likeCounts = await p.evaluate(() => [...document.querySelectorAll(".filter-chips .chip__count")].map((c) => c.textContent.trim()));
  check("dots: every tab-bar badge is an 8px red dot at the icon's upper right, with no number drawn", dots.length >= 2 && dots.every((d) => d.w === 8 && d.h === 8 && d.bg === "rgb(185, 58, 54)" && d.radius === "50%" && !d.inkShown && d.upperRight), JSON.stringify(dots.map(({ w, h, bg, radius, inkShown, upperRight }) => ({ w, h, bg, radius, inkShown, upperRight }))));
  check("dots: the count stays available to assistive tech (badge label and the tab's name)", dots.every((d) => /^\d+ new in /.test(d.label) && /^\d+$/.test(d.text) && /, \d+ new$/.test(d.tab)), dots.map((d) => `${d.label} / ${d.tab}`).join(" | "));
  check("dots: numbers stay where they mean something (Likes and Messages filter counts, the unread count)", likeCounts.length >= 4 && likeCounts.every((c) => /^\d+$/.test(c)) && counts.filters.length >= 3 && counts.unread === "1" && parseFloat(counts.unreadStyle) > 0, `likes ${likeCounts.join(",")}; messages ${counts.filters.join(",")}; unread ${counts.unread}`);

  // 4b5. Conventional shapes where function needs them (V10): radios are circles; checkboxes are
  // slightly rounded squares; the notification dot is a dot. Everything else that is visible (a fill,
  // border, shadow or image) and square stays non-circular: avatars, icon buttons, counts, the FAB,
  // switch handles. The match scallop is an SVG mask, not a radius.
  const circles = [];
  const radios = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const r = await p.evaluate(() => {
      const out = []; const rad = [];
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
          const radius = cs.borderTopLeftRadius.endsWith("%") ? (parseFloat(cs.borderTopLeftRadius) / 100) * w : parseFloat(cs.borderTopLeftRadius);
          const circle = Math.abs(w - h) < 2 && radius >= w / 2 - 0.5;
          if (!pseudo && el.matches(".choice__input--radio")) { rad.push(circle); continue; }
          if (el.matches(".tab-bar .count-badge")) continue; // the notification dot (V11: drawn by its ::after)
          if (circle) out.push(`${el.className.baseVal ?? el.className}${pseudo ?? ""} ${Math.round(w)}px`.trim());
        }
      }
      return { out: [...new Set(out)], rad };
    });
    if (r.out.length) circles.push(`${path}: ${r.out.slice(0, 4).join(", ")}`);
    radios.push(...r.rad);
  }
  check("geometry: radios are circles", radios.length >= 6 && radios.every(Boolean), `${radios.filter(Boolean).length}/${radios.length}`);
  check("geometry: apart from radios and notification dots, no circular UI element on any themed screen (avatars, counts, icon buttons, the FAB, switch handles)", circles.length === 0, circles.join(" | "));

  // 4b5'. Switches and sliders (V10, V11): a slightly wider pill track with a compact pill handle that
  // is wider than tall (not a circle); slider handles are pills too (their V11 shape is checked in 7f,
  // read from the theme's stylesheet, since the native thumb has no computed style; Chromium, which
  // runs this suite, keeps only the WebKit thumb rule), on a pill rail.
  await open(p, "flows.html?screen=settings&theme=tiimo");
  const sw = await p.evaluate(() => [...document.querySelectorAll(".switch")].map((s) => {
    const cs = getComputedStyle(s); const t = getComputedStyle(s, "::after"); const r = s.getBoundingClientRect();
    return { w: r.width, h: r.height, r: cs.borderTopLeftRadius, tw: parseFloat(t.width), th: parseFloat(t.height), tr: t.borderTopLeftRadius, checked: s.checked, role: s.getAttribute("role") ?? s.type, on: cs.backgroundColor };
  }));
  const thumbRules = await p.evaluate(() => {
    const out = [];
    for (const sheet of document.styleSheets) {
      let rules; try { rules = sheet.cssRules; } catch { continue; }
      for (const r of rules) if (r.selectorText && /\.theme-tiimo .slider__track input::-(webkit-slider|moz-range)-thumb/.test(r.selectorText)) out.push({ sel: r.selectorText, w: r.style.width, radius: r.style.borderTopLeftRadius || r.style.borderRadius });
    }
    return out;
  });
  const rail = await p.evaluate(() => { const t = document.querySelector(".slider__track"); return { rail: getComputedStyle(t, "::before").borderTopLeftRadius, fill: getComputedStyle(t, "::after").borderTopLeftRadius, h: t.getBoundingClientRect().height }; });
  check("switches: a 58 x 32 pill track with a 34 x 26 pill handle (wider than tall), purple when on", sw.length >= 4 && sw.every((s) => s.w === 58 && s.h === 32 && s.r === "999px" && s.tw === 34 && s.th === 26 && s.tr === "999px" && s.role === "switch") && sw.filter((s) => s.checked).every((s) => s.on === "rgb(114, 98, 199)"), JSON.stringify(sw[0]));
  check("sliders: pill handles sized by the handle tokens, on a pill rail, same 28px row", thumbRules.length >= 1 && thumbRules.some((t) => /webkit/.test(t.sel)) && thumbRules.every((t) => t.w === "var(--tiimo-handle-slider-width)" && /var\(--tiimo-radius-pill\)/.test(t.radius)) && rail.rail === "999px" && rail.fill === "999px" && rail.h === 28, JSON.stringify({ thumbRules, rail }));

  // 4b5''. Nested corners (V10): where a rounded element sits close to the corner of a rounded parent,
  // its corner follows inner ≈ outer − inset: photo-slot badges and remove buttons, the Likes "New" label,
  // the photo inside an activity card, and the placeholder inside a photo slot.
  const nest = async (screen, inner, outer) => {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    return p.evaluate(([iq, oq]) => [...document.querySelectorAll(iq)].slice(0, 3).map((el) => {
      const o = el.closest(oq); const a = el.getBoundingClientRect(); const b = o.getBoundingClientRect();
      const inset = Math.round(Math.min(a.left - b.left, a.top - b.top, b.right - a.right, b.bottom - a.bottom) >= 0 ? Math.min(...[a.left - b.left, a.top - b.top, b.right - a.right, b.bottom - a.bottom].filter((v) => v <= 24)) : 0);
      return { inner: parseFloat(getComputedStyle(el).borderTopLeftRadius), outer: parseFloat(getComputedStyle(o).borderTopLeftRadius), inset };
    }), [inner, outer]);
  };
  const nested = [
    ["photos", ".photo-slot__index", ".photo-slot"], ["photos", ".photo-slot__remove", ".photo-slot"], ["photos", ".photo-slot .image-placeholder", ".photo-slot"],
    ["likes", ".person-tile__badge .badge", ".person-tile__photo"], ["activity", ".activity-card__media", ".activity-card"],
  ];
  const nestErrors = [];
  for (const [screen, inner, outer] of nested) {
    for (const n of await nest(screen, inner, outer)) if (Math.abs(n.inner - Math.max(0, n.outer - n.inset)) > 2) nestErrors.push(`${screen} ${inner}: outer ${n.outer} inset ${n.inset} inner ${n.inner}`);
  }
  check("geometry: nested corners follow inner ≈ outer − inset (photo slots and their badges, the Likes label, the activity photo)", nestErrors.length === 0, nestErrors.join(" | "));

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

  // 4b8. Status labels: one shape (8px corner) in semantic tones. "Your move" neutral grey with ink;
  // "New" on a like white with deep purple; the unread count a solid purple pill; tab notifications
  // the approved red, as dots (4b4').
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const labelsChats = await p.evaluate(() => {
    const s = (q, pseudo = null) => { const el = document.querySelector(q); const cs = getComputedStyle(el, pseudo); return { bg: cs.backgroundColor, fg: cs.color, r: cs.borderTopLeftRadius, h: el.getBoundingClientRect().height }; };
    // V11: the tab notification dot is drawn by the badge's ::after.
    return { move: s(".conversation__move"), unread: s(".conversation__unread"), count: s(".tab-bar .count-badge", "::after") };
  });
  await open(p, "flows.html?screen=likes&theme=tiimo");
  const labelNew = await p.evaluate(() => { const cs = getComputedStyle(document.querySelector(".person-tile__badge .badge")); return { bg: cs.backgroundColor, fg: cs.color, r: cs.borderTopLeftRadius }; });
  check("labels: \"Your move\" is the neutral grey with ink text", labelsChats.move.bg === "rgb(240, 240, 242)" && labelsChats.move.fg === "rgb(40, 38, 45)" && labelsChats.move.r === "8px", JSON.stringify(labelsChats.move));
  check("labels: \"New\" on a like is white with deep-purple text (emphasis, not a fill)", labelNew.bg === "rgb(255, 255, 255)" && labelNew.fg === "rgb(79, 66, 150)" && labelNew.r === "8px", JSON.stringify(labelNew));
  check("labels: the unread count is a solid brand-purple pill with white text; tab notifications keep the approved red", labelsChats.unread.bg === "rgb(114, 98, 199)" && labelsChats.unread.fg === "rgb(255, 255, 255)" && labelsChats.count.bg === "rgb(185, 58, 54)" && labelsChats.unread.r === "999px", `${JSON.stringify(labelsChats.unread)} ${JSON.stringify(labelsChats.count)}`);

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

  // 4e. Shapes (V10). Every rendered instance on the listed screens is checked against the balanced
  // scale: full pills (999px) for compact actions and toggles; rounded rectangles for structured
  // controls and surfaces (check 6, tag 8, chip, control and item 12, button 14, card 16, photo 20);
  // avatars at a quarter of their size; radios circular.
  const SHAPES = {
    ".btn--primary:not(.btn--sm)": "14px", ".btn--secondary:not(.btn--sm)": "14px", ".btn--quiet:not(.btn--sm)": "14px", ".btn--sm": "999px",
    ".nav-button": "12px", ".fab": "16px", ".composer__send": "12px",
    ".input": "12px", ".search": "12px", ".composer__field": "12px", ".option-card": "12px",
    ".chip[data-emoji]": "12px", ".chip--static:not([data-emoji])": "12px", ".filter-chips:not(:has(.chip[data-emoji])) .chip": "999px", ".segmented__item": "999px",
    ".conversation__move": "8px", ".profile-card__pill": "8px", ".person-tile__badge .badge": "8px", ".activity-card__category": "8px",
    ".choice__input--checkbox": "6px", ".choice__input--radio": "50%", ".tab-bar .count-badge": "50%", ".conversation__unread": "999px",
    ".activity-card": "16px", ".activity-card__media": "8px", ".person-tile__photo": "16px", ".message__bubble": "16px", ".match-queue__image": "16px",
    ".photo-slot": "16px", ".info-card": "16px", ".prompt": "16px", ".list-group__items": "16px",
    ".profile-card__media": "20px", ".fl-pf__photo": "20px", ".action-bar__btn": "999px", ".tab-bar": "0px", ".switch": "999px",
    ".avatar--xs .avatar__image": "6px", ".avatar--sm .avatar__image": "9px", ".avatar--lg:not(.match__you) .avatar__image": "16px", ".avatar--xl .avatar__image": "24px",
    ".match__you .avatar__image": "16px", ".progress__segment": "999px",
  };
  const shapeErrors = [];
  const seen = new Set();
  for (const s of ["basics", "photos", "interests", "discovery", "like-profile", "likes", "chats", "chat", "match", "activity", "prompt", "profile", "settings"]) {
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
  check("shapes: pills, rounded rectangles, avatars, radios and the tab bar follow the V10 balanced scale", shapeErrors.length === 0, shapeErrors.slice(0, 6).join(" | "));

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
  // V10: their portrait is about 12% larger than the approved one (both are capped by the viewport width here: 74vw against 66vw) and uses the softer eight-lobe
  // scallop (a different mask from the approved ten-lobe frame, still an SVG path).
  const portraitOf = async (theme) => {
    await openSeeded(p, `flows.html?screen=match${theme ? "&theme=tiimo" : ""}`, MATCHED);
    return p.evaluate(() => { const f = document.querySelector(".match .organic-portrait"); const ph = f.querySelector(".organic-portrait__photo"); return { w: Math.round(f.getBoundingClientRect().width), mask: getComputedStyle(ph).maskImage || getComputedStyle(ph).webkitMaskImage }; });
  };
  const portraitV10 = await portraitOf(true);
  const portraitApproved = await portraitOf(false);
  const lobes = (m) => (decodeURIComponent(m).match(/L/g) || []).length;
  check("match: their portrait is about 12% larger than the approved one, with the softer scallop (a different SVG mask, same path length)", portraitV10.w / portraitApproved.w >= 1.1 && portraitV10.w / portraitApproved.w <= 1.15 && /svg/.test(portraitV10.mask) && portraitV10.mask !== portraitApproved.mask && lobes(portraitV10.mask) === lobes(portraitApproved.mask), `${portraitV10.w}px vs ${portraitApproved.w}px`);

  // 4g. Pills: only the emoji-and-text pills. Unselected: the inset grey, no border; selected: solid
  // brand purple; a 12px rounded rectangle (V10, a content chip); no gradient.
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
  check("pills: every emoji-and-text pill is a 12px rounded rectangle, not a capsule", pills.length > 10 && pills.every((c) => c.r === 12 && c.h >= 32), [...new Set(pills.map((c) => `${c.r}px on ${Math.round(c.h)}px`))].join(", "));
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

  // 7. V11 polish. Each check below fails on V10's code.
  // 7a. Navigation labels: each tab is the approved 24px icon over a short visible label (the tab's
  // product name), centred below it, at 393 and 375 px. Active icon and label are brand purple, the
  // others the neutral grey. The label repeats the accessible name, so it is hidden from assistive
  // tech, and the tab's name, aria-current and routing are unchanged. Without the flag the bar stays
  // icon-only.
  const TAB_NAMES = ["Home", "Activity", "Likes", "Messages", "Profile"];
  const labelsOf = async (q, theme) => {
    await open(q, `flows.html?screen=likes${theme ? "&theme=tiimo" : ""}`);
    await q.mouse.move(0, 0);
    await wait(400);
    return q.evaluate(() => [...document.querySelectorAll(".tab-bar__item")].map((item) => {
      const label = item.querySelector(".tab-bar__label");
      const icon = item.querySelector(".tab-bar__icon svg").getBoundingClientRect();
      const ls = label && getComputedStyle(label); const lr = label?.getBoundingClientRect(); const ir = item.getBoundingClientRect();
      return {
        text: label?.textContent, shown: !!label && ls.display !== "none" && lr.height > 0, hidden: label?.getAttribute("aria-hidden"),
        size: ls && parseFloat(ls.fontSize), colour: ls?.color, iconColour: getComputedStyle(item.querySelector(".tab-bar__icon")).color,
        below: lr && lr.top >= icon.bottom && lr.top - icon.bottom <= 6, centred: lr && Math.abs((lr.left + lr.right) / 2 - (icon.left + icon.right) / 2) <= 1,
        inside: lr && lr.left >= ir.left && lr.right <= ir.right && lr.bottom <= ir.bottom, fits: label && label.scrollWidth <= label.clientWidth,
        baseline: lr && Math.round(lr.bottom), current: item.classList.contains("is-current"), name: item.getAttribute("aria-label"),
      };
    }));
  };
  const lab393 = await labelsOf(p, true);
  const q375 = await phone(375, 667);
  const lab375 = await labelsOf(q375, true);
  const labApproved = await labelsOf(q375, false);
  await q375.context().close();
  check("V11 navigation: every tab shows its label below the icon, centred, inside the tab and unclipped (393 and 375 px)", [lab393, lab375].every((l) => l.length === 5 && l.map((x) => x.text).join() === TAB_NAMES.join() && l.every((x) => x.shown && x.below && x.centred && x.inside && x.fits) && new Set(l.map((x) => x.baseline)).size === 1), JSON.stringify(lab375.map(({ text, shown, below, centred, inside, fits, baseline }) => ({ text, shown, below, centred, inside, fits, baseline }))));
  check("V11 navigation: labels are 11px; the active icon and label are brand purple, the others the neutral grey; no active background", lab393.every((x) => x.size === 11) && lab393.filter((x) => x.current).every((x) => x.colour === "rgb(114, 98, 199)" && x.iconColour === "rgb(114, 98, 199)") && lab393.filter((x) => !x.current).every((x) => x.colour === "rgb(119, 115, 125)" && x.iconColour === "rgb(119, 115, 125)") && lab393.filter((x) => x.current).length === 1, JSON.stringify(lab393.map(({ text, colour, iconColour }) => ({ text, colour, iconColour }))));
  check("V11 navigation: the visible label is hidden from assistive tech; the tab's accessible name is unchanged; without the flag the bar stays icon-only", lab393.every((x) => x.hidden === "true") && lab393.map((x) => x.name).join() === labApproved.map((x) => x.name).join() && labApproved.every((x) => !x.shown), lab393.map((x) => x.name).join(" | "));
  for (const [i, name] of TAB_NAMES.entries()) {
    await open(p, "flows.html?screen=profile&theme=tiimo");
    await p.locator(".tab-bar__item").nth(i).click();
    await wait(300);
    const at = await p.evaluate(() => ({ current: document.querySelector(".tab-bar__item.is-current .tab-bar__label")?.textContent, themed: !!document.querySelector(".theme-tiimo"), aria: document.querySelector(".tab-bar__item[aria-current=page] .tab-bar__label")?.textContent }));
    if (at.current !== name || at.aria !== name || !at.themed) { check(`V11 navigation: tapping ${name} opens it and marks it current`, false, JSON.stringify(at)); break; }
    if (i === TAB_NAMES.length - 1) check("V11 navigation: tapping each tab opens it, marks it current (aria-current) and keeps the theme", true);
  }
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const dotClear = await p.evaluate(() => [...document.querySelectorAll(".tab-bar .count-badge")].map((d) => {
    const r = d.getBoundingClientRect(); const item = d.closest(".tab-bar__item");
    const icon = item.querySelector(".tab-bar__icon svg").getBoundingClientRect(); const label = item.querySelector(".tab-bar__label")?.getBoundingClientRect();
    return { clearOfIcon: r.left >= icon.right, aboveLabel: !!label && label.height > 0 && r.bottom <= label.top - 8, nearIcon: r.left - icon.right <= 4 && r.top <= icon.top + 2 };
  }));
  check("V11 dots: each red dot sits just outside the icon's upper-right corner, clear of the glyph and well above the label", dotClear.length >= 2 && dotClear.every((d) => d.clearOfIcon && d.aboveLabel && d.nearIcon), JSON.stringify(dotClear));

  // 7b. The light purple: one tint (#F1EFF9), used only as the small prompt-mark holder. No other
  // light surface on any themed screen is tinted (checked in 4b2), and pills keep their grey/purple.
  const tintUses = [];
  for (const screen of ["interests", "discovery", "like-profile", "profile", "edit", "likes", "chats", "activity", "settings"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    tintUses.push(...(await p.evaluate((s) => [...document.querySelectorAll(".theme-tiimo *")].filter((el) => getComputedStyle(el).backgroundColor === "rgb(241, 239, 249)").map((el) => { const r = el.getBoundingClientRect(); return { s, cls: el.className.baseVal ?? el.className, w: r.width, h: r.height }; }), screen)));
  }
  const tintToken = await p.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue("--color-palette-brand-tint").trim());
  check("V11 purple: the one light purple (#F1EFF9) appears only as the 22px prompt-mark holder, never on a card, pill or large area", tintToken.length > 0 && tintUses.length >= 4 && tintUses.every((t) => t.cls === "prompt__mark" && t.w === 22 && t.h === 22), `${tintToken}; ${[...new Set(tintUses.map((t) => `${t.s} ${t.cls} ${t.w}x${t.h}`))].join(" | ")}`);

  // 7c. Prompts: no decorative quotation mark; a small brand-purple speech-bubble mark sits before the
  // question (not the answer), vertically centred on it, and the answer stays the largest text. Same
  // on Profile, Edit profile, Interests, and someone's profile (Discover, Like back).
  const promptLook = [];
  for (const screen of ["profile", "edit", "interests", "discovery", "like-profile"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    promptLook.push(...(await p.evaluate((s) => [...document.querySelectorAll(".prompt, .profile-section--prompt")].map((el) => {
      const q = el.querySelector(".prompt__label, .profile-section__title"); const a = el.querySelector(".prompt__answer, .profile-section__answer");
      const mark = q.querySelector(".prompt__mark"); const mr = mark?.getBoundingClientRect(); const qr = q.getBoundingClientRect();
      const glyph = mark?.querySelector("svg");
      const quote = getComputedStyle(el, "::after").content;
      const text = [...q.childNodes].filter((n) => n.nodeType === 3).map((n) => n.textContent).join("").trim();
      return { s, quote, markFirst: q.firstElementChild === mark && q.firstChild === mark, notInAnswer: !a.querySelector(".prompt__mark"), size: mr && `${mr.width}x${mr.height}`, glyph: glyph && `${glyph.getBoundingClientRect().width}`, colour: mark && getComputedStyle(mark).color, hidden: mark?.getAttribute("aria-hidden"), centred: mr && Math.abs((mr.top + mr.bottom) / 2 - (qr.top + qr.bottom) / 2) <= 1.5, text, answerBigger: parseFloat(getComputedStyle(a).fontSize) > parseFloat(getComputedStyle(q).fontSize) };
    }), screen)));
  }
  check("V11 prompts: no decorative quotation mark on any prompt (Profile, Edit, Interests, Discover, Like back)", promptLook.length >= 5 && promptLook.every((x) => x.quote === "none" || x.quote === "normal"), promptLook.map((x) => `${x.s}: ${x.quote}`).join(" | "));
  check("V11 prompts: a 22px brand-purple speech-bubble mark (14px glyph) comes first in the question, centred on it, never in the answer; decorative", promptLook.length >= 5 && promptLook.every((x) => x.markFirst && x.notInAnswer && x.size === "22x22" && x.glyph === "14" && x.colour === "rgb(114, 98, 199)" && x.hidden === "true" && x.centred), JSON.stringify(promptLook.map(({ s, markFirst, size, glyph, colour, centred }) => ({ s, markFirst, size, glyph, colour, centred }))));
  check("V11 prompts: the question text is unchanged and the answer stays larger than it", promptLook.every((x) => x.text.length > 3 && x.answerBigger) && promptLook.some((x) => x.text === "A perfect first date"), promptLook.map((x) => x.text).join(" | "));
  const approvedMark = await (async () => { await open(p, "flows.html?screen=profile"); return p.evaluate(() => { const m = document.querySelector(".prompt__mark"); return { mark: m ? getComputedStyle(m).display : "absent", quote: getComputedStyle(document.querySelector(".prompt"), "::after").content }; }); })();
  check("V11 prompts: without the flag the approved prompt keeps its quote glyph and shows no mark", (approvedMark.mark === "none" || approvedMark.mark === "absent") && approvedMark.quote !== "none", JSON.stringify(approvedMark));
  // Up to three prompts, as one set. The session holds one prompt today, so this seeds a test-only
  // list made of the repo's own prompt texts (data.js) to exercise the set; a fourth entry and an
  // unanswered one are not shown, and only the first (the one the prompt editor edits) has the edit action.
  const FOUR = [initialState.profile.prompt, { q: "My Sunday ritual", a: "Sea swim, then the longest breakfast in the city." }, { q: "", a: "" }, { q: "A green flag", a: "You still send postcards." }, { q: "Let’s debate this", a: "Croissants are a dinner food." }];
  const seededProfile = { profile: { ...initialState.profile, prompts: FOUR } };
  const setOf = async (screen) => {
    await openSeeded(p, `flows.html?screen=${screen}&theme=tiimo`, seededProfile);
    return p.evaluate(() => {
      const set = document.querySelector(".prompt-set");
      const items = set ? [...set.querySelectorAll(".prompt")] : [];
      const cs = set && getComputedStyle(set);
      return {
        n: items.length, qs: items.map((i) => i.querySelector(".prompt__label").textContent), edits: items.map((i) => !!i.querySelector(".prompt__actions button")),
        outlined: cs && cs.boxShadow === "rgb(228, 228, 231) 0px 0px 0px 1px inset" && cs.borderTopLeftRadius === "16px", inner: items.map((i) => getComputedStyle(i).boxShadow),
        dividers: items.slice(1).map((i) => { const d = getComputedStyle(i, "::before"); return d.content !== "none" && d.height === "1px" && d.backgroundColor === "rgb(228, 228, 231)"; }),
      };
    });
  };
  const setProfile = await setOf("profile");
  const setEdit = await setOf("edit");
  check("V11 prompts: up to three answered prompts show as one outlined set divided by hairlines (Profile and Edit), not stacked cards", [setProfile, setEdit].every((s) => s.n === 3 && s.outlined && s.inner.every((x) => x === "none") && s.dividers.length === 2 && s.dividers.every(Boolean)), JSON.stringify({ setProfile, setEdit }));
  check("V11 prompts: the set keeps the order, skips the unanswered entry and the fourth prompt, and only the first opens the prompt editor", [setProfile, setEdit].every((s) => s.qs.join("|") === "A perfect first date|My Sunday ritual|A green flag" && s.edits.join() === "true,false,false"), JSON.stringify(setProfile.qs));
  await open(p, "flows.html?screen=profile&theme=tiimo");
  const single = await p.evaluate(() => ({ sets: document.querySelectorAll(".prompt-set").length, prompts: document.querySelectorAll(".prompt").length, title: document.querySelector(".list-group__title").textContent }));
  check("V11 prompts: with the one prompt the session holds, Profile shows exactly that prompt (no placeholder answers)", single.sets === 0 && single.prompts === 1 && single.title === "Your prompt", JSON.stringify(single));
  await openSeeded(p, "flows.html?screen=profile&theme=tiimo", seededProfile);
  await p.getByRole("button", { name: "Edit answer to A perfect first date" }).click();
  await wait(400);
  const editorUrl = new URL(p.url());
  check("V11 prompts: the first prompt's edit action still opens the prompt editor, themed", editorUrl.searchParams.get("screen") === "prompt" && editorUrl.searchParams.get("theme") === "tiimo" && (await themed(p)), editorUrl.search);

  // 7d. Settings dividers: inside a group, each divider is inset 16px on both sides (the rows'
  // padding), so it spans exactly the content column; text and toggles keep their positions.
  await open(p, "flows.html?screen=settings&theme=tiimo");
  const groups = await p.evaluate(() => [...document.querySelectorAll(".list-group__items")].filter((g) => g.children.length > 1).map((g) => {
    const gr = g.getBoundingClientRect();
    const rows = [...g.children].map((li) => {
      const hit = li.querySelector(".list-row__hit"); const hr = hit.getBoundingClientRect();
      const text = li.querySelector(".switch-row__text, .list-row__text, .list-row__icon").getBoundingClientRect();
      const toggle = li.querySelector(".switch, .list-row__trail")?.getBoundingClientRect();
      return { divider: getComputedStyle(hit).boxShadow !== "none", left: Math.round(hr.left - gr.left), right: Math.round(gr.right - hr.right), text: Math.round(text.left - gr.left), toggleRight: toggle && Math.round(gr.right - toggle.right), h: Math.round(li.getBoundingClientRect().height) };
    });
    return rows;
  }));
  const notif = groups.find((g) => g.length === 3);
  check("V11 settings: every divider between grouped rows is inset 16px on both sides, level with the row text", groups.length >= 2 && groups.every((g) => g.slice(1).every((r) => r.divider && r.left === 16 && r.right === 16)) && notif.every((r) => r.text === 16), JSON.stringify(groups));
  check("V11 settings: toggles stay at one position (16px from the group edge) and rows keep their height", notif && new Set(notif.map((r) => r.toggleRight)).size === 1 && notif[0].toggleRight === 16 && notif.every((r) => r.h === notif[0].h), JSON.stringify(notif));

  // 7e. Activity card rhythm: title → category 8px, category → date 12px, date → place 6px, place →
  // host 12px; meta icons are centred on their text's first line.
  await open(p, "flows.html?screen=activity&theme=tiimo");
  const rhythm = await p.evaluate(() => {
    const c = document.querySelector(".activity-card:not(.activity-card--compact)");
    const box = (sel, i = 0) => c.querySelectorAll(sel)[i].getBoundingClientRect();
    const t = box(".activity-card__title"); const cat = box(".activity-card__category"); const m1 = box(".meta-row"); const m2 = box(".meta-row", 1); const foot = box(".activity-card__foot");
    const icons = [...c.querySelectorAll(".meta-row")].map((m) => { const i = m.querySelector(".meta-row__icon").getBoundingClientRect(); const lh = parseFloat(getComputedStyle(m).lineHeight); const top = m.getBoundingClientRect().top; return Math.abs((i.top + i.bottom) / 2 - (top + lh / 2)); });
    const body = c.querySelector(".activity-card__body").getBoundingClientRect(); const card = c.getBoundingClientRect();
    return { titleToCat: Math.round(cat.top - t.bottom), catToMeta: Math.round(m1.top - cat.bottom), metaGap: Math.round(m2.top - m1.bottom), metaToFoot: Math.round(foot.top - m2.bottom), icons, padL: Math.round(body.left - card.left), padR: Math.round(card.right - body.right) };
  });
  check("V11 activity: the card's metadata follows one rhythm (title 8, category 12, details 6, host 12) with equal side padding", rhythm.titleToCat === 8 && rhythm.catToMeta === 12 && rhythm.metaGap === 6 && rhythm.metaToFoot === 12 && rhythm.padL === rhythm.padR, JSON.stringify(rhythm));
  check("V11 activity: date and place icons are centred on the first line of their text", rhythm.icons.every((d) => d <= 1.5), rhythm.icons.map((d) => d.toFixed(1)).join(", "));

  // 7f. Slider handles share the switch handle's shape: a white horizontal pill, one step smaller
  // (tokens --tiimo-handle-*), read from the theme's WebKit thumb rule and resolved against the tokens.
  await open(p, "flows.html?screen=settings&theme=tiimo");
  const handles = await p.evaluate(() => {
    const root = getComputedStyle(document.documentElement); const v = (s) => s.replace(/var\((--[\w-]+)\)/, (_, n) => root.getPropertyValue(n).trim());
    let rule = null;
    for (const sheet of document.styleSheets) { let rules; try { rules = sheet.cssRules; } catch { continue; } for (const r of rules) if (r.selectorText === ".theme-tiimo .slider__track input::-webkit-slider-thumb") rule = r; }
    const sw = getComputedStyle(document.querySelector(".switch"), "::after");
    return { thumb: rule && { w: parseFloat(v(rule.style.width)), h: parseFloat(v(rule.style.height)), r: v(rule.style.borderTopLeftRadius || rule.style.borderRadius) }, handle: { w: parseFloat(sw.width), h: parseFloat(sw.height), r: sw.borderTopLeftRadius, bg: sw.backgroundColor }, sliders: document.querySelectorAll(".slider__track input[type=range]").length };
  });
  check("V11 sliders: age and distance handles are horizontal white pills like the switch handle (30 x 22 against 34 x 26), on the same 28px row", handles.thumb && handles.thumb.w === 30 && handles.thumb.h === 22 && handles.thumb.r === "999px" && handles.thumb.w > handles.thumb.h && handles.thumb.w < handles.handle.w && handles.handle.w > handles.handle.h && handles.handle.r === "999px" && handles.sliders >= 3, JSON.stringify(handles));
  const before = await p.evaluate(() => document.querySelector(".slider__value").textContent);
  await p.locator(".slider__track input").first().focus();
  await p.keyboard.press("ArrowRight");
  const after = await p.evaluate(() => document.querySelector(".slider__value").textContent);
  const sw0 = p.locator(".switch").first();
  const was = await sw0.isChecked();
  await sw0.click();
  const now = await sw0.isChecked();
  await sw0.click();
  check("V11 sliders and switches: the keyboard still moves a slider and a switch still toggles", before !== after && was !== now, `${before} → ${after}; switch ${was} → ${now}`);

  // 7g. Roomier small controls: header icon buttons are all 40px, small buttons 44px tall (the touch
  // height), status labels 26px, the photo remove button 28px; metadata icons stay 18px.
  const sizes = {};
  for (const screen of ["discovery", "profile", "activity", "chat", "photos", "likes"]) {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    sizes[screen] = await p.evaluate(() => {
      const dims = (sel) => [...document.querySelectorAll(sel)].map((e) => { const r = e.getBoundingClientRect(); return `${Math.round(r.width)}x${Math.round(r.height)}`; });
      return { header: dims(".nav-button--floating"), sm: dims(".btn--sm").map((d) => d.split("x")[1]), badge: dims(".badge").map((d) => d.split("x")[1]), remove: dims(".photo-slot__remove"), meta: dims(".meta-row__icon") };
    });
  }
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  await p.getByRole("button", { name: /filter/i }).first().click();
  await wait(500);
  sizes.filters = { header: await p.evaluate(() => [...document.querySelectorAll(".sheet .nav-button--flat")].map((e) => { const r = e.getBoundingClientRect(); return `${Math.round(r.width)}x${Math.round(r.height)}`; })), sm: [], badge: [], remove: [], meta: [] };
  const all = (k) => Object.values(sizes).flatMap((s) => s[k]);
  check("V11 sizing: header and sheet-close icon buttons are one 40px size, small buttons 44px, status labels 26px, the photo remove button 28px; meta icons stay 18px", all("header").length >= 5 && sizes.filters.header.length === 1 && all("header").every((d) => d === "40x40") && all("sm").length >= 3 && all("sm").every((h) => h === "44") && all("badge").length >= 3 && all("badge").every((h) => h === "26") && all("remove").length >= 3 && all("remove").every((d) => d === "28x28") && all("meta").every((d) => d === "18x18"), JSON.stringify(sizes));

  // 7h. The photo fade (V11): near-black at the bottom edge (92%), easing out with no slope at either
  // end and clear by 55% of the photo, so white text sits on dark, not on a grey wash. Placeholders
  // keep their solid band and no fade.
  const v11fade = await (async () => {
    await withPhoto("discovery");
    return p.evaluate(() => { const f = getComputedStyle(document.querySelector(".profile-card__media"), "::before"); const m = document.querySelector(".profile-card__media").getBoundingClientRect(); return { h: parseFloat(f.height) / m.height, g: f.backgroundImage }; });
  })();
  const fa = [...v11fade.g.matchAll(/[,/] ([\d.]+)\)/g)].map((m) => Number(m[1]));
  const diffs = fa.slice(1).map((v, i) => fa[i] - v);
  check("V11 fade: 92% black at the bottom, clear at 55% of the photo, gentle at both ends (an ease-in-out, steepest mid-way)", Math.abs(fa[0] - 0.92) < 0.005 && Math.abs(v11fade.h - 0.55) < 0.01 && diffs[0] < diffs[4] && diffs.at(-1) < diffs[4] && diffs.every((d) => d >= 0), `${fa.map((a) => a.toFixed(3)).join(" ")} over ${(v11fade.h * 100).toFixed(0)}%`);
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  const band = await p.evaluate(() => { const m = document.querySelector(".profile-card__media"); const o = getComputedStyle(m.querySelector(".profile-card__overlay")); return { img: !!m.querySelector(".profile-card__img"), fade: getComputedStyle(m, "::before").content, bandBg: o.backgroundColor, bandImg: o.backgroundImage }; });
  check("V11 fade: a placeholder keeps its solid dark information band and gets no fade", !band.img && (band.fade === "none" || band.fade === "normal") && band.bandImg === "none" && !/rgba\(0, 0, 0, 0\)/.test(band.bandBg), JSON.stringify(band));

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
