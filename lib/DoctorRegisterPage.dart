import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({super.key});

  @override
  State<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? _selectedSpecialty;
  
  final List<String> _specialties = [
    'Cardiologist',
    'Dermatologist',
    'Endocrinologist',
    'Gastroenterologist',
    'General Practitioner',
    'Neurologist',
    'Obstetrician/Gynecologist',
    'Oncologist',
    'Ophthalmologist',
    'Orthopedic Surgeon',
    'Pediatrician',
    'Psychiatrist',
    'Radiologist',
    'Urologist',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Doctor icon
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.medical_services,
                      size: 50,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Center(
                  child: Text(
                    'Create Doctor Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Specialty dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    prefixIcon: const Icon(Icons.medical_services),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  items: _specialties.map((String specialty) {
                    return DropdownMenuItem<String>(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSpecialty = newValue;
                      if (newValue == 'Other') {
                        _specialtyController.clear();
                      } else if (newValue != null) {
                        _specialtyController.text = newValue;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your specialty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Custom specialty field (visible only when "Other" is selected)
                if (_selectedSpecialty == 'Other')
                  TextFormField(
                    controller: _specialtyController,
                    decoration: InputDecoration(
                      labelText: 'Specify Specialty',
                      prefixIcon: const Icon(Icons.medical_services),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    validator: (value) {
                      if (_selectedSpecialty == 'Other' && (value == null || value.isEmpty)) {
                        return 'Please specify your specialty';
                      }
                      return null;
                    },
                  ),
                if (_selectedSpecialty == 'Other') const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Register button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final specialty = _selectedSpecialty == 'Other' 
                            ? _specialtyController.text.trim() 
                            : _selectedSpecialty!;
                            
                        await context.read<DoctorProvider>().register(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          specialty,
                        );
                        Navigator.pushReplacementNamed(context, '/doctor_dashboard');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/doctor_login');
                      },
                      child: const Text('Login here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
