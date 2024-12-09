import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'styles_&_fn_handle.dart';

String generateUniqueId() {
  final now = DateTime.now();
  return '${now.millisecondsSinceEpoch}-${Random().nextInt(10000)}';
}

class FireStoreService {
  //get users
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  //create user
  Future<void> addUser(String firstName, String lastName, String email, String password) {
    final userId = generateUniqueId();

    return users.doc(email).set({
      'userID': userId,
      'imageURL': '',
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'address': '',
      'mobileNumber': '',
    });
  }

  //get user cart
  Stream<QuerySnapshot> getCartStream() {
    final cartStream = users.doc(globalUserId).collection("cart").snapshots();
    return cartStream;
  }

  //update user
  Future<void> updateUser(String firstName, String lastName, String email, String address, String mobileNumber, String imageURL) async {
    return users.doc(email).update({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'mobileNumber': mobileNumber,
      'imageURL': imageURL
    });
  }
}