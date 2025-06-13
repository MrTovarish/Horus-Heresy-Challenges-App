import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/turn_model.dart';
import 'event_detail_screen.dart';

class EntryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Event>('events').listenable(),
      builder: (context, Box<Event> box, _) {
        if (box.values.isEmpty) {
          return Center(child: Text('No events yet.', style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final event = box.getAt(index);

            if (event == null || event.turns.isEmpty) {
              return ListTile(
                title: Text('Invalid or empty event at index $index', style: TextStyle(color: Colors.red)),
              );
            }

            
            final resultText = event.matchWin ? 'Victory' : 'Death';
            final resultColor = event.matchWin ? Colors.green : Colors.red[900];

            return Dismissible(
              key: Key(event.key.toString()),
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
                box.deleteAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event deleted')),
                );
              },
              child: ListTile(
                title: Text(
                  event.title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.date.toLocal().toString().split(' ')[0]} — ${event.yourCharacter}',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    Text(
                      resultText,
                      style: TextStyle(color: resultColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
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




