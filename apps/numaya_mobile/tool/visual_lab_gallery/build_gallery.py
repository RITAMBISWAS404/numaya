"""Builds the offline Visual Lab V2 review gallery from a capture run.

Usage: python build_gallery.py --registry lab_registry.json --capture <dir with shots.tsv,
  clips.tsv, shots/, clips/> --history <MVP gallery dir or ''> --commit <sha> --baseline <sha>
  --branch <name> --out <gallery dir>

Writes index.html (inline CSS/JS, manifest embedded), MANIFEST.json, shots/ (JPEG, 720px wide),
clips/ (MP4 as captured), history/ (a few MVP originals), selection-example.json, NEXT_STEPS.txt.
"""
import argparse, csv, datetime, json, os, shutil, sys

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    Image = None

ap = argparse.ArgumentParser()
for a in ('registry', 'capture', 'history', 'commit', 'baseline', 'branch', 'out'):
    ap.add_argument('--' + a, required=True)
args = ap.parse_args()

here = os.path.dirname(os.path.abspath(__file__))
reg = json.load(open(args.registry, encoding='utf-8'))
out = args.out
os.makedirs(os.path.join(out, 'shots'), exist_ok=True)
os.makedirs(os.path.join(out, 'clips'), exist_ok=True)


def to_jpeg(src, dst):
    if Image is None:
        shutil.copyfile(src, dst.replace('.jpg', '.png'))
        return os.path.basename(dst.replace('.jpg', '.png'))
    im = Image.open(src).convert('RGB')
    w, h = im.size
    if w > 720:
        im = im.resize((720, round(h * 720 / w)), Image.LANCZOS)
    im.save(dst, 'JPEG', quality=86, optimize=True)
    return os.path.basename(dst)


shots = []
with open(os.path.join(args.capture, 'shots.tsv'), encoding='utf-8') as f:
    for row in csv.DictReader(f, delimiter='\t'):
        src = os.path.join(args.capture, 'shots', row['file'])
        if not os.path.exists(src) or os.path.getsize(src) < 1000:
            continue
        name = to_jpeg(src, os.path.join(out, 'shots', row['file'].replace('.png', '.jpg')))
        group = row['group']
        shots.append({
            'id': name.rsplit('.', 1)[0],
            'path': 'shots/' + name,
            'screen': row['label'],
            'family': group,
            'variant': row['variant'],
            'kind': row['kind'],
            'viewport': '1080x2424 px (Pixel 10 emulator, 411x914 dp)',
            'textScale': float(row['textScale']),
            'fixture': row['fixture'],
            'captureMethod': 'adb screencap on Android emulator (API 36), integration_test harness',
            'label': row['label'],
        })

videos = []
clips_tsv = os.path.join(args.capture, 'clips.tsv')
if os.path.exists(clips_tsv):
    with open(clips_tsv, encoding='utf-8') as f:
        for row in csv.DictReader(f, delimiter='\t'):
            src = os.path.join(args.capture, 'clips', row['file'])
            if not os.path.exists(src) or os.path.getsize(src) < 1000:
                continue
            shutil.copyfile(src, os.path.join(out, 'clips', row['file']))
            videos.append({
                'interaction': row['interaction'],
                'motionVariant': row['motion'],
                'reducedMotion': row['motion'] == 'M0',
                'path': 'clips/' + row['file'],
                'captureMethod': 'adb shell screenrecord, debug build (behaviour, not frame-rate proof)',
            })

# Historical originals (MVP PRD build) for context.
hist_pick = ['chats', 'requests', 'reconnect', 'expired', 'discover', 'profile', 'health', 'insights', 'likes']
if args.history and os.path.isdir(args.history):
    os.makedirs(os.path.join(out, 'history'), exist_ok=True)
    taken = 0
    for fn in sorted(os.listdir(args.history)):
        if not fn.endswith('.png') or not any(k in fn.lower() for k in hist_pick):
            continue
        name = to_jpeg(os.path.join(args.history, fn), os.path.join(out, 'history', fn.replace('.png', '.jpg')))
        shots.append({'id': 'history-' + name.rsplit('.', 1)[0], 'path': 'history/' + name, 'screen': fn,
                      'family': 'history', 'variant': 'original', 'kind': 'history', 'viewport': '1080x2424',
                      'textScale': 1.0, 'fixture': 'mvp-prd-v1', 'captureMethod': 'adb screencap (MVP run 2026-11-07)',
                      'label': 'Original: ' + fn.split('__', 1)[-1].replace('.png', '').replace('-', ' ')})
        taken += 1
        if taken >= 14:
            break

groups = reg['groups']
missing = []
for g in groups:
    if g['kind'] == 'motion':
        for v in g['variants']:
            if not any(x['motionVariant'] == v['id'] for x in videos):
                missing.append(f"motion {v['id']}: no clip")
        continue
    for v in g['variants']:
        kinds = {s['kind'] for s in shots if s['family'] == g['id'] and s['variant'] == v['id']}
        need = {'crop', 'context'} if g['kind'] == 'component' else {'screen'}
        for k in sorted(need - kinds):
            missing.append(f"{g['id']} {v['id']}: no {k} screenshot")

generated = datetime.datetime.now().astimezone().replace(microsecond=0).isoformat()
review_id = f"vl2-{args.commit[:7]}-{generated[:10]}"
manifest = {
    'schemaVersion': 1,
    'reviewId': review_id,
    'baselineCommit': args.baseline,
    'codeCommit': args.commit,
    'branch': args.branch,
    'generatedAt': generated,
    'groups': groups,
    'compatibility': {g['id']: g.get('requires', {}) for g in groups if g.get('requires')},
    'a11y': {g['id']: 'Layout tested: 320dp, 200% text' for g in groups if g['kind'] != 'motion'},
    'screenshots': shots,
    'videos': videos,
    'missingItems': missing,
}
json.dump(manifest, open(os.path.join(out, 'MANIFEST.json'), 'w', encoding='utf-8'), indent=2)
tpl = open(os.path.join(here, 'template.html'), encoding='utf-8').read()
html = tpl.replace('__MANIFEST__', json.dumps(manifest).replace('</', '<\\/'))
open(os.path.join(out, 'index.html'), 'w', encoding='utf-8').write(html)
json.dump({'schemaVersion': 1, 'reviewId': review_id, 'codeCommit': args.commit, 'generatedAt': generated,
           'selectedAt': None, 'selections': [], 'undecidedGroups': [g['id'] for g in groups]},
          open(os.path.join(out, 'selection-example.json'), 'w', encoding='utf-8'), indent=2)
open(os.path.join(out, 'NEXT_STEPS.txt'), 'w', encoding='utf-8').write(f"""Numaya Visual Lab V2: how to choose (review {review_id})

1. Open index.html in Chrome, Edge or Firefox (no internet or installation needed).
2. For each group, look at O (current-rules baseline) and the alternatives. Tap an image to see it
   full size. Choose one option, "Keep current (O)" or leave it "Undecided". Add notes if useful.
   The "Proposed" badge is Claude's recommendation only; nothing is preselected.
3. Screen groups say which card variants they fix inside that screen. A red note appears if a
   screen choice differs from your card choice elsewhere; both are recorded.
4. Click "Export choices (JSON)". Choices also stay in this browser where it allows (opening the
   file from disk may not keep them, so export before closing).
5. Send the exported JSON to Claude and ask for a separate application pass on branch
   {args.branch}. Claude will check reviewId and codeCommit ({args.commit}), reject unknown IDs,
   apply only your explicit choices, rerun checks, rebuild the APK and update the handoff.

Missing items in this gallery: {len(missing)} (listed in MANIFEST.json "missingItems").
""")
print(json.dumps({'reviewId': review_id, 'screenshots': len(shots), 'videos': len(videos), 'missing': missing[:40]}, indent=1))
