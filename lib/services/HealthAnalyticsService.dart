import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HealthMetric {
  final String id;
  final String name;
  final String unit;
  final List<HealthDataPoint> dataPoints;
  final double minValue;
  final double maxValue;
  final double normalMinValue;
  final double normalMaxValue;

  HealthMetric({
    required this.id,
    required this.name,
    required this.unit,
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
    required this.normalMinValue,
    required this.normalMaxValue,
  });

  // Get the latest value
  double? get latestValue {
    if (dataPoints.isEmpty) return null;
    dataPoints.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return dataPoints.first.value;
  }

  // Get the change percentage from previous value
  double? get changePercentage {
    if (dataPoints.length < 2) return null;
    dataPoints.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final latest = dataPoints[0].value;
    final previous = dataPoints[1].value;
    return ((latest - previous) / previous) * 100;
  }

  // Check if the latest value is within normal range
  bool get isWithinNormalRange {
    final value = latestValue;
    if (value == null) return true;
    return value >= normalMinValue && value <= normalMaxValue;
  }

  // Get data for chart visualization (last 7 days)
  List<double> getChartData(int days) {
    final now = DateTime.now();
    final result = List<double>.filled(days, 0);

    // Initialize with default values
    for (int i = 0; i < days; i++) {
      result[i] = 0;
    }

    // Fill with actual data where available
    for (final point in dataPoints) {
      final daysAgo = now.difference(point.timestamp).inDays;
      if (daysAgo < days) {
        result[days - daysAgo - 1] = point.value;
      }
    }

    return result;
  }

  // Create a copy with updated data points
  HealthMetric copyWith({List<HealthDataPoint>? dataPoints}) {
    return HealthMetric(
      id: id,
      name: name,
      unit: unit,
      dataPoints: dataPoints ?? this.dataPoints,
      minValue: minValue,
      maxValue: maxValue,
      normalMinValue: normalMinValue,
      normalMaxValue: normalMaxValue,
    );
  }
}

class HealthDataPoint {
  final double value;
  final DateTime timestamp;
  final String? notes;

  HealthDataPoint({required this.value, required this.timestamp, this.notes});

  // Convert to and from JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) {
    return HealthDataPoint(
      value: json['value'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      notes: json['notes'],
    );
  }
}

class HealthAnalyticsService {
  static final HealthAnalyticsService _instance =
      HealthAnalyticsService._internal();

  // Predefined metrics
  static const String WEIGHT = 'weight';
  static const String BLOOD_PRESSURE = 'blood_pressure';
  static const String BLOOD_GLUCOSE = 'blood_glucose';
  static const String HEART_RATE = 'heart_rate';
  static const String SLEEP = 'sleep';
  static const String STEPS = 'steps';
  static const String WATER = 'water';
  static const String CALORIES = 'calories';

  // Store metrics
  Map<String, HealthMetric> _metrics = {};

  factory HealthAnalyticsService() {
    return _instance;
  }

  HealthAnalyticsService._internal() {
    _initializeMetrics();
  }

  // Initialize default metrics
  void _initializeMetrics() {
    _metrics = {
      WEIGHT: HealthMetric(
        id: WEIGHT,
        name: 'Weight',
        unit: 'kg',
        dataPoints: [],
        minValue: 30,
        maxValue: 200,
        normalMinValue: 50,
        normalMaxValue: 100,
      ),
      BLOOD_PRESSURE: HealthMetric(
        id: BLOOD_PRESSURE,
        name: 'Blood Pressure',
        unit: 'mmHg',
        dataPoints: [],
        minValue: 80,
        maxValue: 200,
        normalMinValue: 90,
        normalMaxValue: 120,
      ),
      BLOOD_GLUCOSE: HealthMetric(
        id: BLOOD_GLUCOSE,
        name: 'Blood Glucose',
        unit: 'mg/dL',
        dataPoints: [],
        minValue: 50,
        maxValue: 300,
        normalMinValue: 70,
        normalMaxValue: 140,
      ),
      HEART_RATE: HealthMetric(
        id: HEART_RATE,
        name: 'Heart Rate',
        unit: 'bpm',
        dataPoints: [],
        minValue: 40,
        maxValue: 200,
        normalMinValue: 60,
        normalMaxValue: 100,
      ),
      SLEEP: HealthMetric(
        id: SLEEP,
        name: 'Sleep',
        unit: 'hours',
        dataPoints: [],
        minValue: 0,
        maxValue: 12,
        normalMinValue: 7,
        normalMaxValue: 9,
      ),
      STEPS: HealthMetric(
        id: STEPS,
        name: 'Steps',
        unit: 'steps',
        dataPoints: [],
        minValue: 0,
        maxValue: 30000,
        normalMinValue: 7000,
        normalMaxValue: 10000,
      ),
      WATER: HealthMetric(
        id: WATER,
        name: 'Water Intake',
        unit: 'ml',
        dataPoints: [],
        minValue: 0,
        maxValue: 5000,
        normalMinValue: 2000,
        normalMaxValue: 3000,
      ),
      CALORIES: HealthMetric(
        id: CALORIES,
        name: 'Calories',
        unit: 'kcal',
        dataPoints: [],
        minValue: 0,
        maxValue: 5000,
        normalMinValue: 1500,
        normalMaxValue: 2500,
      ),
    };
  }

  // Load metrics from SharedPreferences
  Future<void> loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();

    for (final metricId in _metrics.keys) {
      final dataJson = prefs.getStringList('health_metric_$metricId') ?? [];
      final dataPoints =
          dataJson
              .map((json) => HealthDataPoint.fromJson(jsonDecode(json)))
              .toList();

      _metrics[metricId] = _metrics[metricId]!.copyWith(dataPoints: dataPoints);
    }
  }

  // Save metrics to SharedPreferences
  Future<void> saveMetrics() async {
    final prefs = await SharedPreferences.getInstance();

    for (final metricId in _metrics.keys) {
      final metric = _metrics[metricId]!;
      final dataJson =
          metric.dataPoints.map((point) => jsonEncode(point.toJson())).toList();

      await prefs.setStringList('health_metric_$metricId', dataJson);
    }
  }

  // Add a data point to a metric
  Future<void> addDataPoint(
    String metricId,
    double value, {
    String? notes,
  }) async {
    if (!_metrics.containsKey(metricId)) return;

    final metric = _metrics[metricId]!;
    final newDataPoint = HealthDataPoint(
      value: value,
      timestamp: DateTime.now(),
      notes: notes,
    );

    final updatedDataPoints = [...metric.dataPoints, newDataPoint];
    _metrics[metricId] = metric.copyWith(dataPoints: updatedDataPoints);

    await saveMetrics();
  }

  // Get a specific metric
  HealthMetric? getMetric(String metricId) {
    return _metrics[metricId];
  }

  // Get all metrics
  Map<String, HealthMetric> getAllMetrics() {
    return _metrics;
  }

  // Get metrics that need attention (outside normal range)
  List<HealthMetric> getMetricsNeedingAttention() {
    return _metrics.values
        .where(
          (metric) =>
              metric.dataPoints.isNotEmpty && !metric.isWithinNormalRange,
        )
        .toList();
  }

  // Generate health insights based on the user's health metrics
  List<HealthInsight> generateInsights() {
    return _generateInsights();
  }

  // Internal method to generate health insights
  List<HealthInsight> _generateInsights() {
    final insights = <HealthInsight>[];

    // Check weight changes
    final weightMetric = _metrics[WEIGHT];
    if (weightMetric != null && weightMetric.dataPoints.length >= 2) {
      final latest = weightMetric.latestValue;
      final changePercentage = weightMetric.changePercentage;

      if (latest != null && changePercentage != null) {
        if (changePercentage > 5) {
          insights.add(
            HealthInsight(
              title: 'Weight Gain Alert',
              message:
                  'You\'ve gained ${changePercentage.toStringAsFixed(1)}% weight recently. Consider checking your diet.',
              priority: InsightPriority.medium,
              relatedMetricId: WEIGHT,
            ),
          );
        } else if (changePercentage < -5) {
          insights.add(
            HealthInsight(
              title: 'Weight Loss Detected',
              message:
                  'You\'ve lost ${(-changePercentage).toStringAsFixed(1)}% weight recently. Ensure this is intentional.',
              priority: InsightPriority.medium,
              relatedMetricId: WEIGHT,
            ),
          );
        }
      }
    }

    // Check blood pressure
    final bpMetric = _metrics[BLOOD_PRESSURE];
    if (bpMetric != null && bpMetric.dataPoints.isNotEmpty) {
      final latestBP = bpMetric.latestValue;
      if (latestBP != null && latestBP > 130) {
        insights.add(
          HealthInsight(
            title: 'High Blood Pressure',
            message:
                'Your blood pressure is above the recommended range. Consider consulting a doctor.',
            priority: InsightPriority.high,
            relatedMetricId: BLOOD_PRESSURE,
          ),
        );
      }
    }

    // Check sleep patterns
    final sleepMetric = _metrics[SLEEP];
    if (sleepMetric != null && sleepMetric.dataPoints.length >= 5) {
      final recentPoints = List<HealthDataPoint>.from(sleepMetric.dataPoints)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final lastFivePoints = recentPoints.take(5).toList();

      final avgSleep =
          lastFivePoints.map((p) => p.value).reduce((a, b) => a + b) /
          lastFivePoints.length;

      if (avgSleep < 6) {
        insights.add(
          HealthInsight(
            title: 'Sleep Deficit',
            message:
                'You\'re averaging only ${avgSleep.toStringAsFixed(1)} hours of sleep. Aim for 7-9 hours for optimal health.',
            priority: InsightPriority.medium,
            relatedMetricId: SLEEP,
          ),
        );
      }
    }

    // Check water intake
    final waterMetric = _metrics[WATER];
    if (waterMetric != null && waterMetric.dataPoints.isNotEmpty) {
      final latestWater = waterMetric.latestValue;
      if (latestWater != null && latestWater < 1500) {
        insights.add(
          HealthInsight(
            title: 'Low Water Intake',
            message:
                'You\'re not drinking enough water. Aim for at least 2000ml daily for proper hydration.',
            priority: InsightPriority.low,
            relatedMetricId: WATER,
          ),
        );
      }
    }

    return insights;
  }

  // Generate mock data for demonstration purposes
  Future<void> generateMockData() async {
    final random = Random();
    final now = DateTime.now();

    // Generate 30 days of mock data for each metric
    for (final metricId in _metrics.keys) {
      final metric = _metrics[metricId]!;
      final mockDataPoints = <HealthDataPoint>[];

      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));

        // Generate a value within the normal range with some variation
        final baseValue = (metric.normalMinValue + metric.normalMaxValue) / 2;
        final variation = (metric.normalMaxValue - metric.normalMinValue) / 4;
        final value =
            baseValue + (random.nextDouble() * variation * 2 - variation);

        mockDataPoints.add(
          HealthDataPoint(value: value, timestamp: date, notes: null),
        );
      }

      _metrics[metricId] = metric.copyWith(dataPoints: mockDataPoints);
    }

    await saveMetrics();
  }

  // Format a metric value with its unit
  String formatMetricValue(String metricId, double value) {
    if (!_metrics.containsKey(metricId)) return value.toString();

    final metric = _metrics[metricId]!;
    return '${value.toStringAsFixed(1)} ${metric.unit}';
  }
}

class HealthInsight {
  final String title;
  final String message;
  final InsightPriority priority;
  final String? relatedMetricId;

  HealthInsight({
    required this.title,
    required this.message,
    required this.priority,
    this.relatedMetricId,
  });

  Color get priorityColor {
    switch (priority) {
      case InsightPriority.low:
        return Colors.blue;
      case InsightPriority.medium:
        return Colors.orange;
      case InsightPriority.high:
        return Colors.red;
    }
  }
}

enum InsightPriority { low, medium, high }
