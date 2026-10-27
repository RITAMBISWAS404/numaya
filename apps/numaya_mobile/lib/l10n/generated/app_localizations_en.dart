// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Numaya';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get demoBuildLabel => 'Demo build';

  @override
  String get errorNetwork =>
      'We couldn’t reach Numaya. Check your connection and try again.';

  @override
  String get errorAuthUnavailable =>
      'Sign-in isn’t available in this build yet.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get welcomeTitle => 'Fewer swipes.\nBetter first dates.';

  @override
  String get welcomeLede =>
      'Profiles built around conversation, so the right person knows what to say.';

  @override
  String get welcomeCreateAccount => 'Create an account';

  @override
  String get welcomeHaveAccount => 'I have an account';

  @override
  String get welcomeLegalPrefix => 'By signing up, you agree to our ';

  @override
  String get welcomeLegalTerms => 'Terms';

  @override
  String get welcomeLegalMiddle => '. See how we use your data in our ';

  @override
  String get welcomeLegalPrivacy => 'Privacy Policy';

  @override
  String get welcomeLegalSuffix => '.';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalPending =>
      'The final document isn’t published yet. It will open here before Numaya launches.';

  @override
  String get phoneTitleSignUp => 'Can we get your number, please?';

  @override
  String get phoneLedeSignUp =>
      'We only use phone numbers to make sure everyone on Numaya is real.';

  @override
  String get phoneTitleSignIn => 'Welcome back. What’s your number?';

  @override
  String get phoneLedeSignIn =>
      'We’ll text you a code to sign in. No password to remember.';

  @override
  String get phoneCountryLabel => 'Country';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String phoneCountryButton(Object name, Object dialCode) {
    return 'Country: $name, plus $dialCode';
  }

  @override
  String get phonePrivacyTitle => 'Your number stays private';

  @override
  String get phonePrivacyBody =>
      'We never share it, and it won’t be on your profile.';

  @override
  String get phoneSendCode => 'Send code';

  @override
  String get phoneSending => 'Sending code';

  @override
  String get phoneInvalid =>
      'That number can’t be used. Check it and try again.';

  @override
  String get countrySheetTitle => 'Country or region';

  @override
  String get countrySearch => 'Search';

  @override
  String countryNoResults(Object query) {
    return 'No countries match “$query”.';
  }

  @override
  String get countrySelected => 'Selected';

  @override
  String get verifyTitle => 'Verify your number';

  @override
  String verifyLede(Object number) {
    return 'Enter the code we’ve sent by text to $number.';
  }

  @override
  String get verifyChangeNumber => 'Change number';

  @override
  String get verifyCodeLabel => 'Code';

  @override
  String get verifyChecking => 'Verifying';

  @override
  String get verifyIncorrect =>
      'That code doesn’t match. Try the latest one we sent.';

  @override
  String get verifyExpired => 'That code has expired. Ask for a new one below.';

  @override
  String get verifySuccess => 'Number verified';

  @override
  String get verifyDidntGet => 'Didn’t get a code?';

  @override
  String verifyResendIn(Object time) {
    return 'Resend in $time';
  }

  @override
  String get verifyResend => 'Resend code';

  @override
  String get verifyResent => 'New code sent';

  @override
  String get verifySubmit => 'Verify code';

  @override
  String get demoMessageTitle => 'Demo text message';

  @override
  String demoMessageBody(Object code) {
    return 'Your Numaya code is $code. This build doesn’t send real texts.';
  }

  @override
  String get noAccountTitle => 'No account for this number yet';

  @override
  String get noAccountBody => 'Create one now. It takes about two minutes.';

  @override
  String get noAccountCreate => 'Create an account';

  @override
  String get noAccountOtherNumber => 'Use a different number';

  @override
  String get signedIn => 'You’re signed in';

  @override
  String get setupVerifiedTitle => 'You’re verified';

  @override
  String setupVerifiedBody(Object number) {
    return '$number is confirmed. Now let’s make a profile people actually want to reply to.';
  }

  @override
  String get setupProfileTitle => 'Your profile';

  @override
  String setupCount(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get setupUpNext => 'Up next';

  @override
  String get setupStepDone => 'Done';

  @override
  String get setupBasicsLabel => 'The basics';

  @override
  String get setupBasicsDetail => 'Name, age and who you’d like to meet';

  @override
  String get setupInterestsLabel => 'Interests and prompt';

  @override
  String get setupInterestsDetail => 'Three interests and one answer';

  @override
  String get setupPhotosLabel => 'Photos';

  @override
  String get setupPhotosDetail => 'At least two, ideally four';

  @override
  String get setupBuild => 'Build my profile';

  @override
  String get setupContinue => 'Continue my profile';

  @override
  String get setupGoHome => 'Go to Home';

  @override
  String get setupCaptionTime => 'About two minutes. You can finish later.';

  @override
  String get setupCaptionReady => 'Your profile is ready.';

  @override
  String get basicsTitle => 'Let’s start with the basics';

  @override
  String get basicsFirstName => 'First name';

  @override
  String get basicsBirthYear => 'Year you were born';

  @override
  String get basicsBirthYearHint => 'We show your age, never your birthday.';

  @override
  String get basicsUnderage => 'You need to be 18 or older to use Numaya.';

  @override
  String get basicsInvalidYear => 'Enter a real year, like 1995.';

  @override
  String get basicsGenderLegend => 'I’m a';

  @override
  String get genderWoman => 'Woman';

  @override
  String get genderMan => 'Man';

  @override
  String get genderNonbinary => 'Nonbinary';

  @override
  String get basicsLookingLegend => 'Looking for (up to 2)';

  @override
  String get lookingLongTerm => 'A long-term relationship';

  @override
  String get lookingOpen => 'Open to seeing where it goes';

  @override
  String get lookingCasual => 'Something casual';

  @override
  String get basicsFooter => 'Shown on your profile: first name and age';

  @override
  String get interestsTitle => 'What are you into?';

  @override
  String get interestsLede =>
      'Pick 3 to 5. They start conversations and help us find people like you.';

  @override
  String get interestsLabel => 'Interests';

  @override
  String interestsSelected(int count) {
    return '$count/5 selected';
  }

  @override
  String interestsPickMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pick $count more',
      one: 'Pick 1 more',
    );
    return '$_temp0';
  }

  @override
  String interestsCount(int count) {
    return '$count/5 interests';
  }

  @override
  String get interestsNeedPrompt => 'Now answer your prompt';

  @override
  String get promptSectionTitle => 'Your prompt';

  @override
  String get promptSectionBody =>
      'Matches reply to this. You can change it any time from your profile.';

  @override
  String get promptEmpty => 'Tap to write your answer';

  @override
  String get promptEditLabel => 'Edit your prompt';

  @override
  String get promptPick => 'Pick a prompt';

  @override
  String get promptAnswerLabel => 'Your answer';

  @override
  String get promptAnswerPlaceholder =>
      'Be specific. It gives people something to reply to.';

  @override
  String get promptSave => 'Save prompt';

  @override
  String promptCounter(int count, int max) {
    return '$count/$max';
  }

  @override
  String get promptWriteToSave => 'Write an answer to save.';

  @override
  String get promptNoChanges => 'No changes yet.';

  @override
  String get promptSavedHint =>
      'Saved prompts show on your profile straight away.';

  @override
  String promptCharsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters left',
      one: '1 character left',
    );
    return '$_temp0';
  }

  @override
  String get photosTitle => 'Add your photos';

  @override
  String get photosLede =>
      'At least 2, ideally 4. Clear, recent, and just you in the first one.';

  @override
  String photosAddMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count more for the best results',
      one: 'Add 1 more for the best results',
    );
    return '$_temp0';
  }

  @override
  String get photosLookingGreat => 'Looking great';

  @override
  String get photosMain => 'Main';

  @override
  String get photosAdd => 'Add a photo';

  @override
  String photosRemove(int position) {
    return 'Remove photo $position';
  }

  @override
  String get photosInfoTitle => 'Your first photo leads your profile';

  @override
  String get photosInfoBody =>
      'Photo upload isn’t connected in this build, so + adds a placeholder tile. You can choose a different main photo later in Edit profile.';

  @override
  String get photosFinish => 'Finish profile';

  @override
  String get tabDiscover => 'Home';

  @override
  String get tabLikes => 'Likes';

  @override
  String get tabChats => 'Messages';

  @override
  String get tabProfile => 'Profile';

  @override
  String get profileReady => 'Your profile is ready';

  @override
  String get discoverEmptyTitle => 'No profiles to show yet';

  @override
  String get discoverEmptyBody =>
      'People appear here once matching is connected. This demo build doesn’t include it.';

  @override
  String get discoverFilters => 'Filters';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersAge => 'Age';

  @override
  String get filtersAgeHeading => 'How old are they?';

  @override
  String get filtersDistanceHeading => 'How far away are they?';

  @override
  String get filtersDistanceLabel => 'Distance';

  @override
  String filtersAgeValue(int min, int max) {
    return '$min - $max';
  }

  @override
  String get filtersDistance => 'Maximum distance';

  @override
  String filtersDistanceValue(int km) {
    return 'Up to $km km';
  }

  @override
  String get filtersApply => 'Save filters';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filtersSaved => 'Filters saved';

  @override
  String get likesSubtitle => 'People who liked you. Like them back to match.';

  @override
  String get likesEmptyTitle => 'No new likes right now';

  @override
  String get likesEmptyBody =>
      'When someone likes your profile, they’ll show up here.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get chatsEmptyTitle => 'Connections start here';

  @override
  String get chatsEmptyBody =>
      'When you like each other, you’ll match. Here’s where you can chat.';

  @override
  String get findYourPeople => 'Find your people';

  @override
  String profileNameAge(Object name, int age) {
    return '$name, $age';
  }

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLookingFor => 'Looking for';

  @override
  String get profilePhotosPlaceholder =>
      'Placeholder photos until upload is connected.';

  @override
  String get profilePromptTitle => 'Your prompt';

  @override
  String get profilePromptCaption => 'Matches reply to this.';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileTrust => 'Trust';

  @override
  String get profileVerification => 'Verification';

  @override
  String get profilePhoneVerified => 'Phone verified';

  @override
  String get profileLookingLongTerm => 'Looking for long-term';

  @override
  String get profileLookingOpen => 'Open to seeing where it goes';

  @override
  String get profileLookingCasual => 'Looking for something casual';

  @override
  String get profileInitialLabel =>
      'Your initial, until photo upload is connected';

  @override
  String get editTitle => 'Edit profile';

  @override
  String get editPhotosTitle => 'Photos';

  @override
  String get editPhotosHint => 'Keep at least 2.';

  @override
  String get editPhotosNote =>
      'Upload isn’t connected yet, so + adds a placeholder tile.';

  @override
  String get editPromptSection => 'Prompt';

  @override
  String get editAboutSection => 'About you';

  @override
  String get editSaved => 'Saved';

  @override
  String get editPromptTitle => 'Your prompt';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsPhone => 'Phone number';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNewMatches => 'New matches';

  @override
  String get settingsMessages => 'New messages';

  @override
  String get settingsNotificationsNote =>
      'Push notifications aren’t connected in this build. These choices are kept for this session.';

  @override
  String get settingsSignOut => 'Log out';

  @override
  String get settingsDeleteNote =>
      'Deleting removes your profile, matches and messages.';

  @override
  String get settingsDelete => 'Delete account';

  @override
  String get settingsDeleteTitle => 'Delete your account?';

  @override
  String get settingsDeleteBody =>
      'Your profile, matches and messages will be removed. This can’t be undone.';

  @override
  String get settingsSignedOut => 'You’re signed out';

  @override
  String get settingsDeleted => 'Your account was deleted';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDemoNote =>
      'Demo build: nothing is sent to a server, and your profile is cleared when the app closes.';

  @override
  String settingsVersion(Object version) {
    return 'Version $version';
  }
}
