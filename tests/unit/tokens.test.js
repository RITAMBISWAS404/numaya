import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { build, cssVarName } from "../../scripts/tokens.mjs";
import { contrast, hexToRgb, luminance } from "../../src/lib/contrast.js";

const { tokens, css, js } = build();
const value = (name) => {
  for (const [id, t] of tokens) if (cssVarName(t.path) === name) return resolve(id);
  throw new Error(`No token ${name}`);
};
function resolve(id) {
  const t = tokens.get(id);
  return t.value.replace(/\{([^}]+)\}/g, (_, ref) => resolve(ref));
}
const WHITE = "#ffffff";

describe("token pipeline", () => {
  it("generated files are up to date with the source", () => {
    expect(readFileSync("src/design-system/tokens.css", "utf8")).toBe(css);
    expect(readFileSync("src/design-system/tokens.js", "utf8")).toBe(js);
  });

  it("emits reduced-motion overrides for every motion duration", () => {
    for (const d of ["fast", "base", "slow", "push"]) {
      expect(css).toMatch(new RegExp(`prefers-reduced-motion[\\s\\S]*--motion-duration-${d}:`));
    }
  });

  it("keeps the single brand colour at exactly #F770E3", () => {
    expect(value("--color-brand").toLowerCase()).toBe("#f770e3");
    expect(value("--color-border-brand").toLowerCase()).toBe("#f770e3");
    expect(value("--color-text-brand-display").toLowerCase()).toBe("#f770e3");
    expect(value("--p-color-pink-500").toLowerCase()).toBe("#f770e3");
  });

  it("has no legacy blue brand tokens or literals", () => {
    expect(css).not.toMatch(/--p-color-blue|63afe9|1f6fb0|17507f|3f92d4/i);
    expect(css).not.toMatch(/--color-brand-(strong|pressed)/);
  });

  it("derives tints by lightening the brand pink, with no darker second pink", () => {
    const l = (hex) => luminance(hexToRgb(hex));
    const brand = l(value("--color-brand"));
    for (const t of ["--color-brand-tint", "--color-brand-subtle", "--color-surface-brand"]) expect(l(value(t))).toBeGreaterThan(brand);
    const pinks = tokens.keys().toArray().filter((id) => id.startsWith("primitive.color.pink."));
    expect(pinks.map((id) => id.split(".").pop())).toEqual(["50", "100", "200", "500"]);
  });

  it("puts dark ink, not white, on solid brand fills", () => {
    expect(value("--color-on-brand").toLowerCase()).toBe(value("--p-color-neutral-900").toLowerCase());
    expect(contrast(value("--color-on-brand"), value("--color-brand"))).toBeGreaterThanOrEqual(4.5);
  });
});

describe("contrast requirements", () => {
  const AA_TEXT = [
    ["--color-text-primary", "--color-surface"],
    ["--color-text-secondary", "--color-surface"],
    ["--color-text-muted", "--color-surface"],
    ["--color-text-muted", "--color-surface-soft"],
    ["--color-text-muted", "--color-surface-page"],
    ["--color-text-primary", "--color-surface-page"],
    ["--color-text-brand", "--color-surface"],
    ["--color-text-brand-deep", "--color-brand-tint"],
    ["--color-on-brand", "--color-brand"],
    ["--color-text-brand", "--color-surface"],
    ["--color-text-brand", "--color-brand-tint"],
    ["--color-text-on-inverse", "--color-surface-inverse"],
    ["--color-danger", "--color-surface"],
    ["--color-danger", "--color-danger-tint"],
    ["--color-success", "--color-success-tint"],
    ["--color-warning", "--color-warning-tint"],
    ["--color-text-primary", "--color-brand-tint"],
  ];

  it.each(AA_TEXT)("%s on %s meets 4.5:1", (fg, bg) => {
    expect(contrast(value(fg), value(bg))).toBeGreaterThanOrEqual(4.5);
  });

  it("control outlines and the focus indicator meet 3:1 non-text contrast", () => {
    expect(contrast(value("--color-border-control"), value("--color-surface"))).toBeGreaterThanOrEqual(3);
    expect(contrast(value("--color-focus-ring"), value("--color-surface"))).toBeGreaterThanOrEqual(3);
  });

  it("documents the only accepted exceptions", () => {
    // Pink as display-size headline emphasis: below the 3:1 large-text minimum, documented, one word only.
    const display = contrast(value("--color-text-brand-display"), value("--color-surface"));
    expect(display).toBeGreaterThan(2.4);
    expect(display).toBeLessThan(3);
    // White on the brand fill fails, which is why on-brand is ink.
    expect(contrast(WHITE, value("--color-brand"))).toBeLessThan(3);
    // Placeholder and disabled text.
    expect(contrast(value("--color-text-subtle"), value("--color-surface"))).toBeLessThan(3);
  });
});

describe("geometry and elevation", () => {
  const px = (name) => parseFloat(value(name));
  const maxAlpha = (name) => Math.max(...[...value(name).matchAll(/\/ ([0-9.]+)\)/g)].map((m) => parseFloat(m[1])));

  it("radius scale increases, stays soft and never turns controls into capsules", () => {
    const scale = ["xs", "sm", "md", "lg", "xl", "2xl"].map((k) => px(`--radius-${k}`));
    expect(scale).toEqual([...scale].sort((a, b) => a - b));
    expect(new Set(scale).size).toBe(scale.length);
    // Controls are softly rounded but well below half their height (54px buttons).
    expect(px("--radius-md")).toBeGreaterThanOrEqual(12);
    expect(px("--radius-md")).toBeLessThan(px("--button-height") / 2 - 8);
    expect(px("--radius-2xl")).toBeLessThanOrEqual(32);
  });

  it("nested corners follow outer = inner + inset (tab bar around its items)", () => {
    expect(px("--radius-xl") - px("--radius-lg")).toBe(px("--space-2"));
  });

  it("shadows are neutral and low opacity, strongest only on layered overlays", () => {
    for (const t of ["xs", "sm", "md", "float", "button"]) expect(maxAlpha(`--shadow-${t}`)).toBeLessThanOrEqual(0.14);
    expect(maxAlpha("--shadow-lg")).toBeLessThanOrEqual(0.2);
    for (const t of ["xs", "sm", "md", "float", "lg", "button"]) {
      const v = value(`--shadow-${t}`);
      expect(v).not.toMatch(/247 112 227/); // no pink glow
      expect(v.match(/rgb\(/g).length).toBeLessThanOrEqual(3);
    }
  });
});
