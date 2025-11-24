import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/birthdays/presentation/birthday_list_page.dart';
import '../../features/contributions/presentation/contribution_page.dart';
import '../../features/points/presentation/points_page.dart';
import '../../features/admin/presentation/admin_config_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/profile/presentation/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'birthdays',
            name: 'birthdays',
            builder: (context, state) => const BirthdayListPage(),
          ),
          GoRoute(
            path: 'contribute',
            name: 'contribute',
            builder: (context, state) => const ContributionPage(),
          ),
          GoRoute(
            path: 'points',
            name: 'points',
            builder: (context, state) => const PointsPage(),
          ),
          GoRoute(
            path: 'admin-config',
            name: 'admin-config',
            builder: (context, state) => const AdminConfigPage(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
  );
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();
