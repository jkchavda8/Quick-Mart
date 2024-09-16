import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package
import 'package:quickmartfinal/services/UserSession.dart'; // Import the UserSession class

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionPath = 'users';
  final Uuid _uuid = const Uuid(); // Initialize Uuid

  // Method to register a new user
  Future<Map<String, dynamic>?> registerUser(String name, String email, String password, String phoneNumber, String profilePictureUrl, String address) async {
    try {
      // Generate a custom user ID using uuid
      String userId = _uuid.v4();

      // Prepare the user data
      Map<String, dynamic> userData = {
        'user_id': userId,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'profile_picture_url': profilePictureUrl,
        'address': address,
        'password': password, // Store hashed password in production
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add user data directly to Firestore
      await _db.collection(collectionPath).doc(userId).set(userData);

      UserSession().setCurrentUser(userData);
      // Return the user data
      return userData;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }


  // Method to login a user
  Future<bool> loginUser(String email, String password) async {
    try {
      // Retrieve the list of users from Firestore
      List<Map<String, dynamic>> users = await getUsers();

      // Iterate through the list of users
      for (var user in users) {
        // Check if the email and password match
        if (user['email'] == email && user['password'] == password) {
          UserSession().setCurrentUser(user);
          return true; // Credentials are valid
        }
      }

      // No match found
      return false;
    } catch (e) {
      // Log the error
      print('Error logging in user: $e');

      // Return false if there's an error
      return false;
    }
  }
  // Method to get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final QuerySnapshot snapshot = await _db.collection(collectionPath).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Method to get a user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final DocumentSnapshot doc = await _db.collection(collectionPath).doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Method to update an existing user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(collectionPath).doc(userId).update({
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Method to delete a user by ID
  Future<void> deleteUserById(String userId) async {
    try {
      await _db.collection(collectionPath).doc(userId).delete();
    } catch (e) {
      print('Error deleting user by ID: $e');
    }
  }
}
