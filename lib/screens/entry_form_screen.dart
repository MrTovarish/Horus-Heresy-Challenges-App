import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  final List<_DuelFormData> _duels = [ _DuelFormData() ];

  void _addDuel() {
    setState(() => _duels.add(_DuelFormData()));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final duels = _duels.map((duel) {
        final turns = duel.turns.map((turn) => Turn(
          playerWounds: int.parse(turn.playerWoundsController.text),
          opponentWounds: int.parse(turn.opponentWoundsController.text),
          playerGambit: turn.playerGambit,
          opponentGambit: turn.opponentGambit,
          focusRollWin: turn.focusRollWin,
        )).toList();

        return Duel(
          title: duel.titleController.text,
          yourCharacter: duel.yourCharacterController.text,
          enemyCharacter: duel.enemyCharacterController.text,
          turns: turns,
          result: duel.result,
        );
      }).toList();

      final event = Event(date: _selectedDate, duels: duels);
      Hive.box<Event>('events').add(event);
      widget.onEntrySaved();

      setState(() {
        _selectedDate = DateTime.now();
        _duels.clear();
        _duels.add(_DuelFormData());
      });
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
      backgroundColor: const Color.fromARGB(255, 3, 12, 20),
      appBar: AppBar(title: Text('New Game'), backgroundColor: Colors.grey[900]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(color: Colors.white)),
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

  Widget _buildDuelForm(_DuelFormData duel, int index, List<String> gambitOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Divider(color: const Color.fromRGBO(176, 237, 248, 1)),
        Center(child: Text('Challenge #${index + 1}', style: TextStyle(color: const Color.fromARGB(255, 173, 247, 247), fontSize: 20))),
        TextFormField(
          controller: duel.titleController,
          decoration: InputDecoration(labelText: 'Challenge Title'),
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
            duel,
            gambitOptions,
          ),
        Center(
          child: ElevatedButton(
            onPressed: () => setState(() => duel.turns.add(_TurnInputs())),
            child: Text('Add Turn'),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTurnBlock(
    _TurnInputs turn,
    int turnIndex,
    _DuelFormData duel,
    List<String> gambitOptions,
  ) {
    final isFinal = turnIndex == duel.turns.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Turn ${turnIndex + 1}${isFinal ? " (Final Turn)" : ""}',
            style: TextStyle(color: const Color.fromARGB(255, 144, 240, 230), fontSize: 18),
          ),
        ),
        TextFormField(
          controller: turn.playerWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Your Current Wounds'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter your wounds' : null,
        ),
        TextFormField(
          controller: turn.opponentWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Enemy Current Wounds"),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Enter enemy wounds' : null,
        ),
        DropdownSearch<String>(
          selectedItem: turn.playerGambit,
          items: gambitOptions,
          popupProps: PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(labelText: 'Your Gambit'),
          ),
          onChanged: (value) => setState(() => turn.playerGambit = value!),
        ),
        DropdownSearch<String>(
          selectedItem: turn.opponentGambit,
          items: gambitOptions,
          popupProps: PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(labelText: 'Enemy Gambit'),
          ),
          onChanged: (value) => setState(() => turn.opponentGambit = value!),
        ),
        Center(child: Text('Focus Roll', style: TextStyle(color: const Color.fromARGB(255, 171, 253, 253)))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColoredButton(
              label: 'Won',
              selected: turn.focusRollWin,
              selectedColor: Colors.green,
              onTap: () => setState(() => turn.focusRollWin = true),
            ),
            SizedBox(width: 10),
            _buildColoredButton(
              label: 'Lost',
              selected: !turn.focusRollWin,
              selectedColor: Colors.red[900]!,
              onTap: () => setState(() => turn.focusRollWin = false),
            ),
          ],
        ),
        if (isFinal) ...[
          Center(child: Text('Challenge Result', style: TextStyle(color: const Color.fromARGB(255, 190, 246, 248)))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildColoredButton(
                label: 'Victory',
                selected: duel.result == MatchResult.victory,
                selectedColor: Colors.green,
                onTap: () => setState(() => duel.result = MatchResult.victory),
              ),
              SizedBox(width: 10),
              _buildColoredButton(
                label: 'Draw',
                selected: duel.result == MatchResult.draw,
                selectedColor: Colors.lightBlue,
                onTap: () => setState(() => duel.result = MatchResult.draw),
              ),
              SizedBox(width: 10),
              _buildColoredButton(
                label: 'Death',
                selected: duel.result == MatchResult.death,
                selectedColor: Colors.red[900]!,
                onTap: () => setState(() => duel.result = MatchResult.death),
              ),
            ],
          ),
        ],
        SizedBox(height: 12),
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
      child: Text(label,
          style: TextStyle(
              color: selected ? const Color.fromARGB(255, 10, 35, 66) : Colors.white,
              fontWeight: FontWeight.bold)),
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
  List<_TurnInputs> turns = [ _TurnInputs() ];
  MatchResult result = MatchResult.victory;
}






