import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickmartfinal/services/UserServices.dart';
import 'package:quickmartfinal/services/UserSession.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _profilePictureUrlController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  Uint8List? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = UserSession().getCurrentUser();

    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController.text = user['name'] ?? '';
        _phoneController.text = user['phone_number'] ?? '';
        _emailController.text = user['email'] ?? '';
        _profilePictureUrlController.text = user['profile_picture_url'] ?? '';
        _addressController.text = user['address'] ?? '';
        _isLoading = false;
      });
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

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    String? imageUrl;

    if (_selectedImage != null) {
      // Upload the new image and get the URL
      imageUrl = await _uploadImage(_selectedImage!);
      _profilePictureUrlController.text = imageUrl;
    }

    final updates = {
      'name': _nameController.text,
      'phone_number': _phoneController.text,
      'email': _emailController.text,
      'profile_picture_url': imageUrl ?? _profilePictureUrlController.text,
      'address': _addressController.text,
    };

    String userId = _currentUser?['user_id'] ?? '';
    await UserService().updateUser(userId, updates);

    UserSession().setCurrentUser({
      ..._currentUser!,
      ...updates,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pushNamed(context, '/home');
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
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Profile Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Display Profile Image
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? MemoryImage(_selectedImage!)
                      : (_profilePictureUrlController.text.isNotEmpty
                      ? NetworkImage(_profilePictureUrlController.text)
                      : AssetImage('assets/default_profile.png')) as ImageProvider,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImages,
                  child: Text('Change Profile Picture'),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),

              // Phone Number Field
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 10),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              SizedBox(height: 10),

              // Address Field
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
