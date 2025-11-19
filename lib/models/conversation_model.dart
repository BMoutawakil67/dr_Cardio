import 'package:hive/hive.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 4)
class Conversation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientId;

  @HiveField(2)
  final String doctorId;

  @HiveField(3)
  final String lastMessage;

  @HiveField(4)
  final DateTime lastMessageTime;

  @HiveField(5)
  final int unreadCount;

  @HiveField(6)
  final bool isSystem; // For system/notification conversations

  Conversation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isSystem = false,
  });

  Conversation copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isSystem,
  }) {
    return Conversation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          lastMessage == other.lastMessage &&
          lastMessageTime == other.lastMessageTime &&
          unreadCount == other.unreadCount &&
          isSystem == other.isSystem;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      lastMessage.hashCode ^
      lastMessageTime.hashCode ^
      unreadCount.hashCode ^
      isSystem.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isSystem': isSystem,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: DateTime.parse(map['lastMessageTime'] as String),
      unreadCount: map['unreadCount'] as int? ?? 0,
      isSystem: map['isSystem'] as bool? ?? false,
    );
  }
}
