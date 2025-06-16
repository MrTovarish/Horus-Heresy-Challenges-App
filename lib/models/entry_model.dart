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
}
