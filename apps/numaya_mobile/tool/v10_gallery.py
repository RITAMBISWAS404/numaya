"""V10 review gallery: before (O), after (A) and the alternative (C) side by side, per scene.

    python tool/v10_gallery.py <renders-dir> <out-dir>

<renders-dir> is test/screenshots/v10 (written by test/screenshots/v10_capture_test.dart). The
gallery copies the PNGs it shows into <out-dir>/img and writes <out-dir>/index.html, a single
offline page. Reviewers type a note per scene. Notes stay in that browser (localStorage), and
the page can export them as JSON or Markdown and import a JSON export back in.

The PNGs contain private demo photos, so <out-dir> belongs in a local review folder, never in
Git.
"""

import html
import json
import shutil
import sys
from pathlib import Path

SCENES = [
    ("discover-1-top", "Discover, top"),
    ("discover-2-mid", "Discover, About sheet"),
    ("discover-3-low", "Discover, photos and prompts"),
    ("profile-1-top", "Own Profile, top"),
    ("profile-2-mid", "Own Profile, prompt and groups"),
    ("chat-1-active", "Chat, active conversation"),
    ("chat-2-received-compliment", "Chat, received Compliment"),
]
COLUMNS = [
    ("O", "Before (O, 42b8dba baseline)"),
    ("A", "After (A, People first, default)"),
    ("C", "Alternative (C, Editorial, lab only)"),
    ("A/stress_w320_x2.0", "After at 320pt, 200% text"),
]


def main() -> None:
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    img = out / "img"
    img.mkdir(parents=True, exist_ok=True)
    rows = []
    for scene, title in SCENES:
        figures = []
        for col, caption in COLUMNS:
            f = src / col / f"{scene}.png"
            if not f.exists():
                continue
            name = f"{col.replace('/', '_')}__{scene}.png"
            shutil.copyfile(f, img / name)
            figures.append(
                f'<figure><img loading="lazy" src="img/{name}" alt="{html.escape(caption)}: '
                f'{html.escape(title)}"><figcaption>{html.escape(caption)}</figcaption></figure>'
            )
        rows.append(
            f'<section data-scene="{scene}"><h2>{html.escape(title)}</h2>'
            f'<div class="row">{"".join(figures)}</div>'
            f'<label>Note<textarea data-note="{scene}" rows="3" '
            f'placeholder="Improved, equivalent or worse, and why"></textarea></label></section>'
        )
    page = TEMPLATE.replace("%ROWS%", "\n".join(rows)).replace(
        "%SCENES%", json.dumps([s for s, _ in SCENES])
    )
    (out / "index.html").write_text(page, encoding="utf-8")
    print(out / "index.html")


TEMPLATE = """<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Numaya V10 review</title>
<style>
:root{--bg:#f4f4f6;--fg:#16151c;--muted:#5c5a66;--card:#fff;--brand:#7262C7}
body{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:15px/1.4 system-ui,sans-serif}
header{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:16px}
h1{font-size:20px;margin:0 12px 0 0}h2{font-size:17px;margin:0 0 12px}
button,.file{font:inherit;padding:8px 14px;border-radius:999px;border:1px solid var(--brand);
background:var(--card);color:var(--brand);cursor:pointer}button.primary{background:var(--brand);color:#fff}
section{background:var(--card);border-radius:16px;padding:16px;margin-bottom:16px}
.row{display:flex;gap:16px;overflow-x:auto;padding-bottom:8px}
figure{margin:0;flex:0 0 260px}img{width:100%;border-radius:12px;display:block;border:1px solid #e3e3e8}
figcaption{color:var(--muted);font-size:13px;margin-top:6px}
label{display:block;margin-top:12px;font-weight:600}
textarea{display:block;width:100%;box-sizing:border-box;margin-top:6px;font:inherit;padding:8px;
border-radius:12px;border:1px solid #cfcfd6}
#status{color:var(--muted)}
</style>
<header><h1>Numaya V10: before, after, alternative</h1>
<button class="primary" id="json">Export JSON</button><button id="md">Export Markdown</button>
<label class="file">Import JSON<input id="imp" type="file" accept="application/json" hidden></label>
<span id="status" role="status"></span></header>
<p>Demo build renders: 393 × 852 at 3x, same fixtures and fonts in every column. Private demo photos: do not publish.</p>
%ROWS%
<script>
const SCENES = %SCENES%;
const KEY = "numaya-v10-review-notes";
const status = (t) => { document.getElementById("status").textContent = t; };
const load = () => { try { return JSON.parse(localStorage.getItem(KEY) || "{}"); } catch { return {}; } };
const save = (n) => { try { localStorage.setItem(KEY, JSON.stringify(n)); } catch {} };
const fields = () => [...document.querySelectorAll("textarea[data-note]")];
const collect = () => Object.fromEntries(fields().map((t) => [t.dataset.note, t.value]));
// Import merges: a scene missing from the file keeps the note already typed here.
const fill = (n) => fields().forEach((t) => { t.value = n[t.dataset.note] ?? t.value; });
fill(load());
fields().forEach((t) => t.addEventListener("input", () => save(collect())));
const download = (name, type, body) => {
  const a = document.createElement("a");
  a.href = URL.createObjectURL(new Blob([body], { type }));
  a.download = name; a.click(); URL.revokeObjectURL(a.href);
};
document.getElementById("json").onclick = () => {
  download("numaya-v10-notes.json", "application/json",
    JSON.stringify({ review: "numaya-v10", scenes: SCENES, notes: collect() }, null, 2));
  status("Exported JSON");
};
document.getElementById("md").onclick = () => {
  const n = collect();
  const md = ["# Numaya V10 review notes", ""].concat(
    SCENES.map((s) => `## ${document.querySelector(`[data-scene="${s}"] h2`).textContent}\\n\\n${n[s] || "(no note)"}\\n`));
  download("numaya-v10-notes.md", "text/markdown", md.join("\\n"));
  status("Exported Markdown");
};
document.getElementById("imp").onchange = async (e) => {
  const f = e.target.files[0]; if (!f) return;
  try {
    const data = JSON.parse(await f.text());
    if (data.review !== "numaya-v10" || typeof data.notes !== "object") throw new Error("not a V10 export");
    fill(data.notes); save(collect()); status(`Imported ${Object.keys(data.notes).length} notes`);
  } catch (err) { status(`Import failed: ${err.message}`); }
  e.target.value = "";
};
</script></html>
"""

if __name__ == "__main__":
    main()
