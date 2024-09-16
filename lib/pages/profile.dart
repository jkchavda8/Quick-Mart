import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _profilePictureUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the user data here and set the controllers' initial values
    // Example:
    // _nameController.text = 'John Doe';
    // _phoneController.text = '+1234567890';
    // _emailController.text = 'john.doe@example.com';
    // _profilePictureUrlController.text = 'http://example.com/profile.jpg';
  }

  void _updateProfile() {
    // Implement profile update logic
    final name = _nameController.text;
    final phone = _phoneController.text;
    final email = _emailController.text;
    final profilePictureUrl = _profilePictureUrlController.text;

    // Validate and update profile data here

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Profile Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            ),
            SizedBox(height: 10),

            // Profile Picture URL Field
            TextField(
              controller: _profilePictureUrlController,
              decoration: InputDecoration(labelText: 'Profile Picture URL'),
            ),
            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
            ),
            SizedBox(height: 20),

            // Change Password Button
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         // builder: (context) => ChangePasswordPage(),
            //       ),
            //     );
            //   },
            //   child: Text('Change Password'),
            // ),
          ],
        ),
      ),
    );
  }
}
