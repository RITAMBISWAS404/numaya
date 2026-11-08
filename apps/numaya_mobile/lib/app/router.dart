import 'package:flutter/material.dart' show MaterialPage;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/application/session_expiry.dart';
import '../features/auth/application/verification_controller.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/phone_screen.dart';
import '../features/auth/presentation/reauth_screen.dart';
import '../features/auth/presentation/verify_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/commerce/presentation/store_screens.dart';
import '../features/commerce/presentation/wallet_screen.dart';
import '../features/compliments/presentation/compliment_screens.dart';
import '../features/dating/presentation/archive_screen.dart';
import '../features/dating/presentation/discover_screen.dart';
import '../features/dating/presentation/for_you_screen.dart';
import '../features/dating/presentation/likes_screens.dart';
import '../features/dating/presentation/match_screen.dart';
import '../features/dating/presentation/messages_screens.dart';
import '../features/dating/presentation/photo_viewer_screen.dart';
import '../features/demo/presentation/demo_hub_screen.dart';
import '../features/demo/presentation/design_lab_screen.dart';
import '../features/events_mvp/presentation/event_detail_screens.dart';
import '../features/events_mvp/presentation/events_feed_screen.dart';
import '../features/events_mvp/presentation/my_events_screens.dart';
import '../features/events_mvp/presentation/proposal_staff_screens.dart';
import '../features/experiments/experiment_lab_screen.dart';
import '../features/help/presentation/help_screens.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/lab/visual_lab_screen.dart';
import '../features/matches/presentation/lifecycle_screens.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/presentation/about_you_screens.dart';
import '../features/onboarding/presentation/basics_screen.dart';
import '../features/onboarding/presentation/finish_screens.dart';
import '../features/onboarding/presentation/interests_screen.dart';
import '../features/onboarding/presentation/looking_for_screens.dart';
import '../features/onboarding/presentation/photos_screen.dart';
import '../features/onboarding/presentation/profile_steps_screens.dart';
import '../features/onboarding/presentation/prompt_editor_screen.dart';
import '../features/onboarding/presentation/setup_hub_screen.dart';
import '../features/premium/application/premium_controller.dart';
import '../features/premium/presentation/premium_screens.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_hub_screens.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/blocked_screen.dart';
import '../features/settings/presentation/legal_screens.dart';
import '../features/settings/presentation/settings_more_screens.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/streaks/presentation/streak_screen.dart';
import '../features/verification/presentation/verification_screen.dart';
import 'not_found_screen.dart';
import 'providers.dart';
import 'release_scope.dart';
import 'routes.dart';

/// Re-runs the router's redirect whenever the session changes.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen<AuthSession?>(sessionProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: refresh,
    errorPageBuilder: (_, state) => _page(state, const NotFoundScreen()),
    redirect: (context, state) {
      final path = state.uri.path;
      final session = ref.read(sessionProvider);
      // The Demo Hub and its Design Lab exist only where demo sign-in does (never in release
      // builds).
      if ((path == Routes.demo ||
              path == Routes.designLab ||
              path == Routes.experimentLab ||
              path.startsWith(Routes.visualLab)) &&
          ref.read(demoAuthProvider) == null) {
        return Routes.welcome;
      }
      // First release (UI-031): Opening Moves is excluded, so its route, deep links included,
      // lands on Profile instead.
      if (path == Routes.openingMoves && !ReleaseScope.openingMoves) {
        return Routes.profile;
      }
      // MVP (Tabler MVP pass): Events is unavailable, so its tab route, event pages and their
      // child routes (people, edit, new), deep links included, land on Discover.
      // Events MVP: the old dormant module's links (`/event/...`) land on the new feed.
      if (path == Routes.event || path.startsWith('${Routes.event}/')) {
        return Routes.events;
      }
      // Internal tools demo exists only where the Demo Hub does.
      if (path.startsWith(Routes.staff) && ref.read(demoAuthProvider) == null) {
        return Routes.events;
      }
      if (session == null) {
        if (Routes.requiresSession(path)) return Routes.welcome;
        if (path == Routes.verify &&
            ref.read(verificationProvider).request == null) {
          return Routes.phone;
        }
        return null;
      }
      // Signed in: the welcome and phone steps no longer apply. Not while the verify step is
      // showing its success state: the routes under it in the stack are checked too, and the
      // verify screen hands over itself.
      final verifying =
          ref.read(verificationProvider).status == VerificationStatus.success;
      // A deleted account found at sign-in: restore or start over first (F27).
      if (session.restorableUntil != null && !verifying) {
        return path == Routes.restore ||
                path.startsWith(Routes.help) ||
                path == Routes.demo ||
                path == Routes.designLab ||
                path == Routes.experimentLab
            ? null
            : Routes.restore;
      }
      if (path == Routes.reauth && !ref.read(sessionExpiryProvider)) {
        return Routes.home;
      }
      if (path == Routes.restore && session.restorableUntil == null) {
        return Routes.home;
      }
      // A confirmed age under 18 ends setup: only the explanation and help stay open (OD-3).
      if (ref.read(onboardingProvider).ageLocked) {
        return path == Routes.setupUnderage || path.startsWith(Routes.help)
            ? null
            : Routes.setupUnderage;
      }
      if (!verifying &&
          (path == Routes.welcome || path.startsWith(Routes.phone))) {
        return session.hasProfile ? Routes.home : Routes.setup;
      }
      return null;
    },
    routes: [
      _route(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      _route(
        path: Routes.phone,
        builder: (_, state) => PhoneScreen(
          intent: state.uri.queryParameters['intent'] == Routes.intentSignIn
              ? AuthIntent.signIn
              : AuthIntent.signUp,
        ),
      ),
      _route(path: Routes.verify, builder: (_, _) => const VerifyScreen()),
      _route(
        path: Routes.setup,
        builder: (_, _) => const SetupHubScreen(),
        routes: [
          _route(path: 'name', builder: (_, _) => const NameBirthdayScreen()),
          _route(path: 'underage', builder: (_, _) => const UnderageScreen()),
          _route(path: 'gender', builder: (_, _) => const GenderScreen()),
          _route(path: 'meet', builder: (_, _) => const MeetScreen()),
          _route(
            path: 'intentions',
            builder: (_, _) => const IntentionsScreen(),
          ),
          _route(path: 'height', builder: (_, _) => const HeightScreen()),
          _route(path: 'location', builder: (_, _) => const LocationScreen()),
          _route(path: 'photos', builder: (_, _) => const PhotosScreen()),
          _route(path: 'interests', builder: (_, _) => const InterestsScreen()),
          _route(path: 'prompts', builder: (_, _) => const PromptsScreen()),
          _route(
            path: 'prompt',
            builder: (_, state) => PromptEditorScreen(
              slot: (int.tryParse(state.uri.queryParameters['slot'] ?? '') ?? 0)
                  .clamp(0, 2),
            ),
          ),
          _route(path: 'bio', builder: (_, _) => const BioScreen()),
          _route(path: 'verify', builder: (_, _) => const VerifyOfferScreen()),
          _route(
            path: 'notifications',
            builder: (_, _) => const NotificationsPrimerScreen(),
          ),
          _route(path: 'review', builder: (_, _) => const ReviewScreen()),
          _route(path: 'done', builder: (_, _) => const AllSetScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) =>
            _page(state, HomeShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.likes,
                // R03: `?tab=compliments` opens the Compliments part (notification links).
                builder: (_, state) => LikesScreen(
                  initialTab: state.uri.queryParameters['tab'] == 'compliments'
                      ? HeartTab.compliments
                      : HeartTab.likes,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.messages,
                builder: (_, _) => const MessagesScreen(),
              ),
            ],
          ),
          // Events MVP: the fourth tab (Discover / Likes / Chats / Events / Profile).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.events,
                builder: (_, _) => const EventsFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, state) => ProfileScreen(
                  unavailableNotice:
                      state.uri.queryParameters['notice'] == 'unavailable',
                ),
              ),
            ],
          ),
        ],
      ),
      _route(
        path: Routes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
        routes: [
          _route(path: 'basics', builder: (_, _) => const BasicsScreen()),
          _route(
            path: 'interests',
            builder: (_, _) => const InterestsScreen(editing: true),
          ),
          _route(
            path: 'photos',
            builder: (_, _) => const PhotosScreen(editing: true),
          ),
          _route(
            path: 'prompt',
            builder: (_, state) => PromptEditorScreen(
              editing: true,
              slot:
                  int.tryParse(state.uri.queryParameters['slot'] ?? '')
                      ?.clamp(0, 2) ??
                  0,
            ),
          ),
        ],
      ),
      _route(
        path: Routes.notifications,
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      _route(path: Routes.privacy, builder: (_, _) => const PrivacyScreen()),
      _route(
        path: Routes.deleteAccount,
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      _route(
        path: Routes.completion,
        builder: (_, _) => const CompletionHubScreen(),
      ),
      _route(
        path: Routes.preview,
        builder: (_, _) => const ProfilePreviewScreen(),
      ),
      _route(
        path: Routes.openingMoves,
        builder: (_, _) => const OpeningMovesScreen(),
      ),
      GoRoute(
        path: Routes.verifyPhoto,
        pageBuilder: (_, state) => _modal(state, const VerificationScreen()),
      ),
      GoRoute(
        path: Routes.premium,
        pageBuilder: (_, state) => _modal(state, const PremiumScreen()),
      ),
      _route(
        path: Routes.safety,
        builder: (_, _) => const SafetyCentreScreen(),
      ),
      _route(path: Routes.forYou, builder: (_, _) => const ForYouScreen()),
      // MVP PRD screens (docs/product/mvp-prd-v1/TRACEABILITY.md maps each S-ID).
      GoRoute(
        path: Routes.allowance,
        pageBuilder: (_, state) => _modal(state, const AllowanceUsedScreen()),
      ),
      GoRoute(
        path: '${Routes.compliment}/:id',
        pageBuilder: (_, state) => _modal(
          state,
          ComplimentComposerScreen(
            key: ValueKey(state.uri.toString()),
            personId: state.pathParameters['id']!,
            target: parseComplimentTarget(state.uri.queryParameters),
          ),
        ),
      ),
      _route(
        path: '${Routes.request}/:id',
        builder: (_, state) => RequestScreen(
          key: ValueKey(state.uri.toString()),
          complimentId: state.pathParameters['id']!,
        ),
      ),
      _route(path: Routes.archive, builder: (_, _) => const ArchiveScreen()),
      // R01: retired routes redirect instead of 404 (old notifications, saved links).
      GoRoute(
        path: Routes.legacyExpiredChats,
        redirect: (_, _) => Routes.archive,
      ),
      GoRoute(
        path: '${Routes.legacyReconnect}/:id',
        redirect: (_, state) => '${Routes.chat}/${state.pathParameters['id']}',
      ),
      // Health/Insights removed (Events PRD): old links land on Profile with a short note.
      GoRoute(
        path: Routes.health,
        redirect: (_, _) => Routes.profileUnavailable,
        routes: [
          GoRoute(path: 'about', redirect: (_, _) => Routes.profileUnavailable),
        ],
      ),
      GoRoute(
        path: Routes.insights,
        redirect: (_, _) => Routes.profileUnavailable,
      ),
      _route(path: Routes.streak, builder: (_, _) => const StreakScreen()),
      _route(path: Routes.wallet, builder: (_, _) => const WalletScreen()),
      GoRoute(
        path: Routes.storeCompliments,
        pageBuilder: (_, state) => _modal(state, const ComplimentPackScreen()),
      ),
      GoRoute(
        path: Routes.storeRecovery,
        pageBuilder: (_, state) => _modal(state, const RecoveryScreen()),
      ),
      GoRoute(
        path: Routes.storeOutcome,
        pageBuilder: (_, state) {
          final o = parseOutcome(state.uri.queryParameters);
          return _modal(
            state,
            PurchaseOutcomeScreen(kind: o.kind, outcome: o.outcome),
          );
        },
      ),
      _route(
        path: Routes.legal,
        builder: (_, _) => const LegalScreen(),
        routes: [
          _route(
            path: ':doc',
            builder: (_, state) => LegalDocScreen(
              doc:
                  LegalDoc.values
                      .where((d) => d.name == state.pathParameters['doc'])
                      .firstOrNull ??
                  LegalDoc.terms,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.visibility,
        redirect: (_, _) => Routes.profileUnavailable,
        routes: [
          GoRoute(path: 'about', redirect: (_, _) => Routes.profileUnavailable),
        ],
      ),
      GoRoute(
        path: Routes.paywall,
        pageBuilder: (_, state) {
          final name = state.uri.queryParameters['feature'];
          return _modal(
            state,
            PaywallScreen(
              feature: PremiumFeature.values
                  .where((f) => f.name == name)
                  .firstOrNull,
            ),
          );
        },
      ),
      // Events MVP routes (PRD E02–E07, M01/M02; H01–H04 demo).
      _route(path: Routes.evMine, builder: (_, _) => const MyEventsScreen()),
      _route(
        path: '${Routes.evEvent}/:id',
        builder: (_, state) => EventDetailScreen(
          key: ValueKey(state.uri.toString()),
          eventId: state.pathParameters['id']!,
        ),
        routes: [
          _route(
            path: 'reserve',
            builder: (_, state) =>
                EventReserveScreen(eventId: state.pathParameters['id']!),
          ),
        ],
      ),
      _route(
        path: '${Routes.evReservation}/:id',
        builder: (_, state) => ReservationScreen(
          key: ValueKey(state.uri.toString()),
          eventId: state.pathParameters['id']!,
        ),
      ),
      _route(
        path: '${Routes.evNotice}/:id',
        builder: (_, state) => EventNoticeScreen(
          key: ValueKey(state.uri.toString()),
          noticeId: state.pathParameters['id']!,
        ),
      ),
      _route(
        path: '${Routes.evMet}/:id',
        builder: (_, state) =>
            PeopleMetScreen(eventId: state.pathParameters['id']!),
      ),
      _route(
        path: Routes.evProposals,
        builder: (_, _) => const ProposalsScreen(),
      ),
      _route(
        path: '${Routes.evPropose}/:id',
        builder: (_, state) => ProposalFormScreen(
          key: ValueKey(state.uri.toString()),
          proposalId: state.pathParameters['id']!,
        ),
      ),
      _route(path: Routes.staff, builder: (_, _) => const StaffHomeScreen()),
      _route(
        path: '${Routes.staffProposal}/:id',
        builder: (_, state) =>
            StaffProposalScreen(proposalId: state.pathParameters['id']!),
      ),
      _route(
        path: '${Routes.staffEvent}/:id',
        builder: (_, state) =>
            StaffEventScreen(eventId: state.pathParameters['id']!),
      ),
      _route(
        path: Routes.help,
        builder: (_, _) => const HelpCentreScreen(),
        routes: [
          _route(
            path: 'contact',
            builder: (_, _) => const ContactSupportScreen(),
          ),
          _route(
            path: 'requests',
            builder: (_, _) => const SupportRequestsScreen(),
          ),
          _route(
            path: ':id',
            builder: (_, state) =>
                HelpArticleScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
      _route(
        path: Routes.restore,
        builder: (_, _) => const RestoreAccountScreen(),
      ),
      _route(path: Routes.reauth, builder: (_, _) => const ReauthScreen()),
      _route(
        path: Routes.accountBlocked,
        builder: (_, _) => const AccountBlockedScreen(),
      ),
      _route(path: Routes.demo, builder: (_, _) => const DemoHubScreen()),
      _route(
        path: Routes.visualLab,
        builder: (_, _) => const VisualLabScreen(),
      ),
      _route(
        path: '${Routes.visualLabPreview}/:group',
        builder: (_, state) => LabPreviewScreen(
          key: ValueKey(state.uri.toString()),
          groupId: state.pathParameters['group']!,
          variant: state.uri.queryParameters['v'],
        ),
      ),
      _route(
        path: Routes.experimentLab,
        builder: (_, _) => const ExperimentLabScreen(),
      ),
      _route(
        path: Routes.designLab,
        builder: (_, _) => const DesignLabScreen(),
      ),
      _route(
        path: '${Routes.like}/:id',
        builder: (_, state) =>
            LikeProfileScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.match}/:id',
        pageBuilder: (_, state) =>
            _modal(state, MatchScreen(personId: state.pathParameters['id']!)),
      ),
      _route(
        path: '${Routes.chat}/:id',
        builder: (_, state) => ChatScreen(
          key: ValueKey('chat-${state.pathParameters['id']}'),
          personId: state.pathParameters['id']!,
        ),
      ),
      _route(
        path: '${Routes.person}/:id',
        builder: (_, state) => PersonProfileScreen(
          personId: state.pathParameters['id']!,
          canDecide: state.uri.queryParameters['decide'] == '1',
        ),
      ),
      _route(
        path: '${Routes.person}/:id/photos',
        builder: (_, state) => PhotoViewerScreen(
          personId: state.pathParameters['id']!,
          start: int.tryParse(state.uri.queryParameters['start'] ?? '') ?? 1,
        ),
      ),
      _route(path: Routes.blocked, builder: (_, _) => const BlockedScreen()),
      _route(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// A modal moment (match, paywall, Premium, verification) rises over the page it interrupts rather
/// than pushing sideways (docs/mobile/MOTION_DESIGN_AUDIT.md).
Page<void> _modal(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  name: state.name,
  arguments: state.extra,
  child: child,
  transitionDuration: AppMotion.push,
  reverseTransitionDuration: AppMotion.state,
  transitionsBuilder: modalTransition,
);

/// Every page is built here rather than by go_router: go_router 18 looks for `material_ui`'s
/// `MaterialApp`, doesn't find Flutter's, and would fall back to pages with no transition. A
/// [MaterialPage] runs the theme's page transition (NumayaPageTransitionsBuilder on Android).
Page<void> _page(GoRouterState state, Widget child) => MaterialPage(
  key: state.pageKey,
  name: state.name,
  arguments: state.extra,
  restorationId: state.pageKey.value,
  child: child,
);

/// A [GoRoute] whose page is a [_page].
GoRoute _route({
  required String path,
  required GoRouterWidgetBuilder builder,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _page(state, builder(context, state)),
  routes: routes,
);
