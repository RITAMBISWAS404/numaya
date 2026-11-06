# Overnight v3 review folder

Open `gallery/index.html` in a browser. It works offline. Compare Current/A/B/C, choose, then press
**Export choices JSON**. You can also fill `USER_CHOICES.csv`, or reply with text such as
`EXP-001 A; EXP-002 Current; EXP-003 C; EXP-004 B`.

## Folders
| Folder | Contents |
|---|---|
| `screens/current/`, `screens/refined/` | Every view at 390x844 and at 320x693 with 200% text, as full-resolution PNGs |
| `experiments/<id>/{current,refined-control,A,B,C}/` | `phone`, `narrow` and `tall` renders, plus `comparison*.png` |
| `components/` | State boards |
| `mascot/` | Placement board and pose catalog |
| `reports/` | `decisions.md`, `qa.md`, `experiments.csv`, `coverage.csv`, `mascot.csv`, `tools.csv` |

## Not in the git repository
These ship only in the review ZIP:
- `gallery/assets/`
- `components/*/source-vs-flutter.png`, which are Ente Figma source crops (licensing).

To rebuild the gallery:

```
python tools/build_review_gallery.py review-manifest.json gallery
```

All renders are from the Linux Flutter harness, not from a device.
