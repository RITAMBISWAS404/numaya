"""Builds the offline MVP Focus V5 selection gallery from real emulator captures.

Usage: python build_gallery.py --capture <dir> --before <dir> --extra f15=<dir> f20=<dir> n360=<dir>
  --commit <sha> --baseline <sha> --branch <name> --out <review dir>

Reuses the Visual Lab page (tool/visual_lab_gallery/template.html: localStorage, export JSON and
TXT, import validation, reset). Adds a major-screen index (baseline beside candidate) and QA
sections. Writes index.html, manifest.json, components/, screens/, major/, qa/ (JPEG, 720 px wide),
README.md and choices-example.json.
"""
import argparse, csv, datetime, json, os

from PIL import Image

ap = argparse.ArgumentParser()
for a in ('capture', 'before', 'commit', 'baseline', 'branch', 'out'):
    ap.add_argument('--' + a, required=True)
ap.add_argument('--extra', nargs='*', default=[])
args = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
out = args.out
for d in ('components', 'screens', 'qa', 'major/before', 'major/after'):
    os.makedirs(os.path.join(out, d), exist_ok=True)

M = 'https://mobbin.com/screens/'
METUP_DETAIL = M + 'ec972fea-0cf4-4006-a80c-a2de330fbdd5 (Meetup: image, title, icon-led date and venue rows)'
METUP_BAR = M + 'fa7b4936-53a7-421d-ac90-53ef110093c3 (Meetup: anchored status and action bar)'
METUP_FEED = M + 'e560b483-da2d-446e-b96d-ff99b2fd648c (Meetup: event rows with a photo)'
BUMBLE = M + 'ee54d57a-33f7-4f05-ba27-012f9f74eb48 (Bumble: name directly on the photo)'
ENTE_MEM = 'Figma 6352:38350 (Ente Memory card: white title over a bottom gradient; its 72% is above the owner cap)'
LAB_VARIANTS_COMPLIMENT = [{'id': v, 'name': n, 'pass': 'direction', 'note': t, 'tradeoff': t} for v, n, t in [('O', 'Sender, quote, actions', 'Avatar and name, the Compliment, Reply and Not now buttons.'), ('A', 'Quote-led editorial', 'The words lead in a large quote; sender and actions follow.'), ('B', 'With what they noticed', 'Shows the photo or prompt they complimented beside the words.'), ('C', 'Compact row', 'One row per Compliment; open it to reply.'), ('D', 'Photo-led', 'Their photo as the card’s top half; words on the white half.')]]
BUMBLE_SENT = M + 'b15493f3-1516-46b8-9c60-d86be2cce234 (Bumble: sent note, what happens next)'
V = lambda i, n, p, note, t: {'id': i, 'name': n, 'pass': p, 'note': note, 'tradeoff': t}
GROUPS = [
    {'id': 'v4-photo-label', 'title': 'Name over the first photo', 'kind': 'screen', 'proposed': 'G',
     'question': 'Is the name readable on any photo while the picture stays the subject?',
     'task': 'Recognise who this is on Discover and on a profile.',
     'problem': 'You asked for a smooth gradient instead of a dark name backing. A gradient under 25% cannot reach 4.5:1 on a pure white patch by itself.',
     'axis': 'Image first versus guaranteed contrast.',
     'references': [BUMBLE, ENTE_MEM],
     'variants': [
         V('O', 'Dark panel', 'baseline', 'The earlier solid 55% panel.', 'Very stable text; heavy on the image.'),
         V('G', 'Smooth gradient', 'V5 default (recommended)', 'Name straight on the photo, eased 24% gradient, soft text shadow.', 'The most photo; relies on the shadow over the brightest patches.'),
         V('P', 'Compact glass label', 'contrast', 'A hugging black glass label behind the name.', 'Guaranteed 4.74:1; adds a shape on the photo.'),
         V('B', 'Edge-to-edge glass bar', 'structure', 'A full-width glass strip along the foot of the photo.', 'Steady edge; covers more of the photo.'),
     ]},
    {'id': 'compliment-card', 'title': 'Received Compliment in Heart', 'kind': 'component', 'proposed': 'O',
     'question': 'What should lead a received Compliment: the person or their words?',
     'task': 'Decide which Compliment to open.', 'problem': 'Several earlier directions were never chosen.',
     'axis': 'Person first versus words first, and how much context.',
     'references': [BUMBLE_SENT],
     'variants': LAB_VARIANTS_COMPLIMENT},
    {'id': 'v4-welcome', 'title': 'Welcome brand area', 'kind': 'component', 'proposed': 'S',
     'question': 'Does the first screen feel confidently Numaya?',
     'task': 'First impression before signing up.', 'problem': 'Temporary brand art; a deliberate colour choice is still open.',
     'axis': 'Solid accent versus neutral.', 'references': ['Figma 10871:4420 (colours)'],
     'variants': [
         V('O', 'Lavender tint', 'baseline', 'Previous pale purple panel.', 'Soft; a decorative tint.'),
         V('S', 'Solid purple', 'V5 default (recommended)', 'White mark on the solid brand colour.', 'Strongest identity; the loudest option.'),
         V('N', 'Neutral page', 'quiet', 'Purple mark on the grey page.', 'Calm; less branded.'),
     ]},
]
for sid, title, q in [('screen-heart', 'Heart screen', 'How should Likes and Compliments share the Heart tab?'),
                      ('screen-chats', 'Chats screen', 'How should new matches and conversations be arranged?'),
                      ('screen-profile', 'Profile screen', 'What should lead the Profile tab?')]:
    GROUPS.append({'id': sid, 'title': title, 'kind': 'screen', 'proposed': 'O', 'question': q,
                   'task': 'Earlier layout direction, still undecided by you.',
                   'problem': 'Carried forward. The V5 spacing, gradient and surfaces apply to every option.',
                   'axis': 'Layout direction.', 'references': ['docs/design-experiments/visual-lab-v2/'],
                   'variants': [V(x, n, 'direction', 'Earlier direction, re-rendered with V5 surfaces.', 'See the V2 notes.')
                                for x, n in [('O', 'Current'), ('A', 'Direction A'), ('B', 'Direction B'), ('C', 'Direction C')]]})


def component_crop(im):
    """Removes the Lab's title and variant chips; keeps the component down to its last content row."""
    top, canvas = 530, (244, 244, 244)
    px = im.load()
    w, h = im.size
    last = top
    for y in range(top, h - 110):
        if any(px[x, y] != canvas for x in range(0, w, 12)):
            last = y
    return im.crop((0, top, w, min(h, last + 40)))


def to_jpeg(src, dst, crop=False):
    im = Image.open(src).convert('RGB')
    if crop:
        im = component_crop(im)
    w, h = im.size
    if w > 720:
        im = im.resize((720, round(h * 720 / w)), Image.LANCZOS)
    im.save(dst, 'JPEG', quality=86, optimize=True)


def rows(cap):
    with open(os.path.join(cap, 'shots.tsv'), encoding='utf-8') as f:
        for r in csv.DictReader(f, delimiter='\t'):
            p = os.path.join(cap, 'shots', r['file'])
            if os.path.exists(p) and os.path.getsize(p) > 1000:
                yield r, p


META = {'captureMethod': 'adb screencap, Pixel 10 AVD (API 36), debug build, integration_test',
        'viewport': '1080x2424 px, 411 dp, font scale 1.0 unless labelled'}
shots = []
ids = {g['id'] for g in GROUPS}
for r, p in rows(args.capture):
    name = r['file'].split('__', 1)[-1].replace('.png', '.jpg')
    if r['group'] in ids:
        sub = 'components' if r['kind'] == 'crop' else 'screens'
        to_jpeg(p, os.path.join(out, sub, name), crop=r['kind'] == 'crop')
        shots.append({'id': f'{sub}/{name[:-4]}', 'path': f'{sub}/{name}', 'family': r['group'],
                      'variant': r['variant'], 'kind': r['kind'], 'label': r['label'], **META})
    elif r['group'] == 'major':
        to_jpeg(p, os.path.join(out, 'major/after', name))
    else:
        to_jpeg(p, os.path.join(out, 'qa', name))
        shots.append({'id': f'qa/{name[:-4]}', 'path': f'qa/{name}', 'family': 'default', 'variant': r['variant'],
                      'kind': 'qa', 'label': r['label'], **META})
major = []
for r, p in rows(args.before):
    if r['group'] != 'major':
        continue
    name = r['file'].split('__', 1)[-1].replace('.png', '.jpg')
    to_jpeg(p, os.path.join(out, 'major/before', name))
    if os.path.exists(os.path.join(out, 'major/after', name)):
        major.append({'name': name, 'label': r['label'], 'before': f'major/before/{name}', 'after': f'major/after/{name}'})
LABELS = {'f15': 'font size 1.5', 'f20': 'font size 2.0', 'n360': '360 dp wide'}
for spec in args.extra:
    tag, cap = spec.split('=', 1)
    for r, p in rows(cap):
        name = f"{tag}-{r['file'].split('__', 1)[-1].replace('.png', '.jpg')}"
        to_jpeg(p, os.path.join(out, 'qa', name))
        shots.append({'id': f'qa/{name[:-4]}', 'path': f'qa/{name}', 'family': 'large-text', 'variant': tag, 'kind': 'qa',
                      'label': f"{r['label']} ({LABELS.get(tag, tag)})", **META})

missing = [f"{g['id']} {v['id']}" for g in GROUPS for v in g['variants']
           if not any(s['family'] == g['id'] and s['variant'] == v['id'] for s in shots)]
generated = datetime.datetime.now().astimezone().replace(microsecond=0).isoformat()
review_id = f"v5-{args.commit[:7]}-{generated[:10]}"
manifest = {'schemaVersion': 1, 'reviewId': review_id, 'baselineCommit': args.baseline, 'codeCommit': args.commit,
            'branch': args.branch, 'generatedAt': generated, 'groups': GROUPS, 'dependencies': {}, 'compatibility': {},
            'a11y': {g['id']: ('320 dp and 200% text checked by the V4 widget test' if g['id'].startswith('v4-')
                                else 'Covered by the earlier Lab tests (V2 and V3 records); not re-checked separately in V4')
                     for g in GROUPS},
            'screenshots': shots, 'major': major, 'videos': [], 'missingItems': missing}
json.dump(manifest, open(os.path.join(out, 'manifest.json'), 'w', encoding='utf-8'), indent=2)

tpl = open(os.path.join(here, '..', 'visual_lab_gallery', 'template.html'), encoding='utf-8').read()
subs = [
    ("const KEY = 'numaya-visual-lab-v2:'", "const KEY = 'numaya-mvp-v5:'"),
    ('<h1>Numaya Visual Lab V2</h1>', '<h1>Numaya MVP V5 choices</h1>'),
    ('<title>Numaya Visual Lab V2: review gallery</title>', '<title>Numaya MVP V5 Choices</title>'),
    ('Keep current (O)</label>', 'Keep baseline (O)</label>'),
    ('numaya-visual-lab-choices-', 'numaya-mvp-v5-choices-'),
    ('numaya-visual-lab-summary-', 'numaya-mvp-v5-summary-'),
    ('Numaya Visual Lab V2 choices', 'Numaya MVP V5 choices'),
    ("<h3>${kind==='component'?'Card families':kind==='screen'?'Screens':'Motion'}</h3>",
     "<h3>${kind==='component'?'Components':kind==='screen'?'Screen layouts':'Motion'}</h3>"),
    ("for (const kind of ['component','screen','motion']) {", "for (const kind of ['component','screen']) {"),
    ('selectedAt: state.selectedAt, selections:', 'selectedAt: state.selectedAt, exportedAt: new Date().toISOString(), selections:'),
    ('<span class="badge prop">Proposed (not approved)</span>', '<span class="badge prop">Candidate default (not approved)</span>'),
]
for a, b in subs:
    assert a in tpl, a[:60]
    tpl = tpl.replace(a, b)
a = tpl.index("if (!Object.keys(state.selections).length && !confirm(")
b = tpl.index("{", tpl.index("return;", a)) if False else tpl.index("return;", a) + len("return;")
tpl = tpl[:a] + ("if (Object.keys(state.selections).length===0 && !confirm('No designs selected.\\n\\nEvery group is still Undecided: nothing will be applied. Export an all-undecided file anyway?')) return;") + tpl[b:]
a = tpl.index('  <section class="group" id="intro">')
b = tpl.index('</main>')
tpl = tpl[:a] + '''  <section class="group" id="intro">
    <h2>How to review</h2>
    <p><b>Choose only the layout questions below.</b> The spacing, surfaces and gradient are already in every option. The app works without opening this page: it only holds choices that are a matter of taste. Each group shows the baseline <b>O</b> beside the alternatives on identical data. The candidate default is labelled but is not an approval: leave anything Undecided and it stays as built.</p>
    <p>All images are real Flutter screens from a Pixel 10 emulator (API 36, 1080 × 2424, 411 dp, font 1.0 unless labelled). Nothing here is an HTML mock-up. Choices save in this browser. Export JSON and send it back; the TXT is a readable summary. Import restores an export from this same review and refuses anything else.</p>
  </section>
  <div id="groups"></div>
  <section class="group" id="evidence"><h2>Name on bright, dark and busy photos</h2><div class="gallery" id="evGallery"></div></section>
  <section class="group" id="large"><h2>Font size 1.5 and 2.0; 360 dp width</h2><div class="gallery" id="ltGallery"></div></section>
  <div hidden><div id="scGallery"></div><div id="histGallery"></div><div id="clipGrid"></div></div>
''' + tpl[b:]
tpl = tpl.replace("<p class=\"q\">${esc(g.question)}</p>`;",
                  "<p class=\"q\">${esc(g.question)}</p><p class=\"meta\"><b>Task:</b> ${esc(g.task)} <b>Problem:</b> ${esc(g.problem)} <b>Axis:</b> ${esc(g.axis)}</p><p class=\"meta\"><b>References:</b> ${(g.references||[]).map(esc).join(' · ')}</p>`;", 1)
tpl = tpl.replace('<div class="note">${esc(v.note)}</div>', '<div class="note">${esc(v.note)}</div><div class="note"><i>Tradeoff:</i> ${esc(v.tradeoff||\'\')}</div>', 1)
tpl = tpl.replace("load(); render();", """load(); render();
document.getElementById('majorGrid').innerHTML = (MANIFEST.major||[]).map(m=>`<div style="margin:14px 0"><h4 style="margin:0 0 6px">${esc(m.label)}</h4><div class="gallery" style="display:flex;gap:10px;flex-wrap:wrap">${img({path:m.before,label:m.label+' baseline'},'Baseline')}${img({path:m.after,label:m.label+' candidate'},'V4 candidate')}</div></div>`).join('') || '<p class="meta">None.</p>';""", 1)
html = tpl.replace('__MANIFEST__', json.dumps(manifest).replace('</', '<\\/'))
open(os.path.join(out, 'index.html'), 'w', encoding='utf-8').write(html)

json.dump({'schemaVersion': 1, 'reviewId': review_id, 'codeCommit': args.commit, 'generatedAt': generated,
           'exportedAt': None, 'selections': [], 'undecidedGroups': [g['id'] for g in GROUPS],
           'notesWithoutSelection': {}, '_exampleOnly': 'Shape only. Not owner selections.'},
          open(os.path.join(out, 'choices-example.json'), 'w', encoding='utf-8'), indent=2)
open(os.path.join(out, 'README.md'), 'w', encoding='utf-8').write(
    f"# Numaya MVP V5 choices\n\nOpen index.html. Review {review_id}, code {args.commit}, baseline {args.baseline}, branch {args.branch}.\n"
    "Choose per group, Export JSON, and send it back. Local only: the images show private demo photos.\n")
print(json.dumps({'reviewId': review_id, 'screenshots': len(shots), 'major': len(major), 'missing': missing}, indent=1))
