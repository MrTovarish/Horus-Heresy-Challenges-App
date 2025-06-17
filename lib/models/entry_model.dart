import 'package:hive/hive.dart';
import 'duel_model.dart';

part 'entry_model.g.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  late String game;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String character;

  @HiveField(3)
  late int playerWounds;

  @HiveField(4)
  late String opponent;

  @HiveField(5)
  late int opponentWounds;

  @HiveField(6)
  late String gambit;

  @HiveField(7)
  late bool focusRollWin;

  @HiveField(8)
  late MatchResult result;

  @HiveField(9)
  late String opponentGambit;

  Entry({
    required this.game,
    required this.date,
    required this.character,
    required this.playerWounds,
    required this.opponent,
    required this.opponentWounds,
    required this.gambit,
    required this.focusRollWin,
    required this.result,
    required this.opponentGambit,
  });

  Map<String, dynamic> toJson() => {
        'game': game,
        'date': date.toIso8601String(),
        'character': character,
        'playerWounds': playerWounds,
        'opponent': opponent,
        'opponentWounds': opponentWounds,
        'gambit': gambit,
        'focusRollWin': focusRollWin,
        'result': result.toShortString(),
        'opponentGambit': opponentGambit,
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        game: json['game'],
        date: DateTime.parse(json['date']),
        character: json['character'],
        playerWounds: json['playerWounds'],
        opponent: json['opponent'],
        opponentWounds: json['opponentWounds'],
        gambit: json['gambit'],
        focusRollWin: json['focusRollWin'],
        result: MatchResultExtension.fromString(json['result']),
        opponentGambit: json['opponentGambit'],
      );
}
