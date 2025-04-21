import 'package:flutter/material.dart';
import 'DoctorProfilePage.dart';

class DoctorSearchPage extends StatefulWidget {
  final String? initialQuery;

  const DoctorSearchPage({super.key, this.initialQuery});

  @override
  _DoctorSearchPageState createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _distanceFilter = 10.0;
  String _selectedSpecialty = 'All';
  final bool _isLoading = false;
  bool _showOnlyAvailable = false;

  // This would typically come from an API
  final List<Map<String, dynamic>> _allDoctors = [
    {
      'id': '1',
      'name': 'Dr. Jane Smith',
      'specialty': 'Cardiologist',
      'clinicName': 'Heart Care Center',
      'distance': 2.5,
      'rating': 4.8,
      'isWorking': true,
      'availableTimes': ['09:00', '10:30', '14:00', '16:30'],
      'address': '123 Medical Ave, Downtown',
      'bio':
          'Specialized in cardiovascular diseases with over 15 years of experience.',
      'image': 'assets/images/doctor1.png',
      'offersHouseVisit': true,
      'offersOnlineVisit': true,
    },
    {
      'id': '2',
      'name': 'Dr. Michael Johnson',
      'specialty': 'Dermatologist',
      'clinicName': 'Skin Health Clinic',
      'distance': 3.8,
      'rating': 4.5,
      'isWorking': true,
      'availableTimes': ['08:30', '11:00', '13:30', '15:00'],
      'address': '456 Health St, Westside',
      'bio':
          'Board-certified dermatologist specializing in skin conditions and cosmetic procedures.',
      'image': 'assets/images/doctor2.png',
      'offersHouseVisit': false,
      'offersOnlineVisit': true,
    },
    {
      'id': '3',
      'name': 'Dr. Sarah Williams',
      'specialty': 'Pediatrician',
      'clinicName': 'Children\'s Wellness Center',
      'distance': 1.2,
      'rating': 4.9,
      'isWorking': false,
      'availableTimes': ['09:30', '11:30', '14:30', '16:00'],
      'address': '789 Kid\'s Lane, Northside',
      'bio':
          'Dedicated to providing comprehensive care for infants, children, and adolescents.',
      'image': 'assets/images/doctor3.png',
      'offersHouseVisit': true,
      'offersOnlineVisit': true,
    },
    {
      'id': '4',
      'name': 'Dr. David Lee',
      'specialty': 'Orthopedic Surgeon',
      'clinicName': 'Advanced Orthopedics',
      'distance': 5.1,
      'rating': 4.7,
      'isWorking': true,
      'availableTimes': ['08:00', '10:00', '13:00', '15:30'],
      'address': '321 Bone Street, Eastside',
      'bio':
          'Specializing in sports injuries, joint replacements, and minimally invasive surgeries.',
      'image': 'assets/images/doctor4.png',
      'offersHouseVisit': false,
      'offersOnlineVisit': false,
    },
    {
      'id': '5',
      'name': 'Dr. Patricia Brown',
      'specialty': 'Neurologist',
      'clinicName': 'Brain & Nerve Center',
      'distance': 4.3,
      'rating': 4.6,
      'isWorking': true,
      'availableTimes': ['09:15', '11:45', '14:15', '16:45'],
      'address': '567 Neural Path, Southside',
      'bio':
          'Expert in treating disorders of the nervous system, including the brain and spinal cord.',
      'image': 'assets/images/doctor5.png',
      'offersHouseVisit': false,
      'offersOnlineVisit': true,
    },
    {
      'id': '6',
      'name': 'Dr. Robert Garcia',
      'specialty': 'General Practitioner',
      'clinicName': 'Family Health Clinic',
      'distance': 0.8,
      'rating': 4.5,
      'isWorking': true,
      'availableTimes': ['08:30', '10:30', '13:30', '15:30', '17:30'],
      'address': '890 Community Rd, Central District',
      'bio': 'Providing comprehensive primary care for patients of all ages.',
      'image': 'assets/images/doctor6.png',
      'offersHouseVisit': true,
      'offersOnlineVisit': true,
    },
  ];

  final List<String> _specialtyOptions = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Neurologist',
    'General Practitioner',
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    return _allDoctors.where((doctor) {
      // Filter by search query (name or specialty)
      bool matchesSearch =
          _searchQuery.isEmpty ||
          doctor['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          doctor['specialty'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Filter by distance
      bool matchesDistance = doctor['distance'] <= _distanceFilter;

      // Filter by specialty
      bool matchesSpecialty =
          _selectedSpecialty == 'All' ||
          doctor['specialty'] == _selectedSpecialty;

      // Filter by availability
      bool matchesAvailability = !_showOnlyAvailable || doctor['isWorking'];

      return matchesSearch &&
          matchesDistance &&
          matchesSpecialty &&
          matchesAvailability;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchQuery = widget.initialQuery!;
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          _buildSearchFilters(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search doctors by name or specialty',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Distance: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Show only available doctors: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Switch(
                value: _showOnlyAvailable,
                activeColor: Colors.teal,
                onChanged: (value) {
                  setState(() {
                    _showOnlyAvailable = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Specialty:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  _specialtyOptions
                      .map((specialty) => _buildSpecialtyChip(specialty))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    final bool isSelected = _selectedSpecialty == specialty;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(specialty),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSpecialty = specialty;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.teal.shade100,
        checkmarkColor: Colors.teal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.teal.shade700 : Colors.black87,
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

  Widget _buildSearchResults() {
    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search filters',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorProfilePage(doctor: doctor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor image
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.teal.shade50,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(width: 16),
              // Doctor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                doctor['isWorking']
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor['isWorking'] ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  doctor['isWorking']
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialty'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    if (doctor['clinicName'] != null &&
                        doctor['clinicName'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          doctor['clinicName'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor['distance']} km away',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor['rating'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (doctor['offersHouseVisit'])
                          _buildServiceBadge(Icons.home, 'Home Visit'),
                        if (doctor['offersHouseVisit'] &&
                            doctor['offersOnlineVisit'])
                          const SizedBox(width: 8),
                        if (doctor['offersOnlineVisit'])
                          _buildServiceBadge(Icons.video_call, 'Online'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: const Text('Appointment'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: BorderSide(color: Colors.teal.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              // Navigate to appointment booking
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Appointment booking coming soon!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat, size: 16),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              // Navigate to chat page
                              Navigator.pushNamed(
                                context,
                                '/patient_doctor_chat',
                                arguments: doctor,
                              );
                            },
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
      ),
    );
  }

  Widget _buildServiceBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.teal),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.teal.shade700),
          ),
        ],
      ),
    );
  }
}
