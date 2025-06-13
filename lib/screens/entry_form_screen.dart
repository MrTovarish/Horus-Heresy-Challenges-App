import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/event_model.dart';
import '../models/turn_model.dart';

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
  String _playerGambit = 'Seize the Initiative';
  String _opponentGambit = 'Seize the Initiative';
  bool _focusRollWin = true;
  bool _matchWin = true;

  final List<Turn> _turns = [];

  void _addTurn() {
    if (_formKey.currentState!.validate()) {
      final turn = Turn(
        playerWounds: int.parse(_playerWoundsController.text),
        opponentWounds: int.parse(_opponentWoundsController.text),
        playerGambit: _playerGambit,
        opponentGambit: _opponentGambit,
        focusRollWin: _focusRollWin,
      );

      setState(() {
        _turns.add(turn);
        _playerWoundsController.clear();
        _opponentWoundsController.clear();
        _playerGambit = 'Seize the Initiative';
        _opponentGambit = 'Seize the Initiative';
        _focusRollWin = true;
        _matchWin = true;
      });
    }
  }

  void _saveEvent() {
  if (_formKey.currentState!.validate()) {
    final hasWounds = _playerWoundsController.text.isNotEmpty && _opponentWoundsController.text.isNotEmpty;
    
    if (hasWounds) {
      final firstTurn = Turn(
        playerWounds: int.parse(_playerWoundsController.text),
        opponentWounds: int.parse(_opponentWoundsController.text),
        playerGambit: _playerGambit,
        opponentGambit: _opponentGambit,
        focusRollWin: _focusRollWin,    
      );
      _turns.add(firstTurn);
    }


    final event = Event(
      title: _gameController.text,
      date: _selectedDate,
      yourCharacter: _characterController.text,
      enemyCharacter: _opponentController.text,
      turns: List.from(_turns),
      matchWin: _matchWin,
    );

    final box = Hive.box<Event>('events');
    box.add(event);

    widget.onEntrySaved();

    _gameController.clear();
    _characterController.clear();
    _opponentController.clear();
    _playerWoundsController.clear();
    _opponentWoundsController.clear();
    _selectedDate = DateTime.now();
    _playerGambit = 'Seize the Initiative';
    _opponentGambit = 'Seize the Initiative';
    _focusRollWin = true;
    _matchWin = true;
    _turns.clear();

    setState(() {});
  }
}
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gambitOptions = [
      'Seize the Initiative',
      'Flurry of Blows',
      'Feint and Riposte',
      'Finishing Blow'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('New Record'),
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
                  decoration: InputDecoration(labelText: 'Title'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _characterController,
                  decoration: InputDecoration(labelText: 'Your Character'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your character' : null,
                ),
                TextFormField(
                  controller: _opponentController,
                  decoration: InputDecoration(labelText: 'Enemy Character'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter enemy character' : null,
                ),
                SizedBox(height: 20),
                Text(
                  '--- Turn ${_turns.length + 1} ---',
                  style: TextStyle(color: Colors.teal, fontSize: 16),
                ),
                TextFormField(
                  controller: _playerWoundsController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Your # of Starting Wounds'),
                  style: TextStyle(color: Colors.white),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your wounds' : null,
                ),
                TextFormField(
                  controller: _opponentWoundsController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Enemy's # of Starting Wounds"),
                  style: TextStyle(color: Colors.white),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter enemy wounds' : null,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _playerGambit,
                  items: gambitOptions
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _playerGambit = value!),
                  decoration: InputDecoration(labelText: 'Your Gambit'),
                  dropdownColor: Colors.grey[900],
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButtonFormField<String>(
                  value: _opponentGambit,
                  items: gambitOptions
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _opponentGambit = value!),
                  decoration: InputDecoration(labelText: 'Enemy Gambit'),
                  dropdownColor: Colors.grey[900],
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Text('Focus Roll',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColoredButton(
                      label: 'Won',
                      selected: _focusRollWin == true,
                      selectedColor: Colors.green,
                      onTap: () => setState(() => _focusRollWin = true),
                    ),
                    _buildColoredButton(
                      label: 'Lost',
                      selected: _focusRollWin == false,
                      selectedColor: Colors.red[900]!,
                      onTap: () => setState(() => _focusRollWin = false),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('Victory or Death',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColoredButton(
                      label: 'Victory',
                      selected: _matchWin == true,
                      selectedColor: Colors.green,
                      onTap: () => setState(() => _matchWin = true),
                    ),
                    _buildColoredButton(
                      label: 'Death',
                      selected: _matchWin == false,
                      selectedColor: Colors.red[900]!,
                      onTap: () => setState(() => _matchWin = false),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addTurn,
                      child: Text('New Turn'),
                    ),
                    ElevatedButton(
                      onPressed: _saveEvent,
                      child: Text('Save Event'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColoredButton({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? selectedColor : Colors.grey[700],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}




