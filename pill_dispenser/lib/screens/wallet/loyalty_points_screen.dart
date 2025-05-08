// lib/screens/wallet/loyalty_points_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loyalty Points"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_activity, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              "You have ${walletProvider.loyaltyPoints} loyalty points",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                walletProvider.addLoyaltyPoints(10);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Earned 10 loyalty points!")),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Earn 10 Points (Demo)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate using loyalty points
                if (walletProvider.loyaltyPoints >= 50) {
                  walletProvider.addLoyaltyPoints(-50);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("Redeemed 50 loyalty points!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("Not enough loyalty points to redeem.")),
                  );
                }
              },
              icon: const Icon(Icons.remove),
              label: const Text("Redeem 50 Points (Demo)"),
            ),
          ],
        ),
      ),
    );
  }
}