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
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
          onPressed: onLoginLogoutPressed,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Trigger search functionality
            showSearch(context: context, delegate: CustomSearchDelegate(context: context));
          },
        ),
      ],
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _openDrawer(context), // Open the drawer
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
