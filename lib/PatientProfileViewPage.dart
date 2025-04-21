import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';
import 'DoctorChatbotPage.dart';

class PatientProfileViewPage extends StatefulWidget {
  final String patientId;

  const PatientProfileViewPage({super.key, required this.patientId});

  @override
  _PatientProfileViewPageState createState() => _PatientProfileViewPageState();
}

class _PatientProfileViewPageState extends State<PatientProfileViewPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPatientData();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final patientData = await doctorProvider.getPatientProfile(
      widget.patientId,
    );

    setState(() {
      _patientData = patientData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading
              ? 'Patient Profile'
              : 'Profile: ${_patientData?['name'] ?? 'Unknown'}',
        ),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              if (_patientData != null) {
                // Open chat with patient or send message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messaging feature coming soon'),
                  ),
                );
              }
            },
            tooltip: 'Message Patient',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              if (_patientData != null) {
                // Call patient
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${_patientData!['phone']}')),
                );
              }
            },
            tooltip: 'Call Patient',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _patientData == null
              ? const Center(
                child: Text(
                  'Patient data not found',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientHeader(),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        'Personal Information',
                        _buildPersonalInfo(),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Medical Information',
                        _buildMedicalInfo(),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Medical History',
                        _buildMedicalHistory(),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Current Medications',
                        _buildMedications(),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to appointment scheduling
          Navigator.pushNamed(context, '/doctor_availability');
        },
        backgroundColor: Colors.blue.shade800,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Schedule Appointment'),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Hero(
      tag: 'patient_${_patientData!['id']}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                _patientData!['name'].substring(0, 1),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _patientData!['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _patientData!['gender'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _patientData!['phone'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _patientData!['email'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(_patientData!['status']),
                      const SizedBox(width: 8),
                      if (_patientData!['insuranceProvider'] != null)
                        _buildInsuranceChip(_patientData!['insuranceProvider']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData chipIcon;

    switch (status) {
      case 'Active':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'Inactive':
        chipColor = Colors.grey;
        chipIcon = Icons.cancel;
        break;
      case 'Pending':
        chipColor = Colors.orange;
        chipIcon = Icons.watch_later;
        break;
      default:
        chipColor = Colors.blue;
        chipIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceChip(String provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.health_and_safety, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            provider,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final birthDate = _patientData!['dateOfBirth'];
    final age = DateTime.now().year - DateTime.parse(birthDate).year;

    return Column(
      children: [
        _buildInfoRow('Date of Birth', '$birthDate (Age: $age)'),
        _buildInfoRow('Email', _patientData!['email']),
        _buildInfoRow('Phone', _patientData!['phone']),
        _buildInfoRow('Last Visit', _patientData!['lastVisit']),
      ],
    );
  }

  Widget _buildMedicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Blood Type', _patientData!['bloodType']),
        const SizedBox(height: 8),
        const Text('Allergies:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              (_patientData!['allergies'] as List).map((allergy) {
                return Chip(
                  label: Text(allergy),
                  backgroundColor:
                      allergy == 'None'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conditions:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._buildListItems(_patientData!['medicalHistory'] as List),
      ],
    );
  }

  Widget _buildMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [..._buildListItems(_patientData!['medications'] as List)],
    );
  }

  List<Widget> _buildListItems(List items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(item)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.note_add,
          label: 'Add Note',
          onTap: () {
            // Add medical note
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add note feature coming soon')),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.medication,
          label: 'Prescribe',
          onTap: () {
            // Prescribe medication
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescription feature coming soon')),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.medical_services,
          label: 'Lab Tests',
          onTap: () {
            // Order lab tests
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lab test ordering feature coming soon'),
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.history,
          label: 'History',
          onTap: () {
            // View complete history
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Complete history feature coming soon'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue.shade800),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
            ),
          ],
        ),
      ),
    );
  }
}
