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
  startApp() {
    Timer(Duration(seconds: 1), () async {
      // Navigate to the login page using named routes
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn');
      if(isLoggedIn!){
        var email = prefs.getString('email');
        var password = prefs.getString('password');
        if(email != '' && password != ''){
          await UserService().loginUser(email!, password!);
        }
      }
      Navigator.pushReplacementNamed(context, '/home');
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
