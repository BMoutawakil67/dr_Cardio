import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/medication_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class MedicationRepository {
  final Box<Medication> _box = Hive.box<Medication>(HiveDatabase.medicationBox);
  final Map<String, int> _indexCache = {};

  MedicationRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addMedication(Medication medication) async {
    try {
      final key = await _box.add(medication);
      logger.i('Added medication with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding medication: $e');
      if (kDebugMode) {
        print('Error adding medication: $e');
      }
      throw HiveError('Failed to add medication.');
    }
  }

  Future<Medication?> getMedication(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting medication: $e');
      if (kDebugMode) {
        print('Error getting medication: $e');
      }
      return null;
    }
  }

  Future<List<Medication>> getAllMedications() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all medications: $e');
      if (kDebugMode) {
        print('Error getting all medications: $e');
      }
      return [];
    }
  }

  Future<List<Medication>> getMedicationsByPatient(String patientId) async {
    try {
      return _box.values
          .where((medication) => medication.patientId == patientId)
          .toList();
    } catch (e) {
      logger.e('Error getting medications by patient: $e');
      if (kDebugMode) {
        print('Error getting medications by patient: $e');
      }
      return [];
    }
  }

  Future<bool> updateMedication(Medication medication) async {
    try {
      final index = _findIndex(medication.id);
      if (index != -1) {
        await _box.putAt(index, medication);
        logger.i('Updated medication with id: ${medication.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating medication: $e');
      if (kDebugMode) {
        print('Error updating medication: $e');
      }
      return false;
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted medication with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting medication: $e');
      if (kDebugMode) {
        print('Error deleting medication: $e');
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
