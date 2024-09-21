import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ProductServices.dart';
import '../services/UserSession.dart';
import '../services/CategoryService.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<Uint8List> _imageBytes = [];
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _imagePicker = ImagePicker();

  // Method to pick image from device or camera
  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickImageFromDevice();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take from Camera'),
                onTap: () {
                  _takeImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick image from device storage using FilePicker
  Future<void> _pickImageFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      withData: true,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.map((file) => file.bytes!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid image files (JPG or PNG).')),
      );
    }
  }

  // Method to take an image from the camera using image_picker
  Future<void> _takeImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _imageBytes.add(imageBytes);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to take a picture.')),
      );
    }
  }

  // Method to upload all images and return the download URLs
  Future<List<String>> _uploadImages(List<Uint8List> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('products').child(fileName);

      UploadTask uploadTask = ref.putData(image, SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  // Method to fetch categories
  void _fetchCategories() {
    _categoryService.fetchCategories().listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  // Method to add the product
  void _addProduct() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final Map<String, dynamic>? currentUser = UserSession().getCurrentUser();

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        price > 0 &&
        _selectedCategory != null &&
        _imageBytes.isNotEmpty &&
        currentUser != null) {
      // Upload images and get URLs
      List<String> imageUrls = await _uploadImages(_imageBytes);

      // Add product with image URLs
      await _productService.addProduct(
        name: name,
        description: description,
        price: price,
        category: _selectedCategory!,
        imageUrls: imageUrls,
        sellerId: currentUser['user_id'], // Replace with actual seller ID
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/home');
      }).catchError((e) {
        print("Error while adding product: $e");
      });
    } else {
      print("Form validation failed");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Select Category'),
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Pick Images'),
              ),
              const SizedBox(height: 10),
              _imageBytes.isNotEmpty
                  ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imageBytes.map((bytes) {
                  return Image.memory(
                    bytes,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              )
                  : const Text('No images selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
