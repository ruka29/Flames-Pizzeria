import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firestore_users.dart';
import '../services/styles_&_fn_handle.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final _cartFireStoreService = FireStoreService();
  late Stream<QuerySnapshot> _cartStream;

  @override
  void initState() {
    super.initState();
    _cartStream = _cartFireStoreService.getCartStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Check Out",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25.0
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final cartList = snapshot.data!.docs;

            int totalQuantity = 0;
            int totalPrice = 0;

            for (var item in cartList) {
              totalQuantity += item['qty'] as int;
              totalPrice += item['price'] as int;
            }

            String generateUniqueId() {
              final now = DateTime.now();
              return '${now.millisecondsSinceEpoch}-${Random().nextInt(10000)}';
            }
            final orderId = generateUniqueId();

            Future<void> placeOrder() async {
              final order = FirebaseFirestore.instance.collection('orders').doc(orderId);
              final cart = FirebaseFirestore.instance.collection('users').doc(globalUserId).collection('cart');
              final cartSnapshot = await cart.get();

              final batch = FirebaseFirestore.instance.batch();

              Timestamp timestamp = Timestamp.now();

              DateTime dateTime = timestamp.toDate();

              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

              try {
                batch.set(order, {
                  'orderID': orderId,
                  'userID': globalUserId,
                  'total': totalPrice,
                  'total qty': totalQuantity,
                  'status': "Pending",
                  'time stamp': "$formattedDate $formattedTime",
                });

                for (var itemDoc in cartSnapshot.docs) {
                  final itemData = itemDoc.data();
                  final item = order.collection('items').doc(itemData['itemID'] + itemData['size']);
                  batch.set(item, itemData);
                }

                await batch.commit();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Order Placed Successfully!'),
                  ),
                );

                for (var itemDoc in cartSnapshot.docs) {
                  await itemDoc.reference.delete();
                }

                Navigator.pop(context);
              } catch (e) {
                print('Error placing order: $e');
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartList.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot document = cartList[index];
                        final cartItemID = document.id;
                        final data = document.data()! as Map<String, dynamic>;
                        final qty = data['qty'];
                        final price = data['price'];
                        final size = data['size'];
                        final itemID = data['itemID'];
                        final itemName = data['item name'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        width: 250.0,
                                        child: Text(
                                          itemName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0
                                          ),
                                        ),
                                      ),

                                      if(size.isNotEmpty)
                                        Text(
                                          "($size)"
                                        )
                                    ],
                                  ),

                                  const SizedBox(width: 10.0,),

                                  const Text(
                                    "X"
                                  ),

                                  const SizedBox(width: 10.0,),

                                  Text(
                                    "$qty",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    "Rs. $price.00"
                                  ),
                                ],
                              ),

                              const Divider()
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              const Text(
                                  "Item Count"
                              ),

                              const Spacer(),

                              Text(
                                  "$totalQuantity"
                              ),
                            ],
                          ),

                          const Divider(),

                          Row(
                            children: <Widget>[
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0
                                )
                              ),

                              const Spacer(),

                              Text(
                                "Rs. $totalPrice.00",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
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
                      onPressed: placeOrder,
                      child: const Text(
                        "Place Order",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text(
              "Something went wrong!"
            );
          }
        }
      ),
    );
  }
}
