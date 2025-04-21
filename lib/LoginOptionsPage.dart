import 'package:flutter/material.dart';

class LoginOptionsPage extends StatelessWidget {
  const LoginOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade700, Colors.teal.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 60,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App name
                      const Text(
                        'My Health Guide',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Your health companion',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Login as',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Patient login option
                      _buildLoginOption(
                        context,
                        title: 'Patient',
                        icon: Icons.person,
                        color: Colors.teal,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                      const SizedBox(height: 20),
                      // Doctor login option
                      _buildLoginOption(
                        context,
                        title: 'Doctor',
                        icon: Icons.medical_services,
                        color: Colors.blue.shade800,
                        onTap: () => Navigator.pushNamed(context, '/doctor_login'),
                      ),
                      const Spacer(),
                      // Additional info text
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
