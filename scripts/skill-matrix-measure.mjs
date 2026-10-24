#!/usr/bin/env node
/**
 * Skill-combination matrix: rendered contrast of the elements the variants change, measured on any
 * checkout of the app.
 *
 *   node scripts/skill-matrix-measure.mjs <ID> --root <checkout>
 *
 * For each target the text or icon colour is read from the computed style, then the element's own
 * foreground is hidden and the pixels behind it are captured: what the user actually sees behind the
 * glyphs (photo, scrim, glass wash, page content through glass). Reports the contrast against the
 * median backdrop pixel and against the 2nd-percentile worst pixel. Appends one JSON line per target to
 * artifacts/skill-combination-matrix/measurements.jsonl.
 */
import { appendFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { createServer } from "vite";

const [id, flag, rootArg] = process.argv.slice(2);
if (!id || flag !== "--root") throw new Error("usage: skill-matrix-measure.mjs <ID> --root <checkout>");
const ROOT = resolve(rootArg);
const HERE = resolve(import.meta.dirname, "..");
const OUT = resolve(HERE, "artifacts/skill-combination-matrix/measurements.jsonl");
const { initialState, STORAGE_KEY } = await import(pathToFileURL(resolve(ROOT, "src/flows/store.js")).href);
const session = (patch = {}) => ({ ...initialState, ...patch, profile: { ...initialState.profile, ...patch.profile } });

/* Targets: [screen url, seeded state, label, selector, scroll before measuring (-1: into view)]. */
const TARGETS = [
  ["flows.html?screen=discovery", null, "SuperSwipe star on photo", ".profile-card__actions .action-bar__btn--super", 0],
  ["flows.html?screen=discovery", null, "Name over photo scrim", ".profile-card__name", 0],
  ["flows.html?screen=discovery", null, "Tab icon, inactive (rest)", ".tab-bar__item:not(.is-current)", 0],
  ["flows.html?screen=discovery", null, "Tab icon, inactive (scrolled over prompt)", ".tab-bar__item:not(.is-current)", 520],
  ["flows.html?screen=profile", null, "Tab icon, inactive (scrolled)", ".tab-bar__item:not(.is-current)", 300],
  ["flows.html?screen=discovery", null, "Prompt question on card", ".profile-section--prompt .profile-section__title", -1],
  ["flows.html?screen=profile", null, "Primary button text", ".fl-ready-card .btn--primary, .fl-ready-card button", 0],
  ["flows.html?screen=match", { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }, "Shared-interest chip", ".match__shared-chip", 0],
  ["", null, "Welcome primary button text", ".btn--primary", 0],
];

const lum = ([r, g, b]) => {
  const c = [r, g, b].map((v) => ((v /= 255) <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
};
const ratio = (a, b) => {
  const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p);
  return Math.round(((x + 0.05) / (y + 0.05)) * 100) / 100;
};

const server = await createServer({ root: ROOT, configFile: resolve(ROOT, "vite.config.js"), server: { port: 0, host: "127.0.0.1", fs: { allow: [ROOT, HERE, "/home/user/numaya/node_modules"] } }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();
try {
  for (const [url, state, label, selector, scroll] of TARGETS) {
    const ctx = await browser.newContext({ viewport: { width: 393, height: 852 }, deviceScaleFactor: 1, reducedMotion: "reduce", isMobile: true, hasTouch: true });
    await ctx.addInitScript(
      ([key, value]) => {
        try {
          if (value) localStorage.setItem(key, value);
          else localStorage.removeItem(key);
        } catch {}
      },
      [STORAGE_KEY, state ? JSON.stringify({ version: 1, state: session(state) }) : null],
    );
    const p = await ctx.newPage();
    await p.goto(base + url);
    await p.evaluate(() => document.fonts.ready);
    await p.waitForTimeout(800);
    if (scroll > 0) {
      await p.evaluate((dy) => (document.querySelector(".fl-screen__body") ?? document.scrollingElement).scrollBy(0, dy), scroll);
      await p.waitForTimeout(300);
    }
    const el = p.locator(selector).first();
    if (scroll === -1 && (await el.count())) {
      await el.evaluate((e) => e.scrollIntoView({ block: "center" }));
      await p.waitForTimeout(300);
    }
    if (!(await el.count())) {
      appendFileSync(OUT, JSON.stringify({ variant: id, label, absent: true }) + "\n");
      console.log(`${id} · ${label}: absent`);
      await ctx.close();
      continue;
    }
    const fg = await el.evaluate((e) => {
      const icon = e.querySelector("svg, .tab-bar__icon, [class*=icon]");
      const c = getComputedStyle(icon ?? e).color.match(/[\d.]+/g).map(Number);
      return c.slice(0, 3);
    });
    const box = await el.boundingBox();
    // Hide the foreground (text and icons), keep the element's own surface.
    await el.evaluate((e) => {
      e.style.setProperty("color", "transparent", "important");
      for (const n of e.querySelectorAll("*")) {
        n.style.setProperty("color", "transparent", "important");
        if (n.tagName === "svg" || n.closest("svg")) n.style.setProperty("visibility", "hidden", "important");
      }
      for (const n of e.querySelectorAll(".badge, [class*=badge]")) n.style.setProperty("visibility", "hidden", "important");
    });
    await p.waitForTimeout(100);
    // Inner area only: skip the outer 20% where rims, borders and rounded corners live.
    const clip = { x: box.x + box.width * 0.2, y: box.y + box.height * 0.2, width: box.width * 0.6, height: box.height * 0.6 };
    const png = await p.screenshot({ clip });
    const pixels = await p.evaluate(async (b64) => {
      const img = new Image();
      img.src = `data:image/png;base64,${b64}`;
      await img.decode();
      const c = new OffscreenCanvas(img.width, img.height);
      const g = c.getContext("2d");
      g.drawImage(img, 0, 0);
      const d = g.getImageData(0, 0, img.width, img.height).data;
      const out = [];
      for (let i = 0; i < d.length; i += 4) out.push([d[i], d[i + 1], d[i + 2]]);
      return out;
    }, png.toString("base64"));
    const scored = pixels.map((px) => [ratio(fg, px), px]).sort((a, b) => a[0] - b[0]);
    const worst = scored[Math.floor(scored.length * 0.02)];
    const median = scored[Math.floor(scored.length / 2)];
    const row = { variant: id, label, fg: `rgb(${fg.join(" ")})`, median: median[0], medianBg: `rgb(${median[1].join(" ")})`, worst2pct: worst[0], worstBg: `rgb(${worst[1].join(" ")})` };
    appendFileSync(OUT, JSON.stringify(row) + "\n");
    console.log(`${id} · ${label}: median ${row.median}:1, worst-2% ${row.worst2pct}:1 (fg ${row.fg})`);
    await ctx.close();
  }
} finally {
  await browser.close();
  await server.close();
}
