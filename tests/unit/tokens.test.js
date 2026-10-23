import { readdirSync, readFileSync } from "node:fs";
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

  it("uses the sampled Meetup purple as the brand, with no trace of the old pink", () => {
    expect(value("--color-brand").toLowerCase()).toBe("#7262c7");
    expect(value("--color-border-brand").toLowerCase()).toBe("#7262c7");
    expect(value("--color-focus-ring").toLowerCase()).toBe("#7262c7");
    expect(css).not.toMatch(/f770e3|247 112 227/i);
  });

  it("has no legacy blue brand tokens or literals", () => {
    expect(css).not.toMatch(/--p-color-blue|63afe9|1f6fb0|17507f|3f92d4/i);
    expect(css).not.toMatch(/--color-brand-(strong|pressed)/);
  });

  it("derives lavender tints by lightening the brand purple", () => {
    const l = (hex) => luminance(hexToRgb(hex));
    const brand = l(value("--color-brand"));
    for (const t of ["--color-brand-tint", "--color-brand-soft", "--color-brand-subtle", "--color-surface-brand", "--color-brand-hero"]) expect(l(value(t))).toBeGreaterThan(brand);
    const purples = tokens.keys().toArray().filter((id) => id.startsWith("primitive.color.purple."));
    expect(purples.map((id) => id.split(".").pop())).toEqual(["50", "100", "200", "300", "600", "800"]);
  });

  it("puts white text and glyphs on solid brand purple at AA", () => {
    expect(value("--color-on-brand").toLowerCase()).toBe("#ffffff");
    expect(contrast(value("--color-on-brand"), value("--color-brand"))).toBeGreaterThanOrEqual(4.5);
  });

  it("keeps the secondary Meetup palette to its roles (marks and framing, never text)", () => {
    const accents = [...tokens.values()].filter((t) => t.path[1] === "color" && t.path[2] === "accent").map((t) => cssVarName(t.path));
    expect(accents.sort()).toEqual(["--color-accent-green", "--color-accent-orange", "--color-accent-promo", "--color-accent-rose", "--color-accent-rose-tint", "--color-accent-yellow", "--color-accent-yellow-tint"]);
    const productCss = readdirSync("src", { recursive: true })
      .filter((f) => f.endsWith(".css") && !f.endsWith("tokens.css"))
      .map((f) => readFileSync(`src/${f}`, "utf8"))
      .join("\n");
    // No accent colour is ever used as a text colour.
    expect(productCss).not.toMatch(/(?<![-\w])color:\s*var\(--color-accent-/);
  });

  it("purple fills are flat (no sheen token) and the floating shadow is a soft purple", () => {
    expect(css).not.toMatch(/--gradient-brand-sheen/);
    const glow = value("--shadow-brand");
    const tinted = [...glow.matchAll(/rgb\((\d+ \d+ \d+) \/ ([0-9.]+)\)/g)].filter((m) => m[1] !== "20 19 22");
    expect(tinted.map((m) => m[1])).toEqual(["114 98 199"]);
    expect(parseFloat(tinted[0][2])).toBeLessThanOrEqual(0.5);
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
    ["--color-text-brand", "--color-surface"],
    ["--color-text-brand", "--color-brand-tint"],
    ["--color-text-on-inverse", "--color-surface-inverse"],
    ["--color-danger", "--color-surface"],
    ["--color-danger", "--color-danger-tint"],
    ["--color-success", "--color-success-tint"],
    ["--color-warning", "--color-warning-tint"],
    ["--color-text-primary", "--color-brand-tint"],
    ["--color-on-brand", "--color-brand"],
    ["--color-text-accent", "--color-surface"],
    ["--color-text-brand-deep", "--color-brand-soft"],
    ["--color-text-secondary", "--color-accent-promo"],
    ["--color-text-on-inverse", "--color-danger-badge"],
  ];

  it.each(AA_TEXT)("%s on %s meets 4.5:1", (fg, bg) => {
    expect(contrast(value(fg), value(bg))).toBeGreaterThanOrEqual(4.5);
  });

  it("control outlines and the focus indicator meet 3:1 non-text contrast", () => {
    expect(contrast(value("--color-border-control"), value("--color-surface"))).toBeGreaterThanOrEqual(3);
    expect(contrast(value("--color-focus-ring"), value("--color-surface"))).toBeGreaterThanOrEqual(3);
  });

  it("documents the only accepted exception", () => {
    // Brand purple is used for text (links) and on-brand is AA, so the only sub-AA text token is the
    // placeholder/disabled grey.
    const textTokens = [...tokens.values()].filter((t) => t.path[1] === "color" && t.path[2] === "text").map((t) => cssVarName(t.path));
    const failing = textTokens.filter((t) => t !== "--color-text-on-inverse" && contrast(value(t), value("--color-surface")) < 4.5);
    expect(failing).toEqual(["--color-text-subtle"]);
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

  it("keeps a corner hierarchy: photos softest, then sheets, cards, controls", () => {
    const r = (k) => px(`--radius-${k}`);
    expect(r("photo")).toBeGreaterThanOrEqual(r("xl"));
    expect(r("xl")).toBeGreaterThan(r("card"));
    expect(r("card")).toBeGreaterThan(r("lg"));
    expect(r("lg")).toBeGreaterThan(r("md"));
    // Code cells: softer than the old 16px controls but tighter than cards and sheets.
    expect(px("--code-cell-radius")).toBeGreaterThan(r("md"));
    expect(px("--code-cell-radius")).toBeLessThan(r("lg"));
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

  it("keeps the avatar ring geometry in step with the identity shape and avatar sizes", async () => {
    const { AVATAR_PX } = await import("../../src/design-system/components/Content.jsx");
    for (const [k, px] of Object.entries(AVATAR_PX)) expect(value(`--size-avatar-${k}`)).toBe(`${px}px`);
  });
});
