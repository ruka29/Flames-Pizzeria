import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_orders.dart';
import '../services/styles_&_fn_handle.dart';
import 'dashboard.dart';
import 'order_detail.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<String> status = ['Pending', 'Approved', 'Ready', 'Collected', 'Cancelled'];
  final _orderFireStoreService = OrderFireStoreService();
  late Stream<QuerySnapshot> _orderStream;
  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    _orderStream = _orderFireStoreService.getOrdersStream();
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
      print('Error fetching item details: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
        title: const Text(
          "Orders",
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
                    page: const Dashboard(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined)),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: status.map((status) => Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: selectedStatus == status ? const Color.fromRGBO(197, 110, 51, 1.0) : Colors.white,
                        side: const BorderSide(
                          color: Color.fromRGBO(197, 110, 51, 1.0),
                          width: 1.0,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      child: Text(
                        status,
                        style: TextStyle(
                          color: selectedStatus == status ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),

            const Divider(),

            StreamBuilder<QuerySnapshot>(
              stream: _orderStream,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List orderList = snapshot.data!.docs;
                  switch (selectedStatus) {
                    case "Pending":
                      orderList = orderList.where((order) {
                        return order["status"] == "Pending";
                      }).toList();
                      break;
                    case "Approved":
                      orderList = orderList.where((order) {
                        return order["status"] == "Approved";
                      }).toList();
                      break;
                    case "Ready":
                      orderList = orderList.where((order) {
                        return order["status"] == "Ready";
                      }).toList();
                      break;
                    case "Collected":
                      orderList = orderList.where((order) {
                        return order["status"] == "Collected";
                      }).toList();
                      break;
                    case "Cancelled":
                      orderList = orderList.where((order) {
                        return order["status"] == "Cancelled";
                      }).toList();
                      break;
                    default:
                      null;
                  }

                  return  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = orderList[index];
                        String orderID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        int totalPrice = data['total'];
                        int totalQty = data['total qty'];
                        String status = data['status'];
                        String timeStamp = data['time stamp'];
                        String userID = data['userID'];

                        // Future<Map<String, dynamic>?> getUserName() async {
                        //   try {
                        //     final userRef = FirebaseFirestore.instance.collection('users').doc(userID);
                        //     final snapshot = await userRef.get();
                        //     return snapshot.data() as Map<String, dynamic>;
                        //   } catch (error) {
                        //     print('Error fetching item details: $error');
                        //     return null;
                        //   }
                        // }
                        //
                        // final userDetails = getUserName();
                        // final userName = userDetails.data();

                        Future<void> _confirmDelete() async {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
                                title: const Text('Confirm Delete'),
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
                                    onPressed: () {
                                      _orderFireStoreService.deleteOrder(orderID);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text('Order Deleted Successfully!'),
                                        ),
                                      );
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

                        return GestureDetector(
                          onLongPress: () {
                            status == "Collected" || status == "Canceled" ? _confirmDelete() : null;
                          },
                          onTap: (){
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: OrderDetails(data: data),
                              )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey[200],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Text(
                                          orderID,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),

                                        const Spacer(),

                                        Container(
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: status == "Pending" ? Colors.amber : status == "Approved" ? Colors.green : status == "Ready" ? Colors.blue : status == "Collected" ? Colors.grey[900] : Colors.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    Text(
                                        timeStamp
                                    ),

                                    Text(
                                      "Item count: $totalQty"
                                    ),

                                    Text(
                                      "Total: Rs.$totalPrice.00",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ]
                                ),
                              ),
                            )
                          ),
                        );
                      }
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(
                    color: Colors.black,
                  ));
                }
              }
            ),
          ],
        ),
      )
    );
  }

  //empty cart scaffold
  Center emptyOrders() {
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
            "No Orders Available",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0
            ),
          ),
        ],
      ),
    );
  }
}