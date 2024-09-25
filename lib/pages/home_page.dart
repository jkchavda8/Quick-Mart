import 'package:flutter/material.dart';
import 'package:quickmartfinal/components/common/custom_header.dart';
import 'package:quickmartfinal/services/ProductServices.dart';
import 'package:quickmartfinal/services/WishListServices.dart';
import 'package:quickmartfinal/services/UserSession.dart';
import 'package:quickmartfinal/components/common/custom_drawer.dart';
import 'package:quickmartfinal/services/CategoryService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  final WishlistService _wishlistService = WishlistService();
  final CategoryService _categoryService = CategoryService();
  Map<String, dynamic>? currentUser = UserSession().getCurrentUser();

  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  void _navigateToProductDetailsPage(String productId) {
    Navigator.pushNamed(
      context,
      '/productDetails',
      arguments: {'productId': productId},
    );
  }

  void _navigateToAddProductPage() {
    if (currentUser == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, '/addProduct');
    }
  }

  Future<bool> _isProductInWishlist(String productId) async {
    if (currentUser == null) return false;
    return await _wishlistService.isProductInWishlist(currentUser!['user_id'], productId);
  }

  Future<void> _toggleWishlist(String productId) async {
    if (currentUser == null) return;
    await _wishlistService.toggleWishlist(currentUser!['user_id'], productId);
    setState(() {});
  }

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

  void _fetchCategories() async {
    _categoryService.fetchCategories().listen((categories) {
      setState(() {
        _categories = ['All'] + categories.map((cat) => cat['name'] as String).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = currentUser != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomHeader(
        title: 'Quick Mart',
        isLoggedIn: isLoggedIn,
        onLoginLogoutPressed: () async {
          if (currentUser != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            setState(() {
              UserSession().clearUser();
              currentUser = UserSession().getCurrentUser();
            });
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
      drawer: CustomDrawer(
        appVersion: '1.0.0',
        isLoggedIn: isLoggedIn,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProductPage,
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green, // Enhanced color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Adding a more modern shape
        ),
        tooltip: 'Add a new product',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true, // Make sure it takes full width
                underline: const SizedBox(), // Remove the default underline
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue ?? 'All';
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                final products = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 3 : 2, // Responsive layout
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.95, // Adjust to make images more prominent
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final imageUrl = product['image_urls'] != null && product['image_urls'].isNotEmpty
                        ? product['image_urls'][0]
                        : 'https://via.placeholder.com/150';

                    return FutureBuilder<bool>(
                      future: _isProductInWishlist(product['product_id'] ?? ''),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;

                        return Stack(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  _navigateToProductDetailsPage(product['product_id'] ?? '');
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1.5,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Product Name
                                          Text(
                                            product['name'] ?? 'No name',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18, // Increase font size for product name
                                              color: Colors.black87, // Slightly softer black for the name
                                              letterSpacing: 0.5, // Add letter spacing for a cleaner look
                                            ),
                                            maxLines: 2, // Allow more than one line if the name is long
                                            overflow: TextOverflow.ellipsis, // Avoid overflow
                                          ),
                                          const SizedBox(height: 8), // Increase space between name and price

                                          // Price
                                          Row(
                                            children: [
                                              Text(
                                                '\₹${product['price']?.toString() ?? '0.00'}',
                                                style: const TextStyle(
                                                  color: Colors.green, // Vibrant green for price
                                                  fontSize: 16, // Slightly larger font size for price
                                                  fontWeight: FontWeight.w600, // Semi-bold for price
                                                ),
                                              ),
                                              const SizedBox(width: 8), // Space between price and discount tag if needed

                                              // You can add a discount or special offer label here if necessary
                                              if (product['discount'] != null && product['discount'] > 0)
                                                Text(
                                                  '${product['discount']}% OFF',
                                                  style: const TextStyle(
                                                    color: Colors.red, // Highlight discount in red
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
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
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  _toggleWishlist(product['product_id'] ?? '');
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
