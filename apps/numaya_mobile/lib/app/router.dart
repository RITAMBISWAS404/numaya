import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/session_controller.dart';
import '../features/auth/application/verification_controller.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/phone_screen.dart';
import '../features/auth/presentation/verify_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/home/presentation/tab_screens.dart';
import '../features/onboarding/presentation/basics_screen.dart';
import '../features/onboarding/presentation/interests_screen.dart';
import '../features/onboarding/presentation/photos_screen.dart';
import '../features/onboarding/presentation/prompt_editor_screen.dart';
import '../features/onboarding/presentation/setup_hub_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
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
    redirect: (context, state) {
      final path = state.uri.path;
      final session = ref.read(sessionProvider);
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
            builder: (_, _) => const PromptEditorScreen(editing: true),
          ),
        ],
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
