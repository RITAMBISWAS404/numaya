import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/data/live/live_compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';

/// PR-007: a live Compliment shows the exact photo or prompt it was sent about.
void main() {
  const refs = (photos: ['ph-a', 'ph-b', 'ph-c'], prompts: ['pr-a', 'pr-b']);

  test('the stored photo id maps to its own position, not the first photo', () {
    final t = resolveLiveComplimentTarget(
      isPrompt: false,
      context: const {'kind': 'photo', 'photo_id': 'ph-c'},
      refs: refs,
    );
    expect(t, const ComplimentTarget.photo(2));
  });

  test('the stored prompt id maps to its own position', () {
    final t = resolveLiveComplimentTarget(
      isPrompt: true,
      context: const {'kind': 'prompt', 'prompt_id': 'pr-b'},
      refs: refs,
    );
    expect(t, const ComplimentTarget.prompt(1));
  });

  test('a deleted target is unavailable, never another photo', () {
    for (final ctx in [
      const {'kind': 'photo', 'photo_id': 'gone'},
      null,
    ]) {
      final t = resolveLiveComplimentTarget(
        isPrompt: false,
        context: ctx,
        refs: refs,
      );
      expect(t.unavailable, isTrue);
      expect(t.index, ComplimentTarget.unavailableIndex);
    }
    expect(
      resolveLiveComplimentTarget(
        isPrompt: true,
        context: const {'prompt_id': 'pr-a'},
        refs: null,
      ).unavailable,
      isTrue,
    );
  });
}
