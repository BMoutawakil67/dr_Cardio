import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/consultation_hours_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class ConsultationHoursRepository {
  final Box<ConsultationHours> _box =
      Hive.box<ConsultationHours>(HiveDatabase.consultationHoursBox);
  final Map<String, int> _indexCache = {};

  ConsultationHoursRepository() {
    _rebuildIndexCache();
    _box.watch().listen((_) => _rebuildIndexCache());
  }

  Future<int> addConsultationHours(ConsultationHours hours) async {
    try {
      final key = await _box.add(hours);
      logger.i('Added consultation hours with key: $key');
      return key;
    } catch (e) {
      logger.e('Error adding consultation hours: $e');
      if (kDebugMode) {
        print('Error adding consultation hours: $e');
      }
      throw HiveError('Failed to add consultation hours.');
    }
  }

  Future<ConsultationHours?> getConsultationHours(String doctorId) async {
    try {
      final hours = _box.values
          .firstWhereOrNull((element) => element.doctorId == doctorId);

      // If no hours found, return default
      if (hours == null) {
        return ConsultationHours.getDefault(doctorId);
      }
      return hours;
    } catch (e) {
      logger.e('Error getting consultation hours: $e');
      if (kDebugMode) {
        print('Error getting consultation hours: $e');
      }
      return ConsultationHours.getDefault(doctorId);
    }
  }

  Future<bool> updateConsultationHours(ConsultationHours hours) async {
    try {
      final index = _findIndex(hours.doctorId);
      if (index != -1) {
        await _box.putAt(index, hours);
        logger.i('Updated consultation hours for doctor: ${hours.doctorId}');
        return true;
      } else {
        // If not found, add as new
        await addConsultationHours(hours);
        return true;
      }
    } catch (e) {
      logger.e('Error updating consultation hours: $e');
      if (kDebugMode) {
        print('Error updating consultation hours: $e');
      }
      return false;
    }
  }

  Future<bool> deleteConsultationHours(String doctorId) async {
    try {
      final index = _findIndex(doctorId);
      if (index != -1) {
        await _box.deleteAt(index);
        logger.i('Deleted consultation hours for doctor: $doctorId');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting consultation hours: $e');
      if (kDebugMode) {
        print('Error deleting consultation hours: $e');
      }
      return false;
    }
  }

  int _findIndex(String doctorId) {
    return _indexCache[doctorId] ?? -1;
  }

  void _rebuildIndexCache() {
    _indexCache.clear();
    final entities = _box.values.toList();
    for (var i = 0; i < entities.length; i++) {
      _indexCache[entities[i].doctorId] = i;
    }
  }
}
