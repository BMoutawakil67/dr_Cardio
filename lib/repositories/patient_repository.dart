import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class PatientRepository {
  final Box<Patient> _box = Hive.box<Patient>(HiveDatabase.patientBox);
  final Map<String, int> _indexCache = {};

  PatientRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addPatient(Patient patient) async {
    try {
      final key = await _box.add(patient);
      logger.i('Added patient with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding patient: $e');
      if (kDebugMode) {
        print('Error adding patient: $e');
      }
      throw HiveError('Failed to add patient.');
    }
  }

  Future<Patient?> getPatient(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting patient: $e');
      if (kDebugMode) {
        print('Error getting patient: $e');
      }
      return null;
    }
  }

  Future<List<Patient>> getAllPatients() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all patients: $e');
      if (kDebugMode) {
        print('Error getting all patients: $e');
      }
      return [];
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    try {
      final index = _findIndex(patient.id);
      if (index != -1) {
        await _box.putAt(index, patient);
        logger.i('Updated patient with id: ${patient.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating patient: $e');
      if (kDebugMode) {
        print('Error updating patient: $e');
      }
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted patient with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting patient: $e');
      if (kDebugMode) {
        print('Error deleting patient: $e');
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
