"""Builds the cumulative offline choice gallery: current renders plus every earlier review set.

Usage: python build_gallery.py --current <capture dir> --stress f15=<dir> f20=<dir> n360=<dir>
  --archive <review dir> [...] --commit <sha> --baseline <sha> --branch <name> --out <dir>
Current renders come from ente_v4_review_test.dart (real Flutter screens on the emulator). Earlier
review sets are copied byte for byte with their review ID and source commit, never re-labelled.
"""
import argparse, csv, datetime, json, os, re, shutil

from PIL import Image

ap = argparse.ArgumentParser()
for a in ('current', 'commit', 'baseline', 'branch', 'out'):
    ap.add_argument('--' + a, required=True)
ap.add_argument('--stress', nargs='*', default=[])
ap.add_argument('--archive', nargs='*', default=[])
# Replacement V8: the review-ID prefix (exports from different runs never validate against each
# other) and extra groups rendered from separate builds, as JSON
# {"group": {"title", "question", "flow", "recommended", "variants": [{"id", "name", "note", "images": [[path, label], ...]}]}}.
ap.add_argument('--review-prefix', default='v7')
ap.add_argument('--extra', default=None)
A = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
app = os.path.dirname(os.path.dirname(here))
OUT = A.out
os.makedirs(OUT + '/current')
os.makedirs(OUT + '/stress')

FLOW = {'match-avatar': 'Messages', 'conversation-row': 'Messages', 'compliment-card': 'Likes and Compliments', 'like-tile': 'Likes and Compliments', 'profile-header': 'Profile', 'profile-setup': 'Profile', 'prompt-card': 'Discover', 'discover-photo': 'Discover', 'streak-card': 'Streaks', 'wallet-card': 'Wallet', 'plan-card': 'Premium', 'status-banner': 'Shared', 'empty-state': 'Shared', 'v4-welcome': 'Onboarding', 'v4-photo-label': 'Discover', 'v6-quote-style': 'Chat', 'v6-voice-bubble': 'Chat', 'v6-composer': 'Chat', 'v6-page-title': 'Shared', 'v6-wallet-header': 'Wallet', 'v6-streak-hero': 'Streaks', 'v6-settings-plan': 'Settings', 'v6-discover-margin': 'Discover', 'screen-heart': 'Likes and Compliments', 'screen-chats': 'Messages', 'screen-profile': 'Profile', 'screen-discover': 'Discover'}
V6 = {
    'v6-quote-style': ('Readable quoted reply inside a bubble', 'The stripe used to run to the block’s corners', 'A contained block separates the quote from the reply; removing parts may read lighter', ['mobbin.com/screens/deb573cb-2ca8-4bba-947d-50f14a2c6f79 (WhatsApp sent quote)']),
    'v6-voice-bubble': ('Voice note at rest', 'No voice note existed in chat', 'A position bar is truthful; a compact note saves space', ['mobbin.com/screens/5609cf9c-a6e5-4785-ae58-f0d8b9118851 (WhatsApp recording)']),
    'v6-composer': ('Composer controls that do not jump', 'Microphone and Send compete for one place', 'One slot keeps the bar simple; fixed controls never change position', ['mobbin.com/screens/fef32388-b721-4975-91ab-9cb35883f6b1 (WhatsApp composer)']),
    'v6-page-title': ('Weight of the large page title', 'Headings may need more or less presence', 'One controlled axis: weight and size only', ['Figma 7672:54672 (Ente text styles)']),
    'v6-wallet-header': ('Credit balance as a focal point', 'The balance looks like every other card', 'A solid purple banner makes the balance the first thing read', ['Figma 12099:96480 (Ente storage card)']),
    'v6-streak-hero': ('Streak as a reward moment', 'The streak has no sense of occasion', 'Solid purple may feel more rewarding; it is louder', ['Figma 12099:96480 (Ente storage card)']),
    'v6-settings-plan': ('Membership summary at the top of Settings', 'Subscription is buried low in a long list', 'A leading card surfaces the plan; adds one thing above the list', ['Figma 12099:96480 (Ente storage card)']),
    'v6-discover-margin': ('Photo margin on Discover', 'Discover’s photo could align with the page or fill more of it', 'Alignment against a larger photo', ['Measured: Ente Settings page margin 20']),
}


FLOW.update({'r8-secondary-button': 'Shared', 'r8-photo-scrim': 'Discover and Profile', 'r8-chat-dividers': 'Messages', 'r8-wallet-value': 'Profile', 'r8-profile-bar': 'Profile'})
X = json.load(open(os.path.join(app, '..', '..', 'docs', 'design', 'creative-lab-v7', 'experiments.json'), encoding='utf-8'))
for _gid, _x in X['groups'].items():
    FLOW[_gid] = _x['flow']


def registry():
    s = open(app + '/lib/features/lab/lab_registry.dart', encoding='utf-8').read()
    out = {}
    for m in re.finditer(r"id: '([^']+)',\s*title: '([^']+)',\s*kind: LabKind\.(\w+),\s*question:\s*'([^']*)'", s):
        i = m.end()
        j = s.find('LabGroup(', i)
        blk = s[i:j if j > 0 else None]
        prop = re.search(r"proposed: ('([^']+)'|_o)", blk)
        vs = []
        for v in re.finditer(r"LabVariant\(\s*(_o|'[^']+'),\s*'((?:[^'\\]|\\.)*)',\s*'((?:[^'\\]|\\.)*)',\s*'((?:[^'\\]|\\.)*)',?\s*\)", blk):
            vs.append({'id': 'O' if v.group(1) == '_o' else v.group(1).strip("'"), 'name': v.group(2), 'pass': v.group(3), 'note': v.group(4), 'images': []})
        out[m.group(1)] = {'id': m.group(1), 'title': m.group(2), 'surface': m.group(3), 'question': m.group(4), 'recommended': (prop.group(2) or 'O') if prop else 'O', 'variants': vs}
    return out


def jpg(src, dst, crop=False):
    im = Image.open(src).convert('RGB')
    if crop:
        top, canvas = 530, (244, 244, 244)
        px = im.load()
        w, h = im.size
        last = top
        for y in range(top, h - 110):
            if any(px[x, y] != canvas for x in range(0, w, 12)):
                last = y
        im = im.crop((0, top, w, min(h, last + 40)))
    w, h = im.size
    if w > 720:
        im = im.resize((720, round(h * 720 / w)), Image.LANCZOS)
    im.save(dst, 'JPEG', quality=86, optimize=True)


reg = registry()
archives = []
for d in A.archive:
    for root in (d, d + '/gallery'):
        if os.path.exists(root + '/manifest.json'):
            archives.append((root, json.load(open(root + '/manifest.json', encoding='utf-8'))))
            break
    else:
        raise SystemExit('no manifest in ' + d)
names = {}
for _, m in archives:
    for g in m['groups']:
        names.setdefault(g['id'], g)

groups, stills, seq = [], {}, {}
with open(A.current + '/shots.tsv', encoding='utf-8') as f:
    for r in csv.DictReader(f, delimiter='\t'):
        p = os.path.join(A.current, 'shots', r['file'])
        if r['kind'] == 'journey' and os.path.exists(p):
            seq.setdefault(r['group'], {}).setdefault(r['variant'], []).append((r['file'], p))
            continue
        if os.path.exists(p) and r['group'] in FLOW and os.path.getsize(p) > 1000:
            stills.setdefault(r['group'], {})[r['variant']] = (p, r['kind'] == 'crop')
for gid, by in sorted(stills.items(), key=lambda kv: (FLOW[kv[0]], kv[0])):
    g = reg.get(gid) or {'id': gid, 'surface': 'screen', 'variants': [], 'recommended': 'O', 'question': ''}
    old = names.get(gid, {})
    g.setdefault('title', old.get('title', gid))
    if not g['question']:
        g['question'] = old.get('question', '')
    if not g['variants']:
        g['variants'] = [{'id': v['id'], 'name': v.get('name', v['id']), 'pass': v.get('pass', ''), 'note': v.get('note', ''), 'images': []} for v in old.get('variants', [])] or [{'id': k, 'name': k, 'pass': '', 'note': '', 'images': []} for k in sorted(by)]
    g['requires'] = old.get('requires') or {}
    run = 'Replacement V8' if gid.startswith('r8-') else 'V7 Creative Lab' if gid.startswith('v7-') else 'V6 refinement' if gid.startswith('v6-') else 'Earlier option, re-rendered'
    g.update(flow=FLOW[gid], run=run, source=A.commit[:7], status='current', earlier=[], level=g.get('surface', 'screen'), impl='Implemented in Flutter, selectable in Visual Lab', directions={})
    if gid in X['groups']:
        x = X['groups'][gid]
        g.update({k: x[k] for k in ('level', 'task', 'problem', 'essential', 'primary', 'benefit', 'cost', 'hypothesis', 'references', 'route', 'verification', 'critique', 'directions', 'recommended')})
        for v in g['variants']:
            v['tradeoff'] = x.get('tradeoffs', {}).get(v['id'], '')
    if gid in V6:
        g['task'], g['problem'], g['hypothesis'], g['references'] = V6[gid]
    for v in g['variants']:
        v['images'] = []
        if v['id'] in by:
            src, crop = by[v['id']]
            name = f"{gid}__{v['id']}.jpg"
            jpg(src, f'{OUT}/current/{name}', crop)
            v['images'].append({'path': 'current/' + name, 'label': 'Current render'})
    groups.append(g)
if A.extra:
    for gid, e in json.load(open(A.extra, encoding='utf-8')).items():
        vs = []
        for v in e['variants']:
            ims = []
            for i, (src, label) in enumerate(v['images']):
                name = f"{gid}__{v['id']}__{i}.jpg"
                jpg(src, f'{OUT}/current/{name}')
                ims.append({'path': 'current/' + name, 'label': label})
            vs.append({'id': v['id'], 'name': v['name'], 'pass': v.get('pass', ''), 'note': v.get('note', ''), 'tradeoff': v.get('tradeoff', ''), 'images': ims})
        g = {'id': gid, 'title': e['title'], 'surface': 'screen', 'question': e['question'], 'recommended': e['recommended'], 'requires': {}, 'flow': e['flow'], 'run': e.get('run', 'Replacement V8'), 'source': e.get('source', A.commit[:7]), 'status': e.get('status', 'current'), 'earlier': [], 'level': e.get('level', 'screen'), 'impl': e.get('impl', 'Implemented in Flutter'), 'directions': {}, 'variants': vs}
        # Fable lab: optional review lines the template already knows how to draw.
        for k in ('task', 'problem', 'benefit', 'cost', 'hypothesis', 'route', 'verification', 'references'):
            if k in e:
                g[k] = e[k]
        groups.append(g)
current = {g['id'] for g in groups}

deferred = lambda i: bool(re.search('event|insight|metric-widget|health|ea-met-card', i))
for root, m in archives:
    rid = m['reviewId']
    code = str(m.get('codeCommit', ''))[:7]
    os.makedirs(f'{OUT}/archive/{rid}', exist_ok=True)
    by = {}
    for s in m['screenshots']:
        by.setdefault(s.get('family'), {}).setdefault(s.get('variant'), []).append(s)
    for g in m['groups']:
        if g.get('kind') == 'motion':
            continue
        imgs = {}
        for vid, shots in by.get(g['id'], {}).items():
            for s in shots[:3]:
                src = os.path.join(root, s['path'])
                if not os.path.exists(src):
                    continue
                dst = f"archive/{rid}/{s['path']}"
                os.makedirs(os.path.dirname(f'{OUT}/{dst}'), exist_ok=True)
                shutil.copyfile(src, f'{OUT}/{dst}')
                imgs.setdefault(vid, []).append({'path': dst, 'label': s.get('label') or s.get('kind') or ''})
        if g['id'] in current:
            target = next(x for x in groups if x['id'] == g['id'])
            target['earlier'].append({'run': rid, 'source': code, 'variants': sorted(imgs), 'count': sum(len(v) for v in imgs.values())})
            for v in target['variants']:
                for im in imgs.get(v['id'], []):
                    v.setdefault('history', []).append({**im, 'run': rid})
        else:
            key = f"{rid}:{g['id']}"
            groups.append({
                'id': key, 'title': g.get('title', g['id']), 'surface': g.get('kind', 'screen'), 'question': g.get('question', ''),
                'task': g.get('task', ''), 'problem': g.get('problem', ''), 'references': g.get('references', []),
                'recommended': g.get('proposed', 'O'), 'requires': {}, 'level': g.get('kind', 'screen'), 'directions': {}, 'impl': 'Earlier render, not re-rendered on this source',
                'flow': 'Deferred (Events)' if deferred(g['id']) else 'Earlier review',
                'run': rid, 'source': code, 'status': 'deferred' if deferred(g['id']) else 'earlier', 'earlier': [],
                'variants': [{'id': v['id'], 'name': v.get('name', v['id']), 'pass': v.get('pass', ''), 'note': v.get('note', ''), 'tradeoff': v.get('tradeoff', ''), 'images': imgs.get(v['id'], [])} for v in g.get('variants', [])],
            })

sequences = []
os.makedirs(OUT + '/current/seq')
for sid, conf in X['sequences'].items():
    rows, incomplete = [], []
    bound = reg.get(sid) if sid != 'direction' else None
    for vid in ('O', 'A', 'B', 'C'):
        shots = sorted(seq.get(sid, {}).get(vid, []))
        if len(shots) < len(conf['steps']):
            incomplete.append(vid)
            continue
        steps = []
        for fn, p in shots:
            key = fn[:-4].rsplit('__', 1)[1]
            jpg(p, f'{OUT}/current/seq/{fn[:-4]}.jpg')
            steps.append({'path': f'current/seq/{fn[:-4]}.jpg', 'label': conf['steps'].get(key, key)})
        name = 'Baseline' if vid == 'O' else X['directions'][vid]['name'] if sid == 'direction' else next(v['name'] for v in bound['variants'] if v['id'] == vid)
        rows.append({'variant': vid, 'name': name, 'steps': steps})
    if not rows:
        continue  # not part of this capture set (replacement V8 renders no V7 journeys)
    sequences.append({'id': sid, 'title': conf['title'], 'note': conf['note'] + (f" Not captured end to end, so not shown: {', '.join(incomplete)}." if incomplete else ''), 'rows': rows})

stress = []
LABELS = {'f15': 'Font 1.5', 'f20': 'Font 2.0', 'n360': '360 dp wide'}
for spec in A.stress:
    tag, d = spec.split('=', 1)
    with open(d + '/shots.tsv', encoding='utf-8') as f:
        for r in csv.DictReader(f, delimiter='\t'):
            p = os.path.join(d, 'shots', r['file'])
            name = f"{tag}-{r['file'][:-4]}.jpg"
            jpg(p, f'{OUT}/stress/{name}')
            stress.append({'path': 'stress/' + name, 'label': f"{r['variant']}, {LABELS.get(tag, tag)}", 'setting': LABELS.get(tag, tag)})

generated = datetime.datetime.now().astimezone().replace(microsecond=0).isoformat()
review = f'{A.review_prefix}-{A.commit[:7]}-{generated[:10]}'
manifest = {'schemaVersion': 3, 'directions': X['directions'], 'directionBound': X['directionBound'], 'exclusive': X['exclusive'], 'recommendedPath': [g for g in X['recommendedPath'] if any(x['id'] == g for x in groups)], 'sequences': sequences, 'reviewId': review, 'sourceCommit': A.commit, 'baselineCommit': A.baseline, 'branch': A.branch, 'generatedAt': generated, 'groups': groups, 'stress': stress}
json.dump(manifest, open(OUT + '/manifest.json', 'w', encoding='utf-8'), indent=1)
tpl = open(here + '/template.html', encoding='utf-8').read()
open(OUT + '/index.html', 'w', encoding='utf-8', newline='\n').write(tpl.replace('__MANIFEST__', json.dumps(manifest).replace('</', '<\\/')))
print(json.dumps({'reviewId': review, 'groups': len(groups), 'current': sum(1 for g in groups if g['status'] == 'current'), 'earlier': sum(1 for g in groups if g['status'] == 'earlier'), 'deferred': sum(1 for g in groups if g['status'] == 'deferred'), 'variants': sum(len(g['variants']) for g in groups), 'missingCurrent': [f"{g['id']} {v['id']}" for g in groups if g['status'] == 'current' for v in g['variants'] if not v['images']]}))
