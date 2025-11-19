import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class DoctorRepository {
  final Box<Doctor> _box = Hive.box<Doctor>(HiveDatabase.doctorBox);
  final Map<String, int> _indexCache = {};

  DoctorRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addDoctor(Doctor doctor) async {
    try {
      final key = await _box.add(doctor);
      logger.i('Added doctor with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding doctor: $e');
      if (kDebugMode) {
        print('Error adding doctor: $e');
      }
      throw HiveError('Failed to add doctor.');
    }
  }

  Future<Doctor?> getDoctor(String id) async {
    try {
      return _box.values.firstWhereOrNull((element) => element.id == id);
    } catch (e) {
      logger.e('Error getting doctor: $e');
      if (kDebugMode) {
        print('Error getting doctor: $e');
      }
      return null;
    }
  }

  Future<List<Doctor>> getAllDoctors() async {
    try {
      return _box.values.toList();
    } catch (e) {
      logger.e('Error getting all doctors: $e');
      if (kDebugMode) {
        print('Error getting all doctors: $e');
      }
      return [];
    }
  }

  Future<bool> updateDoctor(Doctor doctor) async {
    try {
      final index = _findIndex(doctor.id);
      if (index != -1) {
        await _box.putAt(index, doctor);
        logger.i('Updated doctor with id: ${doctor.id}');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error updating doctor: $e');
      if (kDebugMode) {
        print('Error updating doctor: $e');
      }
      return false;
    }
  }

  Future<bool> deleteDoctor(String id) async {
    try {
      final index = _findIndex(id);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted doctor with id: $id');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting doctor: $e');
      if (kDebugMode) {
        print('Error deleting doctor: $e');
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
