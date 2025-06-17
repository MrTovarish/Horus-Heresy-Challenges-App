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

extension MatchResultExtension on MatchResult {
  String toShortString() => toString().split('.').last;

  static MatchResult fromString(String value) {
    switch (value) {
      case 'victory':
        return MatchResult.victory;
      case 'draw':
        return MatchResult.draw;
      case 'death':
        return MatchResult.death;
      default:
        throw ArgumentError('Unknown MatchResult: $value');
    }
  }
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
  MatchResult result;

  Duel({
    required this.title,
    required this.yourCharacter,
    required this.enemyCharacter,
    required this.turns,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'yourCharacter': yourCharacter,
        'enemyCharacter': enemyCharacter,
        'turns': turns.map((t) => t.toJson()).toList(),
        'result': result.toShortString(),
      };

  factory Duel.fromJson(Map<String, dynamic> json) => Duel(
        title: json['title'],
        yourCharacter: json['yourCharacter'],
        enemyCharacter: json['enemyCharacter'],
        turns: (json['turns'] as List)
            .map((t) => Turn.fromJson(t as Map<String, dynamic>))
            .toList(),
        result: MatchResultExtension.fromString(json['result']),
      );
}

