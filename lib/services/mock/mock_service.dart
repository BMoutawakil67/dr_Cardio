import 'dart:math';

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

      final conversationBox =
          Hive.box<Conversation>(HiveDatabase.conversationBox);
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
      Patient(
        id: 'patient-003',
        firstName: 'Pierre',
        lastName: 'Martin',
        email: 'pierre.martin@example.com',
        phoneNumber: '+225 07 08 09 10 11',
        address: 'Cocody Angré, Abidjan, Côte d\'Ivoire',
        birthDate: DateTime(1965, 3, 10),
        gender: 'Homme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-003',
      ),
      Patient(
        id: 'patient-004',
        firstName: 'Fatou',
        lastName: 'Traoré',
        email: 'fatou.traore@example.com',
        phoneNumber: '+225 05 06 07 08 09',
        address: 'Marcory Zone 4, Abidjan, Côte d\'Ivoire',
        birthDate: DateTime(1990, 11, 25),
        gender: 'Femme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-004',
      ),
      Patient(
        id: 'patient-005',
        firstName: 'Amadou',
        lastName: 'Koné',
        email: 'amadou.kone@example.com',
        phoneNumber: '+225 01 02 03 04 05',
        address: 'Plateau, Abidjan, Côte d\'Ivoire',
        birthDate: DateTime(1972, 7, 18),
        gender: 'Homme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-005',
      ),
      Patient(
        id: 'patient-006',
        firstName: 'Aïcha',
        lastName: 'Diallo',
        email: 'aicha.diallo@example.com',
        phoneNumber: '+225 09 10 11 12 13',
        address: 'Yopougon, Abidjan, Côte d\'Ivoire',
        birthDate: DateTime(1985, 12, 5),
        gender: 'Femme',
        profileImageUrl: 'https://i.pravatar.cc/150?u=patient-006',
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
        phoneNumber: '+225 07 08 09 10 11',
        specialty: 'Cardiologue',
        address: 'Clinique du Coeur, Cocody, Abidjan',
        profileImageUrl: 'https://i.pravatar.cc/150?u=doctor-001',
      ),
      Doctor(
        id: 'doctor-002',
        firstName: 'Sophie',
        lastName: 'Kouassi',
        email: 'sophie.kouassi@example.com',
        phoneNumber: '+225 05 06 07 08 09',
        specialty: 'Cardiologue',
        address: 'Centre Médical Excellence, Plateau, Abidjan',
        profileImageUrl: 'https://i.pravatar.cc/150?u=doctor-002',
      ),
      Doctor(
        id: 'doctor-003',
        firstName: 'Ibrahim',
        lastName: 'Touré',
        email: 'ibrahim.toure@example.com',
        phoneNumber: '+225 01 02 03 04 05',
        specialty: 'Cardiologue',
        address: 'Hôpital Général, Marcory, Abidjan',
        profileImageUrl: 'https://i.pravatar.cc/150?u=doctor-003',
      ),
    ];
  }

  static List<MedicalNote> _generateMockMedicalNotes() {
    final now = DateTime.now();
    final random = Random();

    return [
      // Patient 001 - Multiple mesures
      MedicalNote(
        id: 'note-001',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: now,
        systolic: 120 + random.nextInt(20),
        diastolic: 80 + random.nextInt(10),
        heartRate: 70 + random.nextInt(10),
        context: 'Prise matin à jeun',
      ),
      MedicalNote(
        id: 'note-002',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 1)),
        systolic: 130 + random.nextInt(15),
        diastolic: 90 + random.nextInt(10),
        heartRate: 75 + random.nextInt(10),
        context: 'Après exercice',
      ),
      MedicalNote(
        id: 'note-003',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 3)),
        systolic: 180 + random.nextInt(20),
        diastolic: 120 + random.nextInt(10),
        heartRate: 80 + random.nextInt(15),
        context: 'Médicaments: Amlodipine 5mg',
      ),
      MedicalNote(
        id: 'note-004',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 7)),
        systolic: 140 + random.nextInt(20),
        diastolic: 90 + random.nextInt(10),
        heartRate: 90 + random.nextInt(10),
        context: 'Stress au travail',
      ),
      MedicalNote(
        id: 'note-005',
        patientId: 'patient-001',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 14)),
        systolic: 125 + random.nextInt(10),
        diastolic: 85 + random.nextInt(5),
        heartRate: 82 + random.nextInt(8),
        context: 'Consultation de routine',
      ),

      // Patient 002
      MedicalNote(
        id: 'note-006',
        patientId: 'patient-002',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(hours: 12)),
        systolic: 110 + random.nextInt(10),
        diastolic: 70 + random.nextInt(10),
        heartRate: 65 + random.nextInt(5),
        context: 'Prise du soir',
      ),
      MedicalNote(
        id: 'note-007',
        patientId: 'patient-002',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 2)),
        systolic: 120 + random.nextInt(10),
        diastolic: 80 + random.nextInt(5),
        heartRate: 68 + random.nextInt(5),
        context: 'Mesure normale',
      ),
      MedicalNote(
        id: 'note-008',
        patientId: 'patient-002',
        doctorId: 'doctor-001',
        date: now.subtract(const Duration(days: 5)),
        systolic: 130 + random.nextInt(10),
        diastolic: 80 + random.nextInt(5),
        heartRate: 70 + random.nextInt(5),
        context: 'Après repas',
      ),

      // Patient 003
      MedicalNote(
        id: 'note-009',
        patientId: 'patient-003',
        doctorId: 'doctor-002',
        date: now.subtract(const Duration(hours: 6)),
        systolic: 170 + random.nextInt(10),
        diastolic: 110 + random.nextInt(10),
        heartRate: 85 + random.nextInt(5),
        context: 'Hypertension détectée',
      ),
      MedicalNote(
        id: 'note-010',
        patientId: 'patient-003',
        doctorId: 'doctor-002',
        date: now.subtract(const Duration(days: 1)),
        systolic: 180 + random.nextInt(10),
        diastolic: 120 + random.nextInt(5),
        heartRate: 88 + random.nextInt(5),
        context: 'Médicaments: Enalapril 10mg',
      ),
      MedicalNote(
        id: 'note-011',
        patientId: 'patient-003',
        doctorId: 'doctor-002',
        date: now.subtract(const Duration(days: 4)),
        systolic: 160 + random.nextInt(10),
        diastolic: 100 + random.nextInt(10),
        heartRate: 80 + random.nextInt(5),
        context: 'Amélioration après traitement',
      ),

      // Patient 004
      MedicalNote(
        id: 'note-012',
        patientId: 'patient-004',
        doctorId: 'doctor-002',
        date: now.subtract(const Duration(hours: 18)),
        systolic: 100 + random.nextInt(10),
        diastolic: 70 + random.nextInt(5),
        heartRate: 62 + random.nextInt(5),
        context: 'Tension normale',
      ),
      MedicalNote(
        id: 'note-013',
        patientId: 'patient-004',
        doctorId: 'doctor-002',
        date: now.subtract(const Duration(days: 3)),
        systolic: 110 + random.nextInt(10),
        diastolic: 70 + random.nextInt(5),
        heartRate: 64 + random.nextInt(5),
        context: 'Prise matin',
      ),

      // Patient 005
      MedicalNote(
        id: 'note-014',
        patientId: 'patient-005',
        doctorId: 'doctor-003',
        date: now,
        systolic: 140 + random.nextInt(10),
        diastolic: 90 + random.nextInt(5),
        heartRate: 74 + random.nextInt(5),
        context: 'Consultation de suivi',
      ),
      MedicalNote(
        id: 'note-015',
        patientId: 'patient-005',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(days: 2)),
        systolic: 150 + random.nextInt(10),
        diastolic: 100 + random.nextInt(5),
        heartRate: 76 + random.nextInt(5),
        context: 'Activité physique modérée',
      ),
      MedicalNote(
        id: 'note-016',
        patientId: 'patient-005',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(days: 6)),
        systolic: 140 + random.nextInt(10),
        diastolic: 90 + random.nextInt(5),
        heartRate: 72 + random.nextInt(5),
        context: 'Médicaments: Losartan 50mg',
      ),

      // Patient 006
      MedicalNote(
        id: 'note-017',
        patientId: 'patient-006',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(hours: 8)),
        systolic: 130 + random.nextInt(10),
        diastolic: 80 + random.nextInt(5),
        heartRate: 69 + random.nextInt(5),
        context: 'Prise après réveil',
      ),
      MedicalNote(
        id: 'note-018',
        patientId: 'patient-006',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(days: 1)),
        systolic: 120 + random.nextInt(10),
        diastolic: 80 + random.nextInt(5),
        heartRate: 68 + random.nextInt(5),
        context: 'Tension stable',
      ),
      MedicalNote(
        id: 'note-019',
        patientId: 'patient-006',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(days: 4)),
        systolic: 140 + random.nextInt(10),
        diastolic: 90 + random.nextInt(5),
        heartRate: 71 + random.nextInt(5),
        context: 'Après activité physique',
      ),
      MedicalNote(
        id: 'note-020',
        patientId: 'patient-006',
        doctorId: 'doctor-003',
        date: now.subtract(const Duration(days: 8)),
        systolic: 130 + random.nextInt(10),
        diastolic: 80 + random.nextInt(5),
        heartRate: 70 + random.nextInt(5),
        context: 'Première mesure',
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
      // Conversation between patient-003 and doctor-001
      Conversation(
        id: 'conv-003',
        patientId: 'patient-003',
        doctorId: 'doctor-001',
        lastMessage: 'Rdv confirmé pour demain à 10h',
        lastMessageTime: now.subtract(const Duration(hours: 5)),
        unreadCount: 2,
        isSystem: false,
      ),
      // Conversation between patient-004 and doctor-001
      Conversation(
        id: 'conv-004',
        patientId: 'patient-004',
        doctorId: 'doctor-001',
        lastMessage: 'J\'ai une question sur mon traitement',
        lastMessageTime: now.subtract(const Duration(hours: 12)),
        unreadCount: 1,
        isSystem: false,
      ),
      // Conversation between patient-005 and doctor-001
      Conversation(
        id: 'conv-005',
        patientId: 'patient-005',
        doctorId: 'doctor-001',
        lastMessage: 'Ma tension est à 14/9 ce matin',
        lastMessageTime: now.subtract(const Duration(hours: 4)),
        unreadCount: 0,
        isSystem: false,
      ),
      // Conversation between patient-006 and doctor-001
      Conversation(
        id: 'conv-006',
        patientId: 'patient-006',
        doctorId: 'doctor-001',
        lastMessage: 'Merci docteur pour vos conseils',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        isSystem: false,
      ),
      // Conversation between patient-001 and doctor-002
      Conversation(
        id: 'conv-007',
        patientId: 'patient-001',
        doctorId: 'doctor-002',
        lastMessage: 'Votre ordonnance est prête',
        lastMessageTime: now.subtract(const Duration(days: 3)),
        unreadCount: 0,
        isSystem: false,
      ),
      // Conversation between patient-003 and doctor-002
      Conversation(
        id: 'conv-008',
        patientId: 'patient-003',
        doctorId: 'doctor-002',
        lastMessage: 'Les résultats sont bons !',
        lastMessageTime: now.subtract(const Duration(hours: 8)),
        unreadCount: 1,
        isSystem: false,
      ),
      // Conversation between patient-005 and doctor-002
      Conversation(
        id: 'conv-009',
        patientId: 'patient-005',
        doctorId: 'doctor-002',
        lastMessage: 'Continuez votre traitement actuel',
        lastMessageTime: now.subtract(const Duration(days: 1, hours: 6)),
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
        text:
            'Bonjour Jean, c\'est un peu élevé. Avez-vous bien pris vos médicaments?',
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

      // Messages for conv-003 (patient-003 and doctor-001)
      Message(
        id: 'msg-011',
        conversationId: 'conv-003',
        senderId: 'patient-003',
        receiverId: 'doctor-001',
        text: 'Bonjour Docteur, j\'aimerais prendre rendez-vous',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      Message(
        id: 'msg-012',
        conversationId: 'conv-003',
        senderId: 'doctor-001',
        receiverId: 'patient-003',
        text: 'Bonjour Pierre, je peux vous recevoir demain à 10h',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg-013',
        conversationId: 'conv-003',
        senderId: 'patient-003',
        receiverId: 'doctor-001',
        text: 'Parfait, merci !',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 10)),
        isRead: false,
      ),
      Message(
        id: 'msg-014',
        conversationId: 'conv-003',
        senderId: 'doctor-001',
        receiverId: 'patient-003',
        text: 'Rdv confirmé pour demain à 10h',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),

      // Messages for conv-004 (patient-004 and doctor-001)
      Message(
        id: 'msg-015',
        conversationId: 'conv-004',
        senderId: 'patient-004',
        receiverId: 'doctor-001',
        text: 'Bonjour Docteur',
        timestamp: now.subtract(const Duration(hours: 12, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg-016',
        conversationId: 'conv-004',
        senderId: 'patient-004',
        receiverId: 'doctor-001',
        text: 'J\'ai une question sur mon traitement',
        timestamp: now.subtract(const Duration(hours: 12)),
        isRead: false,
      ),

      // Messages for conv-005 (patient-005 and doctor-001)
      Message(
        id: 'msg-017',
        conversationId: 'conv-005',
        senderId: 'patient-005',
        receiverId: 'doctor-001',
        text: 'Ma tension est à 14/9 ce matin',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      Message(
        id: 'msg-018',
        conversationId: 'conv-005',
        senderId: 'doctor-001',
        receiverId: 'patient-005',
        text: 'C\'est bien Amadou, votre tension se stabilise',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg-019',
        conversationId: 'conv-005',
        senderId: 'patient-005',
        receiverId: 'doctor-001',
        text: 'Dois-je continuer le même traitement ?',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg-020',
        conversationId: 'conv-005',
        senderId: 'doctor-001',
        receiverId: 'patient-005',
        text: 'Oui, ne changez rien pour le moment',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),

      // Messages for conv-006 (patient-006 and doctor-001)
      Message(
        id: 'msg-021',
        conversationId: 'conv-006',
        senderId: 'doctor-001',
        receiverId: 'patient-006',
        text:
            'Bonjour Aïcha, n\'oubliez pas de prendre vos médicaments régulièrement',
        timestamp: now.subtract(const Duration(days: 2, hours: 10)),
        isRead: true,
      ),
      Message(
        id: 'msg-022',
        conversationId: 'conv-006',
        senderId: 'patient-006',
        receiverId: 'doctor-001',
        text: 'Oui Docteur, je les prends tous les matins',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        isRead: true,
      ),
      Message(
        id: 'msg-023',
        conversationId: 'conv-006',
        senderId: 'patient-006',
        receiverId: 'doctor-001',
        text: 'Merci docteur pour vos conseils',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),

      // Messages for conv-007 (patient-001 and doctor-002)
      Message(
        id: 'msg-024',
        conversationId: 'conv-007',
        senderId: 'patient-001',
        receiverId: 'doctor-002',
        text: 'Bonjour Docteur, puis-je avoir mon ordonnance ?',
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        isRead: true,
      ),
      Message(
        id: 'msg-025',
        conversationId: 'conv-007',
        senderId: 'doctor-002',
        receiverId: 'patient-001',
        text: 'Votre ordonnance est prête',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),

      // Messages for conv-008 (patient-003 and doctor-002)
      Message(
        id: 'msg-026',
        conversationId: 'conv-008',
        senderId: 'patient-003',
        receiverId: 'doctor-002',
        text: 'Voici mes derniers résultats d\'analyses',
        timestamp: now.subtract(const Duration(hours: 9)),
        isRead: true,
        attachmentType: 'document',
      ),
      Message(
        id: 'msg-027',
        conversationId: 'conv-008',
        senderId: 'doctor-002',
        receiverId: 'patient-003',
        text: 'Les résultats sont bons !',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: false,
      ),

      // Messages for conv-009 (patient-005 and doctor-002)
      Message(
        id: 'msg-028',
        conversationId: 'conv-009',
        senderId: 'patient-005',
        receiverId: 'doctor-002',
        text: 'Je me sens beaucoup mieux avec le nouveau traitement',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        isRead: true,
      ),
      Message(
        id: 'msg-029',
        conversationId: 'conv-009',
        senderId: 'doctor-002',
        receiverId: 'patient-005',
        text: 'Excellente nouvelle !',
        timestamp: now.subtract(const Duration(days: 1, hours: 6, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg-030',
        conversationId: 'conv-009',
        senderId: 'doctor-002',
        receiverId: 'patient-005',
        text: 'Continuez votre traitement actuel',
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
      ),
    ];
  }
}
