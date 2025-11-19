// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalNoteAdapter extends TypeAdapter<MedicalNote> {
  @override
  final int typeId = 2;

  @override
  MedicalNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalNote(
      id: fields[0] as String,
      patientId: fields[1] as String,
      doctorId: fields[2] as String,
      date: fields[3] as DateTime,
      systolic: fields[4] as int,
      diastolic: fields[5] as int,
      heartRate: fields[6] as int,
      context: fields[7] as String,
      photoUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalNote obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.doctorId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.systolic)
      ..writeByte(5)
      ..write(obj.diastolic)
      ..writeByte(6)
      ..write(obj.heartRate)
      ..writeByte(7)
      ..write(obj.context)
      ..writeByte(8)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
