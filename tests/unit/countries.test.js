import { describe, expect, it } from "vitest";
import { COUNTRIES, digitCount, formatInternational, formatNational, placeholderFor } from "../../src/data/countries.js";
import { contrast } from "../../src/lib/contrast.js";

const US = COUNTRIES.find((c) => c.iso === "US");
const GB = COUNTRIES.find((c) => c.iso === "GB");

describe("phone formatting", () => {
  it("formats progressively without dangling separators", () => {
    expect(formatNational(US, "")).toBe("");
    expect(formatNational(US, "415")).toBe("(415");
    expect(formatNational(US, "4155")).toBe("(415) 5");
    expect(formatNational(US, "4155550132")).toBe("(415) 555-0132");
  });

  it("derives length and placeholder from the pattern", () => {
    expect(digitCount(US)).toBe(10);
    expect(placeholderFor(US)).toBe("(555) 000-0000");
    expect(formatInternational(GB, "7700900123")).toBe("+44 7700 900123");
  });

  it("has unique ISO codes", () => {
    expect(new Set(COUNTRIES.map((c) => c.iso)).size).toBe(COUNTRIES.length);
  });
});

describe("contrast()", () => {
  it("matches WCAG reference values", () => {
    expect(contrast("#000000", "#ffffff")).toBeCloseTo(21, 0);
    expect(contrast("#ffffff", "#ffffff")).toBeCloseTo(1, 5);
    expect(contrast("#767676", "#ffffff")).toBeCloseTo(4.54, 1);
  });
});
