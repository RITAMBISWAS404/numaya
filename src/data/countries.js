// `pattern` drives both the placeholder and live formatting; each X is a digit.
export const COUNTRIES = [
  { iso: "US", name: "United States", dial: "+1", pattern: "(XXX) XXX-XXXX" },
  { iso: "GB", name: "United Kingdom", dial: "+44", pattern: "XXXX XXXXXX" },
  { iso: "CA", name: "Canada", dial: "+1", pattern: "(XXX) XXX-XXXX" },
  { iso: "AU", name: "Australia", dial: "+61", pattern: "XXX XXX XXX" },
  { iso: "IN", name: "India", dial: "+91", pattern: "XXXXX XXXXX" },
  { iso: "SG", name: "Singapore", dial: "+65", pattern: "XXXX XXXX" },
  { iso: "AE", name: "United Arab Emirates", dial: "+971", pattern: "XX XXX XXXX" },
  { iso: "DE", name: "Germany", dial: "+49", pattern: "XXXX XXXXXXX" },
  { iso: "FR", name: "France", dial: "+33", pattern: "X XX XX XX XX" },
  { iso: "ES", name: "Spain", dial: "+34", pattern: "XXX XXX XXX" },
  { iso: "NL", name: "Netherlands", dial: "+31", pattern: "X XXXX XXXX" },
  { iso: "JP", name: "Japan", dial: "+81", pattern: "XX XXXX XXXX" },
  { iso: "BR", name: "Brazil", dial: "+55", pattern: "XX XXXXX XXXX" },
  { iso: "MX", name: "Mexico", dial: "+52", pattern: "XX XXXX XXXX" },
];

export const DEFAULT_COUNTRY = COUNTRIES[0];

export function digitCount(country) {
  return country.pattern.replace(/[^X]/g, "").length;
}

/** Formats as many digits as are present, never leaving a dangling separator. */
export function formatNational(country, digits) {
  let out = "";
  let i = 0;
  for (const ch of country.pattern) {
    if (i >= digits.length) break;
    if (ch === "X") out += digits[i++];
    else out += ch;
  }
  return out;
}

export function placeholderFor(country) {
  let n = 0;
  return country.pattern.replace(/X/g, () => (n++ < 3 ? "5" : "0"));
}

export function formatInternational(country, digits) {
  return `${country.dial} ${formatNational(country, digits)}`;
}
