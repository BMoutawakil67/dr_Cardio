import 'package:dr_cardio/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/patient_model.dart';
import '../../models/doctor_model.dart';
import '../../models/medical_note_model.dart';
import '../../models/message_model.dart';
import '../../models/conversation_model.dart';
import '../../models/medication_model.dart';
import '../../models/consultation_hours_model.dart';

class HiveDatabase {
  static const String patientBox = 'patient';
  static const String doctorBox = 'doctor';
  static const String medicalNoteBox = 'medical_note';
  static const String messageBox = 'message';
  static const String conversationBox = 'conversation';
  static const String medicationBox = 'medication';
  static const String consultationHoursBox = 'consultation_hours';

  static Future<void> init() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    Hive.registerAdapter(PatientAdapter());
    Hive.registerAdapter(DoctorAdapter());
    Hive.registerAdapter(MedicalNoteAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(ConsultationHoursAdapter());
    Hive.registerAdapter(DayScheduleAdapter());

    // Ouvrir les boxes
    await Hive.openBox<Patient>(patientBox);
    await Hive.openBox<Doctor>(doctorBox);
    await Hive.openBox<MedicalNote>(medicalNoteBox);
    await Hive.openBox<Message>(messageBox);
    await Hive.openBox<Conversation>(conversationBox);
    await Hive.openBox<Medication>(medicationBox);
    await Hive.openBox<ConsultationHours>(consultationHoursBox);

    logger.i('Hive initialized successfully');
  }

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<void> clearAll() async {
    await Hive.box<Patient>(patientBox).clear();
    await Hive.box<Doctor>(doctorBox).clear();
    await Hive.box<MedicalNote>(medicalNoteBox).clear();
    await Hive.box<Message>(messageBox).clear();
    await Hive.box<Conversation>(conversationBox).clear();
    await Hive.box<Medication>(medicationBox).clear();
    await Hive.box<ConsultationHours>(consultationHoursBox).clear();
  }
}
