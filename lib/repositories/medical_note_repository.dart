import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class MedicalNoteRepository {
  final Box<MedicalNote> _box =
      Hive.box<MedicalNote>(HiveDatabase.medicalNoteBox);
  final Map<String, int> _indexCache = {};

  MedicalNoteRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addMedicalNote(MedicalNote medicalNote) async {
    try {
      final key = await _box.add(medicalNote);
      logger.i('Added medical note with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding medical note: $e');
      if (kDebugMode) {
        print('Error adding medical note: $e');
      }
      throw HiveError('Failed to add medical note.');
    }
  }

  Future<MedicalNote?> getMedicalNote(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting medical note: $e');
      if (kDebugMode) {
        print('Error getting medical note: $e');
      }
      return null;
    }
  }

  Future<List<MedicalNote>> getAllMedicalNotes() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all medical notes: $e');
      if (kDebugMode) {
        print('Error getting all medical notes: $e');
      }
      return [];
    }
  }

  Future<List<MedicalNote>> getMedicalNotesByPatient(String patientId) async {
    try {
      return _box.values.where((note) => note.patientId == patientId).toList();
    } catch (e) {
      logger.e('Error getting medical notes by patient: $e');
      if (kDebugMode) {
        print('Error getting medical notes by patient: $e');
      }
      return [];
    }
  }

  Future<bool> updateMedicalNote(MedicalNote medicalNote) async {
    try {
      final index = _findIndex(medicalNote.id);
      if (index != -1) {
        await _box.putAt(index, medicalNote);
        logger.i('Updated medical note with id: ${medicalNote.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating medical note: $e');
      if (kDebugMode) {
        print('Error updating medical note: $e');
      }
      return false;
    }
  }

  Future<bool> deleteMedicalNote(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted medical note with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting medical note: $e');
      if (kDebugMode) {
        print('Error deleting medical note: $e');
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
