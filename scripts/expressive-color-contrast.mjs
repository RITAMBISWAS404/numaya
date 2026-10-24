#!/usr/bin/env node
/**
 * Variant D contrast audit on the rendered five screens: text and glyphs against the backgrounds
 * they actually sit on (computed solid fills; for gradients, the lightest stop the text can meet).
 *
 *   node scripts/expressive-color-contrast.mjs
 */
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../src/flows/store.js";

const ROOT = new URL("..", import.meta.url).pathname;
const session = (patch = {}) => ({ ...initialState, ...patch, prefs: { ...initialState.prefs, ...patch.prefs }, profile: { ...initialState.profile, ...patch.profile } });
const PAGES = [
  ["Welcome", "", null, [["Create an account (white on purple, lightest stop)", ".welcome .btn--primary", "gradTop"], ["I have an account (deep purple on white)", ".welcome .btn--quiet", "page"], ["Legal link", ".legal a", "page"]]],
  ["Discover", "flows.html?screen=discovery", null, [["Verified pill", ".profile-card__pill--verified", "self"], ["SuperSwipe glyph", ".profile-card__actions .action-bar__btn--super", "self"], ["Active tab label", ".tab-bar__item.is-current", "self"], ["You both like pill (coral)", ".shared-interests__pill", "self"]]],
  ["Match", "flows.html?screen=match", { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" }, [["Shared pill (coral)", ".match__shared .chip", "self"], ["You both like label", ".match__shared-label", "page"], ["Copy", ".match__body", "page"]]],
  ["Profile", "flows.html?screen=profile", null, [["Score badge", ".fl-me__pct", "self"], ["Apricot interest chip", ".fl-me__interests .chip--tone-apricot", "self"], ["Periwinkle interest chip", ".fl-me__interests .chip--tone-periwinkle", "self"], ["Edit profile (brand button)", ".fl-me__actions .btn--brand", "self"], ["Readiness caption on lavender", ".fl-ready-card .fl-caption", "card"], ["Write a bio (white on purple, lightest stop)", ".fl-ready-card .btn--primary", "gradTop"]]],
  ["Interests", "flows.html?screen=interests", { profile: { interests: ["Natural wine", "Jazz"] } }, [["Selected chip", ".chip.is-selected", "self"], ["Apricot chip", ".chip--tone-apricot:not(.is-selected)", "self"], ["Apricot + glyph (non-text, 3:1)", ".chip--tone-apricot:not(.is-selected) .chip__affordance", "chip"], ["Periwinkle chip", ".chip--tone-periwinkle:not(.is-selected)", "self"], ["Periwinkle + glyph (non-text)", ".chip--tone-periwinkle:not(.is-selected) .chip__affordance", "chip"], ["Mint chip", ".chip--tone-mint:not(.is-selected)", "self"], ["Mint + glyph (non-text)", ".chip--tone-mint:not(.is-selected) .chip__affordance", "chip"], ["Set label", ".chip-group__set-label", "page"]]],
  ["Interests at max", "flows.html?screen=interests", { profile: { interests: ["Natural wine", "Jazz", "Cooking", "Climbing", "Poetry"] } }, [["Locked chip (disabled; exempt)", ".chip.is-unavailable", "self"], ["Next button glyph (white on purple)", ".fab", "gradTop"]]],
];
const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const browser = await chromium.launch();
const rows = [];
for (const [screen, url, state, checks] of PAGES) {
  const ctx = await browser.newContext({ viewport: { width: 393, height: 852 }, reducedMotion: "reduce" });
  await ctx.addInitScript(([k, v]) => { try { v ? localStorage.setItem(k, v) : localStorage.removeItem(k); } catch {} }, [STORAGE_KEY, state ? JSON.stringify({ version: 1, state: session(state) }) : null]);
  const p = await ctx.newPage();
  await p.goto(server.resolvedUrls.local[0] + url);
  await p.evaluate(() => document.fonts.ready);
  await p.waitForTimeout(800);
  for (const [label, sel, mode] of checks) {
    const r = await p.evaluate(([sel, mode]) => {
      const el = document.querySelector(sel);
      if (!el) return null;
      const parse = (c) => (c.match(/[\d.]+/g) || []).map(Number);
      const L = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
      const lum = ([r, g, b]) => 0.2126 * L(r) + 0.7152 * L(g) + 0.0722 * L(b);
      const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((m, n) => m - n); return (y + 0.05) / (x + 0.05); };
      const solidBg = (e) => { for (let n = e; n; n = n.parentElement) { const c = parse(getComputedStyle(n).backgroundColor); if (c.length >= 3 && (c[3] ?? 1) > 0.95) return c.slice(0, 3); } return [255, 255, 255]; };
      const fg = parse(getComputedStyle(el).color).slice(0, 3);
      let bg;
      if (mode === "gradTop") bg = parse(getComputedStyle(el).backgroundImage).slice(0, 3);
      else if (mode === "chip") bg = solidBg(el.closest(".chip"));
      else if (mode === "card") bg = solidBg(el.closest(".fl-ready-card"));
      else if (mode === "page") bg = solidBg(el.parentElement);
      else bg = solidBg(el);
      return { fg, bg, ratio: Math.round(ratio(fg, bg) * 100) / 100, size: parseFloat(getComputedStyle(el).fontSize), weight: getComputedStyle(el).fontWeight };
    }, [sel, mode]);
    rows.push({ screen, label, ...(r ?? { ratio: "not found" }) });
  }
  await ctx.close();
}
await browser.close();
await server.close();
const hex = (c) => (c ? `#${c.map((v) => Math.round(v).toString(16).padStart(2, "0")).join("")}` : "");
console.log("| Screen | Element | Foreground | Background | Ratio |\n| --- | --- | --- | --- | --- |");
for (const r of rows) console.log(`| ${r.screen} | ${r.label} | ${hex(r.fg)} | ${hex(r.bg)} | ${typeof r.ratio === "number" ? r.ratio.toFixed(2) + ":1" : r.ratio} |`);
