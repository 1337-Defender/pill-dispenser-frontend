// app_router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pill_dispenser/screens/auth/device_registration_screen.dart';
import 'package:pill_dispenser/screens/home_screen.dart';
import 'package:pill_dispenser/screens/medications/add_medications_screen.dart';
import 'package:pill_dispenser/screens/wallet/loyalty_points_screen.dart';
import 'package:pill_dispenser/screens/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screen widgets
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
// import 'features/auth/screens/signup_screen.dart';
// import 'features/auth/screens/device_registration_screen.dart';
import '/screens/splash_screen.dart'; // Example splash

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  static GoRouter get router => _router;

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // If you have nested navigation, define keys for them too

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: RouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authStatus = authProvider.authStatus;
      final currentLoc = state.matchedLocation; // Current path

      // Debug print (optional, remove in production)
      // print('Redirect: currentLoc: $currentLoc, authStatus: $authStatus');

      // 1. If auth state is still unknown or actively authenticating,
      //    stay on splash screen (or go to it if somehow navigated away too early).
      if (authStatus == AuthStatus.unknown || authStatus == AuthStatus.authenticating) {
        return currentLoc == '/splash' ? null : '/splash';
      }

      // 2. If user is authenticated:
      if (authStatus == AuthStatus.authenticated) {
        // If they are on splash, login, or signup, redirect them to the dashboard.
        if (currentLoc == '/splash' || currentLoc == '/login' || currentLoc == '/signup' /* || currentLoc == '/register-device' (if you add it back) */) {
          // TODO: You might want to add a check here in the future:
          // if the user needs to register a device and hasn't, send them to '/register-device'
          // For now, we go straight to dashboard.
          return '/dashboard';
        }
        // Otherwise, they are on an authenticated page, no redirect needed.
        return null;
      }

      // 3. If user is unauthenticated:
      if (authStatus == AuthStatus.unauthenticated) {
        // If they are already on login or signup, no redirect needed.
        if (currentLoc == '/login' || currentLoc == '/signup') {
          return null;
        }
        // Otherwise (e.g., on splash or trying to access an authenticated route), send to login.
        return '/login';
      }

      // Should not be reached if all AuthStatus values are handled
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen()
      ),
      GoRoute(
        path: '/login',
        // builder: (context, state) => LoginScreen(),
        builder: (context, state) => AuthScreen()
      ),
      GoRoute(
        path: '/register-device',
        builder: (context, state) => DeviceRegistrationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => HomeScreen(), // Your main authenticated screen
        // Add more authenticated routes as children or at this level
      ),
      GoRoute(
        path: '/loyalty_points',
        builder: (context, state) => LoyaltyPointsScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => WalletScreen(),
      ),
      GoRoute(
        path: '/add_medication',
        builder: (context, state) => AddMedicationScreen(),
      )
      // ... other routes
    ],
  );
}

// Helper class to listen to Supabase auth stream for go_router refresh
class RouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  RouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}