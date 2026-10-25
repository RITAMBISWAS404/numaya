#!/usr/bin/env node
/**
 * The opt-in Tiimo-inspired experiment (`?theme=tiimo`, artifacts/tiimo-inspired-experiment/, refined
 * in artifacts/tiimo-white-surface-refinement/).
 * Its own contract, kept apart from the approved design's checks in smoke.mjs and product.mjs:
 * scoping (only the 12 selected screens, only with the flag), the visual rules that carry meaning
 * (white canvas, no computed gradient, neutral fields, solid purple for your messages, category tones
 * with readable inks, decorative emoji), and that the screens still work,
 * fit 393 and 375 px wide and log no errors. Run by `npm run test:e2e`.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity"];
const OUTSIDE = ["profile", "edit", "settings", "insights", "activity-detail"];

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}
const lum = (rgb) => {
  const [r, g, b] = rgb.match(/\d+/g).slice(0, 3).map((v) => {
    v /= 255;
    return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  });
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
  check("scoping: with ?theme=tiimo all 12 selected screens carry it", missing.length === 0, missing.join(", "));

  const leaked = [];
  for (const s of OUTSIDE) {
    await open(p, `flows.html?screen=${s}&theme=tiimo`);
    if (await themed(p)) leaked.push(s);
  }
  check("scoping: screens outside the experiment keep the approved design even with the flag", leaked.length === 0, leaked.join(", "));

  // 2. Visual contract on Interests: canvas, tinted category capsules, decorative emoji.
  await open(p, "flows.html?screen=interests&theme=tiimo");
  const look = await p.evaluate(() => {
    const cs = (el) => getComputedStyle(el);
    const screen = document.querySelector(".fl-screen");
    const labels = [...document.querySelectorAll(".chip-group__set-label[data-tone]")].map((el) => ({ tone: el.dataset.tone, fg: cs(el).color, bg: cs(el).backgroundColor }));
    const chip = [...document.querySelectorAll(".chip")].find((c) => c.textContent.includes("Natural wine"));
    return {
      canvas: cs(screen).backgroundColor,
      labels,
      chip: { pressed: chip.getAttribute("aria-pressed"), tone: chip.dataset.tone, bg: cs(chip).backgroundColor, fg: cs(chip).color, emoji: getComputedStyle(chip, "::after").content },
    };
  });
  check("look: themed screens sit on a pure white canvas", look.canvas === "rgb(255, 255, 255)", look.canvas);
  check("look: interest sets are tinted capsules (peach, lilac, mint)", look.labels.map((l) => l.tone).join() === "peach,lilac,mint", look.labels.map((l) => l.tone).join());
  const worstLabel = Math.min(...look.labels.map((l) => ratio(l.fg, l.bg)));
  check("contrast: capsule ink on its tint is at least 4.5:1", worstLabel >= 4.5, worstLabel.toFixed(2));
  check("look: a selected interest takes its category tint and ink", look.chip.pressed === "true" && look.chip.tone === "peach" && look.chip.bg === "rgb(253, 232, 220)", `${look.chip.tone} ${look.chip.bg}`);
  check("contrast: selected interest text on its tint is at least 4.5:1", ratio(look.chip.fg, look.chip.bg) >= 4.5, ratio(look.chip.fg, look.chip.bg).toFixed(2));
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

  // 4. Messages: yours solid brand purple with white text, theirs a distinct light neutral.
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
  check("look: their messages are a light neutral, distinct from yours and from the canvas", bubbles.them.bg !== bubbles.me.bg && bubbles.them.bg !== "rgb(255, 255, 255)" && lum(bubbles.them.bg) > 0.8, bubbles.them.bg);
  check("contrast: their message text is at least 4.5:1", ratio(bubbles.them.fg, bubbles.them.bg) >= 4.5, ratio(bubbles.them.fg, bubbles.them.bg).toFixed(2));

  // 4b. Fields are white or a light neutral grey, never a warm tint (equal R, G and B).
  await open(p, "flows.html?screen=basics&theme=tiimo");
  const field = await p.evaluate(() => getComputedStyle(document.querySelector(".input")).backgroundColor);
  const [fr, fg, fb] = field.match(/\d+/g).map(Number);
  check("look: text fields are a light neutral (no warm or sandy fill)", fr === fg && fg === fb && fr >= 240, field);

  // 4c. No gradients: no element or pseudo-element inside the theme computes a gradient, on every
  // themed screen. Real photographs are images, not gradients, so they never match.
  const gradients = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`)]) {
    await open(p, path);
    const found = await p.evaluate(() => {
      const hits = [];
      for (const root of document.querySelectorAll(".theme-tiimo")) {
        for (const el of [root, ...root.querySelectorAll("*")]) {
          for (const pseudo of [null, "::before", "::after"]) {
            const cs = getComputedStyle(el, pseudo);
            if (/gradient/.test(cs.backgroundImage) || /gradient/.test(cs.borderImageSource) || /gradient/.test(cs.maskImage)) {
              hits.push(`${el.tagName.toLowerCase()}.${[...el.classList].join(".")}${pseudo ?? ""}`);
            }
          }
        }
      }
      return [...new Set(hits)];
    });
    if (found.length) gradients.push(`${path}: ${found.slice(0, 3).join(", ")}`);
  }
  check("look: no computed gradient on the 12 themed screens (elements and ::before/::after)", gradients.length === 0, gradients.join(" | "));

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
    check(`responsive ${w}: no horizontal overflow on the 12 themed screens`, wide.length === 0, wide.join(", "));
    check(`console ${w}: no errors on the 12 themed screens`, q.errors.length === 0, q.errors.slice(0, 3).join(" | "));
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
