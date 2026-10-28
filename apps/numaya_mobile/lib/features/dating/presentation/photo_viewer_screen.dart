import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/sample_people.dart';

/// A sample person's photos one at a time (happn's profile carousel, Hinge's expanded photo):
/// swipe sideways or use the previous / next buttons; back closes. Opened from any photo on a
/// profile, at that photo.
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({super.key, required this.personId, this.start = 1});

  final String personId;

  /// 1-based photo to open at.
  final int start;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final SamplePerson? _person = personById(widget.personId);
  late int _index = ((_person?.photoCount ?? 1) == 0
      ? 0
      : (widget.start - 1).clamp(0, (_person?.photoCount ?? 1) - 1));
  late final PageController _pages = PageController(initialPage: _index);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int index) {
    final reduced = AppMotion.reduced(context);
    if (reduced) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: AppMotion.state,
        curve: AppMotion.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final person = _person;
    final count = person?.photoCount ?? 0;
    return NumayaScreen(
      scrollable: false,
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: person == null ? null : l10n.photoViewerTitle(person.name),
      ),
      body: person == null || count == 0
          ? EmptyState(
              title: l10n.personMissingTitle,
              body: l10n.personMissingBody,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s4),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: count,
                    onPageChanged: (i) {
                      AppHaptics.fire(context, HapticMoment.selection);
                      setState(() => _index = i);
                    },
                    itemBuilder: (context, i) => Center(
                      child: PhotoPlaceholder(
                        label: l10n.discoverPhotoLabel(person.name, i + 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                _PageDots(count: count, index: _index),
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: [
                    NavIconButton(
                      icon: NumayaIcons.chevronLeft,
                      label: l10n.photoViewerPrevious,
                      onPressed: _index > 0 ? () => _go(_index - 1) : null,
                    ),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.photoViewerPosition(_index + 1, count),
                          textAlign: TextAlign.center,
                          style: AppTypography.weight(
                            AppTypography.row,
                            AppTypography.medium,
                          ),
                        ),
                      ),
                    ),
                    NavIconButton(
                      icon: NumayaIcons.chevronRight,
                      label: l10n.photoViewerNext,
                      onPressed: _index < count - 1
                          ? () => _go(_index + 1)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  l10n.photoViewerNote,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
    );
  }
}

/// Which photo is showing: a longer ink segment for the current one (decorative; the position is
/// read out as text).
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.state),
              curve: AppMotion.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index ? AppColors.ink : AppColors.borderStrong,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
            ),
        ],
      ),
    );
  }
}
