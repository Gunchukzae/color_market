import 'package:flutter/material.dart';

class PurchaseModeProvider with ChangeNotifier {
  bool _isActive = false;
  bool get isActive => _isActive;

  void toggle() {
    _isActive = !_isActive;
    notifyListeners();
  }

  void deactivate() {
    _isActive = false;
    notifyListeners();
  }
}
