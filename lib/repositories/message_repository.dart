import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/message_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class MessageRepository {
  final Box<Message> _box = Hive.box<Message>(HiveDatabase.messageBox);
  final Map<String, int> _indexCache = {};

  MessageRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addMessage(Message message) async {
    try {
      final key = await _box.add(message);
      logger.i('Added message with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding message: $e');
      if (kDebugMode) {
        print('Error adding message: $e');
      }
      throw HiveError('Failed to add message.');
    }
  }

  Future<Message?> getMessage(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting message: $e');
      if (kDebugMode) {
        print('Error getting message: $e');
      }
      return null;
    }
  }

  Future<List<Message>> getAllMessages() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all messages: $e');
      if (kDebugMode) {
        print('Error getting all messages: $e');
      }
      return [];
    }
  }

  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      final messages = _box.values
          .where((msg) => msg.conversationId == conversationId)
          .toList();
      // Sort by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      logger.e('Error getting messages by conversation: $e');
      if (kDebugMode) {
        print('Error getting messages by conversation: $e');
      }
      return [];
    }
  }

  Future<List<Message>> getMessagesByUser(String userId) async {
    try {
      return _box.values
          .where((msg) => msg.senderId == userId || msg.receiverId == userId)
          .toList();
    } catch (e) {
      logger.e('Error getting messages by user: $e');
      if (kDebugMode) {
        print('Error getting messages by user: $e');
      }
      return [];
    }
  }

  Future<bool> updateMessage(Message message) async {
    try {
      final index = _findIndex(message.id);
      if (index != -1) {
        await _box.putAt(index, message);
        logger.i('Updated message with id: ${message.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating message: $e');
      if (kDebugMode) {
        print('Error updating message: $e');
      }
      return false;
    }
  }

  Future<bool> markAsRead(String messageId) async {
    try {
      final message = await getMessage(messageId);
      if (message != null) {
        final updatedMessage = message.copyWith(isRead: true);
        return await updateMessage(updatedMessage);
      }
      return false;
    } catch (e) {
      logger.e('Error marking message as read: $e');
      return false;
    }
  }

  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final messages = await getMessagesByConversation(conversationId);
      for (var message in messages) {
        if (!message.isRead) {
          await markAsRead(message.id);
        }
      }
      return true;
    } catch (e) {
      logger.e('Error marking conversation as read: $e');
      return false;
    }
  }

  Future<bool> deleteMessage(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted message with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting message: $e');
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
      return false;
    }
  }

  int _findIndex(String id) {
    return _indexCache[id] ?? -1;
  }

  void _rebuildIndexCache() {
    _indexCache.clear();
    final entities = _box.values.toList();
    for (var i = 0; i < entities.length; i++) {
      _indexCache[entities[i].id] = i;
    }
  }
}
