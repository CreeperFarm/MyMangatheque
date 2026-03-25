import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:pocketbase/pocketbase.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final PocketBase connector = PocketBaseConnector().connector();
  bool _loading = true;

  int usersToday = 0;
  List<FlSpot> userGrowthData = [];

  // Keep references so we can cancel on dispose
  dynamic _usersSubscription;
  dynamic _mangaSubscription;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initStats();
  }

  Future<void> _initStats() async {
    await _fetchStatistics(); // initial load
    _setupRealtimeOrFallback();
  }

  Future<void> _fetchStatistics() async {
    setState(() => _loading = true);
    try {
      final now = DateTime.now();

      // Users registered today
      final todayRes = await PocketBaseConnector().getNewRegisterLast24h();

      // Last 7 days chart (0..6)
      final List<FlSpot> chartSpots = <FlSpot>[];
      final lastMonthRes = await PocketBaseConnector()
          .getNewRegisterLastMonth();
      final lastMonthData = json.decode(lastMonthRes)["data"];
      final Map<String, int> dateCountMap = {};
      for (var item in lastMonthData) {
        final dateStr = item["date"].substring(0, 10); // format yyyy-MM-dd
        dateCountMap[dateStr] = item["count"];
      }
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr =
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        final count = dateCountMap[dateStr] ?? 0;
        chartSpots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
      }

      setState(() {
        usersToday = todayRes;
        userGrowthData = chartSpots;
      });
    } catch (e, st) {
      // keep UI stable and show an error in debug console
      // (optionally show a SnackBar or UI error)
      debugPrint('Error fetching statistics: $e\n$st');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Try to use PocketBase realtime subscribe API. If it fails (NoSuchMethod
  /// or runtime incompatibility), fall back to periodic polling.
  void _setupRealtimeOrFallback() {
    // clear any previous
    _cancelRealtime();
    try {
      // Many PocketBase SDKs expose `.collection('name').subscribe(...)`.
      // We keep the handler very simple: on any user or manga event, refresh.
      _usersSubscription = connector.collection('users').subscribe('*', (
        event,
      ) {
        // event can be create/update/delete; just refresh
        _fetchStatistics();
      });

      // NOTE: some SDK implementations return a subscription object with `unsubscribe()`.
      // We'll keep the references and call unsubscribe() on dispose.
      debugPrint('Realtime subscriptions established.');
    } catch (e) {
      debugPrint('Realtime subscription failed: $e — falling back to polling.');
      // fallback: poll every 15 seconds
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _fetchStatistics();
      });
    }
  }

  void _cancelRealtime() {
    try {
      if (_usersSubscription != null) {
        // try unsubscribe if available
        try {
          _usersSubscription.unsubscribe();
        } catch (_) {
          // ignore if not available
        }
        _usersSubscription = null;
      }
      if (_mangaSubscription != null) {
        try {
          _mangaSubscription.unsubscribe();
        } catch (_) {}
        _mangaSubscription = null;
      }
    } catch (_) {}
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  @override
  void dispose() {
    _cancelRealtime();
    super.dispose();
  }

  Widget _buildUserGrowthChart() {
    if (userGrowthData.isEmpty) {
      return const SizedBox(height: 160, child: Center(child: Text('No data')));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final intIdx = value.toInt().clamp(0, 6);
                  final date = DateTime.now().subtract(
                    Duration(days: 6 - intIdx),
                  );
                  return SideTitleWidget(
                    meta: meta,
                    child: Transform(
                      transform: Matrix4.translationValues(0, 15, 0.0),
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation(45 / 360),
                        child: Text("${date.day}/${date.month}"),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 6,
          lineBarsData: [
            LineChartBarData(
              spots: userGrowthData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final realtimeStatus = _fallbackTimer != null ? ' (polling every 15s)' : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStatistics,
            tooltip: 'Refresh now',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users registered today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$usersToday',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _fetchStatistics,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reload'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'New users (last 7 days)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUserGrowthChart(),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'Updates in real-time$realtimeStatus',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
