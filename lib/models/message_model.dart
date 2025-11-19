import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 3)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String receiverId;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final String? attachmentPath;

  @HiveField(8)
  final String? attachmentType; // 'image', 'document', 'voice', etc.

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.attachmentPath,
    this.attachmentType,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentPath,
    String? attachmentType,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          conversationId == other.conversationId &&
          senderId == other.senderId &&
          receiverId == other.receiverId &&
          text == other.text &&
          timestamp == other.timestamp &&
          isRead == other.isRead &&
          attachmentPath == other.attachmentPath &&
          attachmentType == other.attachmentType;

  @override
  int get hashCode =>
      id.hashCode ^
      conversationId.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      text.hashCode ^
      timestamp.hashCode ^
      isRead.hashCode ^
      attachmentPath.hashCode ^
      attachmentType.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentPath': attachmentPath,
      'attachmentType': attachmentType,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
      attachmentPath: map['attachmentPath'] as String?,
      attachmentType: map['attachmentType'] as String?,
    );
  }
}
