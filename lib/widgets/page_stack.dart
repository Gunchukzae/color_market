import 'package:flutter/material.dart';
import '../providers/page_provider.dart';
import '../screens/cart_page.dart';

Widget buildPageStack(PageProvider pageProvider) {
  if (pageProvider.selectedPageIndex == -1) {
    return const SizedBox.shrink();
  }

  return Container(
    color: Colors.white,
    child: IndexedStack(
      index: pageProvider.selectedPageIndex,
      children: const [CartPage()],
    ),
  );
}
