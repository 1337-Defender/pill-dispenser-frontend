// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/dispenser_config_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/history_provider.dart';
import 'providers/wallet_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
    return MaterialApp.router(
      title: 'Smart Pill Dispenser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(color: Colors.blue),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      // home: const HomeScreen(),
      // initialRoute: '/login',
      // routes: {
      //   '/': (ctx) => const HomeScreen(),
      //   '/login': (ctx) => LoginScreen(),
      //   '/dashboard': (ctx) => const DashboardScreen(),
      //   '/add_medication': (ctx) => AddMedicationScreen(),
      //   '/wallet': (ctx) => WalletScreen(),
      //   '/history': (ctx) => DispensingHistoryScreen(),
      //   '/loyalty_points': (ctx) => LoyaltyPointsScreen(),
      // },
      routerConfig: AppRouter.router,
    );
  }
}