import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/logging/app_logger.dart';

/// What a chat attachment is.
enum AttachmentKind { photo, video, voice }

/// A photo, video or voice note attached to a message. [source] is a local file path, or
/// `asset:<path>` for the bundled sample media. Nothing is uploaded: the attachment stays on this
/// device, like the message it belongs to.
@immutable
class MessageAttachment {
  const MessageAttachment({
    required this.kind,
    this.source,
    this.name,
    this.sizeBytes,
    this.duration,
    this.sample = false,
  });

  final AttachmentKind kind;
  final String? source;
  final String? name;
  final int? sizeBytes;

  /// Known for demo voice notes; videos from the picker don't report one without a player.
  final Duration? duration;

  /// Bundled sample media, or a demo voice note with no audio. Labelled in the UI.
  final bool sample;
}

/// Why a pick didn't produce an attachment.
enum MediaFailure {
  permissionDenied,
  unsupported,
  tooLarge,
  unreadable,
  unavailable,
}

class MediaPickException implements Exception {
  const MediaPickException(this.reason);
  final MediaFailure reason;

  @override
  String toString() => 'MediaPickException(${reason.name})';
}

/// Chooses photos and videos for chat. Returns null when the person cancels.
abstract interface class MediaPicker {
  Future<MessageAttachment?> pickPhoto();
  Future<MessageAttachment?> pickVideo();
}

/// The phone's own picker (Android's Photo Picker through `image_picker`). Needs no storage
/// permission on current Android. Files stay where they are; only the path is kept.
class DeviceMediaPicker implements MediaPicker {
  DeviceMediaPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const _log = AppLogger('Media');

  /// Larger videos are refused: the demo keeps files on the device and a real service would set its
  /// own limit.
  static const int maxVideoBytes = 100 * 1024 * 1024;

  static const _photoTypes = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'heic',
    'heif',
  };
  static const _videoTypes = {'mp4', 'mov', 'm4v', '3gp', 'webm', 'mkv'};

  @override
  Future<MessageAttachment?> pickPhoto() => _pick(
    () => _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    ),
    AttachmentKind.photo,
    _photoTypes,
  );

  @override
  Future<MessageAttachment?> pickVideo() => _pick(
    () => _picker.pickVideo(source: ImageSource.gallery),
    AttachmentKind.video,
    _videoTypes,
  );

  Future<MessageAttachment?> _pick(
    Future<XFile?> Function() pick,
    AttachmentKind kind,
    Set<String> types,
  ) async {
    final XFile? file;
    try {
      file = await pick();
    } on MissingPluginException {
      throw const MediaPickException(MediaFailure.unavailable);
    } on PlatformException catch (e) {
      _log.info('Picker failed (${e.code})');
      throw MediaPickException(
        e.code.contains('access_denied')
            ? MediaFailure.permissionDenied
            : MediaFailure.unreadable,
      );
    }
    if (file == null) return null;
    final ext = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : '';
    if (!types.contains(ext)) {
      throw const MediaPickException(MediaFailure.unsupported);
    }
    final int size;
    try {
      size = await file.length();
    } on Exception {
      throw const MediaPickException(MediaFailure.unreadable);
    }
    if (kind == AttachmentKind.video && size > maxVideoBytes) {
      throw const MediaPickException(MediaFailure.tooLarge);
    }
    return MessageAttachment(
      kind: kind,
      source: file.path,
      name: file.name,
      sizeBytes: size,
    );
  }
}

/// Bundled sample media, for emulators with an empty gallery, desktop runs and tests. Chosen in
/// the Demo Hub; the bubbles say "Sample".
class SampleMediaPicker implements MediaPicker {
  const SampleMediaPicker();

  static const photo = MessageAttachment(
    kind: AttachmentKind.photo,
    source: 'asset:assets/demo/sample_photo.jpg',
    name: 'columbia-road.jpg',
    sizeBytes: 20530,
    sample: true,
  );

  /// No video file is bundled (it would add megabytes); the sample is a file card only.
  static const video = MessageAttachment(
    kind: AttachmentKind.video,
    name: 'market-walk.mp4',
    sizeBytes: 8 * 1024 * 1024 + 400 * 1024,
    sample: true,
  );

  @override
  Future<MessageAttachment?> pickPhoto() async => photo;

  @override
  Future<MessageAttachment?> pickVideo() async => video;
}

/// Demo Hub switch: use [SampleMediaPicker] instead of the phone's gallery.
class SampleMediaController extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool on) => state = on;
}

final sampleMediaProvider = NotifierProvider<SampleMediaController, bool>(
  SampleMediaController.new,
);

final mediaPickerProvider = Provider<MediaPicker>(
  (ref) => ref.watch(sampleMediaProvider)
      ? const SampleMediaPicker()
      : DeviceMediaPicker(),
);
