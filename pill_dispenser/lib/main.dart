// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/medications/add_medications_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/history/dispensing_history_screen.dart';
import 'screens/wallet/loyalty_points_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/dispenser_config_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/history_provider.dart';
import 'providers/wallet_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DispenserConfigProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pill Dispenser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(color: Colors.blue),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // home: const HomeScreen(),
      initialRoute: '/login',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/login': (ctx) => LoginScreen(),
        '/dashboard': (ctx) => const DashboardScreen(),
        '/add_medication': (ctx) => AddMedicationScreen(),
        '/wallet': (ctx) => WalletScreen(),
        '/history': (ctx) => DispensingHistoryScreen(),
        '/loyalty_points': (ctx) => LoyaltyPointsScreen(),
      },
    );
  }
}