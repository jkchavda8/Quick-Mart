import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

class ProductService {
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('Products');
  final Uuid _uuid = const Uuid();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String productCollection = 'Products';

  // Add a new product
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required List<String> imageUrls,
    required String sellerId,
  }) async {
    try {
      print('Adding product to Firestore: $name');
      String ProductId = _uuid.v4();
      await _productsCollection.add({
        'product_id': ProductId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_urls': imageUrls,
        'seller_id': sellerId,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
        'is_sold': false,
        'isApproved': false
      });

      print('Product added to Firestore');
    } catch (e) {
      print('Error adding product to Firestore: $e');
    }
  }

  // Fetch all products
  Stream<List<Map<String, dynamic>>> fetchProducts() {
    return _productsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }

  // Fetch all products (for admin)
  Stream<List<Map<String, dynamic>>> fetchAllProducts() {
    return _productsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<void> approveProduct(String productId) async {
    try {
      // Directly update the 'isApproved' field to true
      await _productsCollection
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'isApproved': true});
          print('Product approved: $productId');
        }
      });
    } catch (e) {
      print('Error approving product: $e');
    }
  }


  Future<void> blockProduct(String productId) async {
    try {
      // Directly update the 'isApproved' field to false
      await _productsCollection
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'isApproved': false});
          print('Product blocked: $productId');
        }
      });
    } catch (e) {
      print('Error blocking product: $e');
    }
  }

  Future<void> unblockProduct(String productId) async {
    try {
      // Directly update the 'isApproved' field to true
      await _productsCollection
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'isApproved': true});
          print('Product unblocked: $productId');
        }
      });
    } catch (e) {
      print('Error unblocking product: $e');
    }
  }


  Future<void> updateProductStatus(String productId, bool isSold) async {
    try {
      _productsCollection
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'is_sold': isSold});
          print('Product sold: $productId');
        }
      });
    } catch (e) {
      print('Error updating product status: $e');
    }
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get product details by product ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      // Query for the product with the specified product_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('Products')
          .where('product_id', isEqualTo: productId)
          .limit(1) // Assuming product_id is unique, limit to 1 result
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document's data
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print('No product found with ID: $productId');
        return null;
      }
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getProductsBySellerId(String sellerId) {
    return _productsCollection
        .where('seller_id', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> fetchProductsByCategory(String category) {
    if (category == 'All') {
      return fetchProducts(); // Return all products if 'All' is selected
    } else {
      return _productsCollection
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
    }
  }

  Stream<List<Map<String, dynamic>>> searchProducts(String query) {
    return _firestore.collection('Products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        final description = product['description']?.toLowerCase() ?? '';
        final price = (product['price'] as num?) ?? 0;

        final queryLower = query.toLowerCase();
        final priceMatch = price.toString().contains(queryLower);

        return name.contains(queryLower) ||
            description.contains(queryLower) ||
            priceMatch;
      })
          .toList();
    });
  }

  // Fetch all product names
  Future<List<String>> fetchProductNames() async {
    try {
      QuerySnapshot querySnapshot = await _productsCollection.get();
      List<String> productNames = querySnapshot.docs.map((doc) {
        return (doc.data() as Map<String, dynamic>)['name'] as String;
      }).toList();

      return productNames;
    } catch (e) {
      print('Error fetching product names: $e');
      return [];
    }
  }
  Future<void> deleteProductById(String productId) async {
    try {
      // Query to find the document with the given product_id
      QuerySnapshot snapshot = await _productsCollection
          .where('product_id', isEqualTo: productId)
          .limit(1) // Assuming product_id is unique, limit to 1 result
          .get();

      if (snapshot.docs.isNotEmpty) {
        // If the document exists, delete it
        await snapshot.docs.first.reference.delete();
        print('Product deleted: $productId');
      } else {
        print('No product found with ID: $productId');
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }


}
// Search products by name, description, or category
//   Stream<List<Map<String, dynamic>>> searchProducts(String searchTerm) {
//     return _productsCollection
//         .where('name', isGreaterThanOrEqualTo: searchTerm)
//         .where('name',
//             isLessThanOrEqualTo:
//                 searchTerm + '\uf8ff') // For case-insensitive prefix match
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList());
//   }
// }
