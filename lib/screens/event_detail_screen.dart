import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/event_model.dart';
import '../models/duel_model.dart';
import '../models/turn_model.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final int duelIndex;

  EventDetailScreen({required this.event, required this.duelIndex});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Duel _duel;
  late TextEditingController _titleController;
  late TextEditingController _yourCharacterController;
  late TextEditingController _enemyCharacterController;
  late List<_EditableTurn> _turns;
  bool _isEditing = false;

  late Box<String> yourCharBox;
  late Box<String> enemyCharBox;

  final gambitOptions = [
    'A Brother Betrayed', 'A Death Long Forseen', 'A Saga Woven Of Glory', 'A Wall Unyielding',
    'Aegis of Wisdom', 'Angelic Descent', 'Archein of Wisdom', 'Barbaran Resilience',
    'Beseech the Gods', 'Brutal Dismemberment', 'Bulwark of the Imperium', 'Calculating Swordsman',
    'Death by a Thousand Cuts', 'Death\'s Champion', 'Decapitation Strike', 'Dirty Fighter',
    'Duty is Sacrifice', 'Executioner\'s Tax', 'Feint and Riposte', 'Finishing Blow',
    'Flurry of Blows', 'Grandstand', 'Guard Up', 'Hammerblow', 'Head-Taker',
    'Howl of the Death Wolf', 'I am Alpharius', 'Legion of One', 'Liquifractor Onslaught','Merciless Strike',
    'No Prey Escapes', 'Nostroman Courage', 'Paragon of Excellence', 'Prophetic Duelist',
    'Seeker of Atonement', 'Seize the Iniative', 'Skill Unmatched', 'Spiteful Demise',
    'Steadfast Resilience', 'Sword of the Order', 'Taunt and Bait', 'Tempered by War',
    'Test the Foe', 'The Breaker', 'The Broken Mirror', 'The Line Unbroken',
    'The Lion\'s Choler', 'The Path of the Warrior', 'The Shadowed Lord', 'The Undying Fire',
    'Thrall of the Red Thirst', 'Violent Overkill', 'Witchblood', 'Withdraw'
  ];

  @override
  void initState() {
    super.initState();
    yourCharBox = Hive.box<String>('your_characters');
    enemyCharBox = Hive.box<String>('enemy_characters');

    _duel = widget.event.duels[widget.duelIndex];
    _titleController = TextEditingController(text: _duel.title);
    _yourCharacterController = TextEditingController(text: _duel.yourCharacter);
    _enemyCharacterController = TextEditingController(text: _duel.enemyCharacter);
    _turns = _duel.turns.map((t) => _EditableTurn.fromTurn(t)).toList();
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

  Future<void> _saveChanges() async {
    final updatedTurns = _turns.map((t) => Turn(
      playerWounds: int.parse(t.playerWoundsController.text),
      opponentWounds: int.parse(t.opponentWoundsController.text),
      playerGambit: t.playerGambit,
      opponentGambit: t.opponentGambit,
      focusRollWin: t.focusRollWin,
    )).toList();

    final yourChar = _yourCharacterController.text.trim();
    final enemyChar = _enemyCharacterController.text.trim();

    if (yourChar.isNotEmpty && !yourCharBox.values.contains(yourChar)) {
      yourCharBox.add(yourChar);
    }
    if (enemyChar.isNotEmpty && !enemyCharBox.values.contains(enemyChar)) {
      enemyCharBox.add(enemyChar);
    }

    final updatedDuel = Duel(
      title: _titleController.text,
      yourCharacter: yourChar,
      enemyCharacter: enemyChar,
      turns: updatedTurns,
      result: _duel.result,
    );

    final box = Hive.box<Event>('events');
    final updatedEvent = widget.event;
    updatedEvent.duels[widget.duelIndex] = updatedDuel;
    await box.put(updatedEvent.key, updatedEvent);

    setState(() {
      _duel = updatedDuel;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Changes saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 11, 17),
      appBar: AppBar(
        title: Text('Duel Details'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _editableField('Title', _titleController),
            _characterAutocompleteField('Your Character', _yourCharacterController, yourCharBox.values.toList()),
            _characterAutocompleteField('Enemy Character', _enemyCharacterController, enemyCharBox.values.toList()),
            SizedBox(height: 20),
            ..._turns.asMap().entries.map((entry) {
              final turnIndex = entry.key;
              final turn = entry.value;
              final isFinal = turnIndex == _turns.length - 1;

              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFinal ? 'Turn ${turnIndex + 1} - Final Turn' : 'Turn ${turnIndex + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      SizedBox(height: 4),
                      _editableField('Your Wounds', turn.playerWoundsController, isNumber: true),
                      _editableField('Enemy Wounds', turn.opponentWoundsController, isNumber: true),
                      _isEditing
                          ? _gambitDropdown(turn.playerGambit, (v) => setState(() => turn.playerGambit = v), 'Your Gambit')
                          : Text('Your Gambit: ${turn.playerGambit}', style: _infoStyle()),
                      _isEditing
                          ? _gambitDropdown(turn.opponentGambit, (v) => setState(() => turn.opponentGambit = v), 'Enemy Gambit')
                          : Text('Enemy Gambit: ${turn.opponentGambit}', style: _infoStyle()),
                      _isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Focus Roll:', style: _infoStyle()),
                                Row(
                                  children: [
                                    _buildColoredButton('Won', turn.focusRollWin, Colors.green,
                                        () => setState(() => turn.focusRollWin = true)),
                                    SizedBox(width: 10),
                                    _buildColoredButton('Lost', !turn.focusRollWin, Colors.red[900]!,
                                        () => setState(() => turn.focusRollWin = false)),
                                  ],
                                ),
                              ],
                            )
                          : Text('Focus Roll: ${turn.focusRollWin ? 'Won' : 'Lost'}', style: _infoStyle()),
                      if (isFinal)
                        _isEditing
                            ? Row(
                                children: [
                                  Text('Result: ', style: _infoStyle()),
                                  _buildColoredButton('Victory', _duel.result == MatchResult.victory, Colors.green,
                                      () => setState(() => _duel.result = MatchResult.victory)),
                                  SizedBox(width: 10),
                                  _buildColoredButton('Draw', _duel.result == MatchResult.draw, Colors.lightBlueAccent,
                                      () => setState(() => _duel.result = MatchResult.draw)),
                                  SizedBox(width: 10),
                                  _buildColoredButton('Death', _duel.result == MatchResult.death,
                                      const Color.fromARGB(255, 211, 32, 32), () => setState(() => _duel.result = MatchResult.death)),
                                ],
                              )
                            : Text(
                                'Result: ${_duel.result.name[0].toUpperCase()}${_duel.result.name.substring(1)}',
                                style: TextStyle(fontSize: 16, color: _getResultColor(_duel.result)),
                              ),
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

  Widget _editableField(String label, TextEditingController controller, {bool isNumber = false}) {
    return _isEditing
        ? TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: _infoStyle(),
            decoration: InputDecoration(labelText: label),
          )
        : Text('$label: ${controller.text}', style: _infoStyle());
  }

  Widget _characterAutocompleteField(String label, TextEditingController controller, List<String> options) {
    return _isEditing
        ? Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return options
                  .where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              if (controller.text.isNotEmpty && textController.text.isEmpty) {
                textController.text = controller.text;
              }

              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(labelText: label),
                style: _infoStyle(),
                onChanged: (val) => controller.text = val,
              );
            },
            onSelected: (val) => controller.text = val,
          )
        : Text('$label: ${controller.text}', style: _infoStyle());
  }

  Widget _gambitDropdown(String selected, ValueChanged<String> onChanged, String label) {
    return DropdownSearch<String>(
      selectedItem: selected,
      items: gambitOptions,
      popupProps: PopupProps.menu(showSearchBox: true),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(labelText: label),
      ),
      onChanged: (value) => onChanged(value ?? selected),
    );
  }

  Color _getResultColor(MatchResult result) {
    switch (result) {
      case MatchResult.victory:
        return Colors.green;
      case MatchResult.draw:
        return Colors.lightBlueAccent;
      case MatchResult.death:
        return const Color.fromARGB(255, 214, 33, 33);
    }
  }

  Widget _buildColoredButton(String label, bool selected, Color selectedColor, VoidCallback onTap) {
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

  TextStyle _infoStyle() => TextStyle(fontSize: 16, color: const Color.fromARGB(255, 186, 224, 226));
}

class _EditableTurn {
  final TextEditingController playerWoundsController;
  final TextEditingController opponentWoundsController;
  String playerGambit;
  String opponentGambit;
  bool focusRollWin;

  _EditableTurn({
    required this.playerWoundsController,
    required this.opponentWoundsController,
    required this.playerGambit,
    required this.opponentGambit,
    required this.focusRollWin,
  });

  factory _EditableTurn.fromTurn(Turn t) {
    return _EditableTurn(
      playerWoundsController: TextEditingController(text: t.playerWounds.toString()),
      opponentWoundsController: TextEditingController(text: t.opponentWounds.toString()),
      playerGambit: t.playerGambit,
      opponentGambit: t.opponentGambit,
      focusRollWin: t.focusRollWin,
    );
  }
}





