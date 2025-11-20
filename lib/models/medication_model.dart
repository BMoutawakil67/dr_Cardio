import 'package:hive/hive.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 5)
class Medication {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final String? frequency;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String patientId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.frequency,
    this.notes,
    required this.patientId,
    required this.createdAt,
    this.updatedAt,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? notes,
    String? patientId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => '$name $dosage';
}
