import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFireStoreService {
  //get orders
  final CollectionReference orders =
  FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOrdersStream() {
    final ordersStream = orders.orderBy('time stamp', descending: true).snapshots();
    return ordersStream;
  }

  Stream<QuerySnapshot> getItemsStream(String orderID) {
    final itemsStream = orders.doc(orderID).collection('items').snapshots();
    return itemsStream;
  }

  Future<void> deleteOrder(String orderID) {
    return orders.doc(orderID).delete();
  }
}