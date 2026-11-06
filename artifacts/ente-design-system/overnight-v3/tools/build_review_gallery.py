"""Build a portable, no-server review gallery from actual captures.

Usage: python build_review_gallery.py review-manifest.json output-directory
Manifest image paths are relative to its parent directory and must stay inside it.
This tool makes no app screenshots. Claude must capture and visually review them.
"""
import argparse
import hashlib
import html
import json
from pathlib import Path
import shutil


def build(manifest_path, output):
    manifest_path = Path(manifest_path).resolve()
    base = manifest_path.parent
    data = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
    output = Path(output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    assets = output / "assets"
    assets.mkdir(exist_ok=True)
    esc = lambda v: html.escape(str(v), quote=True)
    used_ids = set()
    selection_ids = []

    def asset(raw):
        path = Path(raw)
        if path.is_absolute() or ":" in raw or "\\" in raw:
            raise ValueError(f"Use a relative forward-slash image path: {raw}")
        path = (base / path).resolve()
        if not path.is_relative_to(base):
            raise ValueError(f"Image escapes manifest directory: {raw}")
        if path.suffix.lower() not in (".png", ".jpg", ".jpeg", ".webp"):
            raise ValueError(f"Unsupported capture format: {raw}")
        if not path.is_file():
            raise FileNotFoundError(path)
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        target = assets / (digest + path.suffix.lower())
        if not target.exists():
            shutil.copy2(path, target)
        return "assets/" + target.name

    def pictures(paths, caption):
        if not isinstance(paths, list) or not paths:
            raise ValueError(f"At least one actual image is required: {caption}")
        result = []
        for number, path in enumerate(paths, 1):
            url = asset(path)
            result.append(f'<a href="{url}" target="_blank" rel="noopener"><img loading="lazy" src="{url}" alt="{esc(caption)} — capture {number}"></a>')
        return "".join(result)

    blocks = []
    for item in data.get("experiments", []):
        eid = str(item["id"])
        if eid in used_ids:
            raise ValueError(f"Duplicate experiment ID: {eid}")
        used_ids.add(eid)
        selection_ids.append(eid)
        variants = item["variants"]
        if set(variants) != {"Current", "A", "B", "C"}:
            raise ValueError(f"{eid}: variants must contain Current, A, B and C")
        cards = []
        for key in ("Current", "A", "B", "C"):
            variant = variants[key]
            captures = pictures(variant["images"], f"{eid} {key} {variant['name']}")
            cards.append(f'''<article class="variant"><h3>{esc(key)} · {esc(variant['name'])}</h3>
            <p>{esc(variant.get('rationale',''))}</p>{captures}
            <label class="pick"><input type="radio" name="{esc(eid)}" value="{key}"> Choose {esc(key)}</label></article>''')
        extra = ""
        if item.get("refined_control_images"):
            extra = '<details><summary>Refined control — same layout, corrected components</summary><div class="control">' + pictures(item["refined_control_images"], eid + " refined control") + '</div></details>'
        blocks.append(f'''<section class="entry experiment" data-id="{esc(eid)}">
        <h2>{esc(eid)} · {esc(item['title'])}</h2><p>{esc(item.get('task',''))}</p>
        <p class="meta">{esc(item.get('capture_context',''))}</p>
        <p>Recommendation (not selected): {esc(item.get('recommendation','Pending review'))}</p>
        <div class="options">{''.join(cards)}</div>{extra}
        <label>Notes for {esc(eid)}<textarea data-notes="{esc(eid)}" rows="2"></textarea></label>
        <button type="button" class="clear" data-id="{esc(eid)}">Clear this choice</button></section>''')
    for item in data.get("screens", []):
        images = pictures(item["images"], item["title"])
        blocks.append(f'''<section class="entry screen"><h2>{esc(item['title'])}</h2>
        <p class="meta">{esc(item.get('capture_context',''))}</p><div class="screen-images">{images}</div></section>''')
    if not blocks:
        blocks.append('<p>No captures supplied. This is an empty gallery, not completed review evidence.</p>')
    settings = json.dumps({"run_id": data.get("run_id", "numaya-v3"), "ids": selection_ids}, ensure_ascii=True).replace("<", "\\u003c")
    document = '''<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Numaya V3 review</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#f5f3f8;color:#231d30;font:16px/1.5 system-ui,sans-serif}
header,main{max-width:1600px;margin:auto;padding:24px}header{background:#fff;border-bottom:1px solid #ddd7e6}
h1{margin:0 0 12px}h2{font-size:22px}h3{font-size:17px}.meta{color:#625a6b;font-size:14px}
button,input,select,textarea{font:inherit}button,select,input[type=search]{min-height:44px;padding:8px 12px;border:1px solid #8e849d;border-radius:8px;background:white;color:#231d30}
button{cursor:pointer}button:focus-visible,a:focus-visible,input:focus-visible,textarea:focus-visible{outline:3px solid #6b42b8;outline-offset:3px}
.toolbar{display:flex;gap:12px;flex-wrap:wrap;align-items:center}.entry{margin:0 0 32px;background:white;border:1px solid #d8d1e2;border-radius:16px;padding:20px}
.options{display:grid;grid-template-columns:repeat(4,minmax(230px,1fr));gap:16px;overflow-x:auto;padding:8px 0 16px}
.variant{min-width:0;border:1px solid #ddd7e6;border-radius:12px;padding:12px}.variant p{min-height:48px;font-size:14px}
img{display:block;width:100%;height:auto;border-radius:8px;margin:12px 0}.pick{display:block;padding:12px 0;font-weight:600}.pick input{width:20px;height:20px;vertical-align:middle}
textarea{display:block;width:100%;border:1px solid #8e849d;border-radius:8px;margin:8px 0 12px;padding:8px}
.screen-images,.control{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,360px));gap:16px}summary{cursor:pointer;padding:12px 0}
[hidden]{display:none!important}#export{background:#59398c;color:white}small{display:block;margin-top:12px}
@media(max-width:600px){header,main{padding:16px}.entry{padding:12px}.options{grid-template-columns:repeat(4,260px)}}
</style></head><body><header><h1>Numaya · V3 review</h1>
<p>Compare the original Current with A/B/C. Open images at full resolution. Choices remain pending until you select them.</p>
<p>Export your choices before closing this page. Nothing is sent online or automatically applied to the app.</p>
<div class="toolbar"><label>Search <input id="search" type="search" placeholder="Experiment, screen or flow"></label>
<label>Show <select id="mode"><option value="all">Everything</option><option value="experiment">Experiments</option><option value="screen">Screen inventory</option></select></label>
<button id="export" type="button">Export choices JSON</button></div><small id="status" role="status" aria-live="polite"></small></header>
<main>''' + "\n".join(blocks) + '''</main><script>
const config = ''' + settings + ''';
function filter(){const q=document.querySelector('#search').value.toLowerCase();const mode=document.querySelector('#mode').value;let n=0;document.querySelectorAll('.entry').forEach(e=>{e.hidden=!(e.textContent.toLowerCase().includes(q)&&(mode==='all'||e.classList.contains(mode)));if(!e.hidden)n++;});document.querySelector('#status').textContent=n+' sections shown; '+document.querySelectorAll('input[type=radio]:checked').length+' choices selected.';}
document.querySelector('#search').addEventListener('input',filter);document.querySelector('#mode').addEventListener('change',filter);document.addEventListener('change',filter);
document.querySelectorAll('.clear').forEach(b=>b.addEventListener('click',()=>{const s=b.closest('.experiment');s.querySelectorAll('input[type=radio]').forEach(r=>r.checked=false);filter();}));
document.querySelector('#export').addEventListener('click',()=>{const choices=config.ids.map(id=>{const section=Array.from(document.querySelectorAll('.experiment')).find(s=>s.dataset.id===id);return {experiment_id:id,selected_variant:section.querySelector('input[type=radio]:checked')?.value??null,notes:section.querySelector('textarea').value};});const payload={run_id:config.run_id,exported_at:new Date().toISOString(),choices};const url=URL.createObjectURL(new Blob([JSON.stringify(payload,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download='NUMAYA_V3_CHOICES.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);});filter();
</script></body></html>'''
    (output / "index.html").write_text(document, encoding="utf-8")
    return output / "index.html"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest")
    parser.add_argument("output")
    args = parser.parse_args()
    print(build(args.manifest, args.output))
