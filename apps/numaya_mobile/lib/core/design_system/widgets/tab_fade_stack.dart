import 'package:flutter/widgets.dart';

import '../foundations/app_motion.dart';

/// The tab container (V9 motion, docs/v9/design-decisions.md D-09). Like an [IndexedStack], every
/// tab stays mounted and keeps its scroll position and state; only the selected one is on stage.
/// When the selection changes, the new tab fades in over [AppMotion.state] (200ms, ease-out) so the
/// switch reads as one surface changing rather than a hard cut. Nothing moves, so it is safe for
/// vestibular comfort, and under reduced motion the switch is instant.
class TabFadeStack extends StatefulWidget {
  const TabFadeStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<TabFadeStack> createState() => _TabFadeStackState();
}

class _TabFadeStackState extends State<TabFadeStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 1,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _fade,
    curve: AppMotion.easeOut,
  );

  @override
  void didUpdateWidget(TabFadeStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      final d = AppMotion.duration(context, AppMotion.base);
      if (d == Duration.zero) {
        _fade.value = 1;
      } else {
        _fade.duration = d;
        _fade.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Offstage(
            offstage: i != widget.index,
            child: TickerMode(
              enabled: i == widget.index,
              // The same widget type in every slot at all times, so a tab is never remounted.
              child: FadeTransition(
                opacity: i == widget.index ? _curved : kAlwaysCompleteAnimation,
                child: widget.children[i],
              ),
            ),
          ),
      ],
    );
  }
}
