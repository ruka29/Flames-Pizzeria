import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/firestore_orders.dart';

class OrderDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const OrderDetails({super.key, required this.data});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _orderFireStoreService = OrderFireStoreService();
  late Stream<QuerySnapshot> _orderStream;
  String orderID = '';
  int totalPrice = 0;
  int totalQty = 0;
  String status = '';
  String userID = '';
  String firstName = '';
  String lastName = '';
  String address = '';
  String mobileNumber = '';

  @override
  void initState() {
    super.initState();
    orderID = widget.data['orderID'] ?? '';
    totalPrice = widget.data['total'];
    totalQty = widget.data['total qty'];
    status = widget.data['status'] ?? '';
    userID = widget.data['userID'] ?? '';

    _getUserDetails();
    _orderStream = _orderFireStoreService.getItemsStream(orderID);
  }

  Future<void> _getUserDetails() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      setState(() {
        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        address = userData['address'] ?? '';
        mobileNumber = userData['mobileNumber'] ?? '';
      });
    } else {
      print('User document not found');
    }
  }

  Future<void> updateStatus() async {
    final order = FirebaseFirestore.instance.collection('orders').doc(orderID);

    await order.update({
      'status': status
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Order $status!'),
      ),
    );

    Navigator.of(context).pop();
  }

  Future<void> confirmCancel() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
          title: const Text(
              "Cancel Order"
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel this order?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
              ),
              onPressed: () {
                setState(() {
                  status = "Cancelled";
                });
                updateStatus();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes',
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
                Navigator.of(context).pop();
              },
              child: const Text(
                'No',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Order ID"
                          ),

                          Text(
                            orderID,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == "Pending" ? Colors.amber : status == "Approved" ? Colors.green : status == "Ready" ? Colors.blue : status == "Collected" ? Colors.grey : Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),

                  const Divider(),

                  const Text(
                    "Customer Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Customer name:\n   $firstName $lastName"
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        "Address:\n   $address"
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        "Mobile:\n   $mobileNumber"
                    ),
                  ),

                  const Divider(),

                  const Text(
                    "Order Details",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: _orderStream,
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        final itemList = snapshot.data!.docs;

                        List<Widget> itemWidgets = [];
                        for (var doc in itemList) {
                          final itemData = doc.data()! as Map<String, dynamic>;
                          itemWidgets.add(_buildOrderTile(itemData));
                        }

                        // Display the list of order widgets
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                    "Item Count: $totalQty"
                                ),
                              ),

                              Column(
                                children: itemWidgets,
                              ),

                              Container(
                                child: Column(
                                  children: [
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
                              )
                            ],
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
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              children: [
                if(status == "Pending" || status == "Approved" || status == "Ready")
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, right: 5.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: status == "Pending" || status == "Approved" || status == "Ready" ? const Size.fromHeight(65) : null,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0,),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if(status == "Pending") {
                            status = "Approved";
                          } else if (status == "Approved") {
                            status = "Ready";
                          } else {
                            status = "Collected";
                          }
                        });
                        updateStatus();
                      },
                      child: Text(
                        status == "Pending" ? "Approve Order" : status == "Approved" ? "Order Ready" : "Collected",
                        style: const TextStyle(fontSize: 18.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),

                if (status == "Pending")
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 5.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size.fromHeight(65),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0,),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onPressed: () {
                        confirmCancel();
                      },
                      child: const Text(
                        "Cancel Order",
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOrderTile(Map<String, dynamic> itemData) {
    final itemName = itemData['item name'];
    final size = itemData['size'];
    final qty = itemData['qty'];
    final price = itemData['price'];

    return Column(
      children: [
        Row(
          children: <Widget>[
            Text(
              itemName,
              style: const TextStyle(
                  fontSize: 17.0
              ),
            ),

            if(size.isNotEmpty)
              Text(
                  " ($size)"
              ),

            const SizedBox(width: 10.0,),

            const Text(
                "X"
            ),

            const SizedBox(width: 10.0,),

            Text(
              "$qty",
              style: const TextStyle(
                  fontSize: 17.0
              ),
            ),

            const Spacer(),

            Text(
                "Rs. $price.00"
            ),
          ],
        ),
      ],
    );
  }
}
