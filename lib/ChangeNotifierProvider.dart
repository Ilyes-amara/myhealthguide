import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // Private user data (immutable)
  Map<String, dynamic> _userData = {
    'name': '',
    'email': '',
    'age': 0,
    'height': '',
    'weight': '',
    'bloodType': '',
    'allergies': [],
    'medications': [],
    'healthScore': 0,
    'lastCheckup': '',
  };

  // Authentication state
  bool _isLoggedIn = false;

  // Getters
  Map<String, dynamic> get userData => Map<String, dynamic>.unmodifiable(_userData);
  bool get isLoggedIn => _isLoggedIn;

  // Login method with validation
  Future<void> login(String email, String password) async {
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update user data (immutable copy)
    _userData = {
      'name': 'Didi',
      'email': email,
      'age': 28,
      'height': '175 cm',
      'weight': '70 kg',
      'bloodType': 'A+',
      'allergies': ['Peanuts', 'Dust'],
      'medications': ['Vitamin D', 'Iron supplements'],
      'healthScore': calculateHealthScore(),
      'lastCheckup': '2024-12-10',
    };
    _isLoggedIn = true;

    notifyListeners(); // Notify listeners
  }

  // Logout method
  void logout() {
    _userData = {
      'name': '',
      'email': '',
      'age': 0,
      'height': '',
      'weight': '',
      'bloodType': '',
      'allergies': [],
      'medications': [],
      'healthScore': 0,
      'lastCheckup': '',
    };
    _isLoggedIn = false;

    notifyListeners(); // Notify listeners
  }

  // Update user data (immutable copy)
  void updateUserData(Map<String, dynamic> newData) {
    _userData = Map<String, dynamic>.from(newData);
    _userData['healthScore'] = calculateHealthScore();

    notifyListeners(); // Notify listeners
  }

  // Calculate health score dynamically
  int calculateHealthScore() {
    int score = 100;

    if (_userData['allergies'].isNotEmpty) score -= 10;
    if (_userData['medications'].isNotEmpty) score -= 5;
    if (_userData['lastCheckup'].isEmpty) score -= 15;

    return score.clamp(0, 100);
  }

  // Email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}