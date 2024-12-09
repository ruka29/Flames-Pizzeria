import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_items.dart';
import '../services/styles_&_fn_handle.dart';
import 'item_detail_page.dart';
import 'profile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<String> categories = ['All', 'Bestsellers', 'Pizza', 'Burger', 'Submarine', 'Quesadilla', 'Combo', 'Beverages'];
  String _searchText = '';
  bool ascending = true;
  final _itemFireStoreService = ItemFireStoreService();
  late Stream<QuerySnapshot> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _itemFireStoreService.getItemsStream();
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Search items...',
        prefixIcon: Icon(Icons.search),
        labelStyle: TextStyle(
          color: Colors.black
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: Color.fromRGBO(197, 110, 51, 1.0)
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: Color.fromRGBO(197, 110, 51, 1.0)
          )
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
        title: const Text(
          "Menu",
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildSearchBar()
                  ),

                  const SizedBox(width: 10.0,),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        ascending = !ascending;
                      });
                    },
                    icon: Icon(ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
                  )
                ],
              ),
            ),

            const SizedBox(height: 10.0,),

            const Divider(
              color: Colors.black,
            ),

            const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text(
                "Categories",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(height: 5.0,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: globalSelectedCategory == category ? const Color.fromRGBO(197, 110, 51, 1.0) : Colors.white,
                      side: const BorderSide(
                        color: Color.fromRGBO(197, 110, 51, 1.0),
                        width: 1.0,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        globalSelectedCategory = category;
                      });
                    },
                    child: Text(
                      category,
                      style: TextStyle(
                        color: globalSelectedCategory == category ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 5.0,),

            const Divider(
              color: Colors.black,
            ),

            StreamBuilder<QuerySnapshot>(
              stream: _itemsStream,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List itemsList = snapshot.data!.docs;
                  if(globalSelectedCategory == "All") {
                    null;
                  } else {
                    switch (globalSelectedCategory) {
                      case "Bestsellers":
                        itemsList = itemsList.where((item) {
                          return item["bestseller"] == "true";
                        }).toList();
                        break;
                      case "Pizza":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "pizza";
                        }).toList();
                        break;
                      case "Burger":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "burger";
                        }).toList();
                        break;
                      case "Submarine":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "submarine";
                        }).toList();
                        break;
                      case "Quesadilla":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "quesadilla";
                        }).toList();
                        break;
                      case "Combo":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "combo";
                        }).toList();
                        break;
                      case "Beverages":
                        itemsList = itemsList.where((item) {
                          return item["category"] == "beverages";
                        }).toList();
                        break;
                      default:
                        null;
                    }
                  }
                  if (_searchText.isNotEmpty) {
                    itemsList = itemsList.where((item) {
                      final String itemText = item['item name'];
                      return itemText.toLowerCase().contains(_searchText.toLowerCase());
                    }).toList();
                  }
                  if(ascending) {
                    itemsList = itemsList.reversed.toList();
                  }
                  return  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = itemsList[index];
                        String itemID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String imageURL = data['imageURL'];
                        String itemName = data['item name'];
                        String ingredients = data['ingredients'];
                        final price = data['price'];
                        final mediumPrice = data['mediumPrice'];
                        String category = data['category'];
                        String bestseller = data['bestseller'];

                        // bool isItemAdd = false;
                        // int existQty = 1;

                        // @override
                        // void initState() async {
                        //   super.initState();
                        //   final item = await cart.get();
                        //
                        //   if(item.exists){
                        //     setState(() {
                        //       isItemAdd = true;
                        //       existQty = item.data()?['qty'];
                        //     });
                        //   }
                        // }

                        // Future<void> addItemToCart() async {
                        //   if(globalUserId.isNotEmpty) {
                        //     final cart = FirebaseFirestore.instance.collection('users').doc(globalUserId).collection('cart').doc(category == "pizza" ? "${itemID}medium" : itemID);
                        //     setState(() {
                        //       isItemAdd = true;
                        //     });
                        //     try {
                        //       await cart.set({
                        //         'price': category == "pizza" ? int.parse(mediumPrice) : int.parse(price),
                        //         'itemID': itemID,
                        //         'item name': itemName,
                        //         'qty': 1,
                        //         'size': category == "pizza" ? "medium" : ''
                        //       });
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           backgroundColor: Colors.green,
                        //           content: Text('Item added to cart!'),
                        //         ),
                        //       );
                        //     } catch(e) {
                        //       print(e);
                        //     }
                        //   } else {
                        //     showDialog(
                        //       context: context,
                        //       builder: (context) => AlertDialog(
                        //         backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
                        //         title: const Text('Error'),
                        //         content: const Text('Sign in required!'),
                        //         actions: [
                        //           TextButton(
                        //             style: TextButton.styleFrom(
                        //               backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                        //             ),
                        //             onPressed: () => Navigator.of(context).pop(),
                        //             child: const Text(
                        //               'OK',
                        //               style: TextStyle(
                        //                   color: Colors.white
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   }
                        // }

                        // Future<void> itemPlus() async {
                        //   final updatedQty = existQty + 1;
                        //   cart.update({
                        //     'qty': updatedQty
                        //   });
                        // }
                        //
                        // Future<void> itemMinus() async {
                        //   if(existQty == 1) {
                        //     cart.delete();
                        //   } else {
                        //     final updatedQty = existQty - 1;
                        //     cart.update({
                        //       'qty': updatedQty
                        //     });
                        //   }
                        // }

                        Future<void> addItemToCart() async {
                          if(globalUserId.isNotEmpty) {
                            final cart = FirebaseFirestore.instance.collection('users').doc(globalUserId).collection('cart').doc(category == "pizza" ? "${itemID}medium" : itemID);

                            final item = await cart.get();

                            try {
                              if(item.exists) {
                                final existQty = item.data()?['qty'];
                                final updatedQty = existQty + 1;

                                final itemPrice = category == "pizza" ? int.parse(mediumPrice) : int.parse(price);
                                final existPrice = item.data()?['price'];
                                final updatedPrice = existPrice + itemPrice;

                                await cart.update({
                                  'qty': updatedQty,
                                  'price': updatedPrice
                                });
                              } else {
                                await cart.set({
                                  'price': category == "pizza" ? int.parse(mediumPrice) : int.parse(price),
                                  'itemID': itemID,
                                  'item name': itemName,
                                  'qty': 1,
                                  'size': category == "pizza" ? "medium" : ''
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('Item added to cart!'),
                                ),
                              );
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

                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: ItemDetailPage(data: data),
                                )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 300.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: NetworkImage(imageURL),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 300.0,
                                  width: screenWidth - 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black.withOpacity(0.8), Colors.white.withOpacity(0.0)],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if(bestseller == "true")
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5.0),
                                                color: Colors.grey[200],
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                                                child: Text(
                                                  "BESTSELLER",
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),

                                        Text(
                                          itemName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0
                                          ),
                                        ),

                                        Text(
                                          ingredients,
                                          style: const TextStyle(
                                              color: Colors.white
                                          ),
                                        ),

                                        const Divider(),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              children: [
                                                Text(
                                                  mediumPrice.isEmpty ? "LKR $price.00" : "LKR $mediumPrice.00",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20.0
                                                  ),
                                                ),

                                                if(mediumPrice.isNotEmpty)
                                                  const Text(
                                                    "(Medium price)",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.0
                                                    ),
                                                  )
                                              ],
                                            ),

                                            // isItemAdd == true
                                            //     ?
                                            // Row(
                                            //   children: <Widget>[
                                            //     IconButton(
                                            //         color: Colors.white,
                                            //         onPressed: itemMinus,
                                            //         icon: const Icon(
                                            //           Icons.remove,
                                            //           size: 30.0,
                                            //         )
                                            //     ),
                                            //
                                            //     Padding(
                                            //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            //       child: Text(
                                            //         "$existQty",
                                            //         style: const TextStyle(
                                            //             fontSize: 18.0,
                                            //             color: Colors.white
                                            //         ),
                                            //       ),
                                            //     ),
                                            //
                                            //     IconButton(
                                            //         color: Colors.white,
                                            //         onPressed: itemPlus,
                                            //         icon: const Icon(
                                            //           Icons.add,
                                            //           size: 30.0,
                                            //         )
                                            //     ),
                                            //   ],
                                            // )
                                            //     :
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await addItemToCart();
                                                },
                                                child: const Text(
                                                  "Add",
                                                  style: TextStyle(
                                                      color: Colors.white
                                                  ),
                                                )
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.black,));
                }
              }
            )
          ],
        ),
      )
    );
  }
}
