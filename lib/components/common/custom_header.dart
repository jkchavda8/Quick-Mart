import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoggedIn;
  final VoidCallback onLoginLogoutPressed;
  final VoidCallback onMenuPressed;

  const CustomHeader({
    Key? key,
    required this.title,
    required this.isLoggedIn,
    required this.onLoginLogoutPressed,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
          onPressed: onLoginLogoutPressed,
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
