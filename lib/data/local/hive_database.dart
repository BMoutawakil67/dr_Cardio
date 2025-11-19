import 'package:dr_cardio/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/patient_model.dart';
import '../../models/doctor_model.dart';
import '../../models/medical_note_model.dart';

class HiveDatabase {
  static const String patientBox = 'patient';
  static const String doctorBox = 'doctor';
  static const String medicalNoteBox = 'medical_note';

  static Future<void> init() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    Hive.registerAdapter(PatientAdapter());
    Hive.registerAdapter(DoctorAdapter());
    Hive.registerAdapter(MedicalNoteAdapter());

    // Ouvrir les boxes
    await Hive.openBox<Patient>(patientBox);
    await Hive.openBox<Doctor>(doctorBox);
    await Hive.openBox<MedicalNote>(medicalNoteBox);

    logger.i('Hive initialized successfully');
  }

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<void> clearAll() async {
    await Hive.box<Patient>(patientBox).clear();
    await Hive.box<Doctor>(doctorBox).clear();
    await Hive.box<MedicalNote>(medicalNoteBox).clear();
  }
}
