import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Import the uuid packag

class CategoryService {
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('Categories');
  final Uuid _uuid = const Uuid();

  // Add a new category
  Future<void> addCategory({
    required String name,
    required String description,
  }) async {
    try {
      String CategoryId = _uuid.v4();

      await _categoriesCollection.add({
        'CategoryId': CategoryId,
        'name': name,
        'description': description,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  // Fetch all categories
  Stream<List<Map<String, dynamic>>> fetchCategories() {
    return _categoriesCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
