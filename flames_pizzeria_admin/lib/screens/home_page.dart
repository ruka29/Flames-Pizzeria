import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';

import '../services/firestore_items.dart';
import '../services/styles_&_fn_handle.dart';
import 'dashboard.dart';

class HomePage extends StatefulWidget {
  final Function(String category) onTapCategory;
  const HomePage({super.key, required this.onTapCategory});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _itemFireStoreService = ItemFireStoreService();
  late Stream<QuerySnapshot> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _itemFireStoreService.getItemsStream();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      title: const Text(
        "Flames Pizzeria",
        style: TextStyle(
            fontWeight: FontWeight.bold
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              SlidePageRoute(
                page: const Dashboard(),
              ),
            );
          },
          icon: const Icon(Icons.settings_outlined)
        ),
      ],
      headerWidget: headerWidget(context),
      headerBottomBar: headerBottomBarWidget(),
      body: [
        container()
        // listView(),
      ],
      fullyStretchable: true,
      backgroundColor: Colors.white,
      appBarColor: const Color.fromRGBO(217, 188, 169, 1.0),
    );
  }

  Row headerBottomBarWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              SlidePageRoute(
                page: const Dashboard(),
              ),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          color: Colors.black,
        ),
      ],
    );
  }

  Widget headerWidget(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(217, 188, 169, 1.0),
      child: Center(
        child:Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Image.asset(
            "images/logo.png",
            height: 250.0,
            width: 250.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Container container() {
    return Container(
        height: 665.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                "Bestsellers",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),
              ),
            ),

            const SizedBox(height: 20.0,),

            StreamBuilder<QuerySnapshot>(
                stream: _itemsStream,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    List itemsList = snapshot.data!.docs;

                    itemsList = itemsList.where((item) {
                      return item["bestseller"] == "true";
                    }).toList();

                    if(itemsList.isNotEmpty) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
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

                                return GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      width: 130.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.grey[200],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            Image.network(
                                              imageURL,
                                              width: 115,
                                              height: 115,
                                              fit: BoxFit.cover,
                                            ),

                                            const SizedBox(height: 10.0,),

                                            Text(
                                              itemName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0
                                              ),
                                            ),

                                            Text(
                                              "LKR $price$mediumPrice",
                                            ),

                                            const SizedBox(height: 5.0,),

                                            GestureDetector(
                                              onTap: () {},
                                              child: const Text(
                                                "Add",
                                                style: TextStyle(
                                                    color: Colors.green
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                            "No available bestselling items."
                        ),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator(color: Colors.black,),);
                  }
                }
            ),

            const SizedBox(height: 20.0,),

            const Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                "What are you craving for?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),
              ),
            ),

            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Wrap each Container with Expanded to share available space
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Pizza");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/pizza.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.fitWidth,
                              ),
                              const Text(
                                "Pizza",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Burger");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/burger.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Burger",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Submarine");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/submarine.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.fitWidth,
                              ),
                              const Text(
                                "Submarine",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Quesadilla");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/quesadilla.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.fitWidth,
                              ),
                              const Text(
                                "Quesadilla",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Combo");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/combo.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Combo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTapCategory("Beverages");
                          },
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "images/beverages.png",
                                height: 100.0,
                                width: 90.0,
                                fit: BoxFit.fitHeight,
                              ),
                              const Text(
                                "Beverages",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20.0,),

            const Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                "Offers",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),
              ),
            ),
          ],
        )
    );
  }
}

