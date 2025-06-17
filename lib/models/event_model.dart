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

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'duels': duels.map((duel) => duel.toJson()).toList(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        date: DateTime.parse(json['date']),
        duels: (json['duels'] as List<dynamic>)
            .map((d) => Duel.fromJson(d))
            .toList(),
      );
}

