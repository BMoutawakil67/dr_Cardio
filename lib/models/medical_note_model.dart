import 'package:hive/hive.dart';

part 'medical_note_model.g.dart';

@HiveType(typeId: 2)
class MedicalNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientId;

  @HiveField(2)
  final String doctorId;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int systolic;

  @HiveField(5)
  final int diastolic;

  @HiveField(6)
  final int heartRate;

  @HiveField(7)
  final String context;

  @HiveField(8)
  final String? photoUrl;

  MedicalNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.context,
    this.photoUrl,
  });

  MedicalNote copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? date,
    int? systolic,
    int? diastolic,
    int? heartRate,
    String? context,
    String? photoUrl,
  }) {
    return MedicalNote(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      context: context ?? this.context,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          date == other.date &&
          systolic == other.systolic &&
          diastolic == other.diastolic &&
          heartRate == other.heartRate &&
          context == other.context &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      date.hashCode ^
      systolic.hashCode ^
      diastolic.hashCode ^
      heartRate.hashCode ^
      context.hashCode ^
      photoUrl.hashCode;

  // Serialization methods for compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'context': context,
      'photoUrl': photoUrl,
    };
  }

  factory MedicalNote.fromMap(Map<String, dynamic> map) {
    return MedicalNote(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      date: DateTime.parse(map['date'] as String),
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      heartRate: map['heartRate'] as int,
      context: map['context'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}
