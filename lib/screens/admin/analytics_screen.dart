import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/utils/date_utils.dart' as date_utils;

/// Analytics screen for admins
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTimeRange? _dateRange;
  
  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    _dateRange = DateTimeRange(start: startDate, end: endDate);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }
  
  void _loadAnalytics() {
    if (_dateRange == null) return;
    
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    
    final startDate = date_utils.AppDateUtils.startOfDay(_dateRange!.start);
    final endDate = date_utils.AppDateUtils.endOfDay(_dateRange!.end);
    
    analyticsProvider.loadUtilizationStats(startDate, endDate);
    analyticsProvider.loadPeakHours(startDate, endDate);
    analyticsProvider.loadOverallStats(startDate, endDate);
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _loadAnalytics();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, _) {
          if (analyticsProvider.isLoading) {
            return const LoadingIndicator();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range display
                if (_dateRange != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date Range'),
                      subtitle: Text(
                        '${date_utils.AppDateUtils.formatDate(_dateRange!.start)} - ${date_utils.AppDateUtils.formatDate(_dateRange!.end)}',
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDateRange(context),
                        child: const Text('Change'),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Overall statistics
                if (analyticsProvider.overallStats != null) ...[
                  Text(
                    'Overall Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOverallStats(analyticsProvider.overallStats!),
                  const SizedBox(height: 24),
                ],
                // Utilization statistics
                if (analyticsProvider.utilizationStats.isNotEmpty) ...[
                  Text(
                    'Resource Utilization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUtilizationChart(analyticsProvider.utilizationStats),
                  const SizedBox(height: 24),
                ],
                // Peak hours
                if (analyticsProvider.peakHours != null) ...[
                  Text(
                    'Peak Hours',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPeakHoursChart(analyticsProvider.peakHours!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOverallStats(overallStats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _StatCard(
          title: 'Total Bookings',
          value: overallStats.totalBookings.toString(),
          icon: Icons.event,
        ),
        _StatCard(
          title: 'Total Users',
          value: overallStats.totalUsers.toString(),
          icon: Icons.people,
        ),
        _StatCard(
          title: 'Total Resources',
          value: overallStats.totalResources.toString(),
          icon: Icons.inventory_2,
        ),
        _StatCard(
          title: 'Avg Duration',
          value: '${overallStats.averageBookingDuration.toStringAsFixed(1)}h',
          icon: Icons.timer,
        ),
      ],
    );
  }
  
  Widget _buildUtilizationChart(List utilizationStats) {
    if (utilizationStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No utilization data available')),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: utilizationStats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stat.utilizationRate * 100,
                      color: Colors.blue,
                      width: 16,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < utilizationStats.length) {
                        return Text(
                          utilizationStats[value.toInt()].resourceName,
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPeakHoursChart(peakHours) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peak Day: ${peakHours.peakDay}'),
            const SizedBox(height: 8),
            Text('Peak Hours: ${peakHours.peakHours.join(", ")}'),
            const SizedBox(height: 8),
            Text('Average Bookings/Hour: ${peakHours.averageBookingsPerHour.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

