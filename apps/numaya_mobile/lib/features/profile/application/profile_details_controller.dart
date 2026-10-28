import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/profile_draft.dart';
import '../domain/profile_details.dart';

/// The member's profile details beyond the onboarding draft (bio, About you, More about you,
/// languages, more prompts, Opening Moves, gender detail and what the profile shows). Every change
/// applies at once, like the reference's per-field saves (B-25).
class ProfileDetailsController extends Notifier<ProfileDetails> {
  @override
  ProfileDetails build() => const ProfileDetails();

  void setBio(String value) => state = state.copyWith(
    bio: value.trim().characters.take(DetailRules.bioLength).toString(),
  );

  void setAbout(AboutKey key, String value) {
    final next = {...state.about};
    final v = value.trim();
    if (v.isEmpty) {
      next.remove(key);
    } else {
      next[key] = v.characters.take(AboutKey.maxLength).toString();
    }
    state = state.copyWith(about: next);
  }

  void setHeight(int? cm) => state = cm == null
      ? state.copyWith(clearHeight: true)
      : state.copyWith(
          heightCm: cm.clamp(DetailRules.minHeight, DetailRules.maxHeight),
        );

  void setDetail(DetailKey key, String? value) {
    final next = {...state.details};
    if (value == null) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    state = state.copyWith(details: next);
  }

  /// Toggles a language; ignores the tap at the maximum.
  void toggleLanguage(String language) {
    final next = [...state.languages];
    if (!next.remove(language)) {
      if (next.length >= DetailRules.maxLanguages) return;
      next.add(language);
    }
    state = state.copyWith(languages: next);
  }

  /// Sets prompt [index] among the extra prompts (appends when index == length).
  void setExtraPrompt(int index, String question, String answer) {
    final next = [...state.extraPrompts];
    final prompt = PromptAnswer(question: question, answer: answer.trim());
    if (index >= next.length) {
      if (next.length >= DetailRules.maxPrompts - 1) return;
      next.add(prompt);
    } else {
      next[index] = prompt;
    }
    state = state.copyWith(extraPrompts: next);
  }

  void removeExtraPrompt(int index) {
    if (index >= state.extraPrompts.length) return;
    state = state.copyWith(
      extraPrompts: [...state.extraPrompts]..removeAt(index),
    );
  }

  void setOpeningMove(int index, String text) {
    final v = text
        .trim()
        .characters
        .take(DetailRules.openingMoveLength)
        .toString();
    final next = [...state.openingMoves];
    if (v.isEmpty) {
      if (index < next.length) next.removeAt(index);
    } else if (index >= next.length) {
      if (next.length >= DetailRules.maxOpeningMoves) return;
      next.add(v);
    } else {
      next[index] = v;
    }
    state = state.copyWith(openingMoves: next);
  }

  void setGenderDetail(String? value) => state = value == null
      ? state.copyWith(clearGenderDetail: true)
      : state.copyWith(genderDetail: value);

  void setShowGender(bool v) => state = state.copyWith(showGender: v);
  void setShowAge(bool v) => state = state.copyWith(showAge: v);
  void setShowDistance(bool v) => state = state.copyWith(showDistance: v);

  /// Sets the area (OD-7). [fromDevice] when it came from the location prompt.
  void setArea(String? area, {bool fromDevice = false}) => state = area == null
      ? state.copyWith(clearArea: true, areaFromDevice: false)
      : state.copyWith(area: area, areaFromDevice: fromDevice);
}

final profileDetailsProvider =
    NotifierProvider<ProfileDetailsController, ProfileDetails>(
      ProfileDetailsController.new,
    );
