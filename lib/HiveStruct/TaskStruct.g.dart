// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskStruct.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskStructAdapter extends TypeAdapter<TaskStruct> {
  @override
  final int typeId = 0;

  @override
  TaskStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskStruct(
      fields[1] as String,
      fields[2] as String,
      date: fields[3] as DateTime?,
      completed: fields[4] as bool,
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, TaskStruct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
