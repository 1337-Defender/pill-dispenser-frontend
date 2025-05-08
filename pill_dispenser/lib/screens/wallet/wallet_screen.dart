// lib/screens/wallet/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Wallet")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Balance: \$${walletProvider.balance.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "Loyalty Points: ${walletProvider.loyaltyPoints}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                walletProvider.deductBalance(10.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Deducted \$10 from wallet")),
                );
              },
              child: Text("Buy Medication (\$10)"),
            ),
          ],
        ),
      ),
    );
  }
}