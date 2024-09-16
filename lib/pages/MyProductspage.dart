import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/components/common/product_item.dart';
import 'package:quickmartfinal/services/UserSession.dart'; // Import UserSession for managing user sessions

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({Key? key}) : super(key: key);

  @override
  _MyProductsPageState createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final ProductService _productService = ProductService();
  late final String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = UserSession().getCurrentUser()?['user_id'];
  }

  void _navigateToProductDetailsPage(String productId) {
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId}, // Pass the product ID as an argument
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productService.getProductsBySellerId(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              print('hello');
              print(product['product_id']);
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
