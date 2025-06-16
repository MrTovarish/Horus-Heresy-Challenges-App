import 'package:hive/hive.dart';
import 'turn_model.dart';

part 'duel_model.g.dart';

@HiveType(typeId: 3)
enum MatchResult {
  @HiveField(0)
  victory,
  
  @HiveField(1)
  draw,
  
  @HiveField(2)
  death,
}

@HiveType(typeId: 4)
class Duel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String yourCharacter;

  @HiveField(2)
  String enemyCharacter;

  @HiveField(3)
  List<Turn> turns;

  @HiveField(4)
  MatchResult result; // REPLACES bool matchWin

  Duel({
    required this.title,
    required this.yourCharacter,
    required this.enemyCharacter,
    required this.turns,
    required this.result,
  });
}
