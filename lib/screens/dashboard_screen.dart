import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import '../models/event_model.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Event>('events');
    final events = box.values.toList();

    int totalWins = 0;
    int totalLosses = 0;
    int focusWins = 0;
    int focusLosses = 0;

    final gambitUsage = <String, int>{};
    final winningGambits = <String, int>{};
    final winningCharacters = <String, int>{};

    for (var event in events) {
      for (var turn in event.turns) {
        // Total wins/losses
        if (event.matchWin) {
          totalWins++;
          winningGambits[turn.playerGambit] = (winningGambits[turn.playerGambit] ?? 0) + 1;
          winningCharacters[event.yourCharacter] =
              (winningCharacters[event.yourCharacter] ?? 0) + 1;
        } else {
          totalLosses++;
        }

        // Focus roll stats
        if (event.focusRollWin) {
          focusWins++;
        } else {
          focusLosses++;
        }

        // Total gambit usage
        gambitUsage[turn.playerGambit] = (gambitUsage[turn.playerGambit] ?? 0) + 1;
      }
    }

    String mostUsedGambit = gambitUsage.isEmpty
        ? 'N/A'
        : gambitUsage.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    String mostEffectiveGambit = winningGambits.isEmpty
        ? 'N/A'
        : winningGambits.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    String mostVictoriousCharacter = winningCharacters.isEmpty
        ? 'N/A'
        : winningCharacters.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final totalTurns = totalWins + totalLosses;

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
                    title: totalTurns == 0
                        ? '0%'
                        : '${(totalWins / totalTurns * 100).toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalLosses.toDouble(),
                    title: totalTurns == 0
                        ? '0%'
                        : '${(totalLosses / totalTurns * 100).toStringAsFixed(1)}%',
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
          _buildStatCard('Most Effective Gambit', mostEffectiveGambit),
          _buildStatCard('Most Victorious Character', mostVictoriousCharacter),
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

