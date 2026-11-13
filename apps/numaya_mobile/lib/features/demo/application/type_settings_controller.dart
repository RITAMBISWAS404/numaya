import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/logging/app_logger.dart';

/// Where the review build keeps its typography comparison (UI-085 and the 14/15 body size):
/// a small JSON file in the app's support folder on this phone. Never the user's profile and
/// never a server. Release builds neither read nor write it.
class TypeSettingsStore {
  const TypeSettingsStore();

  static const _log = AppLogger('TypeSettings');
  static const fileName = 'numaya_review_typography.json';

  /// True where the comparison exists: debug and profile builds of the development
  /// environment (the same rule as demo sign-in).
  static bool get enabled => AppConfig.demoAuthAllowed;

  Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}/$fileName');

  /// Reads the saved settings, or [TypeSettings.baseline] when there are none, the file is
  /// unreadable or this is a release build.
  Future<TypeSettings> read() async {
    if (!enabled) return TypeSettings.baseline;
    try {
      final file = await _file();
      if (!await file.exists()) return TypeSettings.baseline;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, Object?>) return TypeSettings.fromJson(json);
    } on Object catch (e) {
      // Tests have no path_provider; a damaged file falls back to the baseline.
      _log.warning('Could not read the typography settings: $e');
    }
    return TypeSettings.baseline;
  }

  Future<void> write(TypeSettings settings) async {
    if (!enabled) return;
    try {
      final file = await _file();
      if (settings.isBaseline) {
        if (await file.exists()) await file.delete();
      } else {
        await file.writeAsString(jsonEncode(settings.toJson()), flush: true);
      }
    } on Object catch (e) {
      _log.warning('Could not save the typography settings: $e');
    }
  }

  /// Applies the saved settings before the first frame (called from `main`).
  static Future<void> restore() async {
    AppTypography.apply(await const TypeSettingsStore().read());
  }
}

final typeSettingsStoreProvider = Provider<TypeSettingsStore>(
  (_) => const TypeSettingsStore(),
);

/// The live typography settings. The app root watches this, re-applies [AppTypography] and
/// rebuilds every widget, so a change shows at once on every screen without a restart.
class TypeSettingsController extends Notifier<TypeSettings> {
  @override
  TypeSettings build() => AppTypography.settings;

  Future<void> set(TypeSettings settings) async {
    if (!TypeSettingsStore.enabled || settings == state) return;
    AppTypography.apply(settings);
    state = settings;
    await ref.read(typeSettingsStoreProvider).write(settings);
  }

  /// Restores all three controls to the verified baseline (current families, 15pt body).
  Future<void> reset() => set(TypeSettings.baseline);
}

final typeSettingsProvider =
    NotifierProvider<TypeSettingsController, TypeSettings>(
      TypeSettingsController.new,
    );

/// Marks every element for rebuild, so widgets that read [AppTypography] in `build` pick up the
/// new roles (const subtrees included). Used only when the review settings change.
void rebuildAllElements(Element root) {
  void visit(Element e) {
    e.markNeedsBuild();
    e.visitChildren(visit);
  }

  root.visitChildren(visit);
}
