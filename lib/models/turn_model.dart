import 'package:hive/hive.dart';

part 'turn_model.g.dart';

@HiveType(typeId: 1)
class Turn extends HiveObject {
  @HiveField(0)
  late int playerWounds;

  @HiveField(1)
  late int opponentWounds;

  @HiveField(2)
  late String playerGambit;

  @HiveField(3)
  late String opponentGambit;

  @HiveField(4)
  late bool focusRollWin;

  Turn({
    required this.playerWounds,
    required this.opponentWounds,
    required this.playerGambit,
    required this.opponentGambit,
    required this.focusRollWin,
  });

  Map<String, dynamic> toJson() => {
        'playerWounds': playerWounds,
        'opponentWounds': opponentWounds,
        'playerGambit': playerGambit,
        'opponentGambit': opponentGambit,
        'focusRollWin': focusRollWin,
      };

  factory Turn.fromJson(Map<String, dynamic> json) => Turn(
        playerWounds: json['playerWounds'],
        opponentWounds: json['opponentWounds'],
        playerGambit: json['playerGambit'],
        opponentGambit: json['opponentGambit'],
        focusRollWin: json['focusRollWin'],
      );
}
