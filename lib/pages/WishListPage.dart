// import 'package:flutter/material.dart';
// import 'package:quickmartfinal/services/WishListServices.dart';
// import 'package:quickmartfinal/services/UserSession.dart';
//
// class WishlistPage extends StatelessWidget {
//   final WishlistService _wishlistService = WishlistService();
//   final Map<String, dynamic>? currentUser = UserSession().getCurrentUser();
//
//   WishlistPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Wishlist'),
//         ),
//         body: const Center(child: Text('Please log in to view your wishlist')),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Wishlist'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _wishlistService.getUserWishlist(currentUser!['user_id']),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Your wishlist is empty'));
//           }
//
//           final wishlistProducts = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: wishlistProducts.length,
//             itemBuilder: (context, index) {
//               final product = wishlistProducts[index];
//               return ListTile(
//                 leading: Image.network(product['image_urls'][0]),
//                 title: Text(product['name']),
//                 subtitle: Text('\$${product['price']}'),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/productDetails', arguments: {'productId': product['product_id']});
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
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
        ),
        body: const Center(child: Text('Please log in to view your wishlist')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _wishlistService.getUserWishlist(currentUser!['user_id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your wishlist is empty'));
          }

          final wishlistProducts = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
              final productId = product['product_id'];

              return ListTile(
                leading: Image.network(product['image_urls'][0]),
                title: Text(product['name']),
                subtitle: Text('\$${product['price']}'),
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
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
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
              );
            },
          );
        },
      ),
    );
  }
}
