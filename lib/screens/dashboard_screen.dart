import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import '../models/event_model.dart';
import '../models/duel_model.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Event>('events');
    final events = box.values.toList();

    int totalWins = 0;
    int totalDraws = 0;
    int totalDeaths = 0;
    int focusWins = 0;
    int focusLosses = 0;

    final gambitUsage = <String, int>{};
    final winningGambits = <String, int>{};
    final winningCharacters = <String, int>{};

    for (var event in events) {
      for (var duel in event.duels) {
        for (var turn in duel.turns) {
          if (turn.focusRollWin) {
            focusWins++;
          } else {
            focusLosses++;
          }

          gambitUsage[turn.playerGambit] =
              (gambitUsage[turn.playerGambit] ?? 0) + 1;
        }

        switch (duel.result) {
          case MatchResult.victory:
            totalWins++;
            final finalTurn = duel.turns.last;
            winningGambits[finalTurn.playerGambit] =
                (winningGambits[finalTurn.playerGambit] ?? 0) + 1;
            winningCharacters[duel.yourCharacter] =
                (winningCharacters[duel.yourCharacter] ?? 0) + 1;
            break;
          case MatchResult.draw:
            totalDraws++;
            break;
          case MatchResult.death:
            totalDeaths++;
            break;
        }
      }
    }

    final totalDuels = totalWins + totalDraws + totalDeaths;

    String mostUsedGambit = gambitUsage.isEmpty
        ? 'N/A'
        : gambitUsage.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    String mostEffectiveGambit = winningGambits.isEmpty
        ? 'N/A'
        : winningGambits.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    String mostVictoriousCharacter = winningCharacters.isEmpty
        ? 'N/A'
        : winningCharacters.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Duel Outcomes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
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
                    title: totalDuels == 0 ? '0%' : '${(totalWins / totalDuels * 100).toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: totalDraws.toDouble(),
                    title: totalDuels == 0 ? '0%' : '${(totalDraws / totalDuels * 100).toStringAsFixed(1)}%',
                    color: Colors.lightBlueAccent,
                    radius: 60,
                    titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: totalDeaths.toDouble(),
                    title: totalDuels == 0 ? '0%' : '${(totalDeaths / totalDuels * 100).toStringAsFixed(1)}%',
                    color: Colors.red[900],
                    radius: 60,
                    titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              '$totalWins Wins / $totalDraws Draws / $totalDeaths Deaths',
              style: TextStyle(fontSize: 16, color: Colors.white),
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



