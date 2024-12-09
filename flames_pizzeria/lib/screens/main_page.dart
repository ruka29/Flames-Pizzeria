import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../custom widgets/cart_button.dart';
import '../services/styles_&_fn_handle.dart';
import 'cart.dart';
import 'home_page.dart';
import 'menu_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _pageController = PageController();

  @override
  void initState() {
    super.initState();
    getCartItemCount();
  }

  Future<void> getCartItemCount() async {
    final QuerySnapshot cartSnapshot = await FirebaseFirestore.instance.collection("users").doc(globalUserId).collection("cart").get();

    final List<DocumentSnapshot> cartDocuments = cartSnapshot.docs;

    int totalQuantity = 0;
    for (var item in cartDocuments) {
      totalQuantity += item['qty'] as int;
    }
    globalCartItemCount = totalQuantity;
  }

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
    HomePage(onTapCategory: goToMenuPage,),
    const MenuPage(), // Your menu page
    Cart(onTapCategory: goToMenuPage,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (i) {
          setState(() {
            globalCurrentPage = i;
          });
        },
        controller: _pageController,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: FlashyTabBar(
            height: 55.0,
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
                icon: CartButton(cartItemCount: globalCartItemCount,),
                title: const Text(
                  'Cart',
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
