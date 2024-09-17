import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quickmartfinal/pages/AddCategory.dart';
import 'package:quickmartfinal/pages/AddProduct.dart';
import 'package:quickmartfinal/pages/MyProductspage.dart';
import 'package:quickmartfinal/pages/WishListPage.dart';
import 'package:quickmartfinal/pages/product_details_page.dart';
import 'firebase_options.dart';
import 'package:quickmartfinal/pages/Register.dart';
import 'package:quickmartfinal/pages/Login.dart';
import 'package:quickmartfinal/pages/home_page.dart';
import 'package:quickmartfinal/pages/about_us_page.dart';
import 'package:quickmartfinal/pages/settings_page.dart';
import 'package:quickmartfinal/components/Splash_screen.dart';
import 'package:quickmartfinal/pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      appId: FirebaseConfig.appId,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/settings':
            return MaterialPageRoute(builder: (context) => const SettingsPage());
          case '/about':
            return MaterialPageRoute(builder: (context) => const AboutUsPage());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfilePage());
          case '/addProduct':
            return MaterialPageRoute(builder: (context) => const AddProductPage());
          case '/addCategory':
            return MaterialPageRoute(builder: (context) => const AddCategoryPage());
          case '/wishlist':
            return MaterialPageRoute(builder: (context) => WishlistPage());
            case '/myProducts':
            return MaterialPageRoute(builder: (context) => const MyProductsPage());
          case '/productDetails':
            final args = settings.arguments as Map<String, dynamic>?;
            final productId = args?['productId'] as String?;
            if (productId == null || productId.isEmpty) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('Invalid product ID')),
                ),
              );
            }
            print(productId);
            return MaterialPageRoute(
              builder: (context) => ProductDetailsPage(productId: productId),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(body: Center(child: Text('Page not found'))),
            );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
