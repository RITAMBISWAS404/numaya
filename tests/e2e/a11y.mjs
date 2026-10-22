#!/usr/bin/env node
/**
 * Automated accessibility audit (axe-core, WCAG 2.1 A/AA rules) of the prototype, the flow previews
 * (including their open sheets and dialogs) and the design-system showcase.
 *
 *   npm run test:a11y
 *
 * Fails on serious or critical violations; moderate and minor ones are listed for review.
 */
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import { resolve } from "node:path";
import { chromium } from "playwright";
import { createServer } from "vite";

const ROOT = resolve(import.meta.dirname, "../..");
const AXE = readFileSync(createRequire(import.meta.url).resolve("axe-core/axe.min.js"), "utf8");
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

const server = await createServer({ root: ROOT, server: { port: 0, host: "127.0.0.1" }, logLevel: "error" });
await server.listen();
const base = server.resolvedUrls.local[0];
const browser = await chromium.launch();

/* Deliberate exceptions, each documented where it is shown. */
const EXCLUDE = [
  ".sc-pill-demo--never", // the showcase's "Never: white on #F770E3" anti-example
];

/** Each target loads a page at 393 × 852, optionally opens a state, then audits `scope`. */
const TARGETS = [
  { name: "prototype welcome", url: "" },
  { name: "flow previews", url: "flows.html" },
  {
    name: "chat options menu",
    url: "flows.html",
    scope: "#chat",
    open: async (p) => p.locator("#chat").getByRole("button", { name: "Conversation options" }).click(),
  },
  {
    name: "unmatch sheet",
    url: "flows.html",
    scope: "#chat",
    open: async (p) => {
      await p.locator("#chat").getByRole("button", { name: "Conversation options" }).click();
      await wait(500);
      await p.locator("#chat").getByRole("button", { name: "Unmatch" }).first().click();
    },
  },
  { name: "design-system showcase", url: "showcase.html" },
];

let failed = 0;
try {
  for (const t of TARGETS) {
    const p = await (await browser.newContext({ viewport: { width: 393, height: 852 }, reducedMotion: "reduce" })).newPage();
    await p.goto(base + t.url);
    await wait(1200);
    if (t.open) {
      await t.open(p);
      await wait(700);
    }
    await p.addScriptTag({ content: AXE });
    const result = await p.evaluate(
      ([scope, exclude]) => window.axe.run({ include: [scope ?? "html"], exclude: exclude.map((s) => [s]) }, { runOnly: { type: "tag", values: ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"] } }),
      [t.scope ?? null, EXCLUDE],
    );
    const blocking = result.violations.filter((v) => ["serious", "critical"].includes(v.impact));
    const advisory = result.violations.filter((v) => !blocking.includes(v));
    console.log(`${blocking.length ? "✗" : "✓"} ${t.name}: ${result.passes.length} rules pass, ${blocking.length} serious/critical, ${advisory.length} advisory`);
    for (const v of result.violations) {
      console.log(`    ${v.impact}: ${v.id} — ${v.help} (${v.nodes.length})`);
      for (const n of v.nodes.slice(0, 4)) console.log(`      ${n.target.join(" ")} ${n.failureSummary?.split("\n")[1]?.trim() ?? ""}`);
    }
    failed += blocking.length;
    await p.context().close();
  }
} finally {
  await browser.close();
  await server.close();
}
console.log(failed ? `\n${failed} blocking accessibility violation(s).` : "\nNo serious or critical accessibility violations.");
process.exit(failed ? 1 : 0);
