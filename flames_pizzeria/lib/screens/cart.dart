import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_users.dart';
import '../services/styles_&_fn_handle.dart';
import '../services/toggle_screens.dart';
import 'checkout.dart';
import 'orders.dart';
import 'profile.dart';

class Cart extends StatefulWidget {
  final void Function(String category) onTapCategory;
  const Cart({super.key, required this.onTapCategory});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final _cartFireStoreService = FireStoreService();
  late Stream<QuerySnapshot> _cartStream;

  @override
  void initState() {
    super.initState();
    if(globalUserId.isNotEmpty){
      _cartStream = _cartFireStoreService.getCartStream();
    }
  }

  Future<Map<String, dynamic>?> getItemDetails(String itemID) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('items').doc(itemID);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (error) {
      // print('Error fetching item details: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
        title: const Text(
          "Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25.0
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const Profile(),
                  ),
                );
              },
            icon: const Icon(Icons.settings_outlined)),
          )
        ],
      ),

      body: globalUserId.isNotEmpty ?
      StreamBuilder<QuerySnapshot>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final cartList = snapshot.data!.docs;

            if (cartList.isEmpty) {
              return emptyCart();
            } else {
              int totalQuantity = 0;
              int totalPrice = 0;

              for (var item in cartList) {
                totalQuantity += item['qty'] as int;
                totalPrice += item['price'] as int;
              }
              globalCartItemCount = totalQuantity;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Text(
                      "Item Count: $totalQuantity",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: cartList.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot document = cartList[index];
                        final cartItemID = document.id;
                        final data = document.data()! as Map<String, dynamic>;
                        final existQty = data['qty'];
                        final existPrice = data['price'];
                        final size = data['size'];
                        final itemID = data['itemID'];
                        final itemDetailsFuture = getItemDetails(itemID);

                        final cart = FirebaseFirestore.instance.collection('users').doc(globalUserId).collection('cart').doc(cartItemID);

                        Future<void> confirmDelete() async {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
                                title: const Text(
                                  "Confirm Delete"
                                ),
                                content: const SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text('Are you sure you want to delete this item?'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                                    ),
                                    onPressed: () async {
                                      cart.delete();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          child: Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[200],
                            ),
                            child: FutureBuilder<Map<String, dynamic>?>(
                              future: itemDetailsFuture,
                              builder: (context, itemDetailsSnapshot) {
                                if (itemDetailsSnapshot.hasData) {
                                  final itemDetails = itemDetailsSnapshot.data!;
                                  String imageURL = itemDetails['imageURL'];
                                  String itemName = itemDetails['item name'];
                                  String ingredients = itemDetails['ingredients'];
                                  String price = itemDetails['price'];
                                  String regularPrice = itemDetails['regularPrice'];
                                  String mediumPrice = itemDetails['mediumPrice'];
                                  String largePrice = itemDetails['largePrice'];
                                  int intPrice = 0;

                                  if(size.isNotEmpty) {
                                    switch (size) {
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

                                  Future<void> itemPlus() async {
                                    final updatedQty = existQty + 1;
                                    final updatedPrice = existPrice + intPrice;
                                    cart.update({
                                      'qty': updatedQty,
                                      'price': updatedPrice
                                    });
                                  }

                                  Future<void> itemMinus() async {
                                    if(existQty == 1) {
                                      confirmDelete();
                                    } else {
                                      final updatedQty = existQty - 1;
                                      final updatedPrice = existPrice - intPrice;
                                      cart.update({
                                        'qty': updatedQty,
                                        'price': updatedPrice
                                      });
                                    }
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Image.network(
                                          imageURL,
                                          width: 125.0,
                                          height: 125.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              size.isEmpty ? itemName : "$itemName ($size)",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),

                                            const SizedBox(height: 5.0,),

                                            Text(
                                              ingredients,
                                            ),

                                            const SizedBox(height: 13.0,),

                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    border: Border.all(
                                                      color: Colors.black, // Change the color to green
                                                      width: 1.0, // Change the thickness to 2.0 pixels
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: itemMinus,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(3.0),
                                                          child: Icon(
                                                            existQty == 1 ? Icons.delete_outline_rounded : Icons.remove,
                                                            size: 25.0,
                                                          ),
                                                        ),
                                                      ),

                                                      const Divider(thickness: 1.0,),

                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text(
                                                          "$existQty",
                                                          style: const TextStyle(
                                                              fontSize: 18.0
                                                          ),
                                                        ),
                                                      ),

                                                      const Divider(thickness: 1.0,),

                                                      GestureDetector(
                                                        onTap: itemPlus,
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(3.0),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 25.0,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),

                                                const Spacer(),

                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Text(
                                                    "LKR $existPrice",
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (itemDetailsSnapshot.hasError) {
                                  return Text('Error: ${itemDetailsSnapshot.error}');
                                } else {
                                  return const Center(child: CircularProgressIndicator(color: Colors.black,));
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        const Text(
                          "Total"
                        ),

                        const Spacer(),

                        Text(
                          "Rs. $totalPrice.00"
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, right: 15.0, left: 15.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                        minimumSize: const Size.fromHeight(65),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                              page: const CheckOut(),
                            )
                        );
                      },
                      child: const Text(
                        "Check Out",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          }
        },
      ) : unregistered()
    );
  }

  //empty cart scaffold
  Center emptyCart() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/empty cart.jpg",
              height: 200,
            ),

            const SizedBox(height: 10.0,),

            const Text(
              "Oh oh! Your cart is empty!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0
              ),
            ),

            const SizedBox(height: 10.0,),

            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: () {
                widget.onTapCategory("Bestsellers");
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Text(
                  "Explore Menu",
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10.0,),

            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const Orders(),
                  )
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Text(
                  "Order History",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white
                  ),
                ),
              ),
            )
          ],
        ),
      );
  }

  //unregistered user
  Center unregistered() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Please Sign in!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const ToggleScreens(),
                    )
                  );
                  setState(() {
                    globalCurrentPage = 0;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        )
      );
  }
}
