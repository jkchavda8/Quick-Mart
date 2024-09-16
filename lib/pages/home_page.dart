// import 'package:flutter/material.dart';
// import 'package:quickmartfinal/services/ProductServices.dart';
// import 'package:quickmartfinal/components/common/product_item.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final ProductService _productService = ProductService();
//
//   void _navigateToProductDetailsPage(String productId) {
//     print('Navigating to product details with productId: $productId');
//     Navigator.pushNamed(
//       context,
//       '/productDetails',
//       arguments: {'productId': productId}, // Pass the product ID as an argument
//     );
//   }
//
//   void _navigateToAddProductPage() {
//     Navigator.pushNamed(context, '/addProduct'); // Navigate to Add Product page
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddProductPage,
//         child: const Icon(Icons.add),
//         tooltip: 'Add Product',
//       ),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _productService.fetchProducts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No products available'));
//           }
//
//           final products = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               final imageUrl = product['image_urls'] != null && product['image_urls'].isNotEmpty
//                   ? product['image_urls'][0]
//                   : 'https://via.placeholder.com/150'; // Fallback placeholder
//
//               return ProductItem(
//                 imageUrl: imageUrl,
//                 name: product['name'] ?? 'No name available',
//                 description: product['description'] ?? 'No description available',
//                 price: '\$${product['price']?.toString() ?? '0.00'}',
//                 timeAgo: 'Uploaded at ${product['created_at']?.toDate() ?? 'Unknown time'}',
//                 onTap: () {
//                   _navigateToProductDetailsPage(product['product_id'] ?? ''); // Pass the product ID
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
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/components/common/product_item.dart';
import 'package:quickmartfinal/services/UserSession.dart'; // Import UserSession for managing user sessions
import 'package:quickmartfinal/components/common/custom_drawer.dart'; // Import the CustomDrawer widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  final Map<String, dynamic>? currentUser = UserSession().getCurrentUser();

  void _navigateToProductDetailsPage(String productId) {
    print('Navigating to product details with productId: $productId');
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId}, // Pass the product ID as an argument
    );
  }

  void _navigateToAddProductPage() {
    Navigator.pushNamed(context, '/addProduct'); // Navigate to Add Product page
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: CustomDrawer(
        appVersion: '1.0.0', // Replace with your app version
        isLoggedIn: isLoggedIn,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProductPage,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageUrl = product['image_urls'] != null && product['image_urls'].isNotEmpty
                  ? product['image_urls'][0]
                  : 'https://via.placeholder.com/150'; // Fallback placeholder

              return ProductItem(
                imageUrl: imageUrl,
                name: product['name'] ?? 'No name available',
                description: product['description'] ?? 'No description available',
                price: '\$${product['price']?.toString() ?? '0.00'}',
                timeAgo: 'Uploaded at ${product['created_at']?.toDate() ?? 'Unknown time'}',
                onTap: () {
                  _navigateToProductDetailsPage(product['product_id'] ?? ''); // Pass the product ID
                },
              );
            },
          );
        },
      ),
    );
  }
}
