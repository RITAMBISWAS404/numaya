// Generates the locally bundled demo "photos" for the flow previews (src/flows/assets/scenes/*.svg).
// Scenic illustrations of a person seen from behind: photography-led layouts without real or
// identifiable people, and without external image hosts. Run: node scripts/demo-scenes.mjs
import { mkdirSync, writeFileSync } from "node:fs";

const OUT = "src/flows/assets/scenes";
const W = 600;
const H = 800;

const grad = (id, stops, x2 = 0, y2 = 1) =>
  `<linearGradient id="${id}" x1="0" y1="0" x2="${x2}" y2="${y2}">${stops
    .map(([o, c, a = 1]) => `<stop offset="${o}" stop-color="${c}" stop-opacity="${a}"/>`)
    .join("")}</linearGradient>`;

// Seeded random so the files are stable between runs.
function rng(seed) {
  let s = seed;
  return () => ((s = (s * 16807) % 2147483647) - 1) / 2147483646;
}

const bokeh = (seed, n, colors, yMin, yMax, rMin, rMax, op = 0.55) => {
  const r = rng(seed);
  return Array.from({ length: n }, () => {
    const c = colors[Math.floor(r() * colors.length)];
    return `<circle cx="${(r() * W).toFixed(0)}" cy="${(yMin + r() * (yMax - yMin)).toFixed(0)}" r="${(rMin + r() * (rMax - rMin)).toFixed(0)}" fill="${c}" opacity="${(op * (0.4 + r() * 0.6)).toFixed(2)}"/>`;
  }).join("");
};

/** A person from behind: hair, neck, shoulders; slightly off centre like a candid photo. */
function figure({ x = 300, y = 520, scale = 1, tone = "#1b1d24", rim = "#ffffff", rimOp = 0.25, hair = "long" }) {
  const hairPath =
    hair === "long"
      ? "M-58,-120 C-62,-190 -30,-232 0,-232 C30,-232 62,-190 58,-120 C60,-70 66,-30 72,10 L-72,10 C-66,-30 -60,-70 -58,-120 Z"
      : hair === "bun"
        ? "M-52,-130 C-56,-190 -28,-222 0,-222 C28,-222 56,-190 52,-130 C50,-100 44,-84 38,-74 L-38,-74 C-44,-84 -50,-100 -52,-130 Z M-22,-236 a22,20 0 1,0 44,0 a22,20 0 1,0 -44,0"
        : "M-50,-128 C-54,-186 -26,-216 0,-216 C26,-216 54,-186 50,-128 C48,-104 42,-90 36,-80 L-36,-80 C-42,-90 -48,-104 -50,-128 Z";
  return `<g transform="translate(${x},${y}) scale(${scale})">
  <path d="M-30,-90 L30,-90 L34,-40 L-34,-40 Z" fill="${tone}"/>
  <path d="M-150,300 C-150,120 -120,-30 -40,-50 L40,-50 C120,-30 150,120 150,300 Z" fill="${tone}"/>
  <path d="${hairPath}" fill="${tone}"/>
  <path d="M-150,300 C-150,120 -120,-30 -40,-50" fill="none" stroke="${rim}" stroke-opacity="${rimOp}" stroke-width="3"/>
  <path d="M-58,-120 C-62,-190 -30,-232 0,-232" fill="none" stroke="${rim}" stroke-opacity="${rimOp}" stroke-width="3"/>
</g>`;
}

const svg = (defs, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" preserveAspectRatio="xMidYMid slice"><defs>${defs}<filter id="b" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="14"/></filter><filter id="b2"><feGaussianBlur stdDeviation="5"/></filter>${grad("v", [[0, "#000", 0], [0.6, "#000", 0], [1, "#000", 0.35]])}</defs>${body}<rect width="${W}" height="${H}" fill="url(#v)"/></svg>`;

const SCENES = {
  "city-dusk": svg(
    grad("s", [[0, "#2c3356"], [0.45, "#7b6aa6"], [0.8, "#f2a98a"], [1, "#f6c99b"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <g filter="url(#b2)" fill="#22243a">${[[0, 430, 90], [80, 380, 70], [150, 450, 60], [210, 340, 80], [300, 410, 70], [370, 360, 90], [460, 440, 60], [520, 390, 80]].map(([x, y, w]) => `<rect x="${x}" y="${y}" width="${w}" height="${H}"/>`).join("")}</g>
     <g filter="url(#b2)">${bokeh(7, 60, ["#ffd59a", "#ffe9c4"], 360, 620, 2, 4, 0.9)}</g>
     ${figure({ x: 330, y: 560, tone: "#15161f", rim: "#f6c99b", rimOp: 0.5 })}`,
  ),
  beach: svg(
    grad("s", [[0, "#7cc0e8"], [0.55, "#cfe9f6"], [1, "#f4f1e8"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <circle cx="430" cy="210" r="60" fill="#fff6dc" filter="url(#b)"/>
     <rect y="420" width="${W}" height="120" fill="#3e8fb6"/><rect y="420" width="${W}" height="16" fill="#9fd0e6" opacity=".7"/>
     <rect y="530" width="${W}" height="270" fill="#e9d6b0"/>
     ${figure({ x: 260, y: 580, tone: "#2b2a33", hair: "long", rim: "#fff6dc", rimOp: 0.45 })}`,
  ),
  mountains: svg(
    grad("s", [[0, "#b9d5ec"], [1, "#f3efe6"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <path d="M0,430 L120,300 L210,380 L330,240 L460,370 L600,280 L600,800 L0,800 Z" fill="#8aa3bf"/>
     <path d="M330,240 L370,285 L345,282 L322,300 L300,275 Z M120,300 L150,330 L120,326 L100,322 Z" fill="#f4f6f9"/>
     <path d="M0,520 L160,420 L300,500 L440,430 L600,510 L600,800 L0,800 Z" fill="#5d7690"/>
     <path d="M0,610 L200,560 L380,620 L600,580 L600,800 L0,800 Z" fill="#3f5266"/>
     ${figure({ x: 360, y: 600, tone: "#1d222b", hair: "short", rim: "#ffffff", rimOp: 0.3 })}`,
  ),
  cafe: svg(
    grad("s", [[0, "#5b3d2b"], [0.6, "#3a281e"], [1, "#22180f"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <rect x="360" y="60" width="200" height="300" rx="6" fill="#f3d9a8" opacity=".55" filter="url(#b)"/>
     <g filter="url(#b)">${bokeh(11, 22, ["#f7c36b", "#ffdca0", "#e89a4b"], 40, 420, 14, 40, 0.6)}</g>
     <rect y="560" width="${W}" height="240" fill="#2a1c13"/>
     ${figure({ x: 240, y: 590, tone: "#120d0a", hair: "bun", rim: "#f7c36b", rimOp: 0.55 })}`,
  ),
  park: svg(
    grad("s", [[0, "#cfe6f2"], [0.5, "#e8f1e4"], [1, "#7fa36b"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <g filter="url(#b)">${bokeh(5, 18, ["#5f8f4e", "#7aa860", "#4b7a3d"], 120, 420, 50, 110, 0.85)}</g>
     <rect y="520" width="${W}" height="280" fill="#6e9a58"/>
     ${figure({ x: 300, y: 570, tone: "#24262c", hair: "long", rim: "#fff", rimOp: 0.3 })}`,
  ),
  "jazz-bar": svg(
    grad("s", [[0, "#1b1a2b"], [1, "#0e0d16"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     <path d="M200,0 L400,0 L520,520 L80,520 Z" fill="#f1b76a" opacity=".18" filter="url(#b)"/>
     <g filter="url(#b)">${bokeh(3, 26, ["#f1b76a", "#d2694f", "#f6d6a0"], 60, 480, 10, 34, 0.55)}</g>
     ${figure({ x: 320, y: 600, tone: "#07070b", hair: "short", rim: "#f1b76a", rimOp: 0.6 })}`,
  ),
  museum: svg(
    grad("s", [[0, "#f1ece4"], [1, "#d9d1c4"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     ${[60, 250, 440].map((x) => `<path d="M${x},560 L${x},210 a50,50 0 0,1 100,0 L${x + 100},560 Z" fill="#c6bba9"/><path d="M${x + 10},560 L${x + 10},215 a40,40 0 0,1 80,0 L${x + 90},560 Z" fill="#efe8dc"/>`).join("")}
     <rect y="560" width="${W}" height="240" fill="#bfb29e"/>
     ${figure({ x: 290, y: 600, tone: "#2a2724", hair: "bun", rim: "#fff", rimOp: 0.25 })}`,
  ),
  market: svg(
    grad("s", [[0, "#a9d4ef"], [1, "#f7efe2"]]),
    `<rect width="${W}" height="${H}" fill="url(#s)"/>
     ${[["#e8b4a0", 0, 180], ["#f1d39a", 150, 140], ["#b9cbb0", 270, 200], ["#e7c2c8", 430, 170]].map(([c, x, y]) => `<rect x="${x}" y="${y}" width="170" height="${H}" fill="${c}"/>`).join("")}
     ${[0, 150, 270, 430].map((x, i) => `<path d="M${x},${360 + i * 6} l170,0 l-12,40 l-146,0 Z" fill="${["#c44f45", "#2f6d8f", "#c44f45", "#2f6d8f"][i]}" opacity=".85"/>`).join("")}
     <rect y="560" width="${W}" height="240" fill="#cfc6b8"/>
     ${figure({ x: 300, y: 580, tone: "#23252d", hair: "long", rim: "#fff", rimOp: 0.3 })}`,
  ),
};

mkdirSync(OUT, { recursive: true });
for (const [name, content] of Object.entries(SCENES)) writeFileSync(`${OUT}/${name}.svg`, content.replace(/\n\s*/g, ""));
console.log(`Wrote ${Object.keys(SCENES).length} scenes → ${OUT}`);
