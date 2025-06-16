import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/duel_model.dart';
import 'event_detail_screen.dart';

class EntryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Event>('events').listenable(),
      builder: (context, Box<Event> box, _) {
        if (box.values.isEmpty) {
          return Center(
              child: Text('No events yet.', style: TextStyle(color: Colors.white)));
        }

        final allEntries = <_DuelListEntry>[];

        // Flatten each duel from each event into separate list items
        for (int eventIndex = 0; eventIndex < box.length; eventIndex++) {
          final event = box.getAt(eventIndex);
          if (event == null || event.duels.isEmpty) continue;

          for (int duelIndex = 0; duelIndex < event.duels.length; duelIndex++) {
            allEntries.add(_DuelListEntry(
              eventIndex: eventIndex,
              duelIndex: duelIndex,
              event: event,
              duel: event.duels[duelIndex],
            ));
          }
        }

        return ListView.builder(
          itemCount: allEntries.length,
          itemBuilder: (context, index) {
            final entry = allEntries[index];

            String resultText;
            Color resultColor;

            switch (entry.duel.result) {
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

            return Dismissible(
              key: Key('${entry.event.key}_${entry.duelIndex}'),
              background: Container(
                color: Colors.red[700],
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red[700],
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) => _confirmDelete(context),
              onDismissed: (_) {
                final box = Hive.box<Event>('events');
                box.deleteAt(entry.eventIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event deleted')),
                );
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.duel.title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      resultText,
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${entry.event.date.toLocal().toString().split(' ')[0]} — ${entry.duel.yourCharacter}',
                  style: TextStyle(color: Colors.grey[300]),
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
            );
          },
        );
      },
    );
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
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: Colors.teal)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
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




