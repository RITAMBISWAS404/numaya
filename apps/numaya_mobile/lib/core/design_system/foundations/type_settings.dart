import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// UI-085 (2026-11-15): four fixed font pairings, display family first, UI family second. The
/// display group covers hero headings, page titles, prominent sheet titles, large profile names
/// and large metrics; the UI group covers subheadings, compact navigation titles, body, buttons,
/// fields, labels and metadata. [baseline] is the verified build: Plus Jakarta Sans for display
/// roles and Figtree for UI roles (section and app-bar titles in Plus Jakarta Sans).
///
/// Replaces the earlier independent display and UI selectors (Fraunces, Instrument Serif,
/// DM Serif Display, Manrope, Poppins): the scope rules forbid mixing families freely.
enum FontPairing {
  baseline('default', 'Default', null, null, displayWeights: _variable),
  halantNunito(
    'halant-nunito-sans',
    'Halant + Nunito Sans',
    'Halant',
    'Nunito Sans',
    displayWeights: [300, 400, 500, 600, 700],
  ),
  yesevaJosefin(
    'yeseva-one-josefin-sans',
    'Yeseva One + Josefin Sans',
    'Yeseva One',
    'Josefin Sans',
    displayWeights: [400],
  ),
  breeDmSans(
    'bree-serif-dm-sans',
    'Bree Serif + DM Sans',
    'Bree Serif',
    'DM Sans',
    displayWeights: [400],
  );

  const FontPairing(
    this.id,
    this.label,
    this.display,
    this.ui, {
    required this.displayWeights,
  });

  static const List<int> _variable = [];

  /// Stable id used in the persisted file and the evidence records.
  final String id;
  final String label;

  /// The bundled display family; null keeps each display role's baseline face.
  final String? display;

  /// The bundled UI family; null keeps Figtree (and Plus Jakarta Sans for section titles).
  final String? ui;

  /// Real weights the display family ships. Empty means a variable font (any weight). A role
  /// whose weight is not in the list uses the nearest real one; single-weight faces are never
  /// synthetically emboldened (docs/ui087-102/TYPOGRAPHY_CATALOG.md records the mapping).
  final List<int> displayWeights;

  bool get displaySingleWeight => displayWeights.length == 1;

  static FontPairing byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => baseline);
}

/// UI-095: the brand colour comparison. [baseline] is the verified palette (#7262C7 and its
/// approved derived roles). The two alternatives are the reviewer's exact seeds; their pressed,
/// text, subtle and line roles are derived by one rule (docs/ui087-102/DEV_MODE.md). Only brand
/// roles follow the choice: neutrals and the semantic success, warning and error roles do not.
enum BrandOption {
  baseline('default', 'Default (#7262C7)', BrandPalette.baseline),
  periwinkle('7e77f8', '#7E77F8', BrandPalette.periwinkle),
  lilac('a07add', '#A07ADD', BrandPalette.lilac);

  const BrandOption(this.id, this.label, this.palette);

  final String id;
  final String label;
  final BrandPalette palette;

  static BrandOption byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => baseline);
}

/// The brand roles one seed produces.
@immutable
class BrandPalette {
  const BrandPalette({
    required this.brand,
    required this.pressed,
    required this.text,
    required this.subtle,
    required this.line,
  });

  /// Seed: primary actions, selected controls, progress, switch on.
  final Color brand;

  /// Pressed primary.
  final Color pressed;

  /// Brand text and icons on light surfaces (at least 6:1 on the page, 4.5:1 on [subtle]).
  final Color text;

  /// Subtle brand surface: selected chips, badges, tinted panels (seed at 10% over white).
  final Color subtle;

  /// Edge of a selected chip (seed at 36% over white).
  final Color line;

  /// The verified baseline, unchanged (tokens/monochrome_tokens.dart).
  static const baseline = BrandPalette(
    brand: Color(0xFF7262C7),
    pressed: Color(0xFF5F50B8),
    text: Color(0xFF5B4BB0),
    subtle: Color(0xFFF1EFF9),
    line: Color(0xFFCBC4EC),
  );

  /// Seed #7E77F8. White on it is 3.57:1 (below 4.5:1 for 15pt labels; recorded, not altered).
  static const periwinkle = BrandPalette(
    brand: Color(0xFF7E77F8),
    pressed: Color(0xFF625AF7),
    text: Color(0xFF443AF5),
    subtle: Color(0xFFF2F1FE),
    line: Color(0xFFD1CEFC),
  );

  /// Seed #A07ADD. White on it is 3.32:1 (below 4.5:1 for 15pt labels; recorded, not altered).
  static const lilac = BrandPalette(
    brand: Color(0xFFA07ADD),
    pressed: Color(0xFF8F62D7),
    text: Color(0xFF7239CC),
    subtle: Color(0xFFF6F2FC),
    line: Color(0xFFDDCFF3),
  );
}

/// UI-096: the button shape comparison. [baseline] keeps each variant's existing radius (12, or
/// 8 for compact buttons); [pill] gives every shaped button capsule ends. The reviewer mentioned
/// a third option without describing it; none is invented.
enum ButtonShape {
  baseline('default', 'Default'),
  pill('fully-rounded', 'Fully rounded');

  const ButtonShape(this.id, this.label);
  final String id;
  final String label;

  static ButtonShape byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => baseline);
}

/// UI-098: the secondary button surface comparison. [outline] is the current default (C-03);
/// [filled] is a subtle neutral fill, black at 8% over whatever the button sits on.
enum SecondarySurface {
  outline('outline', 'Outline'),
  filled('filled', 'Filled');

  const SecondarySurface(this.id, this.label);
  final String id;
  final String label;

  static SecondarySurface byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => outline);
}

/// Every Dev Mode comparison in one value (UI-085, UI-095, UI-096, UI-097, UI-098, plus the
/// owner's earlier 14/15 body-size toggle, which stays). Release builds always use [baseline].
/// The class keeps its old name so the persisted file, the controller and the tests stay one
/// system rather than two.
@immutable
class TypeSettings {
  const TypeSettings({
    this.pairing = FontPairing.baseline,
    this.bodySize = 15,
    this.brand = BrandOption.baseline,
    this.shape = ButtonShape.baseline,
    this.secondary = SecondarySurface.outline,
  }) : assert(bodySize == 14 || bodySize == 15);

  /// The verified baseline recorded on 2026-11-15 before any change: Plus Jakarta Sans and
  /// Figtree, 15pt body, #7262C7, 12pt (8pt compact) buttons, outlined secondary buttons.
  static const TypeSettings baseline = TypeSettings();

  /// The two base body sizes under review. Only the body tier follows it (see
  /// [AppTypography.bodyTierRoles]); headings, buttons, metadata and icons do not.
  static const List<int> bodySizes = [14, 15];

  final FontPairing pairing;
  final int bodySize;
  final BrandOption brand;
  final ButtonShape shape;
  final SecondarySurface secondary;

  bool get isBaseline => this == baseline;

  TypeSettings copyWith({
    FontPairing? pairing,
    int? bodySize,
    BrandOption? brand,
    ButtonShape? shape,
    SecondarySurface? secondary,
  }) => TypeSettings(
    pairing: pairing ?? this.pairing,
    bodySize: bodySize ?? this.bodySize,
    brand: brand ?? this.brand,
    shape: shape ?? this.shape,
    secondary: secondary ?? this.secondary,
  );

  Map<String, Object> toJson() => {
    'fontPairing': pairing.id,
    'baseBodySize': bodySize,
    'brandColor': brand.id,
    'buttonShape': shape.id,
    'secondarySurface': secondary.id,
  };

  /// Unknown or retired values (the old `displayFamily` and `uiFamily` keys) fall back to the
  /// baseline value for that control only.
  static TypeSettings fromJson(Map<String, Object?> json) {
    final size = json['baseBodySize'];
    return TypeSettings(
      pairing: FontPairing.byId(json['fontPairing'] as String?),
      bodySize: size == 14 ? 14 : 15,
      brand: BrandOption.byId(json['brandColor'] as String?),
      shape: ButtonShape.byId(json['buttonShape'] as String?),
      secondary: SecondarySurface.byId(json['secondarySurface'] as String?),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TypeSettings &&
      other.pairing == pairing &&
      other.bodySize == bodySize &&
      other.brand == brand &&
      other.shape == shape &&
      other.secondary == secondary;

  @override
  int get hashCode => Object.hash(pairing, bodySize, brand, shape, secondary);

  @override
  String toString() =>
      'TypeSettings(${pairing.id}, $bodySize, ${brand.id}, ${shape.id}, '
      '${secondary.id})';
}
