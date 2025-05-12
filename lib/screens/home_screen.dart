import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/cart_page.dart';
import '../providers/page_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_interactive_grid.dart';
import '../widgets/page_stack.dart';
import '../widgets/home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> pages = const [
    CartPage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);

    return PopScope(
      canPop: pageProvider.selectedPageIndex == -1,
      onPopInvoked: (didPop) {
        if (!didPop && pageProvider.selectedPageIndex != -1) {
          pageProvider.goHome();
        }
      },
      child: Scaffold(
        appBar: buildHomeAppBar(context),
        body: Stack(
          children: [
            const InteractiveGrid(),
            buildPageStack(pageProvider),
          ],
        ),
        bottomNavigationBar: buildBottomBar(context, pageProvider),
      ),
    );
  }
}