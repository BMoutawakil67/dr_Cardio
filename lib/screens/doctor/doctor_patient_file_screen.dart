import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
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

  void _makeCall(BuildContext context) async {
    final patient = await _patientFuture;
    if (patient == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _CallDialog(
        patientName: '${patient.firstName} ${patient.lastName}',
        isVideo: false,
      ),
    );
  }

  void _startVideoCall(BuildContext context) async {
    final patient = await _patientFuture;
    if (patient == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _CallDialog(
        patientName: '${patient.firstName} ${patient.lastName}',
        isVideo: true,
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primaryBlue),
              title: const Text('Télécharger le dossier'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📥 Téléchargement du dossier en cours...'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: AppTheme.primaryBlue),
              title: const Text('Imprimer le dossier'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🖨️ Impression en cours...'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.primaryBlue),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📤 Partage en cours...'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: AppTheme.warningOrange),
              title: const Text('Archiver le patient'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📦 Patient archivé'),
                    backgroundColor: AppTheme.warningOrange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Call Dialog Widget
class _CallDialog extends StatefulWidget {
  final String patientName;
  final bool isVideo;

  const _CallDialog({
    required this.patientName,
    required this.isVideo,
  });

  @override
  State<_CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<_CallDialog> {
  String _callStatus = 'connecting';
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    _simulateCall();
  }

  Future<void> _simulateCall() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _callStatus = 'connected';
      });
    }
  }

  void _endCall() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isVideo
            ? '📹 Appel vidéo terminé'
            : '📞 Appel audio terminé'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isVideo ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isVideo) ...[
              // Simulated video call interface
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam,
                            size: 80,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _callStatus == 'connecting'
                                ? 'Connexion...'
                                : 'Appel vidéo actif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Small self-view in corner
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Audio call interface
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryBlue,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              widget.patientName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isVideo ? Colors.white : AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _callStatus == 'connecting'
                  ? 'Connexion en cours...'
                  : 'En cours...',
              style: TextStyle(
                fontSize: 16,
                color: widget.isVideo
                    ? Colors.white70
                    : AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 32),
            // Call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: 'Muet',
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                  backgroundColor: _isMuted ? AppTheme.errorRed : null,
                ),
                _buildCallButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: 'Haut-parleur',
                  onPressed: () {
                    setState(() {
                      _isSpeakerOn = !_isSpeakerOn;
                    });
                  },
                  backgroundColor: _isSpeakerOn ? AppTheme.primaryBlue : null,
                ),
                _buildCallButton(
                  icon: Icons.call_end,
                  label: 'Raccrocher',
                  onPressed: _endCall,
                  backgroundColor: AppTheme.errorRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    final buttonColor = backgroundColor ??
        (widget.isVideo ? Colors.grey.shade700 : Colors.grey.shade200);
    final iconColor = widget.isVideo ? Colors.white : AppTheme.textColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: buttonColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: widget.isVideo ? Colors.white70 : AppTheme.greyMedium,
          ),
        ),
      ],
    );
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
