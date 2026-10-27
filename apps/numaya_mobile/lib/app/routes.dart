/// Route paths, in one place.
abstract final class Routes {
  static const welcome = '/';
  static const phone = '/phone';
  static const verify = '/verify';
  static const setup = '/setup';
  static const basics = '/setup/basics';
  static const interests = '/setup/interests';
  static const photos = '/setup/photos';
  static const prompt = '/setup/prompt';
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
      path.startsWith(person);

  static bool isSignedOutOnly(String path) =>
      path == welcome || path.startsWith(phone) || path.startsWith(verify);

  static bool isSetup(String path) => path.startsWith(setup);
}
