#!/usr/bin/env node
/**
 * Illustration catalog: annotated screenshots of every registered illustration slot, from the
 * running app, plus a self-contained HTML catalog.
 *
 *   npm run illustrations
 *
 * Reads docs/illustrations/illustration-manifest.json, checks it against the code registry
 * (src/design-system/illustrations/registry.js), drives each placement in Chromium at 393 × 852
 * (2×), outlines the slot and labels it with its future file name, saves the full screen and a crop
 * to docs/illustrations/screenshots/, and writes docs/illustrations/index.html (offline, relative
 * paths, no external resources).
 */
import { mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "..");
const DIR = resolve(ROOT, "docs/illustrations");
const SHOTS = resolve(DIR, "screenshots");
const manifest = JSON.parse(readFileSync(resolve(DIR, "illustration-manifest.json"), "utf8"));
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });
const ALL_LIKES = { maya: "liked", kemi: "passed", noor: "passed", ines: "passed", tomas: "passed", rafa: "liked" };

/* How to reach each placement: url, seeded session, interaction, and the slot to annotate. */
const CAPTURES = {
  match: { url: "flows.html?screen=match", state: session({ matches: ["rafa", "priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }) },
  welcome: { url: "" },
  "verified-sheet": {
    url: "",
    setup: async (p) => {
      await p.getByRole("button", { name: "Create an account" }).click();
      await wait(900);
      await p.locator("#phone-number").fill("4155550132");
      await p.getByRole("button", { name: "Send code" }).click();
      await wait(3200);
      // Type the code from the simulated text message, as the gallery does.
      const code = (await p.locator("body").innerText()).match(/code is (\d{6})/)?.[1];
      await p.locator(".code__input").fill(code ?? "");
      await wait(3400);
    },
  },
  intro: { url: "flows.html?screen=intro" },
  "chats-empty": { url: "flows.html?screen=chats", state: session({ matches: [], threads: {} }) },
  "likes-empty": { url: "flows.html?screen=likes", state: session({ likesHandled: ALL_LIKES, matches: ["rafa", "priya", "jo", "maya"] }) },
  "match-empty": { url: "flows.html?screen=match" },
  "my-activities-empty": { url: "flows.html?screen=my-activities", state: session({ joins: {} }) },
  "explore-empty": { url: "flows.html?screen=activity", state: session({ hiddenActivities: ["a-run", "a-jazz", "a-climb", "a-market", "a-board", "a-film"] }) },
  "home-caught-up": { url: "flows.html?screen=discovery", state: session({ seen: ["maya", "sam", "noor", "ines", "lea", "tomas"] }) },
  unmatched: { url: "flows.html?screen=chat", state: session({ ended: { priya: "unmatched" } }) },
  blocked: { url: "flows.html?screen=chat", state: session({ ended: { priya: "blocked" } }) },
  "report-saved": {
    url: "flows.html?screen=activity-detail",
    setup: async (p) => {
      await p.getByRole("button", { name: "Activity options" }).click();
      await wait(500);
      await p.getByRole("button", { name: "Report activity" }).click();
      await wait(500);
      await p.getByRole("dialog").getByText("Spam or selling something").click();
      await p.getByRole("dialog").getByRole("button", { name: "Send report" }).click();
      await wait(700);
    },
  },
  "home-paused": { url: "flows.html?screen=discovery", state: session({ prefs: { snooze: true } }) },
  "activity-published": {
    url: "flows.html?screen=activity-form",
    setup: async (p) => {
      await p.getByLabel("Activity name").fill("Sunday sea swim");
      await p.getByRole("button", { name: /Choose a category/ }).click();
      await wait(500);
      await p.getByRole("dialog").getByText("Sport", { exact: true }).click();
      await wait(400);
      await p.getByLabel("Place or venue").fill("London Fields Lido café");
      await p.getByLabel("Date").fill("2026-11-01");
      await p.getByLabel("Start time").fill("08:00");
      await p.getByRole("button", { name: "Publish" }).click();
      await wait(1000);
    },
  },
  maintenance: { url: "flows.html?screen=maintenance" },
  basics: { url: "flows.html?screen=basics" },
  interests: { url: "flows.html?screen=interests" },
};

// The manifest and the code registry must name the same slots and files.
const registry = readFileSync(resolve(ROOT, "src/design-system/illustrations/registry.js"), "utf8");
for (const e of manifest.illustrations) {
  if (!registry.includes(`"${e.id}": { file: "${e.file}"`)) throw new Error(`Manifest entry ${e.id} (${e.file}) is not in the registry`);
  for (const pl of e.placements) if (!CAPTURES[pl.capture]) throw new Error(`No capture defined for ${pl.capture}`);
}

rmSync(SHOTS, { recursive: true, force: true });
mkdirSync(SHOTS, { recursive: true });
const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();
const problems = [];
let n = 0;

for (const e of manifest.illustrations) {
  n += 1;
  for (const [i, pl] of e.placements.entries()) {
    const c = CAPTURES[pl.capture];
    const ctx = await browser.newContext({ viewport: { width: 393, height: 852 }, deviceScaleFactor: 2, reducedMotion: "reduce", isMobile: true, hasTouch: true });
    await ctx.addInitScript(() => { Math.random = (() => { let s = 7; return () => ((s = (s * 16807) % 2147483647) / 2147483647); })(); });
    await ctx.addInitScript(([key, seed]) => {
      try { if (seed && !sessionStorage.getItem("seeded")) { localStorage.setItem(key, JSON.stringify({ version: 1, state: seed })); sessionStorage.setItem("seeded", "1"); } } catch {}
    }, [STORAGE_KEY, c.state ?? null]);
    const p = await ctx.newPage();
    p.on("pageerror", (err) => problems.push(`${e.id}: ${err.message}`));
    await p.goto(base + c.url);
    await p.evaluate(() => document.fonts.ready);
    await wait(1100);
    if (c.setup) await c.setup(p);
    const slot = p.locator(`[data-illustration="${e.id}"]`).last();
    if ((await slot.count()) === 0) { problems.push(`${e.id}: slot not found on ${pl.capture}`); await ctx.close(); continue; }
    await slot.evaluate((el) => el.scrollIntoView({ block: "center" }));
    await wait(300);
    const box = await slot.evaluate((el, label) => {
      const r = el.getBoundingClientRect();
      const w = Math.max(r.width, 48), h = Math.max(r.height, 48);
      const x = r.left + r.width / 2 - w / 2, y = r.top + r.height / 2 - h / 2;
      const o = document.createElement("div");
      o.setAttribute("data-catalog-annotation", "");
      o.style.cssText = `position:fixed;left:${x - 6}px;top:${y - 6}px;width:${w + 12}px;height:${h + 12}px;border:2px dashed #7262C7;border-radius:12px;background:rgba(114,98,199,0.06);z-index:2147483647;pointer-events:none`;
      const tag = document.createElement("span");
      tag.textContent = label;
      // The tag sits on the outline's top edge, inside it, so it never covers the screen's own text.
      tag.style.cssText = "position:absolute;left:8px;top:-9px;padding:0 8px;border-radius:999px;background:#7262C7;color:#fff;font:600 11px/16px Inter,system-ui,sans-serif;white-space:nowrap";
      if (x + 230 > innerWidth) { tag.style.left = "auto"; tag.style.right = "8px"; }
      o.append(tag);
      document.body.append(o);
      return { x: x - 6, y: y - 6, w: w + 12, h: h + 12 };
    }, `${n} · ${e.file}`);
    const name = `${String(n).padStart(2, "0")}-${e.id}${e.placements.length > 1 ? `-${i + 1}` : ""}`;
    await p.screenshot({ path: resolve(SHOTS, `${name}.png`) });
    const pad = 56;
    const clip = { x: Math.max(0, box.x - pad), y: Math.max(0, box.y - pad - 24), width: 0, height: 0 };
    clip.width = Math.min(393 - clip.x, box.w + pad * 2);
    clip.height = Math.min(852 - clip.y, box.h + pad * 2 + 24);
    await p.screenshot({ path: resolve(SHOTS, `${name}-crop.png`), clip });
    pl.screenshot = `screenshots/${name}.png`;
    pl.crop = `screenshots/${name}-crop.png`;
    console.log(`${name}`);
    await ctx.close();
  }
}
await browser.close();
await server.close();

writeFileSync(resolve(DIR, "illustration-manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);

/* Offline HTML catalog ------------------------------------------------- */
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const count = (p) => manifest.illustrations.filter((e) => e.priority === p).length;
const placements = manifest.illustrations.reduce((k, e) => k + e.placements.length, 0);
const row = (k, v) => `<tr><th scope="row">${k}</th><td>${v}</td></tr>`;
const card = (e, i) => `
<article class="entry" id="${e.id}">
  <header class="entry__head">
    <span class="num">${i + 1}</span>
    <div>
      <h2><code>${esc(e.file)}</code></h2>
      <p class="meta"><span class="prio prio--${e.priority}">${e.priority} · ${esc(e.requirement)}</span> <span>ID <code>${e.id}</code></span> <span>Code <code>${esc(e.code)}</code></span></p>
    </div>
  </header>
  <div class="entry__body">
    <div class="shots">
      ${e.placements.map((pl) => `
      <figure>
        <a href="${pl.screenshot}"><img src="${pl.screenshot}" alt="${esc(pl.screen)} with the ${esc(e.file)} area outlined" width="393" height="852"></a>
        <figcaption><strong>${esc(pl.screen)}</strong><br><code>${esc(pl.route)}</code></figcaption>
      </figure>
      <figure class="crop">
        <img src="${pl.crop}" alt="Close-up of the ${esc(e.file)} area">
        <figcaption>${esc(pl.region)}<br>Rendered at ${pl.rendered[0]} × ${pl.rendered[1]} px</figcaption>
      </figure>`).join("")}
    </div>
    <table>
      ${row("Purpose", esc(e.purpose))}
      ${row("Art direction", esc(e.art))}
      ${row("Palette", esc(e.palette))}
      ${row("Aspect ratio", esc(e.ratio))}
      ${row("Export size", `@1x ${e.export["1x"].join(" × ")} · @2x ${e.export["2x"].join(" × ")} · <strong>@3x ${e.export["3x"].join(" × ")} (deliver this)</strong>`)}
      ${row("Safe margins", esc(e.safeMargin))}
      ${row("Background", esc(e.transparency))}
      ${row("Shadows", esc(e.shadows))}
      ${row("Text", esc(e.text))}
      ${row("Animation", esc(e.animation))}
      ${row("Status today", esc(e.status))}
    </table>
  </div>
</article>`;
const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Numaya illustration catalog</title>
<style>
  :root { --ink:#141316; --muted:#66656b; --line:#e9e8eb; --soft:#f7f7f8; --brand:#7262c7; --tint:#f3f0fd; }
  * { box-sizing: border-box; }
  body { margin: 0; background: #fff; color: var(--ink); font: 15px/1.5 Inter, system-ui, -apple-system, "Segoe UI", sans-serif; }
  main { max-width: 1200px; margin: 0 auto; padding: 40px 24px 80px; }
  h1 { margin: 0 0 8px; font: 600 34px/1.15 Georgia, "Times New Roman", serif; }
  h2 { margin: 0; font-size: 17px; }
  code { font: 13px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace; background: var(--soft); padding: 1px 5px; border-radius: 6px; }
  .lede { max-width: 760px; color: var(--muted); }
  .summary { display: flex; flex-wrap: wrap; gap: 12px; margin: 24px 0; padding: 0; list-style: none; }
  .summary li { padding: 12px 16px; border-radius: 14px; background: var(--soft); }
  .summary strong { display: block; font-size: 22px; }
  nav ol { columns: 2 280px; padding-left: 20px; }
  .entry { margin-top: 40px; padding: 24px; border: 1px solid var(--line); border-radius: 20px; }
  .entry__head { display: flex; gap: 14px; align-items: flex-start; margin-bottom: 16px; }
  .num { flex: none; display: grid; place-items: center; width: 32px; height: 32px; border-radius: 50%; background: var(--brand); color: #fff; font-weight: 600; }
  .meta { display: flex; flex-wrap: wrap; gap: 8px 16px; margin: 6px 0 0; color: var(--muted); font-size: 13px; }
  .prio { padding: 1px 8px; border-radius: 999px; font-weight: 600; background: var(--soft); }
  .prio--P0 { background: var(--brand); color: #fff; }
  .prio--P1 { background: var(--tint); color: #4f4296; }
  .entry__body { display: grid; grid-template-columns: minmax(0, 1.1fr) minmax(0, 1fr); gap: 24px; }
  .shots { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-content: start; }
  figure { margin: 0; }
  figure img { display: block; width: 100%; height: auto; border: 1px solid var(--line); border-radius: 14px; }
  figcaption { margin-top: 6px; color: var(--muted); font-size: 12.5px; }
  table { width: 100%; border-collapse: collapse; font-size: 14px; align-self: start; }
  th, td { padding: 8px 0; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; }
  th { width: 128px; padding-right: 12px; color: var(--muted); font-weight: 600; }
  .note { padding: 16px 20px; border-radius: 16px; background: var(--tint); }
  @media (max-width: 820px) { .entry__body { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<main>
  <h1>Numaya illustration catalog</h1>
  <p class="lede">Every place a Numaya illustration belongs, shown on the real screens with the area outlined. Make each PNG with the exact file name, put it in <code>${manifest.assetFolder}</code>, and it replaces the slot's fallback on the next build. Details: <a href="README.md">README</a> · <a href="asset-guidelines.md">asset guidelines</a> · <a href="illustration-manifest.json">manifest</a>.</p>
  <ul class="summary">
    <li><strong>${manifest.illustrations.length}</strong>PNG assets</li>
    <li><strong>${placements}</strong>placements</li>
    <li><strong>${count("P0")}</strong>P0 essential</li>
    <li><strong>${count("P1")}</strong>P1 high value</li>
    <li><strong>${count("P2")}</strong>P2 optional</li>
  </ul>
  <p class="note"><strong>Not illustrations</strong> (not listed here): ${manifest.notIllustrations.map(esc).join("; ")}.</p>
  <nav aria-label="Assets"><ol>${manifest.illustrations.map((e) => `<li><a href="#${e.id}"><code>${e.file}</code></a> · ${e.priority}</li>`).join("")}</ol></nav>
  ${manifest.illustrations.map(card).join("")}
</main>
</body>
</html>
`;
writeFileSync(resolve(DIR, "index.html"), html);
if (problems.length) {
  console.error(`\n${problems.length} problem(s):\n${problems.join("\n")}`);
  process.exit(1);
}
console.log(`\nCatalog: ${manifest.illustrations.length} assets, ${placements} placements → docs/illustrations/index.html`);
