import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_registry.dart';
import '../data/media_picker.dart';
import '../data/voice_service.dart';
import 'chat_attachments.dart' show formatClock;

/// The filled round control in the composer's send slot, so nothing moves between states.
class _VoiceAction extends StatelessWidget {
  const _VoiceAction({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    excludeChildSemantics: true,
    pressedScale: 0.92,
    borderRadius: AppRadii.all(AppRadii.control),
    child: SizedBox.square(
      dimension: kMinInteractiveDimension,
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    ),
  );
}

/// A thin position bar. It shows where playback is, not the shape of the sound.
class _VoiceTrack extends StatelessWidget {
  const _VoiceTrack({required this.value, required this.fg, required this.bg});

  final double value;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.all(2),
    child: SizedBox(
      height: 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: bg),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: fg),
          ),
        ],
      ),
    ),
  );
}

enum _BarStage { starting, recording, preview }

/// Replaces the composer while a voice note is made. Recording starts at once and asks for the
/// microphone at that moment. Bin discards; Stop leads to a preview that can be played before Send.
/// Leaving the chat discards an unsent recording.
class VoiceRecorderBar extends ConsumerStatefulWidget {
  const VoiceRecorderBar({
    super.key,
    required this.onClose,
    required this.onSend,
  });

  final VoidCallback onClose;
  final ValueChanged<MessageAttachment> onSend;

  @override
  ConsumerState<VoiceRecorderBar> createState() => _VoiceRecorderBarState();
}

class _VoiceRecorderBarState extends ConsumerState<VoiceRecorderBar> {
  static const _max = 120;

  late final VoiceRecorder _recorder;
  _BarStage _stage = _BarStage.starting;
  int _seconds = 0;
  Timer? _timer;
  MessageAttachment? _note;
  bool _sent = false;

  VoicePlayer? _player;
  bool _playing = false;
  Duration _at = Duration.zero;
  final _subs = <StreamSubscription<void>>[];

  @override
  void initState() {
    super.initState();
    _recorder = ref.read(voiceRecorderFactoryProvider)();
    _begin();
  }

  Future<void> _begin() async {
    final result = await _recorder.start();
    if (!mounted) return;
    final l10n = context.l10n;
    switch (result) {
      case VoiceStart.started:
        setState(() => _stage = _BarStage.recording);
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() => _seconds++);
          if (_seconds >= _max) _stop();
        });
      case VoiceStart.denied:
        NumayaToast.show(context, l10n.voicePermissionDenied);
        widget.onClose();
      case VoiceStart.unavailable:
        NumayaToast.show(context, l10n.voiceUnavailable);
        widget.onClose();
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final l10n = context.l10n;
    if (_seconds < 1) {
      await _recorder.cancel();
      if (!mounted) return;
      NumayaToast.show(context, l10n.voiceTooShort);
      widget.onClose();
      return;
    }
    final note = await _recorder.stop(Duration(seconds: _seconds));
    if (!mounted) return;
    if (note == null) {
      NumayaToast.show(context, l10n.voiceUnavailable);
      widget.onClose();
      return;
    }
    setState(() {
      _note = note;
      _stage = _BarStage.preview;
    });
  }

  Future<void> _discard() async {
    _timer?.cancel();
    await _player?.stop();
    await _recorder.cancel();
    if (mounted) widget.onClose();
  }

  Future<void> _togglePlay() async {
    final note = _note;
    if (note == null) return;
    if (_player == null) {
      final p = ref.read(voicePlayerFactoryProvider)(note);
      _player = p;
      _subs
        ..add(
          p.position.listen((d) {
            if (mounted) setState(() => _at = d);
          }),
        )
        ..add(
          p.completed.listen((_) {
            if (mounted) {
              setState(() {
                _playing = false;
                _at = Duration.zero;
              });
            }
          }),
        );
      setState(() => _playing = true);
      await p.play(note);
      return;
    }
    if (_playing) {
      setState(() => _playing = false);
      await _player!.pause();
    } else {
      setState(() => _playing = true);
      await _player!.resume();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    unawaited(_player?.dispose());
    // Leaving with an unsent recording discards it.
    if (!_sent) unawaited(_recorder.cancel());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final time = formatClock(Duration(seconds: _seconds));
    final preview = _stage == _BarStage.preview;
    final length = _note?.duration ?? Duration(seconds: _seconds);
    final value = length.inMilliseconds == 0
        ? 0.0
        : _at.inMilliseconds / length.inMilliseconds;
    return Row(
      key: const ValueKey('voice-bar'),
      children: [
        NavIconButton(
          key: const ValueKey('voice-discard'),
          icon: NumayaIcons.trash,
          label: l10n.voiceDiscard,
          style: NavButtonStyle.plain,
          onPressed: _discard,
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            padding: EdgeInsets.only(
              left: preview ? AppSpacing.s1 : AppSpacing.s4,
              right: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppRadii.all(AppRadii.field),
            ),
            child: preview
                ? Row(
                    children: [
                      Pressable(
                        key: const ValueKey('voice-preview-play'),
                        onTap: _togglePlay,
                        semanticLabel: _playing
                            ? l10n.voicePause
                            : l10n.voicePlay,
                        excludeChildSemantics: true,
                        borderRadius: AppRadii.all(AppRadii.control),
                        child: SizedBox.square(
                          dimension: kMinInteractiveDimension,
                          child: Center(
                            child: MobileIcon(
                              _playing
                                  ? NumayaMobileIcons.pause
                                  : NumayaMobileIcons.play,
                              size: AppSizes.iconMd,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _VoiceTrack(
                          value: value,
                          fg: AppColors.accent,
                          bg: AppColors.fillStrong,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Text(
                        formatClock(length),
                        style: AppTypography.bodySm.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  )
                : Semantics(
                    liveRegion: true,
                    label: l10n.voiceRecordingLabel(time),
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.errorBase,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s2),
                          Text(
                            time,
                            style: AppTypography.row.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: Text(
                              l10n.voiceRecording,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.s2 - 2),
        if (preview)
          _VoiceAction(
            key: const ValueKey('voice-send'),
            label: l10n.voiceSend,
            onTap: () {
              _sent = true;
              widget.onSend(_note!);
            },
            child: const NumayaIcon(
              NumayaIcons.arrowUp,
              size: 22,
              color: AppColors.inkForeground,
            ),
          )
        else
          _VoiceAction(
            key: const ValueKey('voice-stop'),
            label: l10n.voiceStop,
            onTap: _stage == _BarStage.recording ? _stop : null,
            child: const MobileIcon(
              NumayaMobileIcons.stop,
              size: 22,
              color: AppColors.inkForeground,
            ),
          ),
      ],
    );
  }
}

/// A voice note in the conversation: play, position and length. A note with no sound says so.
class VoiceMessage extends ConsumerStatefulWidget {
  const VoiceMessage({
    super.key,
    required this.attachment,
    required this.mine,
    required this.width,
  });

  final MessageAttachment attachment;
  final bool mine;
  final double width;

  @override
  ConsumerState<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends ConsumerState<VoiceMessage> {
  VoicePlayer? _player;
  final _subs = <StreamSubscription<void>>[];
  bool _playing = false;
  bool _failed = false;
  Duration _at = Duration.zero;

  Future<void> _toggle() async {
    try {
      if (_player == null) {
        final p = ref.read(voicePlayerFactoryProvider)(widget.attachment);
        _player = p;
        _subs
          ..add(
            p.position.listen((d) {
              if (mounted) setState(() => _at = d);
            }),
          )
          ..add(
            p.completed.listen((_) {
              if (!mounted) return;
              unawaited(_player?.dispose());
              setState(() {
                _player = null;
                _playing = false;
                _at = Duration.zero;
              });
            }),
          );
        setState(() {
          _playing = true;
          _failed = false;
        });
        await p.play(widget.attachment);
      } else if (_playing) {
        setState(() => _playing = false);
        await _player!.pause();
      } else {
        setState(() => _playing = true);
        await _player!.resume();
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _playing = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    unawaited(_player?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = ref.watch(labVariantProvider('v6-voice-bubble')) == 'A';
    final mine = widget.mine;
    final a = widget.attachment;
    final length = a.duration ?? Duration.zero;
    final value = length.inMilliseconds == 0
        ? 0.0
        : _at.inMilliseconds / length.inMilliseconds;
    final fg = mine ? AppColors.accentForeground : AppColors.ink;
    final muted = mine
        ? AppColors.accentForeground.withValues(alpha: 0.85)
        : AppColors.textSecondary;
    final time = formatClock(_playing || _at > Duration.zero ? _at : length);
    return Container(
      width: compact ? null : widget.width,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s2,
        AppSpacing.s2,
        AppSpacing.s4,
        AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: mine ? AppColors.accent : AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Pressable(
                onTap: _toggle,
                semanticLabel:
                    '${_playing ? l10n.voicePause : l10n.voicePlay}, ${formatClock(length)}',
                excludeChildSemantics: true,
                pressedScale: 0.92,
                borderRadius: AppRadii.all(AppRadii.control),
                child: SizedBox.square(
                  dimension: kMinInteractiveDimension,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: mine
                            ? AppColors.accentForeground
                            : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: MobileIcon(
                        _playing
                            ? NumayaMobileIcons.pause
                            : NumayaMobileIcons.play,
                        size: 20,
                        color: mine
                            ? AppColors.accent
                            : AppColors.accentForeground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              if (!compact)
                Expanded(
                  child: _VoiceTrack(
                    value: value,
                    fg: fg,
                    bg: mine ? const Color(0x4DFFFFFF) : AppColors.fill,
                  ),
                ),
              const SizedBox(width: AppSpacing.s3),
              Text(
                time,
                style: AppTypography.caption.copyWith(
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (a.sample || _failed)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.s3,
                bottom: AppSpacing.s1,
              ),
              child: Text(
                _failed ? l10n.voicePlayFailed : l10n.voiceSampleNote,
                style: AppTypography.caption.copyWith(color: muted),
              ),
            ),
        ],
      ),
    );
  }
}
