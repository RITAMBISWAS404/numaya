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
  String get editPhotosHint =>
      'Tap a photo to make it your main one. Keep at least 2.';

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
  String get settingsNewLikes => 'New likes';

  @override
  String get settingsMessages => 'New messages';

  @override
  String get settingsSwitchOn => 'On';

  @override
  String get settingsSwitchOff => 'Off';

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

  @override
  String get done => 'Done';

  @override
  String get discoverSampleNote =>
      'Sample profiles. Photos are placeholders; distances are illustrative.';

  @override
  String get discoverSampleBadge => 'Sample profile';

  @override
  String get discoverVerified => 'Verified';

  @override
  String get discoverNewHere => 'New here';

  @override
  String discoverPhotoLabel(Object name, int position) {
    return '$name, photo $position (placeholder)';
  }

  @override
  String get discoverAboutMe => 'About me';

  @override
  String get discoverYouBothLike => 'You both like';

  @override
  String get discoverLocation => 'My location';

  @override
  String discoverDistance(int km) {
    return '~$km km away';
  }

  @override
  String discoverLivesIn(Object place) {
    return 'Lives in $place';
  }

  @override
  String get discoverPass => 'Pass';

  @override
  String get discoverLike => 'Like';

  @override
  String get discoverSuperSwipe => 'SuperSwipe';

  @override
  String discoverLiked(Object name) {
    return 'You liked $name';
  }

  @override
  String discoverSuperSent(Object name) {
    return 'SuperSwipe sent to $name';
  }

  @override
  String discoverUndo(Object name) {
    return 'Undo: bring back $name';
  }

  @override
  String get discoverOptions => 'Profile options';

  @override
  String discoverSwipeHint(Object name) {
    return '$name. Swipe right to like, left to pass, or use the buttons at the end of the profile.';
  }

  @override
  String get discoverNoFitTitle => 'No one fits your filters';

  @override
  String discoverNoFitBody(int count, int min, int max, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people are just outside ages $min–$max or $km km.',
      one: '1 person is just outside ages $min–$max or $km km.',
    );
    return '$_temp0';
  }

  @override
  String get discoverWiden => 'Widen age and distance';

  @override
  String get discoverSeenAllTitle => 'You’ve seen everyone for now';

  @override
  String get discoverSeenAllBody =>
      'That’s every sample profile. People you passed on can come back around.';

  @override
  String get discoverShowAgain => 'Show them again';

  @override
  String get discoverPausedTitle => 'Home is paused';

  @override
  String get discoverPausedBody =>
      'You’re snoozed, so you won’t see new people and they won’t see you. Your matches and chats are still here.';

  @override
  String get discoverResume => 'Resume';

  @override
  String get discoverErrorTitle => 'We couldn’t load profiles';

  @override
  String get discoverErrorBody =>
      'This is a simulated connection problem. Try again, or turn it off in Settings › Prototype tools.';

  @override
  String get discoverRetry => 'Try again';

  @override
  String filtersShowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count people',
      one: 'Show 1 person',
      zero: 'Apply filters',
    );
    return '$_temp0';
  }

  @override
  String get filtersNoneFit => 'No one new fits these filters yet.';

  @override
  String get optionReport => 'Report';

  @override
  String optionBlock(Object name) {
    return 'Block $name';
  }

  @override
  String get optionBlockShort => 'Block';

  @override
  String get optionUnmatch => 'Unmatch';

  @override
  String blockTitle(Object name) {
    return 'Block $name?';
  }

  @override
  String blockC1(Object name) {
    return '$name can’t message you or see you';
  }

  @override
  String get blockC2 => 'You won’t see their profile again';

  @override
  String blockC3(Object name) {
    return '$name isn’t told';
  }

  @override
  String blockedToast(Object name) {
    return '$name is blocked';
  }

  @override
  String reportTitle(Object name) {
    return 'Report $name';
  }

  @override
  String get reportWhat => 'What’s wrong?';

  @override
  String get reportDetails => 'Anything else? (optional)';

  @override
  String reportAlsoBlock(Object name) {
    return 'Also block $name';
  }

  @override
  String get reportAlsoBlockDetail => 'You won’t see each other again';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportDoneTitle => 'Report saved';

  @override
  String get reportDoneBody =>
      'Thanks for telling us. In this demo the report is kept on this device only; nothing is sent or reviewed.';

  @override
  String reportDoneBlocked(Object name) {
    return '$name is blocked.';
  }

  @override
  String unmatchTitle(Object name) {
    return 'Unmatch $name?';
  }

  @override
  String get unmatchC1 => 'You won’t see each other again';

  @override
  String get unmatchC2 => 'This conversation will be closed';

  @override
  String get unmatchNoteTitle => 'Think they’ve broken our guidelines?';

  @override
  String get unmatchNoteBody =>
      'Report them instead. You can block them at the same time.';

  @override
  String get conversationOptions => 'Conversation options';

  @override
  String endedUnmatchedTitle(Object name) {
    return 'You’ve unmatched $name';
  }

  @override
  String endedUnmatchedBody(Object name) {
    return 'The conversation is closed and $name won’t appear in Home.';
  }

  @override
  String endedBlockedTitle(Object name) {
    return 'You’ve blocked $name';
  }

  @override
  String endedBlockedBody(Object name) {
    return '$name isn’t told. You won’t see each other again. Unblock any time in Settings › Blocked people.';
  }

  @override
  String endedReportedTitle(Object name) {
    return 'You’ve reported and blocked $name';
  }

  @override
  String endedReportedBody(Object name) {
    return '$name isn’t told. In this demo the report is kept on this device only; nothing is sent or reviewed.';
  }

  @override
  String get backToMessages => 'Back to messages';

  @override
  String get matchTitle => 'It’s a match!';

  @override
  String matchBody(Object name) {
    return 'You and $name liked each other. Now say hello.';
  }

  @override
  String get matchKeepBrowsing => 'Keep browsing';

  @override
  String get matchClose => 'Close and keep browsing';

  @override
  String matchSayHello(Object name) {
    return 'Say hello to $name';
  }

  @override
  String matchSampleNote(Object name) {
    return '$name is a sample profile: messages stay on this device.';
  }

  @override
  String get likesFilterAll => 'All';

  @override
  String get likesFilterNew => 'New';

  @override
  String get likesFilterNearby => 'Nearby';

  @override
  String likeTileCaption(int km) {
    return 'Liked your profile · about $km km';
  }

  @override
  String get likeNew => 'New';

  @override
  String get likeMatched => 'Matched';

  @override
  String get likesNewEmptyTitle => 'No new likes';

  @override
  String get likesNewEmptyBody => 'Likes from the last day show here.';

  @override
  String get likesNearbyEmptyTitle => 'No one nearby yet';

  @override
  String likesNearbyEmptyBody(int km) {
    return 'Likes from within $km km show here.';
  }

  @override
  String get showAll => 'Show all';

  @override
  String get likeInfoTitle => 'Liked your profile';

  @override
  String get likeInfoBody =>
      'Like them back to match and start chatting, or pass and they won’t be told.';

  @override
  String get likeInfoMatched =>
      'You’ve already matched, so this like is handled.';

  @override
  String get likeBack => 'Like back';

  @override
  String get likePass => 'Pass';

  @override
  String likePassed(Object name) {
    return 'You passed on $name';
  }

  @override
  String messageName(Object name) {
    return 'Message $name';
  }

  @override
  String get likesSampleNote => 'Sample profiles. Photos are placeholders.';

  @override
  String tileLabel(Object name, int age, Object caption) {
    return '$name, $age. $caption';
  }

  @override
  String get messagesSearch => 'Search names and messages';

  @override
  String newMatchesTitle(int count) {
    return 'New matches ($count)';
  }

  @override
  String get conversationsTitle => 'Conversations';

  @override
  String get convFilterAll => 'All';

  @override
  String get convFilterUnread => 'Unread';

  @override
  String get convFilterMove => 'Your move';

  @override
  String searchEmptyTitle(Object query) {
    return 'Nothing matches “$query”';
  }

  @override
  String get searchEmptyBody => 'Search looks at names and messages.';

  @override
  String get searchAgain => 'Search everything again';

  @override
  String get caughtUpTitle => 'You’re all caught up';

  @override
  String get caughtUpBody => 'Conversations show here when they need you.';

  @override
  String get noOneWaitingTitle => 'No one is waiting on you';

  @override
  String youPrefix(Object text) {
    return 'You: $text';
  }

  @override
  String get chatIntro => 'You matched. Say hello and make it personal.';

  @override
  String get chatOpenersLabel => 'Need an opener? Tap one to edit it first.';

  @override
  String chatMatchedWith(Object name) {
    return 'You matched with $name';
  }

  @override
  String chatPlaceholder(Object name) {
    return 'Message $name';
  }

  @override
  String get chatSend => 'Send';

  @override
  String get chatStatusSending => 'Sending…';

  @override
  String get chatStatusOnDevice => 'Demo · saved on this device, not sent';

  @override
  String get chatStatusFailed => 'Not sent';

  @override
  String get chatRetry => 'Retry';

  @override
  String get chatDelete => 'Delete';

  @override
  String chatSampleNote(Object name) {
    return '$name is a sample profile. Messages stay on this device and no one replies.';
  }

  @override
  String viewProfile(Object name) {
    return 'View $name’s profile';
  }

  @override
  String get settingsVisibility => 'Visibility';

  @override
  String get settingsSnooze => 'Snooze';

  @override
  String get settingsSnoozeOff => 'Take a break without losing matches';

  @override
  String get settingsSnoozeOn => 'You’re hidden. Resume any time.';

  @override
  String get settingsSnoozeNote =>
      'Snooze hides your profile and pauses Home. Matches and chats stay.';

  @override
  String get snoozedToast => 'Snoozed. Home is paused.';

  @override
  String get resumedToast => 'Welcome back. Home is on.';

  @override
  String get settingsPrivacy => 'Privacy and safety';

  @override
  String get settingsBlocked => 'Blocked people';

  @override
  String get blockedEmptyTitle => 'No one is blocked';

  @override
  String get blockedEmptyBody => 'People you block or report show here.';

  @override
  String get unblock => 'Unblock';

  @override
  String unblockName(Object name) {
    return 'Unblock $name';
  }

  @override
  String unblockedToast(Object name) {
    return '$name is unblocked';
  }

  @override
  String get settingsPrototype => 'Prototype tools';

  @override
  String get settingsSimulate => 'Simulate connection problems';

  @override
  String get settingsSimulateOn => 'On: loading Home and sending messages fail';

  @override
  String get settingsSimulateOff => 'Off';

  @override
  String get settingsPrototypeNote =>
      'For trying failure states in this demo build. Real Numaya has no such switch.';

  @override
  String get photoMakeMain => 'Make main photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoKeepTwo => 'Keep at least 2 photos';

  @override
  String photoOptionsLabel(int position) {
    return 'Photo $position options';
  }

  @override
  String get photoMadeMain => 'Main photo updated';

  @override
  String tabNewCount(Object label, int count) {
    return '$label, $count new';
  }

  @override
  String get noConvTitle => 'No conversations yet';

  @override
  String get noConvBody => 'Say hello to a new match to start one.';

  @override
  String get timeToday => 'Today';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String hoursLeft(int hours) {
    return '${hours}h left';
  }

  @override
  String minutesLeft(int minutes) {
    return '${minutes}m left';
  }

  @override
  String get queueLikes => 'Likes';

  @override
  String queueLikesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people like you. Open Likes',
      one: '1 person likes you. Open Likes',
    );
    return '$_temp0';
  }

  @override
  String get queueExpired => 'Expired';

  @override
  String queueExpiredLabel(Object name) {
    return '$name. Match expired';
  }

  @override
  String get movesPromoTitle => 'Skip the small talk';

  @override
  String get movesPromoBody =>
      'Add up to three Opening Moves: questions your new matches can answer to start the conversation.';

  @override
  String get movesPromoAction => 'Set Opening Moves';

  @override
  String get yourMoveTag => 'Your move';

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get optionViewProfile => 'View profile';

  @override
  String get optionDidYouMeet => 'Did you meet?';

  @override
  String get chatExtended => 'Extended: you have 24 more hours';

  @override
  String chatExpiredTitle(Object name) {
    return 'Your match with $name expired';
  }

  @override
  String get chatExpiredBody =>
      'Neither of you wrote within 24 hours, so the match ended. Rematch to get another 24 hours.';

  @override
  String get chatRematch => 'Rematch';

  @override
  String get chatRematchPremium => 'Rematch with Premium';

  @override
  String chatExpiresIn(Object time) {
    return '$time to start the conversation';
  }

  @override
  String get chatExtendFreeNote =>
      'Need more time? You get one free Extend a day.';

  @override
  String get chatExtendPremiumNote => 'Premium: extend as often as you like.';

  @override
  String get chatExtend => 'Extend 24 hours';

  @override
  String chatTheirMove(Object name) {
    return '$name’s Opening Move';
  }

  @override
  String get chatReplyToMove => 'Reply';

  @override
  String get chatSampleBadge => 'Sample conversation';

  @override
  String chatTheirMessageLabel(Object name, Object text) {
    return '$name: $text';
  }

  @override
  String chatSampleConversationNote(Object name) {
    return '$name’s messages were written for the demo. What you send stays on this device and no one replies.';
  }

  @override
  String get reportWhere => 'Where did you see it?';

  @override
  String didMeetTitle(Object name) {
    return 'Did you meet $name?';
  }

  @override
  String didMeetBody(Object name) {
    return 'Your answer stays on this device and helps you keep track. $name won’t see it.';
  }

  @override
  String get didMeetYes => 'Yes, we met';

  @override
  String get didMeetNo => 'No, we didn’t meet';

  @override
  String get didMeetThanks => 'Thanks. Saved on this device.';

  @override
  String unmatchedReasonTitle(Object name) {
    return 'You’ve unmatched $name';
  }

  @override
  String unmatchedReasonBody(Object name) {
    return 'Could you tell us why? Your answer stays on this device and $name won’t know.';
  }

  @override
  String get unmatchReasonSkip => 'Skip';

  @override
  String get unmatchReasonThanks =>
      'Thanks. Your answer is saved on this device.';

  @override
  String get filtersDone => 'Done';

  @override
  String get filtersWomen => 'Women';

  @override
  String get filtersMen => 'Men';

  @override
  String get filtersNonbinary => 'Nonbinary people';

  @override
  String get filtersWhoHeading => 'Who do you want to date?';

  @override
  String get filtersEveryone =>
      'Showing everyone. Pick one or more to narrow it down.';

  @override
  String get filtersWhoHint => 'Only the people you picked appear on Home.';

  @override
  String get filtersAgeFallback =>
      'See people 2 years either side if I run out';

  @override
  String get filtersDistanceFallback =>
      'See people slightly further away if I run out';

  @override
  String get filtersVerifiedHeading => 'Have they verified themselves?';

  @override
  String get filtersVerifiedOnly => 'Verified profiles only';

  @override
  String get filtersVerifiedNote =>
      'Only people who have verified their photos.';

  @override
  String get filtersWhatsThis => 'What’s photo verification?';

  @override
  String get filtersAdvancedLocked => 'Advanced filters are part of Premium';

  @override
  String get filtersAdvancedLockedBody =>
      'Narrow down by height, intentions and more. In this demo Premium is simulated: no payment is taken.';

  @override
  String get premiumSee => 'See Premium';

  @override
  String get filtersHeightHeading => 'What is their height?';

  @override
  String get filtersHeight => 'Height';

  @override
  String get filtersAny => 'Any';

  @override
  String filtersTallerThan(int cm) {
    return 'Taller than $cm cm';
  }

  @override
  String get filtersIntentionsHeading => 'What do they want from their dates?';

  @override
  String get filtersMoreHeading => 'More filters';

  @override
  String get filtersAddFilter => 'Add';

  @override
  String get filtersAdvancedFallback => 'Show other people if I run out';

  @override
  String get filtersBasic => 'Basic';

  @override
  String get filtersAdvanced => 'Advanced';

  @override
  String get filtersUsingFallback =>
      'Nobody fits exactly, so people just outside your filters will show.';

  @override
  String discoverSuperSentLeft(int count, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'SuperSwipe sent to $name. $count left',
      one: 'SuperSwipe sent to $name. 1 left',
    );
    return '$_temp0';
  }

  @override
  String get forYouOpen => 'For you: today’s picks';

  @override
  String get discoverFallbackTitle =>
      'Showing people just outside your filters';

  @override
  String get discoverFallbackBody =>
      'Nobody fit exactly, so your “if I run out” settings are on.';

  @override
  String get forYouTitle => 'For you';

  @override
  String forYouRefresh(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'New picks in $hours hours',
      one: 'New picks in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String get forYouLede =>
      'People you have the most in common with, picked once a day.';

  @override
  String get forYouEmptyTitle => 'You’ve seen today’s picks';

  @override
  String forYouEmptyBody(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'New people arrive in $hours hours.',
      one: 'New people arrive in 1 hour.',
    );
    return '$_temp0';
  }

  @override
  String get forYouBackHome => 'Back to Home';

  @override
  String forYouOpenProfile(Object name) {
    return 'Open $name’s profile';
  }

  @override
  String forYouInCommon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things in common',
      one: '1 thing in common',
      zero: 'Picked for you',
    );
    return '$_temp0';
  }

  @override
  String forYouLike(Object name) {
    return 'Like $name';
  }

  @override
  String get forYouRationale =>
      'Based on your interests and who you’ve liked. Sample profiles.';

  @override
  String get likeAction => 'Like';

  @override
  String get personMissingTitle => 'This profile isn’t available';

  @override
  String get personMissingBody =>
      'It may have been removed. Go back to keep exploring.';

  @override
  String heightValue(int cm) {
    return '$cm cm';
  }

  @override
  String get appealHint => 'Tell us what happened. Be as specific as you can.';

  @override
  String get appealLabel => 'Your appeal';

  @override
  String get appealPlaceholder => 'I think this was a mistake because…';

  @override
  String get appealSend => 'Send appeal';

  @override
  String get appealSentTitle => 'Appeal saved';

  @override
  String get appealSentBody =>
      'In this demo nothing is sent or reviewed. In the real app a person reviews appeals and replies by email.';

  @override
  String get blockedAccountTitle => 'Account on hold';

  @override
  String get blockedAccountHeading => 'Your account has been blocked';

  @override
  String get blockedAccountBody =>
      'We found activity that goes against our guidelines. You can appeal within 6 months. This is a preview of a screen the server would show.';

  @override
  String get completionTitle => 'Complete your profile';

  @override
  String completionPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get completionLede =>
      'Profiles with more to talk about get more matches. Pick up where you like.';

  @override
  String get completionDone => 'Your profile is complete. Nice work.';

  @override
  String get completionPhotos => 'Photos';

  @override
  String get completionPrompts => 'Prompts';

  @override
  String get completionInterests => 'Interests';

  @override
  String get completionBio => 'Bio';

  @override
  String get completionAbout => 'About you';

  @override
  String get completionMore => 'More about you';

  @override
  String completionProgress(int done, int total) {
    return '$done of $total added';
  }

  @override
  String get contactTopic => 'What’s it about?';

  @override
  String get contactTopicAccount => 'My account';

  @override
  String get contactTopicSafety => 'Safety or someone’s behaviour';

  @override
  String get contactTopicVerification => 'Photo verification';

  @override
  String get contactTopicBilling => 'Premium and billing';

  @override
  String get contactTopicOther => 'Something else';

  @override
  String get contactMessage => 'Your message';

  @override
  String get contactSend => 'Send message';

  @override
  String get contactDemoNote =>
      'Demo build: your message stays on this device and nobody reads it.';

  @override
  String get contactSentTitle => 'Message saved';

  @override
  String get contactSentBody =>
      'In this demo nothing is sent. In the real app, support replies within a day.';

  @override
  String get deleteHeading => 'Delete your account?';

  @override
  String get deleteLede => 'Before you go, tell us why. It helps us improve.';

  @override
  String get deleteWhy => 'Why are you leaving?';

  @override
  String get deleteSnoozeTitle => 'Just need a break?';

  @override
  String get deleteSnoozeBody =>
      'Snooze hides your profile and keeps your matches and chats.';

  @override
  String get deleteSnoozeAction => 'Snooze instead';

  @override
  String get deleteC1 => 'Your profile is hidden from everyone straight away';

  @override
  String get deleteC2 => 'Your matches and messages are removed';

  @override
  String get deleteC3 =>
      'You can restore everything for 28 days by signing in again';

  @override
  String get deleteSubscriptionTitle => 'Your Premium plan won’t be cancelled';

  @override
  String get deleteSubscriptionBody =>
      'Cancel it in your app store first. In this demo there is no real subscription.';

  @override
  String get deleteContinue => 'Continue';

  @override
  String get deleteHelp => 'What happens when I delete?';

  @override
  String get deleteRestoreNote =>
      'Changed your mind? Sign in with the same number within 28 days to restore it.';

  @override
  String get demoHubTitle => 'Demo hub';

  @override
  String get demoHubBanner => 'Development build only';

  @override
  String get demoHubBody =>
      'Jump to any screen, switch the sample data and try each state. Everything here is local and simulated.';

  @override
  String get demoStart => 'Start';

  @override
  String get demoQuickStart => 'Quick start as Alex (sample account)';

  @override
  String get demoQuickStartNote =>
      'Skips sign-up with a finished sample profile and a fictional 555 number.';

  @override
  String get demoSignedIn =>
      'You’re signed in. Quick start replaces this session with the sample account.';

  @override
  String get demoWorld => 'Sample world';

  @override
  String get demoWorldFull => 'Full demo';

  @override
  String get demoWorldFullBody =>
      '12 profiles, 7 likes, matches in the queue (one expiring soon, one expired) and 3 sample conversations';

  @override
  String get demoWorldFresh => 'Brand-new account';

  @override
  String get demoWorldFreshBody =>
      '7 profiles, 5 likes, no matches or conversations';

  @override
  String get demoReset => 'Reset demo data';

  @override
  String get demoResetDone => 'Demo data reset';

  @override
  String get demoSwitches => 'Switches';

  @override
  String get demoPremium => 'Premium (simulated)';

  @override
  String get demoPremiumNote => 'Unlocks Premium features without the paywall';

  @override
  String get demoApproveVerification => 'Approve the next verification';

  @override
  String get demoApproveOn => 'The next selfie is approved';

  @override
  String get demoApproveOff => 'The next selfie is declined';

  @override
  String get demoResetVerification => 'Reset photo verification';

  @override
  String get demoAreaAccount => 'Account and onboarding';

  @override
  String get demoAreaDiscover => 'Discover';

  @override
  String get demoAreaMatching => 'Likes, matches and messages';

  @override
  String get demoAreaProfile => 'Profile';

  @override
  String get demoAreaSettings => 'Settings, safety and help';

  @override
  String get demoWelcome => 'Welcome';

  @override
  String get demoRestoreHow =>
      'Account restore: delete the account in Settings, then sign in again with the same number.';

  @override
  String get demoSampleProfile => 'A sample profile with Like and Pass';

  @override
  String get demoLikeProfile => 'A like’s profile (Maya)';

  @override
  String get demoMatchScreen => 'Match celebration (Maya)';

  @override
  String get demoChatHistory => 'Conversation with history (Priya)';

  @override
  String get demoChatNew => 'New match, 21 hours left (Jo)';

  @override
  String get demoChatExpiring => 'Match about to expire (Lina)';

  @override
  String get demoChatExpired => 'Expired match (Ollie)';

  @override
  String get demoFullOnly =>
      'The named matches and conversations exist in the full demo.';

  @override
  String get demoNeedsSession => 'Sign in or use Quick start first';

  @override
  String get demoNotFound => 'A link that doesn’t exist';

  @override
  String get editAdd => 'Add';

  @override
  String get editAddPrompt => 'Add a prompt';

  @override
  String get editPromptsSection => 'Prompts';

  @override
  String editPromptsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of 3 added. Prompts give people something to reply to.',
      one: '1 of 3 added. Prompts give people something to reply to.',
    );
    return '$_temp0';
  }

  @override
  String get editBio => 'Bio';

  @override
  String get editBioHint => 'A short, punchy intro.';

  @override
  String get editBioAdd => 'Write a short intro';

  @override
  String get editBioPlaceholder =>
      'Weekend baker, weekday spreadsheet wrangler…';

  @override
  String get editBioTipTitle => 'Show your personality';

  @override
  String get editBioTip =>
      'Share a quirk, an interest or a bit of humour to help you stand out.';

  @override
  String get editClear => 'Remove';

  @override
  String get editGender => 'Gender';

  @override
  String get editGenderMore => 'Add more about your gender';

  @override
  String get editGenderLegend => 'Which describes you best?';

  @override
  String get editGenderShow => 'Show my gender on my profile';

  @override
  String get editGenderShowNote => 'You can change this any time.';

  @override
  String get editHeight => 'Height';

  @override
  String get editLanguages => 'Languages';

  @override
  String editLanguagesHint(int count, int total) {
    return '$count of $total chosen';
  }

  @override
  String get editMoreAbout => 'More about you';

  @override
  String get editMoreAboutNote =>
      'Answer only what you’re comfortable sharing. Some answers help with filters.';

  @override
  String get editMoreSection => 'More';

  @override
  String get editPreferNotToSay => 'Prefer not to say';

  @override
  String get editPreview => 'Preview profile';

  @override
  String get editVerify => 'Verify my profile';

  @override
  String get featureLikes => 'Like as many people as you want';

  @override
  String get featureSeeLikes => 'See who liked you';

  @override
  String get featureExtend => 'Unlimited Extends';

  @override
  String get featureRematch => 'Rematch with expired matches';

  @override
  String get featureAdvancedFilters => 'Advanced filters';

  @override
  String get featureIncognito => 'Incognito';

  @override
  String get featureTravel => 'Travel mode';

  @override
  String get featureSuperSwipes => '5 extra SuperSwipes';

  @override
  String get helpTitle => 'Help centre';

  @override
  String get helpSearch => 'Search help';

  @override
  String get helpTopics => 'Topics';

  @override
  String get helpNoResults => 'Try another word, or contact us.';

  @override
  String get helpStillStuck => 'Still stuck?';

  @override
  String get helpContact => 'Contact support';

  @override
  String get helpMissing => 'That article doesn’t exist any more.';

  @override
  String get incognito => 'Incognito';

  @override
  String get incognitoOn => 'Only people you like can see you';

  @override
  String get incognitoOff => 'Off';

  @override
  String get incognitoNote =>
      'With Incognito, only people you’ve liked can see your profile.';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutBody =>
      'In this demo, logging out clears your profile and sample data from this device.';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get notFoundTitle => 'This page isn’t here';

  @override
  String get notFoundBody =>
      'The link may be old or mistyped. Nothing was lost.';

  @override
  String get notFoundStart => 'Back to the start';

  @override
  String get notificationsMore => 'More notification settings';

  @override
  String get notifMatches => 'New matches';

  @override
  String get notifExpiring => 'Matches about to expire';

  @override
  String get notifTips => 'Tips and news';

  @override
  String get notifPush => 'Push';

  @override
  String get notifInApp => 'In-app';

  @override
  String get notifEmail => 'Email';

  @override
  String get notifNoEmail => 'No email address on file';

  @override
  String get notifWarning =>
      'Turning these off might mean you miss alerts from your matches.';

  @override
  String get notifEmailNote =>
      'Push isn’t connected in this build, so these are saved as preferences only.';

  @override
  String get openingMovesTitle => 'Opening Moves';

  @override
  String get openingMovesHeading => 'Your Opening Moves';

  @override
  String get openingMovesLede =>
      'Skip the “hey”. Choose up to three questions your new matches can answer.';

  @override
  String openingMovesCount(int count) {
    return '$count of 3';
  }

  @override
  String get openingMovesNote =>
      'Your matches see one Opening Move when you match. They can answer it or start their own way.';

  @override
  String get openingMoveFirst => 'First Opening Move';

  @override
  String get openingMoveSecond => 'Second Opening Move';

  @override
  String get openingMoveThird => 'Third Opening Move';

  @override
  String get openingMoveEditTitle => 'Write your Opening Move';

  @override
  String get openingMoveLabel => 'Your question';

  @override
  String get openingMoveSuggestions => 'Need an idea?';

  @override
  String get openingMoveRemove => 'Remove Opening Move';

  @override
  String get openingMoveRemoved => 'Opening Move removed';

  @override
  String get paywallTitle => 'Get more with Premium';

  @override
  String get paywallForFilters => 'Advanced filters come with Premium';

  @override
  String get paywallForRematch => 'Rematch comes with Premium';

  @override
  String get paywallForExtend => 'Unlimited Extends come with Premium';

  @override
  String get paywallForIncognito => 'Incognito comes with Premium';

  @override
  String get paywallForTravel => 'Travel mode comes with Premium';

  @override
  String get paywallForSuperSwipes => 'You’re out of SuperSwipes';

  @override
  String get paywallLede =>
      'Premium in this demo is simulated: no store is connected and no payment is taken.';

  @override
  String get paywallPlans => 'Choose a plan';

  @override
  String get paywallChoose => 'Choose a plan to continue';

  @override
  String paywallContinue(Object plan, Object price) {
    return 'Continue with $plan · $price';
  }

  @override
  String get paywallLegal =>
      'Demo only. In a real build, plans renew automatically until cancelled in your app store. Prices are illustrative.';

  @override
  String get paywallConfirmTitle => 'Simulated purchase';

  @override
  String paywallConfirmBody(Object plan, Object price) {
    return '$plan for $price. This is a demo: nothing is charged and no store is contacted.';
  }

  @override
  String get paywallConfirmBuy => 'Complete demo purchase';

  @override
  String get paywallConfirmFail => 'Simulate a failed payment';

  @override
  String get paywallFailedTitle => 'The payment didn’t go through';

  @override
  String get paywallFailedBody =>
      'Simulated failure. Nothing was charged and your plan is still selected. Try again when you’re ready.';

  @override
  String get paywallSuccessTitle => 'You’re all set';

  @override
  String get paywallAlreadyTitle => 'Premium is active';

  @override
  String paywallSuccessBody(Object date) {
    return 'Premium is active until $date. Demo only: no payment was taken.';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallRestoreNone =>
      'No store is connected in this demo, so there’s nothing to restore.';

  @override
  String get premiumName => 'Numaya Premium';

  @override
  String get premiumActive => 'Active';

  @override
  String premiumActiveUntil(Object date) {
    return 'Active until $date';
  }

  @override
  String premiumActivePlan(Object plan) {
    return '$plan plan, simulated. Cancel any time below.';
  }

  @override
  String get premiumCardBody =>
      'Advanced filters, Rematch, unlimited Extends, Incognito and Travel.';

  @override
  String get premiumExplore => 'Explore Premium';

  @override
  String get premiumManage => 'Manage';

  @override
  String get premiumHeroTitle => 'More ways to meet the right people';

  @override
  String get premiumHeroBody =>
      'Everything in Numaya stays free. Premium adds control and extra time.';

  @override
  String get premiumYourExtras => 'Your extras';

  @override
  String get premiumSuperSwipesLeft => 'SuperSwipes left';

  @override
  String get premiumCompare => 'What you get';

  @override
  String get premiumFree => 'Free';

  @override
  String get premiumShort => 'Premium';

  @override
  String get premiumSeePlans => 'See plans';

  @override
  String get premiumCancelDemo => 'Cancel demo plan';

  @override
  String get premiumCancelled => 'Demo plan cancelled';

  @override
  String get premiumDemoNote =>
      'Demo build: prices and plans are illustrative and nothing is charged.';

  @override
  String get premiumHelp => 'Billing and cancelling';

  @override
  String get premiumOnly => 'Premium';

  @override
  String get previewTitle => 'Preview';

  @override
  String get previewBadge => 'Preview';

  @override
  String get previewInfoTitle => 'This is how others see you';

  @override
  String get previewInfoBody =>
      'Only what you’ve added is shown. Hidden fields stay hidden.';

  @override
  String get previewEdit => 'Back to editing';

  @override
  String get privacyTitle => 'Profile visibility';

  @override
  String get privacyShowTitle => 'On your profile';

  @override
  String get privacyShowAge => 'Show my age';

  @override
  String get privacyShowDistance => 'Show my distance';

  @override
  String get privacyShowNote =>
      'Your age is still used for matching, even when it’s hidden.';

  @override
  String get privacyWhoSees => 'Who can see you';

  @override
  String get profileComplete => 'Complete profile';

  @override
  String profileCompletionLabel(int percent) {
    return 'Profile $percent% complete';
  }

  @override
  String get profileInterestsTitle => 'Interests';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileSafetySupport => 'Safety and support';

  @override
  String get promptRemove => 'Remove prompt';

  @override
  String get promptRemoved => 'Prompt removed';

  @override
  String get restoreTitle => 'Welcome back';

  @override
  String restoreBody(Object date) {
    return 'Your account was deleted recently. You can restore it, with your profile, until $date.';
  }

  @override
  String get restoreAction => 'Restore my account';

  @override
  String get restoreStartOver => 'Start a new profile instead';

  @override
  String get restoreDone => 'Your account is back';

  @override
  String get safetyTitle => 'Safety and wellbeing';

  @override
  String get safetyHeading => 'Date with confidence';

  @override
  String get safetyLede =>
      'Tips for meeting people, and the tools that keep you in control.';

  @override
  String get safetyTip1Title => 'Keep it on Numaya at first';

  @override
  String get safetyTip1Body =>
      'Chat here until you feel comfortable. Never send money or share financial details.';

  @override
  String get safetyTip2Title => 'Meet in public';

  @override
  String get safetyTip2Body =>
      'Tell a friend your plans and arrange your own way there and back.';

  @override
  String get safetyTip3Title => 'Report anything that feels off';

  @override
  String get safetyTip3Body =>
      'Reports are anonymous. Blocking someone means you won’t see each other again.';

  @override
  String get safetyTools => 'Your tools';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationNote =>
      'Location isn’t read in this build; the sample area stands in for it.';

  @override
  String get settingsCurrentLocation => 'Current location';

  @override
  String get settingsSampleLocation => 'Hackney, London (sample)';

  @override
  String get settingsHelpLegal => 'Help and legal';

  @override
  String get snoozeTitle => 'Snooze';

  @override
  String get snoozeBody =>
      'Hide your profile from new people for a while. You keep your matches and chats.';

  @override
  String get snoozeHowLong => 'How long?';

  @override
  String get snooze24h => '24 hours';

  @override
  String get snooze72h => '72 hours';

  @override
  String get snoozeWeek => 'A week';

  @override
  String get snoozeIndefinite => 'Until I turn it off';

  @override
  String get snoozeNoStatus => 'No thanks';

  @override
  String snoozeUntil(Object date) {
    return 'Until $date';
  }

  @override
  String get travelTitle => 'Travel';

  @override
  String get travelBody =>
      'Planning a trip? Meet people there before you go. Demo: changes the sample location only.';

  @override
  String get travelPick => 'Where are you going?';

  @override
  String get travelOff => 'Turn off Travel';

  @override
  String get travelOffValue => 'Off';

  @override
  String get travelOnValue => 'On';

  @override
  String travelSet(Object city) {
    return 'Travel set to $city';
  }

  @override
  String get travelEnded => 'Travel turned off';

  @override
  String get verifyIntroTitle => 'Show them it’s really you';

  @override
  String get verifyIntroBody =>
      'Copy a pose and take a selfie. When it matches your photos, a badge goes on your profile.';

  @override
  String get verifyDemoTitle => 'Simulated in this demo';

  @override
  String get verifyDemoBody =>
      'The camera isn’t used and nobody reviews the photo. The result appears after a few seconds.';

  @override
  String get verifyStart => 'Let’s get verified';

  @override
  String get verifyHelp => 'How does verification work?';

  @override
  String get verifyCopyPose => 'Copy this pose';

  @override
  String verifyViewfinderLabel(Object pose) {
    return 'Camera preview. Pose to copy: $pose';
  }

  @override
  String get verifyCameraOff =>
      'The camera isn’t connected in this demo. Take a demo selfie to continue.';

  @override
  String get verifyTakeSelfie => 'Take demo selfie';

  @override
  String get verifyOtherPose => 'Show me a different pose';

  @override
  String get verifyReviewTitle => 'Happy with it?';

  @override
  String get verifyReviewBody =>
      'Your selfie is compared with your profile photos. It isn’t shown on your profile.';

  @override
  String get verifyDemoSelfie => 'Demo selfie (placeholder)';

  @override
  String get verifyRetake => 'Retake';

  @override
  String get verifyPendingTitle => 'Checking your selfie';

  @override
  String get verifyPendingBody =>
      'Usually a few minutes. In this demo the review is simulated and takes a few seconds.';

  @override
  String get verifyDoneTitle => 'You’re verified';

  @override
  String get verifyDoneBody =>
      'The badge is on your profile. People who filter for verified profiles can now see you.';

  @override
  String get verifyRejectedTitle => 'We couldn’t verify you';

  @override
  String verifyRejectedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The pose didn’t match. You have $count more tries.',
      one: 'The pose didn’t match. You have 1 more try.',
    );
    return '$_temp0';
  }

  @override
  String get verifyRejectedSupport =>
      'After three tries, a person can help. Contact support and we’ll sort it out.';

  @override
  String get verifyTipsTitle => 'Tips';

  @override
  String get verifyTip1 => 'Find good, even light';

  @override
  String get verifyTip2 => 'Keep your face and hand in the frame';

  @override
  String get verifyTip3 => 'Copy the pose exactly';

  @override
  String get verifyTryAgain => 'Try again';

  @override
  String get verifyStatusNone => 'Not verified';

  @override
  String get verifyStatusPending => 'In review';

  @override
  String get verifyStatusRejected => 'Try again';

  @override
  String get verifyStatusVerified => 'Verified';

  @override
  String get photoVerifyTitle => 'Photo verification';

  @override
  String get photoVerifySubmit => 'Submit for review';

  @override
  String get demoHubOpen => 'Demo build. Open the demo hub';

  @override
  String matchTheirMove(Object move, Object name) {
    return '$name’s Opening Move: “$move”';
  }

  @override
  String get photoMoveEarlier => 'Move earlier';

  @override
  String get photoMoveLater => 'Move later';

  @override
  String get photoReplace => 'Replace with a new placeholder';

  @override
  String get photoMoved => 'Photo order updated';

  @override
  String get photoReplaced =>
      'Photo replaced (placeholder: upload isn’t connected)';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationNote =>
      'A short tap when you choose an option, like, match or send. Your phone’s own vibration setting still applies.';

  @override
  String get demoReduceMotion => 'Reduce motion';

  @override
  String get demoReduceMotionNote =>
      'Acts as if the phone’s Remove animations setting were on';

  @override
  String get setupSectionAboutLabel => 'About you';

  @override
  String get setupSectionAboutDetail => 'Your name, birthday and gender';

  @override
  String get setupSectionLookingLabel => 'Who you’re looking for';

  @override
  String get setupSectionLookingDetail =>
      'Who you want to meet, what for and where';

  @override
  String get setupSectionProfileLabel => 'Your profile';

  @override
  String get setupSectionProfileDetail =>
      'Photos, interests, prompts and a bio';

  @override
  String get setupSectionFinishLabel => 'Finish';

  @override
  String get setupSectionFinishDetail =>
      'Verification, notifications and a last look';

  @override
  String get obSkip => 'Skip';

  @override
  String get obContinue => 'Continue';

  @override
  String get obNameTitle => 'Let’s start with an intro';

  @override
  String get obNameLede =>
      'Your first name and age appear on your profile. Your birthday doesn’t.';

  @override
  String get obNameEmpty => 'Enter your first name.';

  @override
  String get obNameCharacters => 'Use letters only, without numbers or emoji.';

  @override
  String get obBirthdayLegend => 'Birthday';

  @override
  String get obDay => 'Day';

  @override
  String get obMonth => 'Month';

  @override
  String get obYear => 'Year';

  @override
  String get obBirthdayInvalid =>
      'That date doesn’t exist. Check the day and month.';

  @override
  String get obBirthdayFuture => 'That date is in the future.';

  @override
  String get obBirthdayUnrealistic =>
      'Check the year: that’s more than 100 years ago.';

  @override
  String get obBirthdayUnderage => 'You need to be 18 or over to use Numaya.';

  @override
  String obAgeHint(int age) {
    return 'You’re $age';
  }

  @override
  String get obNameFooter => 'Only your age is shown';

  @override
  String get obNameFooterMissing => 'Add your name and birthday';

  @override
  String obConfirmAgeTitle(int age) {
    return 'You’re $age';
  }

  @override
  String obConfirmAgeBorn(String date) {
    return 'Born $date';
  }

  @override
  String get obConfirmAgeBody =>
      'Make sure this is right. You can’t change your birthday later.';

  @override
  String get obConfirmEdit => 'Edit';

  @override
  String get obConfirm => 'Confirm';

  @override
  String get obUnderageTitle => 'Numaya is for adults';

  @override
  String get obUnderageBody =>
      'You need to be 18 or over to use Numaya, so we can’t create a profile for you. Nothing you entered has been saved to a profile.';

  @override
  String get obUnderageSignOut => 'Sign out';

  @override
  String get obUnderageHelp => 'Read about our age rules';

  @override
  String get obGenderTitle => 'How do you identify?';

  @override
  String get obGenderLede =>
      'Add more detail if you like, and choose what your profile shows.';

  @override
  String get obGenderMore => 'Add more about your gender';

  @override
  String get obPronounsLabel => 'Pronouns · optional';

  @override
  String obPronounsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get obShowGender => 'Show gender on profile';

  @override
  String get obShowPronouns => 'Show pronouns on profile';

  @override
  String get obGenderFooter => 'Pronouns are optional';

  @override
  String get obGenderFooterMissing => 'Choose one to continue';

  @override
  String get obMeetTitle => 'Who do you want to meet?';

  @override
  String get obMeetLede =>
      'Pick all that apply. This is private: it’s never shown on your profile.';

  @override
  String get obEveryone => 'Everyone';

  @override
  String get obAgesLabel => 'Their age';

  @override
  String get obMeetFooter => 'Hidden on your profile';

  @override
  String get obMeetFooterMissing => 'Pick at least one';

  @override
  String get obIntentTitle => 'What are you hoping to find?';

  @override
  String get obIntentLede => 'Pick one or two. This shows on your profile.';

  @override
  String obIntentFooter(int count) {
    return '$count of 2 picked';
  }

  @override
  String get obIntentFooterMissing => 'Pick at least one';

  @override
  String get obHeightTitle => 'How tall are you?';

  @override
  String get obHeightLede =>
      'Optional. If you add it, it shows on your profile.';

  @override
  String get obHeightCm => 'cm';

  @override
  String get obHeightFtIn => 'ft / in';

  @override
  String obHeightFeet(int feet, int inches) {
    return '$feet′ $inches″';
  }

  @override
  String get obHeightShorter => 'Shorter';

  @override
  String get obHeightTaller => 'Taller';

  @override
  String get obHeightUnitLegend => 'Units';

  @override
  String get obHeightAdd => 'Add my height';

  @override
  String get obHeightFooter => 'Shown on your profile';

  @override
  String get obHeightFooterNone => 'You can skip this';

  @override
  String get obHeightRemove => 'Remove height';

  @override
  String get obLocationTitle => 'Where do you want to meet people?';

  @override
  String get obLocationLede =>
      'Numaya uses your area to show you people nearby. Only the area appears on your profile, never your exact location.';

  @override
  String get obLocationUse => 'Use my location';

  @override
  String get obLocationChoose => 'Choose my area instead';

  @override
  String get obLocationDemo =>
      'The phone’s location is never read in this build. Allowing sets a sample area.';

  @override
  String obLocationSetDevice(String area) {
    return '$area (sample area)';
  }

  @override
  String get obLocationAreaLabel => 'Your area';

  @override
  String get obLocationChange => 'Change area';

  @override
  String get obLocationDeniedTitle => 'Location is off';

  @override
  String get obLocationDeniedBody =>
      'That’s fine. Choose your area instead, or try again.';

  @override
  String get obLocationTryAgain => 'Try again';

  @override
  String get obLocationBlockedTitle => 'Location is blocked for Numaya';

  @override
  String get obLocationBlockedBody =>
      'Android won’t ask again. Turn location on in Settings, or choose your area.';

  @override
  String get obOpenSettings => 'Open settings';

  @override
  String get obOpenSettingsDemo =>
      'Demo build: this would open Numaya’s Android settings.';

  @override
  String get obLocationFooter => 'Only your area is shown';

  @override
  String get obLocationFooterNone => 'You can set this later';

  @override
  String get obAreaSheetTitle => 'Choose your area';

  @override
  String get obAreaSearch => 'Search areas';

  @override
  String obAreaNone(String query) {
    return 'No areas match “$query”';
  }

  @override
  String get permDemoTag => 'Demo · stands in for Android’s prompt';

  @override
  String get permLocationTitle =>
      'Allow Numaya to access this device’s location?';

  @override
  String get permAllowApproximate => 'While using the app · approximate';

  @override
  String get permAllowPrecise => 'While using the app · precise';

  @override
  String get permCameraTitle =>
      'Allow Numaya to take pictures and record video?';

  @override
  String get permNotificationsTitle =>
      'Allow Numaya to send you notifications?';

  @override
  String get permAllow => 'Allow';

  @override
  String get permDeny => 'Don’t allow';

  @override
  String get photoSourceTitle => 'Add a photo';

  @override
  String get photoSourceCamera => 'Take a photo';

  @override
  String get photoSourceLibrary => 'Choose from library';

  @override
  String get photoSourceNote =>
      'Demo build: no camera or photo picker is connected, so either choice adds a placeholder tile.';

  @override
  String get photoCameraDeniedTitle => 'Camera is off for Numaya';

  @override
  String get photoCameraDeniedBody =>
      'Choose from your library instead, or allow the camera next time.';

  @override
  String get photoCameraBlockedBody =>
      'Android won’t ask again. Turn the camera on in Settings, or use your library.';

  @override
  String get photoTipsLink => 'Photo tips';

  @override
  String get photoTipsTitle => 'Photo tips';

  @override
  String get photoTip1 =>
      'Make your main photo just you, with your face clearly visible.';

  @override
  String get photoTip2 => 'Use recent photos taken in good light.';

  @override
  String get photoTip3 => 'Show something you love doing.';

  @override
  String get photoTip4 =>
      'Skip heavy filters, sunglasses in every shot and group photos as your main one.';

  @override
  String get photoTipsNote =>
      'These are tips. Numaya doesn’t scan your photos.';

  @override
  String get interestsSearch => 'Search interests';

  @override
  String interestsNoResults(String query) {
    return 'No interests match “$query”';
  }

  @override
  String get interestsClearSearch => 'Clear search';

  @override
  String get obPromptsTitle => 'Pick prompts to share your story';

  @override
  String get obPromptsLede =>
      'Answer at least one, up to three. People can reply to any of them.';

  @override
  String obPromptSlot(int n) {
    return 'Prompt $n';
  }

  @override
  String get obPromptAdd => 'Add a prompt';

  @override
  String get obPromptRequired => 'Required';

  @override
  String get obPromptOptional => 'Optional';

  @override
  String obPromptsFooter(int count) {
    return '$count of 3 answered';
  }

  @override
  String get obPromptsFooterMissing => 'Answer one to continue';

  @override
  String get promptAlreadyUsed => 'Already answered';

  @override
  String get obBioTitle => 'Write a short bio';

  @override
  String get obBioLede => 'Optional. A few lines about you, in your own words.';

  @override
  String get obBioLabel => 'Bio';

  @override
  String get obBioPlaceholder => 'Weekday baker, weekend hill walker…';

  @override
  String get obBioTip =>
      'Something specific says more than a list of adjectives.';

  @override
  String get obBioPreview => 'How it reads on your profile';

  @override
  String get obBioFooter => 'Shown on your profile';

  @override
  String get obBioFooterNone => 'You can skip this';

  @override
  String get obBioClear => 'Clear';

  @override
  String get obVerifyTitle => 'Verify your photos?';

  @override
  String get obVerifyLede =>
      'A quick selfie shows people your photos are really you. Verified profiles get a badge.';

  @override
  String get obVerifyPrivacy =>
      'The selfie is only used to check your photos. It isn’t shown on your profile.';

  @override
  String get obVerifyDemo =>
      'Demo build: verification is simulated. No selfie is taken, sent or checked, and the result isn’t a real verification.';

  @override
  String get obVerifyNow => 'Verify now';

  @override
  String get obVerifyLater => 'Maybe later';

  @override
  String get obVerifyPending => 'In review (simulated)';

  @override
  String get obVerifyDone => 'Verified (simulated)';

  @override
  String get obVerifyFailed =>
      'Not approved (simulated). You can try again from your profile.';

  @override
  String obVerifyStatus(String status) {
    return 'Status: $status';
  }

  @override
  String get obNotifTitle => 'Don’t miss a match';

  @override
  String get obNotifLede =>
      'Get told about new matches, messages and matches about to expire.';

  @override
  String get obNotifAllow => 'Allow notifications';

  @override
  String get obNotifLater => 'Not now';

  @override
  String get obNotifDemo =>
      'Demo build: no notifications are sent. Your answer sets the switches in Settings.';

  @override
  String get obNotifAllowed => 'Notifications are on.';

  @override
  String get obNotifDenied =>
      'Notifications are off. You can turn them on in Settings.';

  @override
  String get obNotifBlocked =>
      'Android won’t ask again. Turn notifications on in Android’s settings.';

  @override
  String get obReviewTitle => 'Your profile';

  @override
  String get obReviewLede =>
      'This is how other people will see you. Check it, then create your profile.';

  @override
  String get obReviewMissingTitle => 'Before you can finish';

  @override
  String get obMissingName => 'Add your first name';

  @override
  String get obMissingBirthday => 'Add your birthday';

  @override
  String get obMissingGender => 'Choose your gender';

  @override
  String get obMissingOpenTo => 'Choose who you want to meet';

  @override
  String get obMissingIntentions => 'Choose what you’re hoping to find';

  @override
  String obMissingPhotos(int min) {
    return 'Add at least $min photos';
  }

  @override
  String obMissingInterests(int min, int max) {
    return 'Pick $min to $max interests';
  }

  @override
  String get obMissingPrompt => 'Answer a prompt';

  @override
  String get obReviewPrivateTitle => 'Only you see this';

  @override
  String get obReviewMeet => 'Wants to meet';

  @override
  String obReviewAges(int min, int max) {
    return 'Ages $min–$max';
  }

  @override
  String get obReviewArea => 'Area';

  @override
  String get obReviewNotSet => 'Not set';

  @override
  String get obReviewVerification => 'Photo verification';

  @override
  String get obReviewNotVerified => 'Not verified';

  @override
  String get obReviewNotifications => 'Notifications';

  @override
  String get obReviewOn => 'On';

  @override
  String get obReviewOff => 'Off';

  @override
  String get obReviewEdit => 'Edit';

  @override
  String obReviewEditItem(String item) {
    return 'Edit $item';
  }

  @override
  String get obReviewCreate => 'Create my profile';

  @override
  String get obReviewFailed =>
      'Couldn’t create your profile. Check your connection and try again.';

  @override
  String get obReviewSaved => 'Your profile is kept on this device only.';

  @override
  String get obReviewPublicTitle => 'On your profile';

  @override
  String obDoneTitle(String name) {
    return 'You’re all set, $name';
  }

  @override
  String get obDoneBody =>
      'Your profile is ready. Start with today’s people, or keep adding to your profile any time.';

  @override
  String get obDoneStart => 'Start discovering';

  @override
  String get obDoneSample => 'Everyone you’ll see is a sample profile.';

  @override
  String get editBirthday => 'Birthday';

  @override
  String get editBirthdayLocked =>
      'Your birthday can’t be changed after setup.';

  @override
  String get demoAreaOnboarding => 'Onboarding';

  @override
  String get demoPermissionsReset => 'Reset permission answers';

  @override
  String get demoPermissionsResetDone => 'Permission answers reset';

  @override
  String get demoOnboardingStart => 'Start a new sign-up (skips the code)';

  @override
  String get demoOnboardingNote =>
      'Opens profile setup for a new demo account. Each step can also be opened directly once an account exists.';

  @override
  String get demoNeedsAccount => 'Start a sign-up first';

  @override
  String get obMeetLegend => 'Show me';

  @override
  String get obNotifFooter => 'You can change this in Settings';

  @override
  String get obVerifyFooter => 'Optional · you can verify later';

  @override
  String get obDemoBuild => 'Demo build';

  @override
  String discoverUndone(Object name) {
    return '$name is back';
  }

  @override
  String get discoverCoach =>
      'Swipe right to like, left to pass. Scroll for more about them.';

  @override
  String get discoverCoachDismiss => 'Hide tip';

  @override
  String discoverMoreAbout(Object name) {
    return 'Show more about $name';
  }

  @override
  String discoverPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String discoverOpenPhotos(Object name) {
    return 'See $name’s photos';
  }

  @override
  String discoverReportBlock(Object name) {
    return 'Report or block $name';
  }

  @override
  String get discoverSeenAllLikedBody =>
      'You liked everyone you saw. New people don’t arrive in this demo, so check who likes you instead.';

  @override
  String get discoverSeeLikes => 'See who likes you';

  @override
  String get discoverErrorStillTitle => 'Still can’t load profiles';

  @override
  String get discoverFiltersChanged => 'Filters, changed from your preferences';

  @override
  String photoViewerTitle(Object name) {
    return '$name’s photos';
  }

  @override
  String photoViewerPosition(int position, int count) {
    return 'Photo $position of $count';
  }

  @override
  String get photoViewerNext => 'Next photo';

  @override
  String get photoViewerPrevious => 'Previous photo';

  @override
  String get photoViewerNote =>
      'Placeholders. Sample profiles have no real photos.';
}
