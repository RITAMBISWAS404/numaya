import { describe, expect, it } from "vitest";
import { EXPERIMENT_THEMES, themeClassName } from "../../src/lib/theme.js";

describe("experiment themes", () => {
  it("offers the V11 direction and the V16 Withings-inspired visual layer as separate flags", () => {
    expect(EXPERIMENT_THEMES).toEqual(["tiimo", "withings"]);
  });

  it("renders the V16 visual layer on top of V11's structure, and nothing for other values", () => {
    expect(themeClassName("tiimo")).toBe("theme-tiimo");
    expect(themeClassName("withings")).toBe("theme-tiimo theme-wth");
    expect(themeClassName(null)).toBeNull();
    expect(themeClassName("jpm-visual")).toBeNull();
  });
});
