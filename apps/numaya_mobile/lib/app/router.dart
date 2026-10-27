import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/session_controller.dart';
import '../features/auth/application/verification_controller.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/phone_screen.dart';
import '../features/auth/presentation/verify_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/dating/presentation/discover_screen.dart';
import '../features/dating/presentation/for_you_screen.dart';
import '../features/dating/presentation/likes_screens.dart';
import '../features/dating/presentation/match_screen.dart';
import '../features/dating/presentation/messages_screens.dart';
import '../features/demo/presentation/demo_hub_screen.dart';
import '../features/help/presentation/help_screens.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/onboarding/presentation/basics_screen.dart';
import '../features/onboarding/presentation/interests_screen.dart';
import '../features/onboarding/presentation/photos_screen.dart';
import '../features/onboarding/presentation/prompt_editor_screen.dart';
import '../features/onboarding/presentation/setup_hub_screen.dart';
import '../features/premium/application/premium_controller.dart';
import '../features/premium/presentation/premium_screens.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_hub_screens.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/blocked_screen.dart';
import '../features/settings/presentation/settings_more_screens.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/verification/presentation/verification_screen.dart';
import 'not_found_screen.dart';
import 'providers.dart';
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
    errorBuilder: (_, _) => const NotFoundScreen(),
    redirect: (context, state) {
      final path = state.uri.path;
      final session = ref.read(sessionProvider);
      // The Demo Hub exists only where demo sign-in does (never in release builds).
      if (path == Routes.demo && ref.read(demoAuthProvider) == null) {
        return Routes.welcome;
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
                path == Routes.demo
            ? null
            : Routes.restore;
      }
      if (path == Routes.restore && session.restorableUntil == null) {
        return Routes.home;
      }
      if (!verifying &&
          (path == Routes.welcome || path.startsWith(Routes.phone))) {
        return session.hasProfile ? Routes.home : Routes.setup;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(
        path: Routes.phone,
        builder: (_, state) => PhoneScreen(
          intent: state.uri.queryParameters['intent'] == Routes.intentSignIn
              ? AuthIntent.signIn
              : AuthIntent.signUp,
        ),
      ),
      GoRoute(path: Routes.verify, builder: (_, _) => const VerifyScreen()),
      GoRoute(
        path: Routes.setup,
        builder: (_, _) => const SetupHubScreen(),
        routes: [
          GoRoute(path: 'basics', builder: (_, _) => const BasicsScreen()),
          GoRoute(
            path: 'interests',
            builder: (_, _) => const InterestsScreen(),
          ),
          GoRoute(path: 'photos', builder: (_, _) => const PhotosScreen()),
          GoRoute(
            path: 'prompt',
            builder: (_, _) => const PromptEditorScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
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
                builder: (_, _) => const LikesScreen(),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
        routes: [
          GoRoute(
            path: 'basics',
            builder: (_, _) => const BasicsScreen(editing: true),
          ),
          GoRoute(
            path: 'interests',
            builder: (_, _) => const InterestsScreen(editing: true),
          ),
          GoRoute(
            path: 'photos',
            builder: (_, _) => const PhotosScreen(editing: true),
          ),
          GoRoute(
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
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: Routes.privacy, builder: (_, _) => const PrivacyScreen()),
      GoRoute(
        path: Routes.deleteAccount,
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: Routes.completion,
        builder: (_, _) => const CompletionHubScreen(),
      ),
      GoRoute(
        path: Routes.preview,
        builder: (_, _) => const ProfilePreviewScreen(),
      ),
      GoRoute(
        path: Routes.openingMoves,
        builder: (_, _) => const OpeningMovesScreen(),
      ),
      GoRoute(
        path: Routes.verifyPhoto,
        builder: (_, _) => const VerificationScreen(),
      ),
      GoRoute(path: Routes.premium, builder: (_, _) => const PremiumScreen()),
      GoRoute(
        path: Routes.safety,
        builder: (_, _) => const SafetyCentreScreen(),
      ),
      GoRoute(path: Routes.forYou, builder: (_, _) => const ForYouScreen()),
      GoRoute(
        path: Routes.paywall,
        builder: (_, state) {
          final name = state.uri.queryParameters['feature'];
          return PaywallScreen(
            feature: PremiumFeature.values
                .where((f) => f.name == name)
                .firstOrNull,
          );
        },
      ),
      GoRoute(
        path: Routes.help,
        builder: (_, _) => const HelpCentreScreen(),
        routes: [
          GoRoute(
            path: 'contact',
            builder: (_, _) => const ContactSupportScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                HelpArticleScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.restore,
        builder: (_, _) => const RestoreAccountScreen(),
      ),
      GoRoute(
        path: Routes.accountBlocked,
        builder: (_, _) => const AccountBlockedScreen(),
      ),
      GoRoute(path: Routes.demo, builder: (_, _) => const DemoHubScreen()),
      GoRoute(
        path: '${Routes.like}/:id',
        builder: (_, state) =>
            LikeProfileScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.match}/:id',
        builder: (_, state) =>
            MatchScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.chat}/:id',
        builder: (_, state) =>
            ChatScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.person}/:id',
        builder: (_, state) => PersonProfileScreen(
          personId: state.pathParameters['id']!,
          canDecide: state.uri.queryParameters['decide'] == '1',
        ),
      ),
      GoRoute(path: Routes.blocked, builder: (_, _) => const BlockedScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
