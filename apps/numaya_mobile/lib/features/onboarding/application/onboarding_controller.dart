import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../auth/application/session_controller.dart';
import '../domain/profile_draft.dart';

/// Every onboarding step after the code, in flow order (ONBOARDING_MASTER_INVENTORY "Final order").
enum SetupStep {
  name,
  gender,
  meet,
  intentions,
  height,
  location,
  photos,
  interests,
  prompts,
  bio,
  verify,
  notifications,
  review;

  SetupSection get section => switch (this) {
    name || gender => SetupSection.aboutYou,
    meet || intentions || height || location => SetupSection.lookingFor,
    photos || interests || prompts || bio => SetupSection.profile,
    verify || notifications || review => SetupSection.finish,
  };

  /// Whether the member may move on without answering.
  bool get optional => switch (this) {
    height || location || bio || verify || notifications => true,
    _ => false,
  };
}

/// The setup hub's groups, which are also the top bar's progress segments (OD-14).
enum SetupSection {
  aboutYou,
  lookingFor,
  profile,
  finish;

  List<SetupStep> get steps =>
      SetupStep.values.where((s) => s.section == this).toList();
}

@immutable
class OnboardingState {
  const OnboardingState({
    this.draft = const ProfileDraft(),
    this.completed = const {},
    this.ageLocked = false,
    this.creating = false,
  });

  final ProfileDraft draft;

  /// Steps continued past (answered or skipped).
  final Set<SetupStep> completed;

  /// The member confirmed an age under 18: nothing but sign-out is open (OD-3).
  final bool ageLocked;

  /// The profile is being created (OB-22): repeated taps are ignored.
  final bool creating;

  /// First step not done yet, or null when every step has been passed.
  SetupStep? get nextStep {
    for (final step in SetupStep.values) {
      if (!completed.contains(step)) return step;
    }
    return null;
  }

  bool sectionDone(SetupSection section) =>
      section.steps.every(completed.contains);

  OnboardingState copyWith({
    ProfileDraft? draft,
    Set<SetupStep>? completed,
    bool? ageLocked,
    bool? creating,
  }) => OnboardingState(
    draft: draft ?? this.draft,
    completed: completed ?? this.completed,
    ageLocked: ageLocked ?? this.ageLocked,
    creating: creating ?? this.creating,
  );
}

/// Creating the profile failed (simulated connection problem); the screen offers a retry.
class ProfileCreationFailed implements Exception {
  const ProfileCreationFailed();
}

/// View model for profile setup and editing.
class OnboardingController extends Notifier<OnboardingState> {
  int _photoIds = 0;
  ProfileDraft? _beforeEdit;

  @override
  OnboardingState build() => const OnboardingState();

  DateTime get today => ref.read(clockProvider)();

  void _update(ProfileDraft draft) => state = state.copyWith(draft: draft);

  void setFirstName(String value) =>
      _update(state.draft.copyWith(firstName: value));

  void setBirthDate(DateTime value) =>
      _update(state.draft.copyWith(birthDate: value));

  /// Confirming an age under 18 locks setup for this session; there is no way round it (OD-3).
  void confirmUnderage() => state = state.copyWith(ageLocked: true);

  void setGender(Gender value) => _update(state.draft.copyWith(gender: value));

  /// Toggles a pronoun; taps past the maximum are ignored.
  void togglePronoun(String pronoun) {
    final next = [...state.draft.pronouns];
    if (!next.remove(pronoun)) {
      if (next.length >= ProfileRules.maxPronouns) return;
      next.add(pronoun);
    }
    _update(state.draft.copyWith(pronouns: next));
  }

  void setShowPronouns(bool value) =>
      _update(state.draft.copyWith(showPronouns: value));

  /// Toggles one group of people the member wants to meet ("Everyone" is [setOpenToEveryone]).
  void toggleOpenTo(Gender value) {
    final next = {...?state.draft.openTo};
    if (!next.remove(value)) next.add(value);
    // Every group picked is the same as everyone; none picked is no answer yet.
    _update(
      next.isEmpty
          ? state.draft.copyWith(clearOpenTo: true)
          : state.draft.copyWith(
              openTo: next.length == Gender.values.length ? <Gender>{} : next,
            ),
    );
  }

  void setOpenToEveryone() => _update(state.draft.copyWith(openTo: <Gender>{}));

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

  /// Adds a photo at the end: the one chosen on the phone ([source]), or a placeholder tile when
  /// there is no picker (desktop runs, tests).
  void addPhoto({String? source}) {
    final photos = state.draft.photos;
    if (photos.length >= ProfileRules.maxPhotos) return;
    _update(
      state.draft.copyWith(
        photos: [
          ...photos,
          DraftPhoto(id: ++_photoIds, tone: photos.length % 4, source: source),
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

  /// Moves a photo one place earlier (-1) or later (+1) ("Hold and drag to reorder", B-15).
  void movePhoto(int id, int delta) {
    final photos = [...state.draft.photos];
    final i = photos.indexWhere((p) => p.id == id);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= photos.length) return;
    photos.insert(j, photos.removeAt(i));
    _update(state.draft.copyWith(photos: photos));
  }

  /// Replaces a photo in place with [source], or a new placeholder when there is no picker.
  void replacePhoto(int id, {String? source}) {
    final photos = [...state.draft.photos];
    final i = photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    photos[i] = DraftPhoto(
      id: ++_photoIds,
      tone: (photos[i].tone + 1) % 4,
      source: source,
    );
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

  /// OB-22 "Create my profile": once at a time, only when nothing required is missing. Throws
  /// [ProfileCreationFailed] when the Demo Hub simulates connection problems.
  Future<bool> create({required bool simulateFailure}) async {
    if (state.creating || state.draft.missing(today).isNotEmpty) return false;
    state = state.copyWith(creating: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (simulateFailure) throw const ProfileCreationFailed();
      completeStep(SetupStep.review);
      await finish();
      return true;
    } finally {
      if (ref.mounted) state = state.copyWith(creating: false);
    }
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

  /// Demo Hub quick start: a finished sample profile (fictional).
  void loadSample() {
    _photoIds = 4;
    state = OnboardingState(
      draft: ProfileDraft(
        firstName: 'Alex',
        birthDate: DateTime(1996, 4, 12),
        gender: Gender.woman,
        openTo: const {Gender.man},
        lookingFor: const {LookingFor.longTerm},
        interests: const ['Jazz', 'Cooking', 'Travel'],
        prompt: const PromptAnswer(
          question: 'A perfect first date',
          answer: 'A record shop, a long walk, and nowhere to be after.',
        ),
        photos: const [
          DraftPhoto(id: 1, tone: 0),
          DraftPhoto(id: 2, tone: 1),
          DraftPhoto(id: 3, tone: 2),
        ],
      ),
      completed: SetupStep.values.toSet(),
    );
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
