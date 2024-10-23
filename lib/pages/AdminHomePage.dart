import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/ProductServices.dart';
import 'package:quickmartfinal/pages/product_details_page.dart';

class AdminHomePage extends StatelessWidget {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Product Management',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _productService.fetchAllProducts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Map<String, dynamic>> products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productId = product['product_id'];
                final isApproved = product['isApproved'] ?? false;
                final productImage = product['image_urls'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(productId: productId),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display product image using CachedNetworkImage for better handling
                          // if (productImage.isNotEmpty)
                          //   CachedNetworkImage(
                          //     imageUrl: product['image_urls'][0],
                          //     width: 80, // Adjust the width
                          //     height: 80, // Adjust the height
                          //     fit: BoxFit.cover,
                          //     placeholder: (context, url) => const CircularProgressIndicator(),
                          //     errorWidget: (context, url, error) => const Icon(Icons.error),
                          //     imageBuilder: (context, imageProvider) => Container(
                          //       width: 80,
                          //       height: 80,
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(8),
                          //         image: DecorationImage(
                          //           image: imageProvider,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       ),
                          //     ),
                          //   ),

                          if (productImage.isNotEmpty)
                            Container(
                              width: 80, // Desired image width
                              height: 80, // Desired image height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                                image: DecorationImage(
                                  image: NetworkImage(productImage[0]), // Just display the image
                                  fit: BoxFit.cover, // Fit the image within the container
                                ),
                              ),
                            ),

                          if (productImage.isEmpty)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                          const SizedBox(width: 16), // Space between image and product details

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Price: ₹${product['price']}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!isApproved)
                                      ElevatedButton(
                                        onPressed: () => _productService.approveProduct(productId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Approve',
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                    if (isApproved)
                                      ElevatedButton(
                                        onPressed: () {
                                          if (isApproved) {
                                            _productService.blockProduct(productId);
                                          } else {
                                            _productService.unblockProduct(productId);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isApproved ? Colors.red : Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          isApproved ? 'Block' : 'Unblock',
                                          style: const TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
