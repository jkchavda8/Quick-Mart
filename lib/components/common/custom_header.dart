import 'package:flutter/material.dart';
import 'package:quickmartfinal/components/common/custom_drawer.dart'; // Import the CustomDrawer widget
import 'package:quickmartfinal/components/custom_search_delegate.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoggedIn;
  final VoidCallback onLoginLogoutPressed;

  const CustomHeader({
    Key? key,
    required this.title,
    required this.isLoggedIn,
    required this.onLoginLogoutPressed,
  }) : super(key: key);

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Modern white background
      elevation: 4, // Added shadow for depth
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.deepPurpleAccent, // Dark text color for contrast
          fontSize: 20, // Slightly larger font size
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5, // Modern letter spacing
        ),
      ),
      centerTitle: true, // Center the title for a clean look
      actions: [
        IconButton(
          icon: Icon(
            isLoggedIn ? Icons.logout : Icons.login,
            color: Colors.black, // Change icon color for consistency
          ),
          onPressed: onLoginLogoutPressed,
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black), // Black search icon
          onPressed: () {
            // Trigger search functionality
            showSearch(context: context, delegate: CustomSearchDelegate(context: context));
          },
        ),
      ],
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black), // Black menu icon
            onPressed: () => _openDrawer(context), // Open the drawer
          );
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20), // Rounded bottom for modern touch
        ),
      ),
      shadowColor: Colors.grey.withOpacity(0.5), // Softer shadow
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
