#!/usr/bin/env node
/**
 * Before / after sheets from two runs of the gallery (`npm run gallery`, `GALLERY_OUT=…`).
 *
 *   node scripts/gallery-compare.mjs <before-dir> <after-dir> <out-dir> <number…>
 *
 * Each number picks the capture with that gallery number (for example 030) from both runs' `screens/`
 * and writes `<out-dir>/<number>-<slug>.png`: the two captures side by side under their titles.
 */
import { mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";

const [before, after, out, ...numbers] = process.argv.slice(2);
if (!before || !after || !out || !numbers.length) throw new Error("usage: gallery-compare.mjs <before-dir> <after-dir> <out-dir> <number…>");
const OUT = resolve(out);
mkdirSync(OUT, { recursive: true });
const pick = (dir, n) => readdirSync(resolve(dir, "screens")).find((f) => f.startsWith(`${n}-`));
const title = (dir, n) => JSON.parse(readFileSync(resolve(dir, "manifest.json"), "utf8")).screens.find((m) => m.id === n)?.name;

const browser = await chromium.launch();
for (const n of numbers) {
  const a = pick(before, n);
  const b = pick(after, n);
  if (!a || !b) throw new Error(`capture ${n} is missing from one of the runs`);
  const label = title(after, n) ?? b.replace(/\.png$/, "");
  const img = (dir, f) => pathToFileURL(resolve(dir, "screens", f)).href;
  const html = `<!doctype html><meta charset="utf-8"><style>
    body{margin:0;padding:24px;background:#eceff3;font:600 15px/1.3 system-ui,sans-serif;color:#14171f}
    h1{margin:0 0 16px;font-size:18px}.row{display:flex;gap:24px}figure{margin:0;width:393px}
    img{display:block;width:100%;border-radius:12px;box-shadow:0 1px 3px rgb(20 23 31/.14)}figcaption{margin-top:8px;color:#555}
  </style><h1>${n} · ${label}</h1><div class="row">
    <figure><img src="${img(before, a)}"><figcaption>Before (Apple baseline)</figcaption></figure>
    <figure><img src="${img(after, b)}"><figcaption>After (Apple Design + Impeccable)</figcaption></figure></div>`;
  const tmp = resolve(OUT, `.${n}.html`);
  writeFileSync(tmp, html);
  const ctx = await browser.newContext({ viewport: { width: 393 * 2 + 24 * 3, height: 600 }, deviceScaleFactor: 1 });
  const p = await ctx.newPage();
  await p.goto(pathToFileURL(tmp).href);
  await p.evaluate(() => Promise.all([...document.images].map((i) => i.decode())));
  const name = `${n}-${b.replace(/^\d+-/, "").replace(/-\d+x\d+\.png$|-\d+w\.png$/, "")}.png`;
  await p.screenshot({ path: resolve(OUT, name), fullPage: true });
  await ctx.close();
  rmSync(tmp);
  console.log(name);
}
await browser.close();
