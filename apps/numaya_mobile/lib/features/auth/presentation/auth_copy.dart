import '../../../l10n/l10n.dart';
import '../domain/auth_repository.dart';

/// Copy for auth failures. Server text never reaches the screen.
String authFailureMessage(AppLocalizations l10n, AuthFailure failure) =>
    switch (failure) {
      InvalidPhoneNumber() => l10n.phoneInvalid,
      IncorrectCode() => l10n.verifyIncorrect,
      CodeExpired() => l10n.verifyExpired,
      ResendTooSoon() => l10n.errorGeneric,
      AuthNetworkFailure() => l10n.errorNetwork,
      AuthUnavailable() => l10n.errorAuthUnavailable,
    };

/// Onboarding progress shown in the top bar: phone, code, basics, interests, photos.
abstract final class SignUpProgress {
  static const int total = 5;
  static const int phone = 1;
  static const int verify = 2;
  static const int basics = 3;
  static const int interests = 4;
  static const int photos = 5;
}
