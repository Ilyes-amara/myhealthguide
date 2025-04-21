import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';
import 'DoctorEditProfilePage.dart';
import 'DoctorChatbotPage.dart';
import 'PatientProfileViewPage.dart';
import 'services/NotificationService.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final doctorData = doctorProvider.doctorData;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Show notifications
                _showNotifications(context);
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.pushNamed(context, '/doctor_edit_profile');
                    break;
                  case 'chatbot':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorChatbotPage(),
                      ),
                    );
                    break;
                  case 'logout':
                    _confirmLogout(context);
                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Edit Profile'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'chatbot',
                      child: ListTile(
                        leading: Icon(Icons.chat),
                        title: Text('Medical AI Assistant'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body:
            doctorProvider.isLoggedIn
                ? Column(
                  children: [
                    // Tab bar
                    Container(
                      color: Colors.blue.shade800,
                      child: TabBar(
                        onTap: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                          // Restart animation when tab changes
                          _animationController.reset();
                          _animationController.forward();
                        },
                        indicatorColor: Colors.white,
                        tabs: const [
                          Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                          Tab(
                            icon: Icon(Icons.calendar_today),
                            text: 'Appointments',
                          ),
                          Tab(icon: Icon(Icons.person), text: 'Profile'),
                        ],
                      ),
                    ),
                    // Tab content
                    Expanded(
                      child: FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: TabBarView(
                            // The TabBarView automatically connects to DefaultTabController
                            children: [
                              _buildDashboardPage(doctorData),
                              _buildAppointmentsPage(doctorData),
                              _buildProfilePage(doctorData),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : const Center(
                  child: Text('Please log in to view your dashboard'),
                ),
        floatingActionButton:
            _selectedIndex == 1
                ? FloatingActionButton(
                  onPressed: () {
                    // Navigate to availability page to add new appointment slots
                    Navigator.pushNamed(context, '/doctor_availability');
                  },
                  backgroundColor: Colors.blue.shade800,
                  tooltip: 'Manage Availability',
                  child: const Icon(Icons.add),
                )
                : null,
      ),
    );
  }

  Widget _buildDashboardPage(Map<String, dynamic> doctorData) {
    // Get today's appointments
    final todayAppointments =
        (doctorData['appointments'] as List<dynamic>)
            .where((appointment) => appointment['date'] == _getTodayDate())
            .toList();

    // Get pending appointments
    final pendingAppointments =
        (doctorData['appointments'] as List<dynamic>)
            .where((appointment) => appointment['status'] == 'Pending')
            .toList();

    // Get upcoming appointments (next 7 days, excluding today)
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final upcomingAppointments =
        (doctorData['appointments'] as List<dynamic>).where((appointment) {
          final appointmentDate = DateTime.parse(appointment['date']);
          return appointmentDate.isAfter(now) &&
              appointmentDate.isBefore(nextWeek) &&
              appointment['date'] != _getTodayDate() &&
              appointment['status'] == 'Confirmed';
        }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              doctorData['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              doctorData['specialty'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        context,
                        'Availability',
                        Icons.calendar_month,
                        Colors.indigo,
                        () => Navigator.pushNamed(
                          context,
                          '/doctor_availability',
                        ),
                      ),
                      _buildQuickActionButton(
                        context,
                        'Medical AI',
                        Icons.psychology,
                        Colors.green.shade700,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DoctorChatbotPage(),
                          ),
                        ),
                      ),
                      _buildQuickActionButton(
                        context,
                        'Edit Profile',
                        Icons.edit,
                        Colors.orange,
                        () => Navigator.pushNamed(
                          context,
                          '/doctor_edit_profile',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats section
          Row(
            children: [
              _buildStatCard(
                'Today\'s\nAppointments',
                todayAppointments.length.toString(),
                Colors.green.shade100,
                Colors.green,
                Icons.today,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Pending\nRequests',
                pendingAppointments.length.toString(),
                Colors.orange.shade100,
                Colors.orange,
                Icons.pending_actions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Today's appointments section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Appointments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (todayAppointments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to appointments tab
                    });
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (todayAppointments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'No appointments scheduled for today',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),

          const SizedBox(height: 24),

          // Pending appointments section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (pendingAppointments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to appointments tab
                    });
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (pendingAppointments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'No pending appointment requests',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  pendingAppointments.length > 3
                      ? 3
                      : pendingAppointments.length,
              itemBuilder: (context, index) {
                final appointment = pendingAppointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),

          if (pendingAppointments.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to appointments tab
                    });
                  },
                  icon: const Icon(Icons.more_horiz),
                  label: Text(
                    '${pendingAppointments.length - 3} more pending requests',
                  ),
                ),
              ),
            ),

          // Upcoming appointments section
          if (upcomingAppointments.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  upcomingAppointments.length > 3
                      ? 3
                      : upcomingAppointments.length,
              itemBuilder: (context, index) {
                final appointment = upcomingAppointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),

            if (upcomingAppointments.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1; // Switch to appointments tab
                      });
                    },
                    icon: const Icon(Icons.more_horiz),
                    label: Text(
                      '${upcomingAppointments.length - 3} more upcoming appointments',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentsPage(Map<String, dynamic> doctorData) {
    final appointments = doctorData['appointments'] as List<dynamic>;

    // State variables for filtering
    final ValueNotifier<String> selectedFilter = ValueNotifier<String>('All');
    final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
    final ValueNotifier<List<dynamic>> filteredAppointments =
        ValueNotifier<List<dynamic>>([...appointments]);

    // Apply filters
    void applyFilters() {
      List<dynamic> filtered = [...appointments];

      // Apply status filter
      if (selectedFilter.value != 'All') {
        filtered =
            filtered.where((a) => a['status'] == selectedFilter.value).toList();
      }

      // Apply search query
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        filtered =
            filtered
                .where(
                  (a) =>
                      a['patientName'].toLowerCase().contains(query) ||
                      a['reason'].toLowerCase().contains(query),
                )
                .toList();
      }

      // Sort by date (most recent first)
      filtered.sort((a, b) {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA); // Most recent first
      });

      filteredAppointments.value = filtered;
    }

    // Initialize filtered appointments
    applyFilters();

    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search patients or reasons...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                  applyFilters();
                },
              ),

              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', selectedFilter, applyFilters),
                    _buildFilterChip('Pending', selectedFilter, applyFilters),
                    _buildFilterChip('Confirmed', selectedFilter, applyFilters),
                    _buildFilterChip('Completed', selectedFilter, applyFilters),
                    _buildFilterChip('Declined', selectedFilter, applyFilters),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Appointment list
        Expanded(
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: filteredAppointments,
            builder: (context, filteredAppointments, child) {
              if (filteredAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (selectedFilter.value != 'All' ||
                          searchQuery.value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            selectedFilter.value = 'All';
                            searchQuery.value = '';
                            applyFilters();
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                );
              }

              // Group appointments by date
              final Map<String, List<dynamic>> appointmentsByDate = {};
              for (var appointment in filteredAppointments) {
                final date = appointment['date'];
                if (!appointmentsByDate.containsKey(date)) {
                  appointmentsByDate[date] = [];
                }
                appointmentsByDate[date]!.add(appointment);
              }

              // Sort dates
              final sortedDates =
                  appointmentsByDate.keys.toList()..sort((a, b) {
                    final dateA = DateTime.parse(a);
                    final dateB = DateTime.parse(b);
                    return dateB.compareTo(dateA); // Most recent first
                  });

              return ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, dateIndex) {
                  final date = sortedDates[dateIndex];
                  final dateAppointments = appointmentsByDate[date]!;
                  final isToday = date == _getTodayDate();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color:
                            isToday ? Colors.blue.shade50 : Colors.grey.shade50,
                        child: Row(
                          children: [
                            Icon(
                              isToday ? Icons.today : Icons.calendar_today,
                              color:
                                  isToday
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isToday
                                  ? 'Today - ${_formatDate(date)}'
                                  : _formatDate(date),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isToday
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isToday
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${dateAppointments.length} appointment${dateAppointments.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isToday
                                          ? Colors.blue.shade800
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dateAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = dateAppointments[index];
                          final appointmentType =
                              appointment['type'] ?? 'In-person';

                          return _buildAppointmentCard(appointment);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage(Map<String, dynamic> doctorData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      doctorData['profileImage'] != null
                          ? kIsWeb
                              ? NetworkImage(doctorData['profileImage'])
                              : FileImage(File(doctorData['profileImage']))
                                  as ImageProvider
                          : null,
                  child:
                      doctorData['profileImage'] == null
                          ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.blue.shade800,
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '${doctorData['firstName']} ${doctorData['lastName']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorData['speciality'] ?? 'Speciality not specified',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Provider.of<DoctorProvider>(
                      context,
                    ).hasActiveSubscription)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.green[800],
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

          // Subscription section
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
                      Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).primaryColor,
                      ),
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
                            Provider.of<DoctorProvider>(
                                  context,
                                ).hasActiveSubscription
                                ? 'Active Subscription'
                                : 'No Active Subscription',
                            style: TextStyle(
                              color:
                                  Provider.of<DoctorProvider>(
                                        context,
                                      ).hasActiveSubscription
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (Provider.of<DoctorProvider>(
                                context,
                              ).hasActiveSubscription &&
                              doctorData['subscriptionExpiry'] != null)
                            Text(
                              'Expires: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(doctorData['subscriptionExpiry']))}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/doctor_subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          Provider.of<DoctorProvider>(
                                context,
                              ).hasActiveSubscription
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
          const SizedBox(height: 16),

          // Settings list
          // ... existing code ...
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        color: bgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: textColor, size: 30),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade800),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    IconData icon;

    // Convert status to lowercase for consistent comparison
    final normalizedStatus = status.toString().toLowerCase();

    switch (normalizedStatus) {
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'declined':
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.task_alt;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.1),
      label: Text(status, style: TextStyle(color: color)),
      avatar: Icon(icon, color: color, size: 16),
    );
  }

  void _showAppointmentDetails(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    final patientId = appointment['patientId'] ?? '';
    final appointmentType = appointment['type'] ?? 'In-person';
    final status = appointment['status'];
    final normalizedStatus =
        status.toString().toLowerCase(); // Normalize status case

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Appointment Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Patient', appointment['patientName']),
                  _buildDetailItem('Date', appointment['date']),
                  _buildDetailItem('Time', appointment['time']),
                  _buildDetailItem('Reason', appointment['reason']),
                  _buildDetailItem('Status', appointment['status']),
                  _buildDetailItem('Type', appointmentType),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  if (normalizedStatus == 'confirmed') ...[
                    const Text(
                      'Appointment Options:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Visit type selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAppointmentTypeButton(
                          context,
                          appointment,
                          'In-person',
                          Icons.local_hospital,
                          appointmentType == 'In-person',
                        ),
                        _buildAppointmentTypeButton(
                          context,
                          appointment,
                          'Online',
                          Icons.video_call,
                          appointmentType == 'Online',
                        ),
                        _buildAppointmentTypeButton(
                          context,
                          appointment,
                          'Home',
                          Icons.home,
                          appointmentType == 'Home',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Patient actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (patientId.isNotEmpty) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PatientProfileViewPage(
                                        patientId: patientId,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('View Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DoctorChatbotPage(
                                        initialQuery:
                                            "Patient ${appointment['patientName']} medical history",
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Medical AI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (normalizedStatus == 'pending')
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateAppointmentStatus(context, appointment, 'Confirmed');
                  },
                  child: const Text('Confirm'),
                ),
              if (normalizedStatus == 'pending')
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateAppointmentStatus(context, appointment, 'Declined');
                  },
                  child: const Text('Decline'),
                ),
              if (normalizedStatus == 'confirmed')
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateAppointmentStatus(context, appointment, 'Completed');
                  },
                  child: const Text('Mark as Completed'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildAppointmentTypeButton(
    BuildContext context,
    Map<String, dynamic> appointment,
    String type,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        _updateAppointmentType(context, appointment, type);
        Navigator.pop(context);
        // Re-open dialog with updated info
        Future.delayed(const Duration(milliseconds: 300), () {
          _showAppointmentDetails(context, {...appointment, 'type': type});
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(
    BuildContext context,
    Map<String, dynamic> appointment,
    String newStatus,
  ) {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final appointments =
        doctorProvider.doctorData['appointments'] as List<dynamic>;

    // Find the appointment index
    final index = appointments.indexWhere(
      (a) =>
          a['patientName'] == appointment['patientName'] &&
          a['date'] == appointment['date'] &&
          a['time'] == appointment['time'],
    );

    if (index != -1) {
      doctorProvider.updateAppointmentStatus(index, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment ${newStatus.toLowerCase()}')),
      );
    }
  }

  void _updateAppointmentType(
    BuildContext context,
    Map<String, dynamic> appointment,
    String type,
  ) {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final appointments =
        doctorProvider.doctorData['appointments'] as List<dynamic>;

    // Find the appointment index
    final index = appointments.indexWhere(
      (a) =>
          a['patientName'] == appointment['patientName'] &&
          a['date'] == appointment['date'] &&
          a['time'] == appointment['time'],
    );

    if (index != -1) {
      doctorProvider.updateAppointmentType(index, type);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment updated to $type visit')),
      );
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    ValueNotifier<String> selectedFilter,
    VoidCallback onFilterChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedFilter.value == label,
        onSelected: (selected) {
          if (selected) {
            selectedFilter.value = label;
            onFilterChanged();
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color:
              selectedFilter.value == label
                  ? Colors.blue.shade700
                  : Colors.black87,
          fontWeight:
              selectedFilter.value == label
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          _buildNotificationItem(
                            'New appointment request',
                            'Ahmed Ben Ali requested an appointment for tomorrow at 10:00 AM',
                            DateTime.now().subtract(
                              const Duration(minutes: 30),
                            ),
                            isNew: true,
                          ),
                          _buildNotificationItem(
                            'Appointment cancelled',
                            'Fatima Zahra cancelled her appointment for today at 2:00 PM',
                            DateTime.now().subtract(const Duration(hours: 2)),
                            isNew: true,
                          ),
                          _buildNotificationItem(
                            'Medical record updated',
                            'Mohamed Salah\'s medical record has been updated',
                            DateTime.now().subtract(const Duration(days: 1)),
                          ),
                          _buildNotificationItem(
                            'Reminder',
                            'You have 3 appointments scheduled for tomorrow',
                            DateTime.now().subtract(const Duration(days: 1)),
                          ),
                          _buildNotificationItem(
                            'System update',
                            'The system will be down for maintenance tonight from 2:00 AM to 4:00 AM',
                            DateTime.now().subtract(const Duration(days: 2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    DateTime time, {
    bool isNew = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isNew ? Colors.blue.shade100 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNew ? Icons.notifications_active : Icons.notifications,
              color: isNew ? Colors.blue.shade800 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(time),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  Color _getAppointmentTypeColor(String type) {
    switch (type) {
      case 'Online':
        return Colors.teal;
      case 'Home':
        return Colors.purple;
      case 'In-person':
      default:
        return Colors.blue;
    }
  }

  IconData _getAppointmentTypeIcon(String type) {
    switch (type) {
      case 'Online':
        return Icons.video_call;
      case 'Home':
        return Icons.home;
      case 'In-person':
      default:
        return Icons.local_hospital;
    }
  }

  void _showAppointmentOptions(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    final status = appointment['status'];
    final normalizedStatus =
        status.toString().toLowerCase(); // Normalize status case

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['patientName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_formatDate(appointment['date'])} at ${appointment['time']}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      _getStatusChip(status),
                    ],
                  ),
                ),
                const Divider(),
                _buildActionButton(
                  context,
                  'View Details',
                  Icons.info_outline,
                  Colors.blue,
                  () => _showAppointmentDetails(context, appointment),
                ),
                if (normalizedStatus == 'pending')
                  _buildActionButton(
                    context,
                    'Confirm Appointment',
                    Icons.check_circle_outline,
                    Colors.green,
                    () => _updateAppointmentStatus(
                      context,
                      appointment,
                      'Confirmed',
                    ),
                  ),
                if (normalizedStatus == 'pending')
                  _buildActionButton(
                    context,
                    'Decline Appointment',
                    Icons.cancel_outlined,
                    Colors.red,
                    () => _updateAppointmentStatus(
                      context,
                      appointment,
                      'Declined',
                    ),
                  ),
                if (normalizedStatus == 'confirmed')
                  _buildActionButton(
                    context,
                    'Mark as Completed',
                    Icons.task_alt,
                    Colors.green,
                    () => _updateAppointmentStatus(
                      context,
                      appointment,
                      'Completed',
                    ),
                  ),
                if (appointment['patientId'] != null)
                  _buildActionButton(
                    context,
                    'View Patient Profile',
                    Icons.person_outline,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PatientProfileViewPage(
                              patientId: appointment['patientId'],
                            ),
                      ),
                    ),
                  ),
                _buildActionButton(
                  context,
                  'Medical AI Assistant',
                  Icons.psychology,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DoctorChatbotPage(
                            initialQuery:
                                "Patient ${appointment['patientName']} medical history",
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status'];
    final normalizedStatus =
        status.toString().toLowerCase(); // Normalize status case
    final type = appointment['type'] ?? 'In-person';
    final date = DateTime.parse(appointment['date']);
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Hero(
      tag: 'appointment_${appointment['id']}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getAppointmentTypeColor(type).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color:
                normalizedStatus == 'confirmed'
                    ? Colors.green.withOpacity(0.3)
                    : normalizedStatus == 'pending'
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAppointmentDetails(context, appointment),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getAppointmentTypeColor(
                                type,
                              ).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getAppointmentTypeIcon(type),
                              color: _getAppointmentTypeColor(type),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['patientName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment['reason'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isToday
                                ? 'Today'
                                : _formatDate(appointment['date']),
                            style: TextStyle(
                              color:
                                  isToday
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade700,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appointment['time'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getAppointmentTypeColor(
                            type,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getAppointmentTypeIcon(type),
                              size: 14,
                              color: _getAppointmentTypeColor(type),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type,
                              style: TextStyle(
                                color: _getAppointmentTypeColor(type),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (normalizedStatus == 'confirmed')
                        _buildSimpleActionButton(
                          'Chat',
                          Icons.chat,
                          Colors.blue,
                          () =>
                              _navigateToChatWithPatient(context, appointment),
                        ),
                      if (normalizedStatus == 'confirmed')
                        const SizedBox(width: 8),
                      _buildSimpleActionButton(
                        'Options',
                        Icons.more_horiz,
                        Colors.grey,
                        () => _showAppointmentOptions(context, appointment),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    // Convert status to lowercase for consistent comparison
    final normalizedStatus = status.toString().toLowerCase();

    switch (normalizedStatus) {
      case 'confirmed':
        badgeColor = Colors.green;
        badgeText = 'Confirmed';
        badgeIcon = Icons.check_circle;
        break;
      case 'pending':
        badgeColor = Colors.orange;
        badgeText = 'Pending';
        badgeIcon = Icons.watch_later;
        break;
      case 'cancelled':
      case 'declined': // Add declined as an equivalent to cancelled
        badgeColor = Colors.red;
        badgeText = 'Cancelled';
        badgeIcon = Icons.cancel;
        break;
      case 'completed':
        badgeColor = Colors.blue;
        badgeText = 'Completed';
        badgeIcon = Icons.task_alt;
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Unknown';
        badgeIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChatWithPatient(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DoctorChatbotPage(
              initialQuery:
                  "Chat with patient ${appointment['patientName']} about ${appointment['reason']}",
            ),
      ),
    );
  }

  // Schedule a notification for the appointment
  void _scheduleAppointmentReminder(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    final notificationService = NotificationService();
    final dateStr = appointment['date'];
    final timeStr = appointment['time'];

    // Convert time string to hours and minutes
    final timeParts = timeStr.split(':');
    final hour =
        int.tryParse(
          timeParts[0].replaceAll(' AM', '').replaceAll(' PM', ''),
        ) ??
        0;
    final minute =
        int.tryParse(
          timeParts[1].replaceAll(' AM', '').replaceAll(' PM', ''),
        ) ??
        0;

    // Check if it's PM and adjust hour (if not already in 24-hour format)
    final isPM = timeStr.contains('PM');
    final hour24 = isPM && hour < 12 ? hour + 12 : hour;

    // Parse date string
    final dateParts = dateStr.split('-');
    final year = int.tryParse(dateParts[0]) ?? 2024;
    final month = int.tryParse(dateParts[1]) ?? 1;
    final day = int.tryParse(dateParts[2]) ?? 1;

    // Create DateTime for the appointment
    final appointmentDateTime = DateTime(year, month, day, hour24, minute);

    // Generate a unique ID for this appointment
    final appointmentId = appointment.hashCode;

    // Get the doctor provider
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

    // Schedule the notification
    notificationService.scheduleAppointmentReminder(
      appointmentId,
      'Appointment Reminder',
      'You have an appointment with Dr. ${doctorProvider.doctorData['name']} on ${_formatDate(dateStr)} at $timeStr',
      appointmentDateTime,
      'appointment_${appointmentId}',
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final doctorProvider = Provider.of<DoctorProvider>(
                    context,
                    listen: false,
                  );
                  doctorProvider.logout();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login_options');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
