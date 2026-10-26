#!/usr/bin/env node
/**
 * The opt-in Liquid Glass experiment (`?theme=liquid-glass`), V12:
 * artifacts/version-12-liquid-glass-preview/, whose design-decisions.md this file checks. It is V11
 * (`?theme=tiimo`) plus one material on selected layers, so this suite checks only what the glass
 * adds and what it must leave alone: scoping (its own flag; tiimo and the default untouched), the
 * material tokens, where glass is allowed (tab bar, sheets, photo controls) and where it is not
 * (content, cards, pills, inputs, buttons, the Discover photo text, the match), the tab bar over
 * scrolling content with its scroll edge, rendered label contrast over the darkest content, sheets
 * that stay legible, the reduced-transparency and increased-contrast fallbacks, 375 px and the
 * console. Run by `npm run test:e2e`.
 *
 * Chromium is launched with SwiftShader: in some headless environments its default GPU path leaves
 * backdrop-filter blur unrendered over scrolling content, which would make the rendered checks
 * measure something no device shows.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity", "profile", "edit", "settings"];
const TAB_SCREENS = ["discovery", "likes", "chats", "activity", "profile"];
const OUTSIDE = ["insights", "activity-detail", "blocked", "premium", "help"];
const GLASS = '[".tab-bar", ".sheet__panel", ".photo-slot__remove"]';

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}
const lum = ([r, g, b]) => {
  const f = (v) => { v /= 255; return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
};
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };
const rgb = (c) => c.match(/[\d.]+/g).slice(0, 3).map(Number);

const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch({ args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader"] });

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
async function openSeeded(p, path, patch) {
  await open(p, path);
  await p.evaluate(([key, value]) => localStorage.setItem(key, value), [STORAGE_KEY, JSON.stringify({ version: 1, state: { ...initialState, ...patch } })]);
  await p.reload();
  await wait(700);
}
const MATCHED = { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" };
const glassOn = (p) => p.evaluate(() => !!document.querySelector(".theme-liquid-glass"));
const tiimoOn = (p) => p.evaluate(() => !!document.querySelector(".theme-tiimo"));
// The rendered colour under a point (from a screenshot of the viewport).
async function pixels(p, points) {
  const shot = (await p.screenshot()).toString("base64");
  return p.evaluate(async ([b64, pts]) => {
    const img = new Image();
    img.src = `data:image/png;base64,${b64}`;
    await img.decode();
    const c = Object.assign(document.createElement("canvas"), { width: img.width, height: img.height });
    const x = c.getContext("2d");
    x.drawImage(img, 0, 0);
    return pts.map(([a, y]) => [...x.getImageData(Math.round(a), Math.round(y), 1, 1).data].slice(0, 3));
  }, [shot, points]);
}

try {
  const p = await phone();

  // 1. Scoping: its own flag. With ?theme=liquid-glass the selected screens render `.theme-tiimo
  // .theme-liquid-glass` (V11 is the base); ?theme=tiimo and no flag never carry the glass class;
  // screens outside the experiment stay approved.
  const missing = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=liquid-glass`);
    if (!(await glassOn(p)) || !(await tiimoOn(p))) missing.push(s);
  }
  await open(p, "?theme=liquid-glass");
  if (!(await glassOn(p))) missing.push("welcome");
  check("scoping: ?theme=liquid-glass renders all 15 selected screens in .theme-tiimo .theme-liquid-glass", missing.length === 0, missing.join(", "));
  const leaked = [];
  for (const s of FLOW_SCREENS) {
    await open(p, `flows.html?screen=${s}&theme=tiimo`);
    if (await glassOn(p)) leaked.push(`tiimo:${s}`);
    await open(p, `flows.html?screen=${s}`);
    if ((await glassOn(p)) || (await tiimoOn(p))) leaked.push(`default:${s}`);
  }
  for (const s of OUTSIDE) {
    await open(p, `flows.html?screen=${s}&theme=liquid-glass`);
    if ((await glassOn(p)) || (await tiimoOn(p))) leaked.push(`outside:${s}`);
  }
  check("scoping: ?theme=tiimo (V11) and the default never carry the glass; screens outside the experiment stay approved", leaked.length === 0, leaked.join(", "));

  // 2. The material: one small token set, resolved on a themed screen.
  await open(p, "flows.html?screen=chats&theme=liquid-glass");
  const tokens = await p.evaluate(() => {
    const cs = getComputedStyle(document.querySelector(".theme-liquid-glass"));
    return Object.fromEntries(["--glass-fill", "--glass-fill-thick", "--glass-fill-dark", "--glass-filter", "--glass-edge", "--glass-highlight", "--glass-shadow", "--glass-edge-fade", "--lg-fill", "--lg-filter", "--lg-edge-fade"].map((k) => [k, cs.getPropertyValue(k).trim()]));
  });
  check("material: the glass tokens have their values (fill 88%, thick 90%, dark 50%, one blur(24px) saturate(1.2) backdrop, 20% scroll edge)",
    tokens["--glass-fill"] === "rgb(255 255 255 / 0.88)" && tokens["--glass-fill-thick"] === "rgb(255 255 255 / 0.9)" && tokens["--glass-fill-dark"] === "rgb(20 19 22 / 0.5)" && tokens["--glass-filter"] === "blur(24px) saturate(1.2)" && tokens["--glass-edge-fade"] === "0.2" && tokens["--lg-filter"] === "var(--glass-filter)" || tokens["--lg-filter"] === "blur(24px) saturate(1.2)",
    JSON.stringify(tokens));

  // 3. Glass only where it is allowed: on every themed screen, the match and an open sheet, the glass
  // adds a backdrop to the tab bar, sheets and photo controls and to nothing else. Cards, groups,
  // pills, tags, inputs, buttons, profile information and the match composition get none. (V11
  // already gives the small "Verified" and "New here" labels on a photo a backdrop; those are V11's
  // and must stay exactly as they are, so each screen is compared with ?theme=tiimo.)
  const stray = [];
  const glassSeen = new Set();
  const backdrops = async (path, theme) => {
    const t = path.replace("THEME", theme);
    if (t.startsWith("matched")) await openSeeded(p, `flows.html?screen=match&theme=${theme}`, MATCHED);
    else if (t.startsWith("filters")) { await open(p, `flows.html?screen=discovery&theme=${theme}`); await p.getByRole("button", { name: /^Filters/ }).click(); await wait(600); }
    else await open(p, t);
    return p.evaluate((allowed) => {
      const ok = JSON.parse(allowed); const out = []; const seen = [];
      for (const el of document.querySelectorAll("*")) {
        for (const pseudo of [null, "::before", "::after"]) {
          const bf = getComputedStyle(el, pseudo).backdropFilter;
          if (!bf || bf === "none") continue;
          const hit = ok.find((s) => el.matches(s));
          if (hit && !pseudo) seen.push(hit); else out.push(`${el.className.baseVal ?? el.className}${pseudo ?? ""}`);
        }
      }
      return { out, seen };
    }, GLASS);
  };
  for (const path of ["?theme=THEME", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=THEME`), "matched", "filters"]) {
    const g = await backdrops(path, "liquid-glass");
    const v11 = await backdrops(path, "tiimo");
    const extra = g.out.filter((x) => !v11.out.includes(x));
    if (extra.length || g.out.length !== v11.out.length) stray.push(`${path}: ${extra.slice(0, 3).join(", ") || "count differs"}`);
    g.seen.forEach((s) => glassSeen.add(s));
  }
  check("material: the glass adds a backdrop only to the tab bar, sheets and photo controls; no card, pill, input, button, profile text or match element gets one", stray.length === 0 && glassSeen.size === 3, `${[...glassSeen].join(", ")}${stray.length ? " | stray: " + stray.join(" | ") : ""}`);

  // 4. Tab bar: the V11 full-width bar (icon over label, red dots) in regular glass, overlaying the
  // bottom of the screen; the body scrolls beneath it, its last row still clears the bar, and the
  // strip under the bar fades (scroll edge). At 393 and 375 px.
  const barOf = async (q, screen) => {
    await open(q, `flows.html?screen=${screen}&theme=liquid-glass`);
    await q.mouse.move(0, 0);
    await wait(300);
    return q.evaluate(() => {
      const bar = document.querySelector(".tab-bar"); const scr = bar.closest(".fl-screen"); const body = scr.querySelector(".fl-screen__body");
      const cs = getComputedStyle(bar); const b = bar.getBoundingClientRect(); const s = scr.getBoundingClientRect(); const bd = body.getBoundingClientRect();
      body.scrollTop = body.scrollHeight;
      const last = body.lastElementChild.getBoundingClientRect();
      const items = [...bar.querySelectorAll(".tab-bar__item")];
      const cur = bar.querySelector(".is-current");
      const idle = items.find((i) => i !== cur);
      return {
        pos: cs.position, left: b.left - s.left, right: s.right - b.right, bottom: s.bottom - b.bottom, h: b.height, safe: parseFloat(cs.getPropertyValue("--safe-bottom")),
        bg: cs.backgroundColor, bf: cs.backdropFilter, edge: cs.boxShadow, radius: cs.borderTopLeftRadius,
        under: Math.round(bd.bottom) >= Math.round(b.bottom) - 0.5, clears: Math.round(last.bottom) <= Math.round(b.top), mask: getComputedStyle(body).maskImage || getComputedStyle(body).webkitMaskImage,
        icons: items.map((i) => Math.round(i.querySelector(".tab-bar__icon svg").getBoundingClientRect().width)), labels: items.map((i) => i.querySelector(".tab-bar__label").textContent),
        targets: items.every((i) => { const r = i.getBoundingClientRect(); return r.width >= 44 && r.height >= 44; }),
        cur: getComputedStyle(cur).color, curIcon: getComputedStyle(cur.querySelector(".tab-bar__icon")).color, curBg: getComputedStyle(cur).backgroundColor, idle: getComputedStyle(idle).color, idleIcon: getComputedStyle(idle.querySelector(".tab-bar__icon")).color,
        dots: [...bar.querySelectorAll(".count-badge")].map((d) => getComputedStyle(d, "::after").backgroundColor + " " + d.getBoundingClientRect().width),
      };
    });
  };
  const bars = [];
  for (const s of TAB_SCREENS) bars.push({ s, ...(await barOf(p, s)) });
  const q375 = await phone(375, 667);
  bars.push({ s: "chats@375", ...(await barOf(q375, "chats")) });
  check("tab bar: full width and square at the bottom edge, 56px plus the home-indicator inset, overlaying the screen (393 and 375 px)", bars.every((b) => b.pos === "absolute" && b.left === 0 && b.right === 0 && Math.abs(b.bottom) <= 0.5 && b.h === 56 + b.safe && b.radius === "0px"), bars.map((b) => `${b.s}: ${b.pos} ${b.h}px`).join(", "));
  check("tab bar: regular glass (white 88%, the one backdrop), with a hairline edge and a 1px lit line, no shadow", bars.every((b) => b.bg === "rgba(255, 255, 255, 0.88)" && b.bf === "blur(24px) saturate(1.2)" && /rgba\(20, 19, 22, 0\.1\) 0px 1px 0px 0px inset/.test(b.edge) && /rgba\(255, 255, 255, 0\.7\) 0px 2px 0px 0px inset/.test(b.edge) && b.edge.split(/,(?![^(]*\))/).every((l) => /inset/.test(l))), `${bars[0].bg} ${bars[0].bf} | ${bars[0].edge}`);
  check("tab bar: content scrolls beneath it, its last row still ends above the bar, and the strip under the bar fades (scroll edge)", bars.every((b) => b.under && b.clears && /linear-gradient/.test(b.mask)), bars.map((b) => `${b.s}: under ${b.under}, clears ${b.clears}`).join(", "));
  check("tab bar: V11's structure is kept: 24px icons over the five labels, touch targets of 44px or more, red 8px dots", bars.every((b) => b.icons.every((i) => i === 24) && b.labels.join() === "Home,Activity,Likes,Messages,Profile" && b.targets && b.dots.length >= 2 && b.dots.every((d) => d === "rgb(185, 58, 54) 8")), JSON.stringify(bars[0].dots));
  check("tab bar: the active tab is brand purple with no background; inactive tabs take the stronger grey #6B6771 on glass", bars.every((b) => b.cur === "rgb(114, 98, 199)" && b.curIcon === "rgb(114, 98, 199)" && b.curBg === "rgba(0, 0, 0, 0)" && b.idle === "rgb(107, 103, 113)" && b.idleIcon === "rgb(107, 103, 113)"), `${bars[0].cur} / ${bars[0].idle}`);

  // Rendered contrast of every label over the white page and over solid black scrolled under the bar
  // (the darkest thing a photo can put there).
  const contrastOver = async (black) => {
    await open(p, "flows.html?screen=chats&theme=liquid-glass");
    await p.mouse.move(0, 0);
    if (black) await p.evaluate(() => {
      const bd = document.querySelector(".fl-screen__body");
      const d = Object.assign(document.createElement("div"), { style: "height:900px;background:#000" });
      bd.append(d, Object.assign(document.createElement("div"), { style: "height:400px" }));
      bd.scrollTop += d.getBoundingClientRect().bottom - document.querySelector(".tab-bar").getBoundingClientRect().bottom - 20;
    });
    await wait(500);
    const items = await p.evaluate(() => [...document.querySelectorAll(".tab-bar__item")].map((i) => { const l = i.querySelector(".tab-bar__label").getBoundingClientRect(); return { name: i.querySelector(".tab-bar__label").textContent, fg: getComputedStyle(i.querySelector(".tab-bar__label")).color, x: i.getBoundingClientRect().left + 3, y: l.top + l.height / 2 }; }));
    const px = await pixels(p, items.map((i) => [i.x, i.y]));
    return items.map((it, k) => ({ name: it.name, bg: px[k], r: ratio(rgb(it.fg), px[k]) }));
  };
  const onWhite = await contrastOver(false);
  const onBlack = await contrastOver(true);
  check("tab bar: every label keeps 4.5:1 over the white page and over solid black beneath the glass (rendered)", [...onWhite, ...onBlack].every((c) => c.r >= 4.5), onBlack.map((c) => `${c.name} ${c.r.toFixed(2)} on ${c.bg.join(",")}`).join(", "));
  check("tab bar: over dark content the glass still reads as glass (darker than white), not as an opaque white bar", onBlack.every((c) => Math.max(...c.bg) < 252) && onWhite.every((c) => Math.min(...c.bg) >= 254), `white ${onWhite[0].bg.join(",")}, black ${onBlack[1].bg.join(",")}`);

  // 5. Sheets: thick glass over the dimmed page; the groups inside stay opaque white; the sheet's
  // own labels keep AA (rendered); the primary action stays solid purple; it opens and closes.
  await open(p, "flows.html?screen=discovery&theme=liquid-glass");
  await p.getByRole("button", { name: /^Filters/ }).click();
  await wait(700);
  const sheet = await p.evaluate(() => {
    const panel = document.querySelector(".sheet__panel"); const cs = getComputedStyle(panel);
    const groups = [...panel.querySelectorAll(".list-group__items, .slider-card, .fl-filter-card, [class*='card']")].filter((g) => g.getBoundingClientRect().height > 40).map((g) => getComputedStyle(g).backgroundColor);
    const texts = [...panel.querySelectorAll(".list-group__title, h2, .sheet__title, .fl-sheet-label, p, legend")].filter((t) => t.getBoundingClientRect().width && !t.closest(".list-group__items")).map((t) => { const r = t.getBoundingClientRect(); return { t: t.textContent.trim().slice(0, 18), fg: getComputedStyle(t).color, x: r.left - 4, y: r.top + r.height / 2 }; });
    const primary = panel.querySelector(".btn--primary");
    const scrim = document.querySelector(".sheet__scrim");
    return { bg: cs.backgroundColor, bf: cs.backdropFilter, shadow: cs.boxShadow, groups, texts, primary: primary && getComputedStyle(primary).backgroundColor, above: !!scrim && !!(scrim.compareDocumentPosition(panel) & Node.DOCUMENT_POSITION_FOLLOWING) && getComputedStyle(panel).position !== "static", radius: cs.borderTopLeftRadius };
  });
  const sheetPx = await pixels(p, sheet.texts.map((t) => [t.x, t.y]));
  const sheetContrast = sheet.texts.map((t, k) => ({ t: t.t, r: ratio(rgb(t.fg), sheetPx[k]) }));
  check("sheets: thick glass (white 90%, the same backdrop) above the scrim, with a soft upward shadow; same corners as V11", sheet.bg === "rgba(255, 255, 255, 0.9)" && sheet.bf === "blur(24px) saturate(1.2)" && /rgba\(20, 19, 22, 0\.16\) 0px -8px 28px -12px/.test(sheet.shadow) && sheet.above && sheet.radius === "20px", `${sheet.bg} ${sheet.bf} radius ${sheet.radius}`);
  check("sheets: the groups inside stay opaque white; the primary action stays solid brand purple", sheet.groups.length >= 2 && sheet.groups.every((g) => g === "rgb(255, 255, 255)") && sheet.primary === "rgb(114, 98, 199)", `${sheet.groups.join(" ")} | ${sheet.primary}`);
  check("sheets: the sheet's own headings and labels keep 4.5:1 on the glass (rendered)", sheetContrast.length >= 2 && sheetContrast.every((c) => c.r >= 4.5), sheetContrast.map((c) => `${c.t} ${c.r.toFixed(2)}`).join(", "));
  await p.getByRole("button", { name: /close/i }).first().click();
  await wait(700);
  check("sheets: the filter sheet still closes", (await p.locator(".sheet__panel").count()) === 0);

  // 6. Photo controls: the remove button in dark glass (ink 50%), same 28px size; its white icon keeps
  // 3:1 over a pure white photo (computed: the fill over white).
  await open(p, "flows.html?screen=photos&theme=liquid-glass");
  const remove = await p.evaluate(() => [...document.querySelectorAll(".photo-slot__remove")].map((b) => { const cs = getComputedStyle(b); const r = b.getBoundingClientRect(); return { bg: cs.backgroundColor, bf: cs.backdropFilter, w: r.width, h: r.height, fg: cs.color }; }));
  const overWhite = [255 * 0.5 + 20 * 0.5, 255 * 0.5 + 19 * 0.5, 255 * 0.5 + 22 * 0.5];
  check("photo controls: the remove button is dark glass (ink 50%), 28px, with a white icon that keeps 3:1 even over a white photo", remove.length >= 3 && remove.every((r) => r.bg === "rgba(20, 19, 22, 0.5)" && r.bf === "blur(24px) saturate(1.2)" && r.w === 28 && r.h === 28) && ratio(rgb(remove[0].fg), overWhite) >= 3, `${remove[0]?.bg}, ${ratio(rgb(remove[0].fg), overWhite).toFixed(2)}:1 over white`);

  // 7. What glass leaves alone: the Discover photo fade on a real photo and the placeholder band
  // are V11's; the match portrait keeps its scallop and has no glass, halo or added border.
  const fadeOf = async (theme) => {
    await open(p, `flows.html?screen=discovery&theme=${theme}`);
    return p.evaluate(() => {
      const media = document.querySelector(".profile-card__media");
      const band = getComputedStyle(media.querySelector(".profile-card__overlay")).backgroundColor;
      media.prepend(Object.assign(document.createElement("img"), { className: "profile-card__img", alt: "", src: "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" }));
      const f = getComputedStyle(media, "::before");
      return { band, fade: f.backgroundImage, h: f.height, overlay: getComputedStyle(media.querySelector(".profile-card__overlay")).backgroundImage };
    });
  };
  const fadeGlass = await fadeOf("liquid-glass");
  const fadeV11 = await fadeOf("tiimo");
  check("Discover: the photo fade and the placeholder's solid band are exactly V11's (no glass panel behind the name)", fadeGlass.fade === fadeV11.fade && fadeGlass.h === fadeV11.h && fadeGlass.band === fadeV11.band && /gradient/.test(fadeGlass.fade) && fadeGlass.overlay === "none", `${fadeGlass.band} | ${fadeGlass.fade.slice(0, 50)}`);
  const matchOf = async (theme) => {
    await openSeeded(p, `flows.html?screen=match&theme=${theme}`, MATCHED);
    return p.evaluate(() => {
      const ph = document.querySelector(".match .organic-portrait__photo"); const fr = document.querySelector(".match .organic-portrait");
      return { mask: getComputedStyle(ph).maskImage || getComputedStyle(ph).webkitMaskImage, w: Math.round(fr.getBoundingClientRect().width), halo: getComputedStyle(fr).boxShadow, glass: [...document.querySelectorAll(".match *")].filter((e) => getComputedStyle(e).backdropFilter !== "none").length };
    });
  };
  const matchGlass = await matchOf("liquid-glass");
  const matchV11 = await matchOf("tiimo");
  check("Match: an intentional exception: the scalloped portrait, its size and its (absent) halo are V11's, with no glass anywhere in the composition", matchGlass.mask === matchV11.mask && matchGlass.w === matchV11.w && matchGlass.halo === matchV11.halo && matchGlass.glass === 0, `${matchGlass.w}px, glass ${matchGlass.glass}`);

  // 8. V11 is untouched: with ?theme=tiimo the tab bar is in flow and opaque, and sheets are opaque.
  await open(p, "flows.html?screen=chats&theme=tiimo");
  const v11 = await p.evaluate(() => { const b = getComputedStyle(document.querySelector(".tab-bar")); return { pos: b.position, bg: b.backgroundColor, bf: b.backdropFilter, mask: getComputedStyle(document.querySelector(".fl-screen__body")).maskImage }; });
  check("V11 (?theme=tiimo) unchanged: the tab bar stays in flow, opaque white, with no backdrop and no scroll-edge mask", v11.pos !== "absolute" && v11.bg === "rgb(255, 255, 255)" && v11.bf === "none" && (v11.mask === "none" || !v11.mask), JSON.stringify(v11));

  // 9. Fallbacks: with reduced transparency or increased contrast the whole material swaps to opaque
  // surfaces with no backdrop and no scroll-edge fade; the stylesheet also falls back when
  // backdrop-filter is unsupported.
  const fallback = async (feature) => {
    const q = await phone();
    const cdp = await q.context().newCDPSession(q);
    await cdp.send("Emulation.setEmulatedMedia", { features: [{ name: feature, value: feature === "prefers-contrast" ? "more" : "reduce" }] });
    const matches = await q.evaluate((f) => matchMedia(`(${f}: ${f === "prefers-contrast" ? "more" : "reduce"})`).matches, feature);
    await open(q, "flows.html?screen=chats&theme=liquid-glass");
    const r = await q.evaluate(() => { const b = getComputedStyle(document.querySelector(".tab-bar")); return { bg: b.backgroundColor, bf: b.backdropFilter, fade: getComputedStyle(document.querySelector(".theme-liquid-glass")).getPropertyValue("--lg-edge-fade").trim() }; });
    await q.getByRole("button", { name: "Home" }).click();
    await wait(400);
    await q.getByRole("button", { name: /^Filters/ }).click();
    await wait(600);
    const s = await q.evaluate(() => { const c = getComputedStyle(document.querySelector(".sheet__panel")); return { bg: c.backgroundColor, bf: c.backdropFilter }; });
    await q.context().close();
    return { matches, ...r, sheet: s };
  };
  for (const f of ["prefers-reduced-transparency", "prefers-contrast"]) {
    const r = await fallback(f);
    check(`fallback: with ${f} the tab bar and sheets are opaque white with no backdrop and no scroll-edge fade`, r.matches && r.bg === "rgb(255, 255, 255)" && r.bf === "none" && r.fade === "1" && r.sheet.bg === "rgb(255, 255, 255)" && r.sheet.bf === "none", JSON.stringify(r));
  }
  const supportsRule = await p.evaluate(() => {
    for (const sheet of document.styleSheets) {
      let rules; try { rules = sheet.cssRules; } catch { continue; }
      for (const r of rules) if (r.constructor.name === "CSSSupportsRule" && /not.*backdrop-filter/.test(r.conditionText) && [...r.cssRules].some((x) => /theme-liquid-glass/.test(x.selectorText) && /--glass-fallback/.test(x.style.getPropertyValue("--lg-fill")) && x.style.getPropertyValue("--lg-filter").trim() === "none")) return true;
    }
    return false;
  });
  check("fallback: without backdrop-filter support (@supports not), the material swaps to the opaque fallback", supportsRule);

  // 10. Interactions: tabs keep ?theme=liquid-glass and stay keyboard-reachable; every themed screen
  // fits 375 px; no console errors.
  await open(p, "flows.html?screen=chats&theme=liquid-glass");
  await p.getByRole("button", { name: /^Likes/ }).click();
  await wait(400);
  const url = new URL(p.url());
  check("interaction: a tab opens its screen and keeps ?theme=liquid-glass", url.searchParams.get("screen") === "likes" && url.searchParams.get("theme") === "liquid-glass" && (await glassOn(p)), url.search);
  await p.locator(".tab-bar__item").nth(1).focus();
  await p.keyboard.press("Shift+Tab");
  const focused = await p.evaluate(() => document.activeElement?.classList.contains("tab-bar__item") && getComputedStyle(document.activeElement).outlineStyle !== "none");
  check("interaction: tab bar items take keyboard focus with a visible ring", focused);
  const wide = [];
  for (const path of ["?theme=liquid-glass", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=liquid-glass`)]) {
    await open(q375, path);
    const over = await q375.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    if (over > 0) wide.push(`${path} +${over}px`);
  }
  check("responsive 375: no horizontal overflow on the 15 glass screens", wide.length === 0, wide.join(", "));
  check("console: no errors", p.errors.length === 0 && q375.errors.length === 0, [...p.errors, ...q375.errors].slice(0, 3).join(" | "));
  await q375.context().close();
} catch (err) {
  check("liquid glass checks completed without an exception", false, err.message.split("\n")[0]);
} finally {
  await browser.close();
  await server.close();
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} liquid glass checks passed.`);
process.exit(failed.length ? 1 : 0);
