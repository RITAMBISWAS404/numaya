import { describe, expect, it } from "vitest";
import { EXPERIMENT_THEMES, themeClassName } from "../../src/lib/theme.js";

describe("experiment themes", () => {
  it("offers the V11 direction and the V12 Liquid Glass experiment as separate flags", () => {
    expect(EXPERIMENT_THEMES).toEqual(["tiimo", "liquid-glass"]);
  });

  it("renders Liquid Glass on top of the tiimo theme, and nothing for other values", () => {
    expect(themeClassName("tiimo")).toBe("theme-tiimo");
    expect(themeClassName("liquid-glass")).toBe("theme-tiimo theme-liquid-glass");
    expect(themeClassName(null)).toBeNull();
    expect(themeClassName("glass")).toBeNull();
  });
});
