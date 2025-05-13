import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pill_dispenser/screens/auth/auth_settings_popover.dart';
import 'package:pill_dispenser/screens/dashboard.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/wallet_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _navigateBottombar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Dashboard(),
    Scaffold(body: Text('Vinit')),
    Scaffold(body: Text('Veron')),
    Scaffold(body: Text('Shashank')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 243, 244),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GNav(
            onTabChange: (index) => _navigateBottombar(index),
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabMargin: EdgeInsets.symmetric(horizontal: 0),
            tabBackgroundColor: Color.fromARGB(255, 239, 255, 61),
            tabs: [
              GButton(icon: LucideIcons.house, text: 'Home'),
              GButton(icon: LucideIcons.settings, text: 'Configuration'),
              GButton(icon: LucideIcons.calendarCheck, text: 'Schedule'),
              GButton(icon: LucideIcons.store, text: 'Pharmacy'),
              // GButton(icon: LucideIcons.wallet, text: 'Wallet')
            ],
          ),
        ),
      ),
      appBar: AppBar(
        // title: const Text('Smart Pill Dispenser'),
        elevation: 0,
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notifications Icon
                Material(
                  color: Color(0x00000000),
                  borderRadius: BorderRadius.circular(64),
                  child: IconButton(
                    onPressed: () => context.push('/loyalty_points'),
                    icon: const Icon(LucideIcons.bell, size: 24),
                    tooltip: 'Loyalty Points',
                  ),
                ),
                const SizedBox(width: 8), // Space between icons
                // Account Icon
                Builder(
                  builder: (context) {
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(64),
                      child: IconButton(
                        tooltip: 'Account',
                        icon: const Icon(LucideIcons.userRound, size: 24),
                        onPressed:
                            () => showPopover(
                              width: 100,
                              height: 100,
                              backgroundColor: Colors.white,
                              context: context,
                              bodyBuilder: (context) => AuthSettingsPopover(),
                            ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.push('/add_medication'),
      //   label: const Text("Add Medication"),
      //   icon: const Icon(Icons.add),
      // ),
    );
  }
}
