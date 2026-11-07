// Writes the Visual Lab V2 registry as JSON for the offline review gallery manifest.
// Run explicitly (not part of the test suite):
//   flutter test tool/dump_lab_registry.dart --dart-define=OUT=<path>
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

void main() {
  test('dump registry', () {
    const out = String.fromEnvironment('OUT', defaultValue: 'lab_registry.json');
    final groups = [
      for (final g in kLabGroups)
        {
          'id': g.id,
          'title': g.title,
          'kind': g.kind.name,
          'question': g.question,
          'proposed': g.proposed,
          'usages': g.usages,
          'requires': g.requires,
          'variants': [
            for (final v in g.variants)
              {'id': v.id, 'name': v.name, 'pass': v.pass, 'note': v.note},
          ],
        },
    ];
    File(out).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'groups': groups}),
    );
  });
}
