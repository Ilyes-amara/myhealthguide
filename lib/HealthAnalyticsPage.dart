import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'services/HealthAnalyticsService.dart';
import 'theme/AppTheme.dart';

class HealthAnalyticsPage extends StatefulWidget {
  const HealthAnalyticsPage({Key? key}) : super(key: key);

  @override
  _HealthAnalyticsPageState createState() => _HealthAnalyticsPageState();
}

class _HealthAnalyticsPageState extends State<HealthAnalyticsPage> {
  final HealthAnalyticsService _analyticsService = HealthAnalyticsService();
  String _selectedMetricId = HealthAnalyticsService.WEIGHT;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load saved metrics or generate mock data if none exists
    await _analyticsService.loadMetrics();

    // If no data exists, generate mock data for demonstration
    final metric = _analyticsService.getMetric(_selectedMetricId);
    if (metric == null || metric.dataPoints.isEmpty) {
      await _analyticsService.generateMockData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Analytics'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDataPointDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Data Point',
      ),
    );
  }

  Widget _buildContent() {
    final metrics = _analyticsService.getAllMetrics();
    final selectedMetric = metrics[_selectedMetricId]!;
    final insights = _analyticsService.generateInsights();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsOverview(metrics),
          const SizedBox(height: AppTheme.spacingL),

          AppTheme.buildSectionHeader(
            title: 'Selected Metric Details',
            actionLabel: 'View All',
            onActionPressed: () {
              // Navigate to detailed view
            },
          ),
          _buildMetricDetails(selectedMetric),
          const SizedBox(height: AppTheme.spacingL),

          if (insights.isNotEmpty) ...[
            AppTheme.buildSectionHeader(title: 'Health Insights'),
            _buildInsights(insights),
            const SizedBox(height: AppTheme.spacingL),
          ],

          AppTheme.buildSectionHeader(title: 'Metric History'),
          _buildMetricChart(selectedMetric),
          const SizedBox(height: AppTheme.spacingL),

          AppTheme.buildSectionHeader(title: 'All Metrics'),
          _buildMetricsList(metrics),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(Map<String, HealthMetric> metrics) {
    // Find metrics that need attention
    final metricsNeedingAttention =
        _analyticsService.getMetricsNeedingAttention();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Health Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            metricsNeedingAttention.isEmpty
                ? 'All your health metrics are within normal ranges. Great job!'
                : '${metricsNeedingAttention.length} metric(s) need your attention.',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                'Metrics Tracked',
                metrics.values
                    .where((m) => m.dataPoints.isNotEmpty)
                    .length
                    .toString(),
                Icons.track_changes,
              ),
              _buildOverviewItem(
                'Last Updated',
                _getLastUpdatedDate(metrics),
                Icons.update,
              ),
              _buildOverviewItem(
                'Health Score',
                _calculateHealthScore(metrics).toString(),
                Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMetricDetails(HealthMetric metric) {
    final latestValue = metric.latestValue;
    final changePercentage = metric.changePercentage;

    return AppTheme.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.name, style: AppTheme.subtitleLarge),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'Normal range: ${metric.normalMinValue}-${metric.normalMaxValue} ${metric.unit}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color:
                      metric.isWithinNormalRange
                          ? AppTheme.statusActive.withOpacity(0.1)
                          : AppTheme.statusCancelled.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusCircular,
                  ),
                ),
                child: Text(
                  metric.isWithinNormalRange ? 'Normal' : 'Attention Needed',
                  style: AppTheme.bodySmall.copyWith(
                    color:
                        metric.isWithinNormalRange
                            ? AppTheme.statusActive
                            : AppTheme.statusCancelled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Value', style: AppTheme.bodySmall),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      latestValue != null
                          ? '${latestValue.toStringAsFixed(1)} ${metric.unit}'
                          : 'No data',
                      style: AppTheme.headingMedium,
                    ),
                  ],
                ),
              ),
              if (changePercentage != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Change', style: AppTheme.bodySmall),
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          Icon(
                            changePercentage > 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color:
                                changePercentage > 0
                                    ? AppTheme.warningColor
                                    : AppTheme.infoColor,
                            size: 16,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            '${changePercentage.abs().toStringAsFixed(1)}%',
                            style: AppTheme.subtitleMedium.copyWith(
                              color:
                                  changePercentage > 0
                                      ? AppTheme.warningColor
                                      : AppTheme.infoColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(List<HealthInsight> insights) {
    return Column(
      children:
          insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: AppTheme.buildCard(
                color: insight.priorityColor.withOpacity(0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: insight.priorityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getInsightIcon(insight.priority),
                        color: insight.priorityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight.title, style: AppTheme.subtitleMedium),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(insight.message, style: AppTheme.bodyMedium),
                          if (insight.relatedMetricId != null) ...[
                            const SizedBox(height: AppTheme.spacingM),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMetricId = insight.relatedMetricId!;
                                });
                              },
                              child: Text(
                                'View related metric',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMetricChart(HealthMetric metric) {
    final chartData = metric.getChartData(7); // Last 7 days
    final hasData = chartData.any((value) => value > 0);

    if (!hasData) {
      return AppTheme.buildEmptyState(
        message:
            'No data available for this metric. Add data points to see the chart.',
        icon: Icons.show_chart,
        actionLabel: 'Add Data',
        onActionPressed: _showAddDataPointDialog,
      );
    }

    return AppTheme.buildCard(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 Days', style: AppTheme.subtitleMedium),
          const SizedBox(height: AppTheme.spacingL),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.backgroundTertiary,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppTheme.backgroundTertiary,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            DateFormat('E').format(date),
                            style: AppTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (metric.maxValue - metric.minValue) / 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            value.toStringAsFixed(0),
                            style: AppTheme.bodySmall,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppTheme.backgroundTertiary),
                ),
                minX: 0,
                maxX: 6,
                minY: metric.minValue,
                maxY: metric.maxValue,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) {
                      return FlSpot(index.toDouble(), chartData[index]);
                    }),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColorLight,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.3),
                          AppTheme.primaryColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Add normal range indicator
                  LineChartBarData(
                    spots: [
                      FlSpot(0, metric.normalMaxValue),
                      FlSpot(6, metric.normalMaxValue),
                    ],
                    isCurved: false,
                    color: AppTheme.infoColor.withOpacity(0.5),
                    barWidth: 1,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, metric.normalMinValue),
                      FlSpot(6, metric.normalMinValue),
                    ],
                    isCurved: false,
                    color: AppTheme.infoColor.withOpacity(0.5),
                    barWidth: 1,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text('Normal Range', style: AppTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList(Map<String, HealthMetric> metrics) {
    return Column(
      children:
          metrics.values.map((metric) {
            final latestValue = metric.latestValue;
            final hasData = latestValue != null;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMetricId = metric.id;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color:
                      _selectedMetricId == metric.id
                          ? AppTheme.primaryColor.withOpacity(0.05)
                          : AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  border: Border.all(
                    color:
                        _selectedMetricId == metric.id
                            ? AppTheme.primaryColor
                            : AppTheme.backgroundTertiary,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getMetricIconColor(metric.id).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMetricIcon(metric.id),
                        color: _getMetricIconColor(metric.id),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(metric.name, style: AppTheme.subtitleMedium),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            hasData
                                ? '${latestValue.toStringAsFixed(1)} ${metric.unit}'
                                : 'No data',
                            style: AppTheme.bodyMedium.copyWith(
                              color:
                                  hasData
                                      ? AppTheme.textPrimary
                                      : AppTheme.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasData && !metric.isWithinNormalRange)
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXS),
                        decoration: const BoxDecoration(
                          color: AppTheme.warningColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  void _showAddDataPointDialog() {
    final metric = _analyticsService.getMetric(_selectedMetricId)!;
    final TextEditingController valueController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add ${metric.name} Data Point'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Value (${metric.unit})',
                    hintText: 'Enter value',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Enter any notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (valueController.text.isNotEmpty) {
                    final value = double.tryParse(valueController.text);
                    if (value != null) {
                      await _analyticsService.addDataPoint(
                        _selectedMetricId,
                        value,
                        notes:
                            notesController.text.isNotEmpty
                                ? notesController.text
                                : null,
                      );

                      Navigator.pop(context);
                      setState(() {});
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Helper methods

  String _getLastUpdatedDate(Map<String, HealthMetric> metrics) {
    DateTime? lastUpdated;

    for (final metric in metrics.values) {
      if (metric.dataPoints.isNotEmpty) {
        final dates = metric.dataPoints.map((p) => p.timestamp).toList();
        // Create a properly sorted list of dates
        final sortedDates = List<DateTime>.from(dates)
          ..sort((a, b) => b.compareTo(a));

        if (lastUpdated == null || sortedDates.first.isAfter(lastUpdated)) {
          lastUpdated = sortedDates.first;
        }
      }
    }

    if (lastUpdated == null) {
      return 'N/A';
    }

    return DateFormat('MMM d').format(lastUpdated);
  }

  int _calculateHealthScore(Map<String, HealthMetric> metrics) {
    int score = 70; // Base score
    int metricsWithData = 0;

    for (final metric in metrics.values) {
      if (metric.dataPoints.isNotEmpty) {
        metricsWithData++;

        if (metric.isWithinNormalRange) {
          score += 5;
        } else {
          score -= 5;
        }
      }
    }

    // Bonus for tracking multiple metrics
    score += (metricsWithData > 3) ? 5 : 0;

    // Cap score between 0 and 100
    return score.clamp(0, 100);
  }

  IconData _getMetricIcon(String metricId) {
    switch (metricId) {
      case HealthAnalyticsService.WEIGHT:
        return Icons.monitor_weight;
      case HealthAnalyticsService.BLOOD_PRESSURE:
        return Icons.favorite;
      case HealthAnalyticsService.BLOOD_GLUCOSE:
        return Icons.bloodtype;
      case HealthAnalyticsService.HEART_RATE:
        return Icons.favorite_border;
      case HealthAnalyticsService.SLEEP:
        return Icons.nightlight;
      case HealthAnalyticsService.STEPS:
        return Icons.directions_walk;
      case HealthAnalyticsService.WATER:
        return Icons.water_drop;
      case HealthAnalyticsService.CALORIES:
        return Icons.local_fire_department;
      default:
        return Icons.health_and_safety;
    }
  }

  Color _getMetricIconColor(String metricId) {
    switch (metricId) {
      case HealthAnalyticsService.WEIGHT:
        return Colors.blue;
      case HealthAnalyticsService.BLOOD_PRESSURE:
        return Colors.red;
      case HealthAnalyticsService.BLOOD_GLUCOSE:
        return Colors.purple;
      case HealthAnalyticsService.HEART_RATE:
        return Colors.pink;
      case HealthAnalyticsService.SLEEP:
        return Colors.indigo;
      case HealthAnalyticsService.STEPS:
        return Colors.green;
      case HealthAnalyticsService.WATER:
        return Colors.lightBlue;
      case HealthAnalyticsService.CALORIES:
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getInsightIcon(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return Icons.info_outline;
      case InsightPriority.medium:
        return Icons.warning_amber;
      case InsightPriority.high:
        return Icons.error_outline;
    }
  }
}
