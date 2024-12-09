import 'package:cloud_firestore/cloud_firestore.dart';

class ItemFireStoreService {
  //get items
  final CollectionReference items =
  FirebaseFirestore.instance.collection('items');

  Stream<QuerySnapshot> getItemsStream() {
    final itemsStream = items.snapshots();
    return itemsStream;
  }
}