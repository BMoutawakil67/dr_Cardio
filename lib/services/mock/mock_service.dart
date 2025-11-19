import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/models/message_model.dart';
import 'package:dr_cardio/models/conversation_model.dart';
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

      final conversationBox = Hive.box<Conversation>(HiveDatabase.conversationBox);
      if (conversationBox.isEmpty) {
        final conversations = _generateMockConversations();
        for (var conversation in conversations) {
          await conversationBox.add(conversation);
        }
        logger.i('Generated and saved mock conversations.');
      }

      final messageBox = Hive.box<Message>(HiveDatabase.messageBox);
      if (messageBox.isEmpty) {
        final messages = _generateMockMessages();
        for (var message in messages) {
          await messageBox.add(message);
        }
        logger.i('Generated and saved mock messages.');
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

  static List<Conversation> _generateMockConversations() {
    final now = DateTime.now();

    return [
      // Conversation between patient-001 and doctor-001
      Conversation(
        id: 'conv-001',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        lastMessage: 'Votre tension est bonne, continuez ainsi...',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 1,
        isSystem: false,
      ),
      // System conversation for patient-001
      Conversation(
        id: 'conv-system-001',
        patientId: 'patient-001',
        doctorId: 'system',
        lastMessage: 'N\'oubliez pas votre mesure du soir',
        lastMessageTime: now.subtract(const Duration(hours: 10)),
        unreadCount: 0,
        isSystem: true,
      ),
      // Conversation between patient-002 and doctor-001
      Conversation(
        id: 'conv-002',
        patientId: 'patient-002',
        doctorId: 'doctor-001',
        lastMessage: 'Merci pour votre dernière mesure',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isSystem: false,
      ),
    ];
  }

  static List<Message> _generateMockMessages() {
    final now = DateTime.now();

    return [
      // Messages for conversation conv-001 (patient-001 and doctor-001)
      Message(
        id: 'msg-001',
        conversationId: 'conv-001',
        senderId: 'patient-001',
        receiverId: 'doctor-001',
        text: 'Bonjour Docteur, j\'ai mesuré 16/10 ce matin',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg-002',
        conversationId: 'conv-001',
        senderId: 'doctor-001',
        receiverId: 'patient-001',
        text: 'Bonjour Jean, c\'est un peu élevé. Avez-vous bien pris vos médicaments?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 57)),
        isRead: true,
      ),
      Message(
        id: 'msg-003',
        conversationId: 'conv-001',
        senderId: 'patient-001',
        receiverId: 'doctor-001',
        text: 'Oui, ce matin comme d\'habitude',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 56)),
        isRead: true,
      ),
      Message(
        id: 'msg-004',
        conversationId: 'conv-001',
        senderId: 'patient-001',
        receiverId: 'doctor-001',
        text: 'Voici la photo de mon tensiomètre',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 55)),
        isRead: true,
        attachmentType: 'image',
      ),
      Message(
        id: 'msg-005',
        conversationId: 'conv-001',
        senderId: 'doctor-001',
        receiverId: 'patient-001',
        text: 'Parfait. Essayez de vous reposer et reprenez une mesure ce soir',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 50)),
        isRead: true,
      ),
      Message(
        id: 'msg-006',
        conversationId: 'conv-001',
        senderId: 'doctor-001',
        receiverId: 'patient-001',
        text: 'Votre tension est bonne, continuez ainsi...',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),

      // Messages for conversation conv-002 (patient-002 and doctor-001)
      Message(
        id: 'msg-007',
        conversationId: 'conv-002',
        senderId: 'doctor-001',
        receiverId: 'patient-002',
        text: 'Bonjour Marie, comment allez-vous?',
        timestamp: now.subtract(const Duration(days: 1, hours: 10)),
        isRead: true,
      ),
      Message(
        id: 'msg-008',
        conversationId: 'conv-002',
        senderId: 'patient-002',
        receiverId: 'doctor-001',
        text: 'Bonjour Docteur, je vais bien merci',
        timestamp: now.subtract(const Duration(days: 1, hours: 9)),
        isRead: true,
      ),
      Message(
        id: 'msg-009',
        conversationId: 'conv-002',
        senderId: 'doctor-001',
        receiverId: 'patient-002',
        text: 'Merci pour votre dernière mesure',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),

      // System message for patient-001
      Message(
        id: 'msg-010',
        conversationId: 'conv-system-001',
        senderId: 'system',
        receiverId: 'patient-001',
        text: 'N\'oubliez pas votre mesure du soir',
        timestamp: now.subtract(const Duration(hours: 10)),
        isRead: true,
      ),
    ];
  }
}
