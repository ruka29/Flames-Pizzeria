import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import '../custom widgets/order_button.dart';
import '../services/styles_&_fn_handle.dart';
import 'orders.dart';
import 'home_page.dart';
import 'menu_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _pageController = PageController();

  int _cartItemCount = 0;

  void goToMenuPage(String? category) {
    setState(() {
      globalSelectedCategory = category!;
    });
    _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear
    );
  }

  late List<Widget> _pages = [
    HomePage(onTapCategory: goToMenuPage,), // Your home page
    const MenuPage(), // Your menu page
    const Orders(), // Your cart page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: _pages,
        onPageChanged: (i) {
          setState(() {
            globalCurrentPage = i;
          });
        },
        controller: _pageController,
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: FlashyTabBar(
            animationCurve: Curves.linear,
            selectedIndex: globalCurrentPage,
            iconSize: 30,
            showElevation: false, // use this to remove appBar's elevation
            onItemSelected: (i) {
              setState(() {
                globalCurrentPage = i;
                _pageController.animateToPage(
                    globalCurrentPage,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear
                );
              });
            },

            items: [
              FlashyTabBarItem(
                icon: const Icon(
                  Icons.home,
                  color: Color.fromRGBO(197, 110, 51, 1.0),
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(
                      color: Color.fromRGBO(197, 110, 51, 1.0)
                  ),
                ),
              ),
              FlashyTabBarItem(
                icon: const Icon(
                  Icons.menu,
                  color: Color.fromRGBO(197, 110, 51, 1.0),
                ),
                title: const Text(
                  'Menu',
                  style: TextStyle(
                      color: Color.fromRGBO(197, 110, 51, 1.0)
                  ),
                ),
              ),
              FlashyTabBarItem(
                icon: CartButton(cartItemCount: _cartItemCount,),
                title: const Text(
                  'Orders',
                  style: TextStyle(
                      color: Color.fromRGBO(197, 110, 51, 1.0)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
