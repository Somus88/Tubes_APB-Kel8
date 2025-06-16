import 'package:flutter/material.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/account_page.dart';
import 'package:tubes_progress/pages/home_page.dart';
import 'package:tubes_progress/pages/order_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [HomePage(), OrderPage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return PageComp(
      child: IndexedStack(index: selectedIndex, children: pages),
      showBottomNavbar: true,
      selectedIndex: selectedIndex,
      onNavTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}
