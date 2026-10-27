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
