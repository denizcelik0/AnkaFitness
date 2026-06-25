import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/login_screen.dart';
import '../../views/shared/splash_screen.dart';
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/add_member_screen.dart';
import '../../views/admin/member_detail_screen.dart';
import '../../views/member/member_home_screen.dart';
import '../../views/member/workout_screen.dart';

/// GoRouter yapılandırması.
/// Rol tabanlı yönlendirme (admin → admin paneli, member → üye paneli).
class AppRouter {
  static GoRouter router(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isLoggedIn = authViewModel.isLoggedIn;
        final isOnLogin = state.matchedLocation == '/login';
        final isOnSplash = state.matchedLocation == '/';

        // Henüz oturum durumu belirlenmemişse splash'ta kal
        if (isOnSplash && !isLoggedIn) {
          return '/login';
        }

        // Giriş yapmamışsa login'e yönlendir
        if (!isLoggedIn && !isOnLogin) {
          return '/login';
        }

        // Giriş yapmışsa login'den çıkar, role göre yönlendir
        if (isLoggedIn && (isOnLogin || isOnSplash)) {
          return authViewModel.isAdmin ? '/admin' : '/member';
        }

        return null;
      },
      routes: [
        // ── Splash ──
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        // ── Login ──
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // ── Admin Rotaları ──
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'add-member',
              builder: (context, state) => const AddMemberScreen(),
            ),
            GoRoute(
              path: 'member/:uid',
              builder: (context, state) => MemberDetailScreen(
                memberUid: state.pathParameters['uid']!,
              ),
            ),
          ],
        ),

        // ── Üye Rotaları ──
        GoRoute(
          path: '/member',
          builder: (context, state) => const MemberHomeScreen(),
        ),
        GoRoute(
          path: '/workout',
          builder: (context, state) => const WorkoutScreen(),
        ),
      ],
    );
  }
}
