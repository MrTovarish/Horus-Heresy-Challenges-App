import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry_model.dart';

class EntryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Entry>('entries').listenable(),
      builder: (context, Box<Entry> box, _) {
        if (box.values.isEmpty) {
          return Center(child: Text('No entries yet.'));
        }

        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            try {
              final entry = box.getAt(index);

              if (entry == null) {
                return ListTile(
                  title: Text('Invalid entry at index $index'),
                );
              }

              return ListTile(
                title: Text('${entry.gambit}'),
                subtitle: Text(
                  '${entry.date.toLocal().toString().split(' ')[0]} - ${entry.playerWounds}',
                ),
              );
            } catch (e) {
              return ListTile(
                title: Text('Error reading entry at index $index'),
                subtitle: Text(e.toString()),
              );
            }
          },
        );
      },
    );
  }
}