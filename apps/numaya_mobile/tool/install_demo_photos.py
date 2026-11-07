"""Install a local reference-photo set into the demo app (local only; never committed).

Usage (from apps/numaya_mobile):
    python tool/install_demo_photos.py "<photo folder>" [--spec <spec.json>]

The spec (default: <photo folder>/numaya_demo_photos.json) lists the photos to use, in order:

    {"photos": [
      {"file": "Profiles.jpg", "role": "portrait", "face": [0.49, 0.26, 0.23]},
      {"file": "Picnic.jpg",   "role": "scene",    "face": [0.50, 0.31, 0.10]}
    ]}

- role "portrait": the face is large and clear; used for main photos, avatars and thumbnails.
- role "scene": a wider or full-length photo; used only further into a gallery.
- face: [centre x, centre y, face width], each as a fraction of the image width or height.

For each photo the tool writes, into assets/demo/photos/ (git-ignored):
- photo_NN.jpg: a byte-for-byte copy of the original (the original is never modified);
- face_NN.jpg: a 512 x 512 crop centred on the face (portraits only), for circles and squares;
- demo_photos.json: the manifest the app reads at start-up (DemoPhotoLibrary).
Running it again replaces the previous set. With no set installed the app shows its grey
placeholders, as before.
"""
import json
import pathlib
import shutil
import sys

from PIL import Image, ImageOps

APP = pathlib.Path(__file__).resolve().parents[1]
OUT = APP / 'assets' / 'demo' / 'photos'
KEEP = {'README.md'}
FACE_PX = 512


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if not args:
        print(__doc__)
        return 2
    src = pathlib.Path(args[0])
    spec_path = src / 'numaya_demo_photos.json'
    if '--spec' in sys.argv:
        spec_path = pathlib.Path(sys.argv[sys.argv.index('--spec') + 1])
    spec = json.loads(spec_path.read_text(encoding='utf-8'))

    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.iterdir():
        if old.name not in KEEP:
            old.unlink()

    manifest = []
    for n, entry in enumerate(spec['photos'], start=1):
        original = src / entry['file']
        photo = f'photo_{n:02d}.jpg'
        shutil.copyfile(original, OUT / photo)
        fx, fy, fw = entry['face']
        item = {'photo': photo, 'role': entry['role'], 'focus': [fx, fy]}
        if entry['role'] == 'portrait':
            with Image.open(original) as im:
                im = ImageOps.exif_transpose(im).convert('RGB')
                w, h = im.size
                # A square about 2.6 face-widths across, centred a little below the eyes.
                side = min(w, h, max(int(fw * w * 2.6), 1))
                cx, cy = int(fx * w), int(fy * h + 0.15 * fw * w)
                left = min(max(cx - side // 2, 0), w - side)
                top = min(max(cy - side // 2, 0), h - side)
                face = im.crop((left, top, left + side, top + side))
                face = face.resize((FACE_PX, FACE_PX), Image.LANCZOS)
                face_name = f'face_{n:02d}.jpg'
                face.save(OUT / face_name, quality=90)
                item['face'] = face_name
        manifest.append(item)

    (OUT / 'demo_photos.json').write_text(
        json.dumps({'photos': manifest}, indent=2) + '\n', encoding='utf-8')
    print(f'installed {len(manifest)} photos into {OUT}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
