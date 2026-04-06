import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _itemsRef =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await _itemsRef.add(item.toMap());
  }

  Stream<List<Item>> streamItems() {
    return _itemsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> updateItem(Item item) async {
    await _itemsRef.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _itemsRef.doc(id).delete();
  }
}