import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';
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

/// Onboarding progress shown in the top bar: five sections (OD-14). Account covers phone and code;
/// the others follow the setup hub's sections.
abstract final class SignUpProgress {
  static const int total = 5;
  static const int phone = 1;
  static const int verify = 1;

  static int forSection(SetupSection section) => section.index + 2;
}
