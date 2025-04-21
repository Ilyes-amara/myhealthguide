import 'package:flutter/material.dart';

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'isAvailable': isAvailable,
    };
  }

  // Create from JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: TimeOfDay(hour: json['startHour'], minute: json['startMinute']),
      endTime: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  // Format time for display
  String get formattedStartTime => _formatTimeOfDay(startTime);
  String get formattedEndTime => _formatTimeOfDay(endTime);

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class DailyAvailability {
  final String dayName;
  final bool isWorkingDay;
  final List<TimeSlot> timeSlots;
  final bool allowsHomeVisits;
  final bool allowsOnlineVisits;

  DailyAvailability({
    required this.dayName,
    this.isWorkingDay = true,
    this.timeSlots = const [],
    this.allowsHomeVisits = false,
    this.allowsOnlineVisits = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      'isWorkingDay': isWorkingDay,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'allowsHomeVisits': allowsHomeVisits,
      'allowsOnlineVisits': allowsOnlineVisits,
    };
  }

  // Create from JSON
  factory DailyAvailability.fromJson(Map<String, dynamic> json) {
    return DailyAvailability(
      dayName: json['dayName'],
      isWorkingDay: json['isWorkingDay'] ?? true,
      timeSlots: (json['timeSlots'] as List? ?? [])
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      allowsHomeVisits: json['allowsHomeVisits'] ?? false,
      allowsOnlineVisits: json['allowsOnlineVisits'] ?? true,
    );
  }

  // Create a copy with updated values
  DailyAvailability copyWith({
    String? dayName,
    bool? isWorkingDay,
    List<TimeSlot>? timeSlots,
    bool? allowsHomeVisits,
    bool? allowsOnlineVisits,
  }) {
    return DailyAvailability(
      dayName: dayName ?? this.dayName,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      timeSlots: timeSlots ?? this.timeSlots,
      allowsHomeVisits: allowsHomeVisits ?? this.allowsHomeVisits,
      allowsOnlineVisits: allowsOnlineVisits ?? this.allowsOnlineVisits,
    );
  }
}

class DoctorAvailability {
  final List<DailyAvailability> weeklySchedule;
  final int appointmentDurationMinutes;
  final int maxAppointmentsPerDay;
  final bool acceptsNewPatients;

  DoctorAvailability({
    required this.weeklySchedule,
    this.appointmentDurationMinutes = 30,
    this.maxAppointmentsPerDay = 20,
    this.acceptsNewPatients = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'weeklySchedule': weeklySchedule.map((day) => day.toJson()).toList(),
      'appointmentDurationMinutes': appointmentDurationMinutes,
      'maxAppointmentsPerDay': maxAppointmentsPerDay,
      'acceptsNewPatients': acceptsNewPatients,
    };
  }

  // Create from JSON
  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      weeklySchedule: (json['weeklySchedule'] as List? ?? [])
          .map((day) => DailyAvailability.fromJson(day))
          .toList(),
      appointmentDurationMinutes: json['appointmentDurationMinutes'] ?? 30,
      maxAppointmentsPerDay: json['maxAppointmentsPerDay'] ?? 20,
      acceptsNewPatients: json['acceptsNewPatients'] ?? true,
    );
  }

  // Create default availability
  factory DoctorAvailability.createDefault() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weeklySchedule = days.map((day) {
      final isWeekend = day == 'Saturday' || day == 'Sunday';
      return DailyAvailability(
        dayName: day,
        isWorkingDay: !isWeekend,
        timeSlots: isWeekend
            ? []
            : [
                TimeSlot(
                  startTime: const TimeOfDay(hour: 9, minute: 0),
                  endTime: const TimeOfDay(hour: 12, minute: 0),
                ),
                TimeSlot(
                  startTime: const TimeOfDay(hour: 14, minute: 0),
                  endTime: const TimeOfDay(hour: 17, minute: 0),
                ),
              ],
        allowsHomeVisits: day == 'Wednesday',
        allowsOnlineVisits: true,
      );
    }).toList();

    return DoctorAvailability(weeklySchedule: weeklySchedule);
  }

  // Get available time slots for a specific date
  List<TimeOfDay> getAvailableTimeSlotsForDate(DateTime date) {
    final dayName = _getDayName(date.weekday);
    final dailyAvailability = weeklySchedule.firstWhere(
      (day) => day.dayName == dayName,
      orElse: () => DailyAvailability(dayName: dayName, isWorkingDay: false),
    );

    if (!dailyAvailability.isWorkingDay || dailyAvailability.timeSlots.isEmpty) {
      return [];
    }

    final List<TimeOfDay> availableSlots = [];
    for (final timeSlot in dailyAvailability.timeSlots) {
      if (!timeSlot.isAvailable) continue;

      // Generate slots based on appointment duration
      TimeOfDay currentTime = timeSlot.startTime;
      while (_isTimeBefore(currentTime, timeSlot.endTime)) {
        availableSlots.add(currentTime);
        // Add appointment duration to current time
        final totalMinutes = currentTime.hour * 60 + currentTime.minute + appointmentDurationMinutes;
        currentTime = TimeOfDay(
          hour: totalMinutes ~/ 60,
          minute: totalMinutes % 60,
        );
      }
    }

    return availableSlots;
  }

  // Check if a time is before another time
  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour < time2.hour || (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  // Get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}
