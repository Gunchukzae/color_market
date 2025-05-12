import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_mode_provider.dart';

class PageProvider with ChangeNotifier {
  int _selectedPageIndex = -1;
  int get selectedPageIndex => _selectedPageIndex;

  void setPage(int index, BuildContext context) {
    _selectedPageIndex = index;

    final purchaseProvider = context.read<PurchaseModeProvider>();
    if (purchaseProvider.isActive) {
      purchaseProvider.deactivate();
    }

    notifyListeners();
  }

  void goHome() {
    _selectedPageIndex = -1;
    notifyListeners();
  }
}