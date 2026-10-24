#!/usr/bin/env node
/**
 * Variant D (expressive colour) captures and four-way comparisons for the same five screens.
 *
 *   node scripts/expressive-color.mjs capture [slug]   render D from this checkout
 *   node scripts/expressive-color.mjs compare          build 2 × 2 comparison panels + index.html
 *
 * Same fixtures, viewports, fonts check, reduced motion and 2× DPR as
 * scripts/combined-visual-craft.mjs, so D lines up with the verified A, B and C captures, which are
 * read in place from artifacts/combined-visual-craft/ (never rewritten here).
 */
import { existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { createServer } from "vite";

const HERE = resolve(import.meta.dirname, "..");
const OUT = resolve(HERE, "artifacts/numaya-expressive-color");
const PRIOR = resolve(HERE, "artifacts/combined-visual-craft");
const STATES = ["A_original", "B_apple_design", "C_apple_plus_visual_craft", "D_expressive_color"];
const LABELS = { A_original: "A: Original", B_apple_design: "B: Apple", C_apple_plus_visual_craft: "C: Apple + Visual Craft", D_expressive_color: "D: Expressive Colour" };
const dirOf = (s) => (s === "D_expressive_color" ? resolve(OUT, s) : resolve(PRIOR, s));
const VIEWPORTS = [
  { width: 393, height: 852 },
  { width: 375, height: 667 },
  { width: 1440, height: 900 },
];
const SHOTS = [
  { slug: "onboarding", url: "", desktop: true },
  { slug: "discovery", url: "flows.html?screen=discovery" },
  { slug: "discovery-details", url: "flows.html?screen=discovery", scrollBy: 520 },
  { slug: "match", url: "flows.html?screen=match", state: { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" } },
  { slug: "profile", url: "flows.html?screen=profile" },
  { slug: "profile-details", url: "flows.html?screen=profile", scrollBy: 560 },
  { slug: "interests", url: "flows.html?screen=interests", state: { profile: { interests: ["Natural wine", "Jazz"] } } },
  { slug: "interests-max", url: "flows.html?screen=interests", state: { profile: { interests: ["Natural wine", "Jazz", "Cooking", "Climbing", "Poetry"] } } },
];
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const [mode, ...rest] = process.argv.slice(2);

if (mode === "capture") {
  const state = "D_expressive_color";
  const rootIdx = rest.indexOf("--root");
  const ROOT = rootIdx >= 0 ? resolve(rest[rootIdx + 1]) : HERE;
  const only = rest.filter((a, i) => a !== "--root" && i !== rootIdx + 1)[0];
  const { initialState, STORAGE_KEY } = await import(pathToFileURL(resolve(ROOT, "src/flows/store.js")).href);
  const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });
  const dir = dirOf(state);
  mkdirSync(dir, { recursive: true });
  const server = await createServer({ root: ROOT, configFile: resolve(ROOT, "vite.config.js"), server: { port: 0, host: "127.0.0.1", fs: { allow: [ROOT, HERE] } }, logLevel: "error" });
  await server.listen();
  const base = server.resolvedUrls.local[0];
  const browser = await chromium.launch();
  const problems = [];
  try {
    for (const shot of SHOTS) {
      if (only && shot.slug !== only) continue;
      for (const vp of VIEWPORTS) {
        const mobile = vp.width < 600;
        if (!mobile && !shot.desktop) continue;
        const ctx = await browser.newContext({ viewport: vp, deviceScaleFactor: 2, reducedMotion: "reduce", ...(mobile ? { isMobile: true, hasTouch: true } : {}) });
        const seed = shot.state ? JSON.stringify({ version: 1, state: session(shot.state) }) : null;
        await ctx.addInitScript(
          ([key, value]) => {
            let s = 0.42;
            Math.random = () => (s = (s * 9301 + 49297) % 233280 / 233280);
            try {
              if (value) localStorage.setItem(key, value);
              else localStorage.removeItem(key);
            } catch {}
          },
          [STORAGE_KEY, seed],
        );
        const p = await ctx.newPage();
        const tag = `${state} ${shot.slug} ${vp.width}x${vp.height}`;
        p.on("pageerror", (e) => problems.push(`${tag}: ${e.message}`));
        p.on("console", (m) => m.type() === "error" && problems.push(`${tag}: ${m.text()}`));
        await p.goto(base + shot.url);
        await p.evaluate(() => document.fonts.ready);
        const fonts = await p.evaluate(() => [...document.fonts].filter((f) => f.status === "loaded").map((f) => f.family));
        if (!fonts.some((f) => /Fraunces/.test(f)) || !fonts.some((f) => /Inter/.test(f))) problems.push(`${tag}: Fraunces/Inter not loaded (${fonts.join(", ")})`);
        await wait(1200);
        if (shot.scrollBy) {
          await p.evaluate((dy) => (document.querySelector(".fl-screen__body") ?? document.scrollingElement).scrollBy(0, dy), shot.scrollBy);
          await wait(400);
        }
        const name = `${shot.slug}-${vp.width}x${vp.height}.png`;
        await p.screenshot({ path: resolve(dir, name) });
        const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
        if (overflow > 0) problems.push(`${tag}: ${overflow}px horizontal overflow`);
        console.log(`${state}/${name}`);
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
} else if (mode === "compare") {
  const cmp = resolve(OUT, "comparisons");
  mkdirSync(cmp, { recursive: true });
  const names = readdirSync(dirOf("D_expressive_color")).filter((n) => n.endsWith(".png")).sort();
  const browser = await chromium.launch();
  const made = [];
  for (const name of names) {
    if (!STATES.every((s) => existsSync(resolve(dirOf(s), name)))) continue;
    const desktop = name.includes("1440x");
    const w = desktop ? 640 : 393;
    // 2 × 2 panels: each screen stays large enough to read type and small details on GitHub.
    const html = `<!doctype html><meta charset="utf-8"><style>
      body{margin:0;padding:24px;background:#eceff3;font:15px/1.3 Inter,system-ui,sans-serif;color:#14171f}
      h1{margin:0 0 16px;font-size:18px}.grid{display:grid;grid-template-columns:repeat(2,${w}px);gap:24px 20px}
      figure{margin:0}img{display:block;width:100%;border-radius:10px;box-shadow:0 1px 3px rgb(20 23 31/.14)}
      figcaption{margin-top:8px;font-weight:700}
    </style><h1>${name.replace(".png", "")}</h1><div class="grid">${STATES.map(
      (s) => `<figure><img src="${pathToFileURL(resolve(dirOf(s), name)).href}"><figcaption>${LABELS[s]}</figcaption></figure>`,
    ).join("")}</div>`;
    const tmp = resolve(cmp, `.${name}.html`);
    writeFileSync(tmp, html);
    const ctx = await browser.newContext({ viewport: { width: 48 + w * 2 + 20, height: 600 }, deviceScaleFactor: desktop ? 1 : 2 });
    const p = await ctx.newPage();
    await p.goto(pathToFileURL(tmp).href);
    await p.evaluate(() => Promise.all([...document.images].map((i) => i.decode().catch(() => {}))));
    const broken = await p.evaluate(() => [...document.images].filter((i) => !i.naturalWidth).length);
    if (broken) throw new Error(`${name}: ${broken} image(s) failed to load`);
    await p.screenshot({ path: resolve(cmp, name), fullPage: true });
    await ctx.close();
    rmSync(tmp);
    made.push(name);
    console.log(`comparisons/${name}`);
  }
  await browser.close();
  const rel = (s, n) => relative(OUT, resolve(dirOf(s), n));
  writeFileSync(
    resolve(OUT, "index.html"),
    `<!doctype html><meta charset="utf-8"><title>Numaya expressive colour gallery</title><style>body{margin:0 auto;max-width:1000px;padding:24px;font:15px/1.4 system-ui,sans-serif;background:#f6f6f8;color:#14171f}img{max-width:100%;border-radius:8px}section{margin:0 0 40px}h2{font-size:16px}</style>
<h1>Numaya · A Original | B Apple | C Apple + Visual Craft | D Expressive Colour</h1><p>Report: <a href="README.md">README.md</a>.</p>
${made.map((n) => `<section><h2>${n.replace(".png", "")}</h2><a href="comparisons/${n}"><img src="comparisons/${n}" alt="${n}"></a><p>${STATES.map((s) => `<a href="${rel(s, n)}">${LABELS[s]}</a>`).join(" · ")}</p></section>`).join("\n")}\n`,
  );
} else {
  throw new Error("usage: expressive-color.mjs capture [slug] | compare");
}
