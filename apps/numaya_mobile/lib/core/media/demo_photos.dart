import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../logging/app_logger.dart';

/// One photo of the local demo set (assets/demo/photos/README.md).
@immutable
class DemoPhoto {
  const DemoPhoto({
    required this.source,
    required this.portrait,
    required this.focus,
    this.faceSource,
    this.cover = true,
  });

  /// `asset:` source for [localImage].
  final String source;

  /// A clear, large face: usable as a main photo, avatar or thumbnail. Otherwise a wider scene,
  /// used only further into a gallery.
  final bool portrait;

  /// Where the face is, so a `BoxFit.cover` crop keeps it in frame.
  final Alignment focus;

  /// A square crop centred on the face (portraits only), for circles and square thumbnails.
  final String? faceSource;

  /// Usable as an event cover (false for a photo with text burned in).
  final bool cover;
}

/// The local reference-photo set for the demo, read once at start-up from
/// `assets/demo/photos/demo_photos.json`. The set is git-ignored and installed per machine with
/// `tool/install_demo_photos.py`; when it is absent the library is empty and every surface keeps
/// its grey placeholder, as before.
///
/// Assignments are deterministic: a person at index `k` always gets the same main photo and the
/// same gallery, so a sample profile looks the same on Discover, Likes, Messages, the match
/// screen and the photo viewer.
class DemoPhotoLibrary {
  DemoPhotoLibrary(this.photos)
    : _bySource = {
        for (final p in photos) ...{
          p.source: p,
          if (p.faceSource != null) p.faceSource!: p,
        },
      };

  static const String folder = 'assets/demo/photos/';
  static const String manifest = '${folder}demo_photos.json';

  /// The set in use. Empty until [load] finds an installed set.
  static DemoPhotoLibrary instance = DemoPhotoLibrary(const []);

  final List<DemoPhoto> photos;
  final Map<String, DemoPhoto> _bySource;

  bool get isEmpty => photos.isEmpty;

  /// Parses the manifest the install tool writes.
  factory DemoPhotoLibrary.fromJson(Map<String, Object?> json) {
    final items = (json['photos'] as List? ?? const [])
        .cast<Map<String, Object?>>();
    return DemoPhotoLibrary([
      for (final m in items)
        DemoPhoto(
          source: 'asset:$folder${m['photo']}',
          portrait: m['role'] == 'portrait',
          cover: m['cover'] != false,
          focus: _alignment(m['focus']),
          faceSource: m['face'] == null ? null : 'asset:$folder${m['face']}',
        ),
    ]);
  }

  static Alignment _alignment(Object? focus) {
    if (focus is List && focus.length == 2) {
      final x = (focus[0] as num).toDouble(), y = (focus[1] as num).toDouble();
      return Alignment(x * 2 - 1, y * 2 - 1);
    }
    return Alignment.center;
  }

  /// Loads the installed set, if any. Never throws: a missing or broken set leaves the library
  /// empty (placeholders) and is logged.
  static Future<void> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    try {
      final assets = await AssetManifest.loadFromAssetBundle(b);
      if (!assets.listAssets().contains(manifest)) return;
      final json = jsonDecode(await b.loadString(manifest));
      instance = DemoPhotoLibrary.fromJson(
        (json as Map).cast<String, Object?>(),
      );
    } on Object catch (e, s) {
      const AppLogger('DemoPhotos').error('Demo photo set not loaded', e, s);
    }
  }

  List<DemoPhoto> get _portraits => [
    for (final p in photos)
      if (p.portrait) p,
  ];

  /// A wider scene for an event cover, fixed by [key]; null when no set is installed.
  DemoPhoto? coverFor(int key) {
    final scenes = [
      for (final p in photos)
        if (!p.portrait && p.cover) p,
    ];
    return scenes.isEmpty ? null : scenes[key % scenes.length];
  }

  /// The photo at gallery [position] (1-based) for the person at [index]: a portrait first, then
  /// the rest of the set in a fixed rotation. Null when no set is installed.
  DemoPhoto? photoFor(int index, int position) {
    if (photos.isEmpty || position < 1) return null;
    final portraits = _portraits;
    final main = portraits.isEmpty
        ? photos[index % photos.length]
        : portraits[index % portraits.length];
    if (position == 1) return main;
    final rest = [
      for (final p in photos)
        if (p != main) p,
    ];
    if (rest.isEmpty) return main;
    return rest[(index * 3 + position - 2) % rest.length];
  }

  /// Where to anchor a cover crop of [source] (the face); centre for anything else, including the
  /// face crops, which are already centred.
  Alignment focusOf(String source) {
    final photo = _bySource[source];
    if (photo == null || photo.faceSource == source) return Alignment.center;
    return photo.focus;
  }

  /// The square face crop for [source], when it is a portrait of the set.
  String? faceOf(String source) => _bySource[source]?.faceSource;
}
