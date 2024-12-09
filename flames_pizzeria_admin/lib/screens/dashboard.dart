import 'package:flames_pizzeria_admin/screens/sign_in.dart';
import 'package:flutter/material.dart';

import '../services/styles_&_fn_handle.dart';
import 'menu_page.dart';
import 'new_item.dart';
import 'orders.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  void logout() {
    setState(() {
      globalCurrentPage = 0;
      globalSelectedCategory = "Bestsellers";
    });
    Navigator.of(context).pushAndRemoveUntil(
      SlidePageRoute(page: const SignIn()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              children: <Widget>[
                const Column(
                  children: [
                    SizedBox(height: 20.0,),

                    CircleAvatar(
                      radius: 70.0,
                      backgroundImage: ResizeImage(
                        AssetImage("images/logo.jpg"),
                        width: 350,
                        height: 350
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Text(
                      "Welcome! Admin",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50.0,),

                //add items
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text(
                      "Add New Item",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const AddItem(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tileColor: Colors.grey[200],
                  ),
                ),

                const SizedBox(height: 5.0),

                //update and remove items
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text(
                      "Update & Remove Items",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const MenuPage(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tileColor: Colors.grey[200],
                  ),
                ),

                const SizedBox(height: 5.0),

                //purchase history
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt_rounded),
                    title: const Text(
                      "Orders",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const Orders(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tileColor: Colors.grey[200],
                  ),
                ),

                const SizedBox(height: 5.0),

                //about
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(
                      "About",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tileColor: Colors.grey[200],
                  ),
                ),

                const SizedBox(height: 30.0,),

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Logout",
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                      minimumSize: const Size.fromHeight(65),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onPressed: () {
                      logout();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
