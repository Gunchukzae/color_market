import 'package:flutter/material.dart';

class CoinProvider with ChangeNotifier {
  int _coins = 0;
  int get coins => _coins;

  void increment() {
    _coins++;
    notifyListeners();
  }

  void spend(int amount) {
  if (_coins >= amount) {
    _coins -= amount;
    notifyListeners();
  }
}
}