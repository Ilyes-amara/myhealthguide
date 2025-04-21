import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart'; // Import the UserProvider
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic _profileImage; // Use dynamic instead of File for web compatibility
  bool _isLoading = false;
  bool _isRefreshingHealthData = false;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Didi',
    'email': 'didi@example.com',
    'age': 28,
    'height': '175 cm',
    'weight': '70 kg',
    'bloodType': 'A+',
    'allergies': ['Peanuts', 'Dust'],
    'medications': ['Vitamin D', 'Iron supplements'],
    'healthScore': 87,
    'lastCheckup': '2024-12-10',
  };

  // Mock health metrics data
  final List<Map<String, dynamic>> _healthMetrics = [
    {
      'name': 'Heart Rate',
      'value': '72 bpm',
      'status': 'Normal',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'name': 'Blood Pressure',
      'value': '120/80',
      'status': 'Normal',
      'icon': Icons.speed,
      'color': Colors.blue,
    },
    {
      'name': 'Sleep',
      'value': '7.5 hrs',
      'status': 'Good',
      'icon': Icons.nightlight,
      'color': Colors.indigo,
    },
    {
      'name': 'Steps',
      'value': '8,456',
      'status': 'Active',
      'icon': Icons.directions_walk,
      'color': Colors.green,
    },
    {
      'name': 'Water',
      'value': '1.8 L',
      'status': 'Need more',
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
    },
    {
      'name': 'Calories',
      'value': '1,850',
      'status': 'On target',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
  ];

  // Mock appointments
  final List<Map<String, dynamic>> _appointments = [
    {
      'doctor': 'Dr. Sarah Johnson',
      'specialty': 'General Practitioner',
      'date': 'March 20, 2025',
      'time': '10:30 AM',
      'location': 'MediCare Clinic',
      'status': 'Upcoming',
    },
    {
      'doctor': 'Dr. Michael Chen',
      'specialty': 'Dentist',
      'date': 'April 5, 2025',
      'time': '2:15 PM',
      'location': 'Bright Smile Dental',
      'status': 'Upcoming',
    },
    {
      'doctor': 'Dr. Lisa Wong',
      'specialty': 'Dermatologist',
      'date': 'February 15, 2025',
      'time': '11:00 AM',
      'location': 'Skin Health Center',
      'status': 'Completed',
    },
  ];

  // Mock health activity data for charts
  List<FlSpot> _heartRateData = [
    FlSpot(0, 72),
    FlSpot(1, 75),
    FlSpot(2, 80),
    FlSpot(3, 78),
    FlSpot(4, 70),
    FlSpot(5, 73),
    FlSpot(6, 71),
  ];

  List<FlSpot> _stepsData = [
    FlSpot(0, 6500),
    FlSpot(1, 8200),
    FlSpot(2, 7400),
    FlSpot(3, 9100),
    FlSpot(4, 5800),
    FlSpot(5, 7600),
    FlSpot(6, 8400),
  ];

  // Convert sleep data to FlSpot for consistent charting
  List<FlSpot> get _sleepFlSpotData =>
      _sleepData
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList();

  // Original sleep data as simple doubles
  List<double> _sleepData = [7.5, 7.8, 8.0, 7.7, 7.9, 8.1, 7.6];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = io.File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not load image')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildEditProfileForm();
      },
    );
  }

  Widget _buildEditProfileForm() {
    final TextEditingController nameController = TextEditingController(
      text: _userData['name'],
    );
    final TextEditingController heightController = TextEditingController(
      text: _userData['height'],
    );
    final TextEditingController weightController = TextEditingController(
      text: _userData['weight'],
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: heightController,
            decoration: const InputDecoration(
              labelText: 'Height',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: weightController,
            decoration: const InputDecoration(
              labelText: 'Weight',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _userData['bloodType'],
                  items:
                      [
                        'A+',
                        'A-',
                        'B+',
                        'B-',
                        'AB+',
                        'AB-',
                        'O+',
                        'O-',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _userData['bloodType'] = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                setState(() {
                  _userData['name'] = nameController.text;
                  _userData['height'] = heightController.text;
                  _userData['weight'] = weightController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              bool confirm =
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  ) ??
                  false;

              if (confirm) {
                await userProvider.logout(); // Call the logout method
                // Navigate to login page and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverToBoxAdapter(child: _buildHealthScore()),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal,
                  tabs: const <Widget>[
                    Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                    Tab(text: 'Health Data', icon: Icon(Icons.bar_chart)),
                    Tab(text: 'Medical', icon: Icon(Icons.medical_services)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildProfileTab(),
            _buildHealthDataTab(),
            _buildMedicalTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          // Navigate to chat bot
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage as io.File)
                          : null,
                  child:
                      _profileImage == null
                          ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _userData['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _userData['email'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    _buildInfoPill('${_userData['age']} yrs'),
                    const SizedBox(width: 8),
                    _buildInfoPill(_userData['height']),
                    const SizedBox(width: 8),
                    _buildInfoPill(_userData['weight']),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHealthScore() {
    // Calculate health score based on trends
    final bool isHeartRateHealthy =
        _heartRateData.last.y >= 60 && _heartRateData.last.y <= 100;
    final bool isStepsHealthy = _stepsData.last.y >= 7000;
    final bool isSleepHealthy = _sleepData.last >= 7;

    int healthyFactors = 0;
    if (isHeartRateHealthy) healthyFactors++;
    if (isStepsHealthy) healthyFactors++;
    if (isSleepHealthy) healthyFactors++;

    final double healthScore = (healthyFactors / 3) * 100;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: healthScore),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Health Score',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: value / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            value >= 80
                                ? Colors.green
                                : value >= 60
                                ? Colors.amber
                                : Colors.red,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            value >= 80
                                ? 'Excellent'
                                : value >= 60
                                ? 'Good'
                                : 'Needs Attention',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  value >= 80
                                      ? Colors.green
                                      : value >= 60
                                      ? Colors.amber
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildHealthFactor(
                  'Heart Rate',
                  '${_heartRateData.last.y} bpm',
                  isHeartRateHealthy,
                  'Normal range: 60-100 bpm',
                ),
                const SizedBox(height: 8),
                _buildHealthFactor(
                  'Daily Steps',
                  '${_stepsData.last.y.toInt()}',
                  isStepsHealthy,
                  'Target: 10,000 steps',
                ),
                const SizedBox(height: 8),
                _buildHealthFactor(
                  'Sleep Duration',
                  '${_sleepData.last} hours',
                  isSleepHealthy,
                  'Target: 7-9 hours',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthFactor(
    String name,
    String value,
    bool isHealthy,
    String target,
  ) {
    return Row(
      children: [
        Icon(
          isHealthy ? Icons.check_circle : Icons.warning,
          color: isHealthy ? Colors.green : Colors.amber,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isHealthy
                              ? Colors.green.shade700
                              : Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                target,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Health Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ..._healthMetrics.map((metric) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: Icon(metric['icon'], color: metric['color']),
                title: Text(metric['name']),
                subtitle: Text('${metric['value']} - ${metric['status']}'),
              ),
            );
          }), // Explicitly convert to List<Widget>
          const SizedBox(height: 20),
          const Text(
            'Upcoming Appointments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ..._appointments.where((appt) => appt['status'] == 'Upcoming').map((
            appt,
          ) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  child: const Icon(Icons.calendar_today, color: Colors.teal),
                ),
                title: Text('${appt['doctor']} (${appt['specialty']})'),
                subtitle: Text('${appt['date']} at ${appt['time']}'),
                trailing: Chip(
                  label: Text(appt['status']),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ),
            );
          }), // Explicitly convert to List<Widget>
        ],
      ),
    );
  }

  Widget _buildHealthDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health Data Trends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _refreshHealthData,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      _isRefreshingHealthData
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.refresh, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChart('Heart Rate', _heartRateData, Colors.red),
          const SizedBox(height: 24),
          _buildChart('Steps', _stepsData, Colors.green),
          const SizedBox(height: 24),
          _buildChart('Sleep Hours', _sleepFlSpotData, Colors.purple),
          const SizedBox(height: 24),
          _buildHealthScore(),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuad,
                builder: (context, value, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: ChartPainter(
                      data: data,
                      primaryColor: color,
                      secondaryColor: color.withOpacity(0.2),
                      animationValue: value,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last 7 days',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Row(
                  children: [
                    Icon(
                      _getTrendIcon(data),
                      size: 16,
                      color: _getTrendColor(data),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTrendText(data),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTrendColor(data),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrendIcon(List<FlSpot> data) {
    if (data.length < 2) return Icons.trending_neutral;

    // Check if last value is higher than the day before
    final difference = data.last.y - data[data.length - 2].y;
    if (difference > 0) return Icons.trending_up;
    if (difference < 0) return Icons.trending_down;
    return Icons.trending_neutral;
  }

  Color _getTrendColor(List<FlSpot> data) {
    if (data.length < 2) return Colors.grey;

    final difference = data.last.y - data[data.length - 2].y;

    if (difference > 0) {
      // For heart rate, up is bad, for steps & sleep, up is good
      if (data == _heartRateData && data.last.y > 90) return Colors.red;
      if (data == _stepsData) return Colors.green;
      if (data == _sleepFlSpotData) return Colors.green;
    }

    if (difference < 0) {
      // For heart rate, down is good (unless too low), for steps & sleep, down is concerning
      if (data == _heartRateData) {
        if (data.last.y < 60) return Colors.amber;
        return Colors.green;
      }
      if (data == _stepsData) return Colors.red;
      if (data == _sleepFlSpotData) return Colors.red;
    }

    return Colors.grey;
  }

  String _getTrendText(List<FlSpot> data) {
    if (data.length < 2) return "No change";

    final difference = data.last.y - data[data.length - 2].y;
    final percentChange = (difference / data[data.length - 2].y * 100)
        .abs()
        .toStringAsFixed(1);

    if (difference > 0) return "Up $percentChange%";
    if (difference < 0) return "Down $percentChange%";
    return "No change";
  }

  void _refreshHealthData() {
    if (_isRefreshingHealthData) return;

    setState(() {
      _isRefreshingHealthData = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      // Generate new random data
      final random = Random();

      setState(() {
        // Update heart rate data (60-100 bpm range)
        _heartRateData = List.generate(7, (index) {
          if (index < 6) return _heartRateData[index];
          // Last value is new
          return FlSpot(index.toDouble(), 60 + random.nextDouble() * 40);
        });

        // Update steps data (5000-15000 range)
        _stepsData = List.generate(7, (index) {
          if (index < 6) return _stepsData[index];
          // Last value is new
          return FlSpot(index.toDouble(), 5000 + random.nextDouble() * 10000);
        });

        // Update sleep data (4-10 hours range)
        _sleepData = List.generate(7, (index) {
          if (index < 6) return _sleepData[index];
          // Last value is new
          return 4 + random.nextDouble() * 6;
        });

        _isRefreshingHealthData = false;
      });
    });
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Allergies',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _userData['allergies']
                    .map<Widget>((allergy) => Chip(label: Text(allergy)))
                    .toList(), // Explicitly convert to List<Widget>
          ),
          const SizedBox(height: 20),
          const Text(
            'Medications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _userData['medications']
                    .map<Widget>((med) => Chip(label: Text(med)))
                    .toList(), // Explicitly convert to List<Widget>
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'Find Doctors Near Me',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/doctor_map');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    // Get user data from provider
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceOptions(),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage:
                        _profileImage != null
                            ? (kIsWeb
                                ? NetworkImage(_profileImage!.path)
                                : FileImage(_profileImage as io.File)
                                    as ImageProvider)
                            : null,
                    child:
                        _profileImage == null
                            ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.teal.shade800,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'],
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.teal.shade800,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Health Score: ${userData['healthScore']}',
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (userProvider.hasActiveSubscription)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subscription card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text(
                        'Subscription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.hasActiveSubscription
                                ? 'Active Subscription'
                                : 'No Active Subscription',
                            style: TextStyle(
                              color:
                                  userProvider.hasActiveSubscription
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (userProvider.hasActiveSubscription &&
                              userData['subscriptionExpiry'] != null)
                            Text(
                              'Expires: ${DateTime.parse(userData['subscriptionExpiry']).toString().substring(0, 10)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/user_subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          userProvider.hasActiveSubscription
                              ? 'Manage'
                              : 'Subscribe',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickProfileImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement camera capture functionality here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Camera functionality not implemented yet',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white, // Match the app bar background color
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class ChartPainter extends CustomPainter {
  final List<FlSpot> data;
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;

  ChartPainter({
    required this.data,
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Find min and max values
    double minX = data.first.x;
    double maxX = data.first.x;
    double minY = data.first.y;
    double maxY = data.first.y;

    for (var spot in data) {
      minX = min(minX, spot.x);
      maxX = max(maxX, spot.x);
      minY = min(minY, spot.y);
      maxY = max(maxY, spot.y);
    }

    // Add padding to max and min values
    minY = max(0, minY * 0.9);
    maxY = maxY * 1.1;

    // Draw axes
    final axesPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 1;

    // Draw horizontal lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height - (size.height * (i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axesPaint);
    }

    // Function to convert data points to canvas coordinates
    Offset getPointPosition(FlSpot spot) {
      final double x = ((spot.x - minX) / (maxX - minX)) * size.width;
      final double y =
          size.height - ((spot.y - minY) / (maxY - minY)) * size.height;
      return Offset(x, y);
    }

    // Create line path
    final linePath = Path();
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final point = getPointPosition(data[i]);
      points.add(point);

      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
      }
    }

    // Draw line
    final linePaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final animatedPath = Path();
    final pathMetrics = linePath.computeMetrics().first;
    final extractPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * animationValue,
    );
    animatedPath.addPath(extractPath, Offset.zero);

    canvas.drawPath(animatedPath, linePaint);

    // Draw points
    final pointPaint = Paint()..color = primaryColor;

    final visiblePoints = (data.length * animationValue).floor();
    for (var i = 0; i < visiblePoints; i++) {
      final point = points[i];
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.animationValue != animationValue;
  }
}
