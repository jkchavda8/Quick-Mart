import 'package:flutter/material.dart';

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('App Menu', style: TextStyle(color: Colors.white)),
          ),
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
          ListTile(
            title: const Text('Share App'),
            onTap: () {
              Navigator.pushNamed(context, '/share');
            },
          ),
          if (isLoggedIn) // Conditionally add this item if user is logged in
            ListTile(
              title: const Text('My Products'),
              onTap: () {
                Navigator.pushNamed(context, '/myProducts');
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
