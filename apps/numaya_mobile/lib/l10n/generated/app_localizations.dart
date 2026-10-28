import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Numaya'**
  String get appName;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @demoBuildLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo build'**
  String get demoBuildLabel;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t reach Numaya. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorAuthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn’t available in this build yet.'**
  String get errorAuthUnavailable;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fewer swipes.\nBetter first dates.'**
  String get welcomeTitle;

  /// No description provided for @welcomeLede.
  ///
  /// In en, this message translates to:
  /// **'Profiles built around conversation, so the right person knows what to say.'**
  String get welcomeLede;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get welcomeHaveAccount;

  /// No description provided for @welcomeLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get welcomeLegalPrefix;

  /// No description provided for @welcomeLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get welcomeLegalTerms;

  /// No description provided for @welcomeLegalMiddle.
  ///
  /// In en, this message translates to:
  /// **'. See how we use your data in our '**
  String get welcomeLegalMiddle;

  /// No description provided for @welcomeLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get welcomeLegalPrivacy;

  /// No description provided for @welcomeLegalSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get welcomeLegalSuffix;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPending.
  ///
  /// In en, this message translates to:
  /// **'The final document isn’t published yet. It will open here before Numaya launches.'**
  String get legalPending;

  /// No description provided for @phoneTitleSignUp.
  ///
  /// In en, this message translates to:
  /// **'Can we get your number, please?'**
  String get phoneTitleSignUp;

  /// No description provided for @phoneLedeSignUp.
  ///
  /// In en, this message translates to:
  /// **'We only use phone numbers to make sure everyone on Numaya is real.'**
  String get phoneLedeSignUp;

  /// No description provided for @phoneTitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. What’s your number?'**
  String get phoneTitleSignIn;

  /// No description provided for @phoneLedeSignIn.
  ///
  /// In en, this message translates to:
  /// **'We’ll text you a code to sign in. No password to remember.'**
  String get phoneLedeSignIn;

  /// No description provided for @phoneCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get phoneCountryLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneCountryButton.
  ///
  /// In en, this message translates to:
  /// **'Country: {name}, plus {dialCode}'**
  String phoneCountryButton(Object name, Object dialCode);

  /// No description provided for @phonePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your number stays private'**
  String get phonePrivacyTitle;

  /// No description provided for @phonePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'We never share it, and it won’t be on your profile.'**
  String get phonePrivacyBody;

  /// No description provided for @phoneSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get phoneSendCode;

  /// No description provided for @phoneSending.
  ///
  /// In en, this message translates to:
  /// **'Sending code'**
  String get phoneSending;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'That number can’t be used. Check it and try again.'**
  String get phoneInvalid;

  /// No description provided for @countrySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Country or region'**
  String get countrySheetTitle;

  /// No description provided for @countrySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get countrySearch;

  /// No description provided for @countryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No countries match “{query}”.'**
  String countryNoResults(Object query);

  /// No description provided for @countrySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get countrySelected;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyTitle;

  /// No description provided for @verifyLede.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we’ve sent by text to {number}.'**
  String verifyLede(Object number);

  /// No description provided for @verifyChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get verifyChangeNumber;

  /// No description provided for @verifyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get verifyCodeLabel;

  /// No description provided for @verifyChecking.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get verifyChecking;

  /// No description provided for @verifyIncorrect.
  ///
  /// In en, this message translates to:
  /// **'That code doesn’t match. Try the latest one we sent.'**
  String get verifyIncorrect;

  /// No description provided for @verifyExpired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Ask for a new one below.'**
  String get verifyExpired;

  /// No description provided for @verifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Number verified'**
  String get verifySuccess;

  /// No description provided for @verifyDidntGet.
  ///
  /// In en, this message translates to:
  /// **'Didn’t get a code?'**
  String get verifyDidntGet;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String verifyResendIn(Object time);

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyResend;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'New code sent'**
  String get verifyResent;

  /// No description provided for @verifySubmit.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifySubmit;

  /// No description provided for @demoMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo text message'**
  String get demoMessageTitle;

  /// No description provided for @demoMessageBody.
  ///
  /// In en, this message translates to:
  /// **'Your Numaya code is {code}. This build doesn’t send real texts.'**
  String demoMessageBody(Object code);

  /// No description provided for @noAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No account for this number yet'**
  String get noAccountTitle;

  /// No description provided for @noAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Create one now. It takes about two minutes.'**
  String get noAccountBody;

  /// No description provided for @noAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get noAccountCreate;

  /// No description provided for @noAccountOtherNumber.
  ///
  /// In en, this message translates to:
  /// **'Use a different number'**
  String get noAccountOtherNumber;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'You’re signed in'**
  String get signedIn;

  /// No description provided for @setupVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re verified'**
  String get setupVerifiedTitle;

  /// No description provided for @setupVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'{number} is confirmed. Now let’s make a profile people actually want to reply to.'**
  String setupVerifiedBody(Object number);

  /// No description provided for @setupProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get setupProfileTitle;

  /// No description provided for @setupCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String setupCount(int done, int total);

  /// No description provided for @setupUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get setupUpNext;

  /// No description provided for @setupStepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setupStepDone;

  /// No description provided for @setupBasicsLabel.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get setupBasicsLabel;

  /// No description provided for @setupBasicsDetail.
  ///
  /// In en, this message translates to:
  /// **'Name, age and who you’d like to meet'**
  String get setupBasicsDetail;

  /// No description provided for @setupInterestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interests and prompt'**
  String get setupInterestsLabel;

  /// No description provided for @setupInterestsDetail.
  ///
  /// In en, this message translates to:
  /// **'Three interests and one answer'**
  String get setupInterestsDetail;

  /// No description provided for @setupPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get setupPhotosLabel;

  /// No description provided for @setupPhotosDetail.
  ///
  /// In en, this message translates to:
  /// **'At least two, ideally four'**
  String get setupPhotosDetail;

  /// No description provided for @setupBuild.
  ///
  /// In en, this message translates to:
  /// **'Build my profile'**
  String get setupBuild;

  /// No description provided for @setupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue my profile'**
  String get setupContinue;

  /// No description provided for @setupGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get setupGoHome;

  /// No description provided for @setupCaptionTime.
  ///
  /// In en, this message translates to:
  /// **'About two minutes. You can finish later.'**
  String get setupCaptionTime;

  /// No description provided for @setupCaptionReady.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready.'**
  String get setupCaptionReady;

  /// No description provided for @basicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s start with the basics'**
  String get basicsTitle;

  /// No description provided for @basicsFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get basicsFirstName;

  /// No description provided for @basicsBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Year you were born'**
  String get basicsBirthYear;

  /// No description provided for @basicsBirthYearHint.
  ///
  /// In en, this message translates to:
  /// **'We show your age, never your birthday.'**
  String get basicsBirthYearHint;

  /// No description provided for @basicsUnderage.
  ///
  /// In en, this message translates to:
  /// **'You need to be 18 or older to use Numaya.'**
  String get basicsUnderage;

  /// No description provided for @basicsInvalidYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a real year, like 1995.'**
  String get basicsInvalidYear;

  /// No description provided for @basicsGenderLegend.
  ///
  /// In en, this message translates to:
  /// **'I’m a'**
  String get basicsGenderLegend;

  /// No description provided for @genderWoman.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get genderWoman;

  /// No description provided for @genderMan.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get genderMan;

  /// No description provided for @genderNonbinary.
  ///
  /// In en, this message translates to:
  /// **'Nonbinary'**
  String get genderNonbinary;

  /// No description provided for @basicsLookingLegend.
  ///
  /// In en, this message translates to:
  /// **'Looking for (up to 2)'**
  String get basicsLookingLegend;

  /// No description provided for @lookingLongTerm.
  ///
  /// In en, this message translates to:
  /// **'A long-term relationship'**
  String get lookingLongTerm;

  /// No description provided for @lookingOpen.
  ///
  /// In en, this message translates to:
  /// **'Open to seeing where it goes'**
  String get lookingOpen;

  /// No description provided for @lookingCasual.
  ///
  /// In en, this message translates to:
  /// **'Something casual'**
  String get lookingCasual;

  /// No description provided for @basicsFooter.
  ///
  /// In en, this message translates to:
  /// **'Shown on your profile: first name and age'**
  String get basicsFooter;

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you into?'**
  String get interestsTitle;

  /// No description provided for @interestsLede.
  ///
  /// In en, this message translates to:
  /// **'Pick 3 to 5. They start conversations and help us find people like you.'**
  String get interestsLede;

  /// No description provided for @interestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsLabel;

  /// No description provided for @interestsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 selected'**
  String interestsSelected(int count);

  /// No description provided for @interestsPickMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pick 1 more} other{Pick {count} more}}'**
  String interestsPickMore(int count);

  /// No description provided for @interestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 interests'**
  String interestsCount(int count);

  /// No description provided for @interestsNeedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Now answer your prompt'**
  String get interestsNeedPrompt;

  /// No description provided for @promptSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your prompt'**
  String get promptSectionTitle;

  /// No description provided for @promptSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Matches reply to this. You can change it any time from your profile.'**
  String get promptSectionBody;

  /// No description provided for @promptEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap to write your answer'**
  String get promptEmpty;

  /// No description provided for @promptEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit your prompt'**
  String get promptEditLabel;

  /// No description provided for @promptPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a prompt'**
  String get promptPick;

  /// No description provided for @promptAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get promptAnswerLabel;

  /// No description provided for @promptAnswerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Be specific. It gives people something to reply to.'**
  String get promptAnswerPlaceholder;

  /// No description provided for @promptSave.
  ///
  /// In en, this message translates to:
  /// **'Save prompt'**
  String get promptSave;

  /// No description provided for @promptCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String promptCounter(int count, int max);

  /// No description provided for @promptWriteToSave.
  ///
  /// In en, this message translates to:
  /// **'Write an answer to save.'**
  String get promptWriteToSave;

  /// No description provided for @promptNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes yet.'**
  String get promptNoChanges;

  /// No description provided for @promptSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Saved prompts show on your profile straight away.'**
  String get promptSavedHint;

  /// No description provided for @promptCharsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character left} other{{count} characters left}}'**
  String promptCharsLeft(int count);

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your photos'**
  String get photosTitle;

  /// No description provided for @photosLede.
  ///
  /// In en, this message translates to:
  /// **'At least 2, ideally 4. Clear, recent, and just you in the first one.'**
  String get photosLede;

  /// No description provided for @photosAddMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 more for the best results} other{Add {count} more for the best results}}'**
  String photosAddMore(int count);

  /// No description provided for @photosLookingGreat.
  ///
  /// In en, this message translates to:
  /// **'Looking great'**
  String get photosLookingGreat;

  /// No description provided for @photosMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get photosMain;

  /// No description provided for @photosAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get photosAdd;

  /// No description provided for @photosRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo {position}'**
  String photosRemove(int position);

  /// No description provided for @photosInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first photo leads your profile'**
  String get photosInfoTitle;

  /// No description provided for @photosInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Photo upload isn’t connected in this build, so + adds a placeholder tile. You can choose a different main photo later in Edit profile.'**
  String get photosInfoBody;

  /// No description provided for @photosFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish profile'**
  String get photosFinish;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabDiscover;

  /// No description provided for @tabLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get tabLikes;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get tabChats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @profileReady.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready'**
  String get profileReady;

  /// No description provided for @discoverFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get discoverFilters;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get filtersAge;

  /// No description provided for @filtersAgeHeading.
  ///
  /// In en, this message translates to:
  /// **'How old are they?'**
  String get filtersAgeHeading;

  /// No description provided for @filtersDistanceHeading.
  ///
  /// In en, this message translates to:
  /// **'How far away are they?'**
  String get filtersDistanceHeading;

  /// No description provided for @filtersDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filtersDistanceLabel;

  /// No description provided for @filtersAgeValue.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max}'**
  String filtersAgeValue(int min, int max);

  /// No description provided for @filtersDistance.
  ///
  /// In en, this message translates to:
  /// **'Maximum distance'**
  String get filtersDistance;

  /// No description provided for @filtersDistanceValue.
  ///
  /// In en, this message translates to:
  /// **'Up to {km} km'**
  String filtersDistanceValue(int km);

  /// No description provided for @filtersApply.
  ///
  /// In en, this message translates to:
  /// **'Save filters'**
  String get filtersApply;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// No description provided for @filtersSaved.
  ///
  /// In en, this message translates to:
  /// **'Filters saved'**
  String get filtersSaved;

  /// No description provided for @likesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People who liked you. Like them back to match.'**
  String get likesSubtitle;

  /// No description provided for @likesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No new likes right now'**
  String get likesEmptyTitle;

  /// No description provided for @likesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When someone likes your profile, they’ll show up here.'**
  String get likesEmptyBody;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @chatsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Connections start here'**
  String get chatsEmptyTitle;

  /// No description provided for @chatsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you like each other, you’ll match. Here’s where you can chat.'**
  String get chatsEmptyBody;

  /// No description provided for @findYourPeople.
  ///
  /// In en, this message translates to:
  /// **'Find your people'**
  String get findYourPeople;

  /// No description provided for @profileNameAge.
  ///
  /// In en, this message translates to:
  /// **'{name}, {age}'**
  String profileNameAge(Object name, int age);

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileLookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get profileLookingFor;

  /// No description provided for @profilePhotosPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Placeholder photos until upload is connected.'**
  String get profilePhotosPlaceholder;

  /// No description provided for @profilePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Your prompt'**
  String get profilePromptTitle;

  /// No description provided for @profilePromptCaption.
  ///
  /// In en, this message translates to:
  /// **'Matches reply to this.'**
  String get profilePromptCaption;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get profileTrust;

  /// No description provided for @profileVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get profileVerification;

  /// No description provided for @profilePhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get profilePhoneVerified;

  /// No description provided for @profileLookingLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Looking for long-term'**
  String get profileLookingLongTerm;

  /// No description provided for @profileLookingOpen.
  ///
  /// In en, this message translates to:
  /// **'Open to seeing where it goes'**
  String get profileLookingOpen;

  /// No description provided for @profileLookingCasual.
  ///
  /// In en, this message translates to:
  /// **'Looking for something casual'**
  String get profileLookingCasual;

  /// No description provided for @profileInitialLabel.
  ///
  /// In en, this message translates to:
  /// **'Your initial, until photo upload is connected'**
  String get profileInitialLabel;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editTitle;

  /// No description provided for @editPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get editPhotosTitle;

  /// No description provided for @editPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a photo to make it your main one. Keep at least 2.'**
  String get editPhotosHint;

  /// No description provided for @editPhotosNote.
  ///
  /// In en, this message translates to:
  /// **'Upload isn’t connected yet, so + adds a placeholder tile.'**
  String get editPhotosNote;

  /// No description provided for @editPromptSection.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get editPromptSection;

  /// No description provided for @editAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get editAboutSection;

  /// No description provided for @editSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get editSaved;

  /// No description provided for @editPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Your prompt'**
  String get editPromptTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get settingsPhone;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNewLikes.
  ///
  /// In en, this message translates to:
  /// **'New likes'**
  String get settingsNewLikes;

  /// No description provided for @settingsMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages'**
  String get settingsMessages;

  /// No description provided for @settingsSwitchOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsSwitchOn;

  /// No description provided for @settingsSwitchOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsSwitchOff;

  /// No description provided for @settingsNotificationsNote.
  ///
  /// In en, this message translates to:
  /// **'Push notifications aren’t connected in this build. These choices are kept for this session.'**
  String get settingsNotificationsNote;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsSignOut;

  /// No description provided for @settingsDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes your profile, matches and messages.'**
  String get settingsDeleteNote;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDelete;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile, matches and messages will be removed. This can’t be undone.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You’re signed out'**
  String get settingsSignedOut;

  /// No description provided for @settingsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted'**
  String get settingsDeleted;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo build: nothing is sent to a server, and your profile is cleared when the app closes.'**
  String get settingsDemoNote;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(Object version);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @discoverSampleNote.
  ///
  /// In en, this message translates to:
  /// **'Sample profiles. Photos are placeholders; distances are illustrative.'**
  String get discoverSampleNote;

  /// No description provided for @discoverSampleBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample profile'**
  String get discoverSampleBadge;

  /// No description provided for @discoverVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get discoverVerified;

  /// No description provided for @discoverNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here'**
  String get discoverNewHere;

  /// No description provided for @discoverPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, photo {position} (placeholder)'**
  String discoverPhotoLabel(Object name, int position);

  /// No description provided for @discoverAboutMe.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get discoverAboutMe;

  /// No description provided for @discoverYouBothLike.
  ///
  /// In en, this message translates to:
  /// **'You both like'**
  String get discoverYouBothLike;

  /// No description provided for @discoverLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get discoverLocation;

  /// No description provided for @discoverDistance.
  ///
  /// In en, this message translates to:
  /// **'~{km} km away'**
  String discoverDistance(int km);

  /// No description provided for @discoverLivesIn.
  ///
  /// In en, this message translates to:
  /// **'Lives in {place}'**
  String discoverLivesIn(Object place);

  /// No description provided for @discoverPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get discoverPass;

  /// No description provided for @discoverLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get discoverLike;

  /// No description provided for @discoverSuperSwipe.
  ///
  /// In en, this message translates to:
  /// **'SuperSwipe'**
  String get discoverSuperSwipe;

  /// No description provided for @discoverLiked.
  ///
  /// In en, this message translates to:
  /// **'You liked {name}'**
  String discoverLiked(Object name);

  /// No description provided for @discoverSuperSent.
  ///
  /// In en, this message translates to:
  /// **'SuperSwipe sent to {name}'**
  String discoverSuperSent(Object name);

  /// No description provided for @discoverUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo: bring back {name}'**
  String discoverUndo(Object name);

  /// No description provided for @discoverOptions.
  ///
  /// In en, this message translates to:
  /// **'Profile options'**
  String get discoverOptions;

  /// No description provided for @discoverSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'{name}. Swipe right to like, left to pass, or use the buttons at the end of the profile.'**
  String discoverSwipeHint(Object name);

  /// No description provided for @discoverNoFitTitle.
  ///
  /// In en, this message translates to:
  /// **'No one fits your filters'**
  String get discoverNoFitTitle;

  /// No description provided for @discoverNoFitBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person is just outside ages {min}–{max} or {km} km.} other{{count} people are just outside ages {min}–{max} or {km} km.}}'**
  String discoverNoFitBody(int count, int min, int max, int km);

  /// No description provided for @discoverWiden.
  ///
  /// In en, this message translates to:
  /// **'Widen age and distance'**
  String get discoverWiden;

  /// No description provided for @discoverSeenAllTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve seen everyone for now'**
  String get discoverSeenAllTitle;

  /// No description provided for @discoverSeenAllBody.
  ///
  /// In en, this message translates to:
  /// **'That’s every sample profile. People you passed on can come back around.'**
  String get discoverSeenAllBody;

  /// No description provided for @discoverShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Show them again'**
  String get discoverShowAgain;

  /// No description provided for @discoverPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Home is paused'**
  String get discoverPausedTitle;

  /// No description provided for @discoverPausedBody.
  ///
  /// In en, this message translates to:
  /// **'You’re snoozed, so you won’t see new people and they won’t see you. Your matches and chats are still here.'**
  String get discoverPausedBody;

  /// No description provided for @discoverResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get discoverResume;

  /// No description provided for @discoverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load profiles'**
  String get discoverErrorTitle;

  /// No description provided for @discoverErrorBody.
  ///
  /// In en, this message translates to:
  /// **'This is a simulated connection problem. Try again, or turn it off in Settings › Prototype tools.'**
  String get discoverErrorBody;

  /// No description provided for @discoverRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get discoverRetry;

  /// No description provided for @filtersShowCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Apply filters} =1{Show 1 person} other{Show {count} people}}'**
  String filtersShowCount(int count);

  /// No description provided for @filtersNoneFit.
  ///
  /// In en, this message translates to:
  /// **'No one new fits these filters yet.'**
  String get filtersNoneFit;

  /// No description provided for @optionReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get optionReport;

  /// No description provided for @optionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String optionBlock(Object name);

  /// No description provided for @optionBlockShort.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get optionBlockShort;

  /// No description provided for @optionUnmatch.
  ///
  /// In en, this message translates to:
  /// **'Unmatch'**
  String get optionUnmatch;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockTitle(Object name);

  /// No description provided for @blockC1.
  ///
  /// In en, this message translates to:
  /// **'{name} can’t message you or see you'**
  String blockC1(Object name);

  /// No description provided for @blockC2.
  ///
  /// In en, this message translates to:
  /// **'You won’t see their profile again'**
  String get blockC2;

  /// No description provided for @blockC3.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t told'**
  String blockC3(Object name);

  /// No description provided for @blockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked'**
  String blockedToast(Object name);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report {name}'**
  String reportTitle(Object name);

  /// No description provided for @reportWhat.
  ///
  /// In en, this message translates to:
  /// **'What’s wrong?'**
  String get reportWhat;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get reportDetails;

  /// No description provided for @reportAlsoBlock.
  ///
  /// In en, this message translates to:
  /// **'Also block {name}'**
  String reportAlsoBlock(Object name);

  /// No description provided for @reportAlsoBlockDetail.
  ///
  /// In en, this message translates to:
  /// **'You won’t see each other again'**
  String get reportAlsoBlockDetail;

  /// No description provided for @reportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSend;

  /// No description provided for @reportDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Report saved'**
  String get reportDoneTitle;

  /// No description provided for @reportDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for telling us. In this demo the report is kept on this device only; nothing is sent or reviewed.'**
  String get reportDoneBody;

  /// No description provided for @reportDoneBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked.'**
  String reportDoneBlocked(Object name);

  /// No description provided for @unmatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmatch {name}?'**
  String unmatchTitle(Object name);

  /// No description provided for @unmatchC1.
  ///
  /// In en, this message translates to:
  /// **'You won’t see each other again'**
  String get unmatchC1;

  /// No description provided for @unmatchC2.
  ///
  /// In en, this message translates to:
  /// **'This conversation will be closed'**
  String get unmatchC2;

  /// No description provided for @unmatchNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Think they’ve broken our guidelines?'**
  String get unmatchNoteTitle;

  /// No description provided for @unmatchNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Report them instead. You can block them at the same time.'**
  String get unmatchNoteBody;

  /// No description provided for @conversationOptions.
  ///
  /// In en, this message translates to:
  /// **'Conversation options'**
  String get conversationOptions;

  /// No description provided for @endedUnmatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve unmatched {name}'**
  String endedUnmatchedTitle(Object name);

  /// No description provided for @endedUnmatchedBody.
  ///
  /// In en, this message translates to:
  /// **'The conversation is closed and {name} won’t appear in Home.'**
  String endedUnmatchedBody(Object name);

  /// No description provided for @endedBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve blocked {name}'**
  String endedBlockedTitle(Object name);

  /// No description provided for @endedBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t told. You won’t see each other again. Unblock any time in Settings › Blocked people.'**
  String endedBlockedBody(Object name);

  /// No description provided for @endedReportedTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve reported and blocked {name}'**
  String endedReportedTitle(Object name);

  /// No description provided for @endedReportedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t told. In this demo the report is kept on this device only; nothing is sent or reviewed.'**
  String endedReportedBody(Object name);

  /// No description provided for @backToMessages.
  ///
  /// In en, this message translates to:
  /// **'Back to messages'**
  String get backToMessages;

  /// No description provided for @matchTitle.
  ///
  /// In en, this message translates to:
  /// **'It’s a match!'**
  String get matchTitle;

  /// No description provided for @matchBody.
  ///
  /// In en, this message translates to:
  /// **'You and {name} liked each other. Now say hello.'**
  String matchBody(Object name);

  /// No description provided for @matchKeepBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Keep browsing'**
  String get matchKeepBrowsing;

  /// No description provided for @matchClose.
  ///
  /// In en, this message translates to:
  /// **'Close and keep browsing'**
  String get matchClose;

  /// No description provided for @matchSayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name}'**
  String matchSayHello(Object name);

  /// No description provided for @matchSampleNote.
  ///
  /// In en, this message translates to:
  /// **'{name} is a sample profile: messages stay on this device.'**
  String matchSampleNote(Object name);

  /// No description provided for @likesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get likesFilterAll;

  /// No description provided for @likesFilterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get likesFilterNew;

  /// No description provided for @likesFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get likesFilterNearby;

  /// No description provided for @likeTileCaption.
  ///
  /// In en, this message translates to:
  /// **'Liked your profile · about {km} km'**
  String likeTileCaption(int km);

  /// No description provided for @likeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get likeNew;

  /// No description provided for @likeMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get likeMatched;

  /// No description provided for @likesNewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No new likes'**
  String get likesNewEmptyTitle;

  /// No description provided for @likesNewEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Likes from the last day show here.'**
  String get likesNewEmptyBody;

  /// No description provided for @likesNearbyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one nearby yet'**
  String get likesNearbyEmptyTitle;

  /// No description provided for @likesNearbyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Likes from within {km} km show here.'**
  String likesNearbyEmptyBody(int km);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @likeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked your profile'**
  String get likeInfoTitle;

  /// No description provided for @likeInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Like them back to match and start chatting, or pass and they won’t be told.'**
  String get likeInfoBody;

  /// No description provided for @likeInfoMatched.
  ///
  /// In en, this message translates to:
  /// **'You’ve already matched, so this like is handled.'**
  String get likeInfoMatched;

  /// No description provided for @likeBack.
  ///
  /// In en, this message translates to:
  /// **'Like back'**
  String get likeBack;

  /// No description provided for @likePass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get likePass;

  /// No description provided for @likePassed.
  ///
  /// In en, this message translates to:
  /// **'You passed on {name}'**
  String likePassed(Object name);

  /// No description provided for @messageName.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String messageName(Object name);

  /// No description provided for @likesSampleNote.
  ///
  /// In en, this message translates to:
  /// **'Sample profiles. Photos are placeholders.'**
  String get likesSampleNote;

  /// No description provided for @tileLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {age}. {caption}'**
  String tileLabel(Object name, int age, Object caption);

  /// No description provided for @messagesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search names and messages'**
  String get messagesSearch;

  /// No description provided for @newMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'New matches ({count})'**
  String newMatchesTitle(int count);

  /// No description provided for @conversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsTitle;

  /// No description provided for @convFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get convFilterAll;

  /// No description provided for @convFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get convFilterUnread;

  /// No description provided for @convFilterMove.
  ///
  /// In en, this message translates to:
  /// **'Your move'**
  String get convFilterMove;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”'**
  String searchEmptyTitle(Object query);

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Search looks at names and messages.'**
  String get searchEmptyBody;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search everything again'**
  String get searchAgain;

  /// No description provided for @caughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get caughtUpTitle;

  /// No description provided for @caughtUpBody.
  ///
  /// In en, this message translates to:
  /// **'Conversations show here when they need you.'**
  String get caughtUpBody;

  /// No description provided for @noOneWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting on you'**
  String get noOneWaitingTitle;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String youPrefix(Object text);

  /// No description provided for @chatIntro.
  ///
  /// In en, this message translates to:
  /// **'You matched. Say hello and make it personal.'**
  String get chatIntro;

  /// No description provided for @chatOpenersLabel.
  ///
  /// In en, this message translates to:
  /// **'Need an opener? Tap one to edit it first.'**
  String get chatOpenersLabel;

  /// No description provided for @chatMatchedWith.
  ///
  /// In en, this message translates to:
  /// **'You matched with {name}'**
  String chatMatchedWith(Object name);

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String chatPlaceholder(Object name);

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatStatusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get chatStatusSending;

  /// No description provided for @chatStatusOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Demo · saved on this device, not sent'**
  String get chatStatusOnDevice;

  /// No description provided for @chatStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get chatStatusFailed;

  /// No description provided for @chatRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chatRetry;

  /// No description provided for @chatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDelete;

  /// No description provided for @chatSampleNote.
  ///
  /// In en, this message translates to:
  /// **'{name} is a sample profile. Messages stay on this device and no one replies.'**
  String chatSampleNote(Object name);

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View {name}’s profile'**
  String viewProfile(Object name);

  /// No description provided for @settingsVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get settingsVisibility;

  /// No description provided for @settingsSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get settingsSnooze;

  /// No description provided for @settingsSnoozeOff.
  ///
  /// In en, this message translates to:
  /// **'Take a break without losing matches'**
  String get settingsSnoozeOff;

  /// No description provided for @settingsSnoozeOn.
  ///
  /// In en, this message translates to:
  /// **'You’re hidden. Resume any time.'**
  String get settingsSnoozeOn;

  /// No description provided for @settingsSnoozeNote.
  ///
  /// In en, this message translates to:
  /// **'Snooze hides your profile and pauses Home. Matches and chats stay.'**
  String get settingsSnoozeNote;

  /// No description provided for @snoozedToast.
  ///
  /// In en, this message translates to:
  /// **'Snoozed. Home is paused.'**
  String get snoozedToast;

  /// No description provided for @resumedToast.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Home is on.'**
  String get resumedToast;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and safety'**
  String get settingsPrivacy;

  /// No description provided for @settingsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get settingsBlocked;

  /// No description provided for @blockedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one is blocked'**
  String get blockedEmptyTitle;

  /// No description provided for @blockedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'People you block or report show here.'**
  String get blockedEmptyBody;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @unblockName.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}'**
  String unblockName(Object name);

  /// No description provided for @unblockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is unblocked'**
  String unblockedToast(Object name);

  /// No description provided for @settingsPrototype.
  ///
  /// In en, this message translates to:
  /// **'Prototype tools'**
  String get settingsPrototype;

  /// No description provided for @settingsSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate connection problems'**
  String get settingsSimulate;

  /// No description provided for @settingsSimulateOn.
  ///
  /// In en, this message translates to:
  /// **'On: loading Home and sending messages fail'**
  String get settingsSimulateOn;

  /// No description provided for @settingsSimulateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsSimulateOff;

  /// No description provided for @settingsPrototypeNote.
  ///
  /// In en, this message translates to:
  /// **'For trying failure states in this demo build. Real Numaya has no such switch.'**
  String get settingsPrototypeNote;

  /// No description provided for @photoMakeMain.
  ///
  /// In en, this message translates to:
  /// **'Make main photo'**
  String get photoMakeMain;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get photoRemove;

  /// No description provided for @photoKeepTwo.
  ///
  /// In en, this message translates to:
  /// **'Keep at least 2 photos'**
  String get photoKeepTwo;

  /// No description provided for @photoOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo {position} options'**
  String photoOptionsLabel(int position);

  /// No description provided for @photoMadeMain.
  ///
  /// In en, this message translates to:
  /// **'Main photo updated'**
  String get photoMadeMain;

  /// No description provided for @tabNewCount.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count} new'**
  String tabNewCount(Object label, int count);

  /// No description provided for @noConvTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConvTitle;

  /// No description provided for @noConvBody.
  ///
  /// In en, this message translates to:
  /// **'Say hello to a new match to start one.'**
  String get noConvBody;

  /// No description provided for @timeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeToday;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @hoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours}h left'**
  String hoursLeft(int hours);

  /// No description provided for @minutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m left'**
  String minutesLeft(int minutes);

  /// No description provided for @queueLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get queueLikes;

  /// No description provided for @queueLikesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person likes you. Open Likes} other{{count} people like you. Open Likes}}'**
  String queueLikesLabel(int count);

  /// No description provided for @queueExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get queueExpired;

  /// No description provided for @queueExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}. Match expired'**
  String queueExpiredLabel(Object name);

  /// No description provided for @movesPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip the small talk'**
  String get movesPromoTitle;

  /// No description provided for @movesPromoBody.
  ///
  /// In en, this message translates to:
  /// **'Add up to three Opening Moves: questions your new matches can answer to start the conversation.'**
  String get movesPromoBody;

  /// No description provided for @movesPromoAction.
  ///
  /// In en, this message translates to:
  /// **'Set Opening Moves'**
  String get movesPromoAction;

  /// No description provided for @yourMoveTag.
  ///
  /// In en, this message translates to:
  /// **'Your move'**
  String get yourMoveTag;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String unreadCount(int count);

  /// No description provided for @optionViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get optionViewProfile;

  /// No description provided for @optionDidYouMeet.
  ///
  /// In en, this message translates to:
  /// **'Did you meet?'**
  String get optionDidYouMeet;

  /// No description provided for @chatExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended: you have 24 more hours'**
  String get chatExtended;

  /// No description provided for @chatExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Your match with {name} expired'**
  String chatExpiredTitle(Object name);

  /// No description provided for @chatExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Neither of you wrote within 24 hours, so the match ended. Rematch to get another 24 hours.'**
  String get chatExpiredBody;

  /// No description provided for @chatRematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get chatRematch;

  /// No description provided for @chatRematchPremium.
  ///
  /// In en, this message translates to:
  /// **'Rematch with Premium'**
  String get chatRematchPremium;

  /// No description provided for @chatExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'{time} to start the conversation'**
  String chatExpiresIn(Object time);

  /// No description provided for @chatExtendFreeNote.
  ///
  /// In en, this message translates to:
  /// **'Need more time? You get one free Extend a day.'**
  String get chatExtendFreeNote;

  /// No description provided for @chatExtendPremiumNote.
  ///
  /// In en, this message translates to:
  /// **'Premium: extend as often as you like.'**
  String get chatExtendPremiumNote;

  /// No description provided for @chatExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend 24 hours'**
  String get chatExtend;

  /// No description provided for @chatTheirMove.
  ///
  /// In en, this message translates to:
  /// **'{name}’s Opening Move'**
  String chatTheirMove(Object name);

  /// No description provided for @chatReplyToMove.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReplyToMove;

  /// No description provided for @chatSampleBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample conversation'**
  String get chatSampleBadge;

  /// No description provided for @chatTheirMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}: {text}'**
  String chatTheirMessageLabel(Object name, Object text);

  /// No description provided for @chatSampleConversationNote.
  ///
  /// In en, this message translates to:
  /// **'{name}’s messages were written for the demo. What you send stays on this device and no one replies.'**
  String chatSampleConversationNote(Object name);

  /// No description provided for @reportWhere.
  ///
  /// In en, this message translates to:
  /// **'Where did you see it?'**
  String get reportWhere;

  /// No description provided for @didMeetTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you meet {name}?'**
  String didMeetTitle(Object name);

  /// No description provided for @didMeetBody.
  ///
  /// In en, this message translates to:
  /// **'Your answer stays on this device and helps you keep track. {name} won’t see it.'**
  String didMeetBody(Object name);

  /// No description provided for @didMeetYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, we met'**
  String get didMeetYes;

  /// No description provided for @didMeetNo.
  ///
  /// In en, this message translates to:
  /// **'No, we didn’t meet'**
  String get didMeetNo;

  /// No description provided for @didMeetThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Saved on this device.'**
  String get didMeetThanks;

  /// No description provided for @unmatchedReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve unmatched {name}'**
  String unmatchedReasonTitle(Object name);

  /// No description provided for @unmatchedReasonBody.
  ///
  /// In en, this message translates to:
  /// **'Could you tell us why? Your answer stays on this device and {name} won’t know.'**
  String unmatchedReasonBody(Object name);

  /// No description provided for @unmatchReasonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get unmatchReasonSkip;

  /// No description provided for @unmatchReasonThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Your answer is saved on this device.'**
  String get unmatchReasonThanks;

  /// No description provided for @filtersDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filtersDone;

  /// No description provided for @filtersWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get filtersWomen;

  /// No description provided for @filtersMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get filtersMen;

  /// No description provided for @filtersNonbinary.
  ///
  /// In en, this message translates to:
  /// **'Nonbinary people'**
  String get filtersNonbinary;

  /// No description provided for @filtersWhoHeading.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to date?'**
  String get filtersWhoHeading;

  /// No description provided for @filtersEveryone.
  ///
  /// In en, this message translates to:
  /// **'Showing everyone. Pick one or more to narrow it down.'**
  String get filtersEveryone;

  /// No description provided for @filtersWhoHint.
  ///
  /// In en, this message translates to:
  /// **'Only the people you picked appear on Home.'**
  String get filtersWhoHint;

  /// No description provided for @filtersAgeFallback.
  ///
  /// In en, this message translates to:
  /// **'See people 2 years either side if I run out'**
  String get filtersAgeFallback;

  /// No description provided for @filtersDistanceFallback.
  ///
  /// In en, this message translates to:
  /// **'See people slightly further away if I run out'**
  String get filtersDistanceFallback;

  /// No description provided for @filtersVerifiedHeading.
  ///
  /// In en, this message translates to:
  /// **'Have they verified themselves?'**
  String get filtersVerifiedHeading;

  /// No description provided for @filtersVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified profiles only'**
  String get filtersVerifiedOnly;

  /// No description provided for @filtersVerifiedNote.
  ///
  /// In en, this message translates to:
  /// **'Only people who have verified their photos.'**
  String get filtersVerifiedNote;

  /// No description provided for @filtersWhatsThis.
  ///
  /// In en, this message translates to:
  /// **'What’s photo verification?'**
  String get filtersWhatsThis;

  /// No description provided for @filtersAdvancedLocked.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters are part of Premium'**
  String get filtersAdvancedLocked;

  /// No description provided for @filtersAdvancedLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Narrow down by height, intentions and more. In this demo Premium is simulated: no payment is taken.'**
  String get filtersAdvancedLockedBody;

  /// No description provided for @premiumSee.
  ///
  /// In en, this message translates to:
  /// **'See Premium'**
  String get premiumSee;

  /// No description provided for @filtersHeightHeading.
  ///
  /// In en, this message translates to:
  /// **'What is their height?'**
  String get filtersHeightHeading;

  /// No description provided for @filtersHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get filtersHeight;

  /// No description provided for @filtersAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filtersAny;

  /// No description provided for @filtersTallerThan.
  ///
  /// In en, this message translates to:
  /// **'Taller than {cm} cm'**
  String filtersTallerThan(int cm);

  /// No description provided for @filtersIntentionsHeading.
  ///
  /// In en, this message translates to:
  /// **'What do they want from their dates?'**
  String get filtersIntentionsHeading;

  /// No description provided for @filtersMoreHeading.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get filtersMoreHeading;

  /// No description provided for @filtersAddFilter.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get filtersAddFilter;

  /// No description provided for @filtersAdvancedFallback.
  ///
  /// In en, this message translates to:
  /// **'Show other people if I run out'**
  String get filtersAdvancedFallback;

  /// No description provided for @filtersBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get filtersBasic;

  /// No description provided for @filtersAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get filtersAdvanced;

  /// No description provided for @filtersUsingFallback.
  ///
  /// In en, this message translates to:
  /// **'Nobody fits exactly, so people just outside your filters will show.'**
  String get filtersUsingFallback;

  /// No description provided for @discoverSuperSentLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{SuperSwipe sent to {name}. 1 left} other{SuperSwipe sent to {name}. {count} left}}'**
  String discoverSuperSentLeft(int count, Object name);

  /// No description provided for @forYouOpen.
  ///
  /// In en, this message translates to:
  /// **'For you: today’s picks'**
  String get forYouOpen;

  /// No description provided for @discoverFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Showing people just outside your filters'**
  String get discoverFallbackTitle;

  /// No description provided for @discoverFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Nobody fit exactly, so your “if I run out” settings are on.'**
  String get discoverFallbackBody;

  /// No description provided for @forYouTitle.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYouTitle;

  /// No description provided for @forYouRefresh.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{New picks in 1 hour} other{New picks in {hours} hours}}'**
  String forYouRefresh(int hours);

  /// No description provided for @forYouLede.
  ///
  /// In en, this message translates to:
  /// **'People you have the most in common with, picked once a day.'**
  String get forYouLede;

  /// No description provided for @forYouEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve seen today’s picks'**
  String get forYouEmptyTitle;

  /// No description provided for @forYouEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{New people arrive in 1 hour.} other{New people arrive in {hours} hours.}}'**
  String forYouEmptyBody(int hours);

  /// No description provided for @forYouBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get forYouBackHome;

  /// No description provided for @forYouOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open {name}’s profile'**
  String forYouOpenProfile(Object name);

  /// No description provided for @forYouInCommon.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Picked for you} =1{1 thing in common} other{{count} things in common}}'**
  String forYouInCommon(int count);

  /// No description provided for @forYouLike.
  ///
  /// In en, this message translates to:
  /// **'Like {name}'**
  String forYouLike(Object name);

  /// No description provided for @forYouRationale.
  ///
  /// In en, this message translates to:
  /// **'Based on your interests and who you’ve liked. Sample profiles.'**
  String get forYouRationale;

  /// No description provided for @likeAction.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeAction;

  /// No description provided for @personMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This profile isn’t available'**
  String get personMissingTitle;

  /// No description provided for @personMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed. Go back to keep exploring.'**
  String get personMissingBody;

  /// No description provided for @heightValue.
  ///
  /// In en, this message translates to:
  /// **'{cm} cm'**
  String heightValue(int cm);

  /// No description provided for @appealHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened. Be as specific as you can.'**
  String get appealHint;

  /// No description provided for @appealLabel.
  ///
  /// In en, this message translates to:
  /// **'Your appeal'**
  String get appealLabel;

  /// No description provided for @appealPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'I think this was a mistake because…'**
  String get appealPlaceholder;

  /// No description provided for @appealSend.
  ///
  /// In en, this message translates to:
  /// **'Send appeal'**
  String get appealSend;

  /// No description provided for @appealSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Appeal saved'**
  String get appealSentTitle;

  /// No description provided for @appealSentBody.
  ///
  /// In en, this message translates to:
  /// **'In this demo nothing is sent or reviewed. In the real app a person reviews appeals and replies by email.'**
  String get appealSentBody;

  /// No description provided for @blockedAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account on hold'**
  String get blockedAccountTitle;

  /// No description provided for @blockedAccountHeading.
  ///
  /// In en, this message translates to:
  /// **'Your account has been blocked'**
  String get blockedAccountHeading;

  /// No description provided for @blockedAccountBody.
  ///
  /// In en, this message translates to:
  /// **'We found activity that goes against our guidelines. You can appeal within 6 months. This is a preview of a screen the server would show.'**
  String get blockedAccountBody;

  /// No description provided for @completionTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completionTitle;

  /// No description provided for @completionPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String completionPercent(int percent);

  /// No description provided for @completionLede.
  ///
  /// In en, this message translates to:
  /// **'Profiles with more to talk about get more matches. Pick up where you like.'**
  String get completionLede;

  /// No description provided for @completionDone.
  ///
  /// In en, this message translates to:
  /// **'Your profile is complete. Nice work.'**
  String get completionDone;

  /// No description provided for @completionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get completionPhotos;

  /// No description provided for @completionPrompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get completionPrompts;

  /// No description provided for @completionInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get completionInterests;

  /// No description provided for @completionBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get completionBio;

  /// No description provided for @completionAbout.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get completionAbout;

  /// No description provided for @completionMore.
  ///
  /// In en, this message translates to:
  /// **'More about you'**
  String get completionMore;

  /// No description provided for @completionProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} added'**
  String completionProgress(int done, int total);

  /// No description provided for @contactTopic.
  ///
  /// In en, this message translates to:
  /// **'What’s it about?'**
  String get contactTopic;

  /// No description provided for @contactTopicAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get contactTopicAccount;

  /// No description provided for @contactTopicSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety or someone’s behaviour'**
  String get contactTopicSafety;

  /// No description provided for @contactTopicVerification.
  ///
  /// In en, this message translates to:
  /// **'Photo verification'**
  String get contactTopicVerification;

  /// No description provided for @contactTopicBilling.
  ///
  /// In en, this message translates to:
  /// **'Premium and billing'**
  String get contactTopicBilling;

  /// No description provided for @contactTopicOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get contactTopicOther;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get contactMessage;

  /// No description provided for @contactSend.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get contactSend;

  /// No description provided for @contactDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo build: your message stays on this device and nobody reads it.'**
  String get contactDemoNote;

  /// No description provided for @contactSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Message saved'**
  String get contactSentTitle;

  /// No description provided for @contactSentBody.
  ///
  /// In en, this message translates to:
  /// **'In this demo nothing is sent. In the real app, support replies within a day.'**
  String get contactSentBody;

  /// No description provided for @deleteHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteHeading;

  /// No description provided for @deleteLede.
  ///
  /// In en, this message translates to:
  /// **'Before you go, tell us why. It helps us improve.'**
  String get deleteLede;

  /// No description provided for @deleteWhy.
  ///
  /// In en, this message translates to:
  /// **'Why are you leaving?'**
  String get deleteWhy;

  /// No description provided for @deleteSnoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Just need a break?'**
  String get deleteSnoozeTitle;

  /// No description provided for @deleteSnoozeBody.
  ///
  /// In en, this message translates to:
  /// **'Snooze hides your profile and keeps your matches and chats.'**
  String get deleteSnoozeBody;

  /// No description provided for @deleteSnoozeAction.
  ///
  /// In en, this message translates to:
  /// **'Snooze instead'**
  String get deleteSnoozeAction;

  /// No description provided for @deleteC1.
  ///
  /// In en, this message translates to:
  /// **'Your profile is hidden from everyone straight away'**
  String get deleteC1;

  /// No description provided for @deleteC2.
  ///
  /// In en, this message translates to:
  /// **'Your matches and messages are removed'**
  String get deleteC2;

  /// No description provided for @deleteC3.
  ///
  /// In en, this message translates to:
  /// **'You can restore everything for 28 days by signing in again'**
  String get deleteC3;

  /// No description provided for @deleteSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Premium plan won’t be cancelled'**
  String get deleteSubscriptionTitle;

  /// No description provided for @deleteSubscriptionBody.
  ///
  /// In en, this message translates to:
  /// **'Cancel it in your app store first. In this demo there is no real subscription.'**
  String get deleteSubscriptionBody;

  /// No description provided for @deleteContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get deleteContinue;

  /// No description provided for @deleteHelp.
  ///
  /// In en, this message translates to:
  /// **'What happens when I delete?'**
  String get deleteHelp;

  /// No description provided for @deleteRestoreNote.
  ///
  /// In en, this message translates to:
  /// **'Changed your mind? Sign in with the same number within 28 days to restore it.'**
  String get deleteRestoreNote;

  /// No description provided for @demoHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo hub'**
  String get demoHubTitle;

  /// No description provided for @demoHubBanner.
  ///
  /// In en, this message translates to:
  /// **'Development build only'**
  String get demoHubBanner;

  /// No description provided for @demoHubBody.
  ///
  /// In en, this message translates to:
  /// **'Jump to any screen, switch the sample data and try each state. Everything here is local and simulated.'**
  String get demoHubBody;

  /// No description provided for @demoStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get demoStart;

  /// No description provided for @demoQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start as Alex (sample account)'**
  String get demoQuickStart;

  /// No description provided for @demoQuickStartNote.
  ///
  /// In en, this message translates to:
  /// **'Skips sign-up with a finished sample profile and a fictional 555 number.'**
  String get demoQuickStartNote;

  /// No description provided for @demoSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You’re signed in. Quick start replaces this session with the sample account.'**
  String get demoSignedIn;

  /// No description provided for @demoWorld.
  ///
  /// In en, this message translates to:
  /// **'Sample world'**
  String get demoWorld;

  /// No description provided for @demoWorldFull.
  ///
  /// In en, this message translates to:
  /// **'Full demo'**
  String get demoWorldFull;

  /// No description provided for @demoWorldFullBody.
  ///
  /// In en, this message translates to:
  /// **'12 profiles, 7 likes, matches in the queue (one expiring soon, one expired) and 3 sample conversations'**
  String get demoWorldFullBody;

  /// No description provided for @demoWorldFresh.
  ///
  /// In en, this message translates to:
  /// **'Brand-new account'**
  String get demoWorldFresh;

  /// No description provided for @demoWorldFreshBody.
  ///
  /// In en, this message translates to:
  /// **'7 profiles, 5 likes, no matches or conversations'**
  String get demoWorldFreshBody;

  /// No description provided for @demoReset.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get demoReset;

  /// No description provided for @demoResetDone.
  ///
  /// In en, this message translates to:
  /// **'Demo data reset'**
  String get demoResetDone;

  /// No description provided for @demoSwitches.
  ///
  /// In en, this message translates to:
  /// **'Switches'**
  String get demoSwitches;

  /// No description provided for @demoPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium (simulated)'**
  String get demoPremium;

  /// No description provided for @demoPremiumNote.
  ///
  /// In en, this message translates to:
  /// **'Unlocks Premium features without the paywall'**
  String get demoPremiumNote;

  /// No description provided for @demoApproveVerification.
  ///
  /// In en, this message translates to:
  /// **'Approve the next verification'**
  String get demoApproveVerification;

  /// No description provided for @demoApproveOn.
  ///
  /// In en, this message translates to:
  /// **'The next selfie is approved'**
  String get demoApproveOn;

  /// No description provided for @demoApproveOff.
  ///
  /// In en, this message translates to:
  /// **'The next selfie is declined'**
  String get demoApproveOff;

  /// No description provided for @demoResetVerification.
  ///
  /// In en, this message translates to:
  /// **'Reset photo verification'**
  String get demoResetVerification;

  /// No description provided for @demoAreaAccount.
  ///
  /// In en, this message translates to:
  /// **'Account and onboarding'**
  String get demoAreaAccount;

  /// No description provided for @demoAreaDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get demoAreaDiscover;

  /// No description provided for @demoAreaMatching.
  ///
  /// In en, this message translates to:
  /// **'Likes, matches and messages'**
  String get demoAreaMatching;

  /// No description provided for @demoAreaProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get demoAreaProfile;

  /// No description provided for @demoAreaSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings, safety and help'**
  String get demoAreaSettings;

  /// No description provided for @demoWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get demoWelcome;

  /// No description provided for @demoRestoreHow.
  ///
  /// In en, this message translates to:
  /// **'Account restore: delete the account in Settings, then sign in again with the same number.'**
  String get demoRestoreHow;

  /// No description provided for @demoSampleProfile.
  ///
  /// In en, this message translates to:
  /// **'A sample profile with Like and Pass'**
  String get demoSampleProfile;

  /// No description provided for @demoLikeProfile.
  ///
  /// In en, this message translates to:
  /// **'A like’s profile (Maya)'**
  String get demoLikeProfile;

  /// No description provided for @demoMatchScreen.
  ///
  /// In en, this message translates to:
  /// **'Match celebration (Maya)'**
  String get demoMatchScreen;

  /// No description provided for @demoChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation with history (Priya)'**
  String get demoChatHistory;

  /// No description provided for @demoChatNew.
  ///
  /// In en, this message translates to:
  /// **'New match, 21 hours left (Jo)'**
  String get demoChatNew;

  /// No description provided for @demoChatExpiring.
  ///
  /// In en, this message translates to:
  /// **'Match about to expire (Lina)'**
  String get demoChatExpiring;

  /// No description provided for @demoChatExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired match (Ollie)'**
  String get demoChatExpired;

  /// No description provided for @demoFullOnly.
  ///
  /// In en, this message translates to:
  /// **'The named matches and conversations exist in the full demo.'**
  String get demoFullOnly;

  /// No description provided for @demoNeedsSession.
  ///
  /// In en, this message translates to:
  /// **'Sign in or use Quick start first'**
  String get demoNeedsSession;

  /// No description provided for @demoNotFound.
  ///
  /// In en, this message translates to:
  /// **'A link that doesn’t exist'**
  String get demoNotFound;

  /// No description provided for @editAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get editAdd;

  /// No description provided for @editAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a prompt'**
  String get editAddPrompt;

  /// No description provided for @editPromptsSection.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get editPromptsSection;

  /// No description provided for @editPromptsHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of 3 added. Prompts give people something to reply to.} other{{count} of 3 added. Prompts give people something to reply to.}}'**
  String editPromptsHint(int count);

  /// No description provided for @editBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editBio;

  /// No description provided for @editBioHint.
  ///
  /// In en, this message translates to:
  /// **'A short, punchy intro.'**
  String get editBioHint;

  /// No description provided for @editBioAdd.
  ///
  /// In en, this message translates to:
  /// **'Write a short intro'**
  String get editBioAdd;

  /// No description provided for @editBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Weekend baker, weekday spreadsheet wrangler…'**
  String get editBioPlaceholder;

  /// No description provided for @editBioTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Show your personality'**
  String get editBioTipTitle;

  /// No description provided for @editBioTip.
  ///
  /// In en, this message translates to:
  /// **'Share a quirk, an interest or a bit of humour to help you stand out.'**
  String get editBioTip;

  /// No description provided for @editClear.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get editClear;

  /// No description provided for @editGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editGender;

  /// No description provided for @editGenderMore.
  ///
  /// In en, this message translates to:
  /// **'Add more about your gender'**
  String get editGenderMore;

  /// No description provided for @editGenderLegend.
  ///
  /// In en, this message translates to:
  /// **'Which describes you best?'**
  String get editGenderLegend;

  /// No description provided for @editGenderShow.
  ///
  /// In en, this message translates to:
  /// **'Show my gender on my profile'**
  String get editGenderShow;

  /// No description provided for @editGenderShowNote.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time.'**
  String get editGenderShowNote;

  /// No description provided for @editHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get editHeight;

  /// No description provided for @editLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get editLanguages;

  /// No description provided for @editLanguagesHint.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} chosen'**
  String editLanguagesHint(int count, int total);

  /// No description provided for @editMoreAbout.
  ///
  /// In en, this message translates to:
  /// **'More about you'**
  String get editMoreAbout;

  /// No description provided for @editMoreAboutNote.
  ///
  /// In en, this message translates to:
  /// **'Answer only what you’re comfortable sharing. Some answers help with filters.'**
  String get editMoreAboutNote;

  /// No description provided for @editMoreSection.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get editMoreSection;

  /// No description provided for @editPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get editPreferNotToSay;

  /// No description provided for @editPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview profile'**
  String get editPreview;

  /// No description provided for @editVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify my profile'**
  String get editVerify;

  /// No description provided for @featureLikes.
  ///
  /// In en, this message translates to:
  /// **'Like as many people as you want'**
  String get featureLikes;

  /// No description provided for @featureSeeLikes.
  ///
  /// In en, this message translates to:
  /// **'See who liked you'**
  String get featureSeeLikes;

  /// No description provided for @featureExtend.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Extends'**
  String get featureExtend;

  /// No description provided for @featureRematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch with expired matches'**
  String get featureRematch;

  /// No description provided for @featureAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get featureAdvancedFilters;

  /// No description provided for @featureIncognito.
  ///
  /// In en, this message translates to:
  /// **'Incognito'**
  String get featureIncognito;

  /// No description provided for @featureTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel mode'**
  String get featureTravel;

  /// No description provided for @featureSuperSwipes.
  ///
  /// In en, this message translates to:
  /// **'5 extra SuperSwipes'**
  String get featureSuperSwipes;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help centre'**
  String get helpTitle;

  /// No description provided for @helpSearch.
  ///
  /// In en, this message translates to:
  /// **'Search help'**
  String get helpSearch;

  /// No description provided for @helpTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get helpTopics;

  /// No description provided for @helpNoResults.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or contact us.'**
  String get helpNoResults;

  /// No description provided for @helpStillStuck.
  ///
  /// In en, this message translates to:
  /// **'Still stuck?'**
  String get helpStillStuck;

  /// No description provided for @helpContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get helpContact;

  /// No description provided for @helpMissing.
  ///
  /// In en, this message translates to:
  /// **'That article doesn’t exist any more.'**
  String get helpMissing;

  /// No description provided for @incognito.
  ///
  /// In en, this message translates to:
  /// **'Incognito'**
  String get incognito;

  /// No description provided for @incognitoOn.
  ///
  /// In en, this message translates to:
  /// **'Only people you like can see you'**
  String get incognitoOn;

  /// No description provided for @incognitoOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get incognitoOff;

  /// No description provided for @incognitoNote.
  ///
  /// In en, this message translates to:
  /// **'With Incognito, only people you’ve liked can see your profile.'**
  String get incognitoNote;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'In this demo, logging out clears your profile and sample data from this device.'**
  String get logoutBody;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This page isn’t here'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The link may be old or mistyped. Nothing was lost.'**
  String get notFoundBody;

  /// No description provided for @notFoundStart.
  ///
  /// In en, this message translates to:
  /// **'Back to the start'**
  String get notFoundStart;

  /// No description provided for @notificationsMore.
  ///
  /// In en, this message translates to:
  /// **'More notification settings'**
  String get notificationsMore;

  /// No description provided for @notifMatches.
  ///
  /// In en, this message translates to:
  /// **'New matches'**
  String get notifMatches;

  /// No description provided for @notifExpiring.
  ///
  /// In en, this message translates to:
  /// **'Matches about to expire'**
  String get notifExpiring;

  /// No description provided for @notifTips.
  ///
  /// In en, this message translates to:
  /// **'Tips and news'**
  String get notifTips;

  /// No description provided for @notifPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get notifPush;

  /// No description provided for @notifInApp.
  ///
  /// In en, this message translates to:
  /// **'In-app'**
  String get notifInApp;

  /// No description provided for @notifEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get notifEmail;

  /// No description provided for @notifNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address on file'**
  String get notifNoEmail;

  /// No description provided for @notifWarning.
  ///
  /// In en, this message translates to:
  /// **'Turning these off might mean you miss alerts from your matches.'**
  String get notifWarning;

  /// No description provided for @notifEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Push isn’t connected in this build, so these are saved as preferences only.'**
  String get notifEmailNote;

  /// No description provided for @openingMovesTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening Moves'**
  String get openingMovesTitle;

  /// No description provided for @openingMovesHeading.
  ///
  /// In en, this message translates to:
  /// **'Your Opening Moves'**
  String get openingMovesHeading;

  /// No description provided for @openingMovesLede.
  ///
  /// In en, this message translates to:
  /// **'Skip the “hey”. Choose up to three questions your new matches can answer.'**
  String get openingMovesLede;

  /// No description provided for @openingMovesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3'**
  String openingMovesCount(int count);

  /// No description provided for @openingMovesNote.
  ///
  /// In en, this message translates to:
  /// **'Your matches see one Opening Move when you match. They can answer it or start their own way.'**
  String get openingMovesNote;

  /// No description provided for @openingMoveFirst.
  ///
  /// In en, this message translates to:
  /// **'First Opening Move'**
  String get openingMoveFirst;

  /// No description provided for @openingMoveSecond.
  ///
  /// In en, this message translates to:
  /// **'Second Opening Move'**
  String get openingMoveSecond;

  /// No description provided for @openingMoveThird.
  ///
  /// In en, this message translates to:
  /// **'Third Opening Move'**
  String get openingMoveThird;

  /// No description provided for @openingMoveEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your Opening Move'**
  String get openingMoveEditTitle;

  /// No description provided for @openingMoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get openingMoveLabel;

  /// No description provided for @openingMoveSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Need an idea?'**
  String get openingMoveSuggestions;

  /// No description provided for @openingMoveRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Opening Move'**
  String get openingMoveRemove;

  /// No description provided for @openingMoveRemoved.
  ///
  /// In en, this message translates to:
  /// **'Opening Move removed'**
  String get openingMoveRemoved;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Get more with Premium'**
  String get paywallTitle;

  /// No description provided for @paywallForFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters come with Premium'**
  String get paywallForFilters;

  /// No description provided for @paywallForRematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch comes with Premium'**
  String get paywallForRematch;

  /// No description provided for @paywallForExtend.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Extends come with Premium'**
  String get paywallForExtend;

  /// No description provided for @paywallForIncognito.
  ///
  /// In en, this message translates to:
  /// **'Incognito comes with Premium'**
  String get paywallForIncognito;

  /// No description provided for @paywallForTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel mode comes with Premium'**
  String get paywallForTravel;

  /// No description provided for @paywallForSuperSwipes.
  ///
  /// In en, this message translates to:
  /// **'You’re out of SuperSwipes'**
  String get paywallForSuperSwipes;

  /// No description provided for @paywallLede.
  ///
  /// In en, this message translates to:
  /// **'Premium in this demo is simulated: no store is connected and no payment is taken.'**
  String get paywallLede;

  /// No description provided for @paywallPlans.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get paywallPlans;

  /// No description provided for @paywallChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to continue'**
  String get paywallChoose;

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan} · {price}'**
  String paywallContinue(Object plan, Object price);

  /// No description provided for @paywallLegal.
  ///
  /// In en, this message translates to:
  /// **'Demo only. In a real build, plans renew automatically until cancelled in your app store. Prices are illustrative.'**
  String get paywallLegal;

  /// No description provided for @paywallConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulated purchase'**
  String get paywallConfirmTitle;

  /// No description provided for @paywallConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{plan} for {price}. This is a demo: nothing is charged and no store is contacted.'**
  String paywallConfirmBody(Object plan, Object price);

  /// No description provided for @paywallConfirmBuy.
  ///
  /// In en, this message translates to:
  /// **'Complete demo purchase'**
  String get paywallConfirmBuy;

  /// No description provided for @paywallConfirmFail.
  ///
  /// In en, this message translates to:
  /// **'Simulate a failed payment'**
  String get paywallConfirmFail;

  /// No description provided for @paywallFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'The payment didn’t go through'**
  String get paywallFailedTitle;

  /// No description provided for @paywallFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Simulated failure. Nothing was charged and your plan is still selected. Try again when you’re ready.'**
  String get paywallFailedBody;

  /// No description provided for @paywallSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all set'**
  String get paywallSuccessTitle;

  /// No description provided for @paywallAlreadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get paywallAlreadyTitle;

  /// No description provided for @paywallSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Premium is active until {date}. Demo only: no payment was taken.'**
  String paywallSuccessBody(Object date);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No store is connected in this demo, so there’s nothing to restore.'**
  String get paywallRestoreNone;

  /// No description provided for @premiumName.
  ///
  /// In en, this message translates to:
  /// **'Numaya Premium'**
  String get premiumName;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get premiumActive;

  /// No description provided for @premiumActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String premiumActiveUntil(Object date);

  /// No description provided for @premiumActivePlan.
  ///
  /// In en, this message translates to:
  /// **'{plan} plan, simulated. Cancel any time below.'**
  String premiumActivePlan(Object plan);

  /// No description provided for @premiumCardBody.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters, Rematch, unlimited Extends, Incognito and Travel.'**
  String get premiumCardBody;

  /// No description provided for @premiumExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Premium'**
  String get premiumExplore;

  /// No description provided for @premiumManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get premiumManage;

  /// No description provided for @premiumHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'More ways to meet the right people'**
  String get premiumHeroTitle;

  /// No description provided for @premiumHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Everything in Numaya stays free. Premium adds control and extra time.'**
  String get premiumHeroBody;

  /// No description provided for @premiumYourExtras.
  ///
  /// In en, this message translates to:
  /// **'Your extras'**
  String get premiumYourExtras;

  /// No description provided for @premiumSuperSwipesLeft.
  ///
  /// In en, this message translates to:
  /// **'SuperSwipes left'**
  String get premiumSuperSwipesLeft;

  /// No description provided for @premiumCompare.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get premiumCompare;

  /// No description provided for @premiumFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get premiumFree;

  /// No description provided for @premiumShort.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumShort;

  /// No description provided for @premiumSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get premiumSeePlans;

  /// No description provided for @premiumCancelDemo.
  ///
  /// In en, this message translates to:
  /// **'Cancel demo plan'**
  String get premiumCancelDemo;

  /// No description provided for @premiumCancelled.
  ///
  /// In en, this message translates to:
  /// **'Demo plan cancelled'**
  String get premiumCancelled;

  /// No description provided for @premiumDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo build: prices and plans are illustrative and nothing is charged.'**
  String get premiumDemoNote;

  /// No description provided for @premiumHelp.
  ///
  /// In en, this message translates to:
  /// **'Billing and cancelling'**
  String get premiumHelp;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumOnly;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTitle;

  /// No description provided for @previewBadge.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewBadge;

  /// No description provided for @previewInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'This is how others see you'**
  String get previewInfoTitle;

  /// No description provided for @previewInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Only what you’ve added is shown. Hidden fields stay hidden.'**
  String get previewInfoBody;

  /// No description provided for @previewEdit.
  ///
  /// In en, this message translates to:
  /// **'Back to editing'**
  String get previewEdit;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility'**
  String get privacyTitle;

  /// No description provided for @privacyShowTitle.
  ///
  /// In en, this message translates to:
  /// **'On your profile'**
  String get privacyShowTitle;

  /// No description provided for @privacyShowAge.
  ///
  /// In en, this message translates to:
  /// **'Show my age'**
  String get privacyShowAge;

  /// No description provided for @privacyShowDistance.
  ///
  /// In en, this message translates to:
  /// **'Show my distance'**
  String get privacyShowDistance;

  /// No description provided for @privacyShowNote.
  ///
  /// In en, this message translates to:
  /// **'Your age is still used for matching, even when it’s hidden.'**
  String get privacyShowNote;

  /// No description provided for @privacyWhoSees.
  ///
  /// In en, this message translates to:
  /// **'Who can see you'**
  String get privacyWhoSees;

  /// No description provided for @profileComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get profileComplete;

  /// No description provided for @profileCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile {percent}% complete'**
  String profileCompletionLabel(int percent);

  /// No description provided for @profileInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get profileInterestsTitle;

  /// No description provided for @profileYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileYourProfile;

  /// No description provided for @profileSafetySupport.
  ///
  /// In en, this message translates to:
  /// **'Safety and support'**
  String get profileSafetySupport;

  /// No description provided for @promptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove prompt'**
  String get promptRemove;

  /// No description provided for @promptRemoved.
  ///
  /// In en, this message translates to:
  /// **'Prompt removed'**
  String get promptRemoved;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get restoreTitle;

  /// No description provided for @restoreBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted recently. You can restore it, with your profile, until {date}.'**
  String restoreBody(Object date);

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore my account'**
  String get restoreAction;

  /// No description provided for @restoreStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start a new profile instead'**
  String get restoreStartOver;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Your account is back'**
  String get restoreDone;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety and wellbeing'**
  String get safetyTitle;

  /// No description provided for @safetyHeading.
  ///
  /// In en, this message translates to:
  /// **'Date with confidence'**
  String get safetyHeading;

  /// No description provided for @safetyLede.
  ///
  /// In en, this message translates to:
  /// **'Tips for meeting people, and the tools that keep you in control.'**
  String get safetyLede;

  /// No description provided for @safetyTip1Title.
  ///
  /// In en, this message translates to:
  /// **'Keep it on Numaya at first'**
  String get safetyTip1Title;

  /// No description provided for @safetyTip1Body.
  ///
  /// In en, this message translates to:
  /// **'Chat here until you feel comfortable. Never send money or share financial details.'**
  String get safetyTip1Body;

  /// No description provided for @safetyTip2Title.
  ///
  /// In en, this message translates to:
  /// **'Meet in public'**
  String get safetyTip2Title;

  /// No description provided for @safetyTip2Body.
  ///
  /// In en, this message translates to:
  /// **'Tell a friend your plans and arrange your own way there and back.'**
  String get safetyTip2Body;

  /// No description provided for @safetyTip3Title.
  ///
  /// In en, this message translates to:
  /// **'Report anything that feels off'**
  String get safetyTip3Title;

  /// No description provided for @safetyTip3Body.
  ///
  /// In en, this message translates to:
  /// **'Reports are anonymous. Blocking someone means you won’t see each other again.'**
  String get safetyTip3Body;

  /// No description provided for @safetyTools.
  ///
  /// In en, this message translates to:
  /// **'Your tools'**
  String get safetyTools;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @settingsLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Location isn’t read in this build; the sample area stands in for it.'**
  String get settingsLocationNote;

  /// No description provided for @settingsCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get settingsCurrentLocation;

  /// No description provided for @settingsSampleLocation.
  ///
  /// In en, this message translates to:
  /// **'Hackney, London (sample)'**
  String get settingsSampleLocation;

  /// No description provided for @settingsHelpLegal.
  ///
  /// In en, this message translates to:
  /// **'Help and legal'**
  String get settingsHelpLegal;

  /// No description provided for @snoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snoozeTitle;

  /// No description provided for @snoozeBody.
  ///
  /// In en, this message translates to:
  /// **'Hide your profile from new people for a while. You keep your matches and chats.'**
  String get snoozeBody;

  /// No description provided for @snoozeHowLong.
  ///
  /// In en, this message translates to:
  /// **'How long?'**
  String get snoozeHowLong;

  /// No description provided for @snooze24h.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get snooze24h;

  /// No description provided for @snooze72h.
  ///
  /// In en, this message translates to:
  /// **'72 hours'**
  String get snooze72h;

  /// No description provided for @snoozeWeek.
  ///
  /// In en, this message translates to:
  /// **'A week'**
  String get snoozeWeek;

  /// No description provided for @snoozeIndefinite.
  ///
  /// In en, this message translates to:
  /// **'Until I turn it off'**
  String get snoozeIndefinite;

  /// No description provided for @snoozeNoStatus.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get snoozeNoStatus;

  /// No description provided for @snoozeUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String snoozeUntil(Object date);

  /// No description provided for @travelTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travelTitle;

  /// No description provided for @travelBody.
  ///
  /// In en, this message translates to:
  /// **'Planning a trip? Meet people there before you go. Demo: changes the sample location only.'**
  String get travelBody;

  /// No description provided for @travelPick.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get travelPick;

  /// No description provided for @travelOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off Travel'**
  String get travelOff;

  /// No description provided for @travelOffValue.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get travelOffValue;

  /// No description provided for @travelOnValue.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get travelOnValue;

  /// No description provided for @travelSet.
  ///
  /// In en, this message translates to:
  /// **'Travel set to {city}'**
  String travelSet(Object city);

  /// No description provided for @travelEnded.
  ///
  /// In en, this message translates to:
  /// **'Travel turned off'**
  String get travelEnded;

  /// No description provided for @verifyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Show them it’s really you'**
  String get verifyIntroTitle;

  /// No description provided for @verifyIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Copy a pose and take a selfie. When it matches your photos, a badge goes on your profile.'**
  String get verifyIntroBody;

  /// No description provided for @verifyDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulated in this demo'**
  String get verifyDemoTitle;

  /// No description provided for @verifyDemoBody.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t used and nobody reviews the photo. The result appears after a few seconds.'**
  String get verifyDemoBody;

  /// No description provided for @verifyStart.
  ///
  /// In en, this message translates to:
  /// **'Let’s get verified'**
  String get verifyStart;

  /// No description provided for @verifyHelp.
  ///
  /// In en, this message translates to:
  /// **'How does verification work?'**
  String get verifyHelp;

  /// No description provided for @verifyCopyPose.
  ///
  /// In en, this message translates to:
  /// **'Copy this pose'**
  String get verifyCopyPose;

  /// No description provided for @verifyViewfinderLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera preview. Pose to copy: {pose}'**
  String verifyViewfinderLabel(Object pose);

  /// No description provided for @verifyCameraOff.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t connected in this demo. Take a demo selfie to continue.'**
  String get verifyCameraOff;

  /// No description provided for @verifyTakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take demo selfie'**
  String get verifyTakeSelfie;

  /// No description provided for @verifyOtherPose.
  ///
  /// In en, this message translates to:
  /// **'Show me a different pose'**
  String get verifyOtherPose;

  /// No description provided for @verifyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Happy with it?'**
  String get verifyReviewTitle;

  /// No description provided for @verifyReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Your selfie is compared with your profile photos. It isn’t shown on your profile.'**
  String get verifyReviewBody;

  /// No description provided for @verifyDemoSelfie.
  ///
  /// In en, this message translates to:
  /// **'Demo selfie (placeholder)'**
  String get verifyDemoSelfie;

  /// No description provided for @verifyRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get verifyRetake;

  /// No description provided for @verifyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking your selfie'**
  String get verifyPendingTitle;

  /// No description provided for @verifyPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Usually a few minutes. In this demo the review is simulated and takes a few seconds.'**
  String get verifyPendingBody;

  /// No description provided for @verifyDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re verified'**
  String get verifyDoneTitle;

  /// No description provided for @verifyDoneBody.
  ///
  /// In en, this message translates to:
  /// **'The badge is on your profile. People who filter for verified profiles can now see you.'**
  String get verifyDoneBody;

  /// No description provided for @verifyRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify you'**
  String get verifyRejectedTitle;

  /// No description provided for @verifyRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The pose didn’t match. You have 1 more try.} other{The pose didn’t match. You have {count} more tries.}}'**
  String verifyRejectedBody(int count);

  /// No description provided for @verifyRejectedSupport.
  ///
  /// In en, this message translates to:
  /// **'After three tries, a person can help. Contact support and we’ll sort it out.'**
  String get verifyRejectedSupport;

  /// No description provided for @verifyTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get verifyTipsTitle;

  /// No description provided for @verifyTip1.
  ///
  /// In en, this message translates to:
  /// **'Find good, even light'**
  String get verifyTip1;

  /// No description provided for @verifyTip2.
  ///
  /// In en, this message translates to:
  /// **'Keep your face and hand in the frame'**
  String get verifyTip2;

  /// No description provided for @verifyTip3.
  ///
  /// In en, this message translates to:
  /// **'Copy the pose exactly'**
  String get verifyTip3;

  /// No description provided for @verifyTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get verifyTryAgain;

  /// No description provided for @verifyStatusNone.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get verifyStatusNone;

  /// No description provided for @verifyStatusPending.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get verifyStatusPending;

  /// No description provided for @verifyStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get verifyStatusRejected;

  /// No description provided for @verifyStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifyStatusVerified;

  /// No description provided for @photoVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo verification'**
  String get photoVerifyTitle;

  /// No description provided for @photoVerifySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get photoVerifySubmit;

  /// No description provided for @demoHubOpen.
  ///
  /// In en, this message translates to:
  /// **'Demo build. Open the demo hub'**
  String get demoHubOpen;

  /// No description provided for @matchTheirMove.
  ///
  /// In en, this message translates to:
  /// **'{name}’s Opening Move: “{move}”'**
  String matchTheirMove(Object move, Object name);

  /// No description provided for @photoMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get photoMoveEarlier;

  /// No description provided for @photoMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get photoMoveLater;

  /// No description provided for @photoReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace with a new placeholder'**
  String get photoReplace;

  /// No description provided for @photoMoved.
  ///
  /// In en, this message translates to:
  /// **'Photo order updated'**
  String get photoMoved;

  /// No description provided for @photoReplaced.
  ///
  /// In en, this message translates to:
  /// **'Photo replaced (placeholder: upload isn’t connected)'**
  String get photoReplaced;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApp;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationNote.
  ///
  /// In en, this message translates to:
  /// **'A short tap when you choose an option, like, match or send. Your phone’s own vibration setting still applies.'**
  String get settingsVibrationNote;

  /// No description provided for @demoReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get demoReduceMotion;

  /// No description provided for @demoReduceMotionNote.
  ///
  /// In en, this message translates to:
  /// **'Acts as if the phone’s Remove animations setting were on'**
  String get demoReduceMotionNote;

  /// No description provided for @setupSectionAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get setupSectionAboutLabel;

  /// No description provided for @setupSectionAboutDetail.
  ///
  /// In en, this message translates to:
  /// **'Your name, birthday and gender'**
  String get setupSectionAboutDetail;

  /// No description provided for @setupSectionLookingLabel.
  ///
  /// In en, this message translates to:
  /// **'Who you’re looking for'**
  String get setupSectionLookingLabel;

  /// No description provided for @setupSectionLookingDetail.
  ///
  /// In en, this message translates to:
  /// **'Who you want to meet, what for and where'**
  String get setupSectionLookingDetail;

  /// No description provided for @setupSectionProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get setupSectionProfileLabel;

  /// No description provided for @setupSectionProfileDetail.
  ///
  /// In en, this message translates to:
  /// **'Photos, interests, prompts and a bio'**
  String get setupSectionProfileDetail;

  /// No description provided for @setupSectionFinishLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get setupSectionFinishLabel;

  /// No description provided for @setupSectionFinishDetail.
  ///
  /// In en, this message translates to:
  /// **'Verification, notifications and a last look'**
  String get setupSectionFinishDetail;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get obContinue;

  /// No description provided for @obNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s start with an intro'**
  String get obNameTitle;

  /// No description provided for @obNameLede.
  ///
  /// In en, this message translates to:
  /// **'Your first name and age appear on your profile. Your birthday doesn’t.'**
  String get obNameLede;

  /// No description provided for @obNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name.'**
  String get obNameEmpty;

  /// No description provided for @obNameCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use letters only, without numbers or emoji.'**
  String get obNameCharacters;

  /// No description provided for @obBirthdayLegend.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get obBirthdayLegend;

  /// No description provided for @obDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get obDay;

  /// No description provided for @obMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get obMonth;

  /// No description provided for @obYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get obYear;

  /// No description provided for @obBirthdayInvalid.
  ///
  /// In en, this message translates to:
  /// **'That date doesn’t exist. Check the day and month.'**
  String get obBirthdayInvalid;

  /// No description provided for @obBirthdayFuture.
  ///
  /// In en, this message translates to:
  /// **'That date is in the future.'**
  String get obBirthdayFuture;

  /// No description provided for @obBirthdayUnrealistic.
  ///
  /// In en, this message translates to:
  /// **'Check the year: that’s more than 100 years ago.'**
  String get obBirthdayUnrealistic;

  /// No description provided for @obBirthdayUnderage.
  ///
  /// In en, this message translates to:
  /// **'You need to be 18 or over to use Numaya.'**
  String get obBirthdayUnderage;

  /// No description provided for @obAgeHint.
  ///
  /// In en, this message translates to:
  /// **'You’re {age}'**
  String obAgeHint(int age);

  /// No description provided for @obNameFooter.
  ///
  /// In en, this message translates to:
  /// **'Only your age is shown'**
  String get obNameFooter;

  /// No description provided for @obNameFooterMissing.
  ///
  /// In en, this message translates to:
  /// **'Add your name and birthday'**
  String get obNameFooterMissing;

  /// No description provided for @obConfirmAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re {age}'**
  String obConfirmAgeTitle(int age);

  /// No description provided for @obConfirmAgeBorn.
  ///
  /// In en, this message translates to:
  /// **'Born {date}'**
  String obConfirmAgeBorn(String date);

  /// No description provided for @obConfirmAgeBody.
  ///
  /// In en, this message translates to:
  /// **'Make sure this is right. You can’t change your birthday later.'**
  String get obConfirmAgeBody;

  /// No description provided for @obConfirmEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get obConfirmEdit;

  /// No description provided for @obConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get obConfirm;

  /// No description provided for @obUnderageTitle.
  ///
  /// In en, this message translates to:
  /// **'Numaya is for adults'**
  String get obUnderageTitle;

  /// No description provided for @obUnderageBody.
  ///
  /// In en, this message translates to:
  /// **'You need to be 18 or over to use Numaya, so we can’t create a profile for you. Nothing you entered has been saved to a profile.'**
  String get obUnderageBody;

  /// No description provided for @obUnderageSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get obUnderageSignOut;

  /// No description provided for @obUnderageHelp.
  ///
  /// In en, this message translates to:
  /// **'Read about our age rules'**
  String get obUnderageHelp;

  /// No description provided for @obGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get obGenderTitle;

  /// No description provided for @obGenderLede.
  ///
  /// In en, this message translates to:
  /// **'Add more detail if you like, and choose what your profile shows.'**
  String get obGenderLede;

  /// No description provided for @obGenderMore.
  ///
  /// In en, this message translates to:
  /// **'Add more about your gender'**
  String get obGenderMore;

  /// No description provided for @obPronounsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pronouns · optional'**
  String get obPronounsLabel;

  /// No description provided for @obPronounsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String obPronounsCount(int count, int max);

  /// No description provided for @obShowGender.
  ///
  /// In en, this message translates to:
  /// **'Show gender on profile'**
  String get obShowGender;

  /// No description provided for @obShowPronouns.
  ///
  /// In en, this message translates to:
  /// **'Show pronouns on profile'**
  String get obShowPronouns;

  /// No description provided for @obGenderFooter.
  ///
  /// In en, this message translates to:
  /// **'Pronouns are optional'**
  String get obGenderFooter;

  /// No description provided for @obGenderFooterMissing.
  ///
  /// In en, this message translates to:
  /// **'Choose one to continue'**
  String get obGenderFooterMissing;

  /// No description provided for @obMeetTitle.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to meet?'**
  String get obMeetTitle;

  /// No description provided for @obMeetLede.
  ///
  /// In en, this message translates to:
  /// **'Pick all that apply. This is private: it’s never shown on your profile.'**
  String get obMeetLede;

  /// No description provided for @obEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get obEveryone;

  /// No description provided for @obAgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Their age'**
  String get obAgesLabel;

  /// No description provided for @obMeetFooter.
  ///
  /// In en, this message translates to:
  /// **'Hidden on your profile'**
  String get obMeetFooter;

  /// No description provided for @obMeetFooterMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one'**
  String get obMeetFooterMissing;

  /// No description provided for @obIntentTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you hoping to find?'**
  String get obIntentTitle;

  /// No description provided for @obIntentLede.
  ///
  /// In en, this message translates to:
  /// **'Pick one or two. This shows on your profile.'**
  String get obIntentLede;

  /// No description provided for @obIntentFooter.
  ///
  /// In en, this message translates to:
  /// **'{count} of 2 picked'**
  String obIntentFooter(int count);

  /// No description provided for @obIntentFooterMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one'**
  String get obIntentFooterMissing;

  /// No description provided for @obHeightTitle.
  ///
  /// In en, this message translates to:
  /// **'How tall are you?'**
  String get obHeightTitle;

  /// No description provided for @obHeightLede.
  ///
  /// In en, this message translates to:
  /// **'Optional. If you add it, it shows on your profile.'**
  String get obHeightLede;

  /// No description provided for @obHeightCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get obHeightCm;

  /// No description provided for @obHeightFtIn.
  ///
  /// In en, this message translates to:
  /// **'ft / in'**
  String get obHeightFtIn;

  /// No description provided for @obHeightFeet.
  ///
  /// In en, this message translates to:
  /// **'{feet}′ {inches}″'**
  String obHeightFeet(int feet, int inches);

  /// No description provided for @obHeightShorter.
  ///
  /// In en, this message translates to:
  /// **'Shorter'**
  String get obHeightShorter;

  /// No description provided for @obHeightTaller.
  ///
  /// In en, this message translates to:
  /// **'Taller'**
  String get obHeightTaller;

  /// No description provided for @obHeightUnitLegend.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get obHeightUnitLegend;

  /// No description provided for @obHeightAdd.
  ///
  /// In en, this message translates to:
  /// **'Add my height'**
  String get obHeightAdd;

  /// No description provided for @obHeightFooter.
  ///
  /// In en, this message translates to:
  /// **'Shown on your profile'**
  String get obHeightFooter;

  /// No description provided for @obHeightFooterNone.
  ///
  /// In en, this message translates to:
  /// **'You can skip this'**
  String get obHeightFooterNone;

  /// No description provided for @obHeightRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove height'**
  String get obHeightRemove;

  /// No description provided for @obLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to meet people?'**
  String get obLocationTitle;

  /// No description provided for @obLocationLede.
  ///
  /// In en, this message translates to:
  /// **'Numaya uses your area to show you people nearby. Only the area appears on your profile, never your exact location.'**
  String get obLocationLede;

  /// No description provided for @obLocationUse.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get obLocationUse;

  /// No description provided for @obLocationChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose my area instead'**
  String get obLocationChoose;

  /// No description provided for @obLocationDemo.
  ///
  /// In en, this message translates to:
  /// **'The phone’s location is never read in this build. Allowing sets a sample area.'**
  String get obLocationDemo;

  /// No description provided for @obLocationSetDevice.
  ///
  /// In en, this message translates to:
  /// **'{area} (sample area)'**
  String obLocationSetDevice(String area);

  /// No description provided for @obLocationAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Your area'**
  String get obLocationAreaLabel;

  /// No description provided for @obLocationChange.
  ///
  /// In en, this message translates to:
  /// **'Change area'**
  String get obLocationChange;

  /// No description provided for @obLocationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is off'**
  String get obLocationDeniedTitle;

  /// No description provided for @obLocationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'That’s fine. Choose your area instead, or try again.'**
  String get obLocationDeniedBody;

  /// No description provided for @obLocationTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get obLocationTryAgain;

  /// No description provided for @obLocationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for Numaya'**
  String get obLocationBlockedTitle;

  /// No description provided for @obLocationBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Android won’t ask again. Turn location on in Settings, or choose your area.'**
  String get obLocationBlockedBody;

  /// No description provided for @obOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get obOpenSettings;

  /// No description provided for @obOpenSettingsDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo build: this would open Numaya’s Android settings.'**
  String get obOpenSettingsDemo;

  /// No description provided for @obLocationFooter.
  ///
  /// In en, this message translates to:
  /// **'Only your area is shown'**
  String get obLocationFooter;

  /// No description provided for @obLocationFooterNone.
  ///
  /// In en, this message translates to:
  /// **'You can set this later'**
  String get obLocationFooterNone;

  /// No description provided for @obAreaSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your area'**
  String get obAreaSheetTitle;

  /// No description provided for @obAreaSearch.
  ///
  /// In en, this message translates to:
  /// **'Search areas'**
  String get obAreaSearch;

  /// No description provided for @obAreaNone.
  ///
  /// In en, this message translates to:
  /// **'No areas match “{query}”'**
  String obAreaNone(String query);

  /// No description provided for @permDemoTag.
  ///
  /// In en, this message translates to:
  /// **'Demo · stands in for Android’s prompt'**
  String get permDemoTag;

  /// No description provided for @permLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Numaya to access this device’s location?'**
  String get permLocationTitle;

  /// No description provided for @permAllowApproximate.
  ///
  /// In en, this message translates to:
  /// **'While using the app · approximate'**
  String get permAllowApproximate;

  /// No description provided for @permAllowPrecise.
  ///
  /// In en, this message translates to:
  /// **'While using the app · precise'**
  String get permAllowPrecise;

  /// No description provided for @permCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Numaya to take pictures and record video?'**
  String get permCameraTitle;

  /// No description provided for @permNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Numaya to send you notifications?'**
  String get permNotificationsTitle;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permAllow;

  /// No description provided for @permDeny.
  ///
  /// In en, this message translates to:
  /// **'Don’t allow'**
  String get permDeny;

  /// No description provided for @photoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get photoSourceTitle;

  /// No description provided for @photoSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoSourceCamera;

  /// No description provided for @photoSourceLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get photoSourceLibrary;

  /// No description provided for @photoSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Demo build: no camera or photo picker is connected, so either choice adds a placeholder tile.'**
  String get photoSourceNote;

  /// No description provided for @photoCameraDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is off for Numaya'**
  String get photoCameraDeniedTitle;

  /// No description provided for @photoCameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Choose from your library instead, or allow the camera next time.'**
  String get photoCameraDeniedBody;

  /// No description provided for @photoCameraBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Android won’t ask again. Turn the camera on in Settings, or use your library.'**
  String get photoCameraBlockedBody;

  /// No description provided for @photoTipsLink.
  ///
  /// In en, this message translates to:
  /// **'Photo tips'**
  String get photoTipsLink;

  /// No description provided for @photoTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo tips'**
  String get photoTipsTitle;

  /// No description provided for @photoTip1.
  ///
  /// In en, this message translates to:
  /// **'Make your main photo just you, with your face clearly visible.'**
  String get photoTip1;

  /// No description provided for @photoTip2.
  ///
  /// In en, this message translates to:
  /// **'Use recent photos taken in good light.'**
  String get photoTip2;

  /// No description provided for @photoTip3.
  ///
  /// In en, this message translates to:
  /// **'Show something you love doing.'**
  String get photoTip3;

  /// No description provided for @photoTip4.
  ///
  /// In en, this message translates to:
  /// **'Skip heavy filters, sunglasses in every shot and group photos as your main one.'**
  String get photoTip4;

  /// No description provided for @photoTipsNote.
  ///
  /// In en, this message translates to:
  /// **'These are tips. Numaya doesn’t scan your photos.'**
  String get photoTipsNote;

  /// No description provided for @interestsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search interests'**
  String get interestsSearch;

  /// No description provided for @interestsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No interests match “{query}”'**
  String interestsNoResults(String query);

  /// No description provided for @interestsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get interestsClearSearch;

  /// No description provided for @obPromptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick prompts to share your story'**
  String get obPromptsTitle;

  /// No description provided for @obPromptsLede.
  ///
  /// In en, this message translates to:
  /// **'Answer at least one, up to three. People can reply to any of them.'**
  String get obPromptsLede;

  /// No description provided for @obPromptSlot.
  ///
  /// In en, this message translates to:
  /// **'Prompt {n}'**
  String obPromptSlot(int n);

  /// No description provided for @obPromptAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a prompt'**
  String get obPromptAdd;

  /// No description provided for @obPromptRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get obPromptRequired;

  /// No description provided for @obPromptOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get obPromptOptional;

  /// No description provided for @obPromptsFooter.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 answered'**
  String obPromptsFooter(int count);

  /// No description provided for @obPromptsFooterMissing.
  ///
  /// In en, this message translates to:
  /// **'Answer one to continue'**
  String get obPromptsFooterMissing;

  /// No description provided for @promptAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Already answered'**
  String get promptAlreadyUsed;

  /// No description provided for @obBioTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a short bio'**
  String get obBioTitle;

  /// No description provided for @obBioLede.
  ///
  /// In en, this message translates to:
  /// **'Optional. A few lines about you, in your own words.'**
  String get obBioLede;

  /// No description provided for @obBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get obBioLabel;

  /// No description provided for @obBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Weekday baker, weekend hill walker…'**
  String get obBioPlaceholder;

  /// No description provided for @obBioTip.
  ///
  /// In en, this message translates to:
  /// **'Something specific says more than a list of adjectives.'**
  String get obBioTip;

  /// No description provided for @obBioPreview.
  ///
  /// In en, this message translates to:
  /// **'How it reads on your profile'**
  String get obBioPreview;

  /// No description provided for @obBioFooter.
  ///
  /// In en, this message translates to:
  /// **'Shown on your profile'**
  String get obBioFooter;

  /// No description provided for @obBioFooterNone.
  ///
  /// In en, this message translates to:
  /// **'You can skip this'**
  String get obBioFooterNone;

  /// No description provided for @obBioClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get obBioClear;

  /// No description provided for @obVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your photos?'**
  String get obVerifyTitle;

  /// No description provided for @obVerifyLede.
  ///
  /// In en, this message translates to:
  /// **'A quick selfie shows people your photos are really you. Verified profiles get a badge.'**
  String get obVerifyLede;

  /// No description provided for @obVerifyPrivacy.
  ///
  /// In en, this message translates to:
  /// **'The selfie is only used to check your photos. It isn’t shown on your profile.'**
  String get obVerifyPrivacy;

  /// No description provided for @obVerifyDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo build: verification is simulated. No selfie is taken, sent or checked, and the result isn’t a real verification.'**
  String get obVerifyDemo;

  /// No description provided for @obVerifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify now'**
  String get obVerifyNow;

  /// No description provided for @obVerifyLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get obVerifyLater;

  /// No description provided for @obVerifyPending.
  ///
  /// In en, this message translates to:
  /// **'In review (simulated)'**
  String get obVerifyPending;

  /// No description provided for @obVerifyDone.
  ///
  /// In en, this message translates to:
  /// **'Verified (simulated)'**
  String get obVerifyDone;

  /// No description provided for @obVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Not approved (simulated). You can try again from your profile.'**
  String get obVerifyFailed;

  /// No description provided for @obVerifyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String obVerifyStatus(String status);

  /// No description provided for @obNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Don’t miss a match'**
  String get obNotifTitle;

  /// No description provided for @obNotifLede.
  ///
  /// In en, this message translates to:
  /// **'Get told about new matches, messages and matches about to expire.'**
  String get obNotifLede;

  /// No description provided for @obNotifAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get obNotifAllow;

  /// No description provided for @obNotifLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get obNotifLater;

  /// No description provided for @obNotifDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo build: no notifications are sent. Your answer sets the switches in Settings.'**
  String get obNotifDemo;

  /// No description provided for @obNotifAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on.'**
  String get obNotifAllowed;

  /// No description provided for @obNotifDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. You can turn them on in Settings.'**
  String get obNotifDenied;

  /// No description provided for @obNotifBlocked.
  ///
  /// In en, this message translates to:
  /// **'Android won’t ask again. Turn notifications on in Android’s settings.'**
  String get obNotifBlocked;

  /// No description provided for @obReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get obReviewTitle;

  /// No description provided for @obReviewLede.
  ///
  /// In en, this message translates to:
  /// **'This is how other people will see you. Check it, then create your profile.'**
  String get obReviewLede;

  /// No description provided for @obReviewMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you can finish'**
  String get obReviewMissingTitle;

  /// No description provided for @obMissingName.
  ///
  /// In en, this message translates to:
  /// **'Add your first name'**
  String get obMissingName;

  /// No description provided for @obMissingBirthday.
  ///
  /// In en, this message translates to:
  /// **'Add your birthday'**
  String get obMissingBirthday;

  /// No description provided for @obMissingGender.
  ///
  /// In en, this message translates to:
  /// **'Choose your gender'**
  String get obMissingGender;

  /// No description provided for @obMissingOpenTo.
  ///
  /// In en, this message translates to:
  /// **'Choose who you want to meet'**
  String get obMissingOpenTo;

  /// No description provided for @obMissingIntentions.
  ///
  /// In en, this message translates to:
  /// **'Choose what you’re hoping to find'**
  String get obMissingIntentions;

  /// No description provided for @obMissingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least {min} photos'**
  String obMissingPhotos(int min);

  /// No description provided for @obMissingInterests.
  ///
  /// In en, this message translates to:
  /// **'Pick {min} to {max} interests'**
  String obMissingInterests(int min, int max);

  /// No description provided for @obMissingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Answer a prompt'**
  String get obMissingPrompt;

  /// No description provided for @obReviewPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Only you see this'**
  String get obReviewPrivateTitle;

  /// No description provided for @obReviewMeet.
  ///
  /// In en, this message translates to:
  /// **'Wants to meet'**
  String get obReviewMeet;

  /// No description provided for @obReviewAges.
  ///
  /// In en, this message translates to:
  /// **'Ages {min}–{max}'**
  String obReviewAges(int min, int max);

  /// No description provided for @obReviewArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get obReviewArea;

  /// No description provided for @obReviewNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get obReviewNotSet;

  /// No description provided for @obReviewVerification.
  ///
  /// In en, this message translates to:
  /// **'Photo verification'**
  String get obReviewVerification;

  /// No description provided for @obReviewNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get obReviewNotVerified;

  /// No description provided for @obReviewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get obReviewNotifications;

  /// No description provided for @obReviewOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get obReviewOn;

  /// No description provided for @obReviewOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get obReviewOff;

  /// No description provided for @obReviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get obReviewEdit;

  /// No description provided for @obReviewEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit {item}'**
  String obReviewEditItem(String item);

  /// No description provided for @obReviewCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my profile'**
  String get obReviewCreate;

  /// No description provided for @obReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t create your profile. Check your connection and try again.'**
  String get obReviewFailed;

  /// No description provided for @obReviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Your profile is kept on this device only.'**
  String get obReviewSaved;

  /// No description provided for @obReviewPublicTitle.
  ///
  /// In en, this message translates to:
  /// **'On your profile'**
  String get obReviewPublicTitle;

  /// No description provided for @obDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all set, {name}'**
  String obDoneTitle(String name);

  /// No description provided for @obDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready. Start with today’s people, or keep adding to your profile any time.'**
  String get obDoneBody;

  /// No description provided for @obDoneStart.
  ///
  /// In en, this message translates to:
  /// **'Start discovering'**
  String get obDoneStart;

  /// No description provided for @obDoneSample.
  ///
  /// In en, this message translates to:
  /// **'Everyone you’ll see is a sample profile.'**
  String get obDoneSample;

  /// No description provided for @editBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get editBirthday;

  /// No description provided for @editBirthdayLocked.
  ///
  /// In en, this message translates to:
  /// **'Your birthday can’t be changed after setup.'**
  String get editBirthdayLocked;

  /// No description provided for @demoAreaOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get demoAreaOnboarding;

  /// No description provided for @demoPermissionsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset permission answers'**
  String get demoPermissionsReset;

  /// No description provided for @demoPermissionsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Permission answers reset'**
  String get demoPermissionsResetDone;

  /// No description provided for @demoOnboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start a new sign-up (skips the code)'**
  String get demoOnboardingStart;

  /// No description provided for @demoOnboardingNote.
  ///
  /// In en, this message translates to:
  /// **'Opens profile setup for a new demo account. Each step can also be opened directly once an account exists.'**
  String get demoOnboardingNote;

  /// No description provided for @demoNeedsAccount.
  ///
  /// In en, this message translates to:
  /// **'Start a sign-up first'**
  String get demoNeedsAccount;

  /// No description provided for @obMeetLegend.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get obMeetLegend;

  /// No description provided for @obNotifFooter.
  ///
  /// In en, this message translates to:
  /// **'You can change this in Settings'**
  String get obNotifFooter;

  /// No description provided for @obVerifyFooter.
  ///
  /// In en, this message translates to:
  /// **'Optional · you can verify later'**
  String get obVerifyFooter;

  /// No description provided for @obDemoBuild.
  ///
  /// In en, this message translates to:
  /// **'Demo build'**
  String get obDemoBuild;

  /// No description provided for @discoverUndone.
  ///
  /// In en, this message translates to:
  /// **'{name} is back'**
  String discoverUndone(Object name);

  /// No description provided for @discoverCoach.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to like, left to pass. Scroll for more about them.'**
  String get discoverCoach;

  /// No description provided for @discoverCoachDismiss.
  ///
  /// In en, this message translates to:
  /// **'Hide tip'**
  String get discoverCoachDismiss;

  /// No description provided for @discoverMoreAbout.
  ///
  /// In en, this message translates to:
  /// **'Show more about {name}'**
  String discoverMoreAbout(Object name);

  /// No description provided for @discoverPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String discoverPhotoCount(int count);

  /// No description provided for @discoverOpenPhotos.
  ///
  /// In en, this message translates to:
  /// **'See {name}’s photos'**
  String discoverOpenPhotos(Object name);

  /// No description provided for @discoverReportBlock.
  ///
  /// In en, this message translates to:
  /// **'Report or block {name}'**
  String discoverReportBlock(Object name);

  /// No description provided for @discoverSeenAllLikedBody.
  ///
  /// In en, this message translates to:
  /// **'You liked everyone you saw. New people don’t arrive in this demo, so check who likes you instead.'**
  String get discoverSeenAllLikedBody;

  /// No description provided for @discoverSeeLikes.
  ///
  /// In en, this message translates to:
  /// **'See who likes you'**
  String get discoverSeeLikes;

  /// No description provided for @discoverErrorStillTitle.
  ///
  /// In en, this message translates to:
  /// **'Still can’t load profiles'**
  String get discoverErrorStillTitle;

  /// No description provided for @discoverFiltersChanged.
  ///
  /// In en, this message translates to:
  /// **'Filters, changed from your preferences'**
  String get discoverFiltersChanged;

  /// No description provided for @photoViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}’s photos'**
  String photoViewerTitle(Object name);

  /// No description provided for @photoViewerPosition.
  ///
  /// In en, this message translates to:
  /// **'Photo {position} of {count}'**
  String photoViewerPosition(int position, int count);

  /// No description provided for @photoViewerNext.
  ///
  /// In en, this message translates to:
  /// **'Next photo'**
  String get photoViewerNext;

  /// No description provided for @photoViewerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous photo'**
  String get photoViewerPrevious;

  /// No description provided for @photoViewerNote.
  ///
  /// In en, this message translates to:
  /// **'Placeholders. Sample profiles have no real photos.'**
  String get photoViewerNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
