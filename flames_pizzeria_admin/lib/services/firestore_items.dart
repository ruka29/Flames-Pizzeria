import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

String generateUniqueId() {
  final now = DateTime.now();
  return '${now.millisecondsSinceEpoch}-${Random().nextInt(10000)}';
}

class ItemFireStoreService {
  //get items
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  //create items
  Future<void> addItems(String imageURL, String itemName, String ingredients,String category, String price, String regularPrice, String mediumPrice, String largePrice,) {
    final itemID = generateUniqueId();

    return items.doc(itemID).set({
      'itemID': itemID,
      'imageURL': imageURL,
      'item name': itemName,
      'ingredients': ingredients,
      'category': category,
      'price': price,
      'regularPrice': regularPrice,
      'mediumPrice': mediumPrice,
      'largePrice': largePrice,
      'bestseller': "false"
    });
  }

  Stream<QuerySnapshot> getItemsStream() {
    final itemsStream = items.snapshots();
    return itemsStream;
  }

  Future<void> updateItems(String itemID, String imageURL, String itemName, String ingredients,String category, String price, String regularPrice, String mediumPrice, String largePrice,) {
    return items.doc(itemID).set({
      'itemID': itemID,
      'imageURL': imageURL,
      'item name': itemName,
      'ingredients': ingredients,
      'category': category,
      'price': price,
      'regularPrice': regularPrice,
      'mediumPrice': mediumPrice,
      'largePrice': largePrice,
      'bestseller': "false"
    });
  }

  Future<void> deleteItem(String itemID) {
    return items.doc(itemID).delete();
  }
}