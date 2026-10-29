import 'dart:io';

import 'package:flutter/widgets.dart';

/// An image the member picked on this phone ([source] is a file path) or a bundled sample
/// (`asset:<path>`). Nothing here is ever uploaded. [width] decodes it at the size shown.
ImageProvider localImage(String source, {int? width}) {
  final ImageProvider image = source.startsWith('asset:')
      ? AssetImage(source.substring('asset:'.length))
      : FileImage(File(source));
  return width == null ? image : ResizeImage(image, width: width);
}
