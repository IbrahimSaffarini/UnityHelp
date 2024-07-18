import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRequestFromInventory {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<DocumentSnapshot>> fetchInventoryItems() async {
    QuerySnapshot snapshot = await _firestore.collection('Mobile Inventory Items').get();
    return snapshot.docs;
  }

  Stream<QuerySnapshot> getInventoryItemsStream() {
    return _firestore.collection('Mobile Inventory Items').snapshots();
  }

  Future<void> initializeInventory() async {
    final List<Map<String, dynamic>> items = [
      {'Item Name': 'Blanket', 'Item Price': 4, 'Item Quantity': 5000},
      {'Item Name': 'Bread', 'Item Price': 1, 'Item Quantity': 5000},
      {'Item Name': 'Canned Food', 'Item Price': 2, 'Item Quantity': 5000},
      {'Item Name': 'Milk Bottle', 'Item Price': 1, 'Item Quantity': 5000},
      {'Item Name': 'Panadol Extra', 'Item Price': 1, 'Item Quantity': 5000},
      {'Item Name': 'Toilet Paper', 'Item Price': 1, 'Item Quantity': 5000},
      {'Item Name': 'Water Bottle', 'Item Price': 0.5, 'Item Quantity': 5000},
    ];

    final CollectionReference inventoryCollection = _firestore.collection('Mobile Inventory Items');

    for (var item in items) {
      final docRef = inventoryCollection.doc(item['Item Name']);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set(item);
      }
    }
  }
}
