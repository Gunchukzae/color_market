import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../providers/purchase_mode_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/icons.dart';

Widget buildBottomBar(BuildContext context, PageProvider pageProvider) {
  if (pageProvider.selectedPageIndex != -1) return const SizedBox.shrink();

  return Container(
    height: 80.0,
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => context.read<PageProvider>().setPage(0, context),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(AppIcons.cart), Text('카트')],
          ),
        ),
        Consumer<PurchaseModeProvider>(
          builder: (context, purchaseProvider, _) {
            final isActive = purchaseProvider.isActive;
            return GestureDetector(
              onTap: () => purchaseProvider.toggle(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.star, color: isActive ? Colors.orange : Colors.grey),
                  const SizedBox(height: 3),
                  const Text('구매하기', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
        const MoneyEarnIcon(),
      ],
    ),
  );
}

class MoneyEarnIcon extends StatefulWidget {
  const MoneyEarnIcon({super.key});

  @override
  State<MoneyEarnIcon> createState() => _MoneyEarnIconState();
}

class _MoneyEarnIconState extends State<MoneyEarnIcon> {
  Color iconColor = Colors.grey;

  void _animateColor() async {
    setState(() {
      iconColor = Colors.amber;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      iconColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CoinProvider>().increment();
        _animateColor();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_money, color: iconColor), // 또는 AppIcons.coin
          const Text('돈벌기'),
        ],
      ),
    );
  }
}