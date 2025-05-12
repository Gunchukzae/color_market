import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_mode_provider.dart';
import '../providers/grid_selection_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/notification_provider.dart';
import '../constants/color_item_info.dart';
import '../constants/keys.dart';
import '../utils/notification_utils.dart';

class InteractiveGrid extends StatelessWidget {
  const InteractiveGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = 5;
    const cols = 4;

    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      minScale: 1.0,
      maxScale: 5.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / cols;
          final cellHeight = constraints.maxHeight / rows;

          return Stack(
            children: [
              for (int i = 0; i < rows; i++)
                for (int j = 0; j < cols; j++)
                  Positioned(
                    left: j * cellWidth,
                    top: i * cellHeight,
                    width: cellWidth,
                    height: cellHeight,
                    child: _buildGridCell(context, i, j),
                  ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildGridCell(BuildContext context, int i, int j) {
  final purchaseMode = context.watch<PurchaseModeProvider>().isActive;
  final gridProvider = context.watch<GridSelectionProvider>();
  final currentCell = Offset(i.toDouble(), j.toDouble());

  final isPurchased = gridProvider.purchasedCells.contains(currentCell);
  final isJustPurchased = gridProvider.justPurchasedCell == currentCell;
  final coinProvider = context.read<CoinProvider>();
  final colorInfo = colorStyleGrid[i][j];
  final price = colorInfo.price;
  final msgNotification = buildNotificationText(
            emoji: colorInfo.symbol,
            message: '을 구매하셨습니다',
            symbolColor: colorInfo.color,
            textColor: Colors.black,
          );

  Color borderColor;
  double borderWidth;

  if (purchaseMode) {
    if (isPurchased) {
      borderColor = Colors.red;
      borderWidth = isJustPurchased ? 3 : 2;
    } else {
      borderColor = Colors.orange;
      borderWidth = 1;
    }
  } else {
    borderColor = const Color.fromARGB(255, 207, 207, 207).withValues();
    borderWidth = 1;
  }

  return GestureDetector(
    onTap: () {
      if (!purchaseMode) return;

      final cell = Offset(i.toDouble(), j.toDouble());
      final alreadyPurchased = gridProvider.purchasedCells.contains(cell);

      if (alreadyPurchased) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('이미 구매한 상품입니다.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!alreadyPurchased) {
        if (coinProvider.coins >= price) {
          gridProvider.purchase(i, j);
          coinProvider.spend(price);
          context.read<NotificationProvider>().add(msgNotification);
          showBellNotification(context, msgNotification, bellKey);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('코인이 부족합니다!')),
          );
        }
      }
    },
    child: Stack(
  children: [
      Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Text(
            colorInfo.symbol,
            style: TextStyle(
              fontSize: 20,
              color: colorInfo.color,
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${colorInfo.price}p',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}