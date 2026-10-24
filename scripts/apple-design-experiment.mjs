#!/usr/bin/env node
/**
 * Before/after captures for the apple-design visual experiment (five screens).
 *
 *   node scripts/apple-design-experiment.mjs before|after
 *
 * Same tooling and seeding as `npm run gallery` (Vite dev server, Chromium, reduced motion, seeded
 * sessions) so both phases see identical content. Writes
 * artifacts/apple-design-experiment/<screen>-<phase>-<WxH>.png and only replaces files of the phase
 * it is asked for.
 */
import { mkdirSync } from "node:fs";
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../src/flows/store.js";

const phase = process.argv[2];
if (!["before", "after", "compare"].includes(phase)) throw new Error("usage: apple-design-experiment.mjs before|after [slug] | compare");
const only = process.argv[3];

const ROOT = resolve(import.meta.dirname, "..");
const OUT = resolve(ROOT, "artifacts/apple-design-experiment");

/* compare: one sheet per viewport, each row a screen with its before and after side by side. */
if (phase === "compare") {
  const { existsSync, writeFileSync, rmSync } = await import("node:fs");
  const { pathToFileURL } = await import("node:url");
  const slugs = ["onboarding", "discovery", "discovery-details", "match", "profile", "profile-details", "interests", "interests-max"];
  const browser = await chromium.launch();
  for (const size of ["393x852", "375x667", "1440x900"]) {
    const rows = slugs.filter((s) => existsSync(resolve(OUT, `${s}-before-${size}.png`)) && existsSync(resolve(OUT, `${s}-after-${size}.png`)));
    const thumb = size === "1440x900" ? 640 : 300;
    const html = `<!doctype html><meta charset="utf-8"><style>
      body{margin:0;padding:32px;background:#eceff3;font:14px/1.35 system-ui,sans-serif;color:#14171f}
      h1{margin:0 0 24px;font-size:22px}.row{display:flex;gap:24px;align-items:flex-start;margin-bottom:32px}
      .row h2{width:150px;margin:0;font-size:15px}figure{margin:0;width:${thumb}px}
      img{display:block;width:100%;border-radius:12px;box-shadow:0 1px 3px rgb(20 23 31/.12)}figcaption{margin-top:6px;color:#555}
    </style><h1>apple-design experiment · before / after · ${size}</h1>${rows
      .map((s) => `<div class="row"><h2>${s}</h2>${["before", "after"].map((ph) => `<figure><img src="${pathToFileURL(resolve(OUT, `${s}-${ph}-${size}.png`)).href}"><figcaption>${ph}</figcaption></figure>`).join("")}</div>`)
      .join("")}`;
    const tmp = resolve(OUT, `.compare-${size}.html`);
    writeFileSync(tmp, html);
    const ctx = await browser.newContext({ viewport: { width: 200 + thumb * 2 + 112, height: 900 } });
    const p = await ctx.newPage();
    await p.goto(pathToFileURL(tmp).href);
    await p.evaluate(() => Promise.all([...document.images].map((i) => i.decode().catch(() => {}))));
    await p.screenshot({ path: resolve(OUT, `compare-${size}.png`), fullPage: true });
    await ctx.close();
    rmSync(tmp);
    console.log(`compare-${size}.png`);
  }
  await browser.close();
  process.exit(0);
}
const VIEWPORTS = [
  { width: 393, height: 852 },
  { width: 375, height: 667 },
  { width: 1440, height: 900 },
];
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });

const SHOTS = [
  { slug: "onboarding", url: "" },
  { slug: "discovery", url: "flows.html?screen=discovery" },
  { slug: "discovery-details", url: "flows.html?screen=discovery", mobileOnly: true, scrollToSelector: "#root .profile-card__media", scrollBy: 520 },
  { slug: "match", url: "flows.html?screen=match", state: session({ matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  { slug: "profile", url: "flows.html?screen=profile" },
  { slug: "profile-details", url: "flows.html?screen=profile", mobileOnly: true, scrollBy: 560 },
  { slug: "interests", url: "flows.html?screen=interests", state: session({ profile: { interests: ["Natural wine", "Jazz"] } }) },
  { slug: "interests-max", url: "flows.html?screen=interests", mobileOnly: true, state: session({ profile: { interests: ["Natural wine", "Jazz", "Cooking", "Climbing", "Poetry"] } }) },
];

mkdirSync(OUT, { recursive: true });
const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();
const problems = [];
try {
  for (const shot of SHOTS) {
    if (only && !shot.slug.startsWith(only)) continue;
    for (const vp of VIEWPORTS) {
      const mobile = vp.width < 600;
      if (shot.mobileOnly && !mobile) continue;
      const ctx = await browser.newContext({ viewport: vp, deviceScaleFactor: 2, reducedMotion: "reduce", ...(mobile ? { isMobile: true, hasTouch: true } : {}) });
      const seed = shot.state ? JSON.stringify({ version: 1, state: shot.state }) : null;
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
      const tag = `${shot.slug} ${vp.width}x${vp.height}`;
      p.on("pageerror", (e) => problems.push(`${tag}: ${e.message}`));
      p.on("console", (m) => m.type() === "error" && problems.push(`${tag}: ${m.text()}`));
      await p.goto(base + shot.url);
      await p.evaluate(() => document.fonts.ready);
      await wait(1200);
      if (shot.scrollBy) {
        await p.evaluate((dy) => {
          const b = document.querySelector(".fl-screen__body") ?? document.scrollingElement;
          b.scrollBy(0, dy);
        }, shot.scrollBy);
        await wait(400);
      }
      const name = `${shot.slug}-${phase}-${vp.width}x${vp.height}.png`;
      await p.screenshot({ path: resolve(OUT, name) });
      const overflow = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
      if (overflow > 0) problems.push(`${tag}: ${overflow}px horizontal overflow`);
      const broken = await p.evaluate(() => [...document.images].filter((i) => i.complete && !i.naturalWidth).map((i) => i.src));
      if (broken.length) problems.push(`${tag}: broken images ${broken.join(", ")}`);
      console.log(name);
      await ctx.close();
    }
  }
} finally {
  await browser.close();
  await server.close();
}
if (problems.length) {
  console.log("\nProblems:\n" + problems.join("\n"));
  process.exitCode = 1;
}
