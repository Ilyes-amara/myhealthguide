import 'package:flutter/material.dart';
import 'dart:math';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _selectedGender;
  String? _selectedAppointmentType;
  String? _selectedDate;
  String? _selectedTime;
  double _rating = 5.0;
  bool _isSubmittingAppointment = false;

  // Generate available dates (next 10 days)
  List<String> get _availableDates {
    final dates = <String>[];
    final now = DateTime.now();
    for (var i = 1; i <= 10; i++) {
      final date = now.add(Duration(days: i));
      dates.add(
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      );
    }
    return dates;
  }

  // Mock reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'John D.',
      'date': '2023-12-10',
      'rating': 5.0,
      'comment':
          'Dr. Smith is excellent! Very thorough and takes time to explain everything.',
      'verified': true,
    },
    {
      'name': 'Sarah M.',
      'date': '2023-11-28',
      'rating': 4.5,
      'comment':
          'Great doctor, but the wait time was a bit long. Otherwise, very professional and knowledgeable.',
      'verified': true,
    },
    {
      'name': 'Michael R.',
      'date': '2023-11-15',
      'rating': 5.0,
      'comment':
          'Amazing experience. The doctor was very attentive and addressed all my concerns.',
      'verified': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorInfo(),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Book'),
                  ],
                ),
                SizedBox(
                  height:
                      500, // Set a fixed height or calculate based on content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(),
                      _buildReviewsTab(),
                      _buildBookingTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.doctor['name']),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.teal),
            Center(
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ],
    );
  }

  Widget _buildDoctorInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor['specialty'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (widget.doctor['clinicName'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.doctor['clinicName'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.doctor['rating']} (${_reviews.length} reviews)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.location_on,
                '${widget.doctor['distance']} km',
              ),
              _buildInfoItem(
                Icons.access_time,
                widget.doctor['isWorking'] ? 'Available' : 'Unavailable',
              ),
              if (widget.doctor['offersHouseVisit'])
                _buildInfoItem(Icons.home, 'Home Visits'),
              if (widget.doctor['offersOnlineVisit'])
                _buildInfoItem(Icons.video_call, 'Online'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Doctor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.doctor['bio'],
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: Text(widget.doctor['address']),
              trailing: const Icon(Icons.directions),
              onTap: () {
                // Open maps with directions
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (widget.doctor['availableTimes'] as List).map<Widget>((time) {
                  return Chip(
                    label: Text(time),
                    backgroundColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nearby Pharmacies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildNearbyPharmacies(),
        ],
      ),
    );
  }

  Widget _buildNearbyPharmacies() {
    // Mock data for nearby pharmacies
    final List<Map<String, dynamic>> pharmacies = [
      {
        'name': 'HealthPlus Pharmacy',
        'distance': '0.3',
        'isOpen': true,
        'openUntil': '10:00 PM',
        'rating': 4.5,
      },
      {
        'name': 'MediCare Drugstore',
        'distance': '0.7',
        'isOpen': true,
        'openUntil': '9:00 PM',
        'rating': 4.2,
      },
      {
        'name': 'Community Pharmacy',
        'distance': '1.2',
        'isOpen': false,
        'openAt': '8:00 AM tomorrow',
        'rating': 4.0,
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = pharmacies[index];
          return Card(
            margin: const EdgeInsets.only(right: 12, bottom: 4),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_pharmacy, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pharmacy['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy['rating'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text('${pharmacy['distance']} km away'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        pharmacy['isOpen']
                            ? Icons.access_time
                            : Icons.access_time_filled,
                        color: pharmacy['isOpen'] ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy['isOpen']
                            ? 'Open until ${pharmacy['openUntil']}'
                            : 'Opens ${pharmacy['openAt']}',
                        style: TextStyle(
                          color: pharmacy['isOpen'] ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show on map or get directions
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Showing directions to ${pharmacy['name']}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Directions'),
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

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Reviews (${_reviews.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.rate_review),
                label: const Text('Add Review'),
                onPressed: _showAddReviewDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (review['verified'])
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Verified Visit',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review['comment'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Your Review'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your experience with ${widget.doctor['name']}?',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_reviewController.text.isNotEmpty) {
                    // Add the review logic here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review submitted successfully!'),
                      ),
                    );
                  }
                },
                child: const Text('SUBMIT'),
              ),
            ],
          ),
    );
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book an Appointment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Appointment Type
          const Text(
            'Select Appointment Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAppointmentTypeOption(
                  'In-Person',
                  Icons.person,
                  _selectedAppointmentType == 'In-Person',
                ),
              ),
              const SizedBox(width: 12),
              if (widget.doctor['offersHouseVisit'])
                Expanded(
                  child: _buildAppointmentTypeOption(
                    'House Visit',
                    Icons.home,
                    _selectedAppointmentType == 'House Visit',
                  ),
                ),
              if (widget.doctor['offersHouseVisit']) const SizedBox(width: 12),
              if (widget.doctor['offersOnlineVisit'])
                Expanded(
                  child: _buildAppointmentTypeOption(
                    'Online',
                    Icons.video_call,
                    _selectedAppointmentType == 'Online',
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Date Selection
          const Text(
            'Select Date:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final selected = _selectedDate == date;
                final dateObj = DateTime.parse(date);

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = null; // Reset time when date changes
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: selected ? Colors.teal : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateObj.day.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getDayName(dateObj.weekday),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  selected
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Time Selection
          if (_selectedDate != null) ...[
            const Text(
              'Select Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (widget.doctor['availableTimes'] as List).map<Widget>((time) {
                    final selected = _selectedTime == time;
                    // Randomly make some times unavailable for demonstration
                    final available = Random().nextBool();

                    return InkWell(
                      onTap:
                          available
                              ? () {
                                setState(() {
                                  _selectedTime = time;
                                });
                              }
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              !available
                                  ? Colors.grey.shade200
                                  : selected
                                  ? Colors.teal
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? Colors.teal : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            color:
                                !available
                                    ? Colors.grey.shade500
                                    : selected
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          // Patient Information Form
          const Text(
            'Your Information:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  value: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  items:
                      ['Male', 'Female', 'Other'].map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Request Appointment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _canSubmitAppointment() ? _submitAppointmentRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isSubmittingAppointment
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Request Appointment',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTypeOption(
    String type,
    IconData icon,
    bool selected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAppointmentType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.teal.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.teal : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.teal : Colors.grey.shade700),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.teal : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  bool _canSubmitAppointment() {
    return _selectedAppointmentType != null &&
        _selectedDate != null &&
        _selectedTime != null &&
        _fullNameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _selectedGender != null &&
        _phoneNumberController.text.isNotEmpty &&
        !_isSubmittingAppointment;
  }

  void _submitAppointmentRequest() async {
    setState(() {
      _isSubmittingAppointment = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmittingAppointment = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Appointment Requested'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Your appointment request has been sent successfully!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: $_selectedDate\nTime: $_selectedTime\nDoctor: ${widget.doctor['name']}',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The doctor will confirm your appointment shortly. You will receive a notification once confirmed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
