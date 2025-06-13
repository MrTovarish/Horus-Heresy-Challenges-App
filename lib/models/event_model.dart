import 'package:hive/hive.dart';
import 'turn_model.dart';

part 'event_model.g.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String yourCharacter;

  @HiveField(3)
  late String enemyCharacter;

  @HiveField(4)
  late List<Turn> turns;

  @HiveField(5)
  late bool matchWin;

  Event({
  required this.title,
  required this.date,
  required this.yourCharacter,
  required this.enemyCharacter,
  required this.turns,
  required this.matchWin,
  });
}
