import { afterEach, describe, expect, it } from "vitest";
import { EXPERIMENT_THEMES, experimentTheme, themeClasses } from "../../src/lib/theme.js";

const setSearch = (search) => window.history.replaceState(null, "", `/${search}`);

describe("experiment themes", () => {
  afterEach(() => setSearch(""));

  it("knows V11 (tiimo) and V16 (withings), and nothing else", () => {
    expect(EXPERIMENT_THEMES).toEqual(["tiimo", "withings"]);
    setSearch("?theme=other");
    expect(experimentTheme()).toBeNull();
  });

  it("renders the approved design without a flag", () => {
    expect(themeClasses()).toBeNull();
  });

  it("gives V11 its own class and V16 V11's layer plus its own", () => {
    setSearch("?theme=tiimo");
    expect(themeClasses()).toBe("theme-tiimo");
    setSearch("?theme=withings");
    expect(themeClasses()).toBe("theme-tiimo theme-withings");
  });
});
