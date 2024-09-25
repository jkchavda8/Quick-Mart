import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickmartfinal/services/UserServices.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> startApp() async {
    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn');

      // Check if isLoggedIn is not null
      if (isLoggedIn != null && isLoggedIn) {
        var email = prefs.getString('email');
        var password = prefs.getString('password');
        if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
          try {
            await UserService().loginUser(email, password);
            // Navigate to the home page after successful login
            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            // Handle login failure (you can show a dialog or a message)
            print('Login failed: $e');
            Navigator.pushReplacementNamed(context, '/login'); // Navigate to login if login fails
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login'); // Navigate to login if email/password is empty
        }
      } else {
        // If not logged in, navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Center(
        child: LoadingAnimationWidget.halfTriangleDot(
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }
}
