import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/CategoryService.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final CategoryService _categoryService = CategoryService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Method to add category
  void _addCategory() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;

    if (name.isNotEmpty && description.isNotEmpty) {
      await _categoryService.addCategory(
        name: name,
        description: description,
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
        _nameController.clear();
        _descriptionController.clear();
      }).catchError((e) {
        print("Error adding category: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding category')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
