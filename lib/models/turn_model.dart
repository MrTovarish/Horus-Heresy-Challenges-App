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

  Turn({
    required this.playerWounds,
    required this.opponentWounds,
    required this.playerGambit,
    required this.opponentGambit,
  });
}
