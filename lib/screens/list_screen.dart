import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/event_model.dart';
import '../models/duel_model.dart';
import '../models/turn_model.dart';
import 'event_detail_screen.dart';

class EntryListScreen extends StatefulWidget {
  @override
  _EntryListScreenState createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  bool showFilters = false;
  String? selectedCharacter;
  MatchResult? selectedResult;
  DateTime? startDate;
  DateTime? endDate;
  String titleQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(235, 3, 12, 20),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Event>('events').listenable(),
        builder: (context, Box<Event> box, _) {
          final entries = <_DuelListEntry>[];

          final Set<String> characters = {};

          for (int eventIndex = 0; eventIndex < box.length; eventIndex++) {
            final event = box.getAt(eventIndex);
            if (event == null || event.duels.isEmpty) continue;

            for (int duelIndex = 0; duelIndex < event.duels.length; duelIndex++) {
              final duel = event.duels[duelIndex];
              characters.add(duel.yourCharacter);
              entries.add(_DuelListEntry(
                eventIndex: eventIndex,
                duelIndex: duelIndex,
                event: event,
                duel: duel,
              ));
            }
          }

          final filteredEntries = entries.where((entry) {
            final duel = entry.duel;
            final matchesCharacter = selectedCharacter == null || duel.yourCharacter == selectedCharacter;
            final matchesResult = selectedResult == null || duel.result == selectedResult;
            final matchesDate = (startDate == null || entry.event.date.isAfter(startDate!)) &&
                                (endDate == null || entry.event.date.isBefore(endDate!));
            final matchesTitle = duel.title.toLowerCase().contains(titleQuery.toLowerCase());
            return matchesCharacter && matchesResult && matchesDate && matchesTitle;
          }).toList();

          return Column(
            children: [
              _buildFilterSection(characters.toList()),
              Expanded(
                child: filteredEntries.isEmpty
                    ? Center(child: Text('No events found.', style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          final duel = entry.duel;

                          String resultText;
                          Color resultColor;

                          switch (duel.result) {
                            case MatchResult.victory:
                              resultText = 'Victory';
                              resultColor = Colors.green;
                              break;
                            case MatchResult.draw:
                              resultText = 'Draw';
                              resultColor = Colors.lightBlue;
                              break;
                            case MatchResult.death:
                              resultText = 'Death';
                              resultColor = Colors.red[900]!;
                              break;
                          }

                          final backgroundColor = index % 2 == 0
                              ? const Color.fromARGB(255, 20, 30, 40)
                              : const Color.fromARGB(255, 10, 20, 30);

                          return Container(
                            color: backgroundColor,
                            child: Dismissible(
                              key: Key('${entry.event.key}_${entry.duelIndex}'),
                              background: _buildDismissBg(Icons.delete, Alignment.centerLeft),
                              secondaryBackground: _buildDismissBg(Icons.delete, Alignment.centerRight),
                              confirmDismiss: (_) => _confirmDelete(context),
                              onDismissed: (_) {
                                Hive.box<Event>('events').deleteAt(entry.eventIndex);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted')));
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            duel.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${entry.event.date.toLocal().toString().split(' ')[0]}',
                                            style: TextStyle(color: Colors.grey[300], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          duel.yourCharacter,
                                          style: TextStyle(color: const Color.fromARGB(255, 183, 251, 253), fontSize: 16),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          resultText,
                                          style: TextStyle(color: resultColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                        event: entry.event,
                                        duelIndex: entry.duelIndex,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _exportData(context),
                      icon: Icon(Icons.upload_file),
                      label: Text("Export"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _importData(context),
                      icon: Icon(Icons.download),
                      label: Text("Import"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(List<String> characters) {
    return ExpansionTile(
      collapsedBackgroundColor: const Color.fromARGB(255, 15, 25, 35),
      backgroundColor: const Color.fromARGB(255, 20, 30, 40),
      title: Text('Filter', style: TextStyle(color: Colors.white)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              DropdownButton<String>(
                value: selectedCharacter,
                hint: Text('Character', style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.grey[900],
                items: characters.map((char) {
                  return DropdownMenuItem(value: char, child: Text(char, style: TextStyle(color: Colors.white)));
                }).toList()
                  ..insert(0, DropdownMenuItem(value: null, child: Text("All", style: TextStyle(color: Colors.white)))),
                onChanged: (value) => setState(() => selectedCharacter = value),
              ),
              DropdownButton<MatchResult>(
                value: selectedResult,
                hint: Text('Result', style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.grey[900],
                items: MatchResult.values.map((result) {
                  return DropdownMenuItem(
                    value: result,
                    child: Text(result.name, style: TextStyle(color: Colors.white)),
                  );
                }).toList()
                  ..insert(0, DropdownMenuItem(value: null, child: Text("All", style: TextStyle(color: Colors.white)))),
                onChanged: (value) => setState(() => selectedResult = value),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
                child: Text(startDate == null ? 'Start Date' : startDate!.toLocal().toString().split(' ')[0]),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
                child: Text(endDate == null ? 'End Date' : endDate!.toLocal().toString().split(' ')[0]),
              ),
              SizedBox(
                width: 150,
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: 'Search Title', hintStyle: TextStyle(color: Colors.grey)),
                  onChanged: (value) => setState(() => titleQuery = value),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDismissBg(IconData icon, Alignment alignment) {
    return Container(
      color: Colors.red[700],
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final box = Hive.box<Event>('events');
    final events = box.values.map((e) => {
          'date': e.date.toIso8601String(),
          'duels': e.duels.map((d) => {
                'title': d.title,
                'yourCharacter': d.yourCharacter,
                'enemyCharacter': d.enemyCharacter,
                'result': d.result.name,
                'turns': d.turns.map((t) => {
                      'playerWounds': t.playerWounds,
                      'opponentWounds': t.opponentWounds,
                      'playerGambit': t.playerGambit,
                      'opponentGambit': t.opponentGambit,
                      'focusRollWin': t.focusRollWin,
                    }).toList(),
              }).toList(),
        }).toList();

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/heresy_challenges_export.json';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(events));
    await Share.shareXFiles([XFile(filePath)], text: 'Here is your exported Heresy Challenges data.');
  }

  Future<void> _importData(BuildContext context) async {
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(label: 'JSON', extensions: ['json']),
    ]);

    if (file == null) return;

    final content = await file.readAsString();
    final decoded = jsonDecode(content);
    final box = Hive.box<Event>('events');

    for (var eventMap in decoded) {
      final duels = (eventMap['duels'] as List).map((duelMap) {
        final turns = (duelMap['turns'] as List).map((turnMap) {
          return Turn(
            playerWounds: turnMap['playerWounds'],
            opponentWounds: turnMap['opponentWounds'],
            playerGambit: turnMap['playerGambit'],
            opponentGambit: turnMap['opponentGambit'],
            focusRollWin: turnMap['focusRollWin'],
          );
        }).toList();

        return Duel(
          title: duelMap['title'],
          yourCharacter: duelMap['yourCharacter'],
          enemyCharacter: duelMap['enemyCharacter'],
          result: MatchResult.values.firstWhere((e) => e.name == duelMap['result']),
          turns: turns,
        );
      }).toList();

      box.add(Event(date: DateTime.parse(eventMap['date']), duels: duels));
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import complete')));
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Event'),
            content: Text('Are you sure you want to delete this event?'),
            backgroundColor: Colors.grey[900],
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            contentTextStyle: TextStyle(color: Colors.white70),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: Colors.teal))),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }
}

class _DuelListEntry {
  final int eventIndex;
  final int duelIndex;
  final Event event;
  final Duel duel;

  _DuelListEntry({
    required this.eventIndex,
    required this.duelIndex,
    required this.event,
    required this.duel,
  });
}








