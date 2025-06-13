import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    final lastIndex = event.turns.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Title: ${event.title}', style: _headerStyle()),
            Text('Date: ${event.date.toLocal().toString().split(' ')[0]}', style: _infoStyle()),
            Text('Your Character: ${event.yourCharacter}', style: _infoStyle()),
            Text('Enemy Character: ${event.enemyCharacter}', style: _infoStyle()),
            SizedBox(height: 20),
            Text('Turns:', style: _headerStyle()),
            ...event.turns.asMap().entries.map((entry) {
              final index = entry.key;
              final turn = entry.value;
              final isFinal = index == lastIndex;

              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFinal ? 'Turn ${index + 1} - Final Turn' : 'Turn ${index + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      SizedBox(height: 4),
                      Text('Your Wounds: ${turn.playerWounds}', style: _infoStyle()),
                      Text('Enemy Wounds: ${turn.opponentWounds}', style: _infoStyle()),
                      Text('Your Gambit: ${turn.playerGambit}', style: _infoStyle()),
                      Text('Enemy Gambit: ${turn.opponentGambit}', style: _infoStyle()),
                      Text('Focus Roll: ${turn.focusRollWin ? 'Won' : 'Lost'}', style: _infoStyle()),
                      if (isFinal)
                        Text('Result: ${event.matchWin ? 'Victory' : 'Death'}', style: _infoStyle()),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal);
  TextStyle _infoStyle() => TextStyle(fontSize: 16, color: Colors.white);
}
