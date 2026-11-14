"""Builds the capture plan for the complete design-experiment review (2026-11-14).

python tool/design_review/scenes.py <lab_registry.json> <out scenes.json>

Every Design Lab group variant is rendered in the screen where it appears, with the other groups at
the build defaults except the context listed here (an override that would otherwise hide it).
Component groups also get their isolated Visual Lab specimen (/visual-lab/preview/<group>?v=).
"""
import json, sys

reg = json.load(open(sys.argv[1], encoding='utf-8'))
R = {
    'home': '/home', 'likes': '/likes', 'messages': '/messages', 'profile': '/profile',
    'settings': '/profile/settings', 'wallet': '/profile/wallet', 'streak': '/profile/streak',
    'paywall': '/paywall', 'completion': '/profile/complete',
}
# group -> (route, extra choices, flags)
CTX = {
    'match-avatar': ('/messages', {'fx-messages': 'O'}, {}),
    'conversation-row': ('/messages', {'fx-messages': 'O'}, {}),
    'compliment-card': ('/likes?tab=compliments', {}, {}),
    'like-tile': ('/likes', {}, {'premium': True}),
    'profile-header': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O', 'screen-profile': 'C'}, {}),
    'profile-setup': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O'}, {}),
    'prompt-card': ('/home', {'fx-discover': 'O'}, {}),
    'discover-photo': ('/home', {'fx-discover': 'O'}, {}),
    'streak-card': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O', 'screen-profile': 'O'}, {}),
    'wallet-card': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O', 'screen-profile': 'O'}, {}),
    'plan-card': ('/paywall', {'v8-paywall': 'O'}, {}),
    'status-banner': ('/chat/rafa', {}, {}),
    'empty-state': ('/likes?tab=compliments', {}, {}),
    'ea-event-card': ('/events', {}, {'events': True}),
    'v4-event-detail': ('/events/e/ev-board-games-bandra', {}, {'events': True}),
    'v7-nav': ('/home', {}, {}),
    'v7-discover': ('/home', {'fx-discover': 'O'}, {}),
    'v8-profile': ('/profile', {}, {}),
    'v8-match': ('/match/maya', {}, {}),
    'v8-stats': ('/review-stats', {}, {}),
    'v8-paywall': ('/paywall', {}, {}),
    'v8-compliment': ('/compliment/maya?kind=photo&index=0', {}, {}),
    'v7-compliment': ('/home', {'v8-compliment': 'O', 'fx-discover': 'O'}, {'setup': 'compliment'}),
    'v7-profile': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O'}, {}),
    'v7-streak': ('/profile/streak', {'fx-streak': 'O'}, {}),
    'v7-request': ('/request/sam', {}, {}),
    'v7-filters': ('/home', {}, {'setup': 'filters'}),
    'v7-paywall': ('/paywall', {'v8-paywall': 'O'}, {}),
    'v7-likes-locked': ('/likes', {}, {}),
    'v6-quote-style': ('/chat/priya', {}, {'setup': 'reply', 'attachments': True}),
    'v6-voice-bubble': ('/chat/priya', {}, {'attachments': True}),
    'v6-composer': ('/chat/priya', {}, {'attachments': True}),
    'v6-page-title': ('/likes', {}, {'premium': True}),
    'v6-wallet-header': ('/profile/wallet', {'fx-wallet': 'O'}, {}),
    'v6-streak-hero': ('/profile/streak', {'fx-streak': 'O'}, {}),
    'v6-settings-plan': ('/profile/settings', {}, {}),
    'v6-discover-margin': ('/home', {'fx-discover': 'O'}, {}),
    'v4-photo-label': ('/home', {'fx-discover': 'O'}, {}),
    'v4-welcome': ('/visual-lab/preview/v4-welcome', {}, {'specimenOnly': True}),
    'ea-event-filters': ('/events', {}, {'events': True}),
    'ea-event-action': ('/events/e/ev-board-games-bandra', {}, {'events': True}),
    'ea-met-card': ('/events/met/ev-book-swap', {}, {'events': True}),
    'screen-profile': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O'}, {}),
    'screen-heart': ('/likes', {}, {'premium': True}),
    'screen-chats': ('/messages', {'fx-messages': 'O'}, {}),
    'screen-discover': ('/home', {'fx-discover': 'O'}, {}),
    'r8-secondary-button': ('/profile', {}, {}),
    'r8-photo-scrim': ('/home', {}, {}),
    'r8-chat-dividers': ('/messages', {'fx-messages': 'O'}, {}),
    'r8-wallet-value': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O'}, {}),
    'r8-profile-bar': ('/profile', {'v8-profile': 'O', 'fx-profile': 'O'}, {}),
    'fx-discover': ('/home', {}, {}),
    'fx-profile': ('/profile', {'v8-profile': 'O'}, {}),
    'fx-messages': ('/messages', {}, {}),
    'fx-compliment-thread': ('/chat/sam', {}, {}),
    'fx-wallet': ('/profile/wallet', {'v8-stats': 'O'}, {}),
    'fx-streak': ('/profile/streak', {'v8-stats': 'O'}, {}),
}
SKIP = {'motion': 'Motion presets change timing and easing only; a still screenshot cannot show them.'}
COMPONENT_SPECIMENS = {'match-avatar', 'conversation-row', 'compliment-card', 'like-tile', 'profile-header',
                       'profile-setup', 'prompt-card', 'discover-photo', 'streak-card', 'wallet-card',
                       'plan-card', 'status-banner', 'v4-welcome', 'ea-event-card', 'ea-met-card', 'empty-state'}

scenes, plan = [], []
for g in reg['groups']:
    gid = g['id']
    if gid in SKIP:
        plan.append({'group': gid, 'skip': SKIP[gid]})
        continue
    route, ctx, flags = CTX[gid]
    for v in g['variants']:
        vid = v['id']
        choices = dict(ctx)
        # The direction's own component picks, so the screen direction is shown whole.
        for need in g.get('requires', {}).get(vid, []):
            k, val = need.split(':')
            choices[k] = val
        choices[gid] = vid
        shots = []
        if not flags.get('specimenOnly'):
            for view, h in (('top', 852), ('full', 2600)):
                sid = f'{gid}__{vid}__{view}'
                scenes.append({'id': sid, 'route': route, 'choices': choices, 'height': h,
                               'premium': flags.get('premium', False), 'events': flags.get('events', False),
                               'setup': flags.get('setup', ''), 'attachments': flags.get('attachments', False)})
                shots.append(sid)
        if gid in COMPONENT_SPECIMENS:
            sid = f'{gid}__{vid}__specimen'
            scenes.append({'id': sid, 'route': f'/visual-lab/preview/{gid}?v={vid}', 'choices': {gid: vid},
                           'height': 852, 'premium': flags.get('premium', False), 'events': flags.get('events', False),
                           'setup': ''})
            shots.append(sid)
        plan.append({'group': gid, 'variant': vid, 'route': route, 'choices': choices, 'shots': shots})

# The Experiment Lab (overnight v3) experiments still wired into screens.
for exp, route, names in (('matchMoment', '/match/maya', ['current', 'a', 'b', 'c']),
                          ('emptyChats', '/messages', ['current', 'a', 'b', 'c'])):
    for v in names:
        shots = []
        for view, h in (('top', 852),):
            sid = f'exp-{exp}__{v}__{view}'
            scenes.append({'id': sid, 'route': route, 'choices': {'v8-match': 'O'} if exp == 'matchMoment' else {},
                           'height': h, 'premium': False, 'events': False, 'setup': '', 'experiment': [exp, v],
                           'empty': exp == 'emptyChats'})
            shots.append(sid)
        plan.append({'group': f'exp-{exp}', 'variant': v, 'route': route, 'shots': shots})

json.dump({'scenes': scenes, 'plan': plan}, open(sys.argv[2], 'w', encoding='utf-8'), indent=1)
print(len(scenes), 'scenes')
