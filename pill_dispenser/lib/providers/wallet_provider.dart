// lib/providers/wallet_provider.dart

import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 100.0;
  int _loyaltyPoints = 50;

  double get balance => _balance;
  int get loyaltyPoints => _loyaltyPoints;

  void deductBalance(double amount) {
    if (amount <= _balance) {
      _balance -= amount;
      notifyListeners();
    } else {
      print('Insufficient balance');
    }
  }

  void addLoyaltyPoints(int points) {
    _loyaltyPoints += points;
    notifyListeners();
  }

  void setBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}