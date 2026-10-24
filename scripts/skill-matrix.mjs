#!/usr/bin/env node
/**
 * Skill-combination matrix: capture any checkout of the app under identical conditions, and build
 * the comparison sheets.
 *
 *   node scripts/skill-matrix.mjs capture <ID> --root <checkout> [screen]
 *   node scripts/skill-matrix.mjs capture <ID> --root <checkout> discover-scrolled   (glass evidence)
 *   node scripts/skill-matrix.mjs sheets
 *
 * Capture: Vite dev server on the given checkout, Chromium via Playwright, 2× DPR, reduced motion,
 * Fraunces and Inter awaited and checked, the same seeded sessions as `npm run gallery`. Writes
 * artifacts/skill-combination-matrix/screens/<screen>-<ID>-<label>-<WxH>.png.
 */
import { existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { createServer } from "vite";

export const VARIANTS = {
  A: { label: "original", title: "A · Original" },
  B: { label: "apple", title: "B · Apple" },
  C: { label: "impeccable", title: "C · Apple + Impeccable" },
  D: { label: "uipro", title: "D · Apple + UI/UX Pro Max" },
  E: { label: "glass", title: "E · Apple + Liquid Glass" },
  F: { label: "impeccable-uipro", title: "F · Impeccable + UI/UX Pro Max" },
  G: { label: "uipro-glass", title: "G · UI/UX Pro Max + Liquid Glass" },
  H: { label: "full-stack", title: "H · Full stack" },
  // H's intermediate states, captured under the same conditions but kept out of the eight-column sheets.
  H1: { label: "full-stack-checkpoint1-impeccable", title: "H · checkpoint 1 (Impeccable)", checkpoint: true },
  H2: { label: "full-stack-checkpoint2-uipro", title: "H · checkpoint 2 (+ UI/UX Pro Max)", checkpoint: true },
};
const SCREENS = [
  { slug: "welcome", title: "Welcome", url: "", desktop: true },
  { slug: "discover", title: "Discover", url: "flows.html?screen=discovery" },
  { slug: "match", title: "Match", url: "flows.html?screen=match", state: { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" } },
  { slug: "profile", title: "Profile", url: "flows.html?screen=profile" },
  { slug: "interests", title: "Interests", url: "flows.html?screen=interests", state: { profile: { interests: ["Natural wine", "Jazz"] } } },
  // Evidence only (glass legibility): Discover scrolled so the prompt text sits under the tab bar. 393 only, not in the sheets.
  { slug: "discover-scrolled", title: "Discover, scrolled", url: "flows.html?screen=discovery", scrollBy: 520, extra: true },
];
const MOBILE = [
  { width: 393, height: 852 },
  { width: 375, height: 667 },
];
const DESKTOP = { width: 1440, height: 900 };
const HERE = resolve(import.meta.dirname, "..");
const OUT = resolve(HERE, "artifacts/skill-combination-matrix");
const SHOTS = resolve(OUT, "screens");
const CHECKPOINTS = resolve(OUT, "checkpoints");
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const file = (slug, id, size) => `${slug}-${id}-${VARIANTS[id].label}-${size}.png`;
const [mode, ...rest] = process.argv.slice(2);

if (mode === "capture") {
  const id = rest[0];
  if (!VARIANTS[id]) throw new Error(`variant must be one of ${Object.keys(VARIANTS).join(" ")}`);
  const rootIdx = rest.indexOf("--root");
  if (rootIdx < 0) throw new Error("--root <checkout> is required");
  const ROOT = resolve(rest[rootIdx + 1]);
  const only = rest.find((a, i) => i > 0 && i !== rootIdx && i !== rootIdx + 1);
  const { initialState, STORAGE_KEY } = await import(pathToFileURL(resolve(ROOT, "src/flows/store.js")).href);
  const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });
  const DIR = VARIANTS[id].checkpoint ? CHECKPOINTS : SHOTS;
  mkdirSync(DIR, { recursive: true });
  const server = await createServer({ root: ROOT, configFile: resolve(ROOT, "vite.config.js"), server: { port: 0, host: "127.0.0.1", fs: { allow: [ROOT, HERE, "/home/user/numaya/node_modules"] } }, logLevel: "error" });
  await server.listen();
  const base = server.resolvedUrls.local[0];
  const browser = await chromium.launch();
  const problems = [];
  try {
    for (const shot of SCREENS) {
      if (only ? shot.slug !== only : shot.extra) continue;
      for (const vp of shot.desktop ? [...MOBILE, DESKTOP] : shot.extra ? MOBILE.slice(0, 1) : MOBILE) {
        const mobile = vp.width < 600;
        const ctx = await browser.newContext({ viewport: vp, deviceScaleFactor: 2, reducedMotion: "reduce", ...(mobile ? { isMobile: true, hasTouch: true } : {}) });
        await ctx.addInitScript(
          ([key, value]) => {
            let s = 0.42;
            Math.random = () => (s = (s * 9301 + 49297) % 233280 / 233280);
            try {
              if (value) localStorage.setItem(key, value);
              else localStorage.removeItem(key);
            } catch {}
          },
          [STORAGE_KEY, shot.state ? JSON.stringify({ version: 1, state: session(shot.state) }) : null],
        );
        const p = await ctx.newPage();
        const tag = `${id} ${shot.slug} ${vp.width}x${vp.height}`;
        p.on("pageerror", (e) => problems.push(`${tag}: ${e.message}`));
        p.on("console", (m) => m.type() === "error" && problems.push(`${tag}: ${m.text()}`));
        await p.goto(base + shot.url);
        await p.evaluate(() => document.fonts.ready);
        const fonts = await p.evaluate(() => [...document.fonts].filter((f) => f.status === "loaded").map((f) => f.family).join(","));
        if (!/Fraunces/.test(fonts) || !/Inter/.test(fonts)) problems.push(`${tag}: fonts not loaded (${fonts})`);
        await wait(1200);
        if (shot.scrollBy) {
          await p.evaluate((dy) => (document.querySelector(".fl-screen__body") ?? document.scrollingElement).scrollBy(0, dy), shot.scrollBy);
          await wait(400);
        }
        const name = file(shot.slug, id, `${vp.width}x${vp.height}`);
        await p.screenshot({ path: resolve(DIR, name) });
        const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
        if (overflow > 0) problems.push(`${tag}: ${overflow}px horizontal overflow`);
        const broken = await p.evaluate(() => [...document.images].filter((i) => i.complete && !i.naturalWidth).length);
        if (broken) problems.push(`${tag}: ${broken} broken image(s)`);
        console.log(`${VARIANTS[id].checkpoint ? "checkpoints" : "screens"}/${name}`);
        await ctx.close();
      }
    }
  } finally {
    await browser.close();
    await server.close();
  }
  if (problems.length) {
    console.log(`\nProblems:\n${problems.join("\n")}`);
    process.exitCode = 1;
  }
} else if (mode === "sheets") {
  const SHEETS = resolve(OUT, "sheets");
  mkdirSync(SHEETS, { recursive: true });
  const browser = await chromium.launch();
  const render = async (name, html, width, dpr = 1) => {
    const tmp = resolve(SHEETS, `.${name}.html`);
    writeFileSync(tmp, html);
    const ctx = await browser.newContext({ viewport: { width, height: 600 }, deviceScaleFactor: dpr });
    const p = await ctx.newPage();
    await p.goto(pathToFileURL(tmp).href);
    await p.evaluate(() => Promise.all([...document.images].map((i) => i.decode().catch(() => {}))));
    const missing = await p.evaluate(() => [...document.images].filter((i) => !i.naturalWidth).map((i) => i.getAttribute("src")));
    if (missing.length) throw new Error(`${name}: missing ${missing.join(", ")}`);
    await p.screenshot({ path: resolve(SHEETS, name), fullPage: true });
    await ctx.close();
    rmSync(tmp);
    console.log(`sheets/${name}`);
  };
  const css = (w) => `body{margin:0;padding:24px;background:#eceff3;font:600 14px/1.3 system-ui,sans-serif;color:#14171f}
    h1{margin:0 0 16px;font-size:20px}.row{display:flex;gap:16px}figure{margin:0;width:${w}px}
    img{display:block;width:100%;border-radius:8px;box-shadow:0 1px 3px rgb(20 23 31/.14)}figcaption{margin-top:6px}
    table{border-spacing:10px 8px}th{text-align:left;font-size:13px}td img{width:${w}px}`;
  const src = (slug, id, size) => pathToFileURL(resolve(SHOTS, file(slug, id, size))).href;
  const ids = Object.keys(VARIANTS).filter((id) => !VARIANTS[id].checkpoint);
  const have = (slug, id, size) => existsSync(resolve(SHOTS, file(slug, id, size)));
  // 1. Overview: five screens (rows) × eight variants (columns), 393 × 852, small thumbnails.
  const thumb = 150;
  const rows = SCREENS.filter((s) => !s.extra).map((s) => `<tr><th>${s.title}</th>${ids.map((id) => `<td>${have(s.slug, id, "393x852") ? `<img src="${src(s.slug, id, "393x852")}">` : "missing"}</td>`).join("")}</tr>`).join("");
  await render("overview-393x852.png", `<!doctype html><meta charset="utf-8"><style>${css(thumb)}</style><h1>Numaya skill-combination matrix · 393 × 852</h1><table><tr><th></th>${ids.map((id) => `<th>${VARIANTS[id].title}</th>`).join("")}</tr>${rows}</table>`, 120 + (thumb + 10) * 8 + 60, 2);
  // 2. Per-screen sheets: A–D and E–H, at both mobile sizes; desktop Welcome A–H.
  for (const s of SCREENS.filter((x) => !x.extra)) {
    for (const size of ["393x852", "375x667"]) {
      for (const [group, gids] of [["A-D", ["A", "B", "C", "D"]], ["E-H", ["E", "F", "G", "H"]]]) {
        const list = gids.filter((id) => have(s.slug, id, size));
        if (!list.length) continue;
        const w = 320;
        await render(`${s.slug}-${group}-${size}.png`, `<!doctype html><meta charset="utf-8"><style>${css(w)}</style><h1>${s.title} · ${size.replace("x", " × ")} · ${group}</h1><div class="row">${list.map((id) => `<figure><img src="${src(s.slug, id, size)}"><figcaption>${VARIANTS[id].title}</figcaption></figure>`).join("")}</div>`, 48 + (w + 16) * list.length, 2);
      }
    }
  }
  const desk = ids.filter((id) => have("welcome", id, "1440x900"));
  if (desk.length) {
    const w = 480;
    await render("welcome-desktop-1440x900.png", `<!doctype html><meta charset="utf-8"><style>${css(w)}.row{flex-wrap:wrap;width:${(w + 16) * 4}px}</style><h1>Welcome · 1440 × 900</h1><div class="row">${desk.map((id) => `<figure><img src="${src("welcome", id, "1440x900")}"><figcaption>${VARIANTS[id].title}</figcaption></figure>`).join("")}</div>`, 48 + (w + 16) * 4, 1);
  }
  await browser.close();
} else {
  throw new Error("usage: skill-matrix.mjs capture <ID> --root <checkout> [screen] | sheets");
}
