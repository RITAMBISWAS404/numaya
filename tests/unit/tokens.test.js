import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { build, cssVarName } from "../../scripts/tokens.mjs";
import { contrast } from "../../src/lib/contrast.js";

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

  it("keeps the brand accent at exactly #63AFE9", () => {
    expect(value("--color-brand").toLowerCase()).toBe("#63afe9");
    expect(value("--color-focus-ring").toLowerCase()).toBe("#63afe9");
    expect(value("--color-border-brand").toLowerCase()).toBe("#63afe9");
  });

  it("keeps foreground on brand fills white", () => {
    expect(value("--color-on-brand").toLowerCase()).toBe(WHITE);
  });

  it("uses the same hue for the strong brand variant", () => {
    const hue = (hex) => {
      const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255);
      const max = Math.max(r, g, b);
      const min = Math.min(r, g, b);
      return 60 * (4 + (r - g) / (max - min)); // blue is the max channel for both
    };
    expect(Math.abs(hue(value("--color-brand")) - hue(value("--color-brand-strong")))).toBeLessThan(2);
  });
});

describe("contrast requirements", () => {
  const AA_TEXT = [
    ["--color-text-primary", "--color-surface"],
    ["--color-text-secondary", "--color-surface"],
    ["--color-text-muted", "--color-surface"],
    ["--color-text-muted", "--color-surface-soft"],
    ["--color-text-brand", "--color-surface"],
    ["--color-text-brand-deep", "--color-brand-tint"],
    ["--color-on-brand", "--color-brand-strong"],
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

  it("control outlines meet 3:1 non-text contrast", () => {
    expect(contrast(value("--color-border-control"), value("--color-surface"))).toBeGreaterThanOrEqual(3);
  });

  it("documents the only accepted exceptions", () => {
    // Glyph-only white marks on the exact brand fill, always paired with a text label or a shape cue.
    expect(contrast(value("--color-on-brand"), value("--color-brand"))).toBeCloseTo(2.38, 1);
    // Placeholder and disabled text.
    expect(contrast(value("--color-text-subtle"), value("--color-surface"))).toBeLessThan(3);
  });
});
