import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/services/WishListServices.dart'; // Import WishlistService for handling wishlist
import 'package:quickmartfinal/components/common/product_item.dart';
import 'package:quickmartfinal/services/UserSession.dart';
import 'package:quickmartfinal/components/common/custom_drawer.dart';
import 'package:quickmartfinal/services/CategoryService.dart'; // Import CategoryService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  final WishlistService _wishlistService = WishlistService(); // Create instance of WishlistService
  final CategoryService _categoryService = CategoryService(); // Create instance of CategoryService
  final Map<String, dynamic>? currentUser = UserSession().getCurrentUser();

  String _selectedCategory = 'All'; // Default category
  List<String> _categories = ['All']; // Default category list

  void _navigateToProductDetailsPage(String productId) {
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId}, // Pass the product ID as an argument
    );
  }

  void _navigateToAddProductPage() {
    Navigator.pushNamed(context, '/addProduct'); // Navigate to Add Product page
  }

  // Function to check if a product is already in the wishlist
  Future<bool> _isProductInWishlist(String productId) async {
    if (currentUser == null) return false;
    return await _wishlistService.isProductInWishlist(currentUser!['user_id'], productId);
  }

  // Function to toggle product in/out of wishlist
  Future<void> _toggleWishlist(String productId) async {
    if (currentUser == null) return;
    await _wishlistService.toggleWishlist(currentUser!['user_id'], productId);
    setState(() {}); // Update UI after toggling wishlist
  }

  // Fetch products based on selected category
  Stream<List<Map<String, dynamic>>> _fetchProductsByCategory(String category) {
    if (category == 'All') {
      return _productService.fetchProducts();
    } else {
      return _productService.fetchProductsByCategory(category);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories from Firestore and update the dropdown
  void _fetchCategories() async {
    _categoryService.fetchCategories().listen((categories) {
      setState(() {
        _categories = ['All'] + categories.map((cat) => cat['name'] as String).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            items: _categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue ?? 'All';
              });
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        appVersion: '1.0.0',
        isLoggedIn: isLoggedIn,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProductPage,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchProductsByCategory(_selectedCategory),
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

              return FutureBuilder<bool>(
                future: _isProductInWishlist(product['product_id'] ?? ''),
                builder: (context, snapshot) {
                  final isLiked = snapshot.data ?? false;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap ProductItem inside Expanded to allow space for the icon button
                      Expanded(
                        child: ProductItem(
                          imageUrl: imageUrl,
                          name: product['name'] ?? 'No name available',
                          description: product['description'] ?? 'No description available',
                          price: '\$${product['price']?.toString() ?? '0.00'}',
                          timeAgo: 'Uploaded at ${product['created_at']?.toDate() ?? 'Unknown time'}',
                          onTap: () {
                            _navigateToProductDetailsPage(product['product_id'] ?? '');
                          },
                        ),
                      ),
                      // Add the heart icon button
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleWishlist(product['product_id'] ?? '');
                        },
                      ),
                    ],
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
