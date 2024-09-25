import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/WishListServices.dart';
import 'package:quickmartfinal/services/UserSession.dart';

class WishlistPage extends StatefulWidget {
  WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _wishlistService = WishlistService();
  final Map<String, dynamic>? currentUser = UserSession().getCurrentUser();

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wishlist'),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: Text('Please log in to view your wishlist',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _wishlistService.getUserWishlist(currentUser!['user_id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your wishlist is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final wishlistProducts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
              final productId = product['product_id'];
              final imageUrl = product['image_urls'] != null && product['image_urls'].isNotEmpty
                  ? product['image_urls'][0]
                  : 'https://via.placeholder.com/150'; // Fallback image

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product['name'] ?? 'No name available',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        '₹${product['price']?.toString() ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Uploaded on ${product['created_at']?.toDate()?.toString().split(' ')[0] ?? 'Unknown date'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: FutureBuilder<bool>(
                    future: _wishlistService.isProductInWishlist(
                        currentUser!['user_id'], productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final isInWishlist = snapshot.data ?? false;

                      return IconButton(
                        icon: Icon(
                          isInWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : null,
                        ),
                        onPressed: () async {
                          // Toggle the product in/out of the wishlist
                          await _wishlistService.toggleWishlist(
                            currentUser!['user_id'],
                            productId,
                          );

                          // Update the UI after toggling
                          setState(() {});
                        },
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/productDetails',
                      arguments: {'productId': productId},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
