"""Builds NUMAYA_DESIGN_EXPERIMENT_REVIEW: every layout/UI experiment, captured or sourced, with an
offline gallery (choose a winner per experiment, notes per variant, Markdown export), manifest.csv
and screenshots/<experiment>/<variant>/.

python tool/design_review/build_review.py <lab_registry.json> <scenes.json> <same.json> <renders dir> <out dir> <app sha>
"""
import csv, html, io, json, os, re, shutil, sys
from PIL import Image

REG, PLAN, SAME, RENDERS, OUT, SHA = sys.argv[1:7]
reg = json.load(open(REG, encoding='utf-8'))
plan = json.load(open(PLAN, encoding='utf-8'))['plan']
same = json.load(open(SAME, encoding='utf-8'))
DESK = r'C:\Users\biswa\OneDrive\Desktop'
OLDER = [
    ('V7 review gallery (native renders, build 71564be, 2026-11-10)', os.path.join(DESK, r'Numaya MVP V7 Review\2026-11-10 1305\current'), '{g}__{v}'),
    ('Replacement V8 gallery (native renders, build ee87648, 2026-11-12)', os.path.join(DESK, r'Numaya Replacement V8 Review\2026-11-12 ee87648\current'), '{g}__{v}__'),
    ('Visual Lab V2 gallery (native renders, build 010fe8f, 2026-11-08)', os.path.join(DESK, r'Numaya Visual Lab\2026-11-08 Premium Likes update\shots'), '__{g}__{v}__'),
]
SP = os.path.dirname(PLAN)
REVIEW_ZIP = os.path.join(SP, 'v8z', 'review')

ISSUES = {'v8-paywall': 'UI-076', 'v8-stats': 'UI-078', 'v8-match': 'UI-082', 'v8-profile': 'UI-084, UI-042',
          'v8-compliment': 'UI-083', 'r8-secondary-button': 'UI-002', 'r8-photo-scrim': 'UI-066',
          'v4-welcome': 'UI-001', 'v7-nav': 'UI-026', 'r8-chat-dividers': 'UI-003', 'like-tile': 'UI-064',
          'match-avatar': 'UI-033', 'status-banner': 'UI-086', 'discover-photo': 'UI-014', 'prompt-card': 'UI-007',
          'fx-messages': 'UI-068', 'fx-compliment-thread': 'UI-083', 'v7-likes-locked': 'UI-065'}

def slug(s):
    return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')[:28].strip('-') or 'variant'

def save(src, dst, width=786):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    im = Image.open(src).convert('RGB')
    if im.width > width:
        im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    im.save(dst, 'JPEG', quality=86, optimize=True)

if os.path.exists(OUT):
    shutil.rmtree(OUT)
os.makedirs(OUT)

shots_by = {}
for p in plan:
    if 'variant' in p:
        shots_by[(p['group'], p['variant'])] = p

experiments = []  # dicts
rows = []

def older_for(g, v):
    found = []
    for label, folder, pat in OLDER:
        if not os.path.isdir(folder):
            continue
        key = pat.format(g=g, v=v)
        for f in sorted(os.listdir(folder)):
            if (f.startswith(key) or key in f) and f.lower().endswith(('.jpg', '.png')):
                if pat == '{g}__{v}' and not (f.startswith(key + '.') or f.startswith(key + '__')):
                    continue
                found.append((label, os.path.join(folder, f), f))
    return found[:3]

VIEW = {'top': 'Top of screen', 'full': 'Full page', 'specimen': 'Isolated component (Visual Lab preview)'}
pix = same.get('pixels', {})

def add_group(eid, title, screen, question, default, variants, source_note=''):
    experiments.append({'id': eid, 'title': title, 'screen': screen, 'question': question,
                        'default': default, 'variants': variants, 'note': source_note})

for g in reg['groups']:
    gid = g['id']
    vlist = []
    for v in g['variants']:
        vid = v['id']
        title = f"{vid} · {v['name']}"
        name_slug = slug(v['name'])
        p = shots_by.get((gid, vid))
        images, status, reason = [], 'Captured (current build)', ''
        if gid == 'motion':
            status, reason = 'Capture unavailable', 'Motion presets change timing and easing only; a still screenshot cannot show the difference. Try them in the app.'
        elif p:
            for sid in p['shots']:
                view = sid.rsplit('__', 1)[1]
                src = os.path.join(RENDERS, sid + '.png')
                if not os.path.exists(src):
                    continue
                d = pix.get(gid, {}).get(vid, {}).get(view)
                note = ''
                if d is not None and d < 30:
                    note = 'no visible difference from another option here'
                rel = f'screenshots/{gid}/{vid}/{gid}__{name_slug}__{view}.jpg'
                save(src, os.path.join(OUT, rel))
                images.append({'path': rel, 'label': VIEW[view] + (f' ({note})' if note else ''), 'source': f'Native render, current build {SHA[:7]}'})
            if vid in same.get('same', {}).get(gid, []):
                status = 'Captured, no visible change in this build'
                reason = 'Switching to this option renders the same screen as another option in the current build; older evidence is shown where it exists.'
                for k, (label, path, f) in enumerate(older_for(gid, vid)):
                    rel = f'screenshots/{gid}/{vid}/{gid}__{name_slug}__older-{label.split()[0].lower()}-{k + 1}.jpg'
                    save(path, os.path.join(OUT, rel))
                    images.append({'path': rel, 'label': 'Older capture: ' + label, 'source': label})
        vlist.append({'id': vid, 'title': title, 'change': v['note'], 'provenance': v['pass'], 'status': status,
                      'reason': reason, 'images': images,
                      'route': p['route'] if p else '',
                      'selector': f"Settings › Prototype tools › Demo hub › Visual Lab V2 › {g['title']} › {vid}"})
    add_group(gid, g['title'], ', '.join(g['usages'])[:120], g['question'], g['proposed'], vlist)

# Experiment Lab (overnight v3).
EXP = {
    'matchMoment': ('EXP-001 Match moment', '/match/maya', {'current': 'Refined candidate: portrait, line, shared interests', 'a': 'Paired portraits', 'b': 'Identity-led photo hero', 'c': 'Restrained cat celebration'}),
    'emptyChats': ('EXP-003 Empty conversations', '/messages (new account, no chats)', {'current': 'Refined candidate: illustrated card', 'a': 'A', 'b': 'B', 'c': 'C'}),
}
src_exp = io.open(os.path.join(os.path.dirname(RENDERS), '..', '..', 'lib', 'features', 'experiments', 'experiments.dart'), encoding='utf-8').read()
m = re.search(r"emptyChats\(.*?names: \{(.*?)\}", src_exp, re.S)
if m:
    for k, vname in re.findall(r"ExpVariant\.(\w+): '([^']+)'", m.group(1)):
        EXP['emptyChats'][2][k] = vname
for exp, (title, route, names) in EXP.items():
    vlist = []
    for vid, vname in names.items():
        sid = f'exp-{exp}__{vid}__top'
        rel = f'screenshots/exp-{exp}/{vid}/exp-{exp}__{slug(vname)}__top.jpg'
        save(os.path.join(RENDERS, sid + '.png'), os.path.join(OUT, rel))
        vlist.append({'id': vid, 'title': f'{vid} · {vname}', 'change': vname, 'provenance': 'Experiment Lab (overnight v3)',
                      'status': 'Captured (current build)', 'reason': '', 'route': route,
                      'images': [{'path': rel, 'label': 'Top of screen', 'source': f'Native render, current build {SHA[:7]}'}],
                      'selector': f'Settings › Prototype tools › Demo hub › Experiment Lab › {title} › {vid}'})
    add_group(f'exp-{exp}', title, route, 'Experiment Lab comparison', 'current', vlist)
for eid, title, names in (('EXP-002', 'EXP-002 Own-profile upper section', ['Refined candidate: round photo over the card', 'Photo-led cover', 'Compact identity row', 'Identity with quick actions']),
                          ('EXP-004', 'EXP-004 Profile completion card', ['Refined candidate: title, bar, button', 'Ente progress banner', 'Next single task', 'Cat encouragement'])):
    vlist = [{'id': vid, 'title': f'{vid} · {n}', 'change': n, 'provenance': 'Experiment Lab (overnight v3)', 'status': 'Capture unavailable',
              'reason': 'Still listed in the Experiment Lab, but no current screen reads this experiment (the Profile was rebuilt since), and no saved screenshot was found.',
              'route': '/profile', 'images': [], 'selector': f'Settings › Prototype tools › Demo hub › Experiment Lab › {title} › {vid}'}
             for vid, n in zip(['current', 'a', 'b', 'c'], names)]
    add_group(eid.lower(), title, 'Profile', 'Experiment Lab comparison (no longer wired)', 'current', vlist)

# Removed experiments with older evidence only.
vl = json.load(open(os.path.join(DESK, r'Numaya Visual Lab\2026-11-08 Premium Likes update\manifest.json'), encoding='utf-8'))
for g in vl['groups']:
    if g['id'] not in ('insights-summary', 'metric-widget', 'screen-insights'):
        continue
    vlist = []
    for v in g['variants']:
        imgs = []
        for k, (label, path, f) in enumerate(older_for(g['id'], v['id'])):
            rel = f"screenshots/{g['id']}/{v['id']}/{g['id']}__{slug(v.get('name', v['id']))}__older-{k + 1}.jpg"
            save(path, os.path.join(OUT, rel))
            imgs.append({'path': rel, 'label': 'Older capture: ' + label, 'source': label})
        vlist.append({'id': v['id'], 'title': f"{v['id']} · {v.get('name', '')}", 'change': v.get('note', ''), 'provenance': v.get('pass', ''),
                      'status': 'Sourced from older evidence' if imgs else 'Capture unavailable',
                      'reason': 'Removed from the app with Insights (H-13); shown from the 8 November Visual Lab gallery.' if imgs else 'Removed with Insights; no saved screenshot found.',
                      'route': '/profile/insights (removed)', 'images': imgs, 'selector': 'No longer selectable'})
    add_group(g['id'], g.get('title', g['id']), 'Insights (removed)', g.get('question', ''), g.get('proposed', 'O'), vlist)
r8 = json.load(open(os.path.join(DESK, r'Numaya Replacement V8 Review\2026-11-12 ee87648\manifest.json'), encoding='utf-8'))
for g in r8['groups']:
    if g['id'] != 'r8-compliment-home':
        continue
    vlist = []
    for v in g['variants']:
        imgs = []
        for im in v['images']:
            rel = f"screenshots/{g['id']}/{v['id']}/{g['id']}__{slug(v['name'])}__older-{v['images'].index(im) + 1}.jpg"
            save(os.path.join(DESK, r'Numaya Replacement V8 Review\2026-11-12 ee87648', im['path']), os.path.join(OUT, rel))
            imgs.append({'path': rel, 'label': 'Older capture: ' + im['label'], 'source': 'Replacement V8 gallery (build ee87648 / O from 014ac35)'})
        vlist.append({'id': v['id'], 'title': f"{v['id']} · {v['name']}", 'change': v['note'], 'provenance': g['run'], 'status': 'Sourced from older evidence',
                      'reason': 'Decided in the Replacement V8 pass (A is the app now); no longer a selector.', 'route': '/messages', 'images': imgs, 'selector': 'No longer selectable'})
    add_group(g['id'], g['title'], 'Messages', g['question'], 'A', vlist)

# Concept only.
add_group('v8-likes-tile', 'Likes tile in New matches (UI-034)', 'Messages › New matches', 'Should Likes come back as the first tile in New matches?', 'O', [
    {'id': 'O', 'title': 'O · No Likes tile (current)', 'change': 'New matches shows matches only; Likes has its own tab.', 'provenance': 'Owner selection (Visual Lab)',
     'status': 'Captured (current build)', 'reason': '', 'route': '/messages', 'selector': 'Default',
     'images': [{'path': 'screenshots/match-avatar/O/match-avatar__circle__top.jpg', 'label': 'Top of screen', 'source': f'Native render, current build {SHA[:7]}'}]},
    {'id': 'A', 'title': 'A · Illustrated Likes tile first', 'change': 'A rounded-square Likes tile with an illustration and the count at the top, first in the row.', 'provenance': 'UI-034 (review register)',
     'status': 'Concept only', 'reason': 'Documented in the review register but never built: it conflicts with the later choice to give Likes its own tab, and the mascot art does not exist.', 'route': '', 'selector': 'Not built', 'images': []},
])
for e in experiments:
    if e['id'] == 'v8-likes-tile':
        p0 = e['variants'][0]['images'][0]['path']
        if not os.path.exists(os.path.join(OUT, p0)):
            cand = [f for f in os.listdir(os.path.join(OUT, 'screenshots', 'match-avatar', 'O')) if f.endswith('__top.jpg')]
            e['variants'][0]['images'][0]['path'] = f'screenshots/match-avatar/O/{cand[0]}'

# HTML prototypes from the V8 review (concept sources for the native groups).
os.makedirs(os.path.join(OUT, 'prototypes'), exist_ok=True)
PROTO = {'v8-paywall': 'NUMAYA_PREMIUM_LAYOUTS.html', 'v8-match': 'NUMAYA_MATCH_LAYOUTS.html', 'v8-profile': 'NUMAYA_PROFILE_LAYOUTS.html'}
for e in experiments:
    if e['id'] in PROTO:
        f = PROTO[e['id']]
        shutil.copyfile(os.path.join(REVIEW_ZIP, f), os.path.join(OUT, 'prototypes', f))
        e['prototype'] = f'prototypes/{f}'
        e['note'] = 'The source HTML prototype (concept, not the app) is linked for comparison; the options below are native renders.'
    if e['id'] in ISSUES:
        e['issue'] = ISSUES[e['id']]

# Manifest.
with io.open(os.path.join(OUT, 'manifest.csv'), 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f)
    w.writerow(['experiment_id', 'experiment', 'screen', 'variant_id', 'descriptive_title', 'what_changes', 'issue_id', 'route', 'selector_path', 'source', 'capture_status', 'reason', 'screenshots', 'current_default'])
    for e in experiments:
        for v in e['variants']:
            srcs = sorted({i['source'] for i in v['images']}) or ['None']
            w.writerow([e['id'], e['title'], e['screen'], v['id'], v['title'], v['change'], e.get('issue', ''), v['route'], v['selector'],
                        '; '.join(srcs), v['status'], v['reason'], ' | '.join(i['path'] for i in v['images']), 'yes' if v['id'] == e['default'] else ''])

data = {'appSha': SHA, 'experiments': experiments}
tpl = io.open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gallery.html'), encoding='utf-8').read()
io.open(os.path.join(OUT, 'index.html'), 'w', encoding='utf-8', newline='\n').write(tpl.replace('/*DATA*/null', json.dumps(data, ensure_ascii=False)))
from collections import Counter
c = Counter(v['status'] for e in experiments for v in e['variants'])
print(len(experiments), 'experiments', sum(len(e['variants']) for e in experiments), 'variants', dict(c))
json.dump({'experiments': len(experiments), 'variants': sum(len(e['variants']) for e in experiments), 'status': dict(c)}, open(os.path.join(SP, 'dr_counts.json'), 'w'))
