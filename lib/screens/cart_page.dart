import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grid_selection_provider.dart';
import '../constants/color_item_info.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final purchasedCells = context.watch<GridSelectionProvider>().purchasedCells;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchasedCells.length,
      itemBuilder: (context, index) {
        final cell = purchasedCells[index];
        final i = cell.dx.toInt();
        final j = cell.dy.toInt();
        final info = colorStyleGrid[i][j];

       return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(
              info.symbol,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: info.color),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    info.desc,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

