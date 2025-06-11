import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/entry_model.dart';

class EntryFormScreen extends StatefulWidget {
  final VoidCallback onEntrySaved;

  EntryFormScreen({required this.onEntrySaved});

  @override
  _EntryFormScreenState createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameController = TextEditingController();
  final _characterController = TextEditingController();
  final _opponentController = TextEditingController();
  final _playerWoundsController = TextEditingController();
  final _opponentWoundsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedGambit = 'Seize the Initiative';
  bool _focusRollWin = true;
  bool _matchWin = true;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEntry = Entry(
        game: _gameController.text,
        date: _selectedDate,
        character: _characterController.text,
        playerWounds: int.parse(_playerWoundsController.text),
        opponent: _opponentController.text,
        opponentWounds: int.parse(_opponentWoundsController.text),
        gambit: _selectedGambit,
        focusRollWin: _focusRollWin,
        matchWin: _matchWin,
      );

      final box = Hive.box<Entry>('entries');
      box.add(newEntry);

      widget.onEntrySaved();
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('New Entry'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _gameController,
                  decoration: InputDecoration(labelText: 'Game'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter a game name' : null,
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}", style: TextStyle(color: Colors.white)),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _characterController,
                  decoration: InputDecoration(labelText: 'Character'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter a character name' : null,
                ),
                TextFormField(
                  controller: _playerWoundsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '# of Wounds'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter # of wounds' : null,
                ),
                TextFormField(
                  controller: _opponentController,
                  decoration: InputDecoration(labelText: 'vs Who'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter opponent name' : null,
                ),
                TextFormField(
                  controller: _opponentWoundsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '# of Wounds (Opponent)'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter opponent wounds' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGambit,
                  items: [
                    'Seize the Initiative',
                    'Flurry of Blows',
                    'Feint and Riposte',
                    'Finishing Blow'
                  ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setState(() => _selectedGambit = value!),
                  decoration: InputDecoration(labelText: 'Gambit'),
                  dropdownColor: Colors.grey[900],
                  style: TextStyle(color: Colors.white),
                ),
                SwitchListTile(
                  title: Text('Focus Roll Win?', style: TextStyle(color: Colors.white)),
                  value: _focusRollWin,
                  onChanged: (val) => setState(() => _focusRollWin = val),
                ),
                SwitchListTile(
                  title: Text('Match Win?', style: TextStyle(color: Colors.white)),
                  value: _matchWin,
                  onChanged: (val) => setState(() => _matchWin = val),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Save Entry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
