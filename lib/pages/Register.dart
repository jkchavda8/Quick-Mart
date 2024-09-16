import 'package:flutter/material.dart';
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
  final _profilePictureUrlController = TextEditingController();
  final _addressController = TextEditingController();

  final UserService _userService = UserService();

  Future<void> _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final phoneNumber = _phoneNumberController.text;
    final profilePictureUrl = _profilePictureUrlController.text;
    final address = _addressController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final user = await _userService.registerUser(
      name,
      email,
      password,
      phoneNumber,
      profilePictureUrl,
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

                    // Profile Picture URL Field
                    InputField(
                      controller: _profilePictureUrlController,
                      hintText: 'Profile Picture URL',
                      icon: Icons.link,
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    InputField(
                      controller: _addressController,
                      hintText: 'Address',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 20),

                    // Register Button using MyButton
                    Center(
                      child: MyButton(
                        text: 'Register',
                        onPress: _register,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Or continue with Social Media
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            color: Colors.black26,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or continue with'),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black26,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Media Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/facebook.png'), // Replace with your FB icon
                          iconSize: 40,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset('assets/google.png'), // Replace with your Google icon
                          iconSize: 40,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset('assets/apple.png'), // Replace with your Apple icon
                          iconSize: 40,
                          onPressed: () {},
                        ),
                      ],
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
