import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/conversation_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class ConversationRepository {
  final Box<Conversation> _box =
      Hive.box<Conversation>(HiveDatabase.conversationBox);
  final Map<String, int> _indexCache = {};

  ConversationRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addConversation(Conversation conversation) async {
    try {
      final key = await _box.add(conversation);
      logger.i('Added conversation with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding conversation: $e');
      if (kDebugMode) {
        print('Error adding conversation: $e');
      }
      throw HiveError('Failed to add conversation.');
    }
  }

  Future<Conversation?> getConversation(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting conversation: $e');
      if (kDebugMode) {
        print('Error getting conversation: $e');
      }
      return null;
    }
  }

  Future<List<Conversation>> getAllConversations() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all conversations: $e');
      if (kDebugMode) {
        print('Error getting all conversations: $e');
      }
      return [];
    }
  }

  Future<List<Conversation>> getConversationsByPatient(String patientId) async {
    try {
      final conversations = _box.values
          .where((conv) => conv.patientId == patientId)
          .toList();
      // Sort by last message time (most recent first)
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    } catch (e) {
      logger.e('Error getting conversations by patient: $e');
      if (kDebugMode) {
        print('Error getting conversations by patient: $e');
      }
      return [];
    }
  }

  Future<List<Conversation>> getConversationsByDoctor(String doctorId) async {
    try {
      final conversations = _box.values
          .where((conv) => conv.doctorId == doctorId)
          .toList();
      // Sort by last message time (most recent first)
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    } catch (e) {
      logger.e('Error getting conversations by doctor: $e');
      if (kDebugMode) {
        print('Error getting conversations by doctor: $e');
      }
      return [];
    }
  }

  /// Stream that watches conversations for a specific doctor
  /// Emits a new list whenever conversations are added, updated, or deleted
  Stream<List<Conversation>> watchConversationsByDoctor(String doctorId) {
    return _box.watch().map((_) {
      final conversations = _box.values
          .where((conv) => conv.doctorId == doctorId)
          .toList();
      // Sort by last message time (most recent first)
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    });
  }

  /// Stream that watches conversations for a specific patient
  /// Emits a new list whenever conversations are added, updated, or deleted
  Stream<List<Conversation>> watchConversationsByPatient(String patientId) {
    return _box.watch().map((_) {
      final conversations = _box.values
          .where((conv) => conv.patientId == patientId)
          .toList();
      // Sort by last message time (most recent first)
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    });
  }

  Future<Conversation?> getConversationBetween(
      String patientId, String doctorId) async {
    try {
      return _box.values.firstWhereOrNull(
        (conv) =>
            conv.patientId == patientId &&
            conv.doctorId == doctorId &&
            !conv.isSystem,
      );
    } catch (e) {
      logger.e('Error getting conversation between users: $e');
      return null;
    }
  }

  Future<bool> updateConversation(Conversation conversation) async {
    try {
      final index = _findIndex(conversation.id);
      if (index != -1) {
        await _box.putAt(index, conversation);
        logger.i('Updated conversation with id: ${conversation.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating conversation: $e');
      if (kDebugMode) {
        print('Error updating conversation: $e');
      }
      return false;
    }
  }

  Future<bool> deleteConversation(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted conversation with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting conversation: $e');
      if (kDebugMode) {
        print('Error deleting conversation: $e');
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
