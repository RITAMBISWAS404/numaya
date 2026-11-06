import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart';
import 'primitives.dart';

/// The Numaya mark: a soft square with a bite out of its corner and a rose dot in the bite. In V16
/// the square is Withings blue (COMPONENT_RULES.md: "mark in accent blue, rose dot kept").
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _BrandMarkPainter());
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;
    canvas.scale(s);
    final square = Path()
      ..addRRect(RRect.fromLTRBR(2, 2, 30, 30, const Radius.circular(9)));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: const Offset(27, 5), radius: 7));
    canvas.drawPath(
      Path.combine(PathOperation.difference, square, bite),
      Paint()..color = AppColors.accent,
    );
    canvas.drawCircle(
      const Offset(27, 5),
      3.5,
      Paint()..color = AppColors.accentRose,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mark plus the "numaya" wordmark in bold Hanken Grotesk ink.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.small = false, this.maxWidth});
  final bool small;

  /// The room the wordmark may take. When the full mark and word would not fit (Discover's header
  /// between its buttons on a 320pt phone, or at large text), the mark alone stands for the brand,
  /// rather than the word running under the buttons or being shrunk.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final mark = BrandMark(size: small ? 20 : 26);
    final gap = small ? 7.0 : 8.0;
    final style = AppTypography.wordmark(small: small);
    var fits = true;
    if (maxWidth != null) {
      final word = TextPainter(
        text: TextSpan(text: 'numaya', style: style),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      fits = mark.size + gap + word.width <= maxWidth!;
      word.dispose();
    }
    return Semantics(
      label: 'Numaya',
      excludeSemantics: true,
      child: fits
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                mark,
                SizedBox(width: gap),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text('numaya', style: style),
                ),
              ],
            )
          : mark,
    );
  }
}

/// Spot illustrations shared with the web (exported by tool/export_assets.mjs).
enum NumayaIllustration {
  verified,
  hello,
  interests,
  noChats,
  noMatch,
  seenEveryone,
  paused,
  unmatched,
  blocked,

  /// Mobile-only scenes drawn in the same style (assets/illustrations/mobile/, not the web export).
  noEvents,
  eventGoing,
  notEnoughData,

  /// The Numaya mascot (overnight polish, OP-06): a purple cat with large ears, waiting with a
  /// heart. Original artwork; used where the person is waiting on someone else (no likes yet).
  mascotWaiting;

  String get asset {
    final file = switch (this) {
      noChats => 'no-chats',
      noMatch => 'no-match',
      seenEveryone => 'seen-everyone',
      noEvents => 'mobile/no-events',
      eventGoing => 'mobile/event-going',
      notEnoughData => 'mobile/not-enough-data',
      mascotWaiting => 'mobile/mascot-waiting',
      _ => name,
    };
    return 'assets/illustrations/$file.svg';
  }

  /// Width / height of the drawing's canvas.
  double get aspectRatio => this == hello || this == interests ? 1 : 4 / 3;
}

/// Decorative illustration; the surrounding copy carries the meaning.
class IllustrationView extends StatelessWidget {
  const IllustrationView(this.illustration, {super.key, required this.width});

  final NumayaIllustration illustration;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        illustration.asset,
        width: width,
        height: width / illustration.aspectRatio,
      ),
    );
  }
}

/// Information box, as Ente's Banner (14590:125245, OV-01): a white card on the grey page with no
/// tint or border, the icon in Numaya purple aligned with the title (UI-010), a semibold ink title
/// and a muted body. It explains; it is not a card you open.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.body,
  });

  final NumayaIcons icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      // UI-010: the icon sits at the top left, aligned with the first line of the content (a
      // 20pt icon on a 20pt line), however many lines follow.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumayaIcon(icon, size: AppSizes.iconMd, color: AppColors.accent),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.weight(
                    AppTypography.bodySm,
                    AppTypography.semibold,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    body!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Prompt card (`.theme-withings .prompt`): a white card (14pt corner, no border) with the question
/// as the card title beside a round tint mark, and the answer in semibold below. Without an answer
/// it becomes the call to write one; [onTap] adds a chevron.
class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.question,
    required this.answer,
    this.onTap,
    this.emptyLabel,
    this.editLabel,
  });

  final String question;
  final String? answer;
  final VoidCallback? onTap;
  final String? emptyLabel;
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = answer != null && answer!.isNotEmpty;
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UI-007: the prompt is a small secondary label, the response the dominant text; no
          // leading decorative icon. The chevron stays: it says the card opens an editor.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (onTap != null)
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: AppSizes.iconMd,
                  color: AppColors.textMuted,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          // An empty card's affordance stays body-sized and muted, so it never reads as an answer.
          Text(
            hasAnswer ? answer! : (emptyLabel ?? ''),
            style: hasAnswer
                ? AppTypography.promptAnswer
                : AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return Semantics(label: '$question. ${answer ?? ''}', child: card);
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: hasAnswer
          ? '${editLabel ?? question}. $answer'
          : '$question. ${emptyLabel ?? ''}',
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: card,
    );
  }
}

/// The prompt mark: a blue speech bubble in a round 24pt tint holder.
class PromptMark extends StatelessWidget {
  const PromptMark({super.key});

  @override
  Widget build(BuildContext context) => const NumayaIcon(
    // The icon on its own beside the heading (RD-08); no holder.
    NumayaIcons.message,
    size: AppSizes.iconSm,
    color: AppColors.accent,
  );
}

/// One photo in a grid, by id. [tone] picks the placeholder shade until real images exist.
class GridPhoto {
  const GridPhoto({required this.id, required this.tone, this.image});
  final int id;
  final int tone;

  /// The real photo, when there is one; otherwise the tile is the placeholder grey.
  final ImageProvider? image;
}

/// 3 × 2 photo grid (`.theme-withings .photo-grid`): 14pt tiles in the warm photo grey with an order
/// tag ("Main", 2, 3: 6pt corner) and a round remove button; empty slots are white with a dashed
/// edge and an ink "+" circle.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.onOpen,
    this.openLabel,
    required this.mainLabel,
    required this.addLabel,
    required this.removeLabel,
    this.slots = 6,
  });

  final List<GridPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  /// Tapping a filled photo (photo options: make main, remove). Receives the photo id.
  final ValueChanged<int>? onOpen;

  /// Accessible label for that action, by 1-based position.
  final String Function(int position)? openLabel;
  final String mainLabel;
  final String addLabel;
  final String Function(int position) removeLabel;
  final int slots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final w = (constraints.maxWidth - gap * 2) / 3;
        final h = w * 4 / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < slots; i++)
              SizedBox(
                width: w,
                height: h,
                child: i < photos.length ? _filled(i, photos[i]) : _empty(),
              ),
          ],
        );
      },
    );
  }

  Widget _tile(GridPhoto photo) => ClipRRect(
    borderRadius: AppRadii.all(AppRadii.card),
    child: photo.image == null
        ? const ColoredBox(color: AppColors.photo)
        : Image(
            image: photo.image!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.photo),
          ),
  );

  Widget _filled(int i, GridPhoto photo) {
    return Semantics(
      label: i == 0 ? '$mainLabel photo' : 'Photo ${i + 1}',
      child: Stack(
        children: [
          Positioned.fill(
            child: onOpen == null
                ? _tile(photo)
                : Pressable(
                    onTap: () => onOpen!(photo.id),
                    semanticLabel: openLabel?.call(i + 1),
                    excludeChildSemantics: true,
                    pressedScale: 0.97,
                    borderRadius: AppRadii.all(AppRadii.card),
                    child: SizedBox.expand(child: _tile(photo)),
                  ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.tag),
              ),
              child: Text(
                i == 0 ? mainLabel : '${i + 1}',
                style: AppTypography.weight(
                  AppTypography.micro,
                  AppTypography.semibold,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Pressable(
              onTap: () => onRemove(photo.id),
              semanticLabel: removeLabel(i + 1),
              excludeChildSemantics: true,
              borderRadius: AppRadii.all(AppRadii.tag),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInverse,
                  borderRadius: AppRadii.all(AppRadii.tag),
                ),
                alignment: Alignment.center,
                child: const NumayaIcon(
                  NumayaIcons.close,
                  size: 16,
                  color: AppColors.textOnInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Any empty slot adds the next photo at the end, so photos stay in order.
  Widget _empty() {
    final tile = CustomPaint(
      painter: _DashedRRectPainter(
        color: AppColors.borderStrong,
        radius: AppRadii.card,
        strokeWidth: 1.5,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        alignment: Alignment.center,
        child: const NumayaIcon(
          NumayaIcons.plus,
          size: AppSizes.iconLg,
          color: AppColors.ink,
        ),
      ),
    );
    return Pressable(
      onTap: onAdd,
      semanticLabel: addLabel,
      excludeChildSemantics: true,
      pressedScale: 0.97,
      borderRadius: AppRadii.all(AppRadii.card),
      child: SizedBox.expand(child: tile),
    );
  }
}

/// A dashed rounded-rectangle edge (`outline: 1.5px dashed`).
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).inflate(strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const dash = 3.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

/// Outcome block (`.result`): illustration, 24pt semibold title, muted body.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.title,
    this.body,
    this.illustration,
    this.compact = false,
    this.illustrationWidth = 160,
  });

  final String title;
  final String? body;
  final NumayaIllustration? illustration;
  final bool compact;
  final double illustrationWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4, bottom: AppSpacing.s1),
      child: Column(
        children: [
          if (illustration != null)
            _BadgeIn(
              child: IllustrationView(illustration!, width: illustrationWidth),
            ),
          SizedBox(height: compact ? AppSpacing.s3 : AppSpacing.s5),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headline,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                body!,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeIn extends StatelessWidget {
  const _BadgeIn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.celebrate,
      curve: AppMotion.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: child,
    );
  }
}

enum SetupStepStatus { done, active, upcoming }

class SetupStepData {
  const SetupStepData({
    required this.label,
    required this.detail,
    required this.icon,
    required this.status,
  });

  final String label;
  final String detail;
  final NumayaIcons icon;
  final SetupStepStatus status;
}

/// Profile setup checklist (`.setup-steps`), in V16's language: white cards on the page with no
/// border; done steps on the fill; the step up next ringed in ink with a blue-tint "Up next" tag.
class SetupProgress extends StatelessWidget {
  const SetupProgress({
    super.key,
    required this.title,
    required this.countLabel,
    required this.steps,
    required this.upNextLabel,
    required this.doneLabel,
  });

  final String title;
  final String countLabel;
  final List<SetupStepData> steps;
  final String upNextLabel;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppTypography.sheetTitle),
              ),
            ),
            Text(countLabel, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s2),
          _SetupStepTile(
            step: steps[i],
            upNextLabel: upNextLabel,
            doneLabel: doneLabel,
          ),
        ],
      ],
    );
  }
}

class _SetupStepTile extends StatelessWidget {
  const _SetupStepTile({
    required this.step,
    required this.upNextLabel,
    required this.doneLabel,
  });

  final SetupStepData step;
  final String upNextLabel;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    final active = step.status == SetupStepStatus.active;
    final done = step.status == SetupStepStatus.done;
    final labelColor = active
        ? AppColors.textPrimary
        : done
        ? AppColors.textSecondary
        : AppColors.textMuted;
    return Semantics(
      label:
          '${step.label}. ${step.detail}. ${done
              ? doneLabel
              : active
              ? upNextLabel
              : ''}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: done ? AppColors.fill : AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
          border: done
              ? null
              : Border.all(
                  color: active
                      ? AppColors.controlSelected
                      : Colors.transparent,
                  width: active ? AppBorders.focus : AppBorders.hairline,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        child: Row(
          children: [
            NumayaIcon(
              done ? NumayaIcons.check : step.icon,
              color: active
                  ? AppColors.brand
                  : done
                  ? AppColors.textSecondary
                  : AppColors.textSubtle,
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ).copyWith(color: labelColor),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    step.detail,
                    style: AppTypography.caption.copyWith(
                      color: active
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (active || done) ...[
              const SizedBox(width: AppSpacing.s3),
              Container(
                padding: active
                    ? const EdgeInsets.symmetric(
                        horizontal: AppLayout.badgeInsetX,
                        vertical: AppLayout.badgeInsetY,
                      )
                    : EdgeInsets.zero,
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.accentTint,
                        borderRadius: AppRadii.all(AppRadii.pill),
                      )
                    : null,
                child: Text(
                  active ? upNextLabel : doneLabel,
                  style:
                      AppTypography.weight(
                        AppTypography.caption,
                        AppTypography.semibold,
                      ).copyWith(
                        color: active
                            ? AppColors.textBrandDeep
                            : AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ente bottom sheet (Bottom Sheet Header 4809:7991, template 4809:8027). UI-023: the sheet uses
/// the app's light-grey page surface, and related settings sit on white cards inside it (the same
/// [ListGroup], [OptionGroup] and card rules as a page). 24pt top corners,
/// no drag handle, 20pt padding, the title in H1 (20/28 semibold) on the left and a circular close
/// button on the right, 16pt to the content. Swipe-down dismissal still works (a Numaya keep).
Future<T?> showNumayaSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  required String closeLabel,
  bool tall = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet(context),
    isScrollControlled: true,
    useSafeArea: true,
    // Sheets cover the tab bar, as on the web.
    useRootNavigator: true,
    // V16 `.sheet__panel`: as tall as its content, at most the screen less 8pt.
    constraints: BoxConstraints(
      maxHeight:
          MediaQuery.sizeOf(context).height -
          MediaQuery.paddingOf(context).top -
          AppSpacing.s2,
    ),
    backgroundColor: AppColors.canvas,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    builder: (context) {
      // `useSafeArea` leaves the bottom to the sheet: its white runs behind the system navigation
      // bar (edge to edge), and its content stays above the bar and above the keyboard.
      // paddingOf already shrinks to zero where the keyboard covers the bar.
      final sheet = Padding(
        padding: EdgeInsets.only(
          bottom:
              AppSpacing.s4 +
              MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s5,
                AppSpacing.s4,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: AppTypography.sheetTitle),
                    ),
                  ),
                  NavIconButton(
                    icon: NumayaIcons.close,
                    label: closeLabel,
                    style: NavButtonStyle.circular,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Flexible(
              fit: tall ? FlexFit.tight : FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                // V3-D01: a content-height sheet scrolls when its content is taller than the
                // space left (320pt at 200% text overflowed the Unmatch sheet by 31pt). Tall
                // sheets fill their height and manage their own scrolling.
                child: SheetSurface(
                  child: tall
                      ? Builder(builder: builder)
                      : SingleChildScrollView(child: Builder(builder: builder)),
                ),
              ),
            ),
          ],
        ),
      );
      return tall
          ? FractionallySizedBox(heightFactor: 0.8, child: sheet)
          : sheet;
    },
  );
}

/// Marks content inside a Numaya sheet. Since UI-023 the sheet is the grey page surface, so groups
/// inside it draw their white cards exactly as on a page; the marker stays for widgets that need
/// to know they are in a sheet.
class SheetSurface extends InheritedWidget {
  const SheetSurface({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetSurface>() != null;

  @override
  bool updateShouldNotify(SheetSurface oldWidget) => false;
}

/// Metadata on one line (CL-04): parts such as "Woman | Looking for long-term" or
/// "Mon 2 Nov | 2 km away", separated by a subtle vertical bar instead of a middle dot.
///
/// Code joins parts with [joiner] (U+2063 INVISIBLE SEPARATOR), which never appears in user
/// content, so user text, decimals and real lists keep their own punctuation. The bar is excluded
/// from semantics; screen readers hear the parts in order, separated by commas.
class MetaText extends StatelessWidget {
  const MetaText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.separatorColor,
  });

  /// Joins metadata parts for [MetaText] (and for [ListRow] details, which render with it).
  static const String joiner = '⁣';

  /// [parts] joined with [joiner], skipping empty parts.
  static String join(Iterable<String?> parts) =>
      parts.whereType<String>().where((p) => p.isNotEmpty).join(joiner);

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// The bar's colour; defaults to [AppColors.borderStrong]. Set it on coloured surfaces,
  /// such as a sent chat bubble, where the default grey would not read.
  final Color? separatorColor;

  @override
  Widget build(BuildContext context) {
    if (!text.contains(joiner)) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }
    final parts = text.split(joiner);
    final base = DefaultTextStyle.of(context).style.merge(style);
    final size = (base.fontSize ?? 14) * 0.85;
    return Semantics(
      label: parts.join(', '),
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (i > 0)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                      ),
                      child: Container(
                        width: 1,
                        height: size,
                        color: separatorColor ?? AppColors.borderStrong,
                      ),
                    ),
                  ),
                TextSpan(text: parts[i]),
              ],
            ],
          ),
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}
