import 'dart:ui';
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

class _EntryFormScreenState extends State<EntryFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final List<_DuelFormData> _duels = [_DuelFormData()];
  late Box<String> yourCharBox;
  late Box<String> enemyCharBox;
  late AnimationController _animationController;

  final List<String> gambitOptions = [
    'A Brother Betrayed',
    'A Death Long Forseen',
    'A Saga Woven Of Glory',
    'A Wall Unyielding',
    'Aegis of Wisdom',
    'Angelic Descent',
    'Archein of Wisdom',
    'Barbaran Resilience',
    'Beseech the Gods',
    'Brutal Dismemberment',
    'Bulwark of the Imperium',
    'Calculating Swordsman',
    'Death by a Thousand Cuts',
    'Death\'s Champion',
    'Decapitation Strike',
    'Dirty Fighter',
    'Duty is Sacrifice',
    'Executioner\'s Tax',
    'Feint and Riposte',
    'Finishing Blow',
    'Flurry of Blows',
    'Grandstand',
    'Guard Up',
    'Hammerblow',
    'Head-Taker',
    'Howl of the Death Wolf',
    'I am Alpharius',
    'Legion of One',
    'Merciless Strike',
    'No Prey Escapes',
    'Nostroman Courage',
    'Paragon of Excellence',
    'Prophetic Duelist',
    'Seeker of Atonement',
    'Seize the Iniative',
    'Skill Unmatched',
    'Spiteful Demise',
    'Steadfast Resilience',
    'Sword of the Order',
    'Taunt and Bait',
    'Tempered by War',
    'Test the Foe',
    'The Breaker',
    'The Broken Mirror',
    'The Line Unbroken',
    'The Lion\'s Choler',
    'The Path of the Warrior',
    'The Shadowed Lord',
    'The Undying Fire',
    'Thrall of the Red Thirst',
    'Violent Overkill',
    'Witchblood',
    'Withdraw'
  ];

  @override
  void initState() {
    super.initState();
    yourCharBox = Hive.box<String>('your_characters');
    enemyCharBox = Hive.box<String>('enemy_characters');
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Widget _animatedButton(String text, Color color, VoidCallback onPressed,
      {bool isSelected = false, bool isToggle = false}) {
    final backgroundColor = isToggle
        ? (isSelected ? color : Colors.grey.shade800)
        : color;
    final gradient = LinearGradient(
      colors: isToggle && !isSelected
          ? [Colors.grey.shade800, Colors.grey.shade800]
          : [backgroundColor.withOpacity(0.9), backgroundColor.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: onPressed,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isToggle && isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildGambitDropdown(String label, String value, Function(String?) onChanged) {
  final controller = TextEditingController();

  if (value.isNotEmpty) {
    controller.text = value;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0, left: 4),
        child: Text(label, style: TextStyle(color: Colors.white70)),
      ),
      Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return gambitOptions.where((g) =>
              g.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (val) {
          controller.text = val;
          onChanged(val);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          // Initialize text only once
          if (controller.text.isNotEmpty && textEditingController.text.isEmpty) {
            textEditingController.text = controller.text;
          }

          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type to Filter',
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (val) => onChanged(val),
          );
        },
      )
    ],
  );
}


  Widget _buildTextInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black26,
          labelStyle: TextStyle(color: Colors.white70, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildTurnBlock(_TurnInputs turn, int turnIndex, _DuelFormData duel) {
    final isFinal = turnIndex == duel.turns.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text('Turn ${turnIndex + 1}${isFinal ? " (Final Turn)" : ""}',
            style: TextStyle(color: const Color.fromARGB(255, 109, 145, 243), fontSize: 16, fontWeight: FontWeight.w500)),
        _buildTextInput('Your Wounds', turn.playerWoundsController),
        _buildTextInput('Enemy Wounds', turn.opponentWoundsController),
        _buildGambitDropdown("Your Gambit", turn.playerGambit, (val) => setState(() => turn.playerGambit = val!)),
        _buildGambitDropdown("Enemy Gambit", turn.opponentGambit, (val) => setState(() => turn.opponentGambit = val!)),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Focus Roll',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _animatedButton('Won', Colors.green, () => setState(() => turn.focusRollWin = true),
                isSelected: turn.focusRollWin, isToggle: true),
            SizedBox(width: 10),
            _animatedButton('Lost', Colors.red[900]!, () => setState(() => turn.focusRollWin = false),
                isSelected: !turn.focusRollWin, isToggle: true),
          ],
        ),
        if (isFinal) ...[
          SizedBox(height: 8),
          Center(
            child: Text(
              'Challenge Result',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _animatedButton('Victory', Colors.green, () => setState(() => duel.result = MatchResult.victory),
                  isSelected: duel.result == MatchResult.victory, isToggle: true),
              SizedBox(width: 10),
              _animatedButton('Draw', Colors.lightBlue, () => setState(() => duel.result = MatchResult.draw),
                  isSelected: duel.result == MatchResult.draw, isToggle: true),
              SizedBox(width: 10),
              _animatedButton('Death', Colors.red[900]!, () => setState(() => duel.result = MatchResult.death),
                  isSelected: duel.result == MatchResult.death, isToggle: true),
            ],
          )
        ]
      ],
    );
  }

  Widget _buildDuelForm(_DuelFormData duel, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('⚔️Challenge #${index + 1}',
            style: TextStyle(color: const Color.fromARGB(255, 102, 199, 255), fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        _buildTextInput('Name your Challenge', duel.titleController),
        _buildTextInput('Your Character', duel.yourCharacterController),
        _buildTextInput('Enemy Character', duel.enemyCharacterController),
        SizedBox(height: 8),
        for (int t = 0; t < duel.turns.length; t++)
          _buildTurnBlock(duel.turns[t], t, duel),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: _animatedButton('Add Turn', const Color.fromARGB(255, 53, 104, 194), () => setState(() => duel.turns.add(_TurnInputs()))),
          ),
        ),
        Divider(color: Colors.white24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Color(0xFF0A0F1F),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Game',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                ListTile(
                  title: Text(
                    "Select Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white70),
                  onTap: _pickDate,
                ),
                for (int i = 0; i < _duels.length; i++) _buildDuelForm(_duels[i], i),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _animatedButton('Add Challenge', const Color.fromARGB(255, 138, 79, 206), _addDuel),
                    _animatedButton('Save', const Color.fromARGB(255, 10, 196, 152), _saveEvent),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TurnInputs {
  final playerWoundsController = TextEditingController();
  final opponentWoundsController = TextEditingController();
  String playerGambit = '';
  String opponentGambit = '';
  bool focusRollWin = true;
}

class _DuelFormData {
  final titleController = TextEditingController();
  final yourCharacterController = TextEditingController();
  final enemyCharacterController = TextEditingController();
  List<_TurnInputs> turns = [_TurnInputs()];
  MatchResult result = MatchResult.victory;
}
















