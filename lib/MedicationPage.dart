import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> reminders = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();

  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSavedMedications();
    _loadSavedReminders();

    // Start the periodic reminder check
    _startReminderChecks();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMedications = prefs.getStringList('medications') ?? [];

    setState(() {
      medications =
          savedMedications
              .map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList();
    });
  }

  Future<void> _saveMedication(Map<String, dynamic> medication) async {
    final prefs = await SharedPreferences.getInstance();
    final savedMedications = prefs.getStringList('medications') ?? [];

    // Add adherence tracking data
    if (!medication.containsKey('adherence')) {
      medication['adherence'] = {
        'total_doses': 0,
        'taken_doses': 0,
        'last_7_days': List.filled(7, false),
      };
    }

    savedMedications.add(jsonEncode(medication));
    await prefs.setStringList('medications', savedMedications);

    setState(() {
      medications.add(medication);
    });
  }

  Future<void> _loadSavedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders') ?? [];

    setState(() {
      reminders =
          savedReminders
              .map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList();
    });
  }

  Future<void> _saveReminder(Map<String, dynamic> reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders') ?? [];

    savedReminders.add(jsonEncode(reminder));
    await prefs.setStringList('reminders', savedReminders);

    setState(() {
      reminders.add(reminder);
    });
  }

  Future<void> _searchMedication(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Using the OpenFDA API for medication information
      final response = await http.get(
        Uri.parse(
          'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"$query"&limit=5',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final List<Map<String, dynamic>> searchResults = [];

          for (var result in data['results']) {
            final Map<String, dynamic> medicationInfo = {
              'name': result['openfda']?['brand_name']?[0] ?? 'Unknown',
              'generic_name':
                  result['openfda']?['generic_name']?[0] ?? 'Not available',
              'dosage_forms':
                  result['openfda']?['dosage_form']?[0] ?? 'Not available',
              'indications':
                  result['indications_and_usage']?[0] ?? 'Not available',
              'warnings': result['warnings']?[0] ?? 'Not available',
              'side_effects':
                  result['adverse_reactions']?[0] ?? 'Not available',
              'administration':
                  result['dosage_and_administration']?[0] ?? 'Not available',
            };
            searchResults.add(medicationInfo);
          }

          _showSearchResults(searchResults);
        } else {
          _showErrorSnackBar('No results found for "$query"');
        }
      } else {
        _showErrorSnackBar('Error fetching data. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSearchResults(List<Map<String, dynamic>> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final medication = results[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(medication['name']),
                                subtitle: Text(medication['generic_name']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _addMedicationToMyList(medication);
                                  },
                                ),
                                onTap: () => _showMedicationDetails(medication),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showMedicationDetails(Map<String, dynamic> medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              medication['name'],
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Navigator.pop(context);
                              _addMedicationToMyList(medication);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generic Name: ${medication['generic_name']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: controller,
                          children: [
                            _buildInfoSection(
                              'Dosage Forms',
                              medication['dosage_forms'],
                            ),
                            _buildInfoSection(
                              'Indications',
                              medication['indications'],
                            ),
                            _buildInfoSection(
                              'Administration',
                              medication['administration'],
                            ),
                            _buildInfoSection(
                              'Warnings',
                              medication['warnings'],
                            ),
                            _buildInfoSection(
                              'Side Effects',
                              medication['side_effects'],
                            ),
                            _buildDietaryRecommendations(medication),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildDietaryRecommendations(Map<String, dynamic> medication) {
    // In a real app, these recommendations would be based on the medication properties
    // Here we're using mock data for demonstration

    // This map contains common medications and related dietary recommendations
    final Map<String, List<Map<String, dynamic>>> dietaryGuidelines = {
      'Lipitor': [
        {
          'type': 'avoid',
          'item': 'Grapefruit juice',
          'reason': 'May increase the medication level in your blood',
        },
        {
          'type': 'limit',
          'item': 'Alcohol',
          'reason': 'May increase risk of liver problems',
        },
      ],
      'Warfarin': [
        {
          'type': 'watch',
          'item': 'Green leafy vegetables',
          'reason': 'May decrease effectiveness of medication',
        },
        {
          'type': 'avoid',
          'item': 'Cranberry juice',
          'reason': 'May increase risk of bleeding',
        },
      ],
      'Metformin': [
        {
          'type': 'limit',
          'item': 'Alcohol',
          'reason': 'May cause low blood sugar',
        },
        {
          'type': 'recommend',
          'item': 'Low-carb diet',
          'reason': 'Helps control blood sugar levels',
        },
      ],
    };

    // Default recommendations for all medications
    List<Map<String, dynamic>> recommendations = [
      {
        'type': 'recommend',
        'item': 'Stay hydrated',
        'reason': 'Helps medication absorption and reduces side effects',
      },
      {
        'type': 'recommend',
        'item': 'Balanced diet',
        'reason': 'Supports overall health during treatment',
      },
    ];

    // Check if we have specific recommendations for this medication
    final String medName = medication['name'].toString().toLowerCase();
    for (var key in dietaryGuidelines.keys) {
      if (medName.contains(key.toLowerCase())) {
        recommendations = [...dietaryGuidelines[key]!, ...recommendations];
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dietary Recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children:
                recommendations.map((rec) {
                  IconData icon;
                  Color color;

                  switch (rec['type']) {
                    case 'avoid':
                      icon = Icons.not_interested;
                      color = Colors.red;
                      break;
                    case 'limit':
                      icon = Icons.warning_amber;
                      color = Colors.orange;
                      break;
                    case 'watch':
                      icon = Icons.visibility;
                      color = Colors.blue;
                      break;
                    case 'recommend':
                    default:
                      icon = Icons.check_circle;
                      color = Colors.green;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['item'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rec['reason'],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to diet plan page with medication name as parameter
              Navigator.pushNamed(context, '/diet');
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('View Diet Plan Suggestions'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _addMedicationToMyList(Map<String, dynamic> medication) {
    _saveMedication({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': medication['name'],
      'generic_name': medication['generic_name'],
      'dosage_forms': medication['dosage_forms'],
      'added_on': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} added to your medications'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showAddMedicationManuallyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Medication Manually'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _medicationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_medicationNameController.text.isNotEmpty) {
                    _saveMedication({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': _medicationNameController.text,
                      'dosage': _dosageController.text,
                      'notes': _notesController.text,
                      'added_on': DateTime.now().toIso8601String(),
                      'manual_entry': true,
                    });

                    Navigator.pop(context);

                    _medicationNameController.clear();
                    _dosageController.clear();
                    _notesController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medication added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medication name is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _showAddReminderDialog() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      _selectedTime = pickedTime;

      // Show medication selection dialog
      if (medications.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to add medications first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Medication for Reminder'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return ListTile(
                      title: Text(medication['name']),
                      subtitle:
                          medication['dosage'] != null &&
                                  medication['dosage'].isNotEmpty
                              ? Text(medication['dosage'])
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        _showReminderDetailsDialog(medication);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );
    }
  }

  void _showReminderDetailsDialog(Map<String, dynamic> medication) {
    final TextEditingController reminderNoteController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Reminder for ${medication['name']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time: ${_selectedTime.format(context)}'),
                  const SizedBox(height: 16),
                  const Text('Repeat:'),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Daily'),
                        selected: true,
                        onSelected: (_) {},
                      ),
                      FilterChip(
                        label: const Text('Weekdays'),
                        selected: false,
                        onSelected: (_) {},
                      ),
                      FilterChip(
                        label: const Text('Weekends'),
                        selected: false,
                        onSelected: (_) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reminderNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveReminder({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'medication_id': medication['id'],
                    'medication_name': medication['name'],
                    'time': '${_selectedTime.hour}:${_selectedTime.minute}',
                    'repeat': 'daily',
                    'notes': reminderNoteController.text,
                    'created_at': DateTime.now().toIso8601String(),
                    'active': true,
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder set for ${medication['name']}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Set Reminder'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Tracker'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'My Medications'),
            Tab(text: 'Reminders'),
            Tab(text: 'Search'),
            Tab(text: 'Pharmacies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyMedicationsTab(),
          _buildRemindersTab(),
          _buildSearchTab(),
          _buildPharmaciesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddMedicationManuallyDialog();
          } else if (_tabController.index == 1) {
            _showAddReminderDialog();
          }
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyMedicationsTab() {
    if (medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medications added yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddMedicationManuallyDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                _tabController.animateTo(2); // Switch to search tab
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Medication Database'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (medications.length > 1) _buildInteractionChecker(),

        if (medications.isNotEmpty) _buildMedicationInsights(),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              final bool isManualEntry = medication['manual_entry'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              medication['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () {
                              _selectedTime = TimeOfDay.now();
                              _showReminderDetailsDialog(medication);
                            },
                            tooltip: 'Add reminder',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              // Handle medication deletion
                              setState(() {
                                medications.removeAt(index);
                              });

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setStringList(
                                'medications',
                                medications.map((m) => jsonEncode(m)).toList(),
                              );
                            },
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      const Divider(),
                      if (!isManualEntry && medication['generic_name'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Generic Name: ${medication['generic_name']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if (medication['dosage'] != null &&
                          medication['dosage'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Dosage: ${medication['dosage']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      if (medication['notes'] != null &&
                          medication['notes'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Notes: ${medication['notes']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      if (medication['added_on'] != null)
                        Text(
                          'Added on: ${DateFormat('MMM d, yyyy').format(DateTime.parse(medication['added_on']))}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Add adherence tracking
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adherence Tracking',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAdherenceWidget(medication, index),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionChecker() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Medication Interaction Checker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Check for potential interactions between your medications',
              style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkMedicationInteractions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Check Interactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkMedicationInteractions() {
    // Create a map of known medication interactions for demo purposes
    final Map<String, Map<String, String>> interactionMap = {
      'warfarin': {
        'aspirin': 'Increased risk of bleeding.',
        'ibuprofen': 'Increased risk of serious bleeding.',
        'citalopram': 'Increased risk of bleeding.',
      },
      'lisinopril': {
        'spironolactone': 'May cause dangerously high potassium levels.',
        'potassium': 'May cause dangerously high potassium levels.',
      },
      'simvastatin': {
        'amlodipine': 'May increase risk of muscle pain and damage.',
        'amiodarone': 'May increase risk of muscle pain and damage.',
      },
      'metformin': {'glipizide': 'May cause low blood sugar.'},
      'levothyroxine': {
        'calcium': 'May reduce absorption of levothyroxine.',
        'iron': 'May reduce absorption of levothyroxine.',
      },
    };

    List<Map<String, String>> foundInteractions = [];

    // Compare each medication with every other medication
    for (int i = 0; i < medications.length; i++) {
      final med1 = medications[i];
      final name1 = med1['name'].toString().toLowerCase();
      final generic1 = med1['generic_name']?.toString().toLowerCase() ?? '';

      for (int j = i + 1; j < medications.length; j++) {
        final med2 = medications[j];
        final name2 = med2['name'].toString().toLowerCase();
        final generic2 = med2['generic_name']?.toString().toLowerCase() ?? '';

        // Check for interactions using both brand and generic names
        for (final baseKey in interactionMap.keys) {
          if (name1.contains(baseKey) || generic1.contains(baseKey)) {
            final interactions = interactionMap[baseKey];
            for (final interactingMed in interactions!.keys) {
              if (name2.contains(interactingMed) ||
                  generic2.contains(interactingMed)) {
                foundInteractions.add({
                  'med1': med1['name'],
                  'med2': med2['name'],
                  'warning': interactions[interactingMed]!,
                });
              }
            }
          } else if (name2.contains(baseKey) || generic2.contains(baseKey)) {
            final interactions = interactionMap[baseKey];
            for (final interactingMed in interactions!.keys) {
              if (name1.contains(interactingMed) ||
                  generic1.contains(interactingMed)) {
                foundInteractions.add({
                  'med1': med2['name'],
                  'med2': med1['name'],
                  'warning': interactions[interactingMed]!,
                });
              }
            }
          }
        }
      }
    }

    // Show the results in a dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              foundInteractions.isNotEmpty
                  ? 'Potential Interactions Found'
                  : 'No Interactions Found',
              style: TextStyle(
                color: foundInteractions.isNotEmpty ? Colors.red : Colors.green,
              ),
            ),
            content: SingleChildScrollView(
              child:
                  foundInteractions.isEmpty
                      ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No potential interactions were found between your medications.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Note: This is a basic check. Always consult with your healthcare provider about all medications you take.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...foundInteractions.map((interaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${interaction['med1']} + ${interaction['med2']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(interaction['warning']!),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Text(
                            'Important: This is a basic check. Always consult with your healthcare provider about all medications you take.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (foundInteractions.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    // Here you would implement logic to share with healthcare provider
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Interaction report saved to your health profile',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Share with Doctor'),
                ),
            ],
          ),
    );
  }

  Widget _buildRemindersTab() {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_off, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reminders set yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddReminderDialog,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Set Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final timeStr = reminder['time'];
        final timeParts = timeStr.split(':');
        final time = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.access_time, color: Colors.redAccent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            time.format(context),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            reminder['medication_name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: reminder['active'] ?? true,
                      activeColor: Colors.redAccent,
                      onChanged: (value) async {
                        setState(() {
                          reminder['active'] = value;
                          reminders[index] = reminder;
                        });

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList(
                          'reminders',
                          reminders.map((r) => jsonEncode(r)).toList(),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeats: ${reminder['repeat'] ?? 'Daily'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      if (reminder['notes'] != null &&
                          reminder['notes'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            reminder['notes'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          reminders.removeAt(index);
                        });

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList(
                          'reminders',
                          reminders.map((r) => jsonEncode(r)).toList(),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
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
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Medication Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Enter medication name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _searchMedication,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _searchMedication(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for medication information',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: Tylenol, Advil, Lipitor',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPharmaciesTab() {
    // Mock data for nearby pharmacies
    final List<Map<String, dynamic>> pharmacies = [
      {
        'name': 'HealthPlus Pharmacy',
        'address': '123 Main St, Cityville',
        'distance': '0.3',
        'isOpen': true,
        'openUntil': '10:00 PM',
        'rating': 4.5,
        'hasDriveThru': true,
        'has24HourService': false,
      },
      {
        'name': 'MediCare Drugstore',
        'address': '456 Oak Ave, Townsburg',
        'distance': '0.7',
        'isOpen': true,
        'openUntil': '9:00 PM',
        'rating': 4.2,
        'hasDriveThru': false,
        'has24HourService': false,
      },
      {
        'name': 'Community Pharmacy',
        'address': '789 Pine Blvd, Villageton',
        'distance': '1.2',
        'isOpen': false,
        'openAt': '8:00 AM tomorrow',
        'rating': 4.0,
        'hasDriveThru': true,
        'has24HourService': false,
      },
      {
        'name': 'All Night Pharmacy',
        'address': '101 Health Road, Wellnessville',
        'distance': '2.4',
        'isOpen': true,
        'openUntil': 'Open 24 hours',
        'rating': 4.3,
        'hasDriveThru': false,
        'has24HourService': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Pharmacies',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 12),
                const Text(
                  'Showing pharmacies near your current location',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filter by name or services...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // Show filter options
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter options coming soon')),
                  );
                },
                icon: const Icon(Icons.tune),
                tooltip: 'Filter',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.1,
                              ),
                              child: const Icon(
                                Icons.local_pharmacy,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pharmacy['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pharmacy['address'],
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${pharmacy['distance']} km',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    Text(' ${pharmacy['rating']}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    pharmacy['isOpen']
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color:
                                      pharmacy['isOpen']
                                          ? Colors.green.shade200
                                          : Colors.red.shade200,
                                ),
                              ),
                              child: Text(
                                pharmacy['isOpen']
                                    ? 'Open until ${pharmacy['openUntil']}'
                                    : 'Opens ${pharmacy['openAt']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      pharmacy['isOpen']
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (pharmacy['hasDriveThru'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  'Drive-thru',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (pharmacy['has24HourService'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.purple.shade200,
                                  ),
                                ),
                                child: Text(
                                  '24 Hours',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Call pharmacy
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Calling ${pharmacy['name']}...',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Get directions
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Directions to ${pharmacy['name']}',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.directions),
                                label: const Text('Directions'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceWidget(Map<String, dynamic> medication, int index) {
    // Ensure adherence data exists
    final adherence =
        medication.containsKey('adherence')
            ? medication['adherence']
            : {
              'total_doses': 0,
              'taken_doses': 0,
              'last_7_days': List.filled(7, false),
            };

    final int totalDoses = adherence['total_doses'] ?? 0;
    final int takenDoses = adherence['taken_doses'] ?? 0;
    final List<bool> last7Days = List<bool>.from(
      adherence['last_7_days'] ?? List.filled(7, false),
    );

    // Calculate adherence percentage
    final double adherencePercentage =
        totalDoses > 0 ? (takenDoses / totalDoses) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly calendar view
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDayIndicator('M', last7Days[0]),
            _buildDayIndicator('T', last7Days[1]),
            _buildDayIndicator('W', last7Days[2]),
            _buildDayIndicator('T', last7Days[3]),
            _buildDayIndicator('F', last7Days[4]),
            _buildDayIndicator('S', last7Days[5]),
            _buildDayIndicator('S', last7Days[6]),
          ],
        ),
        const SizedBox(height: 12),
        // Adherence stats
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adherence: ${adherencePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: adherencePercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      adherencePercentage >= 80
                          ? Colors.green
                          : adherencePercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Doses taken: $takenDoses',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _markMedicationAsTaken(index),
              icon: const Icon(Icons.check),
              label: const Text('Take Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (medication.containsKey('taken_logs') &&
            (medication['taken_logs'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last taken: ${_formatLastTakenDate(medication['taken_logs'] as List)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatLastTakenDate(List takenLogs) {
    if (takenLogs.isEmpty) return 'Never';

    final lastDate = DateTime.parse(takenLogs.last.toString());
    final now = DateTime.now();

    final difference = now.difference(lastDate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastDate);
    }
  }

  Widget _buildDayIndicator(String day, bool taken) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: taken ? Colors.green : Colors.grey.shade200,
            border: Border.all(
              color: taken ? Colors.green.shade700 : Colors.grey.shade400,
              width: 1,
            ),
          ),
          child:
              taken
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
        ),
      ],
    );
  }

  // Track medication adherence
  Future<void> _markMedicationAsTaken(int index) async {
    setState(() {
      final medication = medications[index];

      if (!medication.containsKey('adherence')) {
        medication['adherence'] = {
          'total_doses': 0,
          'taken_doses': 0,
          'last_7_days': List.filled(7, false),
        };
      }

      // Update today's adherence
      final adherence = medication['adherence'];
      adherence['total_doses'] = (adherence['total_doses'] as int) + 1;
      adherence['taken_doses'] = (adherence['taken_doses'] as int) + 1;

      // Update the last 7 days tracking
      final last7Days = List<bool>.from(adherence['last_7_days']);
      last7Days[DateTime.now().weekday % 7] = true;
      adherence['last_7_days'] = last7Days;

      // Add today's date to the taken logs
      if (!medication.containsKey('taken_logs')) {
        medication['taken_logs'] = [];
      }
      medication['taken_logs'].add(DateTime.now().toIso8601String());

      medications[index] = medication;
    });

    // Save the updated data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'medications',
      medications.map((m) => jsonEncode(m)).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication marked as taken'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startReminderChecks() {
    // Check for medication reminders every 30 seconds
    _reminderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForDueReminders();
    });

    // Also check immediately on startup
    _checkForDueReminders();
  }

  void _checkForDueReminders() {
    // Skip if no reminders or we're not in the foreground
    if (reminders.isEmpty || !mounted) return;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Find reminders that are due in the current time
    for (final reminder in reminders) {
      if (reminder['active'] != true) continue;

      final timeStr = reminder['time'].toString();
      final timeParts = timeStr.split(':');
      final reminderHour = int.tryParse(timeParts[0]) ?? 0;
      final reminderMinute = int.tryParse(timeParts[1]) ?? 0;
      final reminderMinutes = reminderHour * 60 + reminderMinute;

      // Check if it's time for the reminder (within 5 minute window)
      if ((currentMinutes - reminderMinutes).abs() <= 5) {
        final medicationName = reminder['medication_name'];

        // Show only if we haven't already shown this reminder recently
        final lastNotificationKey = 'last_notif_${reminder['id']}';
        final prefs = SharedPreferences.getInstance();
        prefs.then((prefs) {
          final lastNotification = prefs.getString(lastNotificationKey);
          final today = DateTime.now().toIso8601String().split('T')[0];

          // Only show once per day per reminder
          if (lastNotification != today) {
            _showAnimatedReminderNotification(medicationName);
            prefs.setString(lastNotificationKey, today);
          }
        });
      }
    }
  }

  void _showAnimatedReminderNotification(String medicationName) {
    // Show a custom animated notification overlay
    final overlay = Overlay.of(context);

    // Create overlay entry first before referencing it
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.redAccent,
                child: InkWell(
                  onTap: () {
                    // Navigate to reminders tab when clicked
                    _tabController.animateTo(1);
                    overlay.mounted ? overlayEntry.remove() : null;
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.medication_liquid,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Medication Reminder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Time to take $medicationName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Mark as taken
                            final medication = medications.firstWhere(
                              (med) => med['name'] == medicationName,
                              orElse: () => {},
                            );
                            if (medication.isNotEmpty) {
                              final index = medications.indexOf(medication);
                              _markMedicationAsTaken(index);
                            }
                            overlay.mounted ? overlayEntry.remove() : null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (overlay.mounted == true) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildMedicationInsights() {
    // Calculate overall adherence
    int totalTakenDoses = 0;
    int totalDoses = 0;

    // Get the current time as TimeOfDay
    final currentTimeOfDay = TimeOfDay.now();
    final morning = TimeOfDay(hour: 6, minute: 0);
    final afternoon = TimeOfDay(hour: 12, minute: 0);
    final evening = TimeOfDay(hour: 18, minute: 0);
    final night = TimeOfDay(hour: 21, minute: 0);

    // Current time in minutes since midnight
    final currentTimeInMinutes =
        currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

    String timeOfDay = "night";
    if (currentTimeInMinutes >= morning.hour * 60 + morning.minute &&
        currentTimeInMinutes < afternoon.hour * 60 + afternoon.minute) {
      timeOfDay = "morning";
    } else if (currentTimeInMinutes >= afternoon.hour * 60 + afternoon.minute &&
        currentTimeInMinutes < evening.hour * 60 + evening.minute) {
      timeOfDay = "afternoon";
    } else if (currentTimeInMinutes >= evening.hour * 60 + evening.minute &&
        currentTimeInMinutes < night.hour * 60 + night.minute) {
      timeOfDay = "evening";
    }

    // Get count of medications due soon
    int dueSoonCount = 0;
    for (final reminder in reminders) {
      if (reminder['active'] != true) continue;

      final timeStr = reminder['time'].toString();
      final timeParts = timeStr.split(':');
      final reminderHour = int.tryParse(timeParts[0]) ?? 0;
      final reminderMinute = int.tryParse(timeParts[1]) ?? 0;
      final reminderMinutes = reminderHour * 60 + reminderMinute;

      // Check if reminder is due within next 2 hours
      final timeDiff = reminderMinutes - currentTimeInMinutes;
      if (timeDiff > 0 && timeDiff <= 120) {
        dueSoonCount++;
      }
    }

    // Gather adherence data
    for (final medication in medications) {
      if (medication.containsKey('adherence')) {
        final adherence = medication['adherence'];
        totalTakenDoses += adherence['taken_doses'] as int;
        totalDoses += adherence['total_doses'] as int;
      }
    }

    // Calculate overall adherence percentage
    final double adherencePercentage =
        totalDoses > 0 ? (totalTakenDoses / totalDoses) * 100 : 0;

    // Generate insight message based on adherence
    String insightMessage;
    IconData insightIcon;
    Color insightColor;

    if (adherencePercentage >= 90) {
      insightMessage = "Excellent! Your medication adherence is very good.";
      insightIcon = Icons.thumb_up;
      insightColor = Colors.green;
    } else if (adherencePercentage >= 70) {
      insightMessage =
          "You're doing well with your medications, but there's room for improvement.";
      insightIcon = Icons.trending_up;
      insightColor = Colors.blue;
    } else if (adherencePercentage >= 50) {
      insightMessage =
          "Try to be more regular with your medications for better health outcomes.";
      insightIcon = Icons.trending_flat;
      insightColor = Colors.orange;
    } else {
      insightMessage =
          "Your medication adherence needs attention for optimal health benefits.";
      insightIcon = Icons.warning;
      insightColor = Colors.red;
    }

    // Add reminder about upcoming doses if any are due soon
    if (dueSoonCount > 0) {
      insightMessage +=
          " You have $dueSoonCount medication(s) due in the next 2 hours.";
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(insightIcon, color: insightColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good $timeOfDay!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insightMessage,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (totalDoses > 0) ...[
                  const Text(
                    'Overall Adherence',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: adherencePercentage / 100,
                    ),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$totalTakenDoses/$totalDoses doses taken',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.shade200,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              value >= 0.9
                                  ? Colors.green
                                  : value >= 0.7
                                  ? Colors.blue
                                  : value >= 0.5
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
