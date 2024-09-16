import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final String timeAgo;
  final VoidCallback onTap; // Add onTap callback

  const ProductItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.timeAgo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(name),
      subtitle: Text(description),
      trailing: Text(price),
      onTap: onTap, // Use the onTap callback
    );
  }
}
