import 'package:hive/hive.dart';
import 'duel_model.dart';

part 'event_model.g.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {

  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late List<Duel> duels;

  Event({
  required this.date,
  required this.duels,
  });
}
