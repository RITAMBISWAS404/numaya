"""Builds the offline Ente Alignment Lab V3 selection gallery from a capture run.

Usage: python build_gallery.py --capture <dir with shots.tsv and shots/> --commit <sha>
  --baseline <sha> --branch <name> --out <review dir>

Reuses the Visual Lab V2 page (tool/visual_lab_gallery/template.html: localStorage, export, import
validation, reset) with V3 storage key, titles, sections and a prominent zero-selection warning.
Writes index.html, manifest.json, components/, screens/, qa/ (JPEG, 720 px wide), README.md and
choices-example.json. Groups mirror lib/features/lab/lab_registry.dart (ids starting `ea-`).
"""
import argparse, csv, datetime, json, os

from PIL import Image

ap = argparse.ArgumentParser()
for a in ('capture', 'commit', 'baseline', 'branch', 'out'):
    ap.add_argument('--' + a, required=True)
args = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
out = args.out
for d in ('components', 'screens', 'qa'):
    os.makedirs(os.path.join(out, d), exist_ok=True)

M = 'https://mobbin.com/screens/'
GROUPS = [
    {'id': 'ea-event-card', 'title': 'Event card (feed)', 'kind': 'component', 'proposed': 'O',
     'question': 'Can a member tell what, when and where at a glance, and scan several events?',
     'task': 'Pick an event worth going to from the city feed.',
     'problem': 'Every card is cover-led and tall: two events per screen, and Free and availability repeat as equal badges.',
     'axis': 'Density and hierarchy (what leads: picture, date or title).',
     'references': [M + '22bd5dea-485c-472e-98cc-0b82f26aa701 (Apple Music: date badge on a thumbnail)',
                    M + '8c3a2265-dda7-4b61-a699-227858eefc73 (Lightyear: date tile leads)',
                    M + '0691edb9-4486-4b03-b4ad-11c72485e8f7 (Swiggy: square cover rows)'],
     'variants': [
         {'id': 'O', 'name': 'Cover-led card', 'pass': 'baseline', 'note': 'Current: wide cover, title, date line, place line, Free and availability badges.', 'tradeoff': 'Imagery-first; about two events per screen.'},
         {'id': 'A', 'name': 'Compact row', 'pass': 'density', 'note': 'Square category thumbnail; date, title, place; about twice as many events per screen.', 'tradeoff': 'Cover art becomes a small mark; less atmosphere.'},
         {'id': 'B', 'name': 'Date-led', 'pass': 'hierarchy', 'note': 'A tinted date tile leads; time and place share one line; no cover.', 'tradeoff': 'Scans like a calendar; no imagery at all.'},
         {'id': 'C', 'name': 'Cover with date chip', 'pass': 'structure', 'note': 'Date chip on the cover; one merged "Free · availability" badge; fewer labels.', 'tradeoff': 'Same height as O; date competes with the cover.'}]},
    {'id': 'ea-event-filters', 'title': 'Event filters (feed)', 'kind': 'screen', 'proposed': 'O',
     'question': 'Can a member change city, date and activity without a crowded header?',
     'task': 'Narrow the feed to a city, a date range and an activity.',
     'problem': 'A full-width city field plus two pill rows push the first event below the fold.',
     'axis': 'Header density (how many rows the filters take).',
     'references': [M + 'c5ef6ad8-7fa5-48a5-b1d8-135abf1dd8c4 (DICE: compact filters)', M + 'ce86d8f6-0d1c-4fa5-8d76-0288b648a4a8 (StubHub: search and filters)'],
     'variants': [
         {'id': 'O', 'name': 'City field and two pill rows', 'pass': 'baseline', 'note': 'Current: city field, then date pills, then activity pills.', 'tradeoff': 'Every option visible; three rows tall.'},
         {'id': 'A', 'name': 'One row of dropdown chips', 'pass': 'density', 'note': 'City, date and activity as Ente disclosure chips on one row; each opens a picker sheet.', 'tradeoff': 'One row; changing date or activity takes one more tap.'},
         {'id': 'B', 'name': 'City chip with date pills', 'pass': 'hierarchy', 'note': 'City becomes the first chip of the date row; activity pills stay below.', 'tradeoff': 'Two rows; date pills scroll on narrow phones.'}]},
    {'id': 'ea-event-action', 'title': 'Event detail action bar', 'kind': 'screen', 'proposed': 'O',
     'question': 'Is price and availability clear at the moment of reserving?',
     'task': 'Reserve a free place from the event page.',
     'problem': 'The pinned button says "free" but availability is only in the body above.',
     'axis': 'Information at the point of action.',
     'references': [M + 'a108ecf2-3f28-407a-a030-aeccf8ff8d11 (Insight Timer: price and places with Reserve)', M + '006cedf3-df91-4ecb-a875-87426d73603c (Trainline: summary and Continue)'],
     'variants': [
         {'id': 'O', 'name': 'Full-width button', 'pass': 'baseline', 'note': 'Current: one full-width primary pinned at the bottom (Ente Button Large).', 'tradeoff': 'Largest target; no availability at the point of action.'},
         {'id': 'A', 'name': 'Summary and button', 'pass': 'hierarchy', 'note': 'Free and places left on the left; a compact "Reserve" on the right.', 'tradeoff': 'Departs from Ente\'s full-width Button Large on pages.'},
         {'id': 'B', 'name': 'Availability line above', 'pass': 'data', 'note': 'A one-line "Free · places left" note above the full-width button.', 'tradeoff': 'Keeps the Ente button; the bar grows by one line.'}]},
    {'id': 'ea-met-card', 'title': 'People I met card', 'kind': 'component', 'proposed': 'O',
     'question': 'Can a member decide on each person calmly, with the actions clearly paired?',
     'task': 'Send private interest to, or pass on, people from a past event.',
     'problem': 'Fixed for every option: Pass and Interested were content-width and far apart (now equal width, 12pt gap). Open question: how much each person should lead.',
     'axis': 'Imagery versus density.',
     'references': [M + 'b0b5ab9f-b79d-404d-b79a-f0971b3da3c6 (Hinge: photo cards)', M + '7aea9888-2e9a-4bf8-b3f6-51516e86b2f6 (Bumble: photo card with a heart action)'],
     'variants': [
         {'id': 'O', 'name': 'Row with paired buttons', 'pass': 'baseline', 'note': 'Current, aligned: photo, name, chevron; Pass and Interested as an equal-width group.', 'tradeoff': 'Clear labelled actions; four people per screen.'},
         {'id': 'A', 'name': 'Photo card', 'pass': 'structure', 'note': 'A large 4:3 photo leads, the name under it; the paired buttons below.', 'tradeoff': 'Most personal; about one person per screen.'},
         {'id': 'B', 'name': 'Compact row with icon actions', 'pass': 'density', 'note': 'One row: photo, name, then labelled round Pass (x) and Interested (heart) controls.', 'tradeoff': 'Whole list at a glance; icons carry the action (labels are spoken, not shown).'}]},
]

def to_jpeg(src, dst):
    im = Image.open(src).convert('RGB')
    w, h = im.size
    if w > 720:
        im = im.resize((720, round(h * 720 / w)), Image.LANCZOS)
    im.save(dst, 'JPEG', quality=86, optimize=True)

shots = []
with open(os.path.join(args.capture, 'shots.tsv'), encoding='utf-8') as f:
    for row in csv.DictReader(f, delimiter='\t'):
        src = os.path.join(args.capture, 'shots', row['file'])
        if not os.path.exists(src) or os.path.getsize(src) < 1000:
            continue
        kind = row['kind']
        sub = {'crop': 'components', 'screen': 'screens'}.get(kind, 'qa')
        name = row['file'].split('__', 1)[-1].replace('.png', '.jpg')
        to_jpeg(src, os.path.join(out, sub, name))
        family = row['group']
        if family == 'qa':
            family = 'large-text' if row['variant'] == 'large' else 'default'
        shots.append({'id': f'{sub}/{name[:-4]}', 'path': f'{sub}/{name}', 'family': family,
                      'variant': row['variant'], 'kind': kind, 'label': row['label'],
                      'textScale': float(row['textScale']),
                      'viewport': '1080x2424 px Pixel 10 emulator (411 dp; large-text shots at 360 dp)',
                      'captureMethod': 'adb screencap, API 36 emulator, debug build, integration_test'})

missing = []
for g in GROUPS:
    for v in g['variants']:
        if not any(s['family'] == g['id'] and s['variant'] == v['id'] for s in shots):
            missing.append(f"{g['id']} {v['id']}: no screenshot")

generated = datetime.datetime.now().astimezone().replace(microsecond=0).isoformat()
review_id = f"ea3-{args.commit[:7]}-{generated[:10]}"
manifest = {
    'schemaVersion': 1, 'reviewId': review_id, 'baselineCommit': args.baseline, 'codeCommit': args.commit,
    'branch': args.branch, 'generatedAt': generated, 'groups': GROUPS,
    'dependencies': {'ea-event-card': 'Also used in E02 "Other events" when an event is full.',
                     'ea-event-filters': 'Independent of the card choice.',
                     'ea-event-action': 'Only the "Reserve" state; "View your reservation" is unchanged.',
                     'ea-met-card': 'Every option keeps the same private actions, allowance and states.'},
    'compatibility': {},
    'a11y': {g['id']: 'Checked at 320 dp and 200% text (widget test)' for g in GROUPS},
    'screenshots': shots, 'videos': [], 'missingItems': missing,
}
json.dump(manifest, open(os.path.join(out, 'manifest.json'), 'w', encoding='utf-8'), indent=2)

tpl = open(os.path.join(here, '..', 'visual_lab_gallery', 'template.html'), encoding='utf-8').read()
subs = [
    ("const KEY = 'numaya-visual-lab-v2:'", "const KEY = 'numaya-ente-alignment-v3:'"),
    ('<h1>Numaya Visual Lab V2</h1>', '<h1>Numaya Ente Alignment Lab V3</h1>'),
    ('<title>Numaya Visual Lab V2: review gallery</title>', '<title>Numaya Ente Alignment Lab V3: selection gallery</title>'),
    ('Keep current (O)</label>', 'Keep baseline (O)</label>'),
    ('numaya-visual-lab-choices-', 'numaya-ente-alignment-choices-'),
    ('numaya-visual-lab-summary-', 'numaya-ente-alignment-summary-'),
    ('Numaya Visual Lab V2 choices', 'Numaya Ente Alignment Lab V3 choices'),
    ("<h3>${kind==='component'?'Card families':kind==='screen'?'Screens':'Motion'}</h3>",
     "<h3>${kind==='component'?'Components':kind==='screen'?'Screen layouts':'Motion'}</h3>"),
    ("if (!Object.keys(state.selections).length && !confirm('No choices are recorded in this page yet (choices can be lost if the browser does not keep storage for files opened from disk). Export an empty file anyway?')) return;",
     "const n=Object.keys(state.selections).length; if (n===0) { if (!confirm('No designs selected.\\n\\nEvery group is still Undecided. Export an all-undecided file anyway?')) return; } else if (!confirm(`Export ${n} of ${groups.length} groups selected?`)) return;"),
    ('selectedAt: state.selectedAt, selections:', 'selectedAt: state.selectedAt, exportedAt: new Date().toISOString(), selections:'),
]
for a, b in subs:
    assert a in tpl, a[:60]
    tpl = tpl.replace(a, b)
# Page sections: intro, QA evidence and large text; no Insights, motion or history sections.
a = tpl.index('  <section class="group" id="intro">')
b = tpl.index('</main>')
tpl = tpl[:a] + '''  <section class="group" id="intro">
    <h2>How to review</h2>
    <p><b>Only layout questions are here.</b> Objective Ente alignment fixes are already in every option and are shown in the QA section, not voted on. Each group shows the current layout <b>O</b> and real Flutter alternatives on the same sample data and viewport. Pick one per group, <i>Keep baseline (O)</i>, or leave it <i>Undecided</i>. Nothing is preselected; the app keeps O until you choose.</p>
    <p>Images are real emulator screenshots (Pixel 10, API 36, debug build) from <code>integration_test/ente_alignment_review_test.dart</code>. "Crop" is the component alone in the debug Visual Lab; "Screen" is the real screen with that option chosen. People, events and venues are sample data. Choices are kept in this browser where possible; export the JSON before closing and send it back.</p>
  </section>
  <div id="groups"></div>
  <section class="group" id="evidence"><h2>QA: alignment fixes in the default (not selectable)</h2><p class="q">Semantic specimen, paired actions, picker rows, sheets, status banners, Plan O and the floating bar.</p><div class="gallery" id="evGallery"></div></section>
  <section class="group" id="large"><h2>QA: Events at 360 dp and 200% text</h2><div class="gallery" id="ltGallery"></div></section>
  <div hidden><div id="scGallery"></div><div id="histGallery"></div><div id="clipGrid"></div></div>
''' + tpl[b:]
# Show each group's task, problem, references and per-option tradeoff.
tpl = tpl.replace("<p class=\"q\">${esc(g.question)}</p>`;",
                  "<p class=\"q\">${esc(g.question)}</p><p class=\"meta\"><b>Task:</b> ${esc(g.task)} <b>Problem:</b> ${esc(g.problem)} <b>Axis:</b> ${esc(g.axis)}</p><p class=\"meta\"><b>References:</b> ${g.references.map(esc).join(' · ')}</p><p class=\"meta\"><b>Depends on:</b> ${esc((MANIFEST.dependencies||{})[g.id]||'none')}</p>`;", 1)
tpl = tpl.replace('<div class="note">${esc(v.note)}</div>', '<div class="note">${esc(v.note)}</div><div class="note"><i>Tradeoff:</i> ${esc(v.tradeoff||\'\')}</div>', 1)
tpl = tpl.replace("<span class=\"badge prop\">Proposed (not approved)</span>", "<span class=\"badge prop\">Current default</span>", 1)
html = tpl.replace('__MANIFEST__', json.dumps(manifest).replace('</', '<\\/'))
open(os.path.join(out, 'index.html'), 'w', encoding='utf-8').write(html)

json.dump({'schemaVersion': 1, 'reviewId': review_id, 'codeCommit': args.commit, 'generatedAt': generated,
           'exportedAt': None, 'selections': [], 'undecidedGroups': [g['id'] for g in GROUPS],
           'notesWithoutSelection': {}, '_exampleOnly': 'Shape only. Not owner selections.'},
          open(os.path.join(out, 'choices-example.json'), 'w', encoding='utf-8'), indent=2)
print(json.dumps({'reviewId': review_id, 'screenshots': len(shots), 'missing': missing}, indent=1))
