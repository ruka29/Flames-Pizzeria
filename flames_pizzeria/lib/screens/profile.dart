import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/styles_&_fn_handle.dart';
import '../services/toggle_screens.dart';
import 'orders.dart';
import 'user_details.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String imageURL = '';
  String address = '';
  String mobile = '';

  void signIn() {
    setState(() {
      globalCurrentPage = 0;
      globalSelectedCategory = "Bestsellers";
    });
    Navigator.push(
      context,
      // Use SlidePageRoute instead of MaterialPageRoute
      SlidePageRoute(
        page: const ToggleScreens(),
      ),
    );
  }

  void logout() {
    setState(() {
      globalUserId = "";
      globalCurrentPage = 0;
      globalSelectedCategory = "Bestsellers";
      globalCartItemCount = 0;
    });
    Navigator.of(context).pushAndRemoveUntil(
      SlidePageRoute(page: const ToggleScreens()),
          (Route<dynamic> route) => false,
    );
  }

  void validateUser(bool userDetailsBtn) {
    if(globalUserId.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Sign in required!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      if(userDetailsBtn) {
        Navigator.push(
          context,
          SlidePageRoute(
            page: const UserDetails(),
          ),
        );
      } else {
        Navigator.push(
          context,
          SlidePageRoute(
            page: const Orders(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
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
                globalUserId.isNotEmpty
                    ?
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(globalUserId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final userDetails = snapshot.data!.data();
                      firstName = userDetails!['firstName'];
                      lastName = userDetails['lastName'];
                      email = userDetails['email'];
                      address = userDetails['address'];
                      mobile = userDetails['mobileNumber'];
                      imageURL = userDetails['imageURL'];

                      return Column(
                        children: [
                          const SizedBox(height: 20.0,),

                          CircleAvatar(
                            radius: 70.0,
                            backgroundImage: imageURL.isEmpty
                                ?
                            const ResizeImage(
                                AssetImage("images/profile.jpg"),
                                width: 350,
                                height: 350
                            )
                                :
                            ResizeImage(
                                NetworkImage(imageURL),
                                width: 350,
                                height: 350
                            ),
                          ),

                          const SizedBox(height: 10.0,),

                          Text(
                            "$firstName $lastName",
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5.0),

                          Text(
                            "$email",
                            style: const TextStyle(),
                          ),
                        ],
                      );
                    }

                    return const Center(child: CircularProgressIndicator(color: Colors.black,));
                  },
                )
                    :
                const Column(
                  children: [
                    SizedBox(height: 20.0,),

                    CircleAvatar(
                      radius: 70.0,
                      backgroundImage: ResizeImage(
                          AssetImage("images/profile.jpg"),
                          width: 350,
                          height: 350
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Please Sign In"
                    ),
                  ],
                ),

                const SizedBox(height: 50.0,),

                //user details
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: Colors.green,),
                    title: const Text(
                      "User Details",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      if(globalUserId.isEmpty) {
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
                      } else {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const UserDetails(),
                          ),
                        );
                      }
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
                    leading: const Icon(Icons.history),
                    title: const Text(
                      "Purchase History",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      if(globalUserId.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
                            title: Text('Error'),
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
                      } else {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const Orders(),
                          ),
                        );
                      }
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
                      globalUserId.isEmpty ? Icons.login : Icons.logout,
                      color: Colors.white,
                    ),
                    label: Text(
                      globalUserId.isEmpty ? "Sign In" : "Logout",
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
                      globalUserId.isEmpty ? signIn() : logout();
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
