import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/DoctorAvailability.dart';
import 'services/GoogleCalendarService.dart';

class DoctorProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic> _doctorData = {
    'name': '',
    'email': '',
    'specialty': '',
    'clinicAddress': '',
    'phoneNumber': '',
    'bio': '',
    'education': [],
    'experience': [],
    'appointments': [],
    'averageRating': 0.0,
    'subscriptionStatus': 'none', // none, active, expired
    'subscriptionExpiry': null, // DateTime.now().toString()
    'subscriptionAmount': 2000, // Monthly subscription amount in DA
  };
  DoctorAvailability? _availability;
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  bool _isCalendarConnected = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic> get doctorData => _doctorData;
  DoctorAvailability? get availability => _availability;
  bool get isCalendarConnected => _isCalendarConnected;

  // Check if subscription is active
  bool get hasActiveSubscription =>
      _doctorData['subscriptionStatus'] == 'active' &&
      (_doctorData['subscriptionExpiry'] != null
          ? DateTime.parse(
            _doctorData['subscriptionExpiry'],
          ).isAfter(DateTime.now())
          : false);

  DoctorProvider() {
    _loadDoctorDataFromLocal();
    _checkCalendarConnection();
  }

  // Load doctor data from local storage
  Future<void> _loadDoctorDataFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final doctorDataString = prefs.getString('doctor_data');
    final availabilityString = prefs.getString('doctor_availability');

    if (doctorDataString != null) {
      _doctorData = jsonDecode(doctorDataString);
      _isLoggedIn = true;
    }

    if (availabilityString != null) {
      _availability = DoctorAvailability.fromJson(
        jsonDecode(availabilityString),
      );
    } else if (_isLoggedIn) {
      // Create default availability if logged in but no availability set
      _availability = DoctorAvailability.createDefault();
      await _saveAvailabilityLocally();
    }

    notifyListeners();
  }

  // Check if Google Calendar is connected
  Future<void> _checkCalendarConnection() async {
    if (_isLoggedIn) {
      _isCalendarConnected = await _calendarService.isAuthenticated();
      notifyListeners();
    }
  }

  // Connect to Google Calendar
  Future<bool> connectGoogleCalendar() async {
    try {
      final success = await _calendarService.authenticate();
      _isCalendarConnected = success;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error connecting to Google Calendar: $e');
      return false;
    }
  }

  // Disconnect from Google Calendar
  Future<void> disconnectGoogleCalendar() async {
    await _calendarService.signOut();
    _isCalendarConnected = false;
    notifyListeners();
  }

  // Save doctor data to local storage
  Future<void> _saveDoctorDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_data', jsonEncode(_doctorData));
  }

  // Save availability to local storage
  Future<void> _saveAvailabilityLocally() async {
    if (_availability == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'doctor_availability',
      jsonEncode(_availability!.toJson()),
    );
  }

  // Check if email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Login method with basic validation
  Future<void> login(String email, String password) async {
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Simulate an API call with a delay
    await Future.delayed(const Duration(seconds: 2));

    // Check for predefined demo account
    if (email == 'i@gmail.com' && password == '123456') {
      _doctorData = {
        'name': 'Dr. Ilyes Amara',
        'email': email,
        'specialty': 'Generalist',
        'licenseNumber': 'MD98765432',
        'clinicAddress': '456 Health Center, Medical Blvd',
        'phoneNumber': '+1 (555) 987-6543',
        'bio':
            'Experienced general practitioner with a focus on preventive care and holistic health approaches.',
        'education': [
          {
            'degree': 'MD',
            'institution': 'University of Medicine',
            'year': '2012',
          },
          {
            'degree': 'Residency',
            'institution': 'General Hospital',
            'year': '2016',
          },
        ],
        'experience': [
          {
            'position': 'General Practitioner',
            'institution': 'Community Health Center',
            'period': '2016-2020',
          },
          {
            'position': 'Senior Physician',
            'institution': 'Medical Associates Clinic',
            'period': '2020-Present',
          },
        ],
        'appointments': [
          {
            'id': 'A001',
            'patientName': 'Ilyes Amara',
            'date': '2025-03-20',
            'time': '09:00 AM',
            'reason': 'Annual physical examination',
            'status': 'confirmed',
            'patientPhone': '+216 55 123 456',
            'patientEmail': 'i@gmail.com',
            'type': 'In-person',
            'patientId': 'P12345',
            'notes': 'Patient reported occasional headaches and mild fatigue',
          },
          {
            'id': 'A002',
            'patientName': 'Ilyes Amara',
            'date': '2025-03-25',
            'time': '02:30 PM',
            'reason': 'Blood pressure follow-up',
            'status': 'pending',
            'patientPhone': '+216 55 123 456',
            'patientEmail': 'i@gmail.com',
            'type': 'Online',
            'patientId': 'P12345',
            'notes': 'Follow-up for mild hypertension',
          },
          {
            'id': 'A003',
            'patientName': 'Ahmed Ben Ali',
            'date': '2025-03-19',
            'time': '11:00 AM',
            'reason': 'Flu symptoms',
            'status': 'confirmed',
            'patientPhone': '+1 (555) 123-4567',
            'patientEmail': 'ahmed@example.com',
            'type': 'In-person',
            'patientId': 'P23456',
          },
          {
            'id': 'A004',
            'patientName': 'Fatima Zahra',
            'date': '2025-03-19',
            'time': '02:15 PM',
            'reason': 'Pregnancy consultation',
            'status': 'confirmed',
            'patientPhone': '+1 (555) 234-5678',
            'patientEmail': 'fatima@example.com',
            'type': 'In-person',
            'patientId': 'P34567',
          },
          {
            'id': 'A005',
            'patientName': 'Mohamed Salah',
            'date': '2025-03-21',
            'time': '10:30 AM',
            'reason': 'Sports injury follow-up',
            'status': 'confirmed',
            'patientPhone': '+1 (555) 345-6789',
            'patientEmail': 'mohamed@example.com',
            'type': 'Home',
            'patientId': 'P45678',
          },
          {
            'id': 'A006',
            'patientName': 'Ilyes Amara',
            'date': '2025-02-15',
            'time': '09:30 AM',
            'reason': 'Initial consultation for hypertension',
            'status': 'completed',
            'patientPhone': '+216 55 123 456',
            'patientEmail': 'i@gmail.com',
            'type': 'In-person',
            'patientId': 'P12345',
            'notes': 'Prescribed lifestyle changes and scheduled follow-up',
            'diagnosis': 'Mild hypertension (140/90 mmHg)',
            'treatment':
                'Lifestyle modifications, diet changes, daily exercise',
          },
        ],
        'ratings': [
          {
            'rating': 5.0,
            'comment': 'Excellent doctor, very attentive!',
            'patientName': 'Anonymous',
          },
          {
            'rating': 4.8,
            'comment': 'Great experience, highly recommend',
            'patientName': 'Anonymous',
          },
          {
            'rating': 4.5,
            'comment': 'Very knowledgeable and caring',
            'patientName': 'Anonymous',
          },
        ],
        'averageRating': 4.77,
      };
      _isLoggedIn = true;

      // Save doctor data to local storage
      await _saveDoctorDataLocally();

      // Create default availability
      _availability = DoctorAvailability.createDefault();
      await _saveAvailabilityLocally();

      // Check calendar connection
      await _checkCalendarConnection();

      notifyListeners();
      return;
    }

    // Default mock data for other logins
    _doctorData = {
      'name': 'Dr. Jane Smith',
      'email': email,
      'specialty': 'Cardiology',
      'licenseNumber': 'MD12345678',
      'clinicAddress': '123 Medical Center, Health Street',
      'phoneNumber': '+1 (555) 123-4567',
      'bio': 'Experienced cardiologist with over 10 years of practice.',
      'education': [
        {
          'degree': 'MD',
          'institution': 'Harvard Medical School',
          'year': '2010',
        },
        {'degree': 'Residency', 'institution': 'Mayo Clinic', 'year': '2014'},
        {
          'degree': 'Fellowship',
          'institution': 'Cleveland Clinic',
          'year': '2016',
        },
      ],
      'experience': [
        {
          'position': 'Cardiologist',
          'institution': 'City Hospital',
          'period': '2016-2020',
        },
        {
          'position': 'Senior Cardiologist',
          'institution': 'Heart Center',
          'period': '2020-Present',
        },
      ],
      'appointments': [],
      'ratings': [],
      'averageRating': 0.0,
    };
    _isLoggedIn = true;

    // Save doctor data to local storage
    await _saveDoctorDataLocally();

    // Create default availability
    _availability = DoctorAvailability.createDefault();
    await _saveAvailabilityLocally();

    notifyListeners();
  }

  // Register method with basic validation
  Future<void> register(
    String name,
    String email,
    String password,
    String specialty,
  ) async {
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (specialty.isEmpty) {
      throw Exception('Specialty cannot be empty');
    }

    // Simulate an API call with a delay
    await Future.delayed(const Duration(seconds: 2));

    // Create new doctor data
    _doctorData = {
      'name': name,
      'email': email,
      'specialty': specialty,
      'licenseNumber': '',
      'clinicAddress': '',
      'phoneNumber': '',
      'bio': '',
      'education': [],
      'experience': [],
      'appointments': [],
      'ratings': [],
      'averageRating': 0.0,
    };
    _isLoggedIn = true;

    // Save doctor data to local storage
    await _saveDoctorDataLocally();

    // Create default availability
    _availability = DoctorAvailability.createDefault();
    await _saveAvailabilityLocally();

    notifyListeners();
  }

  // Initialize doctor data (called from main.dart)
  Future<void> initDoctorData() async {
    await _loadDoctorDataFromLocal();
  }

  // Update doctor data (called from DoctorEditProfilePage)
  Future<void> updateDoctorData(Map<String, dynamic> updatedData) async {
    _doctorData = {..._doctorData, ...updatedData};

    // Save updated data to local storage
    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Update appointment status (called from DoctorDashboardPage)
  Future<void> updateAppointmentStatus(int index, String newStatus) async {
    if (!_isLoggedIn ||
        _doctorData['appointments'] == null ||
        index >= _doctorData['appointments'].length) {
      return;
    }

    // Update appointment status in doctor data
    _doctorData['appointments'][index]['status'] = newStatus;

    // Update in Google Calendar if connected
    if (_isCalendarConnected &&
        _doctorData['appointments'][index]['eventId'] != null) {
      try {
        await _calendarService.updateAppointment(
          _doctorData['appointments'][index]['eventId'],
          {'status': newStatus},
        );
      } catch (e) {
        debugPrint('Error updating appointment status in Google Calendar: $e');
      }
    }

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Update doctor profile
  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    _doctorData = {..._doctorData, ...updatedData};

    // Save updated data to local storage
    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Update doctor availability
  Future<void> updateAvailability(DoctorAvailability availability) async {
    _availability = availability;
    await _saveAvailabilityLocally();
    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
    _isLoggedIn = false;
    _doctorData = {};
    _availability = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_data');
    await prefs.remove('doctor_availability');

    notifyListeners();
  }

  // Add an appointment
  Future<void> addAppointment(Map<String, dynamic> appointment) async {
    if (!_isLoggedIn) return;

    // Add appointment to doctor data
    if (_doctorData['appointments'] == null) {
      _doctorData['appointments'] = [];
    }

    _doctorData['appointments'].add(appointment);

    // Add to Google Calendar if connected
    if (_isCalendarConnected) {
      try {
        final calendarEvent = await _calendarService.addAppointment(
          appointment,
        );
        // Update appointment with calendar event ID
        final index = _doctorData['appointments'].length - 1;
        _doctorData['appointments'][index]['eventId'] =
            calendarEvent['eventId'];
        _doctorData['appointments'][index]['calendarLink'] =
            calendarEvent['calendarLink'];
      } catch (e) {
        debugPrint('Error adding appointment to Google Calendar: $e');
      }
    }

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Update an appointment
  Future<void> updateAppointment(
    int index,
    Map<String, dynamic> updatedData,
  ) async {
    if (!_isLoggedIn ||
        _doctorData['appointments'] == null ||
        index >= _doctorData['appointments'].length) {
      return;
    }

    // Update appointment in doctor data
    _doctorData['appointments'][index] = {
      ..._doctorData['appointments'][index],
      ...updatedData,
    };

    // Update in Google Calendar if connected
    if (_isCalendarConnected &&
        _doctorData['appointments'][index]['eventId'] != null) {
      try {
        await _calendarService.updateAppointment(
          _doctorData['appointments'][index]['eventId'],
          updatedData,
        );
      } catch (e) {
        debugPrint('Error updating appointment in Google Calendar: $e');
      }
    }

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Delete an appointment
  Future<void> deleteAppointment(int index) async {
    if (!_isLoggedIn ||
        _doctorData['appointments'] == null ||
        index >= _doctorData['appointments'].length) {
      return;
    }

    // Delete from Google Calendar if connected
    if (_isCalendarConnected &&
        _doctorData['appointments'][index]['eventId'] != null) {
      try {
        await _calendarService.deleteAppointment(
          _doctorData['appointments'][index]['eventId'],
        );
      } catch (e) {
        debugPrint('Error deleting appointment from Google Calendar: $e');
      }
    }

    // Remove appointment from doctor data
    _doctorData['appointments'].removeAt(index);

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Update appointment type (called from DoctorDashboardPage)
  Future<void> updateAppointmentType(int index, String type) async {
    if (!_isLoggedIn ||
        _doctorData['appointments'] == null ||
        index >= _doctorData['appointments'].length) {
      return;
    }

    // Update appointment type in doctor data
    _doctorData['appointments'][index]['type'] = type;

    // Update in Google Calendar if connected
    if (_isCalendarConnected &&
        _doctorData['appointments'][index]['eventId'] != null) {
      try {
        await _calendarService.updateAppointment(
          _doctorData['appointments'][index]['eventId'],
          {'type': type},
        );
      } catch (e) {
        debugPrint('Error updating appointment type in Google Calendar: $e');
      }
    }

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Get available time slots for a specific date
  List<TimeOfDay> getAvailableTimeSlotsForDate(DateTime date) {
    if (_availability == null) return [];
    return _availability!.getAvailableTimeSlotsForDate(date);
  }

  // Check if a specific date and time is available
  bool isTimeSlotAvailable(DateTime date, TimeOfDay time) {
    final availableSlots = getAvailableTimeSlotsForDate(date);
    return availableSlots.any(
      (slot) => slot.hour == time.hour && slot.minute == time.minute,
    );
  }

  // Get patient profile by ID
  Future<Map<String, dynamic>?> getPatientProfile(String patientId) async {
    // In a real app, this would fetch patient data from a database or API
    // For demo purposes, we'll return mock data

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return predefined patient profile for Ilyes Amara
    if (patientId == 'P12345') {
      return {
        'id': 'P12345',
        'name': 'Ilyes Amara',
        'gender': 'Male',
        'dateOfBirth': '1993-05-15',
        'phone': '+216 55 123 456',
        'email': 'i@gmail.com',
        'address': '123 Tunis Street, Tunis',
        'bloodType': 'O+',
        'height': '180 cm',
        'weight': '75 kg',
        'bmi': '23.1', // Fixed BMI calculation
        'insuranceProvider': 'MedAssist Premium',
        'insuranceNumber': 'INS-789456',
        'emergencyContact': 'Sarah Amara: +216 55 789 012',
        'status': 'Active',
        'allergies': ['Penicillin'],
        'conditions': ['Mild Hypertension'],
        'medications': [
          {
            'name': 'Amlodipine',
            'dosage': '5mg daily',
            'purpose': 'Blood pressure control',
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg daily',
            'purpose': 'Immune support',
          },
          {
            'name': 'Omega-3',
            'dosage': '1000mg daily',
            'purpose': 'Cardiovascular health',
          },
        ],
        'pastVisits': _generatePastVisits(
          'P12345',
          'Ilyes Amara',
          (_doctorData['appointments'] as List<dynamic>)
              .where((appointment) => appointment['patientId'] == 'P12345')
              .toList(),
        ),
      };
    }

    // Check if patient exists in doctor's appointments
    if (_doctorData['appointments'] != null) {
      final patientAppointments =
          (_doctorData['appointments'] as List<dynamic>)
              .where((appointment) => appointment['patientId'] == patientId)
              .toList();

      if (patientAppointments.isNotEmpty) {
        // Get patient name from appointment
        final patientName = patientAppointments.first['patientName'];

        // Calculate a stable height and weight based on patient ID
        final height = 150 + (patientId.hashCode % 50);
        final weight = 50 + (patientId.hashCode % 50);

        // Calculate BMI correctly with proper parentheses
        final bmi = (weight / ((height / 100) * (height / 100)))
            .toStringAsFixed(1);

        // Create mock patient data based on patientId and name
        return {
          'id': patientId,
          'name': patientName,
          'gender': ['Male', 'Female'][patientId.hashCode % 2],
          'dateOfBirth':
              '${1960 + (patientId.hashCode % 40)}-${1 + (patientId.hashCode % 12)}-${1 + (patientId.hashCode % 28)}',
          'phone':
              '+1 ${800 + (patientId.hashCode % 200)} ${1000 + (patientId.hashCode % 9000)}',
          'email':
              '${patientName.toLowerCase().replaceAll(' ', '.')}@example.com',
          'address':
              '${100 + (patientId.hashCode % 900)} Main St, Anytown, US ${10000 + (patientId.hashCode % 90000)}',
          'bloodType':
              [
                'A+',
                'A-',
                'B+',
                'B-',
                'AB+',
                'AB-',
                'O+',
                'O-',
              ][patientId.hashCode % 8],
          'height': '$height cm',
          'weight': '$weight kg',
          'bmi': bmi,
          'insuranceProvider': _getInsuranceProvider(patientId),
          'insuranceNumber': 'INS-${100000 + (patientId.hashCode % 900000)}',
          'emergencyContact':
              'Family Member: +1 ${800 + (patientId.hashCode % 200)} ${1000 + ((patientId.hashCode * 3) % 9000)}',
          'status': 'Active',
          'allergies': _generateRandomAllergies(patientId),
          'conditions': _generateRandomConditions(patientId),
          'medications': _generateRandomMedications(patientId),
          'pastVisits': _generatePastVisits(
            patientId,
            patientName,
            patientAppointments,
          ),
        };
      }
    }

    return null;
  }

  String _getInsuranceProvider(String patientId) {
    final providers = [
      'MedAssist Basic',
      'HealthGuard Plus',
      'WellCare Complete',
      'MediShield',
      'LifeHealth Premier',
      'GlobalCare',
      'UniversalHealth',
    ];

    return providers[patientId.hashCode % providers.length];
  }

  List<String> _generateRandomAllergies(String patientId) {
    final allergies = [
      'Penicillin',
      'Peanuts',
      'Shellfish',
      'Latex',
      'Dust',
      'Pollen',
      'Eggs',
      'Milk',
      'Soy',
      'Wheat',
      'Tree nuts',
      'Fish',
    ];

    final numAllergies = patientId.hashCode % 4; // 0-3 allergies
    if (numAllergies == 0) return ['None reported'];

    final result = <String>[];
    for (var i = 0; i < numAllergies; i++) {
      result.add(allergies[(patientId.hashCode + i) % allergies.length]);
    }

    return result;
  }

  List<String> _generateRandomConditions(String patientId) {
    final conditions = [
      'Hypertension',
      'Diabetes Type 2',
      'Asthma',
      'Arthritis',
      'Migraine',
      'Anxiety',
      'Depression',
      'Hypothyroidism',
      'GERD',
      'Hyperlipidemia',
      'Insomnia',
    ];

    final numConditions = patientId.hashCode % 3; // 0-2 conditions
    if (numConditions == 0) return ['None reported'];

    final result = <String>[];
    for (var i = 0; i < numConditions; i++) {
      result.add(conditions[(patientId.hashCode + i) % conditions.length]);
    }

    return result;
  }

  List<Map<String, String>> _generateRandomMedications(String patientId) {
    final medications = [
      {'name': 'Lisinopril', 'dosage': '10mg daily', 'purpose': 'Hypertension'},
      {
        'name': 'Metformin',
        'dosage': '500mg twice daily',
        'purpose': 'Diabetes',
      },
      {
        'name': 'Atorvastatin',
        'dosage': '20mg daily',
        'purpose': 'Cholesterol',
      },
      {
        'name': 'Levothyroxine',
        'dosage': '50mcg daily',
        'purpose': 'Hypothyroidism',
      },
      {'name': 'Albuterol', 'dosage': '2 puffs as needed', 'purpose': 'Asthma'},
      {
        'name': 'Sertraline',
        'dosage': '50mg daily',
        'purpose': 'Anxiety/Depression',
      },
      {'name': 'Omeprazole', 'dosage': '20mg daily', 'purpose': 'GERD'},
      {
        'name': 'Ibuprofen',
        'dosage': '400mg as needed',
        'purpose': 'Pain relief',
      },
    ];

    final numMeds = patientId.hashCode % 3; // 0-2 medications
    if (numMeds == 0) return [];

    final result = <Map<String, String>>[];
    for (var i = 0; i < numMeds; i++) {
      result.add(medications[(patientId.hashCode + i) % medications.length]);
    }

    return result;
  }

  List<Map<String, dynamic>> _generatePastVisits(
    String patientId,
    String patientName,
    List<dynamic> appointments,
  ) {
    // Convert confirmed past appointments to visits
    final pastVisits = <Map<String, dynamic>>[];

    // Add actual past appointments
    for (final appointment in appointments) {
      if (appointment['status'] == 'Completed') {
        pastVisits.add({
          'date': appointment['date'],
          'reason': appointment['reason'],
          'diagnosis': _generateRandomDiagnosis(appointment['reason']),
          'treatment': _generateRandomTreatment(appointment['reason']),
          'notes':
              'Patient reported ${appointment['reason']}. '
              'Examination showed ${_generateRandomExamination()}.',
        });
      }
    }

    // Add some mock past visits if needed
    if (pastVisits.isEmpty) {
      // Generate 0-2 past visits
      final numVisits = patientId.hashCode % 3;

      final reasons = [
        'Annual check-up',
        'Flu symptoms',
        'Headache',
        'Back pain',
        'Allergic reaction',
        'Skin rash',
        'Stomach pain',
        'Fever',
      ];

      for (var i = 0; i < numVisits; i++) {
        final visitDate = DateTime.now().subtract(
          Duration(days: 30 * (i + 1) + (patientId.hashCode % 30)),
        );
        final reason = reasons[(patientId.hashCode + i) % reasons.length];

        pastVisits.add({
          'date':
              '${visitDate.year}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}',
          'reason': reason,
          'diagnosis': _generateRandomDiagnosis(reason),
          'treatment': _generateRandomTreatment(reason),
          'notes':
              'Patient reported $reason. '
              'Examination showed ${_generateRandomExamination()}.',
        });
      }
    }

    return pastVisits;
  }

  String _generateRandomDiagnosis(String reason) {
    final diagnoses = {
      'Annual check-up': 'Routine examination, no significant findings',
      'Flu symptoms': 'Influenza type A',
      'Headache': 'Tension headache',
      'Back pain': 'Lumbar strain',
      'Allergic reaction': 'Allergic contact dermatitis',
      'Skin rash': 'Atopic dermatitis',
      'Stomach pain': 'Gastritis',
      'Fever': 'Viral infection',
      'Cough': 'Upper respiratory infection',
      'Sore throat': 'Pharyngitis',
      'Ear pain': 'Otitis media',
    };

    // Return matching diagnosis or default
    return diagnoses[reason] ??
        'Symptoms consistent with ${reason.toLowerCase()}';
  }

  String _generateRandomTreatment(String reason) {
    final treatments = {
      'Annual check-up': 'Continue current medications, follow up in 1 year',
      'Flu symptoms':
          'Rest, fluids, acetaminophen for fever, follow up if symptoms worsen',
      'Headache':
          'OTC pain relievers, stress reduction techniques, adequate hydration',
      'Back pain': 'NSAIDs, muscle relaxants, physical therapy referral',
      'Allergic reaction':
          'Antihistamines, topical corticosteroids, avoid allergen',
      'Skin rash': 'Topical corticosteroid cream, moisturize affected area',
      'Stomach pain': 'Antacids, bland diet, H2 blockers if needed',
      'Fever': 'Acetaminophen, rest, fluids, follow up if fever persists',
      'Cough': 'Cough suppressants, humidifier, increased fluid intake',
      'Sore throat': 'Salt water gargles, throat lozenges, rest voice',
      'Ear pain': 'Antibiotic ear drops, pain relievers',
    };

    // Return matching treatment or default
    return treatments[reason] ?? 'Symptomatic treatment and monitoring';
  }

  String _generateRandomExamination() {
    final examinations = [
      'normal vital signs',
      'mild tenderness on palpation',
      'slight inflammation',
      'no acute distress',
      'normal range of motion',
      'clear lungs on auscultation',
      'regular heart rhythm',
      'no neurological deficits',
      'normal abdominal examination',
    ];

    return examinations[DateTime.now().millisecond % examinations.length];
  }

  // Add subscription
  Future<void> activateSubscription(int months) async {
    final now = DateTime.now();
    final expiryDate = DateTime(
      now.year,
      now.month + months,
      now.day,
      now.hour,
      now.minute,
    );

    _doctorData['subscriptionStatus'] = 'active';
    _doctorData['subscriptionExpiry'] = expiryDate.toString();

    await _saveDoctorDataLocally();
    notifyListeners();
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    _doctorData['subscriptionStatus'] = 'expired';

    await _saveDoctorDataLocally();
    notifyListeners();
  }
}
