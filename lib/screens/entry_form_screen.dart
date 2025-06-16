import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/event_model.dart';
import '../models/turn_model.dart';
import '../models/duel_model.dart';

class EntryFormScreen extends StatefulWidget {
  final VoidCallback onEntrySaved;

  EntryFormScreen({required this.onEntrySaved});

  @override
  _EntryFormScreenState createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  int _turnNumber = 1;
  final List<_DuelFormData> _duels = [ _DuelFormData() ];

  void _addDuel() {
    setState(() => _duels.add(_DuelFormData()));
  }

  void _addTurnToAllDuels() {
    setState(() {
      for (var duel in _duels) {
        duel.turns.add(_TurnInputs());
      }
      _turnNumber++;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final duels = _duels.map((duel) {
        final turns = duel.turns.map((turn) {
          return Turn(
            playerWounds: int.parse(turn.playerWoundsController.text),
            opponentWounds: int.parse(turn.opponentWoundsController.text),
            playerGambit: turn.playerGambit,
            opponentGambit: turn.opponentGambit,
            focusRollWin: turn.focusRollWin,
          );
        }).toList();

        return Duel(
          title: duel.titleController.text,
          yourCharacter: duel.yourCharacterController.text,
          enemyCharacter: duel.enemyCharacterController.text,
          turns: turns,
          result: duel.result,
        );
      }).toList();

      final event = Event(
        date: _selectedDate,
        duels: duels,
      );

      final box = Hive.box<Event>('events');
      box.add(event);
      widget.onEntrySaved();

      // Reset state
      _selectedDate = DateTime.now();
      _turnNumber = 1;
      _duels.clear();
      _duels.add(_DuelFormData());

      setState(() {});
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
              children: [
                ListTile(
                  title: Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: _pickDate,
                ),
                SizedBox(height: 20),
                for (int i = 0; i < _duels.length; i++)
                  _buildDuelForm(_duels[i], i, gambitOptions),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: _addDuel, child: Text('Add Duel')),
                    ElevatedButton(onPressed: _addTurnToAllDuels, child: Text('Add Turn')),
                    ElevatedButton(onPressed: _saveEvent, child: Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuelForm(_DuelFormData duel, int duelIndex, List<String> gambitOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.teal),
        Text('=== Duel ${duelIndex + 1} ===', style: TextStyle(color: Colors.teal, fontSize: 18)),
        TextFormField(
          controller: duel.titleController,
          decoration: InputDecoration(labelText: 'Title'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter a title' : null,
        ),
        TextFormField(
          controller: duel.yourCharacterController,
          decoration: InputDecoration(labelText: 'Your Character'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter your character' : null,
        ),
        TextFormField(
          controller: duel.enemyCharacterController,
          decoration: InputDecoration(labelText: 'Enemy Character'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter enemy character' : null,
        ),
        SizedBox(height: 12),
        for (int turnIndex = 0; turnIndex < duel.turns.length; turnIndex++)
          _buildTurnBlock(
            duel.turns[turnIndex],
            turnIndex,
            isFinalTurn: turnIndex == duel.turns.length - 1,
            duel: duel,
            gambitOptions: gambitOptions,
          ),
      ],
    );
  }

  Widget _buildTurnBlock(
    _TurnInputs turn,
    int turnIndex, {
    required bool isFinalTurn,
    required _DuelFormData duel,
    required List<String> gambitOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '--- Turn ${turnIndex + 1}${isFinalTurn ? " (Final Turn)" : ""} ---',
          style: TextStyle(color: Colors.teal, fontSize: 16),
        ),
        TextFormField(
          controller: turn.playerWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Your # of Starting Wounds'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter your wounds' : null,
        ),
        TextFormField(
          controller: turn.opponentWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Enemy's # of Starting Wounds"),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter enemy wounds' : null,
        ),
        DropdownButtonFormField<String>(
          value: turn.playerGambit,
          items: gambitOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (value) => setState(() => turn.playerGambit = value!),
          decoration: InputDecoration(labelText: 'Your Gambit'),
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
        ),
        DropdownButtonFormField<String>(
          value: turn.opponentGambit,
          items: gambitOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (value) => setState(() => turn.opponentGambit = value!),
          decoration: InputDecoration(labelText: 'Enemy Gambit'),
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
        ),
        Text('Focus Roll', style: TextStyle(color: Colors.white, fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColoredButton(
              label: 'Won',
              selected: turn.focusRollWin == true,
              selectedColor: Colors.green,
              onTap: () => setState(() => turn.focusRollWin = true),
            ),
            _buildColoredButton(
              label: 'Lost',
              selected: turn.focusRollWin == false,
              selectedColor: Colors.red[900]!,
              onTap: () => setState(() => turn.focusRollWin = false),
            ),
          ],
        ),
        if (isFinalTurn) ...[
          Text('Result', style: TextStyle(color: Colors.white, fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColoredButton(
                label: 'Victory',
                selected: duel.result == MatchResult.victory,
                selectedColor: Colors.green,
                onTap: () => setState(() => duel.result = MatchResult.victory),
              ),
              _buildColoredButton(
                label: 'Draw',
                selected: duel.result == MatchResult.draw,
                selectedColor: Colors.lightBlueAccent,
                onTap: () => setState(() => duel.result = MatchResult.draw),
              ),
              _buildColoredButton(
                label: 'Death',
                selected: duel.result == MatchResult.death,
                selectedColor: Colors.red[900]!,
                onTap: () => setState(() => duel.result = MatchResult.death),
              ),
            ],
          ),
        ],
        SizedBox(height: 20),
      ],
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

class _TurnInputs {
  final playerWoundsController = TextEditingController();
  final opponentWoundsController = TextEditingController();
  String playerGambit = 'Seize the Initiative';
  String opponentGambit = 'Seize the Initiative';
  bool focusRollWin = true;
}

class _DuelFormData {
  final titleController = TextEditingController();
  final yourCharacterController = TextEditingController();
  final enemyCharacterController = TextEditingController();
  final List<_TurnInputs> turns = [ _TurnInputs() ];
  MatchResult result = MatchResult.victory;
}






