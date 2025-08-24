import 'package:flutter/material.dart';
import '../providers/page_provider.dart';

Widget buildPageStack(PageProvider pageProvider, List<Widget> pages) {
  if (pageProvider.selectedPageIndex == -1) {
    return const SizedBox.shrink();
  }

  return Container(
    color: Colors.white,
    child: IndexedStack(
      index: pageProvider.selectedPageIndex,
      children: pages,
    ),
  );
}