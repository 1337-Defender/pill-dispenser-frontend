import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/dispenser_config_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/history_provider.dart';
import 'providers/wallet_provider.dart';
import 'package:provider/provider.dart';

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
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}