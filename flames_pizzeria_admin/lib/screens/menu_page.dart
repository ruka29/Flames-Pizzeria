import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_items.dart';
import '../services/styles_&_fn_handle.dart';
import 'dashboard.dart';
import 'item_update_page.dart';
import 'new_item.dart';

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
                              String price = data['price'];
                              String mediumPrice = data['mediumPrice'];
                              String category = data['category'];
                              String bestseller = data['bestseller'];

                              Future<void> confirmDelete() async {
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
                                            _itemFireStoreService.deleteItem(itemID);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text('Item Deleted Successfully!'),
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
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
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

                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        ),
                                                      ),
                                                      onPressed: confirmDelete,
                                                      child: Text(
                                                        "Remove",
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
                      return const Center(
                        child: Text(
                            "No items found on this category!"
                        ),
                      );
                    }
                  }
              )
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
        onPressed: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: const AddItem(),
            ),
          );
        },
        child: Icon(Icons.add, color: const Color.fromRGBO(197, 110, 51, 1.0),),
      ),
    );
  }
}
