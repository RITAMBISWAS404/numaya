#!/usr/bin/env node
// Exports the web design system's icons and spot illustrations for the Flutter app, so both apps
// draw the same artwork from one source:
//   - src/design-system/icons/material-symbols.js  -> lib/core/design_system/icons/numaya_icon_data.g.dart
//   - src/design-system/components/Illustration.jsx -> assets/illustrations/<scene>.svg
// Illustration colours are resolved from the approved tokens (the web uses .ill__* CSS classes).
//
//   node apps/numaya_mobile/tool/export_assets.mjs

import { mkdirSync, writeFileSync, rmSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const here = dirname(fileURLToPath(import.meta.url));
const appRoot = resolve(here, "..");
const repoRoot = resolve(appRoot, "..", "..");

// 1 · Icons ------------------------------------------------------------------
const { GLYPHS, SYMBOL_NAMES, MATERIAL_SYMBOLS_VERSION } = await import(
  pathToFileURL(resolve(repoRoot, "src/design-system/icons/material-symbols.js")).href
);
let dart = `// GENERATED FILE. DO NOT EDIT.
// Material Symbols Rounded ${MATERIAL_SYMBOLS_VERSION} (Google, Apache-2.0), weight 500, optical size 24,
// exported from src/design-system/icons/material-symbols.js by tool/export_assets.mjs.
// Each entry: (filled path, outline path) on the 0 -960 960 960 grid.
// ignore_for_file: lines_longer_than_80_chars

/// Icon names shared with the web design system (\`<Icon name="..."/>\`).
enum NumayaIcons {
${Object.keys(GLYPHS)
  .map((name) => `  /// Material Symbol \`${SYMBOL_NAMES[name]}\`.\n  ${name}`)
  .join(",\n")};

  /// SVG path data, (filled, outline).
  (String, String) get paths => numayaIconPaths[this]!;
}

const Map<NumayaIcons, (String, String)> numayaIconPaths = {
${Object.entries(GLYPHS)
  .map(([name, [fill, outline]]) => `  NumayaIcons.${name}: ('${fill}', '${outline}'),`)
  .join("\n")}
};
`;
const iconOut = resolve(appRoot, "lib/core/design_system/icons/numaya_icon_data.g.dart");
mkdirSync(dirname(iconOut), { recursive: true });
writeFileSync(iconOut, dart);
console.log(`Wrote ${Object.keys(GLYPHS).length} icons to ${iconOut}`);

// 2 · Illustrations ------------------------------------------------------------
const { tokenByName } = await import(pathToFileURL(resolve(repoRoot, "src/design-system/tokens.js")).href);
const c = (name) => tokenByName[name].resolved;
const STYLE = {
  ill__ink: { stroke: c("--color-text-primary"), "stroke-width": "2.5", "stroke-linecap": "round", "stroke-linejoin": "round" },
  ill__open: { fill: "none" },
  "ill__on-brand": { stroke: c("--color-on-brand"), "stroke-width": "3.5", "stroke-linecap": "round", "stroke-linejoin": "round" },
  ill__paper: { fill: c("--color-surface") },
  ill__wash: { fill: c("--color-surface-brand") },
  ill__ground: { fill: c("--color-surface-soft") },
  ill__soft: { fill: c("--color-surface-sunken") },
  ill__muted: { fill: c("--color-border-strong") },
  ill__strong: { fill: c("--color-border-control") },
  ill__brand: { fill: c("--color-brand") },
  ill__promo: { fill: c("--color-accent-promo") },
  ill__yellow: { fill: c("--color-accent-yellow") },
  "ill__on-brand-fill": { fill: c("--color-on-brand") },
  ill__trail: { fill: "none", stroke: c("--color-border-control"), "stroke-width": "2", "stroke-linecap": "round", "stroke-dasharray": "2 6" },
};

const tmp = resolve(repoRoot, "node_modules/.cache/numaya-mobile-export");
mkdirSync(tmp, { recursive: true });
const entry = resolve(tmp, "entry.jsx");
writeFileSync(
  entry,
  `import { renderToStaticMarkup } from "react-dom/server";
import { Illustration, ILLUSTRATION_SCENES } from ${JSON.stringify(resolve(repoRoot, "src/design-system/components/Illustration.jsx"))};
export const scenes = Object.fromEntries(ILLUSTRATION_SCENES.map((s) => [s, renderToStaticMarkup(<Illustration scene={s} />)]));
`,
);
const bundle = resolve(tmp, "bundle.mjs");
await build({ entryPoints: [entry], bundle: true, format: "esm", platform: "node", outfile: bundle, jsx: "automatic", logLevel: "error", external: ["react", "react-dom", "react/*", "react-dom/*"] });
const { scenes } = await import(pathToFileURL(bundle).href + `?t=${Date.now()}`);
rmSync(tmp, { recursive: true, force: true });

const illOut = resolve(appRoot, "assets/illustrations");
mkdirSync(illOut, { recursive: true });
for (const [scene, markup] of Object.entries(scenes)) {
  const svg = markup
    // Classes become presentation attributes (later classes win, as in the stylesheet order).
    .replace(/ class="([^"]*)"/g, (_, cls) => {
      const style = {};
      for (const name of cls.split(/\s+/)) Object.assign(style, STYLE[name]);
      return Object.entries(style)
        .map(([k, v]) => ` ${k}="${v}"`)
        .join("");
    })
    .replace(/ (aria-hidden|focusable|data-scene)="[^"]*"/g, "")
    .replace("<svg", '<svg xmlns="http://www.w3.org/2000/svg"');
  writeFileSync(resolve(illOut, `${scene}.svg`), `${svg}\n`);
}
console.log(`Wrote ${Object.keys(scenes).length} illustrations to ${illOut}`);
