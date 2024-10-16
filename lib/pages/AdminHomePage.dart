import 'package:flutter/material.dart';
import '../services/ProductServices.dart';

class AdminHomePage extends StatelessWidget {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Product Management'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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

              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Price: \$${product['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isApproved) // Show Approve button if not approved
                      ElevatedButton(
                        onPressed: () => _productService.approveProduct(productId),
                        child: const Text('Approve'),
                      ),
                    if (isApproved) // Show Block or Unblock button based on isApproved status
                      ElevatedButton(
                        onPressed: () {
                          if (isApproved) {
                            _productService.blockProduct(productId);
                          } else {
                            _productService.unblockProduct(productId);
                          }
                        },
                        child: Text(isApproved ? 'Block' : 'Unblock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproved ? Colors.red : Colors.green,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
