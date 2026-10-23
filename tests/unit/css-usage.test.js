import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";

const walk = (dir) =>
  readdirSync(dir, { withFileTypes: true }).flatMap((e) => (e.isDirectory() ? walk(join(dir, e.name)) : [join(dir, e.name)]));

const tokensCss = readFileSync("src/design-system/tokens.css", "utf8");
const defined = new Set([...tokensCss.matchAll(/(--[a-z0-9-]+):/g)].map((m) => m[1]));
// Runtime and component-local custom properties set in CSS or inline styles.
const RUNTIME = new Set([
  "--safe-top", "--safe-bottom", "--keyboard-inset", "--keypad-h",
  "--x", "--r", "--s", "--i", "--from", "--to", "--code-length", "--code-group", "--sc-min", "--avatar-size", "--avatar-inset", "--dx", "--rot", "--p",
  "--profile-card-photo-height", "--profile-card-photo-min", "--profile-card-ratio",
]);
const files = walk("src").filter((f) => /\.(css|jsx?)$/.test(f) && !f.endsWith("tokens.css") && !f.endsWith("tokens.js"));

describe("CSS custom property usage", () => {
  it("every var() reference resolves to a token or a documented runtime variable", () => {
    const unknown = [];
    for (const f of files) {
      for (const m of readFileSync(f, "utf8").matchAll(/var\((--[a-z0-9-]+)[,)]/g)) {
        if (!defined.has(m[1]) && !RUNTIME.has(m[1])) unknown.push(`${f}: ${m[1]}`);
      }
    }
    expect(unknown).toEqual([]);
  });

  it("product CSS contains no raw colours (simulator chrome excluded)", () => {
    const product = files.filter((f) => f.endsWith(".css") && !f.endsWith("device.css"));
    const raw = [];
    for (const f of product) {
      const text = readFileSync(f, "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/url\("data:[^"]*"\)/g, "");
      for (const m of text.matchAll(/#[0-9a-fA-F]{3,8}\b|rgba?\(/g)) raw.push(`${f}: ${m[0]}`);
    }
    // Shadow tokens may contain rgb(); everything else must go through tokens.
    expect(raw).toEqual([]);
  });

  it("component CSS never references primitive tokens directly", () => {
    const offenders = files.filter((f) => /var\(--p-/.test(readFileSync(f, "utf8")));
    expect(offenders).toEqual([]);
  });
});

describe("geometry rules", () => {
  const css = files.filter((f) => f.endsWith(".css")).map((f) => readFileSync(f, "utf8")).join("\n");
  const block = (selector) => {
    const m = css.match(new RegExp(`(^|\\n)${selector.replace(/\./g, "\\.")}\\s*\\{([^}]*)\\}`));
    return m ? m[2] : "";
  };

  it("ordinary controls are not pills (chips and buttons are pills, as in the references)", () => {
    for (const sel of [".badge", ".tag", ".pill"]) {
      expect(block(sel), sel).toContain("border-radius");
      expect(block(sel), sel).not.toMatch(/radius-pill|999px/);
    }
  });

  it("segmented options are separate filter pills, as in the Meetup reference", () => {
    expect(block(".segmented__item")).toMatch(/border-radius:\s*var\(--radius-pill\)/);
    expect(block(".segmented__item.is-selected")).toMatch(/background:\s*var\(--color-control-selected\)/);
    expect(block(".segmented")).not.toMatch(/background/);
  });

  it("every pressable control has press feedback", () => {
    for (const sel of [".btn", ".nav-button", ".fab", "button.chip", ".tab-bar__item", ".action-bar__btn", ".composer__send", ".option-card", "button.list-row__hit", ".conversation__hit", ".match-queue__item", ".action-sheet__item", ".country-row", ".photo-slot--empty", ".fl-edit-card", ".fl-photo-strip__empty"]) {
      expect(css, sel).toMatch(new RegExp(`${sel.replace(/\./g, "\\.")}(:[a-z-]+\\([^)]*\\))*:active`));
    }
  });

  it("closing animations run on the motion tokens, so reduced motion shortens them", () => {
    for (const m of css.matchAll(/animation:\s*(sheet-out|fade-out|pill-out)[^;]*;/g)) expect(m[0]).toMatch(/var\(--motion-duration-/);
  });

  it("chips are pills, as in the reference", () => {
    expect(block(".chip")).toMatch(/radius-pill/);
    expect(block(".btn")).toMatch(/radius-pill/);
  });

  it("uses plain border-radius only: no corner-shape, superellipse or squircle anywhere", () => {
    for (const f of files) expect(readFileSync(f, "utf8"), f).not.toMatch(/corner-shape|superellipse\(/);
  });
});
