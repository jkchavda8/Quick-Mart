import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickmartfinal/components/input_field.dart';
import 'package:quickmartfinal/components/custom_button.dart';
import 'package:quickmartfinal/services/UserServices.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  final UserService _userService = UserService();
  Uint8List? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  String? _profilePictureUrl;

  Future<void> _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final phoneNumber = _phoneNumberController.text;
    final address = _addressController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // If an image is selected, upload it to Firebase
    if (_selectedImage != null) {
      _profilePictureUrl = await _uploadImage(_selectedImage!);
    }

    final user = await _userService.registerUser(
      name,
      email,
      password,
      phoneNumber,
      _profilePictureUrl ?? '', // Use the uploaded URL, or an empty string if no image
      address,
    );

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register user')),
      );
    }
  }

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

  Future<void> _pickImageFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = result.files.first.bytes;
      });
    }
  }

  Future<void> _takeImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  Future<String> _uploadImage(Uint8List imageBytes) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('profiles').child(fileName);

    UploadTask uploadTask = ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'), // Your background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your new account',
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Profile Picture Upload
                    GestureDetector(
                      onTap: _pickImages,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage != null
                            ? MemoryImage(_selectedImage!)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                        child: _selectedImage == null
                            ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name Field
                    InputField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    InputField(
                      controller: _emailController,
                      hintText: 'user@mail.com',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    InputField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    InputField(
                      controller: _phoneNumberController,
                      hintText: 'Phone Number',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    InputField(
                      controller: _addressController,
                      hintText: 'Address',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 20),

                    // Register Button
                    Center(
                      child: MyButton(
                        text: 'Register',
                        onPress: _register,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Already have an account? Sign in
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black45),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
