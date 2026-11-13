import 'package:flutter/foundation.dart';

/// UI-085 display group: hero headings, page titles, prominent sheet titles, large profile names
/// and large metrics. [baseline] keeps each of those roles in its verified face (Plus Jakarta Sans,
/// or Figtree for sheet titles).
enum DisplayFace {
  baseline('baseline', 'Default (Plus Jakarta Sans)', null, false),
  fraunces('fraunces', 'Fraunces', 'Fraunces', false),
  instrumentSerif(
    'instrument-serif',
    'Instrument Serif',
    'Instrument Serif',
    true,
  ),
  dmSerifDisplay(
    'dm-serif-display',
    'DM Serif Display',
    'DM Serif Display',
    true,
  );

  const DisplayFace(this.id, this.label, this.family, this.singleWeight);

  /// Stable id used in the persisted file and the gallery export.
  final String id;
  final String label;

  /// The bundled family name; null keeps the baseline face of each role.
  final String? family;

  /// The face ships one weight (400). It is never synthetically emboldened.
  final bool singleWeight;

  static DisplayFace byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => baseline);
}

/// UI-085 UI group: subheadings, compact navigation titles, body, buttons, fields, labels and
/// metadata. [baseline] keeps Figtree (and Plus Jakarta Sans for section and app-bar titles).
enum UiFace {
  baseline('baseline', 'Default (Figtree)', null),
  manrope('manrope', 'Manrope', 'Manrope'),
  poppins('poppins', 'Poppins', 'Poppins');

  const UiFace(this.id, this.label, this.family);

  final String id;
  final String label;
  final String? family;

  static UiFace byId(String? id) =>
      values.firstWhere((f) => f.id == id, orElse: () => baseline);
}

/// The review-build typography comparison (UI-085 and the owner's 14/15 decision, 2026-11-14):
/// three independent controls. Release builds always use [baseline].
@immutable
class TypeSettings {
  const TypeSettings({
    this.display = DisplayFace.baseline,
    this.ui = UiFace.baseline,
    this.bodySize = 15,
  }) : assert(bodySize == 14 || bodySize == 15);

  /// The verified baseline: current families and the approved 15pt body.
  static const TypeSettings baseline = TypeSettings();

  /// The two base body sizes under review. Only the body tier follows it (see
  /// [AppTypography.bodyTierRoles]); headings, buttons, metadata and icons do not.
  static const List<int> bodySizes = [14, 15];

  final DisplayFace display;
  final UiFace ui;
  final int bodySize;

  bool get isBaseline => this == baseline;

  TypeSettings copyWith({DisplayFace? display, UiFace? ui, int? bodySize}) =>
      TypeSettings(
        display: display ?? this.display,
        ui: ui ?? this.ui,
        bodySize: bodySize ?? this.bodySize,
      );

  /// The field names match the gallery export's `typography` object.
  Map<String, Object> toJson() => {
    'displayFamily': display.id,
    'uiFamily': ui.id,
    'baseBodySize': bodySize,
  };

  /// Unknown values fall back to the baseline value for that control only.
  static TypeSettings fromJson(Map<String, Object?> json) {
    final size = json['baseBodySize'];
    return TypeSettings(
      display: DisplayFace.byId(json['displayFamily'] as String?),
      ui: UiFace.byId(json['uiFamily'] as String?),
      bodySize: size == 14 ? 14 : 15,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TypeSettings &&
      other.display == display &&
      other.ui == ui &&
      other.bodySize == bodySize;

  @override
  int get hashCode => Object.hash(display, ui, bodySize);

  @override
  String toString() => 'TypeSettings(${display.id}, ${ui.id}, $bodySize)';
}
