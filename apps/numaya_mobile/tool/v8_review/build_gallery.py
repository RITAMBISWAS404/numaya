"""Builds the V8 review gallery (2026-11-14): offline, selectable, with notes and JSON export/import.

Usage:
  python tool/v8_review/build_gallery.py --renders test/screenshots/v8 --out <review>/gallery \
      --sha <full app source sha>

Images are copied from the harness renders (real Flutter widget renders of the app at 393 x 852
logical, 3x, the full demo world and the local demo photos). The page needs no server and no
network: every image path is relative. The images show the private demo photos, so the output
stays local (never commit it).

Contract (companion gallery/CONTRACT.md): galleryRevision + appSourceSha; groups with baseline,
options (status implemented-rendered / concept-only / blocked), recommendation shown but never
preselected; export {schemaVersion, galleryRevision, appSourceSha, exportedAt, choices[{groupId,
optionId, note}], typography{displayFamily, uiFamily, baseBodySize}, unresolvedGroups[]}; import
rejects a different revision (unless the migration map covers it), unknown ids, duplicates and
bad enums; notes are text.
"""
import argparse, json, os, shutil, sys

ap = argparse.ArgumentParser()
ap.add_argument('--renders', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--sha', required=True)
A = ap.parse_args()
if len(A.sha) != 40:
    sys.exit('--sha must be the full 40-character app source sha')
REV = 'v8r-20261114-' + A.sha[:7]

R = 'implemented-rendered'


def opt(i, label, images, desc, tradeoffs='', status=R):
    return {'id': i, 'label': label, 'status': status, 'images': images,
            'description': desc, 'tradeoffs': tradeoffs}


GROUPS = [
    {
        'id': 'v8-paywall', 'sourceIssueIds': ['UI-076', 'UI-077'], 'scope': 'screen',
        'title': 'Premium paywall', 'dependencies': [],
        'question': 'How should the five Premium durations be chosen?',
        'baselineId': 'O', 'recommendationId': 'A',
        'recommendationWhy': 'A keeps the decision informed: every benefit is read before the price, and the five durations sit in one scannable list where the two unpriced terms are visibly inert. The tradeoff is that the plans start below the first view on a 393pt phone; B shows prices sooner but splits the eye between two columns.',
        'options': [
            opt('O', 'Selected V8 paywall (baseline)', ['exp-paywall-O.png'], 'Benefits list, three plan rows, no artwork slot; the state before UI-076.', 'Lacks the 16:9 slot and the 3 and 6 month terms.'),
            opt('A', 'Benefits first, stacked plans', ['exp-paywall-A.png', 'exp-paywall-A-selected.png'], 'The padded 16:9 artwork slot above "Get more with Premium", one grouped benefits card, then five stacked plan rows. 3 and 6 months show Price pending and cannot be chosen.', 'Plans below the fold.'),
            opt('B', 'Plans first, comparison cards', ['exp-paywall-B.png'], 'The artwork slot and title, then plan cards two to a row with Yearly across the width, then the benefits.', 'Prices first; benefits come after the choice.'),
            opt('C', 'Duration picker, selected plan', ['exp-paywall-C.png'], 'A five-way duration picker and one card with the chosen plan in detail, then the benefits.', 'Compact; shows one price at a time, so comparing needs taps.'),
        ],
    },
    {
        'id': 'v8-stats', 'sourceIssueIds': ['UI-078', 'UI-061'], 'scope': 'component family',
        'title': 'Statistics cards (credits, streak, completion)', 'dependencies': [],
        'question': 'Which one template should credits, streak and profile completion share?',
        'baselineId': 'O', 'recommendationId': 'T2',
        'recommendationWhy': 'T2 progress rail fits all three without inventing anything: the credit buckets in spend order, the days of the week, the six profile parts. It reads at a glance and stays compact. The tradeoff is that it is calmer than the ring (T3), which celebrates progress more but only works where a true denominator exists.',
        'options': [
            opt('O', 'Selected cards (baseline)', ['base-wallet.png', 'base-streak.png', 'base-completion.png'], 'The purple credits and streak summary cards and the completion card as selected.', ''),
            opt('T1', 'Number first', ['exp-stats-T1.png'], 'Icon and heading, the figure large, then the detail lines. No bar.', 'Least visual; progress is words only.'),
            opt('T2', 'Progress rail', ['exp-stats-T2.png'], 'The figure, then one full-width rail: credit buckets, the week, or the six profile parts.', ''),
            opt('T3', 'Goal ring', ['exp-stats-T3.png'], 'A ring with the figure inside; it fills only against a real whole (earned credits of the cap, day of 7, percent).', 'For credits the ring shows earned of the cap, not the balance.'),
            opt('T4', 'Cadence marks', ['exp-stats-T4.png'], 'Heading and figure on one line, then discrete marks: days, profile parts, earnable credits.', 'Strongest for the streak; credits read as a cap, which can confuse.'),
            opt('T5', 'Side art', ['exp-stats-T5.png'], 'A square artwork slot beside the figures and a compact rail (artwork pending).', 'Needs the mascot art to earn its space.'),
            opt('T6', 'Split metric', ['exp-stats-T6.png'], 'The figure on the left, a divider, heading and detail on the right.', 'Dense; long details wrap into a tall right column.'),
        ],
    },
    {
        'id': 'v8-match', 'sourceIssueIds': ['UI-082', 'UI-028', 'UI-029', 'UI-030'], 'scope': 'screen',
        'title': 'Match screen', 'dependencies': [],
        'question': 'How should a new match be presented? (each option with and without shared interests)',
        'baselineId': 'O', 'recommendationId': 'M4',
        'recommendationWhy': 'M4 match ticket groups the person, the moment and the conversation hook in one card, and keeps both actions in their usual place at the bottom. It degrades cleanly when nothing is shared. The tradeoff is a smaller landscape crop of the photo than M1 or M5.',
        'options': [opt('O', 'Selected match (baseline)', ['exp-match-O-shared.png', 'exp-match-O-none.png'], 'The 3:4 photo, the line under it, the shared-interests card and two actions.')] + [
            opt(m, n, [f'exp-match-{m}-shared.png', f'exp-match-{m}-none.png'], d, t) for m, n, d, t in [
                ('M1', 'Photo spotlight', 'Their portrait leads; title and name on the shared gradient; interests below.', 'Most emotional; text sits on the photo.'),
                ('M2', 'Two portraits', 'Your portrait and theirs side by side under the title; interests below.', 'Needs your own photo; shows an initial without one.'),
                ('M3', 'Shared interests first', 'One card leading with what you both like and a small portrait beside it.', 'Photo is small; strongest conversation hook.'),
                ('M4', 'Match ticket', 'One white card: portrait, light inset divider, details and interests; actions outside.', ''),
                ('M5', 'Celebration sheet', 'A large portrait above a raised panel with title, interests and both actions; thin purple accent at the join.', 'Actions move into the panel.'),
                ('M6', 'Framed portrait', 'The portrait in an offset frame over a small purple accent; a clean vertical stack.', 'Decorative frame; least information above the fold.'),
            ]],
    },
    {
        'id': 'v8-profile', 'sourceIssueIds': ['UI-084', 'UI-042', 'UI-043'], 'scope': 'screen',
        'title': 'Profile hub', 'dependencies': ['v8-stats'],
        'question': 'Which whole-page Profile layout?',
        'baselineId': 'O', 'recommendationId': 'P1',
        'recommendationWhy': 'P1 portrait card gives the identity a calm, centred home and keeps Edit and Preview right under it, then activity, the next step and the groups in the selected order. It changes the least about where things are. The tradeoff is more height before the tiles than the selected Profile A; P10 (your UI-042 sketch) is the bolder alternative but drops the Preview button from the card.',
        'options': [opt('O', 'Selected Profile A (baseline)', ['exp-profile-O.png'], 'Identity row with pills and two actions, credit and streak tiles, next step, groups.')] + [
            opt(p, n, [f'exp-profile-{p}.png'], d) for p, n, d in [
                ('P1', 'Portrait card', 'A white card with the centred photo, name and pills, Edit and Preview; then tiles, next step and groups.'),
                ('P2', 'Compact account', 'Small inline identity, paired compact actions; settings before activity.'),
                ('P3', 'Progress first', 'Profile completion leads as a progress card under the identity.'),
                ('P4', 'Two-column dashboard', 'Identity, then an activity grid: credits and streak side by side, completion across.'),
                ('P5', 'Edit and preview', 'Edit and Preview as a two-way switch under the name; the prompt follows.'),
                ('P6', 'Profile story', 'The prompt leads after the identity; activity at the end.'),
                ('P7', 'Action centre', 'One card gathers Edit, Preview, Verify and the next setup step.'),
                ('P8', 'Account and activity', 'Account groups first, then a distinct Activity section with full-width cards.'),
                ('P9', 'Settings hub', 'A boxed identity, stacked settings sections, then actions and activity.'),
                ('P10', 'Overlapping portrait (UI-042)', 'A large centred photo straddles the top of a white card with the name, status and Edit profile.'),
            ]],
    },
    {
        'id': 'v8-compliment', 'sourceIssueIds': ['UI-083'], 'scope': 'flow',
        'title': 'Sending a Compliment', 'dependencies': [],
        'question': 'UI-083 is approved and is the build default. Keep it, or return to the separate page?',
        'baselineId': 'O', 'recommendationId': 'A',
        'recommendationWhy': 'A is the approved UI-083 flow: the Compliment is written where the conversation will live, the quoted photo or prompt is the standard reply preview, and after sending the thread says plainly that the chat continues once they reply. The tradeoff is less room to show the photo large while writing.',
        'options': [
            opt('O', 'Separate page (before UI-083)', ['flow-compliment-page.png'], 'A full composer page with the photo or prompt card above a text field.'),
            opt('A', 'In the chat (UI-083, default)', ['flow-compliment-photo.png', 'flow-compliment-typed.png', 'flow-compliment-sent.png'], 'Reply mode in the recipient\'s chat; one limited pre-match Compliment; the waiting status after sending.'),
        ],
    },
    {
        'id': 'v8-likes-tile', 'sourceIssueIds': ['UI-034'], 'scope': 'component',
        'title': 'Likes tile in New matches', 'dependencies': [],
        'question': 'UI-034 asked for an illustrated Likes tile first in New matches; a later owner selection moved Likes to the Heart tab. Which applies?',
        'baselineId': 'O', 'recommendationId': None,
        'recommendationWhy': 'No recommendation: this is a product decision between two of your instructions.',
        'options': [
            opt('O', 'No Likes tile (current)', ['base-messages.png'], 'New matches shows matches only; Likes is the Heart tab.'),
            opt('A', 'Likes tile first (UI-034)', [], 'An illustrated rounded-square Likes tile with the count at the top, first in the row.', 'Not built: needs the mascot art and your confirmation that Likes returns to Messages.', status='concept-only'),
        ],
    },
]

TYPE = {
    'displayFamily': [('baseline', 'Default (Plus Jakarta Sans)'), ('fraunces', 'Fraunces'), ('instrument-serif', 'Instrument Serif'), ('dm-serif-display', 'DM Serif Display')],
    'uiFamily': [('baseline', 'Default (Figtree)'), ('manrope', 'Manrope'), ('poppins', 'Poppins')],
    'baseBodySize': [14, 15],
    'screens': ['discover', 'chat', 'form', 'settings'],
}

# Choices from earlier galleries: already applied as the build's defaults, so nothing maps into
# this gallery's groups. Imports carrying them are explained, never silently reinterpreted.
MIGRATION = {
    'fx-da197b7-2026-11-13': {'note': 'The selected-designs export, already applied as the build defaults (Discover O, Profile A, Messages A, Received Compliment A, Credits O, Streak O).', 'map': {}},
}

os.makedirs(os.path.join(A.out, 'img'), exist_ok=True)
missing = []
used = set()
for g in GROUPS:
    for o in g['options']:
        for im in o['images']:
            used.add(im)
for d in TYPE['displayFamily']:
    for u in TYPE['uiFamily']:
        for s in TYPE['screens']:
            used.add(f'type-{d[0]}--{u[0]}--15--{s}.png')
for s in TYPE['screens']:
    used.add(f'type-baseline--baseline--14--{s}.png')
for im in sorted(used):
    src = os.path.join(A.renders, im)
    if os.path.exists(src):
        shutil.copyfile(src, os.path.join(A.out, 'img', im))
    else:
        missing.append(im)

registry = {
    'schemaVersion': 1,
    'galleryRevision': REV,
    'appSourceSha': A.sha,
    'viewport': 'Flutter widget renders of the real app: 393 x 852 logical at 3x (1179 px wide), full demo world, local demo photos, system text 1.0, default typography (15pt body) unless the typography group says otherwise.',
    'groups': GROUPS,
    'typography': {k: v for k, v in TYPE.items()},
    'migration': MIGRATION,
    'missingImages': missing,
}
json.dump(registry, open(os.path.join(A.out, 'registry.json'), 'w', encoding='utf-8'), indent=2)
tpl = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gallery_template.html'), encoding='utf-8').read()
html = tpl.replace('/*REGISTRY*/null', json.dumps(registry))
open(os.path.join(A.out, 'index.html'), 'w', encoding='utf-8', newline='\n').write(html)
print('gallery', A.out, 'revision', REV, 'images', len(used) - len(missing), 'missing', missing)
