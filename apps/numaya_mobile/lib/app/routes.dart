/// Route paths, in one place.
abstract final class Routes {
  static const welcome = '/';
  static const phone = '/phone';
  static const verify = '/verify';
  static const setup = '/setup';
  static const interests = '/setup/interests';
  static const photos = '/setup/photos';
  static const prompt = '/setup/prompt';
  static const setupName = '/setup/name';
  static const setupUnderage = '/setup/underage';
  static const setupGender = '/setup/gender';
  static const setupMeet = '/setup/meet';
  static const setupIntentions = '/setup/intentions';
  static const setupHeight = '/setup/height';
  static const setupLocation = '/setup/location';
  static const setupPrompts = '/setup/prompts';
  static const setupBio = '/setup/bio';
  static const setupVerify = '/setup/verify';
  static const setupNotifications = '/setup/notifications';
  static const setupReview = '/setup/review';
  static const setupDone = '/setup/done';
  static const home = '/home';
  static const likes = '/likes';
  static const messages = '/messages';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const editBasics = '/profile/edit/basics';
  static const editInterests = '/profile/edit/interests';
  static const editPhotos = '/profile/edit/photos';
  static const editPrompt = '/profile/edit/prompt';
  static const settings = '/profile/settings';
  static const blocked = '/profile/settings/blocked';
  static const notifications = '/profile/settings/notifications';
  static const privacy = '/profile/settings/privacy';
  static const deleteAccount = '/profile/settings/delete';
  static const completion = '/profile/complete';
  static const preview = '/profile/preview';
  static const openingMoves = '/profile/opening-moves';
  static const verifyPhoto = '/profile/verify';
  static const premium = '/profile/premium';
  static const safety = '/profile/safety';
  static const forYou = '/for-you';

  /// Paywall, with `?feature=` naming what triggered it (D-14).
  static const paywall = '/paywall';

  /// Help centre, readable signed in or out.
  static const help = '/help';
  static const helpContact = '/help/contact';

  /// A deleted account found at sign-in (F27).
  static const restore = '/restore';

  /// Moderation block with appeal (B-59). Shown when the server says so; the demo previews it
  /// from the Demo Hub.
  static const accountBlocked = '/account-blocked';

  /// Development-only screen catalogue.
  static const demo = '/demo';

  /// Full-screen dating routes, outside the tab shell; each takes a sample person id.
  static const like = '/like';
  static const match = '/match';
  static const chat = '/chat';
  static const person = '/person';

  /// Query parameter on [phone]: `?intent=signin` for returning members.
  static const intentSignIn = 'signin';

  static bool requiresSession(String path) =>
      path.startsWith(setup) ||
      path.startsWith(home) ||
      path.startsWith(likes) ||
      path.startsWith(messages) ||
      path.startsWith(profile) ||
      path.startsWith(like) ||
      path.startsWith(match) ||
      path.startsWith(chat) ||
      path.startsWith(person) ||
      path.startsWith(forYou) ||
      path.startsWith(paywall) ||
      path.startsWith(restore);

  static bool isSignedOutOnly(String path) =>
      path == welcome || path.startsWith(phone) || path.startsWith(verify);

  static bool isSetup(String path) => path.startsWith(setup);
}
