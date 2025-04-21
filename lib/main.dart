import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ChatBotPage.dart';
import 'UserProfilePage.dart';
import 'UserProvider.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'DoctorMapScreen.dart';
import 'WorkoutPage.dart';
import 'DietPlanPage.dart';
import 'MedicationPage.dart';
import 'DoctorSearchPage.dart';
import 'dart:math';
import 'dart:async';
import 'DoctorLoginPage.dart';
import 'DoctorRegisterPage.dart';
import 'DoctorDashboardPage.dart';
import 'DoctorEditProfilePage.dart';
import 'LoginOptionsPage.dart';
import 'DoctorProvider.dart';
import 'DoctorAvailabilityPage.dart';
import 'DoctorSubscriptionPage.dart';
import 'PaymentProcessingPage.dart';
import 'UserSubscriptionPage.dart';
import 'UserPaymentProcessingPage.dart';
import 'PatientDoctorChatPage.dart';
import 'services/HealthAnalyticsService.dart';

// List of doctors that will be accessible by the map screen
final List<Map<String, dynamic>> doctorsList = [
  {'name': 'Dr. Jane Doe', 'specialty': 'Cardiologist', 'distance': 0.8},
  {'name': 'Dr. John Smith', 'specialty': 'Dermatologist', 'distance': 1.2},
  {'name': 'Dr. Maria Garcia', 'specialty': 'Pediatrician', 'distance': 2.5},
  {
    'name': 'Dr. Alex Johnson',
    'specialty': 'Orthopedic Surgeon',
    'distance': 3.0,
  },
  {'name': 'Dr. Emily Davis', 'specialty': 'Neurologist', 'distance': 4.0},
  {'name': 'Dr. Ilyes Amara', 'specialty': 'Generalist', 'distance': 1.0},
  {'name': 'Dr. Islem Smimani', 'specialty': 'Cardiologist', 'distance': 4.0},
];

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            // Initialize the UserProvider and its data
            final provider = UserProvider();
            provider
                .initUserData(); // This will attempt to load data from storage
            return provider;
          },
        ), // Provide UserProvider
        ChangeNotifierProvider(
          create: (_) {
            // Initialize the DoctorProvider and its data
            final provider = DoctorProvider();
            provider
                .initDoctorData(); // This will attempt to load data from storage
            return provider;
          },
        ), // Provide DoctorProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Enhanced app theme
        brightness: Brightness.light,
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Add custom button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginOptionsPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => const HomePage(),
        '/doctor_map': (context) => DoctorMapScreen(doctors: doctorsList),
        '/workout': (context) => WorkoutPage(),
        '/diet_plan': (context) => DietPlanPage(),
        '/medication': (context) => MedicationPage(),
        '/doctor_search': (context) => DoctorSearchPage(),
        '/login_options': (context) => const LoginOptionsPage(),
        '/doctor_login': (context) => DoctorLoginPage(),
        '/doctor_register': (context) => const DoctorRegisterPage(),
        '/doctor_dashboard': (context) => const DoctorDashboardPage(),
        '/doctor_edit_profile': (context) => const DoctorEditProfilePage(),
        '/doctor_availability': (context) => const DoctorAvailabilityPage(),
        '/doctor_subscription': (context) => const DoctorSubscriptionPage(),
        '/payment_processing': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return PaymentProcessingPage(
            months: args['months'],
            amount: args['amount'],
          );
        },
        '/user_subscription': (context) => const UserSubscriptionPage(),
        '/user_payment_processing': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return UserPaymentProcessingPage(
            months: args['months'],
            amount: args['amount'],
          );
        },
        '/patient_doctor_chat':
            (context) => PatientDoctorChatPage.routeWithArguments(context),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    HealthChatBot(topic: 'Health'), // Pass required parameters
    const UserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Check login status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final doctorProvider = Provider.of<DoctorProvider>(
        context,
        listen: false,
      );

      // If neither a user nor a doctor is logged in, redirect to login options
      if (!userProvider.isLoggedIn && !doctorProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login_options');
      }
      // If a doctor is logged in, redirect to doctor dashboard
      else if (doctorProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/doctor_dashboard');
      }
      // If only a user is logged in, stay on the home page
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat Bot',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ChatBotPage extends StatelessWidget {
  final String topic;
  final dynamic userModel;

  const ChatBotPage({super.key, required this.topic, this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Bot'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Topic: $topic',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Chat Bot Page', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class OldWorkoutPage extends StatelessWidget {
  const OldWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(child: Text('This is the Workout Page')),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _distanceFilter = 20.0;

  // For pull to refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  // Animation controller for animated transitions
  late AnimationController _animationController;

  // Dynamic health metrics
  bool _refreshingMetrics = false;
  int _heartRate = 68;
  String _heartRateChange = '+3';
  List<double> _heartRateData = [65, 67, 70, 66, 68, 72, 68];

  String _bloodPressure = '120/80';
  String _bloodPressureChange = '-5';
  List<double> _bloodPressureData = [125, 122, 118, 120, 121, 119, 120];

  double _weight = 68.5;
  String _weightChange = '-0.5';
  List<double> _weightData = [70, 69.5, 69, 69, 68.7, 68.5, 68.5];

  double _sleepHours = 7.33; // 7h 20m in decimal
  String _sleepChange = '+40m';
  List<double> _sleepData = [6.5, 6.7, 7.0, 6.8, 7.2, 7.5, 7.33];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Simulate periodic data updates
    Timer.periodic(const Duration(minutes: 10), (timer) {
      if (mounted) {
        _updateHealthMetrics();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Method to simulate updating metrics with random variations
  void _updateHealthMetrics() {
    // Update heart rate (random variation ±3)
    final Random random = Random();
    final int heartRateChange = random.nextInt(7) - 3; // -3 to +3
    final int newHeartRate = _heartRate + heartRateChange;

    // Update blood pressure
    final int systolicChange = random.nextInt(5) - 2; // -2 to +2
    final int diastolicChange = random.nextInt(5) - 2; // -2 to +2
    final List<String> bpParts = _bloodPressure.split('/');
    final int newSystolic = int.parse(bpParts[0]) + systolicChange;
    final int newDiastolic = int.parse(bpParts[1]) + diastolicChange;

    // Update weight (random variation ±0.2)
    final double weightChange = (random.nextInt(5) - 2) / 10; // -0.2 to +0.2
    final double newWeight = _weight + weightChange;

    // Update sleep (random variation ±15 minutes)
    final double sleepChange =
        (random.nextInt(7) - 3) / 4; // -0.75 to +0.75 (in quarter hours)
    final double newSleep = max(
      4.0,
      min(10.0, _sleepHours + sleepChange),
    ); // Keep between 4 and 10 hours

    setState(() {
      // Update heart rate
      _heartRate = newHeartRate;
      _heartRateChange =
          heartRateChange >= 0 ? '+$heartRateChange' : '$heartRateChange';
      _heartRateData = [..._heartRateData.sublist(1), newHeartRate.toDouble()];

      // Update blood pressure
      _bloodPressure = '$newSystolic/$newDiastolic';
      final int avgBPChange = (systolicChange + diastolicChange) ~/ 2;
      _bloodPressureChange =
          avgBPChange >= 0 ? '+$avgBPChange' : '$avgBPChange';
      _bloodPressureData = [
        ..._bloodPressureData.sublist(1),
        newSystolic.toDouble(),
      ];

      // Update weight
      _weight = newWeight;
      _weightChange =
          weightChange >= 0
              ? '+${weightChange.toStringAsFixed(1)}'
              : weightChange.toStringAsFixed(1);
      _weightData = [..._weightData.sublist(1), newWeight];

      // Update sleep
      _sleepHours = newSleep;
      final int sleepMinChange = (sleepChange * 60).round();
      _sleepChange =
          sleepMinChange >= 0 ? '+${sleepMinChange}m' : '${sleepMinChange}m';
      _sleepData = [..._sleepData.sublist(1), newSleep];
    });

    // Animate the updates
    _animationController.reset();
    _animationController.forward();
  }

  // Pull to refresh implementation
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Update health metrics
    _updateHealthMetrics();

    setState(() {
      _isRefreshing = false;
    });

    // Show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health data refreshed successfully!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }

    return;
  }

  final List<Map<String, dynamic>> _doctors = [
    {'name': 'Dr. Jane Doe', 'specialty': 'Cardiologist', 'distance': 0.8},
    {'name': 'Dr. John Smith', 'specialty': 'Dermatologist', 'distance': 1.2},
    {'name': 'Dr. Maria Garcia', 'specialty': 'Pediatrician', 'distance': 2.5},
    {
      'name': 'Dr. Alex Johnson',
      'specialty': 'Orthopedic Surgeon',
      'distance': 3.0,
    },
    {'name': 'Dr. Emily Davis', 'specialty': 'Neurologist', 'distance': 4.0},
    {'name': 'Dr. Ilyes Amara', 'specialty': 'Generalist', 'distance': 1.0},
    {'name': 'Dr. Islem Smimani', 'specialty': 'Cardiologist', 'distance': 4.0},
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_searchQuery.isEmpty && _distanceFilter >= 20.0) return _doctors;
    return _doctors.where((doctor) {
      final nameMatch = doctor['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final specialtyMatch = doctor['specialty']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final distanceMatch = doctor['distance'] <= _distanceFilter;
      return (nameMatch || specialtyMatch) && distanceMatch;
    }).toList();
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location, color: Colors.teal),
                ),
                title: const Text('Use current location'),
                subtitle: const Text('Using GPS'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for location',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Saved Locations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildLocationItem(
                      context,
                      title: 'Home',
                      address: '123 Main Street, Downtown',
                      icon: Icons.home,
                    ),
                    _buildLocationItem(
                      context,
                      title: 'Work',
                      address: '456 Business Ave, Financial District',
                      icon: Icons.work,
                    ),
                    _buildLocationItem(
                      context,
                      title: 'Gym',
                      address: '789 Fitness Blvd, Westside',
                      icon: Icons.fitness_center,
                    ),
                    _buildLocationItem(
                      context,
                      title: "Mom's House",
                      address: '321 Family Lane, Suburbs',
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add New Location'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationItem(
    BuildContext context, {
    required String title,
    required String address,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.teal),
      ),
      title: Text(title),
      subtitle: Text(address),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: Colors.teal,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserStatsSummary(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.grey[300]),
                ),
                _buildHealthMetricsSection(context),
                const SizedBox(height: 24),
                _buildHealthInsightsSection(context),
                const SizedBox(height: 24),
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
                _buildTodayScheduleSection(context),
                const SizedBox(height: 24),
                _buildHealthRemindersSection(context),
                const SizedBox(height: 24),
                _buildEnhancedDoctorSearch(context),
                const SizedBox(height: 24),
                _buildTopDoctorsSection(context),
                const SizedBox(height: 24),
                _buildHealthContentSection(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserStatsSummary(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade500, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, DIDI!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tuesday, February 26',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Steps Stat
                Column(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1,820',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Steps',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                // Heart Rate Stat
                Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      '68',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Heart Rate',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                // Water Stat
                Column(
                  children: [
                    Icon(Icons.local_drink, color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      '6/8',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Water',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                // Sleep Stat
                Column(
                  children: [
                    Icon(Icons.nightlight, color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      '7h 20m',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Sleep',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildHealthMetricsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _selectHeader(title: 'Health Metrics'),
            InkWell(
              onTap: () {
                setState(() {
                  // Simulate refreshing data
                  _refreshingMetrics = true;
                });

                // Simulate data refresh with a short delay
                Future.delayed(const Duration(milliseconds: 1500), () {
                  setState(() {
                    _refreshingMetrics = false;
                    // Simulate updated metrics with slight variations
                    _updateHealthMetrics();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Health metrics updated from your devices'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    _refreshingMetrics
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.teal,
                          ),
                        )
                        : const Icon(Icons.sync, color: Colors.teal, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ListView(
              key: ValueKey<int>(
                _heartRate,
              ), // This forces the rebuild when data changes
              scrollDirection: Axis.horizontal,
              children: [
                _buildMetricCard(
                  context,
                  title: 'Heart Rate',
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  value: '$_heartRate',
                  unit: 'bpm',
                  change: _heartRateChange,
                  chartData: _heartRateData,
                  onTap: () => _showMetricDetailDialog(context, 'Heart Rate'),
                ),
                _buildMetricCard(
                  context,
                  title: 'Blood Pressure',
                  icon: Icons.show_chart,
                  color: Colors.purpleAccent,
                  value: _bloodPressure,
                  unit: 'mmHg',
                  change: _bloodPressureChange,
                  chartData: _bloodPressureData,
                  onTap:
                      () => _showMetricDetailDialog(context, 'Blood Pressure'),
                ),
                _buildMetricCard(
                  context,
                  title: 'Weight',
                  icon: Icons.monitor_weight,
                  color: Colors.orangeAccent,
                  value: _weight.toStringAsFixed(1),
                  unit: 'kg',
                  change: _weightChange,
                  chartData: _weightData,
                  onTap: () => _showMetricDetailDialog(context, 'Weight'),
                ),
                _buildMetricCard(
                  context,
                  title: 'Sleep',
                  icon: Icons.nightlight,
                  color: Colors.blueAccent,
                  value: _formatSleepHours(_sleepHours),
                  unit: 'hrs',
                  change: _sleepChange,
                  chartData: _sleepData,
                  onTap: () => _showMetricDetailDialog(context, 'Sleep'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMetricDetailDialog(BuildContext context, String metricName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Hero(
              tag: 'metric_$metricName',
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              metricName == 'Heart Rate'
                                  ? Icons.favorite
                                  : metricName == 'Blood Pressure'
                                  ? Icons.show_chart
                                  : metricName == 'Weight'
                                  ? Icons.monitor_weight
                                  : Icons.nightlight,
                              color:
                                  metricName == 'Heart Rate'
                                      ? Colors.redAccent
                                      : metricName == 'Blood Pressure'
                                      ? Colors.purpleAccent
                                      : metricName == 'Weight'
                                      ? Colors.orangeAccent
                                      : Colors.blueAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$metricName Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text(
                              metricName == 'Heart Rate'
                                  ? 'Current: $_heartRate bpm'
                                  : metricName == 'Blood Pressure'
                                  ? 'Current: $_bloodPressure mmHg'
                                  : metricName == 'Weight'
                                  ? 'Current: ${_weight.toStringAsFixed(1)} kg'
                                  : 'Current: ${_formatSleepHours(_sleepHours)} hrs',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text(
                              metricName == 'Heart Rate'
                                  ? 'Trend: $_heartRateChange'
                                  : metricName == 'Blood Pressure'
                                  ? 'Trend: $_bloodPressureChange'
                                  : metricName == 'Weight'
                                  ? 'Trend: $_weightChange'
                                  : 'Trend: $_sleepChange',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    (metricName == 'Heart Rate' &&
                                                _heartRateChange.startsWith(
                                                  '+',
                                                ) ||
                                            metricName == 'Blood Pressure' &&
                                                _bloodPressureChange.startsWith(
                                                  '-',
                                                ) ||
                                            metricName == 'Weight' &&
                                                _weightChange.startsWith('-') ||
                                            metricName == 'Sleep' &&
                                                _sleepChange.startsWith('+'))
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '30-Day History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: value,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Interactive chart will be displayed here',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$metricName data exported'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Data'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$metricName goal set'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.flag),
                            label: const Text('Set Goal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatSleepHours(double hours) {
    int h = hours.floor();
    int m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    required String change,
    required List<double> chartData,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: 'metric_$title',
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                change.startsWith('+')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            change,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  change.startsWith('+')
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          chartData.length,
                          (index) => TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end:
                                  (chartData[index] /
                                      chartData.reduce(
                                        (a, b) => a > b ? a : b,
                                      )) *
                                  40,
                            ),
                            duration: Duration(milliseconds: 300 + index * 100),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Container(
                                width: 6,
                                height: value,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/workout');
                },
                child: _buildActionButton(
                  context,
                  icon: Icons.fitness_center,
                  label: 'Workout',
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/diet_plan');
                },
                child: _buildActionButton(
                  context,
                  icon: Icons.fastfood,
                  label: 'Diet Plan',
                  color: Colors.purpleAccent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/medication');
                },
                child: _buildActionButton(
                  context,
                  icon: Icons.medication,
                  label: 'Medication',
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectHeader(title: "Today's Schedule"),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete Your Workout Plan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('30 min cardio + strength training'),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation(Colors.teal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dentist Appointment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Dr. Sarah Johnson, Downtown Clinic',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRemindersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _selectHeader(title: 'Health Reminders'),

            // Add notification toggle button
            GestureDetector(
              onTap: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Reminders Enabled'),
                        content: const Text(
                          'You will receive notifications for your health reminders.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.teal,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Enable',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildReminderCard(
                context,
                title: 'Drink Water',
                description: 'Remember to drink water throughout the day',
                icon: Icons.local_drink,
                color: Colors.teal,
                time: 'Every 2 hours',
                isDue: true,
              ),
              _buildReminderCard(
                context,
                title: 'Take Medication',
                description: 'Don\'t forget to take your medication',
                icon: Icons.medication,
                color: Colors.purple,
                time: '8:00 PM',
                isDue: false,
              ),
              _buildReminderCard(
                context,
                title: 'Exercise',
                description: 'Don\'t forget to exercise today',
                icon: Icons.fitness_center,
                color: Colors.teal,
                time: '5:00 PM',
                isDue: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String time,
    required bool isDue,
  }) {
    return GestureDetector(
      onTap: () {
        if (isDue) {
          // Show completion dialog
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Complete $title?'),
                  content: Text('Mark $title as completed for today?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title completed!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Complete'),
                    ),
                  ],
                ),
          );
        } else {
          // Show reminder details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title is scheduled for $time'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border:
              isDue
                  ? Border.all(color: color.withOpacity(0.5), width: 2)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (isDue)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isDue)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDoctorSearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectHeader(title: 'Find Doctors'),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showLocationPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Downtown, Main Street',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.teal),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctors, specialties...',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DoctorSearchPage(initialQuery: value),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/doctor_search');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/doctor_map');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.map, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Distance:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _distanceFilter,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${_distanceFilter.round()} km',
                onChanged: (value) => setState(() => _distanceFilter = value),
                activeColor: Colors.teal,
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text('${_distanceFilter.round()} km'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSpecialtyChip('All', isSelected: true),
              _buildSpecialtyChip('Cardiology'),
              _buildSpecialtyChip('Dentistry'),
              _buildSpecialtyChip('Dermatology'),
              _buildSpecialtyChip('Pediatrics'),
              _buildSpecialtyChip('Orthopedics'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.grey.withOpacity(0.1),
        selectedColor: Colors.teal.withOpacity(0.2),
        checkmarkColor: Colors.teal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.teal : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.teal : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildTopDoctorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectHeader(
          title: 'Doctors Near You',
          actionLabel: 'View All',
          onActionPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FullDoctorListPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                _filteredDoctors.map((doctor) {
                  return _buildDoctorCard(
                    context,
                    name: doctor['name'],
                    specialty: doctor['specialty'],
                    rating: 4.8,
                    availability: 'Available Today',
                    distance: '${doctor['distance']} km',
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(
    BuildContext context, {
    required String name,
    required String specialty,
    required double rating,
    required String availability,
    required String distance,
  }) {
    return GestureDetector(
      onTap: () {
        // Show a snackbar when a doctor card is tapped
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing $name\'s profile'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Book',
              onPressed: () {
                Navigator.pushNamed(context, '/doctor_search');
              },
            ),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                distance,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          specialty,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                availability,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectHeader(
          title: 'Health Tips & Articles',
          actionLabel: 'View All',
          onActionPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FullArticleListPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildArticleCard(
                context,
                title: 'How to Maintain Heart Health',
                category: 'Cardiology',
                imageIcon: Icons.favorite,
                imageColor: Colors.redAccent,
              ),
              _buildArticleCard(
                context,
                title: '10 Ways to Improve Your Sleep',
                category: 'Wellness',
                imageIcon: Icons.nightlight,
                imageColor: Colors.blueAccent,
              ),
              _buildArticleCard(
                context,
                title: 'Nutrition Tips for Better Immunity',
                category: 'Diet',
                imageIcon: Icons.restaurant,
                imageColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),
        _buildHealthInsightsSection(context),
      ],
    );
  }

  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String category,
    required IconData imageIcon,
    required Color imageColor,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: imageColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(child: Icon(imageIcon, size: 50, color: imageColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Health Guide Staff',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightsSection(BuildContext context) {
    // Create mock insights if the HealthAnalyticsService doesn't return any
    List<HealthInsight> mockInsights = [
      HealthInsight(
        title: 'Medication Adherence',
        message: '2 medications need to be taken today',
        priority: InsightPriority.medium,
        relatedMetricId: HealthAnalyticsService.WATER,
      ),
      HealthInsight(
        title: 'Upcoming Appointment',
        message: 'Appointment with Dr. Smith tomorrow at 10:00 AM',
        priority: InsightPriority.low,
        relatedMetricId: HealthAnalyticsService.SLEEP,
      ),
      HealthInsight(
        title: 'Hydration Reminder',
        message: 'You\'ve only had 2 glasses of water today',
        priority: InsightPriority.medium,
        relatedMetricId: HealthAnalyticsService.WATER,
      ),
    ];

    // Get insights from HealthAnalyticsService
    final healthAnalyticsService = HealthAnalyticsService();
    List<HealthInsight> insights = [];

    try {
      insights = healthAnalyticsService.generateInsights();
      // If no insights were generated, use mock insights
      if (insights.isEmpty) {
        insights = mockInsights;
      }
    } catch (e) {
      // If there's an error, use mock insights
      insights = mockInsights;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insights,
                    color: Colors.purple.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Health Insights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Personalized recommendations based on your data',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children:
                insights.map((insight) {
                  IconData icon;
                  Color color;

                  // Determine icon and color based on related metric or priority
                  switch (insight.relatedMetricId) {
                    case HealthAnalyticsService.WEIGHT:
                      icon = Icons.monitor_weight;
                      color = Colors.orange;
                      break;
                    case HealthAnalyticsService.BLOOD_PRESSURE:
                      icon = Icons.favorite;
                      color = Colors.red;
                      break;
                    case HealthAnalyticsService.SLEEP:
                      icon = Icons.bedtime;
                      color = Colors.indigo;
                      break;
                    case HealthAnalyticsService.WATER:
                      icon = Icons.water_drop;
                      color = Colors.blue;
                      break;
                    default:
                      icon = Icons.health_and_safety;
                      color = insight.priorityColor;
                  }

                  return _buildInsightItem(
                    context,
                    icon: icon,
                    color: color,
                    title: insight.title,
                    message: insight.message,
                    actionText: 'View Details',
                    onTap: () {
                      // Navigate based on metric type
                      if (insight.relatedMetricId ==
                          HealthAnalyticsService.WATER) {
                        Navigator.pushNamed(context, '/water_tracking');
                      } else if (insight.relatedMetricId ==
                          HealthAnalyticsService.SLEEP) {
                        Navigator.pushNamed(context, '/sleep_tracking');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing ${insight.title} details'),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health insights dashboard coming soon!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade100,
                    foregroundColor: Colors.purple.shade800,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View All Health Insights',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Generate mock data
                    final healthAnalyticsService = HealthAnalyticsService();
                    healthAnalyticsService.generateMockData().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mock health data generated successfully!',
                          ),
                        ),
                      );
                    });
                  },
                  child: const Text('Generate Sample Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actionText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _selectHeader({
    required String title,
    String actionLabel = 'View All',
    VoidCallback? onActionPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class UserProfilePage1 extends StatelessWidget {
  const UserProfilePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(child: Text('This is the User Profile Page')),
    );
  }
}

class FullDoctorListPage extends StatelessWidget {
  const FullDoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DoctorSearchPage();
  }
}

class FullArticleListPage extends StatelessWidget {
  const FullArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Articles'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(child: Text('This is the Full Article List Page')),
    );
  }
}
