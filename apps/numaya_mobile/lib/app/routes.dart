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

  // MVP PRD (2026-11-07) -------------------------------------------------------------------------
  /// S17: today's likes are used.
  static const allowance = '/allowance';

  /// S14: `/compliment/:personId?kind=photo|prompt&index=n`.
  static const compliment = '/compliment';

  /// S21: `/request/:complimentId`.
  static const request = '/request';

  /// R01: Archive (quiet conversations, and initial matches that ran out).
  static const archive = '/chats/archive';

  /// Retired by R01 (no expiry or reconnection for started chats). Kept only so old links and
  /// notifications land somewhere sensible: `/chats/expired` opens Archive, `/reconnect/:id`
  /// opens that chat.
  static const legacyExpiredChats = '/chats/expired';
  static const legacyReconnect = '/reconnect';

  /// S29-S33 in Profile.
  static const health = '/profile/health';
  static const healthAbout = '/profile/health/about';
  static const insights = '/profile/insights';
  static const streak = '/profile/streak';
  static const wallet = '/profile/wallet';

  /// S35-S37.
  static const storeCompliments = '/store/compliments';
  static const storeRecovery = '/store/recovery';
  static const storeOutcome = '/store/outcome';

  /// S45: `/legal` and `/legal/:doc` (readable signed out).
  static const legal = '/legal';

  /// S43: support and appeal requests.
  static const supportRequests = '/help/requests';

  /// The Events tab (`?view=mine` opens My events) and full-screen event pages.
  static const events = '/events';

  /// Events MVP (co-founder PRD, 2026-11-08). E04, E02 (+/reserve), E05, E06, E07, M02, M01.
  static const evMine = '/events/mine';
  static const evEvent = '/events/e';
  static const evReservation = '/events/r';
  static const evNotice = '/events/notice';
  static const evMet = '/events/met';
  static const evProposals = '/events/proposals';
  static const evPropose = '/events/propose';

  /// Internal tools demo (H01–H04): Demo Hub only.
  static const staff = '/staff';
  static const staffProposal = '/staff/proposal';
  static const staffEvent = '/staff/event';

  /// Neutral fallback for retired Health/Insights links.
  static const profileUnavailable = '/profile?notice=unavailable';
  static const event = '/event';
  static const eventNew = '/event/new';

  /// The Events tab and every event page (`/events`, `/event/new`, `/event/:id`, `/event/:id/...`).
  static bool isEvents(String path) =>
      path == events ||
      path.startsWith('$events/') ||
      path == event ||
      path.startsWith('$event/');

  /// Profile & visibility (account health) and its explanation page.
  static const visibility = '/profile/visibility';
  static const visibilityAbout = '/profile/visibility/about';

  /// Paywall, with `?feature=` naming what triggered it (D-14).
  static const paywall = '/paywall';

  /// Help centre, readable signed in or out.
  static const help = '/help';
  static const helpContact = '/help/contact';

  /// A deleted account found at sign-in (F27).
  static const restore = '/restore';

  /// Session expired: sign in again over the current screen (states-and-recovery §3).
  static const reauth = '/sign-in-again';

  /// Moderation block with appeal (B-59). Shown when the server says so; the demo previews it
  /// from the Demo Hub.
  static const accountBlocked = '/account-blocked';

  /// Development-only screen catalogue.
  static const demo = '/demo';

  /// Development-only Design Lab (Monochrome Meetup components and states), under the Demo Hub.
  static const designLab = '/design-lab';

  /// DEVELOPMENT ONLY: overnight v3 layout experiments (Current / A / B / C per experiment).
  static const experimentLab = '/experiment-lab';

  /// DEVELOPMENT ONLY. Visual Lab V2 Design Lab and its per-family previews.
  static const visualLab = '/visual-lab';
  static const visualLabPreview = '/visual-lab/preview';

  /// Full-screen dating routes, outside the tab shell; each takes a sample person id.
  static const like = '/like';
  static const match = '/match';
  static const chat = '/chat';
  static const person = '/person';

  /// A sample person's photos, opened at photo [start] (1-based).
  static String personPhotos(String id, {int start = 1}) =>
      '$person/$id/photos?start=$start';

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
      path.startsWith(events) ||
      path.startsWith(event) ||
      path.startsWith(forYou) ||
      path.startsWith(paywall) ||
      path.startsWith(allowance) ||
      path.startsWith(compliment) ||
      path.startsWith(request) ||
      path.startsWith('/chats') ||
      path.startsWith(legacyReconnect) ||
      path.startsWith('/store') ||
      path.startsWith(restore) ||
      path == reauth;

  static bool isSignedOutOnly(String path) =>
      path == welcome || path.startsWith(phone) || path.startsWith(verify);

  static bool isSetup(String path) => path.startsWith(setup);
}
