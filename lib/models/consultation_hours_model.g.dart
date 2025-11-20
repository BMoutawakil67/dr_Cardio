// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_hours_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsultationHoursAdapter extends TypeAdapter<ConsultationHours> {
  @override
  final int typeId = 6;

  @override
  ConsultationHours read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsultationHours(
      id: fields[0] as String,
      doctorId: fields[1] as String,
      schedule: (fields[2] as Map).cast<String, DaySchedule>(),
      updatedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConsultationHours obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.doctorId)
      ..writeByte(2)
      ..write(obj.schedule)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationHoursAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayScheduleAdapter extends TypeAdapter<DaySchedule> {
  @override
  final int typeId = 7;

  @override
  DaySchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DaySchedule(
      enabled: fields[0] as bool,
      start: fields[1] as String,
      end: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DaySchedule obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
