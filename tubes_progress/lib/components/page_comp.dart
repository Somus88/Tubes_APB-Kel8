import 'package:flutter/material.dart';
import 'package:tubes_progress/components/bottom_navbar_comp.dart';
import 'package:tubes_progress/pages/account_page.dart';
import 'package:tubes_progress/pages/edit_profile_page.dart';
import 'package:tubes_progress/pages/home_page.dart';
import 'package:tubes_progress/pages/order_page.dart';
import 'package:tubes_progress/theme.dart';
import 'bottom_navbar_comp.dart'; // Import navbar

class PageComp extends StatelessWidget {
  final Widget child;
  final bool showBottomNavbar;
  final int selectedIndex;
  final Function(int)? onNavTap;
  final bool isScrollable;
  final bool showAppBar;
  final String appBarTitle;

  const PageComp({
    Key? key,
    required this.child,
    this.showBottomNavbar = false,
    this.selectedIndex = 0,
    this.onNavTap,
    this.isScrollable = true,
    this.showAppBar = false,
    this.appBarTitle = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content =
        isScrollable
            ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(padding: const EdgeInsets.all(16.0), child: child),
            )
            : Padding(padding: const EdgeInsets.all(16.0), child: child);

    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: Text(this.appBarTitle),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.blue[600],
              )
              : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundColorGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: content),
              if (showBottomNavbar)
                SizedBox(
                  height: 70,
                  child: BottomNavbarComp(
                    selectedIndex: selectedIndex,
                    onTap: (index) {
                      if (index == 0 && index != selectedIndex) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                        );
                      } else if (index == 1 && index != selectedIndex) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => OrderPage()),
                        );
                      } else if (index == 2 && index != selectedIndex) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AccountPage()),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
