import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../auth/application/session_controller.dart';
import '../domain/profile_draft.dart';

enum SetupStep { basics, interests, photos }

@immutable
class OnboardingState {
  const OnboardingState({
    this.draft = const ProfileDraft(),
    this.completed = const {},
  });

  final ProfileDraft draft;

  /// Steps whose next button has been pressed.
  final Set<SetupStep> completed;

  /// First step not done yet, or null when the profile is ready.
  SetupStep? get nextStep {
    for (final step in SetupStep.values) {
      if (!completed.contains(step)) return step;
    }
    return null;
  }

  OnboardingState copyWith({ProfileDraft? draft, Set<SetupStep>? completed}) =>
      OnboardingState(
        draft: draft ?? this.draft,
        completed: completed ?? this.completed,
      );
}

/// View model for profile setup and editing.
class OnboardingController extends Notifier<OnboardingState> {
  int _photoIds = 0;
  ProfileDraft? _beforeEdit;

  @override
  OnboardingState build() => const OnboardingState();

  int get currentYear => ref.read(clockProvider)().year;

  void _update(ProfileDraft draft) => state = state.copyWith(draft: draft);

  void setFirstName(String value) =>
      _update(state.draft.copyWith(firstName: value));

  void setBirthYear(String value) => _update(
    state.draft.copyWith(birthYear: value.replaceAll(RegExp(r'\D'), '')),
  );

  void setGender(Gender value) => _update(state.draft.copyWith(gender: value));

  /// Toggles an intention; ignores the tap when the maximum is reached.
  void toggleLookingFor(LookingFor value) {
    final next = {...state.draft.lookingFor};
    if (!next.remove(value)) {
      if (next.length >= ProfileRules.maxLookingFor) return;
      next.add(value);
    }
    _update(state.draft.copyWith(lookingFor: next));
  }

  /// Toggles an interest; extra taps past the maximum are ignored (spec B-17).
  void toggleInterest(String interest) {
    final next = [...state.draft.interests];
    if (!next.remove(interest)) {
      if (next.length >= ProfileRules.maxInterests) return;
      next.add(interest);
    }
    _update(state.draft.copyWith(interests: next));
  }

  void setPrompt(String question, String answer) => _update(
    state.draft.copyWith(
      prompt: PromptAnswer(question: question, answer: answer.trim()),
    ),
  );

  void addPhoto() {
    final photos = state.draft.photos;
    if (photos.length >= ProfileRules.maxPhotos) return;
    _update(
      state.draft.copyWith(
        photos: [
          ...photos,
          DraftPhoto(id: ++_photoIds, tone: photos.length % 4),
        ],
      ),
    );
  }

  void removePhoto(int id) => _update(
    state.draft.copyWith(
      photos: state.draft.photos.where((p) => p.id != id).toList(),
    ),
  );

  /// Moves a photo to the front ("Make main photo").
  void makeMain(int id) {
    final photos = [...state.draft.photos];
    final i = photos.indexWhere((p) => p.id == id);
    if (i <= 0) return;
    photos.insert(0, photos.removeAt(i));
    _update(state.draft.copyWith(photos: photos));
  }

  void completeStep(SetupStep step) =>
      state = state.copyWith(completed: {...state.completed, step});

  /// Saves the finished profile and marks the account as set up.
  Future<void> finish() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    await ref.read(profileRepositoryProvider).save(session.userId, state.draft);
    await ref.read(sessionProvider.notifier).markProfileComplete();
  }

  /// Edit profile: remember the saved profile so leaving without saving restores it.
  void beginEdit() => _beforeEdit = state.draft;

  void cancelEdit() {
    final before = _beforeEdit;
    _beforeEdit = null;
    if (before != null) _update(before);
  }

  /// Saves edits made from Edit profile.
  Future<void> saveEdits() async {
    _beforeEdit = null;
    await finish();
  }

  /// A returning member signed in: load their saved profile.
  Future<void> restore() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    final saved = await ref
        .read(profileRepositoryProvider)
        .load(session.userId);
    if (saved != null && ref.mounted) {
      _photoIds = saved.photos.fold(0, (m, p) => p.id > m ? p.id : m);
      state = OnboardingState(
        draft: saved,
        completed: SetupStep.values.toSet(),
      );
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
