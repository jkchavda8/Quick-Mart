import 'package:flutter/material.dart';
import 'package:quickmartfinal/components/common/product_item.dart';
import 'package:quickmartfinal/services/ProductServices.dart';

class CustomSearchDelegate extends SearchDelegate {
  final ProductService _productService = new ProductService();
  final context;

  CustomSearchDelegate({required this.context});

  void _navigateToProductDetailsPage(String productId) {
    print('Navigating to product details with productId: $productId');
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId}, // Pass the product ID as an argument
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Actions for the AppBar (clear button)
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Leading icon (back button)
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search bar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _productService.searchProducts(query), // Use the query to search
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found for "$query"'));
        }

        final products = snapshot.data!;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final imageUrl = product['image_urls'] != null &&
                    product['image_urls'].isNotEmpty
                ? product['image_urls'][0]
                : 'https://via.placeholder.com/150'; // Fallback placeholder

            return ProductItem(
              imageUrl: imageUrl,
              name: product['name'] ?? 'No name available',
              description: product['description'] ?? 'No description available',
              price: '\$${product['price']?.toString() ?? '0.00'}',
              timeAgo:
                  'Uploaded at ${product['created_at']?.toDate() ?? 'Unknown time'}',
              onTap: () {
                _navigateToProductDetailsPage(
                    product['product_id'] ?? ''); // Pass the product ID
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Fetch product names asynchronously here
    return FutureBuilder<List<String>>(
      future: _productService.fetchProductNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching products'));
        } else if (snapshot.hasData) {
          final searchItems = snapshot.data!;
          final filteredItems = searchItems.where((item) {
            return item.toLowerCase().contains(query.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredItems[index]),
                onTap: () {
                  query = filteredItems[index];
                  showResults(context);
                },
              );
            },
          );
        } else {
          return Center(child: Text('No products found'));
        }
      },
    );
  }
}
