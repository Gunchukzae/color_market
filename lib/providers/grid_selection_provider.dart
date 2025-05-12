import 'package:flutter/material.dart';

class GridSelectionProvider with ChangeNotifier {
  final List<Offset> _purchasedCells = [];
  Offset? _justPurchasedCell;

  List<Offset> get purchasedCells => _purchasedCells;
  Offset? get justPurchasedCell => _justPurchasedCell;

  void purchase(int i, int j) {
    final cell = Offset(i.toDouble(), j.toDouble());
    if (!_purchasedCells.contains(cell)) {
      _purchasedCells.add(cell);
      _justPurchasedCell = cell;
      notifyListeners();
    }
  }

  void clearHighlight() {
    _justPurchasedCell = null;
    notifyListeners();
  }
}
