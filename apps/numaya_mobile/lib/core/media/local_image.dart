import 'dart:io';

import 'package:flutter/widgets.dart';

import 'demo_photos.dart';

/// An image the member picked on this phone ([source] is a file path) or a bundled sample
/// (`asset:<path>`). Nothing here is ever uploaded. [width] decodes it at the size shown.
ImageProvider localImage(String source, {int? width}) {
  final ImageProvider image = source.startsWith('asset:')
      ? AssetImage(source.substring('asset:'.length))
      : FileImage(File(source));
  return width == null ? image : ResizeImage(image, width: width);
}

/// Where to anchor a `BoxFit.cover` crop of [source] so the face stays in frame (the demo set's
/// recorded face position; the centre for anything else).
Alignment localImageFocus(String source) =>
    DemoPhotoLibrary.instance.focusOf(source);

/// The source to draw in a circle or square: the demo set's face crop of [source] when it has one,
/// else [source] itself.
String localImageAvatar(String source) =>
    DemoPhotoLibrary.instance.faceOf(source) ?? source;
