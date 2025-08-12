// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkerAdapter extends TypeAdapter<Worker> {
  @override
  final int typeId = 1;

  @override
  Worker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Worker(
      name: fields[0] as String,
      groupName: fields[1] as String,
      deductions: fields[2] as String,
      selectedDays: (fields[3] as List).cast<String>(),
      earnings: fields[4] as String,
      total: fields[5] as String,
      weekRange: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Worker obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.deductions)
      ..writeByte(3)
      ..write(obj.selectedDays)
      ..writeByte(4)
      ..write(obj.earnings)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.weekRange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
