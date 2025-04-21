import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';
import 'models/DoctorAvailability.dart';

class DoctorAvailabilityPage extends StatefulWidget {
  const DoctorAvailabilityPage({super.key});

  @override
  _DoctorAvailabilityPageState createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  late DoctorAvailability _availability;
  bool _isLoading = true;
  bool _hasChanges = false;
  int _appointmentDuration = 30;
  int _maxAppointments = 20;
  bool _acceptsNewPatients = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  void _loadAvailability() {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    if (doctorProvider.availability != null) {
      _availability = doctorProvider.availability!;
      _appointmentDuration = _availability.appointmentDurationMinutes;
      _maxAppointments = _availability.maxAppointmentsPerDay;
      _acceptsNewPatients = _availability.acceptsNewPatients;
    } else {
      _availability = DoctorAvailability.createDefault();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAvailability() async {
    setState(() {
      _isLoading = true;
    });

    final updatedAvailability = DoctorAvailability(
      weeklySchedule: _availability.weeklySchedule,
      appointmentDurationMinutes: _appointmentDuration,
      maxAppointmentsPerDay: _maxAppointments,
      acceptsNewPatients: _acceptsNewPatients,
    );

    await Provider.of<DoctorProvider>(
      context,
      listen: false,
    ).updateAvailability(updatedAvailability);

    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Availability settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectTimeRange(
    BuildContext context,
    DailyAvailability day,
    int slotIndex,
  ) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: day.timeSlots[slotIndex].startTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: day.timeSlots[slotIndex].endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (endTime == null) return;

    // Check if end time is after start time
    if (endTime.hour < startTime.hour ||
        (endTime.hour == startTime.hour &&
            endTime.minute <= startTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final updatedSlot = TimeSlot(
        startTime: startTime,
        endTime: endTime,
        isAvailable: day.timeSlots[slotIndex].isAvailable,
      );

      final updatedTimeSlots = List<TimeSlot>.from(day.timeSlots);
      updatedTimeSlots[slotIndex] = updatedSlot;

      final updatedDay = day.copyWith(timeSlots: updatedTimeSlots);

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  void _addTimeSlot(DailyAvailability day) {
    setState(() {
      final newSlot = TimeSlot(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final updatedTimeSlots = List<TimeSlot>.from(day.timeSlots)..add(newSlot);

      final updatedDay = day.copyWith(timeSlots: updatedTimeSlots);

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  void _removeTimeSlot(DailyAvailability day, int slotIndex) {
    setState(() {
      final updatedTimeSlots = List<TimeSlot>.from(day.timeSlots);
      updatedTimeSlots.removeAt(slotIndex);

      final updatedDay = day.copyWith(timeSlots: updatedTimeSlots);

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  void _toggleWorkingDay(DailyAvailability day) {
    setState(() {
      final updatedDay = day.copyWith(isWorkingDay: !day.isWorkingDay);

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  void _toggleHomeVisits(DailyAvailability day) {
    setState(() {
      final updatedDay = day.copyWith(allowsHomeVisits: !day.allowsHomeVisits);

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  void _toggleOnlineVisits(DailyAvailability day) {
    setState(() {
      final updatedDay = day.copyWith(
        allowsOnlineVisits: !day.allowsOnlineVisits,
      );

      final index = _availability.weeklySchedule.indexWhere(
        (d) => d.dayName == day.dayName,
      );

      final updatedSchedule = List<DailyAvailability>.from(
        _availability.weeklySchedule,
      );
      updatedSchedule[index] = updatedDay;

      _availability = DoctorAvailability(
        weeklySchedule: updatedSchedule,
        appointmentDurationMinutes: _appointmentDuration,
        maxAppointmentsPerDay: _maxAppointments,
        acceptsNewPatients: _acceptsNewPatients,
      );

      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Settings'),
        backgroundColor: Colors.blue,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAvailability,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Google Calendar integration card
                    _buildGoogleCalendarCard(),
                    const SizedBox(height: 20),

                    // Appointment settings card
                    _buildAppointmentSettingsCard(),
                    const SizedBox(height: 20),

                    // Weekly schedule
                    const Text(
                      'Weekly Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._availability.weeklySchedule.map(
                      (day) => _buildDayCard(day),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildGoogleCalendarCard() {
    final isConnected =
        Provider.of<DoctorProvider>(context).isCalendarConnected;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/google_calendar_icon.png',
                  width: 32,
                  height: 32,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.calendar_month,
                        size: 32,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Google Calendar Integration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isConnected
                  ? 'Your Google Calendar is connected. Appointments will be automatically synced.'
                  : 'Connect your Google Calendar to sync appointments automatically.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isConnected ? Icons.link_off : Icons.link),
                label: Text(
                  isConnected ? 'Disconnect Calendar' : 'Connect Calendar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  if (isConnected) {
                    await Provider.of<DoctorProvider>(
                      context,
                      listen: false,
                    ).disconnectGoogleCalendar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Calendar disconnected'),
                      ),
                    );
                  } else {
                    final success =
                        await Provider.of<DoctorProvider>(
                          context,
                          listen: false,
                        ).connectGoogleCalendar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Google Calendar connected successfully'
                              : 'Failed to connect Google Calendar',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Appointment Duration:')),
                Expanded(
                  flex: 3,
                  child: DropdownButton<int>(
                    value: _appointmentDuration,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _appointmentDuration = value!;
                        _hasChanges = true;
                      });
                    },
                    items:
                        [15, 30, 45, 60].map((duration) {
                          return DropdownMenuItem<int>(
                            value: duration,
                            child: Text('$duration minutes'),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('Max Appointments Per Day:'),
                ),
                Expanded(
                  flex: 3,
                  child: DropdownButton<int>(
                    value: _maxAppointments,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _maxAppointments = value!;
                        _hasChanges = true;
                      });
                    },
                    items:
                        [10, 15, 20, 25, 30].map((count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count appointments'),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Accept New Patients'),
              value: _acceptsNewPatients,
              activeColor: Colors.blue,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _acceptsNewPatients = value;
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(DailyAvailability day) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              day.dayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: day.isWorkingDay ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            if (day.isWorkingDay)
              const Icon(Icons.check_circle, color: Colors.green, size: 16)
            else
              const Icon(Icons.cancel, color: Colors.red, size: 16),
          ],
        ),
        subtitle:
            day.isWorkingDay
                ? Text(
                  day.timeSlots.isEmpty
                      ? 'No time slots configured'
                      : '${day.timeSlots.length} time slot(s)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                )
                : const Text(
                  'Not a working day',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Working Day'),
                  value: day.isWorkingDay,
                  activeColor: Colors.blue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (_) => _toggleWorkingDay(day),
                ),
                if (day.isWorkingDay) ...[
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Home Visits'),
                          value: day.allowsHomeVisits,
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => _toggleHomeVisits(day),
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Online Visits'),
                          value: day.allowsOnlineVisits,
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => _toggleOnlineVisits(day),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Time Slots',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...day.timeSlots.asMap().entries.map((entry) {
                    final index = entry.key;
                    final slot = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${slot.formattedStartTime} - ${slot.formattedEndTime}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                () => _selectTimeRange(context, day, index),
                            tooltip: 'Edit time slot',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTimeSlot(day, index),
                            tooltip: 'Remove time slot',
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Time Slot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _addTimeSlot(day),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
