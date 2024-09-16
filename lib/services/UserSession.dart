class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  Map<String, dynamic>? currentUser;

  // Method to get the current user data
  Map<String, dynamic>? getCurrentUser() {
    return currentUser;
  }

  // Method to set the current user data
  void setCurrentUser(Map<String, dynamic>? userData) {
    currentUser = userData;
  }

  // Method to clear the current user data
  void clearUser() {
    currentUser = null;
  }
}
