import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/event_model.dart';
import '../models/duel_model.dart';
import '../models/turn_model.dart';

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
  late Box<String> yourCharBox;
  late Box<String> enemyCharBox;

  @override
  void initState() {
    super.initState();
    yourCharBox = Hive.box<String>('your_characters');
    enemyCharBox = Hive.box<String>('enemy_characters');
  }

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

        final yourChar = duel.yourCharacterController.text.trim();
        final enemyChar = duel.enemyCharacterController.text.trim();

        if (yourChar.isNotEmpty && !yourCharBox.values.contains(yourChar)) {
          yourCharBox.add(yourChar);
        }
        if (enemyChar.isNotEmpty && !enemyCharBox.values.contains(enemyChar)) {
          enemyCharBox.add(enemyChar);
        }

        return Duel(
          title: duel.titleController.text,
          yourCharacter: yourChar,
          enemyCharacter: enemyChar,
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
      'Finishing Blow',
      'Test the Foe',
      'Guard Up',
      'Taunt and Bait',
      'Grandstand',
      'Withdraw'
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
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Challenge #${index + 1}', style: TextStyle(color: Colors.tealAccent, fontSize: 20)),
          SizedBox(height: 12),
          TextFormField(
            controller: duel.titleController,
            decoration: InputDecoration(labelText: 'Challenge Title'),
            style: TextStyle(color: Colors.white),
            validator: (value) => value!.isEmpty ? 'Enter a title' : null,
          ),
          _buildAutoCompleteField(
            label: 'Your Character',
            controller: duel.yourCharacterController,
            options: yourCharBox.values.toList(),
          ),
          _buildAutoCompleteField(
            label: 'Enemy Character',
            controller: duel.enemyCharacterController,
            options: enemyCharBox.values.toList(),
          ),
          SizedBox(height: 12),
          for (int turnIndex = 0; turnIndex < duel.turns.length; turnIndex++)
            _buildTurnBlock(duel.turns[turnIndex], turnIndex, duel, gambitOptions),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () => setState(() => duel.turns.add(_TurnInputs())), child: Text('Add Turn')),
        ],
      ),
    );
  }

  Widget _buildAutoCompleteField({
    required String label,
    required TextEditingController controller,
    required List<String> options,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return options.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        textController.text = controller.text;
        textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
        textController.addListener(() {
          controller.text = textController.text;
        });
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: label),
          validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        );
      },
      onSelected: (selection) => controller.text = selection,
    );
  }

  Widget _buildTurnBlock(_TurnInputs turn, int turnIndex, _DuelFormData duel, List<String> gambitOptions) {
    final isFinal = turnIndex == duel.turns.length - 1;
    return Column(
      children: [
        SizedBox(height: 8),
        Text('Turn ${turnIndex + 1}${isFinal ? " (Final Turn)" : ""}', style: TextStyle(color: Colors.cyanAccent)),
        TextFormField(
          controller: turn.playerWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Your Wounds'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: turn.opponentWoundsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Enemy Wounds'),
          style: TextStyle(color: Colors.white),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        DropdownButtonFormField<String>(
          value: turn.playerGambit,
          items: gambitOptions.map((g) => DropdownMenuItem(child: Text(g), value: g)).toList(),
          onChanged: (val) => setState(() => turn.playerGambit = val!),
          decoration: InputDecoration(labelText: 'Your Gambit'),
        ),
        DropdownButtonFormField<String>(
          value: turn.opponentGambit,
          items: gambitOptions.map((g) => DropdownMenuItem(child: Text(g), value: g)).toList(),
          onChanged: (val) => setState(() => turn.opponentGambit = val!),
          decoration: InputDecoration(labelText: 'Enemy Gambit'),
        ),
        SizedBox(height: 8),
        Text('Focus Roll', style: TextStyle(color: Colors.white70)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColoredButton('Won', turn.focusRollWin, Colors.green, () => setState(() => turn.focusRollWin = true)),
            SizedBox(width: 10),
            _buildColoredButton('Lost', !turn.focusRollWin, Colors.red[900]!, () => setState(() => turn.focusRollWin = false)),
          ],
        ),
        if (isFinal)
          Column(
            children: [
              Text('Challenge Result', style: TextStyle(color: Colors.white70)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColoredButton('Victory', duel.result == MatchResult.victory, Colors.green, () => setState(() => duel.result = MatchResult.victory)),
                  SizedBox(width: 10),
                  _buildColoredButton('Draw', duel.result == MatchResult.draw, Colors.lightBlue, () => setState(() => duel.result = MatchResult.draw)),
                  SizedBox(width: 10),
                  _buildColoredButton('Death', duel.result == MatchResult.death, Colors.red[900]!, () => setState(() => duel.result = MatchResult.death)),
                ],
              ),
            ],
          ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildColoredButton(String label, bool selected, Color selectedColor, VoidCallback onTap) {
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









