def L(h):
    c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    c=[x/12.92 if x<=0.04045 else ((x+0.055)/1.055)**2.4 for x in c]
    return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2]
def r(a,b):
    la,lb=sorted([L(a),L(b)],reverse=True); return (la+0.05)/(lb+0.05)
T=dict(canvas='F4F4F6',surface='FFFFFF',fill='ECECF0',field='EAEAEF',fieldPressed='DDDDE3',ink='18181B',text2='4A4A53',muted='696972',brand='7262C7',brandText='5B4BB0',brandSubtle='F1EFF9',onBrand='FFFFFF',danger='C8383B',dangerSubtle='FBEDED',warning='8A5A00',warningSubtle='FBF3E2',success='2B774B',successSubtle='E8F3EC',outline='8B8B94',disabled='E4E4E9',disabledText='8A8A93')
pairs=[
('ink','canvas','Page titles, body','text',4.5),('ink','surface','Card text','text',4.5),('ink','field','Field value, secondary button label, Pass','text',4.5),
('text2','canvas','Secondary text on page','text',4.5),('text2','surface','Secondary text in cards','text',4.5),('text2','fill','Chip labels on fill','text',4.5),
('muted','surface','Captions, values, placeholders in cards','text',4.5),('muted','canvas','Footnotes on page','text',4.5),('muted','field','Field placeholder','text',4.5),('muted','fill','Muted text on fill','text',4.5),
('onBrand','brand','Primary button, Like, own bubble, selected pill','text',4.5),
('brandText','surface','Links, badges, metric number in cards','text',4.5),('brandText','canvas','Purple text on page','text',4.5),('brandText','brandSubtle','Tinted pill / InfoCard text, selected tab icon','text',4.5),
('brand','brandSubtle','SuperSwipe star, tint marks (non-text)','ui',3.0),('brand','surface','Progress fill, switch on, radio (non-text)','ui',3.0),('brand','canvas','Step segments on page (non-text)','ui',3.0),
('danger','surface','Destructive text','text',4.5),('onBrand','danger','Destructive solid button','text',4.5),('danger','dangerSubtle','Error banner text','text',4.5),
('warning','warningSubtle','Warning banner text','text',4.5),('success','successSubtle','Success text','text',4.5),
('outline','surface','Radio/checkbox ring, switch-off edge (non-text)','ui',3.0),('disabledText','disabled','Disabled button label (exempt)','exempt',0),
]
print('| Foreground | Background | Used for | Ratio | Needs | Result |\n|---|---|---|---|---|---|')
for f,b,u,k,need in pairs:
    v=r(T[f],T[b]); res='exempt (disabled)' if k=='exempt' else ('pass' if v>=need else 'FAIL')
    print(f'| `{f}` #{T[f]} | `{b}` #{T[b]} | {u} | {v:.2f}:1 | {need if need else "—"} | {res} |')
