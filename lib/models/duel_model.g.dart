// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuelAdapter extends TypeAdapter<Duel> {
  @override
  final int typeId = 4;

  @override
  Duel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Duel(
      title: fields[0] as String,
      yourCharacter: fields[1] as String,
      enemyCharacter: fields[2] as String,
      turns: (fields[3] as List).cast<Turn>(),
      result: fields[4] as MatchResult,
    );
  }

  @override
  void write(BinaryWriter writer, Duel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.yourCharacter)
      ..writeByte(2)
      ..write(obj.enemyCharacter)
      ..writeByte(3)
      ..write(obj.turns)
      ..writeByte(4)
      ..write(obj.result);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchResultAdapter extends TypeAdapter<MatchResult> {
  @override
  final int typeId = 3;

  @override
  MatchResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MatchResult.victory;
      case 1:
        return MatchResult.draw;
      case 2:
        return MatchResult.death;
      default:
        return MatchResult.victory;
    }
  }

  @override
  void write(BinaryWriter writer, MatchResult obj) {
    switch (obj) {
      case MatchResult.victory:
        writer.writeByte(0);
        break;
      case MatchResult.draw:
        writer.writeByte(1);
        break;
      case MatchResult.death:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
