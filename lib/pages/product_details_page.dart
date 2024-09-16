import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/services/UserServices.dart'; // Import the UserServices

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();
    final UserService _userService = UserService(); // Create an instance of UserService

    if (productId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid product ID')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _productService.getProductById(productId), // Fetch product details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching product details'));
          }
          print(productId);
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          }

          var productData = snapshot.data!;

          // Fetch seller details
          Future<Map<String, dynamic>?> fetchSellerDetails(String sellerId) async {
            return await _userService.getUserById(sellerId);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Name: ${productData['name']}'),
                Text('Price: \$${productData['price']}'),
                Text('Category: ${productData['category']}'),
                Text('Description: ${productData['description']}'),
                const SizedBox(height: 16.0),
                Text('Images:', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(
                  height: 200.0, // Adjust as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productData['image_urls'].length,
                    itemBuilder: (context, index) {
                      final imageUrl = productData['image_urls'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                FutureBuilder<Map<String, dynamic>?>(
                  future: fetchSellerDetails(productData['seller_id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching seller details'));
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('Seller not found'));
                    }

                    var sellerData = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seller Name: ${sellerData['name']}'),
                        Text('Seller Address: ${sellerData['address']}'),
                        Text('Seller Phone: ${sellerData['phone_number']}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
