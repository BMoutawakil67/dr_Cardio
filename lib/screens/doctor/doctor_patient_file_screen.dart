import 'dart:convert';
import 'package:dr_cardio/models/medical_note_model.dart';
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
  List<MedicalNote> _medicalNotes = [];
  final String _patientId = "patient123"; // Example patient ID

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('medical_notes_$_patientId');
    if (notesJson != null) {
      final notesList = json.decode(notesJson) as List;
      setState(() {
        _medicalNotes =
            notesList.map((note) => MedicalNote.fromMap(note)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final patientName = args['patientName'] ?? 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: Text(patientName),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du patient
            Container(
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
                  const Text('Homme, 45 ans'),
                  const SizedBox(height: 4),
                  const Text('📧 jean.dupont@email.com'),
                  const SizedBox(height: 4),
                  const Text('📱 +229 XX XX XX XX'),
                  const SizedBox(height: 4),
                  Text(
                    '📅 Patient depuis: 3 mois',
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Alerte active
            Container(
              width: double.infinity,
              color: AppTheme.secondaryRed.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🚨', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'ALERTE ACTIVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.secondaryRed.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('🔴', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 8),
                            Text(
                              'Tension élevée',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '18 / 11    💓 85 bpm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Il y a 15 minutes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _contactPatient(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryRed,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('CONTACTER'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _addNote(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppTheme.secondaryRed),
                                  foregroundColor: AppTheme.secondaryRed,
                                ),
                                child: const Text('NOTER'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Dernières mesures (7j)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Dernières mesures (7j)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '[Graphique interactif]',
                        style: TextStyle(color: AppTheme.greyMedium),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tendance: ↗ En hausse',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.warningOrange,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Moyenne: 15/10',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.patientFullHistory,
                            arguments: {'patientName': patientName},
                          );
                        },
                        child: const Text('Voir détails >'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Traitement actuel
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💊 Traitement actuel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('• Losartan 50mg (2x/j)'),
                  const SizedBox(height: 4),
                  const Text('• Amlodipine 5mg (1x/j)'),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _modifyPrescription(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier ordonnance'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Documents
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📄 Documents (4)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentItem('ECG - 15 Oct'),
                  _buildDocumentItem('MAPA - 10 Oct'),
                  _buildDocumentItem('Bilan sanguin - 5 Oct'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _viewAllDocuments(context),
                    child: const Text('Voir tous'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Notes médicales
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 Notes médicales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _addNote(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une note'),
                  ),
                  const SizedBox(height: 16),
                  _buildNotesList(),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Boutons d'action principaux
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.patientFullHistory,
                          arguments: {'patientName': patientName},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        '📊 HISTORIQUE COMPLET',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _sendMessage(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text(
                        '💬 ENVOYER MESSAGE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.description, size: 16, color: AppTheme.greyMedium),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.doctorChat);
  }

  void _makeCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appel téléphonique'),
        content: const Text('Voulez-vous appeler ce patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Lancer l'appel
            },
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visioconférence'),
        content: const Text('Démarrer une téléconsultation avec ce patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.teleconsultation);
            },
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier les informations'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Modifier les informations
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Désactiver les alertes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Gérer les alertes
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archiver le dossier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archiver
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.person_remove, color: AppTheme.secondaryRed),
              title: const Text(
                'Retirer de mes patients',
                style: TextStyle(color: AppTheme.secondaryRed),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Confirmer retrait
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactPatient(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appel téléphonique'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Envoyer un message'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Visioconférence'),
              onTap: () {
                Navigator.pop(context);
                _startVideoCall(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNote(BuildContext context, {MedicalNote? note}) {
    // Refactored to work with the new MedicalNote schema
    // The new schema uses systolic, diastolic, heartRate, context

    final formKey = GlobalKey<FormState>();
    final systolicController = TextEditingController(text: note?.systolic.toString() ?? '');
    final diastolicController = TextEditingController(text: note?.diastolic.toString() ?? '');
    final heartRateController = TextEditingController(text: note?.heartRate.toString() ?? '');
    final contextController = TextEditingController(text: note?.context ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            note == null ? 'Ajouter une mesure' : 'Modifier la mesure'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: systolicController,
                decoration: const InputDecoration(
                  labelText: 'Systolique (mmHg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la pression systolique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: diastolicController,
                decoration: const InputDecoration(
                  labelText: 'Diastolique (mmHg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la pression diastolique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: heartRateController,
                decoration: const InputDecoration(
                  labelText: 'Fréquence cardiaque (bpm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la fréquence cardiaque';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contextController,
                decoration: const InputDecoration(
                  labelText: 'Contexte',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newNote = MedicalNote(
                  id: note?.id ?? const Uuid().v4(),
                  patientId: _patientId,
                  doctorId: 'doctor456', // Example doctor ID
                  date: note?.date ?? DateTime.now(),
                  systolic: int.parse(systolicController.text),
                  diastolic: int.parse(diastolicController.text),
                  heartRate: int.parse(heartRateController.text),
                  context: contextController.text.isEmpty ? 'Consultation' : contextController.text,
                  photoUrl: note?.photoUrl,
                );
                _saveNote(newNote);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote(MedicalNote note) async {
    // Check if note already exists (edit mode)
    final existingIndex = _medicalNotes.indexWhere((n) => n.id == note.id);

    if (existingIndex != -1) {
      // Update existing note
      _medicalNotes[existingIndex] = note;
    } else {
      // Add new note
      _medicalNotes.add(note);
    }

    final prefs = await SharedPreferences.getInstance();
    final notesJson =
        json.encode(_medicalNotes.map((note) => note.toMap()).toList());
    await prefs.setString('medical_notes_$_patientId', notesJson);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existingIndex != -1 ? 'Note modifiée avec succès' : 'Note ajoutée avec succès'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _modifyPrescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'ordonnance'),
        content: const Text(
          'Cette fonctionnalité permet de modifier le traitement du patient. Elle nécessite une signature électronique sécurisée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Interface de modification d'ordonnance
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _viewAllDocuments(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.patientDocuments);
  }

  Widget _buildNotesList() {
    if (_medicalNotes.isEmpty) {
      return const Text('Aucune note pour le moment.');
    }
    _medicalNotes.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicalNotes.length,
      itemBuilder: (context, index) {
        final note = _medicalNotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${note.systolic}/${note.diastolic} mmHg - ${note.heartRate} bpm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${note.date.day}/${note.date.month}/${note.date.year}',
                  style:
                      const TextStyle(color: AppTheme.greyMedium, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  note.context,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => _viewNote(note),
                        child: const Text('Voir')),
                    TextButton(
                        onPressed: () => _editNote(note),
                        child: const Text('Modifier')),
                    TextButton(
                      onPressed: () => _deleteNote(note),
                      child: const Text('Supprimer',
                          style: TextStyle(color: AppTheme.secondaryRed)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewNote(MedicalNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la mesure'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Mesure cardiaque',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                  'Date: ${note.date.day}/${note.date.month}/${note.date.year}'),
              const SizedBox(height: 16),
              const Text('Mesures:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Systolique: ${note.systolic} mmHg'),
              Text('Diastolique: ${note.diastolic} mmHg'),
              Text('Fréquence cardiaque: ${note.heartRate} bpm'),
              const SizedBox(height: 16),
              const Text('Contexte:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(note.context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _editNote(MedicalNote note) {
    // In a real app, you'd check if the current doctor is the author.
    _addNote(context, note: note);
  }

  Future<void> _deleteNote(MedicalNote note) async {
    // For now, allow any doctor to delete. In a real app, you'd check doctorId.
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette note ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.secondaryRed)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _medicalNotes.removeWhere((n) => n.id == note.id);
      final prefs = await SharedPreferences.getInstance();
      final notesJson =
          json.encode(_medicalNotes.map((n) => n.toMap()).toList());
      await prefs.setString('medical_notes_$_patientId', notesJson);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note supprimée avec succès'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}
