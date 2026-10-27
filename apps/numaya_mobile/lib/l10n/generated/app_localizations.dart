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

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles to show yet'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'People appear here once matching is connected. This demo build doesn’t include it.'**
  String get discoverEmptyBody;

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
  /// **'Keep at least 2.'**
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

  /// No description provided for @settingsNewMatches.
  ///
  /// In en, this message translates to:
  /// **'New matches'**
  String get settingsNewMatches;

  /// No description provided for @settingsMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages'**
  String get settingsMessages;

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
