import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart'; // Import UserProvider

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Login'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacementNamed(context, '/login_options'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Patient icon
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 30),
              // Title
              const Text(
                'Patient Portal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Access your health information',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<UserProvider>().login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
