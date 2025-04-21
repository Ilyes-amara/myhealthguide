import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// This is a mock implementation of Google Calendar API integration
// In a real app, you would use the google_sign_in and googleapis packages
class GoogleCalendarService {
  // Singleton pattern
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  // Check if the user is authenticated with Google
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('google_calendar_authenticated') ?? false;
  }

  // Mock Google authentication
  Future<bool> authenticate() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Store authentication status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_calendar_authenticated', true);
      
      return true;
    } catch (e) {
      debugPrint('Google Calendar authentication error: $e');
      return false;
    }
  }

  // Sign out from Google
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_calendar_authenticated', false);
  }

  // Add an appointment to Google Calendar
  Future<Map<String, dynamic>> addAppointment(Map<String, dynamic> appointment) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate a mock Google Calendar event ID
      final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
      
      // Store the event locally (in a real app, this would be in Google Calendar)
      final prefs = await SharedPreferences.getInstance();
      final events = jsonDecode(prefs.getString('google_calendar_events') ?? '[]') as List;
      
      // Add Google Calendar specific fields
      final calendarEvent = {
        ...appointment,
        'eventId': eventId,
        'created': DateTime.now().toIso8601String(),
        'calendarLink': 'https://calendar.google.com/calendar/event?eid=$eventId',
      };
      
      events.add(calendarEvent);
      await prefs.setString('google_calendar_events', jsonEncode(events));
      
      return calendarEvent;
    } catch (e) {
      debugPrint('Google Calendar add appointment error: $e');
      rethrow;
    }
  }

  // Update an appointment in Google Calendar
  Future<Map<String, dynamic>> updateAppointment(String eventId, Map<String, dynamic> updatedData) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the event locally
      final prefs = await SharedPreferences.getInstance();
      final events = jsonDecode(prefs.getString('google_calendar_events') ?? '[]') as List;
      
      final eventIndex = events.indexWhere((event) => event['eventId'] == eventId);
      if (eventIndex == -1) {
        throw Exception('Event not found');
      }
      
      events[eventIndex] = {
        ...events[eventIndex],
        ...updatedData,
        'updated': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('google_calendar_events', jsonEncode(events));
      
      return events[eventIndex];
    } catch (e) {
      debugPrint('Google Calendar update appointment error: $e');
      rethrow;
    }
  }

  // Delete an appointment from Google Calendar
  Future<bool> deleteAppointment(String eventId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Delete the event locally
      final prefs = await SharedPreferences.getInstance();
      final events = jsonDecode(prefs.getString('google_calendar_events') ?? '[]') as List;
      
      final filteredEvents = events.where((event) => event['eventId'] != eventId).toList();
      await prefs.setString('google_calendar_events', jsonEncode(filteredEvents));
      
      return true;
    } catch (e) {
      debugPrint('Google Calendar delete appointment error: $e');
      return false;
    }
  }

  // Get all appointments from Google Calendar
  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Get events from local storage
      final prefs = await SharedPreferences.getInstance();
      final events = jsonDecode(prefs.getString('google_calendar_events') ?? '[]') as List;
      
      return List<Map<String, dynamic>>.from(events);
    } catch (e) {
      debugPrint('Google Calendar get appointments error: $e');
      return [];
    }
  }
}
