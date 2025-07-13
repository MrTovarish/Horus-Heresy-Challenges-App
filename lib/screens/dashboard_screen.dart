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
    final topUsedGambits = getTopEntries(gambitUsage);
    final topEffectiveGambits = getTopEntries(winningGambits);
    final topVictoriousChars = getTopEntries(winningCharacters);
    final topRivals = getTopEntries(losingEnemies);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 12, 20),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
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
            const SizedBox(height: 16),
            Text('Challenge Stats',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: wins.toDouble(),
                            title: totalDuels == 0 ? '0%' : '${(wins / totalDuels * 100).toStringAsFixed(1)}%',
                            color: const Color.fromARGB(255, 63, 160, 67),
                            radius: 50,
                            titleStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: draws.toDouble(),
                            title: totalDuels == 0 ? '0%' : '${(draws / totalDuels * 100).toStringAsFixed(1)}%',
                            color: const Color.fromARGB(255, 49, 168, 223),
                            radius: 50,
                            titleStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: deaths.toDouble(),
                            title: totalDuels == 0 ? '0%' : '${(deaths / totalDuels * 100).toStringAsFixed(1)}%',
                            color: const Color.fromARGB(255, 136, 20, 20),
                            radius: 50,
                            titleStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Focus Roll Results', '$focusWins — $focusLosses', 'Wins — Losses'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('$wins Victory / $draws Draw / $deaths Death',
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 20),
            Column(
              children: [
                const SizedBox(height: 16),
                _buildTopListCard('Most Used Gambits', topUsedGambits),
                _buildTopListCard('Most Effective Gambits', topEffectiveGambits),
                _buildTopListCard('Most Victorious', topVictoriousChars),
                _buildTopListCard('Top Rivals', topRivals),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey[700]),

            // Donation section temporarily disabled for App Store compliance
            
            Column(
              children: [
                Text(
                  '❤️ Help keep Heresy Challenges free for all',
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
                  child: Text('Donate via Paypal'),
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

  List<MapEntry<String, int>> getTopEntries(Map<String, int> map, [int count = 3]) {
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(count).toList();
  }

  Widget _buildStatCard(String title, String stat, [String? subtitle]) {
    final isCenterAligned = title == 'Focus Roll Results';
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color.fromARGB(255, 20, 20, 30),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: isCenterAligned ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(),
                  style: TextStyle(fontSize: 13, color: Colors.cyanAccent[100], letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Text(stat,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopListCard(String title, List<MapEntry<String, int>> topList) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color.fromARGB(255, 20, 20, 30),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(),
                  style: TextStyle(fontSize: 13, color: Colors.cyanAccent[100], letterSpacing: 0.8)),
              const SizedBox(height: 8),
              if (topList.isEmpty)
                Text('N/A', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              for (int i = 0; i < topList.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${i + 1}: ${topList[i].key} — [${topList[i].value}]',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}






