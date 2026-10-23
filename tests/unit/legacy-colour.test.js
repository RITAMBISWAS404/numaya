import { readdirSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

/*
 * Regression guard for the retired #F770E3 pink theme (October 2026 Meetup migration).
 * Scans every production source the browser loads: component and screen CSS/JS, the generated
 * tokens, the HTML entry points and public assets. Documentation and tests are not scanned: they
 * describe the migration. There are no exceptions: the supplied logo asset is not yet in the repo
 * (see docs/numaya-meetup-ui-map.md, "Logo"); add a narrowly scoped one here if it ever needs pink.
 */
const SOURCES = [
  ...readdirSync("src", { recursive: true }).filter((f) => /\.(css|js|jsx|svg)$/.test(f)).map((f) => `src/${f}`),
  ...readdirSync("public", { recursive: true }).filter((f) => /\.(svg|css|js|json|webmanifest)$/.test(f)).map((f) => `public/${f}`),
  "index.html",
  "flows.html",
  "showcase.html",
];

const hsl = ([r, g, b]) => {
  const [R, G, B] = [r, g, b].map((v) => v / 255);
  const max = Math.max(R, G, B), min = Math.min(R, G, B), l = (max + min) / 2, d = max - min;
  if (!d) return [0, 0, l];
  const s = d / (1 - Math.abs(2 * l - 1));
  const h = max === R ? ((G - B) / d) % 6 : max === G ? (B - R) / d + 2 : (R - G) / d + 4;
  return [(h * 60 + 360) % 360, s, l];
};
// The old brand pink (hue ≈ 309°) and every tint, shade and alpha variant of it. Meetup purple
// (≈ 250°) and the Meetup accent rose (≈ 343°) sit outside this window.
const isLegacyPink = (rgb) => {
  const [h, s, l] = hsl(rgb);
  return h >= 290 && h <= 330 && s > 0.35 && l > 0.3;
};

function colours(text) {
  const out = [];
  for (const m of text.matchAll(/#([0-9a-f]{6}|[0-9a-f]{3})\b/gi)) {
    const h = m[1].length === 3 ? [...m[1]].map((c) => c + c).join("") : m[1];
    out.push({ v: m[0], rgb: [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16)) });
  }
  for (const m of text.matchAll(/rgba?\(\s*(\d+)[\s,]+(\d+)[\s,]+(\d+)/g)) out.push({ v: m[0], rgb: [+m[1], +m[2], +m[3]] });
  for (const m of text.matchAll(/hsla?\(\s*(\d+(?:\.\d+)?)(?:deg)?[\s,]+(\d+(?:\.\d+)?)%[\s,]+(\d+(?:\.\d+)?)%/g)) {
    out.push({ v: m[0], hsl: [+m[1], +m[2] / 100, +m[3] / 100] });
  }
  return out;
}

describe("legacy pink guard", () => {
  it("finds production sources to scan", () => {
    expect(SOURCES.length).toBeGreaterThan(30);
  });

  it("no production source contains the retired #F770E3 pink or any variant of it", () => {
    const hits = [];
    for (const f of SOURCES) {
      for (const c of colours(readFileSync(f, "utf8"))) {
        const legacy = c.rgb ? isLegacyPink(c.rgb) : c.hsl[0] >= 290 && c.hsl[0] <= 330 && c.hsl[1] > 0.35 && c.hsl[2] > 0.3;
        if (legacy) hits.push(`${f}: ${c.v}`);
      }
    }
    expect(hits).toEqual([]);
  });

  it("the guard itself recognises the retired pink and its tints, and spares the Meetup palette", () => {
    for (const hex of ["#f770e3", "#fdd4f7", "#feeefc", "#fff6fd"]) expect(isLegacyPink(colours(hex)[0].rgb), hex).toBe(true);
    for (const hex of ["#7262c7", "#9c85e6", "#f0ecf9", "#ea698c", "#c1486a", "#d6dcfd"]) expect(isLegacyPink(colours(hex)[0].rgb), hex).toBe(false);
  });

  it("retired token and component names are gone", () => {
    const css = readFileSync("src/design-system/tokens.css", "utf8");
    expect(css).not.toMatch(/--p-color-pink|--color-decor-ribbon|--gradient-brand-sheen|--color-text-brand-display/);
    for (const f of SOURCES) expect(readFileSync(f, "utf8"), f).not.toMatch(/class(Name)?=["'{][^"'}]*\bribbon\b|corner-shape|superellipse\(/);
  });
});
