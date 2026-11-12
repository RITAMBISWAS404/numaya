"""Builds the Fable lab review set from the Flutter test renders.

Usage (from apps/numaya_mobile, after rendering with test/screenshots/fx_lab_capture_test.dart):
  python tool/fable_lab/build_review.py --commit <app sha> --out-gallery <dir> --out-shots <dir>
    [--r8-gallery <dir of the replacement V8 gallery, for the still-undecided photo scrim>]

Writes the offline gallery (tool/v6_gallery template: notes, JSON/TXT export, import with
review-ID validation) and a flat, numbered PNG folder with an index and capture manifest.
The renders contain the local-only demo photos: both outputs stay off GitHub.
"""
import argparse, hashlib, json, os, shutil, subprocess, sys, tempfile

ap = argparse.ArgumentParser()
ap.add_argument('--commit', required=True)
ap.add_argument('--out-gallery', required=True)
ap.add_argument('--out-shots', required=True)
ap.add_argument('--r8-gallery', default=None)
A = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
app = os.path.dirname(os.path.dirname(here))
FX = os.path.join(app, 'test', 'screenshots', 'fx')
BRANCH = 'experiment/numaya-fable-design-20261113-0048'
HERO = 'Shares the feature card (FxHeroCard) with Profile B/C, Credits B and Streak B. It is artwork-pending: the mascot is a stand-in.'

# id -> (title, flow, question, problem, recommended, route/widget, [views], {option: (name, note, tradeoff)}, extra lines)
GROUPS = [
    ('fx-discover', 'Discover profile', 'Discover', 'What should a member read first under the photo, and how do they send a Compliment?',
     'The facts that decide interest (distance, intent, common ground) sit below the fold, and the Compliment action is an unlabelled icon.',
     'A', 'Home (DiscoverScreen), lib/features/fable_lab/fx_discover.dart', ['top', 'more'], {
         'O': ('Name on photo, prompt card', 'The selected V7 card: name and job on the photo, an icon button for a Compliment, then the prompt.', ''),
         'A': ('Essentials first', 'Bio, distance, intent and common ground as one text block under the photo, then a labelled Send a Compliment button.', 'Stronger: the deciding facts and the action are visible without scrolling. Weaker: the first prompt moves down.'),
         'B': ('Photo-led', 'Distance and intent as pills on the photo with the Compliment button on it; a purple Common ground card; facts as a two-column tile grid.', 'Stronger: more personality and a faster scan of facts. Weaker: more of the photo is covered, and the grid stacks at large text.'),
     }, {'benefit': 'A: one reading order (photo, who, why you might match, act).', 'cost': 'Local layout change. B adds a two-column grid, which the earlier direction avoided for cards.'}),
    ('fx-profile', 'Profile hub', 'Profile', 'What should your own Profile tab lead with?',
     'The hub repeats the large photo you already know, and credits and streak read as two similar cards.',
     'B', 'Profile (ProfileScreen), lib/features/fable_lab/fx_profile.dart', ['top', 'more'], {
         'O': ('Photo cover, cards', 'The selected V7 hub: large cover, setup card, list groups, activity cards.', ''),
         'A': ('Compact hub', 'A small identity row, Edit profile and Preview as an equal pair, credits and streak as two number-first tiles, the next setup step as one row.', 'Stronger: everything you do here fits one screen. Weaker: two-column tiles, and less of your photo.'),
         'B': ('Credit hero', 'A shorter cover, then one dark feature card: credits number first, the three balances as labelled numbers, one action. Streak and setup are two quieter blocks.', 'Stronger: one clear focal card and labelled balances. Weaker: needs finished artwork (the mascot is a stand-in), and the cover is shorter.'),
         'C': ('Credit hero, purple', 'B with the feature card in brand purple. Same layout and data; the artwork sits on a white disc.', 'A palette study of B, not a third layout. Purple ties it to the brand but competes with the purple primary buttons elsewhere.'),
     }, {'benefit': 'B: credits (what you spend) become the one feature of the tab.', 'cost': HERO + ' Help and Settings stay in the title bar in every option.'}),
    ('fx-messages', 'Messages with Compliments', 'Messages', 'Can a member tell a Compliment that needs a reply from an ordinary chat?',
     'A pending Compliment differs from a chat only by a small glyph; "whose turn" is carried by pills on each row.',
     'A', 'Messages (MessagesScreen, ConversationRow variants FA/FB)', ['top'], {
         'O': ('One list, icon marks a Compliment', 'Rows sorted by time with the All / Unread / Your move filters; a glyph marks a Compliment.', ''),
         'A': ('Whose turn', 'Two groups replace the filter row: Your turn, then Waiting on them. A Compliment states its condition in words under the preview.', 'Stronger: who needs a reply is the structure of the list. Weaker: no Unread filter, and time order holds only inside each group.'),
         'B': ('Context rows', 'One time-sorted list with the filters. A Compliment row leads with what it was about and shows that photo at the end, with the unread count on it.', 'Stronger: you see what was complimented before opening. Weaker: taller rows and a second image per row.'),
     }, {'benefit': 'Both keep one conversation list and one row per person (no second inbox).', 'cost': 'Local. Text-inset separators (your choice) are kept in both.'}),
    ('fx-compliment-thread', 'Received Compliment', 'Messages', 'Can a member see what was complimented, who sent it, and how to answer or decline?',
     'Declining lives only in the menu, and the context of the Compliment is a small quote inside a chat bubble.',
     'B', 'Chat route before a reply (ComplimentThread), lib/features/fable_lab/fx_thread.dart', ['photo', 'prompt'], {
         'O': ('Sender photo first', 'Their photo and name, then the Compliment as a bubble quoting your photo or prompt, with the reply field always open.', ''),
         'A': ('Compact context card', 'No separate sender photo (the header has their avatar). One card: your photo or your own answer as the quoted block, then their words in the reading size.', 'Stronger: the context is complete and the thread starts higher. Weaker: it drops the photo-led opening you chose in V7, so treat it as opt-in.'),
         'B': ('Decide first', 'Their photo with the name on it, their words as the large line, then Dismiss and Reply as a pair. Reply opens the composer with the keyboard.', 'Stronger: declining is as visible as replying, and their words lead. Weaker: one more tap before typing.'),
     }, {'benefit': 'Rules are identical in all three: replying is free and happens once, the sender cannot write first, Report and Block stay in the menu.', 'cost': 'Local. Dismiss still asks for confirmation.'}),
    ('fx-wallet', 'Compliment credits screen', 'Credits', 'Is the balance, where it came from, and how to get more clear before the history?',
     'The balance card and the Get Compliments action are at opposite ends of the screen.',
     'A', 'Compliment credits (WalletScreen), lib/features/fable_lab/fx_wallet_streak.dart', ['top'], {
         'O': ('Purple balance card', 'A purple card with the total, three bucket rows with their numbers, and Get Compliments in the footer.', ''),
         'A': ('Number-led card', 'A white card: the number large with art beside it, the three buckets as labelled numbers, and Get Compliments inside the card. The rows below explain each bucket.', 'Stronger: number, breakdown and action form one group. Weaker: the action scrolls away with the card.'),
         'B': ('Credit hero and tiles', 'The dark feature card with the action inside it; the buckets become three short tiles.', 'Stronger: one focal card. Weaker: bucket explanations are one tap away, and it needs finished artwork.'),
     }, {'benefit': 'The number stays first in every option (your r8 choice).', 'cost': HERO}),
    ('fx-streak', 'Streak screen', 'Streak', 'Is today’s state, and what earns the next credit, clear at once?',
     'Seven identical bars do not say which day is today or where the reward is.',
     'A', 'Streak (StreakScreen), lib/features/fable_lab/fx_wallet_streak.dart', ['top'], {
         'O': ('Streak card', 'Flame, the count, seven bars and two lines of status.', ''),
         'A': ('Week strip', 'The count as the large number; seven numbered days with counted days checked, the next day ringed and the reward on day 7; then days remaining.', 'Stronger: today and the reward are explicit. Weaker: slightly denser than the bars.'),
         'B': ('Next credit', 'A dark feature card that leads with the days remaining to the next credit, with the bars and today’s state inside it.', 'Stronger: the goal leads. Weaker: the streak count becomes secondary, and it needs finished artwork.'),
     }, {'benefit': 'Uses the existing rule only: 7 counted days earn 1 credit.', 'cost': HERO}),
]

missing = []
extra = {}
shots = []
for gid, title, flow, q, problem, rec, route, views, opts, more in GROUPS:
    vs = []
    for oid, (name, note, tradeoff) in opts.items():
        ims = []
        for v in views:
            p = os.path.join(FX, f'{gid}__{oid}__{v}.png')
            if not os.path.exists(p):
                continue  # a view that is identical to another option's is not rendered twice
            ims.append([p, f'{v} (Flutter render, 393 x 852 at 3x)'])
            shots.append((gid, title, oid, name, v, p))
        if not ims:
            missing.append(f'{gid} {oid}')
        vs.append({'id': oid, 'name': name, 'note': note, 'tradeoff': tradeoff, 'pass': 'baseline' if oid == 'O' else 'fable', 'images': ims})
    extra[gid] = {'title': title, 'flow': flow, 'question': q, 'problem': problem, 'recommended': rec, 'route': route, 'level': 'local layout', 'run': 'Fable lab',
                  'impl': 'Implemented in Flutter; selectable in the Design Lab of a development build. The app default stays O.',
                  'verification': 'Rendered from this commit with identical demo data; also rendered at 1.5x text and 360 wide without overflow; targeted rule checks in test/widget/fx_lab_test.dart.',
                  'variants': vs, **more}
if missing:
    sys.exit('missing renders:\n' + '\n'.join(missing))

# The one r8 decision still open, shown with its earlier renders (not re-rendered).
if A.r8_gallery and os.path.exists(os.path.join(A.r8_gallery, 'manifest.json')):
    m = json.load(open(os.path.join(A.r8_gallery, 'manifest.json'), encoding='utf-8'))
    g = next((x for x in m['groups'] if x['id'] == 'r8-photo-scrim'), None)
    if g:
        extra['r8-photo-scrim'] = {
            'title': g['title'], 'flow': 'Discover and Profile', 'question': g['question'], 'recommended': g['recommended'], 'level': 'shared (every name over a photo)',
            'run': 'Replacement V8 (still undecided)', 'status': 'earlier', 'source': str(m['sourceCommit'])[:7],
            'impl': 'Implemented; unchanged since the replacement V8 gallery. Shown here because it was left undecided in your export.',
            'variants': [{'id': v['id'], 'name': v['name'], 'note': v.get('note', ''), 'pass': v.get('pass', ''),
                          'images': [[os.path.join(A.r8_gallery, i['path']), 'Earlier emulator render, ' + str(m['sourceCommit'])[:7]] for i in v['images']]} for v in g['variants']],
        }

tmp = tempfile.mkdtemp()
open(os.path.join(tmp, 'shots.tsv'), 'w', encoding='utf-8').write('file\tgroup\tvariant\tkind\ttextScale\tfixture\tlabel\n')
os.makedirs(os.path.join(tmp, 'shots'))
json.dump(extra, open(os.path.join(tmp, 'extra.json'), 'w', encoding='utf-8'))
if os.path.exists(A.out_gallery):
    sys.exit('gallery folder exists: ' + A.out_gallery)
# Stress samples: each group's recommended option at 1.5x text and at 360 wide.
stress_args = []
for tag, sub in (('f15', 'w393_x1.5'), ('n360', 'w360_x1')):
    d = os.path.join(tmp, tag)
    os.makedirs(os.path.join(d, 'shots'))
    rows = ['file	group	variant	kind	textScale	fixture	label']
    for gid, title, flow, q, problem, rec, route, views, opts, more in GROUPS:
        src = os.path.join(FX, 'stress', sub, f'{gid}__{rec}__{views[0]}.png')
        if os.path.exists(src):
            fn = f'{gid}__{rec}.png'
            shutil.copyfile(src, os.path.join(d, 'shots', fn))
            rows.append(f'{fn}	{gid}	{title} {rec}	stress	1.0	demo	{title}')
    open(os.path.join(d, 'shots.tsv'), 'w', encoding='utf-8').write(chr(10).join(rows) + chr(10))
    stress_args.append(f'{tag}={d}')
r = subprocess.run([sys.executable, '-X', 'utf8', os.path.join(app, 'tool', 'v6_gallery', 'build_gallery.py'), '--current', tmp, '--commit', A.commit, '--baseline', 'c890d029329a25268896f87867e5d5660fb1ba95',
                    '--branch', BRANCH, '--out', A.out_gallery, '--review-prefix', 'fx', '--extra', os.path.join(tmp, 'extra.json'), '--stress', *stress_args], capture_output=True, text=True, encoding='utf-8')
print(r.stdout[-600:], r.stderr[-1500:])
if r.returncode:
    sys.exit(1)

# Flat numbered folder for phone review.
if os.path.exists(A.out_shots):
    sys.exit('screenshot folder exists: ' + A.out_shots)
os.makedirs(A.out_shots)
slug = lambda s: ''.join(c if c.isalnum() else '-' for c in s).strip('-').replace('--', '-')
idx = ['# Fable lab renders', '', f'App commit `{A.commit}` on `{BRANCH}`. Flutter test renders of the real app (not emulator screenshots): 393 x 852 logical at 3x (1179 x 2556), text scale 1.0, the full demo fixture. No status bar is drawn.',
       '', 'Every PNG was rendered from that commit. They show the private demo photos: keep this folder local.', '', '| File | Screen | Option | View | SHA-256 (first 16) |', '|---|---|---|---|---|']
for n, (gid, title, oid, name, v, p) in enumerate(shots, 1):
    fn = f"{n:02d}-{slug(title)}-{oid}-{slug(name)}-{v}.png"
    shutil.copyfile(p, os.path.join(A.out_shots, fn))
    idx.append(f"| {fn} | {title} | {oid} {name}{' (baseline)' if oid == 'O' else ''} | {v} | {hashlib.sha256(open(p, 'rb').read()).hexdigest()[:16]} |")
open(os.path.join(A.out_shots, 'INDEX.md'), 'w', encoding='utf-8', newline='\n').write('\n'.join(idx) + '\n')
print('shots', len(shots), A.out_shots)
