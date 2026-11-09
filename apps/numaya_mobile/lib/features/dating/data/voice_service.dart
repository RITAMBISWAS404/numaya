import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/logging/app_logger.dart';
import 'media_picker.dart';

enum VoiceStart { started, denied, unavailable }

/// Records one voice note. The microphone is requested when recording starts, not earlier. The
/// file stays on this device, like every other message in this build.
abstract interface class VoiceRecorder {
  Future<VoiceStart> start();

  /// Finishes and returns the note, or null if nothing was captured.
  Future<MessageAttachment?> stop(Duration elapsed);

  /// Discards the recording: nothing is kept.
  Future<void> cancel();

  Future<void> dispose();
}

class DeviceVoiceRecorder implements VoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  static const _log = AppLogger('Voice');
  String? _path;

  @override
  Future<VoiceStart> start() async {
    try {
      if (!await _recorder.hasPermission()) return VoiceStart.denied;
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _path = path;
      return VoiceStart.started;
    } on MissingPluginException {
      return VoiceStart.unavailable;
    } on Exception catch (e) {
      _log.info('Recording failed to start (${e.runtimeType})');
      return VoiceStart.unavailable;
    }
  }

  @override
  Future<MessageAttachment?> stop(Duration elapsed) async {
    final path = await _recorder.stop();
    if (path == null) return null;
    _path = null;
    return MessageAttachment(
      kind: AttachmentKind.voice,
      source: path,
      duration: elapsed,
    );
  }

  @override
  Future<void> cancel() async {
    final path = _path;
    _path = null;
    if (path == null) return;
    try {
      await _recorder.cancel();
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } on Exception catch (e) {
      _log.info('Could not discard the recording (${e.runtimeType})');
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

/// Sample media mode and tests: no microphone, and the note says it has no sound.
class DemoVoiceRecorder implements VoiceRecorder {
  @override
  Future<VoiceStart> start() async => VoiceStart.started;

  @override
  Future<MessageAttachment?> stop(Duration elapsed) async => MessageAttachment(
    kind: AttachmentKind.voice,
    duration: elapsed,
    sample: true,
  );

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
}

/// Plays one voice note.
abstract interface class VoicePlayer {
  Stream<Duration> get position;
  Stream<void> get completed;
  Future<void> play(MessageAttachment note);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}

class DeviceVoicePlayer implements VoicePlayer {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<Duration> get position => _player.onPositionChanged;

  @override
  Stream<void> get completed => _player.onPlayerComplete;

  @override
  Future<void> play(MessageAttachment note) =>
      _player.play(DeviceFileSource(note.source!));

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

/// A note with no sound: the position advances so the controls can be exercised.
class DemoVoicePlayer implements VoicePlayer {
  final _position = StreamController<Duration>.broadcast();
  final _completed = StreamController<void>.broadcast();
  Timer? _timer;
  Duration _at = Duration.zero;
  Duration _length = Duration.zero;

  void _tick() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _at += const Duration(milliseconds: 200);
      if (_at >= _length) {
        _timer?.cancel();
        _at = Duration.zero;
        _completed.add(null);
      } else {
        _position.add(_at);
      }
    });
  }

  @override
  Stream<Duration> get position => _position.stream;

  @override
  Stream<void> get completed => _completed.stream;

  @override
  Future<void> play(MessageAttachment note) async {
    _length = note.duration ?? Duration.zero;
    _at = Duration.zero;
    _timer?.cancel();
    _tick();
  }

  @override
  Future<void> pause() async => _timer?.cancel();

  @override
  Future<void> resume() async {
    _timer?.cancel();
    _tick();
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _at = Duration.zero;
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    await _position.close();
    await _completed.close();
  }
}

/// Makes a recorder for one recording.
final voiceRecorderFactoryProvider = Provider<VoiceRecorder Function()>(
  (ref) => ref.watch(sampleMediaProvider)
      ? DemoVoiceRecorder.new
      : DeviceVoiceRecorder.new,
);

/// Makes a player for one note. A note with no file gets the silent player.
final voicePlayerFactoryProvider =
    Provider<VoicePlayer Function(MessageAttachment)>(
      (ref) =>
          (note) => note.sample || note.source == null
          ? DemoVoicePlayer()
          : DeviceVoicePlayer(),
    );
