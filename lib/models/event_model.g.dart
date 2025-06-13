// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 2;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      title: fields[0] as String,
      date: fields[1] as DateTime,
      yourCharacter: fields[2] as String,
      enemyCharacter: fields[3] as String,
      turns: (fields[4] as List).cast<Turn>(),
      focusRollWin: fields[5] as bool,
      matchWin: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.yourCharacter)
      ..writeByte(3)
      ..write(obj.enemyCharacter)
      ..writeByte(4)
      ..write(obj.turns)
      ..writeByte(5)
      ..write(obj.focusRollWin)
      ..writeByte(6)
      ..write(obj.matchWin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
