// Measures white-text contrast on the Discover card (name, job line, cue) beside each line.
// Usage: node scripts/combined-card-contrast.mjs [checkout-root]
import { chromium } from "playwright";
import { createServer } from "vite";
const ROOT = process.argv[2] ?? process.cwd();
const server = await createServer({ root: ROOT, configFile: ROOT + "/vite.config.js", server: { port: 0, host: "127.0.0.1", fs: { allow: [ROOT, "/home/user/numaya"] } }, logLevel: "error" });
await server.listen();
const b = await chromium.launch();
for (const vp of [{ width: 393, height: 852 }, { width: 375, height: 667 }]) {
  const ctx = await b.newContext({ viewport: vp, deviceScaleFactor: 1, reducedMotion: "reduce" });
  const p = await ctx.newPage();
  await p.goto(server.resolvedUrls.local[0] + "flows.html?screen=discovery");
  await p.evaluate(() => document.fonts.ready); await p.waitForTimeout(1000);
  const lines = await p.evaluate(() => [".profile-card__name", ".profile-card__detail", ".profile-card__cue"].map((s) => { const e = document.querySelector(s); if (!e) return null; const r = e.getBoundingClientRect(); return { s, x: r.left, y: r.top, w: r.width, h: r.height }; }).filter(Boolean));
  const shot = await p.screenshot();
  const { default: zlib } = await import("node:zlib");
  // decode via sharp-less approach: use page to sample pixels from its own screenshot
  const res = await p.evaluate(async ({ data, lines }) => {
    const img = new Image(); img.src = "data:image/png;base64," + data; await img.decode();
    const c = document.createElement("canvas"); c.width = img.width; c.height = img.height; const g = c.getContext("2d"); g.drawImage(img, 0, 0);
    const L = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
    return lines.map(({ s, x, y, w, h }) => {
      let worst = 99;
      // Background strip just past the line's end and just above its top (no glyphs there).
      for (let yy = Math.ceil(y); yy < y + h; yy += 1) for (let xx = Math.ceil(x + w + 3); xx < x + w + 9; xx += 1) {
        const [r, gg, bb] = g.getImageData(xx, yy, 1, 1).data;
        const lum = 0.2126 * L(r) + 0.7152 * L(gg) + 0.0722 * L(bb);
        worst = Math.min(worst, 1.05 / (lum + 0.05));
      }
      return `${s} ≥ ${worst.toFixed(2)}:1`;
    });
  }, { data: shot.toString("base64"), lines });
  console.log(`${vp.width}x${vp.height}`, res.join(" | "));
  await ctx.close();
}
await b.close(); await server.close();
