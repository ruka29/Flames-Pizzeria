import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  final int cartItemCount;

  const CartButton({required this.cartItemCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Color.fromRGBO(197, 110, 51, 1.0),
          ),
        ),
        Positioned(
          // Position the badge on the top right of the icon
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.all(2.0), // Adjust padding as needed
            decoration: BoxDecoration(
              color: Colors.red, // Badge color
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                cartItemCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0, // Adjust font size as needed
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}