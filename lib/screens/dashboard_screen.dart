import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../models/duel_model.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedCharacter;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Event>('events');
    final events = box.values.toList();

    final characters = <String>{};
    for (var event in events) {
      for (var duel in event.duels) {
        characters.add(duel.yourCharacter);
      }
    }

    final filteredEvents = events.map((event) {
      final filteredDuels = _selectedCharacter == null
          ? event.duels
          : event.duels.where((duel) => duel.yourCharacter == _selectedCharacter).toList();
      return Event(date: event.date, duels: filteredDuels);
    }).toList();

    int wins = 0;
    int draws = 0;
    int deaths = 0;
    int focusWins = 0;
    int focusLosses = 0;

    final gambitUsage = <String, int>{};
    final winningGambits = <String, int>{};
    final winningCharacters = <String, int>{};
    final losingEnemies = <String, int>{};

    for (var event in filteredEvents) {
      for (var duel in event.duels) {
        for (var turn in duel.turns) {
          if (turn.focusRollWin) {
            focusWins++;
          } else {
            focusLosses++;
          }
          gambitUsage[turn.playerGambit] = (gambitUsage[turn.playerGambit] ?? 0) + 1;
        }

        switch (duel.result) {
          case MatchResult.victory:
            wins++;
            finalTurnProcess(duel, winningGambits, winningCharacters);
            break;
          case MatchResult.draw:
            draws++;
            break;
          case MatchResult.death:
            deaths++;
            losingEnemies[duel.enemyCharacter] = (losingEnemies[duel.enemyCharacter] ?? 0) + 1;
            break;
        }
      }
    }

    final totalDuels = wins + draws + deaths;
    final mostUsedGambit = getTopKey(gambitUsage);
    final mostEffectiveGambit = getTopKey(winningGambits);
    final mostVictoriousCharacter = getTopKey(winningCharacters);
    final rival = getTopKey(losingEnemies);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 12, 20),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (characters.isNotEmpty)
              DropdownButton<String>(
                value: _selectedCharacter,
                hint: Text('Select Character', style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.grey[900],
                style: TextStyle(color: Colors.white),
                items: [
                  DropdownMenuItem(value: null, child: Text('All Characters')),
                  ...characters.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (value) => setState(() => _selectedCharacter = value),
              ),
            SizedBox(height: 12),
            Text('Challenge Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: wins.toDouble(),
                      title: totalDuels == 0 ? '0%' : '${(wins / totalDuels * 100).toStringAsFixed(1)}%',
                      color: Colors.green,
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: draws.toDouble(),
                      title: totalDuels == 0 ? '0%' : '${(draws / totalDuels * 100).toStringAsFixed(1)}%',
                      color: Colors.lightBlueAccent,
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: deaths.toDouble(),
                      title: totalDuels == 0 ? '0%' : '${(deaths / totalDuels * 100).toStringAsFixed(1)}%',
                      color: Colors.red[900],
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('$wins Victory / $draws Draw / $deaths Death',
                style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard('Focus Roll Results', '$focusWins / $focusLosses', 'Wins / Losses'),
                _buildStatCard('Most Used Gambit', mostUsedGambit),
                _buildStatCard('Most Effective Gambit', mostEffectiveGambit),
                _buildStatCard('Most Victorious', mostVictoriousCharacter),
                _buildStatCard('Rival', rival),
              ],
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey),
            Column(
              children: [
                Text(
                  '❤️ Please consider supporting Heresy Challenges',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse('https://linktr.ee/TovarishWorks');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      await launchUrl(url, mode: LaunchMode.inAppWebView);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 116, 27, 27),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Donate via Linktree'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void finalTurnProcess(Duel duel, Map<String, int> winningGambits, Map<String, int> winningCharacters) {
    final finalTurn = duel.turns.last;
    winningGambits[finalTurn.playerGambit] = (winningGambits[finalTurn.playerGambit] ?? 0) + 1;
    winningCharacters[duel.yourCharacter] = (winningCharacters[duel.yourCharacter] ?? 0) + 1;
  }

  String getTopKey(Map<String, int> map) {
    if (map.isEmpty) return 'N/A';
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Widget _buildStatCard(String title, String stat, [String? subtitle]) {
    return SizedBox(
      width: 160,
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 122, 141, 228))),
              SizedBox(height: 4),
              Text(stat, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}






