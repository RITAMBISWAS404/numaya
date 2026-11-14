"""Revised design review (2026-11-14): only the layout/UI options selectable in the running build.

python tool/design_review/build_live.py <lab_registry.json> <scenes.json> <renders> <live_groups.txt> <out> <build json>

Eligibility: the group must be listed by the build's own selector UI (Visual Lab V2 or Experiment Lab, walked
on the device; ids in live_groups.txt). Motion presets are excluded (timing only, no visual layout).
An option is shown only if its render differs from every other option of the same selector in at least
one view; options that render the same as another are reported, not shown. A selector left with fewer
than two distinct options is reported, not shown.
"""
import csv, io, json, os, re, shutil, sys
import numpy as np
from PIL import Image

REG, PLAN, RENDERS, LIVE, OUT, BUILD = sys.argv[1:7]
reg = {g['id']: g for g in json.load(open(REG, encoding='utf-8'))['groups']}
plan = json.load(open(PLAN, encoding='utf-8'))['plan']
live = [l.strip() for l in open(LIVE, encoding='utf-8') if l.strip()]
build = json.load(open(BUILD, encoding='utf-8'))
src_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(RENDERS))))

SCREEN = [  # (match on group or route) -> screen name, order
    (lambda g, r: g == 'v7-nav', 'Bottom navigation (every tab)'),
    (lambda g, r: g == 'v7-filters', 'Discover: Filters sheet'),
    (lambda g, r: g in ('v7-compliment', 'v8-compliment'), 'Send a Compliment'),
    (lambda g, r: r.startswith('/home'), 'Discover'),
    (lambda g, r: r.startswith('/likes?tab'), 'Visual Lab component previews'),
    (lambda g, r: r.startswith('/likes'), 'Likes'),
    (lambda g, r: r.startswith('/messages'), 'Messages'),
    (lambda g, r: r.startswith('/chat'), 'Chat'),
    (lambda g, r: r.startswith('/request'), 'Compliment request'),
    (lambda g, r: r.startswith('/match'), 'Match'),
    (lambda g, r: r == '/profile', 'Profile'),
    (lambda g, r: r.startswith('/profile/wallet'), 'Compliment credits'),
    (lambda g, r: r.startswith('/profile/streak'), 'Streak'),
    (lambda g, r: r.startswith('/profile/settings'), 'Settings'),
    (lambda g, r: r.startswith('/paywall'), 'Premium paywall'),
    (lambda g, r: r.startswith('/review-stats'), 'Statistics cards'),
    (lambda g, r: r.startswith('/visual-lab/preview/v4-welcome'), 'Welcome'),
]
ORDER = ['Welcome', 'Discover', 'Discover: Filters sheet', 'Send a Compliment', 'Likes', 'Match', 'Messages', 'Chat',
         'Compliment request', 'Profile', 'Statistics cards', 'Compliment credits', 'Streak', 'Settings', 'Premium paywall',
         'Bottom navigation (every tab)', 'Visual Lab component previews']
SCREEN_ROUTE = {'Welcome': 'Welcome (signed out)', 'Discover': '/home', 'Discover: Filters sheet': '/home › Filters',
                'Send a Compliment': 'Discover › Compliment on a photo or prompt', 'Likes': '/likes (Premium)', 'Match': '/match/maya',
                'Messages': '/messages', 'Chat': '/chat/…', 'Compliment request': '/request/…', 'Profile': '/profile',
                'Statistics cards': 'Demo hub › Statistics cards', 'Compliment credits': '/profile/wallet', 'Streak': '/profile/streak',
                'Settings': '/profile/settings', 'Premium paywall': '/paywall', 'Bottom navigation (every tab)': 'every tab',
                'Visual Lab component previews': 'Visual Lab V2 › group › Preview'}
VIEW = {'top': 'Top of screen', 'full': 'Full page', 'specimen': 'Visual Lab preview'}
HUB = 'Explore the demo › Profile › Settings › Prototype tools › Demo hub'

def screen_of(g, route):
    for f, name in SCREEN:
        if f(g, route):
            return name
    return 'Other'

def slug(s):
    return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')[:28].strip('-') or 'option'

def load(path):
    im = Image.open(path).convert('L')
    return np.asarray(im.resize((393, round(im.height / 3))), dtype=np.int16)

def diff(a, b):
    if a.shape != b.shape:
        return 10 ** 9
    return int((np.abs(a - b) > 40).sum())

# Collect the plan per selector.
sel = {}
for p in plan:
    if 'variant' not in p:
        continue
    g = p['group']
    if g.startswith('exp-'):
        exp = g[4:]
        if exp not in ('matchMoment', 'emptyChats'):
            continue
        sel.setdefault(g, []).append(p)
    elif g in live and g != 'motion':
        sel.setdefault(g, []).append(p)

EXPLAB = {'exp-matchMoment': ('Match moment', 'EXP-001-match-moment', 'current'),
          'exp-emptyChats': ('Empty conversations', 'EXP-003-empty-conversations', 'current')}
exp_src = io.open(os.path.join(src_root, 'lib', 'features', 'experiments', 'experiments.dart'), encoding='utf-8').read()
def exp_names(key):
    m = re.search(key + r"\(.*?names: \{(.*?)\}", exp_src, re.S)
    return dict(re.findall(r"ExpVariant\.(\w+): '([^']+)'", m.group(1))) if m else {}
EXPNAMES = {'exp-matchMoment': exp_names('matchMoment'), 'exp-emptyChats': exp_names('emptyChats')}

if os.path.exists(OUT):
    shutil.rmtree(OUT)
os.makedirs(OUT)

screens, report_same, report_fail = {}, [], []
for gid, ps in sel.items():
    views = {}
    for p in ps:
        for sid in p['shots']:
            view = sid.rsplit('__', 1)[1]
            f = os.path.join(RENDERS, sid + '.png')
            if os.path.exists(f):
                views.setdefault(view, {})[p['variant']] = f
            else:
                report_fail.append((gid, p['variant'], sid, 'render missing'))
    arrs = {v: {k: load(f) for k, f in d.items()} for v, d in views.items()}
    vids = [p['variant'] for p in ps]
    # Which views distinguish anything at all.
    useful = [v for v, d in arrs.items() if any(diff(d[a], d[b]) >= 30 for a in d for b in d if a < b)]
    def same(a, b):
        return all(diff(arrs[v][a], arrs[v][b]) < 30 for v in useful if a in arrs[v] and b in arrs[v])
    is_exp = gid.startswith('exp-')
    default = EXPLAB[gid][2] if is_exp else reg[gid]['proposed']
    keep, dropped = [], []
    for v in sorted(vids, key=lambda x: (x != default, vids.index(x))):
        twin = next((k for k in keep if same(k, v)), None)
        if twin is None:
            keep.append(v)
        else:
            dropped.append((v, twin))
    if is_exp:
        title, code, _ = EXPLAB[gid]
        names = EXPNAMES[gid]
        gtitle, gpath = title, f'{HUB} › Experiment Lab › {title} ({code})'
    else:
        g = reg[gid]
        gtitle = g['title']
        gpath = f"{HUB} › Visual Lab V2 › {g['title']} ({gid})"
    route = ps[0]['route']
    ctx = {k: v for k, v in ps[0].get('choices', {}).items() if k != gid} if not is_exp else {}
    for v, twin in dropped:
        report_same.append((gtitle, gid, v, twin))
    if len(keep) < 2:
        report_same.append((gtitle, gid, '(whole selector)', f'only {len(keep)} distinct option in this build'))
        continue
    scr = screen_of(gid, route)
    entry = {'id': gid, 'title': gtitle, 'question': '' if is_exp else reg[gid]['question'], 'default': default, 'path': gpath,
             'route': route, 'context': ctx, 'options': []}
    for v in keep:
        if is_exp:
            label = {'current': 'Current', 'a': 'A', 'b': 'B', 'c': 'C'}[v]
            name, change = names.get(v, v), names.get(v, v)
        else:
            var = next(x for x in reg[gid]['variants'] if x['id'] == v)
            label, name, change = v, var['name'], var['note']
        imgs = []
        for view in ('top', 'full', 'specimen'):
            if view not in useful or v not in views.get(view, {}):
                continue
            rel = f"screenshots/{slug(scr)}/{gid}/{v}/{gid}__{slug(name)}__{view}.jpg"
            dst = os.path.join(OUT, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            im = Image.open(views[view][v]).convert('RGB')
            im = im.resize((786, round(im.height * 786 / im.width)), Image.LANCZOS)
            im.save(dst, 'JPEG', quality=86, optimize=True)
            imgs.append({'path': rel, 'label': VIEW[view]})
        if not imgs:
            report_fail.append((gid, v, '-', 'no distinguishing view'))
            continue
        entry['options'].append({'label': label, 'name': name, 'change': change, 'images': imgs,
                                 'path': f'{gpath} › {label}', 'default': v == default})
    screens.setdefault(scr, []).append(entry)

data = {'build': build, 'screens': [{'name': s, 'where': SCREEN_ROUTE.get(s, ''), 'selectors': screens[s]} for s in ORDER if s in screens]}
tpl = io.open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gallery_live.html'), encoding='utf-8').read()
io.open(os.path.join(OUT, 'index.html'), 'w', encoding='utf-8', newline='\n').write(tpl.replace('/*DATA*/null', json.dumps(data, ensure_ascii=False)))
with io.open(os.path.join(OUT, 'manifest.csv'), 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f)
    w.writerow(['screen', 'selector', 'selector_id', 'option_label', 'descriptive_name', 'what_changes', 'path_in_app', 'context_choices', 'is_current_default', 'screenshots'])
    for s in data['screens']:
        for e in s['selectors']:
            for o in e['options']:
                w.writerow([s['name'], e['title'], e['id'], o['label'], o['name'], o['change'], o['path'],
                            '; '.join(f'{k}={v}' for k, v in e['context'].items()), 'yes' if o['default'] else '', ' | '.join(i['path'] for i in o['images'])])
nscr = len(data['screens'])
nsel = sum(len(s['selectors']) for s in data['screens'])
nopt = sum(len(e['options']) for s in data['screens'] for e in s['selectors'])
json.dump({'screens': nscr, 'selectors': nsel, 'options': nopt, 'same': report_same, 'fail': report_fail},
          open(os.path.join(os.path.dirname(PLAN), 'live_counts.json'), 'w', encoding='utf-8'), indent=1)
print(nscr, 'screens', nsel, 'selectors', nopt, 'options; not shown:', len(report_same), 'failures:', len(report_fail))
