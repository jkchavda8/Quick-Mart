import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/services/UserSession.dart';

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
        title: const Text('My Products', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productService.getProductsBySellerId(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageUrl = product['image_urls'] != null && product['image_urls'].isNotEmpty
                  ? product['image_urls'][0]
                  : 'https://via.placeholder.com/150'; // Fallback placeholder

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        product['description'] ?? 'No description available',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${product['price']?.toString() ?? '0.00'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Uploaded on ${product['created_at']?.toDate()?.toString().split(' ')[0] ?? 'Unknown date'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onPressed: () {
                      _navigateToProductDetailsPage(product['product_id'] ?? ''); // Navigate to product details
                    },
                  ),
                  onTap: () {
                    _navigateToProductDetailsPage(product['product_id'] ?? ''); // Pass the product ID
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
