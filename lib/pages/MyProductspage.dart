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
  bool showUnsold = true; // Initially showing unsold products
  double grandTotal = 0.0; // Total price of sold products
  bool hasCalculatedGrandTotal = false; // Flag to check if grand total has been calculated

  @override
  void initState() {
    super.initState();
    _currentUserId = UserSession().getCurrentUser()?['user_id'];
  }

  // Function to calculate grand total of sold products
  void _calculateGrandTotal(List<Map<String, dynamic>> products) {
    if (hasCalculatedGrandTotal) return; // Return if already calculated

    double total = 0.0;
    for (var product in products) {
        total += product['price'] ?? 0.0;

    }

    // Use addPostFrameCallback to safely update the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        grandTotal = total; // Update grand total with pre-sold products
        hasCalculatedGrandTotal = true; // Set flag to true after calculation
      });
    });
  }

  // Function to mark product as sold
  void _markAsSold(String productId, double price) async {
    try {
      await _productService.updateProductStatus(productId, true);
      setState(() {
        grandTotal += price; // Update the grand total when a product is sold
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product marked as sold')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update product status')),
      );
    }
  }

  // Function to mark product as unsold
  void _markAsUnsold(String productId, double price) async {
    try {
      await _productService.updateProductStatus(productId, false);
      setState(() {
        grandTotal -= price; // Update the grand total when a product is marked as unsold
        hasCalculatedGrandTotal = false; // Reset calculation flag
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product marked as unsold')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update product status')),
      );
    }
  }

  // Function to remove a product
  void _removeProduct(String productId) async {
    try {
      await _productService.deleteProductById(productId);
      setState(() {
        hasCalculatedGrandTotal = false; // Reset calculation flag on removal
      }); // Refresh the UI after the product is deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove product')),
      );
    }
  }

  void _navigateToProductDetailsPage(String productId) {
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Products',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Toggle between Unsold and Sold products
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [showUnsold, !showUnsold],
              onPressed: (index) {
                setState(() {
                  showUnsold = index == 0;
                  // Reset grand total calculation when toggling
                  hasCalculatedGrandTotal = false;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Unsold'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Sold'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productService.getProductsBySellerId(_currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No products found',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  );
                }

                // Filter products based on sold/unsold status
                final products = snapshot.data!
                    .where((product) =>
                (showUnsold && !(product['is_sold'] ?? false)) ||
                    (!showUnsold && (product['is_sold'] ?? false)))
                    .toList();

                // Calculate grand total for pre-sold products only when showing sold products
                  _calculateGrandTotal(products);


                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products in this category',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final imageUrl = product['image_urls'] != null &&
                        product['image_urls'].isNotEmpty
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
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
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
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Uploaded on ${product['created_at']?.toDate()?.toString().split(' ')[0] ?? 'Unknown date'}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: showUnsold
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _markAsSold(
                                  product['product_id'],
                                  product['price'] ?? 0.0),
                              child: const Text('Mark as Sold',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _removeProduct(product['product_id']),
                              color: Colors.red,
                            ),
                          ],
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _markAsUnsold(
                                  product['product_id'],
                                  product['price'] ?? 0.0),
                              child: const Text('Mark as Unsold',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _removeProduct(product['product_id']),
                              color: Colors.red,
                            ),
                          ],
                        ), // No action for sold products
                        onTap: () {
                          _navigateToProductDetailsPage(
                              product['product_id'] ?? '');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
