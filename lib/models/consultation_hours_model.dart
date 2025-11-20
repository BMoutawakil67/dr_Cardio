import 'package:hive/hive.dart';

part 'consultation_hours_model.g.dart';

@HiveType(typeId: 6)
class ConsultationHours {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String doctorId;

  @HiveField(2)
  final Map<String, DaySchedule> schedule;

  @HiveField(3)
  final DateTime? updatedAt;

  ConsultationHours({
    required this.id,
    required this.doctorId,
    required this.schedule,
    this.updatedAt,
  });

  ConsultationHours copyWith({
    String? id,
    String? doctorId,
    Map<String, DaySchedule>? schedule,
    DateTime? updatedAt,
  }) {
    return ConsultationHours(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      schedule: schedule ?? this.schedule,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ConsultationHours getDefault(String doctorId) {
    return ConsultationHours(
      id: doctorId,
      doctorId: doctorId,
      schedule: {
        'monday': DaySchedule(enabled: true, start: '08:00', end: '17:00'),
        'tuesday': DaySchedule(enabled: true, start: '08:00', end: '17:00'),
        'wednesday': DaySchedule(enabled: true, start: '08:00', end: '17:00'),
        'thursday': DaySchedule(enabled: true, start: '08:00', end: '17:00'),
        'friday': DaySchedule(enabled: true, start: '08:00', end: '17:00'),
        'saturday': DaySchedule(enabled: true, start: '08:00', end: '12:00'),
        'sunday': DaySchedule(enabled: false, start: '', end: ''),
      },
    );
  }
}

@HiveType(typeId: 7)
class DaySchedule {
  @HiveField(0)
  final bool enabled;

  @HiveField(1)
  final String start;

  @HiveField(2)
  final String end;

  DaySchedule({
    required this.enabled,
    required this.start,
    required this.end,
  });

  DaySchedule copyWith({
    bool? enabled,
    String? start,
    String? end,
  }) {
    return DaySchedule(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
