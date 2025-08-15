// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkerModelAdapter extends TypeAdapter<WorkerModel> {
  @override
  final int typeId = 0;

  @override
  WorkerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkerModel(
      name: fields[0] as String,
      deductions: fields[1] as String,
      selectedDays: (fields[2] as List).cast<String>(),
      earnings: fields[3] as String,
      total: fields[4] as String,
      weekRange: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.deductions)
      ..writeByte(2)
      ..write(obj.selectedDays)
      ..writeByte(3)
      ..write(obj.earnings)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.weekRange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupModelAdapter extends TypeAdapter<GroupModel> {
  @override
  final int typeId = 1;

  @override
  GroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupModel(
      groupName: fields[0] as String,
      workers: (fields[1] as List).cast<WorkerModel>(),
      paymentHistory: (fields[2] as List).cast<String>(),
      currentDate: fields[3] as String,
      currentDay: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GroupModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.groupName)
      ..writeByte(1)
      ..write(obj.workers)
      ..writeByte(2)
      ..write(obj.paymentHistory)
      ..writeByte(3)
      ..write(obj.currentDate)
      ..writeByte(4)
      ..write(obj.currentDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
