import 'package:flutter/material.dart';
import 'package:quickmartfinal/services/UserSession.dart'; // Import your UserSession class

class CustomDrawer extends StatelessWidget {
  final String appVersion;
  final bool isLoggedIn;

  const CustomDrawer({
    Key? key,
    required this.appVersion,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the user details from UserSession
    final user = UserSession().getCurrentUser();
    final profilePictureUrl = user?['profile_picture_url']; // Profile picture URL
    final userName = user?['name'] ?? 'Guest'; // Show 'Guest' if user not logged in

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl) // Show profile picture if available
                      : null, // Otherwise, show default icon
                  child: profilePictureUrl == null || profilePictureUrl.isEmpty
                      ? const Icon(Icons.person, size: 50) // Default user icon
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  isLoggedIn ? userName : 'Guest', // Show user name if logged in, else 'Guest'
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          if (isLoggedIn)
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            title: const Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          if (isLoggedIn) // Conditionally add this item if user is logged in
            ListTile(
              title: const Text('My Products'),
              onTap: () {
                Navigator.pushNamed(context, '/myProducts');
              },
            ),
          if (isLoggedIn) // Conditionally show the Wishlist if the user is logged in
            ListTile(
              title: const Text('Wishlist'), // Add Wishlist item here
              onTap: () {
                Navigator.pushNamed(context, '/wishlist'); // Navigate to the Wishlist page
              },
            ),
          ListTile(
            title: Text('App Version: $appVersion'),
          ),
        ],
      ),
    );
  }
}
