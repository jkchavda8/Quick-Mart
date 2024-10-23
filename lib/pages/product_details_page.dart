import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/services/UserServices.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();
    final UserService _userService = UserService();

    if (productId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid product ID')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _productService.getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching product details'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          }

          var productData = snapshot.data!;

          // Fetch seller details
          Future<Map<String, dynamic>?> fetchSellerDetails(String sellerId) async {
            return await _userService.getUserById(sellerId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center( // Center the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  // Product Image
                  // SizedBox(
                  //   height: 200.0, // Fixed height for image
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center, // Center the images
                  //     children: List.generate(
                  //       productData['image_urls'].length,
                  //           (index) {
                  //         final imageUrl = productData['image_urls'][index];
                  //         return Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(10),
                  //             child: Image.network(
                  //               imageUrl,
                  //               fit: BoxFit.cover,
                  //               height: 200,
                  //               width: 200,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
              SizedBox(
                   height: 200.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: Row(
                      children: List.generate(
                        productData['image_urls'].length,
                            (index) {
                          final imageUrl = productData['image_urls'][index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: 200,
                                width: 200,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ),

                  const SizedBox(height: 16),

                  // Product Title
                  Text(
                    productData['name'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Product Price
                  Text(
                    'Price: ₹${productData['price']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Product Category
                  Text(
                    'Category: ${productData['category']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Product Description in a Card
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        productData['description'] ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Fetch and Display Seller Details
                  FutureBuilder<Map<String, dynamic>?>(
                    future: fetchSellerDetails(productData['seller_id']),
                    builder: (context, sellerSnapshot) {
                      if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (sellerSnapshot.hasError) {
                        return const Center(child: Text('Error fetching seller details'));
                      }

                      if (!sellerSnapshot.hasData || sellerSnapshot.data == null) {
                        return const Center(child: Text('Seller not found'));
                      }

                      var sellerData = sellerSnapshot.data!;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Seller Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text('Name: ${sellerData['name']}', textAlign: TextAlign.center),
                              const SizedBox(height: 5),
                              Text('Address: ${sellerData['address']}', textAlign: TextAlign.center),
                              const SizedBox(height: 5),
                              Text('Phone: ${sellerData['phone_number']}', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
