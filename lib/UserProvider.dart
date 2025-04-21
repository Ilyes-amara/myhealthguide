import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  // User data stored in a Map
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
    'subscriptionStatus': 'none', // none, active, expired
    'subscriptionExpiry': null, // DateTime.now().toString()
    'subscriptionAmount': 1000, // Monthly subscription amount in DA
  };

  // Authentication state
  bool _isLoggedIn = false;

  // Getters for user data and login status
  Map<String, dynamic> get userData => _userData;
  bool get isLoggedIn => _isLoggedIn;

  // Check if subscription is active
  bool get hasActiveSubscription =>
      _userData['subscriptionStatus'] == 'active' &&
      (_userData['subscriptionExpiry'] != null
          ? DateTime.parse(
            _userData['subscriptionExpiry'],
          ).isAfter(DateTime.now())
          : false);

  // Initialize user data from local storage
  Future<void> initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _userData = Map<String, dynamic>.from(jsonDecode(userDataString));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Login method with basic validation
  Future<void> login(String email, String password) async {
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Simulate an API call with a delay
    await Future.delayed(const Duration(seconds: 2));

    // Check for predefined account
    if (email == 'i@gmail.com' && password == '123456') {
      _userData = {
        'name': 'Ilyes Amara',
        'email': 'i@gmail.com',
        'age': 32,
        'height': '180 cm',
        'weight': '75 kg',
        'bloodType': 'O+',
        'allergies': ['Penicillin'],
        'medications': ['Vitamin C', 'Omega-3'],
        'healthScore': 85,
        'lastCheckup': '2025-02-15',
        'id': 'P12345',
        'phone': '+216 55 123 456',
        'gender': 'Male',
        'address': '123 Tunis Street, Tunis',
        'insuranceProvider': 'MedAssist Premium',
        'emergencyContact': 'Sarah Amara: +216 55 789 012',
        'chronicConditions': ['Mild Hypertension'],
        'status': 'Active',
        'subscriptionStatus': 'active',
        'subscriptionExpiry':
            DateTime.now().add(const Duration(days: 30)).toString(),
        'subscriptionAmount': 1000,
      };
      _isLoggedIn = true;
      await _saveUserDataLocally();
      notifyListeners();
      return;
    }

    // Update user data for other accounts
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
      'subscriptionStatus': 'none',
      'subscriptionExpiry': null,
      'subscriptionAmount': 1000,
    };
    _isLoggedIn = true;

    // Save user data to local storage
    await _saveUserDataLocally();
    notifyListeners();
  }

  // Register method with basic validation
  Future<void> register(String name, String email, String password) async {
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    // Check if trying to register with predefined account email
    if (email == 'i@gmail.com') {
      throw Exception(
        'This email is already registered. Please try logging in instead.',
      );
    }

    // Simulate an API call with a delay
    await Future.delayed(const Duration(seconds: 2));

    // Update user data
    _userData = {
      'name': name,
      'email': email,
      'age': 28, // Default value
      'height': '175 cm',
      'weight': '70 kg',
      'bloodType': 'A+',
      'allergies': ['Peanuts', 'Dust'],
      'medications': ['Vitamin D', 'Iron supplements'],
      'healthScore': calculateHealthScore(),
      'lastCheckup': '2024-12-10',
      'subscriptionStatus': 'none',
      'subscriptionExpiry': null,
      'subscriptionAmount': 1000,
    };
    _isLoggedIn = true;

    // Save user data to local storage
    await _saveUserDataLocally();
    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
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
      'subscriptionStatus': 'none',
      'subscriptionExpiry': null,
      'subscriptionAmount': 1000,
    };
    _isLoggedIn = false;

    // Clear user data from local storage
    await _clearUserDataLocally();
    notifyListeners();
  }

  // Update user profile data
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    _userData = newData;
    _userData['healthScore'] = calculateHealthScore();

    // Save updated user data to local storage
    await _saveUserDataLocally();
    notifyListeners();
  }

  // Validate email address
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Calculate health score dynamically
  int calculateHealthScore() {
    int score = 100; // Base score

    if (_userData['allergies'].isNotEmpty) score -= 10;
    if (_userData['medications'].isNotEmpty) score -= 5;
    if (_userData['lastCheckup'].isEmpty) score -= 15;

    return score.clamp(0, 100); // Ensure score stays within 0-100 range
  }

  // Add subscription
  Future<void> activateSubscription(int months) async {
    final now = DateTime.now();
    final expiryDate = DateTime(
      now.year,
      now.month + months,
      now.day,
      now.hour,
      now.minute,
    );

    _userData['subscriptionStatus'] = 'active';
    _userData['subscriptionExpiry'] = expiryDate.toString();

    await _saveUserDataLocally();
    notifyListeners();
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    _userData['subscriptionStatus'] = 'expired';

    await _saveUserDataLocally();
    notifyListeners();
  }

  // Save user data to local storage
  Future<void> _saveUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', jsonEncode(_userData));
  }

  // Clear user data from local storage
  Future<void> _clearUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user_data');
  }
}
