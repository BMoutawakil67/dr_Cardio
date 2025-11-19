import 'dart:convert';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DoctorPatientFileScreen extends StatefulWidget {
  const DoctorPatientFileScreen({super.key});

  @override
  State<DoctorPatientFileScreen> createState() =>
      _DoctorPatientFileScreenState();
}

class _DoctorPatientFileScreenState extends State<DoctorPatientFileScreen> {
  final MedicalNoteRepository _medicalNoteRepository = MedicalNoteRepository();
  final PatientRepository _patientRepository = PatientRepository();

  late Future<Patient?> _patientFuture;
  late Future<List<MedicalNote>> _medicalNotesFuture;
  String? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('patientId')) {
      _patientId = args['patientId'];
      if (_patientId != null) {
        _patientFuture = _patientRepository.getPatient(_patientId!);
        _medicalNotesFuture =
            _medicalNoteRepository.getMedicalNotesByPatient(_patientId!);
      }
    } else {
      _patientFuture = Future.value(null);
      _medicalNotesFuture = Future.value([]);
    }
  }

  Future<void> _refreshNotes() {
    if (_patientId != null) {
      setState(() {
        _medicalNotesFuture =
            _medicalNoteRepository.getMedicalNotesByPatient(_patientId!);
      });
    }
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Patient?>(
      future: _patientFuture,
      builder: (context, patientSnapshot) {
        if (patientSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (patientSnapshot.hasError ||
            !patientSnapshot.hasData ||
            patientSnapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Patient non trouvé')),
            body: const Center(
              child: Text('Impossible de charger les données du patient.'),
            ),
          );
        }

        final patient = patientSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text('${patient.firstName} ${patient.lastName}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => _sendMessage(context),
              ),
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () => _makeCall(context),
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () => _startVideoCall(context),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshNotes,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfo(patient),
                  const Divider(height: 1, thickness: 1),
                  _buildMedicalNotesSection(),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addNote(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildPatientInfo(Patient patient) {
    final age =
        (DateTime.now().difference(patient.birthDate).inDays / 365).floor();
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👤', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Informations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${patient.gender}, $age ans'),
          const SizedBox(height: 4),
          Text('📧 ${patient.email}'),
          const SizedBox(height: 4),
          Text('📱 ${patient.phoneNumber}'),
        ],
      ),
    );
  }

  Widget _buildMedicalNotesSection() {
    return FutureBuilder<List<MedicalNote>>(
      future: _medicalNotesFuture,
      builder: (context, notesSnapshot) {
        if (notesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notesSnapshot.hasError) {
          return const Center(
            child: Text('Erreur de chargement des notes médicales.'),
          );
        }
        if (!notesSnapshot.hasData || notesSnapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 Notes Médicales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                SizedBox(height: 16),
                Center(child: Text('Aucune note médicale.')),
              ],
            ),
          );
        }

        final medicalNotes = notesSnapshot.data!;

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📝 Notes Médicales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              ...medicalNotes.map((note) => _NoteCard(
                    note: note,
                    onEdit: () => _editNote(context, note),
                    onDelete: () => _deleteNote(context, note.id),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _addNote(BuildContext context) {
    _showNoteDialog(context);
  }

  void _editNote(BuildContext context, MedicalNote note) {
    _showNoteDialog(context, noteToEdit: note);
  }

  Future<void> _deleteNote(BuildContext context, String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _medicalNoteRepository.deleteMedicalNote(noteId);
      _refreshNotes();
    }
  }

  void _showNoteDialog(BuildContext context, {MedicalNote? noteToEdit}) {
    final systolicController = TextEditingController(
      text: noteToEdit?.systolic.toString() ?? '',
    );
    final diastolicController = TextEditingController(
      text: noteToEdit?.diastolic.toString() ?? '',
    );
    final heartRateController = TextEditingController(
      text: noteToEdit?.heartRate.toString() ?? '',
    );
    final contextController = TextEditingController(
      text: noteToEdit?.context ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(noteToEdit == null ? 'Ajouter une note' : 'Modifier la note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: systolicController,
                decoration: const InputDecoration(labelText: 'Systolique'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diastolicController,
                decoration: const InputDecoration(labelText: 'Diastolique'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heartRateController,
                decoration:
                    const InputDecoration(labelText: 'Fréquence cardiaque'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: contextController,
                decoration: const InputDecoration(labelText: 'Contexte'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_patientId == null) return;
              final newNote = MedicalNote(
                id: noteToEdit?.id ?? const Uuid().v4(),
                patientId: _patientId!,
                doctorId: 'doctor-001', // TODO: Get current doctor ID
                date: DateTime.now(),
                systolic: int.parse(systolicController.text),
                diastolic: int.parse(diastolicController.text),
                heartRate: int.parse(heartRateController.text),
                context: contextController.text,
              );

              if (noteToEdit == null) {
                await _medicalNoteRepository.addMedicalNote(newNote);
              } else {
                await _medicalNoteRepository.updateMedicalNote(newNote);
              }

              Navigator.pop(context);
              _refreshNotes();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.doctorChat);
  }

  void _makeCall(BuildContext context) {
    // TODO: Implement
  }

  void _startVideoCall(BuildContext context) {
    // TODO: Implement
  }

  void _showMoreOptions(BuildContext context) {
    // TODO: Implement
  }
}

class _NoteCard extends StatelessWidget {
  final MedicalNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${note.date.day}/${note.date.month}/${note.date.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tension: ${note.systolic}/${note.diastolic} mmHg'),
            Text('Fréquence cardiaque: ${note.heartRate} bpm'),
            if (note.context.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Contexte: ${note.context}'),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
