import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';

/// Floating status pill (`.theme-withings .pill`): the reference's light blue pill ("Password
/// created"): blue tint, deep-blue semibold text, a soft float shadow, three pulsing dots while
/// busy. Announced to screen readers. Returns a handle so busy toasts can be closed by the caller.
abstract final class NumayaToast {
  static ToastHandle show(
    BuildContext context,
    String message, {
    bool busy = false,
    Duration? duration = const Duration(milliseconds: 2200),
    bool aboveFooter = true,
    bool belowHeader = false,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    final handle = ToastHandle._(() => entry.remove());
    entry = OverlayEntry(
      builder: (context) => _ToastView(
        message: message,
        busy: busy,
        aboveFooter: aboveFooter,
        belowHeader: belowHeader,
        handle: handle,
      ),
    );
    overlay.insert(entry);
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
    if (duration != null) Future<void>.delayed(duration, handle.close);
    return handle;
  }
}

class ToastHandle {
  ToastHandle._(this._remove);
  final VoidCallback _remove;
  bool _closed = false;
  VoidCallback? _animateOut;

  /// Closes the toast (idempotent).
  void close() {
    if (_closed) return;
    _closed = true;
    final out = _animateOut;
    if (out != null) {
      out();
    } else {
      _remove();
    }
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.busy,
    required this.aboveFooter,
    required this.handle,
    this.belowHeader = false,
  });

  final String message;
  final bool busy;
  final bool aboveFooter;

  /// Just under a 56pt top bar, for screens whose content runs down to the tab bar (Discover's
  /// photo card), where a bottom toast would cover the name or the tabs.
  final bool belowHeader;
  final ToastHandle handle;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  )..forward();
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    widget.handle._animateOut = () async {
      if (!mounted) return widget.handle._remove();
      await _in.animateBack(
        0,
        duration: AppMotion.base,
        curve: AppMotion.easeInOut,
      );
      widget.handle._remove();
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The busy dots loop only while the toast is up, and not at all under reduced motion.
    final loop = widget.busy && !AppMotion.reduced(context);
    if (loop && !_dots.isAnimating) {
      unawaited(_dots.repeat());
    } else if (!loop && _dots.isAnimating) {
      _dots.stop();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final media = MediaQuery.of(context);
    final bottom =
        media.padding.bottom +
        media.viewInsets.bottom +
        (widget.aboveFooter ? 104 : 20);
    final curved = CurvedAnimation(parent: _in, curve: AppMotion.easeOut);
    return Positioned(
      left: 0,
      right: 0,
      top: widget.belowHeader
          ? media.padding.top + AppSizes.topBar + AppSpacing.s4
          : null,
      bottom: widget.belowHeader ? null : bottom,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: reduced
                  ? const AlwaysStoppedAnimation(Offset.zero)
                  : Tween(
                      begin: Offset(0, widget.belowHeader ? -0.4 : 0.4),
                      end: Offset.zero,
                    ).animate(curved),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    // A pill for one line; the same radius stays soft when a message wraps.
                    borderRadius: AppRadii.all(20),
                    boxShadow: AppElevation.withingsFloat,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Wraps instead of overflowing: some messages (picker errors) run long.
                      Flexible(
                        child: Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style:
                              AppTypography.weight(
                                AppTypography.bodySm,
                                AppTypography.semibold,
                              ).copyWith(
                                fontSize: 14,
                                height: 18 / 14,
                                color: AppColors.accentOnTint,
                              ),
                        ),
                      ),
                      if (widget.busy) ...[
                        const SizedBox(width: 8),
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(width: 3),
                          AnimatedBuilder(
                            animation: _dots,
                            builder: (context, _) {
                              final t = ((_dots.value - i * 0.14) % 1 + 1) % 1;
                              final o = reduced
                                  ? 1.0
                                  : (t < 0.5
                                        ? 0.35 + t * 1.3
                                        : 1 - (t - 0.5) * 1.3);
                              return Opacity(
                                opacity: o.clamp(0.3, 1.0),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentOnTint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
