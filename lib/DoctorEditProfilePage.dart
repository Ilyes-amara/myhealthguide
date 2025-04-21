import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';

class DoctorEditProfilePage extends StatefulWidget {
  const DoctorEditProfilePage({super.key});

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _licenseController;
  
  List<Map<String, String>> _education = [];
  List<Map<String, String>> _experience = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing doctor data
    final doctorData = Provider.of<DoctorProvider>(context, listen: false).doctorData;
    
    _nameController = TextEditingController(text: doctorData['name']);
    _specialtyController = TextEditingController(text: doctorData['specialty']);
    _phoneController = TextEditingController(text: doctorData['phoneNumber']);
    _addressController = TextEditingController(text: doctorData['clinicAddress']);
    _bioController = TextEditingController(text: doctorData['bio']);
    _licenseController = TextEditingController(text: doctorData['licenseNumber']);
    
    // Copy education and experience lists
    _education = List<Map<String, String>>.from(
      (doctorData['education'] as List).map((item) => 
        Map<String, String>.from(item)
      )
    );
    
    _experience = List<Map<String, String>>.from(
      (doctorData['experience'] as List).map((item) => 
        Map<String, String>.from(item)
      )
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.person, size: 60, color: Colors.blue.shade800),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Basic Information Section
                    _buildSectionHeader('Basic Information'),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your specialty';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Contact Information Section
                    _buildSectionHeader('Contact Information'),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Clinic Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bio Section
                    _buildSectionHeader('Professional Bio'),
                    
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Education Section
                    _buildSectionHeader('Education'),
                    ..._buildEducationFields(),
                    
                    const SizedBox(height: 16),
                    
                    OutlinedButton.icon(
                      onPressed: _addEducation,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Education'),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Experience Section
                    _buildSectionHeader('Experience'),
                    ..._buildExperienceFields(),
                    
                    const SizedBox(height: 16),
                    
                    OutlinedButton.icon(
                      onPressed: _addExperience,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Experience'),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.blue.shade200),
        ],
      ),
    );
  }

  List<Widget> _buildEducationFields() {
    return _education.asMap().entries.map((entry) {
      final index = entry.key;
      final education = entry.value;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Education #${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEducation(index),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: education['degree'],
                decoration: const InputDecoration(labelText: 'Degree'),
                onChanged: (value) {
                  setState(() {
                    _education[index]['degree'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: education['institution'],
                decoration: const InputDecoration(labelText: 'Institution'),
                onChanged: (value) {
                  setState(() {
                    _education[index]['institution'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: education['year'],
                decoration: const InputDecoration(labelText: 'Year'),
                onChanged: (value) {
                  setState(() {
                    _education[index]['year'] = value;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildExperienceFields() {
    return _experience.asMap().entries.map((entry) {
      final index = entry.key;
      final experience = entry.value;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Experience #${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExperience(index),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: experience['position'],
                decoration: const InputDecoration(labelText: 'Position'),
                onChanged: (value) {
                  setState(() {
                    _experience[index]['position'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: experience['institution'],
                decoration: const InputDecoration(labelText: 'Institution'),
                onChanged: (value) {
                  setState(() {
                    _experience[index]['institution'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: experience['period'],
                decoration: const InputDecoration(labelText: 'Period (e.g., 2018-2022)'),
                onChanged: (value) {
                  setState(() {
                    _experience[index]['period'] = value;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _addEducation() {
    setState(() {
      _education.add({
        'degree': '',
        'institution': '',
        'year': '',
      });
    });
  }

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  void _addExperience() {
    setState(() {
      _experience.add({
        'position': '',
        'institution': '',
        'period': '',
      });
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experience.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedData = {
          'name': _nameController.text,
          'specialty': _specialtyController.text,
          'phoneNumber': _phoneController.text,
          'clinicAddress': _addressController.text,
          'bio': _bioController.text,
          'licenseNumber': _licenseController.text,
          'education': _education,
          'experience': _experience,
        };
        
        await Provider.of<DoctorProvider>(context, listen: false)
            .updateDoctorData(updatedData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
