#!/usr/bin/env node
/**
 * The opt-in Tiimo-inspired experiment (`?theme=tiimo`, artifacts/tiimo-inspired-experiment/, refined
 * in artifacts/tiimo-white-surface-refinement/, artifacts/tiimo-inspired-v3/, artifacts/tiimo-inspired-v4/ and
 * artifacts/version-5-final-screenshot-preview/).
 * Its own contract, kept apart from the approved design's checks in smoke.mjs and product.mjs:
 * scoping (only the 12 selected screens, only with the flag), the visual rules that carry meaning
 * (white canvas, gradients only as the black fade on profile photos, compact rounded controls,
 * neutral headings, a match without decoration, neutral fields, solid purple for your messages,
 * category tones with readable inks, decorative emoji), and that the screens still work,
 * fit 393 and 375 px wide and log no errors. Run by `npm run test:e2e`.
 */
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";
import { initialState, STORAGE_KEY } from "../../src/flows/store.js";

const ROOT = resolve(import.meta.dirname, "../..");
const FLOW_SCREENS = ["basics", "photos", "interests", "discovery", "like-profile", "likes", "match", "chats", "chat", "prompt", "activity"];
const OUTSIDE = ["profile", "edit", "settings", "insights", "activity-detail"];

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(name, ok, detail = "") {
  results.push({ name, ok, detail });
  console.log(`${ok ? "✓" : "✗"} ${name}${detail ? ` (${detail})` : ""}`);
}
// Channels 0–1 from a computed colour: rgb(…) in 0–255, or color(srgb …) in 0–1 (what color-mix gives).
const channels = (c) => {
  const n = c.match(/[\d.]+/g).map(Number);
  return c.startsWith("color(") ? n.slice(0, 3) : n.slice(0, 3).map((v) => v / 255);
};
const lum = (colour) => {
  const [r, g, b] = channels(colour).map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
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
// Opens a flow screen with a seeded session (as the gallery does), e.g. the match right after liking Maya.
async function openSeeded(p, path, patch) {
  await open(p, path);
  await p.evaluate(([key, value]) => localStorage.setItem(key, value), [STORAGE_KEY, JSON.stringify({ version: 1, state: { ...initialState, ...patch } })]);
  await p.reload();
  await wait(700);
}
const MATCHED = { matches: ["priya", "jo", "maya"], seen: ["maya"], lastMatch: "maya" };
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

  // 2. Visual contract on Interests: canvas, neutral set headings with a tinted emoji holder,
  // decorative emoji.
  await open(p, "flows.html?screen=interests&theme=tiimo");
  const look = await p.evaluate(() => {
    const cs = (el) => getComputedStyle(el);
    const screen = document.querySelector(".fl-screen");
    const labels = [...document.querySelectorAll(".chip-group__set-label[data-tone]")].map((el) => ({ tone: el.dataset.tone, fg: cs(el).color, bg: cs(el).backgroundColor, holder: getComputedStyle(el, "::after").backgroundColor }));
    const prompt = document.querySelector(".prompt__label");
    const chip = [...document.querySelectorAll(".chip")].find((c) => c.textContent.includes("Natural wine"));
    return {
      canvas: cs(screen).backgroundColor,
      labels,
      prompt: prompt && cs(prompt).color,
      chip: { pressed: chip.getAttribute("aria-pressed"), tone: chip.dataset.tone, bg: cs(chip).backgroundColor, ring: cs(chip).boxShadow, fg: cs(chip).color, emoji: getComputedStyle(chip, "::after").content },
    };
  });
  check("look: themed screens sit on a pure white canvas", look.canvas === "rgb(255, 255, 255)", look.canvas);
  // Neutral = no visible hue (the ink is a near-black with a 3-point cool cast).
  const neutral = (c) => { const [r, g, b] = c.match(/\d+/g).map(Number); return Math.max(r, g, b) - Math.min(r, g, b) <= 6; };
  check("look: interest sets keep their categories (peach, lilac, mint)", look.labels.map((l) => l.tone).join() === "peach,lilac,mint", look.labels.map((l) => l.tone).join());
  check("look: interest set headings are neutral ink, on no coloured fill", look.labels.every((l) => neutral(l.fg) && l.bg === "rgba(0, 0, 0, 0)"), look.labels.map((l) => `${l.fg} on ${l.bg}`).join(", "));
  check("look: each set's category colour sits in its tinted emoji holder", look.labels.every((l) => l.holder !== "rgba(0, 0, 0, 0)" && !neutral(l.holder)), look.labels.map((l) => l.holder).join(", "));
  const worstLabel = Math.min(...look.labels.map((l) => ratio(l.fg, "rgb(255, 255, 255)")));
  check("contrast: set headings on the white canvas are at least 4.5:1", worstLabel >= 4.5, worstLabel.toFixed(2));
  check("look: the prompt question is a neutral heading, not accent text", look.prompt && neutral(look.prompt), look.prompt);
  check("look: a selected interest is a light purple pill with a fine purple outline", look.chip.pressed === "true" && look.chip.bg === "rgb(233, 228, 251)" && /rgb\(114, 98, 199\) 0px 0px 0px 1px inset/.test(look.chip.ring), `${look.chip.bg} / ${look.chip.ring}`);
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

  // 4c. Gradients: the only one allowed is the black fade over a real profile photograph that carries
  // text (the ::before layer of a photo container that holds an <img>). Every other element
  // and ::before/::after, on every themed screen, computes no gradient; the sample profiles only have
  // grey placeholders, which take no gradient. Photographs are images, not gradients, so never match.
  const gradients = [];
  const overlays = [];
  for (const path of ["?theme=tiimo", ...FLOW_SCREENS.map((s) => `flows.html?screen=${s}&theme=tiimo`), "matched"]) {
    if (path === "matched") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, path);
    const found = await p.evaluate(() => {
      const hits = [];
      const allowed = [];
      for (const root of document.querySelectorAll(".theme-tiimo")) {
        for (const el of [root, ...root.querySelectorAll("*")]) {
          for (const pseudo of [null, "::before", "::after"]) {
            const cs = getComputedStyle(el, pseudo);
            if (!(/gradient/.test(cs.backgroundImage) || /gradient/.test(cs.borderImageSource) || /gradient/.test(cs.maskImage))) continue;
            const onPhoto = pseudo === "::before" && el.classList.contains("profile-card__media") && el.querySelector(":scope > .profile-card__img");
            if (onPhoto) allowed.push(cs.backgroundImage);
            else hits.push(`${el.tagName.toLowerCase()}.${[...el.classList].join(".")}${pseudo ?? ""}`);
          }
        }
      }
      return { hits: [...new Set(hits)], allowed };
    });
    if (found.hits.length) gradients.push(`${path}: ${found.hits.slice(0, 3).join(", ")}`);
    overlays.push(...found.allowed);
  }
  check("look: no gradient on the 12 themed screens and the match moment, placeholders included (elements and ::before/::after)", gradients.length === 0 && overlays.length === 0, [...gradients, ...overlays].join(" | "));

  // 4d. With a real photograph the card gets the fade. The repo has no photography, so a test image
  // is put into the card: pure white, the worst case for white text.
  const withPhoto = async (screen) => {
    await open(p, `flows.html?screen=${screen}&theme=tiimo`);
    return p.evaluate(() => {
      const media = document.querySelector(".profile-card__media");
      const c = Object.assign(document.createElement("canvas"), { width: 300, height: 400 });
      const x = c.getContext("2d");
      x.fillStyle = "#ffffff";
      x.fillRect(0, 0, 300, 400);
      media.querySelector(".profile-card__stand-in")?.remove();
      media.prepend(Object.assign(document.createElement("img"), { className: "profile-card__img", alt: "", src: c.toDataURL() }));
      const fade = getComputedStyle(media, "::before");
      const g = fade.backgroundImage;
      const stops = [...g.matchAll(/(rgba?\([^)]*\)|color\(srgb [^)]*\)) ([\d.]+)%/g)].map((m) => [Number(m[2]) / 100, Number(m[1].match(/[,/] ([\d.]+)\)$/)?.[1] ?? 1)]);
      const mediaBox = media.getBoundingClientRect();
      const h = parseFloat(fade.height);
      const box = { bottom: mediaBox.bottom, top: mediaBox.bottom - h, height: h };
      // Layering: the fade sits above the photo and below the text and the SuperSwipe.
      const z = (el) => Number(getComputedStyle(el).zIndex) || 0;
      const layered = Number(fade.zIndex) > z(media.querySelector(".profile-card__img")) && z(media.querySelector(".profile-card__overlay")) > Number(fade.zIndex) && (!media.querySelector(".profile-card__actions") || z(media.querySelector(".profile-card__actions")) > Number(fade.zIndex));
      // Opacity of the fade at a height: 0 at its bottom edge, 1 at its top edge.
      const alphaAt = (y) => {
        const t = (box.bottom - y) / box.height;
        for (let i = 1; i < stops.length; i++) if (t <= stops[i][0]) {
          const [t0, a0] = stops[i - 1]; const [t1, a1] = stops[i];
          return a0 + ((t - t0) / (t1 - t0)) * (a1 - a0);
        }
        return 0;
      };
      // Each text line at its lightest point: its top edge.
      const line = (sel) => alphaAt(document.querySelector(sel).getBoundingClientRect().top);
      return {
        gradient: g,
        name: line(".profile-card__name"),
        detail: document.querySelector(".profile-card__detail") ? line(".profile-card__detail") : null,
        clear: (box.top - mediaBox.top) / mediaBox.height, // share of the photo above the fade
        clipped: getComputedStyle(media).overflow === "hidden" && parseFloat(getComputedStyle(media).borderTopLeftRadius) > 0,
        layered,
        overlayBg: getComputedStyle(media.querySelector(".profile-card__overlay")).backgroundImage,
      };
    });
  };
  for (const screen of ["discovery", "like-profile"]) overlays.push({ screen, ...(await withPhoto(screen)) });

  // The rendered fade, read from pixels (Discover with the pure-white test image): down a column clear
  // of text and of the SuperSwipe, the photo stays pure white above the fade, then darkens smoothly
  // and steadily to the bottom, with no band edge (no jump of more than a few levels between rows).
  await withPhoto("discovery");
  const media = p.locator(".profile-card__media");
  const shot = (await media.screenshot()).toString("base64");
  const column = await p.evaluate(async (b64) => {
    const img = new Image();
    img.src = `data:image/png;base64,${b64}`;
    await img.decode();
    const c = Object.assign(document.createElement("canvas"), { width: img.width, height: img.height });
    const x = c.getContext("2d");
    x.drawImage(img, 0, 0);
    const media = document.querySelector(".profile-card__media").getBoundingClientRect();
    // The first text on the photo: the badges (or the name). The overlay box itself starts higher,
    // with empty padding, so it is not the reference.
    const text = (document.querySelector(".profile-card__pills") ?? document.querySelector(".profile-card__name")).getBoundingClientRect();
    const col = Math.round(img.width * 0.75); // right of the name block
    const end = Math.round(((text.top - media.top) / media.height) * img.height) - 4; // just above the text and SuperSwipe
    const v = [];
    for (let y = 0; y < end; y++) v.push(x.getImageData(col, y, 1, 1).data[0]);
    return { v, height: img.height };
  }, shot);
  const fadeTop = column.v.findIndex((v) => v < 254);
  const jumps = column.v.slice(1).map((v, i) => column.v[i] - v);
  const steady = jumps.every((d) => d >= -1);
  const maxJump = Math.max(...jumps);
  check("look: the rendered fade starts below the upper photo, darkens steadily and has no band edge", fadeTop > column.height * 0.38 && steady && maxJump <= 3 && column.v.at(-1) < 200, `starts ${(fadeTop / column.height * 100).toFixed(0)}% down, largest step ${maxJump} levels per row, ${column.v.at(-1)} just above the text`);
  // Stops compute as rgba(…) or, for color-mix, color(srgb r g b / a).
  const colours = (g) => [...g.matchAll(/rgba?\([^)]*\)|color\(srgb [^)]*\)/g)].map((m) => m[0]);
  const isBlack = (c) => /^rgba?\(0, 0, 0(, [\d.]+)?\)$/.test(c) || /^color\(srgb 0 0 0( \/ [\d.]+)?\)$/.test(c);
  const alphaOf = (c) => Number(c.match(/[,/] ([\d.]+)\)$/)?.[1] ?? 1);
  const blackOnly = overlays.length === 2 && overlays.every((o) => /gradient/.test(o.gradient) && colours(o.gradient).every(isBlack));
  check("look: with a photo, Discover and Like back get a black fade (no purple or ink tint)", blackOnly, overlays.map((o) => `${o.screen}: ${o.gradient.slice(0, 60)}`).join(" | "));
  const fades = overlays.every((o) => {
    const a = colours(o.gradient).map(alphaOf);
    return /to top/.test(o.gradient) && a[0] > 0.5 && a.at(-1) === 0 && a.every((v, i) => i === 0 || v <= a[i - 1]);
  });
  check("look: the fade is darkest at the bottom and clear at the top", fades);
  check("look: the fade sits above the photo and below the text and actions; the text block adds no second scrim", overlays.every((o) => o.layered && o.overlayBg === "none"), overlays.map((o) => `${o.screen}: ${o.layered} ${o.overlayBg}`).join(", "));
  check("look: the fade covers only the photo's lower part (its upper 40% has none) and is clipped by its corners", overlays.every((o) => o.clear >= 0.399 && o.clipped), overlays.map((o) => `${o.screen}: ${(o.clear * 100).toFixed(0)}% of the photo clear`).join(", "));

  // Text stays readable over a pure white photo: the fade's opacity at each line composited over white.
  const overWhite = (a) => { const v = Math.round(255 * (1 - a)); return `rgb(${v}, ${v}, ${v})`; };
  for (const o of overlays) {
    const nameRatio = ratio("rgb(255, 255, 255)", overWhite(o.name));
    check(`contrast (${o.screen}): the name (large text) over a white photo is at least 3:1`, nameRatio >= 3, `${nameRatio.toFixed(2)} at ${(o.name * 100).toFixed(0)}% black`);
    if (o.detail !== null) {
      const detailRatio = ratio("rgb(255, 255, 255)", overWhite(o.detail));
      check(`contrast (${o.screen}): the detail line over a white photo is at least 4.5:1`, detailRatio >= 4.5, `${detailRatio.toFixed(2)} at ${(o.detail * 100).toFixed(0)}% black`);
    }
  }

  // 4e. Shapes that the pill styling must never reach: each component keeps the V2 geometry
  // (measured from experiment/tiimo-white-surface-refinement, before V3 and V4 squared controls
  // off). Every rendered instance on the listed screens is checked.
  const SHAPES = {
    ".btn--primary": "999px", ".btn--secondary": "999px", ".btn--quiet": "999px",
    ".action-bar__btn": "28px", ".nav-button": "50%", ".fab": "50%",
    ".count-badge": "999px", ".conversation__unread": "999px", ".conversation__move": "999px",
    ".profile-card__pill": "999px", ".person-tile__badge .badge": "999px",
    ".tab-bar": "999px", ".tab-bar__item": "999px",
    ".search": "999px", ".composer__field": "20px", ".composer__send": "50%", ".input": "16px",
    ".segmented__item": "999px", ".filter-chips:not(:has(.chip[data-emoji])) .chip": "999px",
    ".avatar__image:not(.match__you .avatar__image)": "50%", ".match-queue__image": "20px",
    ".profile-card__media": "32px", ".message__bubble": "20px",
  };
  const shapeErrors = [];
  const seen = new Set();
  for (const s of ["basics", "interests", "discovery", "like-profile", "likes", "chats", "chat", "match", "activity"]) {
    if (s === "match") await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
    else await open(p, `flows.html?screen=${s}&theme=tiimo`);
    const found = await p.evaluate((shapes) => Object.entries(shapes).map(([sel, want]) => {
      const got = [...document.querySelectorAll(`.theme-tiimo ${sel}`)].map((el) => getComputedStyle(el).borderTopLeftRadius);
      return [sel, want, got];
    }), SHAPES);
    for (const [sel, want, got] of found) {
      if (got.length) seen.add(sel);
      for (const g of new Set(got)) if (g !== want) shapeErrors.push(`${s} ${sel}: ${g} (want ${want})`);
    }
  }
  check("shapes: buttons, Discover actions, icon buttons, badges, tab bar, inputs, filters, avatars and photos keep their own shapes", shapeErrors.length === 0, shapeErrors.slice(0, 6).join(" | "));
  check("shapes: every pinned component was found and measured", seen.size === Object.keys(SHAPES).length, Object.keys(SHAPES).filter((k) => !seen.has(k)).join(", "));

  // 4f. The match moment: their photo fills and is clipped by the scalloped silhouette; yours is a
  // smaller rounded square on its lower-left edge; no heart, no halo, no confetti.
  await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
  const match = await p.evaluate(() => {
    const m = document.querySelector(".match");
    const halo = document.querySelector(".organic-portrait__backdrop");
    const frame = document.querySelector(".match .organic-portrait");
    const photo = frame.querySelector(".organic-portrait__photo");
    const image = photo.querySelector("img, .organic-portrait__fallback");
    const you = document.querySelector(".match__you");
    const f = frame.getBoundingClientRect();
    const ph = photo.getBoundingClientRect();
    const i = image.getBoundingClientRect();
    const y = you.getBoundingClientRect();
    const pcs = getComputedStyle(photo);
    const yi = getComputedStyle(you.querySelector(".avatar__image"));
    const art = document.querySelector(".match__art .illustration-slot");
    const yc = { x: y.left + y.width / 2, y: y.top + y.height / 2 };
    const fc = { x: f.left + f.width / 2, y: f.top + f.height / 2 };
    return {
      confetti: [getComputedStyle(m, "::before").content, getComputedStyle(m, "::after").content],
      halo: halo ? getComputedStyle(halo).display : "none",
      // The photo layer is masked by the scallop path and the image fills it edge to edge.
      clipped: /svg/.test(pcs.maskImage || pcs.webkitMaskImage) && pcs.backgroundColor === "rgba(0, 0, 0, 0)" && Math.abs(i.width - ph.width) < 1 && Math.abs(i.height - ph.height) < 1 && Math.abs(ph.width - f.width) < 1,
      youRadius: yi.borderTopLeftRadius,
      rounded: parseFloat(yi.borderTopLeftRadius) >= 10 && parseFloat(yi.borderTopLeftRadius) < y.width / 2 - 8,
      // Lower-left: its centre is left of and below their centre, and the two overlap.
      lowerLeft: yc.x < fc.x - f.width * 0.2 && yc.y > fc.y + f.height * 0.2 && y.right > f.left + f.width * 0.15 && y.top < f.bottom - f.height * 0.15,
      clearOfFace: Math.hypot(yc.x - fc.x, yc.y - fc.y) > f.width * 0.35,
      dominant: f.width > 2.5 * y.width,
      heart: art ? [...art.querySelectorAll("*")].some((el) => getComputedStyle(el).visibility === "visible" && el.getBoundingClientRect().width > 0) : false,
      artSpace: art ? Math.round(art.getBoundingClientRect().height) : 0,
      detail: `frame ${Math.round(f.width)}px, yours ${Math.round(y.width)}px at radius ${yi.borderTopLeftRadius}, centres ${Math.round(Math.hypot(yc.x - fc.x, yc.y - fc.y))}px apart`,
    };
  });
  check("match: no confetti or particles around the photos", match.confetti.every((c) => c === "none" || c === "normal"), match.confetti.join(" "));
  check("match: no lavender halo or outline around their photo", match.halo === "none", match.halo);
  check("match: their photo fills the scalloped silhouette and is clipped by it", match.clipped, match.detail);
  check("match: your smaller photo is a rounded square, not a circle", match.rounded, match.youRadius);
  check("match: your photo overlaps the lower-left edge of theirs, clear of its centre", match.lowerLeft && match.clearOfFace && match.dominant, match.detail);
  check("match: the temporary purple heart is gone; its slot stays, empty, for the hand illustrations", !match.heart && match.artSpace > 0, `slot ${match.artSpace}px tall`);

  // 4g. Pills (V5): only the emoji-and-text pills. Unselected: light neutral grey, no border;
  // selected: light purple with a fine purple outline; a 12px rounded rectangle; no gradient.
  const pillStyle = (sel) => p.evaluate((q) => [...document.querySelectorAll(q)].map((c) => {
    const cs = getComputedStyle(c);
    return { selected: c.classList.contains("is-selected"), locked: c.classList.contains("is-unavailable"), r: parseFloat(cs.borderTopLeftRadius), h: c.getBoundingClientRect().height, bg: cs.backgroundColor, image: cs.backgroundImage, ring: cs.boxShadow, border: cs.borderTopWidth, fg: cs.color };
  }), sel);
  const pills = [];
  await open(p, "flows.html?screen=interests&theme=tiimo");
  pills.push(...(await pillStyle(".chip[data-emoji]")));
  await open(p, "flows.html?screen=activity&theme=tiimo");
  pills.push(...(await pillStyle(".filter-chips:has(.chip[data-emoji]) .chip")));
  await open(p, "flows.html?screen=discovery&theme=tiimo");
  pills.push(...(await pillStyle(".shared-interests__pill")));
  await openSeeded(p, "flows.html?screen=match&theme=tiimo", MATCHED);
  pills.push(...(await pillStyle(".match__shared-chip")));
  const unselected = pills.filter((c) => !c.selected);
  const selected = pills.filter((c) => c.selected);
  check("pills: every emoji-and-text pill is a 12px rounded rectangle, not a capsule", pills.length > 10 && pills.every((c) => c.r === 12 && c.h >= 32), [...new Set(pills.map((c) => `${c.r}px on ${Math.round(c.h)}px`))].join(", "));
  check("pills: unselected pills are light neutral grey with no border or outline", unselected.length > 0 && unselected.every((c) => c.bg === "rgb(242, 242, 242)" && c.ring === "none" && c.border === "0px"), [...new Set(unselected.map((c) => `${c.bg} ${c.ring} ${c.border}`))].join(" | "));
  check("pills: selected pills are light purple with a fine purple outline", selected.length >= 2 && selected.every((c) => c.bg === "rgb(233, 228, 251)" && /rgb\(114, 98, 199\) 0px 0px 0px 1px inset/.test(c.ring)), [...new Set(selected.map((c) => `${c.bg} ${c.ring}`))].join(" | "));
  check("pills: no gradient on any pill", pills.every((c) => c.image === "none"));
  const worstPill = Math.min(...pills.filter((c) => !c.locked).map((c) => ratio(c.fg, c.bg)));
  check("contrast: pill text is at least 4.5:1, selected and unselected", worstPill >= 4.5, worstPill.toFixed(2));

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
