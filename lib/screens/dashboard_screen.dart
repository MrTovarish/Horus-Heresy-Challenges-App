import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import '../models/entry_model.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Entry>('entries');
    final entries = box.values.toList();

    // --- Calculate Summary Stats ---
    int totalWins = entries.where((e) => e.matchWin).length;
    int totalLosses = entries.length - totalWins;

    int focusWins = entries.where((e) => e.focusRollWin).length;
    int focusLosses = entries.length - focusWins;

    // Most Used Gambit
    Map<String, int> gambitCounts = {};
    for (var e in entries) {
      gambitCounts[e.gambit] = (gambitCounts[e.gambit] ?? 0) + 1;
    }
    String mostUsedGambit = gambitCounts.entries.isEmpty
        ? 'N/A'
        : gambitCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Win/Loss Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: totalWins.toDouble(),
                    title: entries.isEmpty
                        ? '0%'
                        : '${(totalWins / entries.length * 100).toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalLosses.toDouble(),
                    title: entries.isEmpty
                        ? '0%'
                        : '${(totalLosses / entries.length * 100).toStringAsFixed(1)}%',
                    color: Colors.red[900],
                    radius: 60,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              '$totalWins Wins / $totalLosses Losses',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildStatCard('Focus Rolls', '$focusWins / $focusLosses', 'Wins / Losses'),
          _buildStatCard('Most Used Gambit', mostUsedGambit),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String stat, [String? subtitle]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.teal)),
            SizedBox(height: 8),
            Text(stat, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle, style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
