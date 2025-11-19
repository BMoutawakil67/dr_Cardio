import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class MockService {
  static Future<void> generateAndSaveMockData() async {
    try {
      final patientBox = Hive.box<Patient>(HiveDatabase.patientBox);
      if (patientBox.isEmpty) {
        final patients = _generateMockPatients();
        for (var patient in patients) {
          await patientBox.add(patient);
        }
        logger.i('Generated and saved mock patients.');
      }

      final doctorBox = Hive.box<Doctor>(HiveDatabase.doctorBox);
      if (doctorBox.isEmpty) {
        final doctors = _generateMockDoctors();
        for (var doctor in doctors) {
          await doctorBox.add(doctor);
        }
        logger.i('Generated and saved mock doctors.');
      }

      final medicalNoteBox = Hive.box<MedicalNote>(HiveDatabase.medicalNoteBox);
      if (medicalNoteBox.isEmpty) {
        final medicalNotes = _generateMockMedicalNotes();
        for (var note in medicalNotes) {
          await medicalNoteBox.add(note);
        }
        logger.i('Generated and saved mock medical notes.');
      }
    } catch (e) {
      logger.e('Error generating and saving mock data: $e');
      if (kDebugMode) {
        print('Error generating and saving mock data: $e');
      }
      rethrow;
    }
  }

  static List<Patient> _generateMockPatients() {
    return [
      Patient(
        id: 'patient-001',
        firstName: 'Jean',
        lastName: 'Dupont',
        email: 'jean.dupont@example.com',
        phoneNumber: '0123456789',
        address: '123 Rue de la Paix, 75001 Paris',
        birthDate: DateTime(1980, 5, 15),
        gender: 'Homme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-001',
      ),
      Patient(
        id: 'patient-002',
        firstName: 'Marie',
        lastName: 'Curie',
        email: 'marie.curie@example.com',
        phoneNumber: '0987654321',
        address: '456 Avenue des Champs-Élysées, 75008 Paris',
        birthDate: DateTime(1975, 8, 22),
        gender: 'Femme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-002',
      ),
    ];
  }

  static List<Doctor> _generateMockDoctors() {
    return [
      Doctor(
        id: 'doctor-001',
        firstName: 'Alain',
        lastName: 'Martin',
        email: 'alain.martin@example.com',
        phoneNumber: '0123456789',
        specialty: 'Cardiologue',
        address: '789 Boulevard Saint-Germain, 75006 Paris',
        profileImageUrl: 'https://i.pravatar.cc/150?u=doctor-001',
      ),
    ];
  }

  static List<MedicalNote> _generateMockMedicalNotes() {
    return [
      MedicalNote(
        id: 'note-001',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: DateTime.now(),
        systolic: 120,
        diastolic: 80,
        heartRate: 70,
        context: 'Consultation de routine',
        photoUrl: 'https://via.placeholder.com/150',
      ),
      MedicalNote(
        id: 'note-002',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: DateTime.now().subtract(const Duration(days: 30)),
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        context: 'Suivi mensuel',
        photoUrl: 'https://via.placeholder.com/150',
      ),
      MedicalNote(
        id: 'note-003',
        patientId: 'patient-002',
        doctorId: 'doctor-001',
        date: DateTime.now().subtract(const Duration(days: 10)),
        systolic: 140,
        diastolic: 90,
        heartRate: 80,
        context: 'Première consultation',
        photoUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }
}
