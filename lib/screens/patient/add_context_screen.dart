import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/models/medication_model.dart';
import 'package:dr_cardio/repositories/medication_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AddContextScreen extends StatefulWidget {
  const AddContextScreen({super.key});

  @override
  State<AddContextScreen> createState() => _AddContextScreenState();
}

class _AddContextScreenState extends State<AddContextScreen> {
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final MedicationRepository _medicationRepository = MedicationRepository();

  List<Medication> _medications = [];
  final Map<String, bool> _selectedMedications = {};
  String _activity = 'Aucune';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final patientId = AuthService().currentUserId ?? '';
    final medications = await _medicationRepository.getMedicationsByPatient(patientId);

    if (mounted) {
      setState(() {
        _medications = medications;
        // Initialize selection map
        for (var med in medications) {
          _selectedMedications[med.id] = false;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get existing context if provided
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('context')) {
      final existingContext = args['context'] as String?;
      if (existingContext != null && existingContext.isNotEmpty) {
        _notesController.text = existingContext;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _buildContextString() {
    final parts = <String>[];

    // Medications
    final selectedMeds = _medications
        .where((med) => _selectedMedications[med.id] == true)
        .map((med) => med.displayName)
        .toList();
    if (selectedMeds.isNotEmpty) {
      parts.add('Médicaments: ${selectedMeds.join(", ")}');
    }

    // Weight
    if (_weightController.text.isNotEmpty) {
      parts.add('Poids: ${_weightController.text} kg');
    }

    // Activity
    if (_activity != 'Aucune') {
      parts.add('Activité: $_activity');
    }

    // Notes
    if (_notesController.text.isNotEmpty) {
      parts.add('Notes: ${_notesController.text}');
    }

    return parts.isEmpty ? '' : parts.join(' | ');
  }

  void _saveContext() {
    final contextString = _buildContextString();
    Navigator.pop(context, contextString);
  }

  Future<void> _showAddMedicationDialog() async {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.medication, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Ajouter un médicament'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament *',
                  hintText: 'ex: Amlodipine',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  hintText: 'ex: 5mg',
                  prefixIcon: Icon(Icons.speed),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Fréquence (optionnel)',
                  hintText: 'ex: 1x par jour, matin et soir',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'ex: Avant repas',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  dosageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir le nom et le dosage'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    // Dispose controllers first
    final name = nameController.text.trim();
    final dosage = dosageController.text.trim();
    final frequency = frequencyController.text.trim();
    final notes = notesController.text.trim();

    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    notesController.dispose();

    if (result == true && mounted) {
      final patientId = AuthService().currentUserId ?? '';
      final medication = Medication(
        id: const Uuid().v4(),
        name: name,
        dosage: dosage,
        frequency: frequency.isEmpty ? null : frequency,
        notes: notes.isEmpty ? null : notes,
        patientId: patientId,
        createdAt: DateTime.now(),
      );

      await _medicationRepository.addMedication(medication);

      // Use a post-frame callback to ensure we're not in the middle of a build
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _loadMedications();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${medication.displayName} ajouté'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _showEditMedicationDialog(Medication medication) async {
    final nameController = TextEditingController(text: medication.name);
    final dosageController = TextEditingController(text: medication.dosage);
    final frequencyController =
        TextEditingController(text: medication.frequency ?? '');
    final notesController = TextEditingController(text: medication.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Modifier le médicament'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament *',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  prefixIcon: Icon(Icons.speed),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Fréquence (optionnel)',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  dosageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir le nom et le dosage'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    // Dispose controllers first
    final name = nameController.text.trim();
    final dosage = dosageController.text.trim();
    final frequency = frequencyController.text.trim();
    final notes = notesController.text.trim();

    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    notesController.dispose();

    if (result == true && mounted) {
      final updatedMedication = medication.copyWith(
        name: name,
        dosage: dosage,
        frequency: frequency.isEmpty ? null : frequency,
        notes: notes.isEmpty ? null : notes,
        updatedAt: DateTime.now(),
      );

      await _medicationRepository.updateMedication(updatedMedication);

      // Use a post-frame callback to ensure we're not in the middle of a build
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _loadMedications();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${updatedMedication.displayName} mis à jour'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le médicament'),
        content: Text(
          'Voulez-vous vraiment supprimer ${medication.displayName} de votre liste?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _medicationRepository.deleteMedication(medication.id);

      // Use a post-frame callback to ensure we're not in the middle of a build
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _loadMedications();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🗑️ ${medication.displayName} supprimé'),
                backgroundColor: AppTheme.greyMedium,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Contexte'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Ajoutez des informations complémentaires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Medications Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('💊 Médicaments pris'),
                TextButton.icon(
                  onPressed: _showAddMedicationDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Ajouter'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildMedicationList(),

            const SizedBox(height: 20),
            _buildSectionTitle('⚖️ Poids (kg) - Optionnel'),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '75',
                labelText: 'Poids',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('🏃 Activité physique'),
            const SizedBox(height: 10),
            _buildActivityList(),
            const SizedBox(height: 20),
            _buildSectionTitle('📝 Notes (optionnel)'),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Ressenti stress, après repas, au repos...',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveContext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text(
                'ENREGISTRER',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildMedicationList() {
    if (_medications.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 48,
                color: AppTheme.greyMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Aucun médicament enregistré',
                style: TextStyle(color: AppTheme.greyMedium),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showAddMedicationDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter votre premier médicament'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _medications.map((medication) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: _selectedMedications[medication.id] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _selectedMedications[medication.id] = value ?? false;
              });
            },
            title: Text(
              medication.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: medication.frequency != null || medication.notes != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (medication.frequency != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppTheme.greyMedium),
                            const SizedBox(width: 4),
                            Text(
                              medication.frequency!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      if (medication.notes != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.note, size: 14, color: AppTheme.greyMedium),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                medication.notes!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  )
                : null,
            secondary: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditMedicationDialog(medication);
                } else if (value == 'delete') {
                  _deleteMedication(medication);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppTheme.primaryBlue),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorRed),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Aucune'),
          value: 'Aucune',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Légère (marche)'),
          value: 'Légère (marche)',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Modérée (sport)'),
          value: 'Modérée (sport)',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Intense'),
          value: 'Intense',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
      ],
    );
  }
}
