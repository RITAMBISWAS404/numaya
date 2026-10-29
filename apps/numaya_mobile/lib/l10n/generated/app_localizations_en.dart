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
  String get chatAttach => 'Add a photo, video or voice note';

  @override
  String get chatAttachPhoto => 'Photo';

  @override
  String get chatAttachVideo => 'Video';

  @override
  String get chatAttachVoice => 'Voice note';

  @override
  String get chatAttachmentPhoto => 'Photo';

  @override
  String get chatAttachmentVideo => 'Video';

  @override
  String get chatAttachmentSample => 'Sample';

  @override
  String get chatAttachmentRemove => 'Remove attachment';

  @override
  String chatPendingLabel(String what) {
    return 'Ready to send: $what';
  }

  @override
  String get chatCaptionPlaceholder => 'Add a caption';

  @override
  String get chatOpenPhoto => 'Open photo';

  @override
  String get chatVideoNoPlayback =>
      'Video playback isn’t in this build. The file stays on your phone.';

  @override
  String chatVoiceLabel(String duration) {
    return 'Voice note, $duration';
  }

  @override
  String get chatVoiceDemo => 'Demo · no sound recorded';

  @override
  String get mediaPermissionDenied =>
      'Numaya can’t see your photos. Allow access in your phone’s Settings, then try again.';

  @override
  String get mediaUnsupported =>
      'That file type isn’t supported. Choose a JPG, PNG, WebP or HEIC photo, or an MP4 or MOV video.';

  @override
  String get mediaTooLarge =>
      'That video is over 100 MB. Choose a shorter one.';

  @override
  String get mediaUnreadable => 'Couldn’t open that file. Try another one.';

  @override
  String get mediaUnavailable =>
      'Choosing photos isn’t available here. Turn on sample media in the Demo Hub to try it.';

  @override
  String get mediaMissing => 'This file is no longer on your phone';

  @override
  String get voiceTitle => 'Voice note';

  @override
  String get voiceDemoTitle => 'Demo recorder';

  @override
  String get voiceDemoNote =>
      'This build doesn’t use the microphone, so no sound is captured. It shows how recording a voice note works.';

  @override
  String get voiceStart => 'Start recording';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voiceUse => 'Add to message';

  @override
  String get voiceRedo => 'Record again';

  @override
  String get voiceRecording => 'Recording…';

  @override
  String voiceRecordingLabel(String time) {
    return 'Recording, $time';
  }

  @override
  String get voiceMaxNote => 'Up to 2 minutes';

  @override
  String get voiceTooShort => 'Too short. Record for at least a second.';

  @override
  String get demoSampleMedia => 'Use sample media';

  @override
  String get demoSampleMediaNote =>
      'Attach the bundled sample photo and video instead of opening the phone’s gallery';

  @override
  String get optionShareDate => 'Share date details';

  @override
  String get optionShareDateEdit => 'Date details shared';

  @override
  String get shareDateTitle => 'Share your date';

  @override
  String get shareDateBody =>
      'Let someone you trust know where you’ll be. Meet somewhere public, and keep your own way home.';

  @override
  String get shareDateWhere => 'Where';

  @override
  String get shareDateWhereHint => 'e.g. Violet Cakes, Wilton Way';

  @override
  String get shareDateWhen => 'When';

  @override
  String get shareDateWhenHint => 'e.g. Saturday, 7pm';

  @override
  String get shareDatePreviewLabel => 'What your friend will see';

  @override
  String shareDatePreview(String name, int age, String where, String when) {
    return 'I’m meeting $name, $age, from Numaya at $where, $when. I’ll check in afterwards.';
  }

  @override
  String get shareDateDemo =>
      'Sharing isn’t connected in this build: the details stay on this device and nothing is sent.';

  @override
  String get shareDateShare => 'Share';

  @override
  String get shareDateDone =>
      'Date details saved. Nothing was sent from this demo.';

  @override
  String get recoveryEmailLabel => 'Recovery email';

  @override
  String get recoveryEmailAdd => 'Add';

  @override
  String get recoveryEmailBody =>
      'If you ever lose access to your number, an email on file lets support help you back into your account.';

  @override
  String get recoveryEmailDemo =>
      'In this build the address stays on this device. No email is sent and it isn’t verified.';

  @override
  String get recoveryEmailInvalid =>
      'Enter an email address like name@example.com';

  @override
  String get recoveryEmailSaved => 'Recovery email saved';

  @override
  String get recoveryEmailRemoved => 'Recovery email removed';

  @override
  String get recoveryEmailRemove => 'Remove email';

  @override
  String get recoveryEmailUnverified =>
      'Not verified: no email service in this build';

  @override
  String get reauthTitle => 'Please sign in again';

  @override
  String reauthBody(String phone) {
    return 'For your security, this session has ended. Confirm it’s you with a code sent to $phone and you’ll be back where you were.';
  }

  @override
  String get reauthSend => 'Send code';

  @override
  String get reauthSignOut => 'Sign out instead';

  @override
  String get reauthDone => 'You’re signed in again';

  @override
  String get demoExpireSession => 'Expire my session';

  @override
  String get demoExpireSessionNote =>
      'As if the server ended it: asks you to sign in again over this screen';

  @override
  String get chatStatusWaiting =>
      'Waiting for a connection. It’ll send when you’re back online.';

  @override
  String get offlineBanner => 'You’re offline. We’ll keep trying.';

  @override
  String get offlineBannerDemo => 'Simulated in the Demo Hub';

  @override
  String get demoOffline => 'Simulate being offline';

  @override
  String get demoOfflineNote =>
      'Shows the offline banner; messages wait and send when you switch it off; joining events fails';

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

  @override
  String get tabEvents => 'Events';

  @override
  String eventAbout(Object km) {
    return 'about $km km';
  }

  @override
  String get eventAbout2 => 'About this event';

  @override
  String eventAndMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count more',
      one: 'and 1 more',
    );
    return '$_temp0';
  }

  @override
  String get eventAnswerHint => 'Only the host sees this.';

  @override
  String get eventAreaNote =>
      'Shown as an area and a rough distance, never as an address.';

  @override
  String get eventAttendees => 'Attendees';

  @override
  String get eventBadgeCancelled => 'Cancelled';

  @override
  String get eventBadgeChanged => 'Changed';

  @override
  String get eventBadgeClosed => 'Registration closed';

  @override
  String get eventBadgeDraft => 'Draft';

  @override
  String get eventBadgeFewSpots => 'Few spots left';

  @override
  String get eventBadgeGoing => 'Going';

  @override
  String get eventBadgeHosting => 'Hosting';

  @override
  String get eventBadgeLive => 'Happening now';

  @override
  String get eventBadgePast => 'Ended';

  @override
  String get eventBadgeWaitlist => 'Waitlist';

  @override
  String get eventCancel => 'Cancel event';

  @override
  String get eventCancelBody =>
      'Everyone going and waiting will see that it’s cancelled. The event stays visible with its status.';

  @override
  String get eventCancelConfirm => 'Cancel event';

  @override
  String get eventCancelKeep => 'Keep event';

  @override
  String get eventCancelNoteHint =>
      'Optional, for example why, or when you’ll run it again.';

  @override
  String get eventCancelNoteLabel => 'Note to attendees';

  @override
  String get eventCancelTitle => 'Cancel this event?';

  @override
  String get eventCancelledBody => 'The host cancelled this event.';

  @override
  String get eventCancelledFooter => 'Nobody can join a cancelled event.';

  @override
  String eventCancelledNote(Object note) {
    return 'The host cancelled this event: “$note”';
  }

  @override
  String get eventCancelledTitle => 'Cancelled';

  @override
  String get eventCancelledToast => 'Event cancelled';

  @override
  String eventCapacityValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get eventCatArts => 'Arts';

  @override
  String get eventCatFood => 'Food and drink';

  @override
  String get eventCatGames => 'Games';

  @override
  String get eventCatMusic => 'Music';

  @override
  String get eventCatOutdoors => 'Outdoors';

  @override
  String get eventCatSport => 'Sport';

  @override
  String get eventChangedByYou =>
      'You changed the time or place. People going see this note.';

  @override
  String get eventChangedTitle => 'Changed since people joined';

  @override
  String get eventChangesSaved => 'Changes saved';

  @override
  String get eventChoose => 'Choose';

  @override
  String get eventClosedDetail => 'Joining closes 2 hours before the start.';

  @override
  String get eventClosedToast => 'You can’t join this event any more';

  @override
  String get eventCostAtVenue => 'Cost paid at the venue';

  @override
  String get eventCostHint =>
      'Leave empty if it’s free. Numaya never takes payment.';

  @override
  String get eventCostNote =>
      'Any cost is paid to the venue or host. Numaya doesn’t sell tickets.';

  @override
  String get eventCoverNote => 'Cover colour. Photos come later.';

  @override
  String eventCoverOption(int option) {
    return 'Cover colour $option';
  }

  @override
  String get eventCreate => 'Create an event';

  @override
  String get eventDateAny => 'Any day';

  @override
  String get eventDateToday => 'Today';

  @override
  String get eventDateWeek => 'Next 7 days';

  @override
  String get eventDateWeekend => 'This weekend';

  @override
  String get eventDeleteDraft => 'Delete draft';

  @override
  String get eventDeleteDraftBody =>
      'This draft will be gone. Nobody else has seen it.';

  @override
  String get eventDeleteDraftTitle => 'Delete this draft?';

  @override
  String get eventDemoRsvp => 'Saved on this device (demo)';

  @override
  String get eventDescriptionHint =>
      'What you’ll do, who it’s for, anything to bring.';

  @override
  String get eventDiscard => 'Discard changes';

  @override
  String get eventDiscardBody => 'You have changes that aren’t saved.';

  @override
  String get eventDiscardTitle => 'Leave without saving?';

  @override
  String get eventDistanceAny => 'Any distance';

  @override
  String eventDistanceWithin(int km) {
    return 'Within $km km';
  }

  @override
  String get eventDraftBody =>
      'Only you can see this. Publish when it’s ready.';

  @override
  String get eventDraftDeleted => 'Draft deleted';

  @override
  String get eventDraftIncomplete => 'Finish the missing details to publish';

  @override
  String get eventDraftNeedsTitle => 'Add a title to save a draft';

  @override
  String get eventDraftSaved => 'Draft saved';

  @override
  String get eventDraftTitle => 'Draft';

  @override
  String eventDuration(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours h $minutes min',
      one: '1 h $minutes min',
      zero: '$minutes min',
    );
    return '$_temp0';
  }

  @override
  String get eventEdit => 'Edit';

  @override
  String get eventEditTitle => 'Edit event';

  @override
  String get eventEditingPublished => 'This event is live';

  @override
  String get eventEditingPublishedBody =>
      'If you change the time or place, people going see a note.';

  @override
  String eventErrCapacity(int min) {
    return 'Allow at least $min people.';
  }

  @override
  String eventErrCapacityGoing(int going) {
    return '$going people are already going. Remove someone first or keep the limit higher.';
  }

  @override
  String get eventErrCategory => 'Choose a category.';

  @override
  String get eventErrDate => 'Choose a date and a start time.';

  @override
  String eventErrDescription(int min) {
    return 'Describe it in at least $min characters.';
  }

  @override
  String get eventErrOnline => 'Say how people will get the link.';

  @override
  String get eventErrPast => 'Choose a time in the future.';

  @override
  String eventErrTitle(int min) {
    return 'Add a title of at least $min characters.';
  }

  @override
  String eventErrTitleLong(int max) {
    return 'Keep the title under $max characters.';
  }

  @override
  String get eventErrVenue => 'Add the public place you’ll meet.';

  @override
  String get eventFailedBody =>
      'Nothing changed. This is the demo’s simulated connection problem.';

  @override
  String get eventFailedTitle => 'Couldn’t save that';

  @override
  String get eventFewer => 'Fewer people';

  @override
  String get eventFieldArea => 'Area';

  @override
  String get eventFieldCategory => 'Category';

  @override
  String get eventFieldCost => 'Cost note (optional)';

  @override
  String get eventFieldCover => 'Cover colour';

  @override
  String get eventFieldDate => 'Date';

  @override
  String get eventFieldDescription => 'Description';

  @override
  String get eventFieldLimit => 'Limit attendees';

  @override
  String get eventFieldOnline => 'How people join';

  @override
  String get eventFieldPeople => 'People';

  @override
  String get eventFieldQuestion => 'Question for people joining (optional)';

  @override
  String get eventFieldTime => 'Start time';

  @override
  String get eventFieldTitle => 'Title';

  @override
  String get eventFieldVenue => 'Venue';

  @override
  String get eventFieldWhen => 'When';

  @override
  String get eventFieldWhere => 'Where';

  @override
  String get eventFilterAreaBody =>
      'Distance uses the area you choose. Your device location isn’t read.';

  @override
  String eventFilterAreaOutside(Object area) {
    return 'Events in this demo are in London, not $area';
  }

  @override
  String get eventFilterCategories => 'Categories';

  @override
  String get eventFilterChooseArea => 'Choose area';

  @override
  String get eventFilterDistance => 'Distance';

  @override
  String get eventFilterFormat => 'Format';

  @override
  String get eventFilterFree => 'Free only';

  @override
  String get eventFilterFreeNote => 'Events with no cost note from the host.';

  @override
  String eventFilterFromArea(Object area) {
    return 'From $area';
  }

  @override
  String get eventFilterNoArea => 'No area chosen';

  @override
  String get eventFilters => 'Filters';

  @override
  String eventFiltersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filters, $count on',
      one: 'Filters, 1 on',
    );
    return '$_temp0';
  }

  @override
  String get eventFixErrors => 'Some details need fixing';

  @override
  String get eventFormNote =>
      'Your event is kept on this device in the demo. Nothing is published to other people.';

  @override
  String get eventFormatAny => 'Any';

  @override
  String get eventFormatInPerson => 'In person';

  @override
  String get eventFormatOnline => 'Online';

  @override
  String get eventFree => 'Free';

  @override
  String get eventFull => 'Full';

  @override
  String eventGoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count going',
      one: '1 going',
    );
    return '$_temp0';
  }

  @override
  String get eventGoingHeading => 'Going';

  @override
  String get eventHostBadge => 'Host';

  @override
  String get eventHostPeopleNote =>
      'Tap someone to remove them. The first person waiting takes the place.';

  @override
  String get eventHostSample => 'Sample host';

  @override
  String get eventHostUnknown => 'Someone';

  @override
  String get eventHostYou => 'That’s you';

  @override
  String eventHostedBy(Object name) {
    return 'Hosted by $name';
  }

  @override
  String get eventJoin => 'Join';

  @override
  String get eventJoinWaitlist => 'Join waitlist';

  @override
  String get eventJoinedToast => 'You’re going';

  @override
  String get eventKeepDraft => 'Keep draft';

  @override
  String get eventKeepEditing => 'Keep editing';

  @override
  String get eventLeave => 'Leave';

  @override
  String get eventLeaveBody =>
      'Your place goes to the first person waiting, if there is one.';

  @override
  String get eventLeaveTitle => 'Leave this event?';

  @override
  String get eventLeaveWaitlist => 'Leave waitlist';

  @override
  String get eventLeaveWaitlistBody => 'You’ll lose your place in the queue.';

  @override
  String get eventLeaveWaitlistTitle => 'Leave the waitlist?';

  @override
  String get eventLeftToast => 'You’re not going any more';

  @override
  String get eventLeftWaitlistToast => 'You left the waitlist';

  @override
  String get eventLimitNote => 'When it’s full, people can join a waitlist.';

  @override
  String get eventLiveBody => 'Joining is closed while it’s on.';

  @override
  String get eventLiveTitle => 'Happening now';

  @override
  String get eventMissingBody =>
      'It may have been deleted, or the link is wrong.';

  @override
  String get eventMissingTitle => 'Event not found';

  @override
  String get eventMore => 'More people';

  @override
  String get eventMoveToGoing => 'Move to going';

  @override
  String eventMovedToast(Object name) {
    return '$name is going';
  }

  @override
  String get eventNewTitle => 'New event';

  @override
  String get eventNobodyYet => 'Nobody else yet';

  @override
  String eventOnWaitlist(int position) {
    return 'On the waitlist, number $position';
  }

  @override
  String get eventOnline => 'Online';

  @override
  String get eventOnlineHint =>
      'For example: I’ll send the video link to people going an hour before.';

  @override
  String get eventOwnNote => 'Your event, kept on this device in the demo.';

  @override
  String get eventPastTitle => 'This event has ended';

  @override
  String get eventPeopleNote =>
      'First names only. Open someone to see their profile, report or block.';

  @override
  String eventPickedBecause(Object interest) {
    return 'Because you like $interest';
  }

  @override
  String get eventPreview => 'Preview';

  @override
  String get eventPreviewBody =>
      'This is how people will see your event. Nothing is published yet.';

  @override
  String get eventPreviewTitle => 'Preview';

  @override
  String get eventPublish => 'Publish';

  @override
  String get eventPublishedBody =>
      'It’s in Hosting under My events. In the demo nobody else can see it.';

  @override
  String get eventPublishedTitle => 'Your event is live';

  @override
  String get eventQuestionHint => 'For example: any dietary needs?';

  @override
  String get eventQuestionTitle => 'A question from the host';

  @override
  String get eventRemove => 'Remove';

  @override
  String get eventRemoveBody =>
      'They’ll no longer be going. The first person waiting takes the place.';

  @override
  String eventRemoveTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String eventRemovedToast(Object name) {
    return '$name removed';
  }

  @override
  String get eventReport => 'Report this event';

  @override
  String get eventReportDone => 'Done';

  @override
  String get eventReportLegend => 'What’s wrong?';

  @override
  String get eventReportNote =>
      'Reports stay on this device in the demo; nothing is sent or reviewed.';

  @override
  String get eventReportSend => 'Send report';

  @override
  String get eventReportTitle => 'Report event';

  @override
  String get eventReportedToast => 'Report saved on this device';

  @override
  String get eventSafetyBody =>
      'Meet at the listed public place, tell a friend where you’re going, and leave whenever you like. Numaya never shows anyone’s home address or live location.';

  @override
  String get eventSafetyTitle => 'Meeting safely';

  @override
  String eventSave(Object title) {
    return 'Save $title';
  }

  @override
  String get eventSaveChanges => 'Save changes';

  @override
  String get eventSaveDraft => 'Save draft';

  @override
  String get eventSaved => 'Saved';

  @override
  String get eventSelected => 'Selected';

  @override
  String get eventShare => 'Share';

  @override
  String get eventShareToast =>
      'Sharing isn’t available in the demo. Nothing leaves this device.';

  @override
  String eventShowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count events',
      one: 'Show 1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get eventSortBy => 'Sort by';

  @override
  String get eventSortDate => 'Date';

  @override
  String get eventSortNote =>
      'Relevance puts events matching your interests first, then by date.';

  @override
  String get eventSortRelevance => 'Relevance';

  @override
  String eventSpotsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
    );
    return '$_temp0';
  }

  @override
  String get eventStay => 'Stay';

  @override
  String eventTimeRange(Object start, Object end, Object zone) {
    return '$start–$end ($zone)';
  }

  @override
  String get eventTitle => 'Event';

  @override
  String eventUnsave(Object title) {
    return 'Unsave $title';
  }

  @override
  String get eventUnsaved => 'Removed from saved';

  @override
  String get eventUntitled => 'Untitled event';

  @override
  String eventVenueDistance(Object venue, Object km) {
    return '$venue · about $km km';
  }

  @override
  String get eventVenueHint =>
      'A public place, for example a café or a park entrance.';

  @override
  String eventWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting',
      one: '1 waiting',
      zero: 'Nobody waiting',
    );
    return '$_temp0';
  }

  @override
  String get eventWaitlistDetail => 'If someone drops out, you move up.';

  @override
  String get eventWaitlistFullNote => 'Moving someone up needs a free place.';

  @override
  String eventWaitlistHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waitlist ($count)',
      one: 'Waitlist (1)',
    );
    return '$_temp0';
  }

  @override
  String eventWaitlistPlace(int place) {
    return 'Number $place';
  }

  @override
  String get eventWaitlistRoomNote =>
      'There’s room: tap someone to move them to going.';

  @override
  String eventWaitlistToast(int position) {
    return 'You’re on the waitlist, number $position';
  }

  @override
  String get eventWhoGoing => 'Who’s going';

  @override
  String get eventYou => 'You';

  @override
  String get eventYouWent => 'You went';

  @override
  String get eventYourAnswer => 'Your answer';

  @override
  String get eventYoureGoing => 'You’re going';

  @override
  String get eventsAll => 'All events';

  @override
  String get eventsClear => 'Clear search and filters';

  @override
  String get eventsErrorBody =>
      'This is a simulated connection problem. Try again, or turn it off in the Demo Hub.';

  @override
  String get eventsErrorStillTitle => 'Still can’t load events';

  @override
  String get eventsErrorTitle => 'We couldn’t load events';

  @override
  String get eventsExplore => 'Explore';

  @override
  String get eventsFind => 'Find events';

  @override
  String get eventsGoing => 'Going';

  @override
  String get eventsGoingEmptyBody => 'Events you join appear here.';

  @override
  String get eventsGoingEmptyTitle => 'Nothing planned yet';

  @override
  String get eventsHosting => 'Hosting';

  @override
  String get eventsHostingEmptyBody =>
      'Host a walk, a dinner, a game night. Drafts stay private until you publish.';

  @override
  String get eventsHostingEmptyTitle => 'You’re not hosting anything';

  @override
  String eventsListCount(Object label, int count) {
    return '$label $count';
  }

  @override
  String get eventsLoading => 'Loading events';

  @override
  String get eventsMine => 'My events';

  @override
  String get eventsNoAreaBody =>
      'Distance needs an area. Choose one in Filters, or clear the distance filter.';

  @override
  String get eventsNoResultsBody => 'Try other words, or clear the filters.';

  @override
  String get eventsNoResultsTitle => 'No events match';

  @override
  String get eventsPast => 'Past';

  @override
  String get eventsPastEmptyBody =>
      'Events you went to or hosted appear here afterwards.';

  @override
  String get eventsPastEmptyTitle => 'No past events';

  @override
  String get eventsPicked => 'Picked for your interests';

  @override
  String get eventsPickedNote =>
      'Events in a category linked to an interest on your profile.';

  @override
  String get eventsSampleNote =>
      'Sample events. Hosts, places and attendees are invented; joining is saved on this device only.';

  @override
  String get eventsSaved => 'Saved';

  @override
  String get eventsSavedEmptyBody =>
      'Tap the heart on an event to keep it here.';

  @override
  String get eventsSavedEmptyTitle => 'Nothing saved';

  @override
  String get eventsSearch => 'Search events';

  @override
  String get eventsWaitlist => 'Waitlist';

  @override
  String get eventsWaitlistEmptyBody =>
      'When an event is full you can join its waitlist.';

  @override
  String get eventsWaitlistEmptyTitle => 'No waitlists';

  @override
  String get eventFilterWhen => 'When';

  @override
  String get visTitle => 'Profile & visibility';

  @override
  String get visLede =>
      'What Numaya knows about whether people can see your profile, what you can change, and what it can’t tell you.';

  @override
  String get visVisibility => 'Visibility';

  @override
  String get visStatusVisible => 'Visible';

  @override
  String get visStatusPaused => 'Paused';

  @override
  String get visStatusLimited => 'Limited';

  @override
  String get visStatusAction => 'Action needed';

  @override
  String get visStatusCantCheck => 'Can’t check right now';

  @override
  String get visVisibleBody => 'Your profile can appear in Discover.';

  @override
  String get visVisibleLimits =>
      'Based on your settings and a demo notice source. How often a profile is shown also depends on who is nearby and what they’re looking for, which this page can’t see.';

  @override
  String get visSourceNote =>
      'Based on your own settings and a demo notice source.';

  @override
  String get visPausedBody =>
      'New people can’t see you while you’re paused. Your matches and chats are still here.';

  @override
  String visPausedUntil(Object date) {
    return 'New people can’t see you while you’re paused. It ends $date.';
  }

  @override
  String get visResume => 'Resume';

  @override
  String get visLimitedBody =>
      'Incognito is on: only people you like can see you.';

  @override
  String get visPrivacySettings => 'Privacy settings';

  @override
  String get visCantCheckBody =>
      'We couldn’t check for account notices, so we can’t confirm your visibility. Your own settings are shown below.';

  @override
  String get visRestrictedTitle => 'Hidden from Discover';

  @override
  String get visRestrictedBody =>
      'Numaya has hidden your profile from Discover while a notice is reviewed.';

  @override
  String get visReviewNotice => 'Review and appeal';

  @override
  String get visMissingBody =>
      'Your profile is missing something Discover needs:';

  @override
  String get visReqProfile => 'Finish setting up your profile';

  @override
  String get visReqPhotos => 'At least 2 photos';

  @override
  String get visReqInterests => 'At least 3 interests';

  @override
  String get visReqPrompt => 'One prompt answered';

  @override
  String get visCompleteness => 'Profile completeness';

  @override
  String get visCompletenessNote =>
      'Six parts with equal weight, from what you’ve entered. Verification and private settings aren’t counted.';

  @override
  String get visComplete => 'Complete';

  @override
  String get visIncomplete => 'Incomplete';

  @override
  String get visDone => 'Done';

  @override
  String get visDiscovery => 'Discovery setup';

  @override
  String get visDiscoveryNote => 'These shape who you see, not who sees you.';

  @override
  String get visArea => 'Your area';

  @override
  String get visAreaMissing =>
      'Without one, people see no distance and event distances can’t work.';

  @override
  String get visNotSet => 'Not set';

  @override
  String get visSet => 'Set';

  @override
  String get visOpenTo => 'Who you want to meet';

  @override
  String get visFilters => 'Discover filters';

  @override
  String visFiltersFit(int fit, int total) {
    return 'Fits $fit of $total';
  }

  @override
  String get visFiltersEmpty =>
      'Nobody in the sample fits: Discover would be empty.';

  @override
  String get visVerification => 'Verification';

  @override
  String get visVerificationNote =>
      'Shown on its own and never counted in completeness.';

  @override
  String get visPhone => 'Phone number';

  @override
  String get visPhoto => 'Photo verification';

  @override
  String get visPhotoNotStarted => 'Not started';

  @override
  String get visPhotoPending => 'In review';

  @override
  String get visPhotoVerified => 'Verified';

  @override
  String visPhotoRejected(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Not approved, $left tries left',
      one: 'Not approved, 1 try left',
      zero: 'Not approved',
    );
    return '$_temp0';
  }

  @override
  String get visNotices => 'Account notices';

  @override
  String get visNoNotices => 'No notices';

  @override
  String get visDemoNoticeSource =>
      'From the demo notice source. A real account would check Numaya’s safety team.';

  @override
  String get visNoticeTitle => 'A notice about your profile';

  @override
  String get visNoticeBody =>
      'A photo was removed because it didn’t follow the community guidelines. Your profile is still visible.';

  @override
  String get visReadNotice => 'Read notice';

  @override
  String get visNoticeSheetTitle => 'About this notice';

  @override
  String get visNoticeSheetBody =>
      'One of your photos was removed because it didn’t follow the community guidelines. Nothing else on your account has changed. You can read the guidelines, or contact support if you think this was a mistake.';

  @override
  String get visDemoNoticeNote =>
      'Demo: this notice was set from the Demo Hub. No review took place.';

  @override
  String get visGuidelines => 'Community guidelines';

  @override
  String get visContactSupport => 'Contact support';

  @override
  String get visNoticesUnavailable =>
      'We couldn’t reach the notice source. This doesn’t mean anything is wrong.';

  @override
  String get visActivity => 'Your activity, last 7 days';

  @override
  String get visActivityNote =>
      'Counted from your likes, matches and messages.';

  @override
  String get visSampleData => 'Sample data';

  @override
  String get visLikes => 'Likes received';

  @override
  String get visMatches => 'New matches';

  @override
  String get visConversations => 'Conversations with messages';

  @override
  String get visViews => 'Profile views';

  @override
  String get visNotMeasured => 'Not measured';

  @override
  String get visActivityUpdated => 'Updated just now.';

  @override
  String get visActivityStale =>
      'Last updated 3 days ago: these may be out of date.';

  @override
  String get visActivityUnavailable =>
      'Activity counts aren’t available right now';

  @override
  String get visActivityUnavailableBody =>
      'Nothing about your account changes while they’re missing.';

  @override
  String get visActivityEmpty => 'Not enough activity yet';

  @override
  String get visActivityEmptyBody =>
      'There’s nothing useful to show for the last 7 days.';

  @override
  String get visActivityMeaning =>
      'Counts depend on who is nearby, their preferences and the time of year. They don’t measure you, and a quiet week isn’t a penalty.';

  @override
  String get visSuggestions => 'Suggestions';

  @override
  String get visSuggestionsNote => 'Each one says why it’s here.';

  @override
  String get visNoSuggestions => 'Nothing to suggest';

  @override
  String get visNoSuggestionsBody =>
      'Your profile is complete and nothing needs your attention.';

  @override
  String get visSugRestriction => 'Review the notice';

  @override
  String get visSugNotice => 'Read the notice';

  @override
  String get visSugResume => 'Resume Discover';

  @override
  String get visSugFinish => 'Finish your profile';

  @override
  String get visSugReqPhotos => 'Add photos';

  @override
  String get visSugReqInterests => 'Add interests';

  @override
  String get visSugReqPrompt => 'Answer a prompt';

  @override
  String get visSugVerify => 'Verify your photos';

  @override
  String get visSugPhotos => 'Add more photos';

  @override
  String get visSugPrompts => 'Answer another prompt';

  @override
  String get visSugBio => 'Write a bio';

  @override
  String get visSugInterests => 'Add more interests';

  @override
  String get visSugAbout => 'Fill in About you';

  @override
  String get visSugMore => 'Add more about you';

  @override
  String get visSugArea => 'Choose your area';

  @override
  String get visSugFilters => 'Review your filters';

  @override
  String get visWhyRestriction => 'Your profile is hidden while it’s reviewed.';

  @override
  String get visWhyNotice => 'There’s a notice on your account.';

  @override
  String get visWhyResume => 'You’re paused, so new people can’t see you.';

  @override
  String get visWhyRequired =>
      'Discover needs this before your profile can appear.';

  @override
  String get visWhyVerify =>
      'Verification is optional; it shows people your photos are you.';

  @override
  String get visWhyIncomplete => 'This part of your profile isn’t complete.';

  @override
  String get visWhyArea => 'No area is set.';

  @override
  String get visWhyFilters => 'Your filters fit nobody in the sample.';

  @override
  String get visHowItWorks => 'How this works';

  @override
  String visCheckedAt(Object time) {
    return 'Checked at $time, on this device.';
  }

  @override
  String get visSettingsDetail => 'Visibility, completeness and notices';

  @override
  String get visAboutMeasuredTitle => 'What is measured';

  @override
  String get visAboutMeasuredBody =>
      'Whether your profile can appear in Discover, how complete it is, how Discover is set up for you, your verification, any account notices, and counts of your likes, matches and conversations.';

  @override
  String get visAboutHowTitle => 'How it’s worked out';

  @override
  String get visAboutHowBody =>
      'Visibility is the first of these that applies: a notice hiding your profile, being paused, something Discover needs, the notice source not answering, Incognito; otherwise visible. Completeness is the average of six parts. There is no combined score.';

  @override
  String get visAboutDataTitle => 'What information is used';

  @override
  String get visAboutDataBody =>
      'Your profile entries, your settings (Snooze, Incognito, filters, area), your verification status, the account-notice source and your likes, matches and messages.';

  @override
  String get visAboutWhenTitle => 'When it updates';

  @override
  String get visAboutWhenBody =>
      'Immediately, every time something changes, on this device.';

  @override
  String get visAboutChangeTitle => 'What you can change';

  @override
  String get visAboutChangeBody =>
      'Your profile, Snooze, Incognito, your area, your filters and verification. Each suggestion opens the place to change it.';

  @override
  String get visAboutCantTitle => 'What this page can’t tell you';

  @override
  String get visAboutCantBody =>
      'How other people’s Discover orders profiles, how many people saw yours, or why someone did or didn’t like you. A drop in likes isn’t a sign of a penalty: who is nearby and what they’re looking for change all the time.';

  @override
  String get visAboutDemoTitle => 'Demo sources';

  @override
  String get visAboutDemoBody =>
      'In this build the account notices and the activity counts come from sample data and the Demo Hub. A real account would use Numaya’s services instead.';

  @override
  String get demoAreaEvents => 'Events';

  @override
  String get demoEventsNote =>
      'Sample events relative to today. Joining, hosting and reports stay on this device.';

  @override
  String get demoEventOpen => 'An open event (Late jazz)';

  @override
  String get demoEventFull => 'A full event with a waitlist';

  @override
  String get demoEventCancelled => 'A cancelled event';

  @override
  String get demoEventOpenSpot => 'Open a spot at board games';

  @override
  String get demoEventOpenSpotDetail =>
      'Someone going drops out; the waitlist moves up';

  @override
  String get demoEventSpotYou => 'A spot opened: you’re going';

  @override
  String get demoEventSpotOpened => 'A spot opened; the waitlist moved up';

  @override
  String get demoEventReset => 'Reset events';

  @override
  String get demoEventResetDone => 'Events back to the sample data';

  @override
  String get demoVisNote =>
      'Sets the demo notice and activity sources. Nothing is reviewed or measured.';

  @override
  String get demoVisNoticeNone => 'Notices: none';

  @override
  String get demoVisNotice => 'Notices: a photo was removed';

  @override
  String get demoVisRestricted => 'Notices: hidden while reviewed';

  @override
  String get demoVisUnavailable => 'Notices: source not answering';

  @override
  String get demoVisInsightsLive => 'Activity: up to date';

  @override
  String get demoVisInsightsStale => 'Activity: out of date';

  @override
  String get demoVisInsightsOff => 'Activity: unavailable';
}
