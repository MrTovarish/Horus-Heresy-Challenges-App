// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turn_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TurnAdapter extends TypeAdapter<Turn> {
  @override
  final int typeId = 1;

  @override
  Turn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Turn(
      playerWounds: fields[0] as int,
      opponentWounds: fields[1] as int,
      playerGambit: fields[2] as String,
      opponentGambit: fields[3] as String,
      focusRollWin: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Turn obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.playerWounds)
      ..writeByte(1)
      ..write(obj.opponentWounds)
      ..writeByte(2)
      ..write(obj.playerGambit)
      ..writeByte(3)
      ..write(obj.opponentGambit)
      ..writeByte(4)
      ..write(obj.focusRollWin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
