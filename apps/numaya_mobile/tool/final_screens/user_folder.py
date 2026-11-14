"""NUMAYA_CURRENT_BUILD_SCREENSHOTS: what a user reaches through normal navigation, default design.

python tool/final_screens/user_folder.py <capture run folder> <out folder> <ordered folder from build_phone_folder>

Takes the journey-ordered flat folder, drops developer-only and hidden-route screens, drops screens that
render the same as an earlier one, and renames to 001-flow-screen[-top|-middle-N|-bottom].png.
"""
import hashlib, os, re, shutil, sys
import numpy as np
from PIL import Image

CAP, OUT, ORDERED = sys.argv[1:4]
EXCLUDE = {
    'Review-typography': 'Developer tools (Prototype tools > Typography)',
    'Review-statistics-cards': 'Developer tools (Prototype tools > Statistics cards)',
    'Account-States-Restricted': 'Only shown when the server restricts an account (opened through a hidden route here)',
    'Account-States-Page-not-found': 'Only reachable by typing an unknown deep link',
    'Purchase-unavailable': 'Only shown when no store answers; the demo checkout does not offer it (opened through a hidden route here)',
    'Likes-Compliments-Compliments-populated': 'Same Messages list as messages-all (only the clock differs)',
    'Account-States-Session-expired': 'Only shown when the server ends a session (opened through a hidden route here)',
}
REN = [('Likes-Compliments-Compliments-populated', 'Messages-Compliments-in-chat-list'),
       ('Likes-Compliments-Compliment-request-photo', 'Messages-Compliment-conversation-photo'),
       ('Likes-Compliments-Compliment-request-prompt', 'Messages-Compliment-conversation-prompt'),
       ('Likes-Compliments-Compliment-options-menu', 'Messages-Compliment-conversation-menu'),
       ('Likes-Compliments-Dismiss-compliment-sheet', 'Messages-Compliment-dismiss-sheet'),
       ('Likes-Compliments-Send-compliment', 'Compliment-send'),
       ('Likes-Compliments-', 'Likes-'),
       ('Wallet-Store-', 'Compliment-credits-'),
       ('Safety-Help-Legal-', 'Safety-help-'),
       ('Streaks-', '')]

if os.path.exists(OUT):
    shutil.rmtree(OUT)
os.makedirs(OUT)
files = sorted(f for f in os.listdir(ORDERED) if f.endswith('.png'))
kept, dropped, prints = [], [], []

def small(p):
    im = Image.open(p).convert('L')
    # Ignore the status bar (clock) when comparing.
    im = im.crop((0, 150, im.width, im.height))
    return np.asarray(im.resize((360, 760)), dtype=np.int16)

for f in files:
    name = f.split('-', 1)[1][:-4]
    reason = next((r for k, r in EXCLUDE.items() if k in name), None)
    if reason:
        dropped.append((name, reason))
        continue
    arr = small(os.path.join(ORDERED, f))
    # Same screen: fewer than 20 clearly changed pixels (out of 273,600).
    twin = next((n for n, a in prints if int((np.abs(arr - a) > 40).sum()) < 20), None)
    if twin:
        dropped.append((name, f'same image as {twin}'))
        continue
    prints.append((name, arr))
    kept.append((f, name))

# Parts: "-01-top", "-02-middle", ..., "-NN-bottom".
def tidy(name):
    for a, b in REN:
        if a in name:
            name = name.replace(a, b)
            break
    m = re.match(r'(.*)-(\d\d)-(top|middle|bottom)$', name)
    if m:
        base, n, part = m.groups()
        return base, part, int(n)
    return name, None, 0

rows = [tidy(n) for _, n in kept]
mids = {}
for base, part, n in rows:
    if part == 'middle':
        mids.setdefault(base, []).append(n)
for i, ((f, _), (base, part, n)) in enumerate(zip(kept, rows), 1):
    suffix = ''
    if part == 'top':
        suffix = '-top'
    elif part == 'bottom':
        suffix = '-bottom'
    elif part == 'middle':
        ms = sorted(mids[base])
        suffix = '-middle' if len(ms) == 1 else f'-middle-{ms.index(n) + 1}'
    slug = re.sub(r'[^a-z0-9]+', '-', base.lower()).strip('-')
    shutil.copyfile(os.path.join(ORDERED, f), os.path.join(OUT, f'{i:03d}-{slug}{suffix}.png'))
print('kept', len(kept), 'dropped', len(dropped))
for d in dropped:
    print('DROP', d[0], '|', d[1])
