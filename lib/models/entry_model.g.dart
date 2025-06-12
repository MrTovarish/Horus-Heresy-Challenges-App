// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryAdapter extends TypeAdapter<Entry> {
  @override
  final int typeId = 0;

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Entry(
      game: fields[0] as String,
      date: fields[1] as DateTime,
      character: fields[2] as String,
      playerWounds: fields[3] as int,
      opponent: fields[4] as String,
      opponentWounds: fields[5] as int,
      gambit: fields[6] as String,
      focusRollWin: fields[7] as bool,
      matchWin: fields[8] as bool,
      opponentGambit: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.game)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.character)
      ..writeByte(3)
      ..write(obj.playerWounds)
      ..writeByte(4)
      ..write(obj.opponent)
      ..writeByte(5)
      ..write(obj.opponentWounds)
      ..writeByte(6)
      ..write(obj.gambit)
      ..writeByte(7)
      ..write(obj.focusRollWin)
      ..writeByte(8)
      ..write(obj.matchWin)
      ..writeByte(9)
      ..write(obj.opponentGambit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
