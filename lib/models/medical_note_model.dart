import 'dart:convert';

class MedicalNote {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String title;
  final String content;
  final String category;
  final List<String> attachments;
  DateTime? lastModified;

  MedicalNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.title,
    required this.content,
    required this.category,
    this.attachments = const [],
    this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'category': category,
      'attachments': attachments,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory MedicalNote.fromMap(Map<String, dynamic> map) {
    return MedicalNote(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      content: map['content'],
      category: map['category'],
      attachments: List<String>.from(map['attachments']),
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicalNote.fromJson(String source) =>
      MedicalNote.fromMap(json.decode(source));
}
