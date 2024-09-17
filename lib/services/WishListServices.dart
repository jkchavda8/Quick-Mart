import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if a product is in the user's wishlist
  Future<bool> isProductInWishlist(String userId, String productId) async {
    final snapshot = await _firestore
        .collection('Wishlist')
        .where('user_id', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final wishlist = snapshot.docs.first;
      List<dynamic> productIds = wishlist['product_ids'];
      return productIds.contains(productId);
    }
    return false;
  }

  // Toggle the product in/out of the wishlist
  Future<void> toggleWishlist(String userId, String productId) async {
    final wishlistRef = _firestore.collection('Wishlist');
    final snapshot =
        await wishlistRef.where('user_id', isEqualTo: userId).get();

    if (snapshot.docs.isNotEmpty) {
      final wishlistDoc = snapshot.docs.first;
      List<dynamic> productIds = wishlistDoc['product_ids'];

      if (productIds.contains(productId)) {
        // Product is in wishlist, remove it
        productIds.remove(productId);
      } else {
        // Product is not in wishlist, add it
        productIds.add(productId);
      }

      await wishlistDoc.reference.update({'product_ids': productIds});
    } else {
      // Create a new wishlist if not exists
      await wishlistRef.add({
        'wishlist_id': wishlistRef.doc().id,
        'user_id': userId,
        'product_ids': [productId],
        'created_at': Timestamp.now(),
      });
    }
  }

  // Method to get user's wishlist products
  Future<List<Map<String, dynamic>>> getUserWishlist(String userId) async {
    try {
      // Fetch the user's wishlist document by userId
      final QuerySnapshot wishlistSnapshot = await _firestore
          .collection('Wishlist')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();
      // print("f");
      if (wishlistSnapshot.docs.isEmpty) {
        // Return empty list if no wishlist found for the user
        return [];
      }
      // print("S");
      // Get the product IDs from the wishlist document
      final List<String> productIds =
      List<String>.from(wishlistSnapshot.docs[0]['product_ids']);

      if (productIds.isEmpty) {
        // If the wishlist has no products, return an empty list
        return [];
      }
      // print("t");
      // Fetch product details for each product in the user's wishlist
      final List<Map<String, dynamic>> products = [];
      for (String productId in productIds) {
        // Fetch the product document directly by querying 'product_id'
        final QuerySnapshot<Map<String, dynamic>> productSnapshot =
        await _firestore.collection('Products').where('product_id', isEqualTo: productId).get();

        // Check if the query returned any documents
        if (productSnapshot.docs.isNotEmpty) {
          // Assuming there is only one document per product_id, extract the first one
          products.add(productSnapshot.docs[0].data());
        }
      }

      return products; // Return the list of product details
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

}
