import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/styles_&_fn_handle.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ItemDetailPage({super.key, required this.data});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String itemID = '';
  String itemName = '';
  String imageURL = '';
  String ingredients = '';
  String price = '';
  String regularPrice = '';
  String mediumPrice = '';
  String largePrice = '';
  String category = '';
  String _selectedSize = 'medium';
  int intPrice = 0;
  int qty = 1;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    itemID = widget.data['itemID'] ?? '';
    itemName = widget.data['item name'] ?? '';
    imageURL = widget.data['imageURL'] ?? '';
    ingredients = widget.data['ingredients'] ?? '';
    category = widget.data['category'] ?? '';
    price = widget.data['price'] ?? '';
    regularPrice = widget.data['regularPrice'] ?? '';
    mediumPrice = widget.data['mediumPrice'] ?? '';
    largePrice = widget.data['largePrice'] ?? '';
  }

  Future<void> addItemToCart() async {
    if(globalUserId.isNotEmpty) {
      try {
        final cart = FirebaseFirestore.instance.collection('users').doc(globalUserId).collection('cart').doc(category == "pizza" ? itemID + _selectedSize : itemID);

        final item = await cart.get();

        if(item.exists) {
          final existQty = item.data()?['qty'];
          final updatedQty = existQty + qty;

          final existPrice = item.data()?['price'];
          final updatedPrice = existPrice + totalPrice;

          cart.update({
            'qty': updatedQty,
            'price': updatedPrice
          });
        } else {
          await cart.set({
            'itemID': itemID,
            'item name': itemName,
            'qty': qty,
            'price': totalPrice,
            'size': category == "pizza" ? _selectedSize : ''
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Item added to cart!'),
          ),
        );

        Navigator.pop(context);
      } catch(e) {
        print(e);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
          title: const Text('Error'),
          content: const Text('Sign in required!'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(category == "pizza") {
      switch (_selectedSize) {
        case "regular":
          intPrice = int.parse(regularPrice);
          break;
        case "medium":
          intPrice = int.parse(mediumPrice);
          break;
        case "large":
          intPrice = int.parse(largePrice);
          break;
        default:
          null;
      }
    } else {
      intPrice = int.parse(price);
    }
    totalPrice = (intPrice * qty);

    return Scaffold(
      appBar: AppBar(),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 350.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageURL),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                ingredients
              ),
            ),

            const SizedBox(height: 20.0,),

            category == "pizza"
                ?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: pizzaPrices(),
            )
                :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "LKR $price.00",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    color: qty == 1 ? Colors.grey : Colors.black,
                    onPressed: () {
                      if(qty <= 1) {
                        null;
                      } else {
                        setState(() {
                          qty--;
                        });
                      }
                    },
                    icon: const Icon(
                        Icons.remove,
                      size: 30.0,
                    )
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "$qty",
                      style: const TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                  ),

                  IconButton(
                    color: Colors.black,
                    onPressed: () {
                      setState(() {
                        qty++;
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 30.0,
                    )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                  minimumSize: const Size.fromHeight(65),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                onPressed: addItemToCart,
                child: Text(
                  "LKR $totalPrice | Add",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Container pizzaPrices() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Select your desired size"
          ),

          Column(
            children: [
              Row(
                children: [
                  Radio<String>(
                    activeColor: const Color.fromRGBO(197, 110, 51, 1.0),
                    value: 'regular',
                    groupValue: _selectedSize,
                    onChanged: (value) => setState(() => _selectedSize = value!),
                  ),

                  const Text("Regular"),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      "LKR $regularPrice",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),

              Row(
                children: [
                  Radio<String>(
                    activeColor: const Color.fromRGBO(197, 110, 51, 1.0),
                    value: 'medium',
                    groupValue: _selectedSize,
                    onChanged: (value) => setState(() => _selectedSize = value!),
                  ),

                  const Text("Medium"),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      "LKR $mediumPrice",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),

              Row(
                children: [
                  Radio<String>(
                    activeColor: const Color.fromRGBO(197, 110, 51, 1.0),
                    value: 'large',
                    groupValue: _selectedSize,
                    onChanged: (value) => setState(() => _selectedSize = value!),
                  ),

                  const Text("Large"),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      "LKR $largePrice",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
