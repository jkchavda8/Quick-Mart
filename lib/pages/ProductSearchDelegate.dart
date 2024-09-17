import 'package:flutter/material.dart';

class ProductSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  ProductSearchDelegate({required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Placeholder while query is processed
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Optionally, you can provide suggestions here
  }
}
