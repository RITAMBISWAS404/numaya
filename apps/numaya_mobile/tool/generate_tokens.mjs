#!/usr/bin/env node
// Generates lib/core/design_system/tokens/numaya_tokens.g.dart from the web design system's compiled
// tokens (src/design-system/tokens.js, itself generated from tokens/numaya.tokens.json).
//
// One source of truth: change a colour in tokens/numaya.tokens.json, run `npm run tokens` at the repo
// root, then run this script. The app implements V16, so the shared semantic and component tokens and
// V16's own (withings) tokens are exported; AppColors / AppTypography re-point the roles onto the V16
// values exactly as src/design-system/styles/theme-withings.css does on the web.
//
//   node apps/numaya_mobile/tool/generate_tokens.mjs           write the Dart file
//   node apps/numaya_mobile/tool/generate_tokens.mjs --check   exit 1 if the Dart file is stale

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const appRoot = resolve(here, "..");
const repoRoot = resolve(appRoot, "..", "..");
const out = resolve(appRoot, "lib/core/design_system/tokens/numaya_tokens.g.dart");

const { tokens } = await import(pathToFileURL(resolve(repoRoot, "src/design-system/tokens.js")).href);

// The Flutter app implements V16 (the Withings Health Mate reconstruction). Its tokens are the
// shared semantic and component tokens plus V16's own (`--color-withings-*`, `--withings-*`,
// `--shadow-withings-*`). V11 (tiimo) tokens and raw primitives stay on the web side.
const approved = tokens.filter(
  (t) => t.layer !== "primitive" && !/tiimo|palette/.test(t.name),
);

const camel = (name) =>
  name
    .replace(/^--/, "")
    .replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase())
    .replace(/^(\d)/, "n$1");

const hex2 = (n) => Math.round(n).toString(16).padStart(2, "0").toUpperCase();

function color(value) {
  const v = String(value).trim();
  let m = v.match(/^#([0-9a-f]{6})$/i);
  if (m) return `Color(0xFF${m[1].toUpperCase()})`;
  m = v.match(/^rgba?\(\s*(\d+)[\s,]+(\d+)[\s,]+(\d+)\s*(?:[/,]\s*([\d.]+))?\s*\)$/i);
  if (m) {
    const a = m[4] === undefined ? 1 : Number(m[4]);
    return `Color(0x${hex2(a * 255)}${hex2(+m[1])}${hex2(+m[2])}${hex2(+m[3])})`;
  }
  throw new Error(`Unsupported colour: ${v}`);
}

const px = (v) => {
  const n = Number(String(v).replace(/px$/, ""));
  if (Number.isNaN(n)) throw new Error(`Unsupported dimension: ${v}`);
  return n;
};
const num = (n) => (Number.isInteger(n) ? `${n}.0` : String(n));

// Splits "a, b" at top-level commas (not inside rgb()).
function splitTop(value) {
  const parts = [];
  let depth = 0;
  let cur = "";
  for (const ch of value) {
    if (ch === "(") depth++;
    if (ch === ")") depth--;
    if (ch === "," && depth === 0) {
      parts.push(cur.trim());
      cur = "";
    } else cur += ch;
  }
  if (cur.trim()) parts.push(cur.trim());
  return parts;
}

// Flutter's BoxShadow has no inset; inset layers (a 1px top highlight on buttons) are dropped and
// documented in docs/mobile/DESIGN_SYSTEM.md.
function shadow(value) {
  const layers = splitTop(String(value))
    .filter((l) => !l.startsWith("inset"))
    .map((l) => {
      const colorStart = l.search(/rgb|#/);
      const [x, y, blur = "0", spread = "0"] = l.slice(0, colorStart).trim().split(/\s+/);
      return `BoxShadow(color: ${color(l.slice(colorStart))}, offset: Offset(${num(px(x))}, ${num(px(y))}), blurRadius: ${num(px(blur))}, spreadRadius: ${num(px(spread))})`;
    });
  return `[${layers.join(", ")}]`;
}

const groups = {
  color: { cls: "NumayaColorTokens", type: "Color", emit: (t) => color(t.resolved) },
  dimension: {
    cls: "NumayaSizeTokens",
    type: "double",
    emit: (t) => {
      const v = String(t.resolved);
      // Letter spacing stays in em; AppTypography multiplies it by the font size.
      if (v.endsWith("em")) return num(Number(v.replace(/em$/, "")));
      return num(px(v));
    },
  },
  fontWeight: { cls: "NumayaWeightTokens", type: "double", emit: (t) => num(Number(t.resolved)) },
  number: { cls: "NumayaNumberTokens", type: "double", emit: (t) => num(Number(t.resolved)) },
  duration: {
    cls: "NumayaMotionTokens",
    type: "Duration",
    emit: (t) => `Duration(milliseconds: ${parseInt(t.resolved, 10)})`,
  },
  cubicBezier: {
    cls: "NumayaCurveTokens",
    type: "Cubic",
    emit: (t) => {
      const [a, b, c, d] = String(t.resolved).match(/[\d.]+/g).map(Number);
      return `Cubic(${num(a)}, ${num(b)}, ${num(c)}, ${num(d)})`;
    },
  },
  shadow: { cls: "NumayaShadowTokens", type: "List<BoxShadow>", emit: (t) => shadow(t.resolved) },
};

const docLine = (s) =>
  String(s ?? "")
    .replace(/\s+/g, " ")
    .trim();

let dart = `// GENERATED FILE. DO NOT EDIT.
// Source: tokens/numaya.tokens.json -> src/design-system/tokens.js -> tool/generate_tokens.mjs
// Regenerate: node apps/numaya_mobile/tool/generate_tokens.mjs
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
`;

for (const [type, g] of Object.entries(groups)) {
  const list = approved.filter((t) => t.type === type);
  if (!list.length) continue;
  dart += `\n/// ${type} tokens of the Numaya design system (${list.length}).\nabstract final class ${g.cls} {\n`;
  for (const t of list) {
    const d = docLine(t.description);
    if (d) dart += `  /// ${d}\n`;
    dart += `  static const ${g.type} ${camel(t.name)} = ${g.emit(t)};\n`;
  }
  dart += "}\n";
}

// Variable-font axes for the display face, e.g. "SOFT" 50, "WONK" 0.
const axes = approved.find((t) => t.name === "--font-display-axes");
if (axes) {
  const pairs = [...String(axes.resolved).matchAll(/"(\w{4})"\s+([\d.]+)/g)];
  dart += `\n/// Fraunces axis settings shared by every display style (${docLine(axes.resolved)}).\nabstract final class NumayaFontTokens {\n  static const List<(String, double)> displayAxes = [${pairs
    .map(([, tag, v]) => `('${tag}', ${num(Number(v))})`)
    .join(", ")}];\n}\n`;
}

if (process.argv.includes("--check")) {
  const current = existsSync(out) ? readFileSync(out, "utf8") : "";
  // dart format may rewrap the file and add trailing commas, so compare without either.
  const squash = (s) => s.replace(/\s+/g, "").replace(/,([\])}])/g, "$1");
  if (squash(current) !== squash(dart)) {
    console.error(`Stale: ${out}\nRun: node apps/numaya_mobile/tool/generate_tokens.mjs`);
    process.exit(1);
  }
  console.log("Dart tokens are up to date.");
} else {
  writeFileSync(out, dart);
  console.log(`Wrote ${approved.length} tokens to ${out}`);
}
