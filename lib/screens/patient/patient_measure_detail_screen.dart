import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:intl/intl.dart';

class PatientMeasureDetailScreen extends StatefulWidget {
  const PatientMeasureDetailScreen({super.key});

  @override
  State<PatientMeasureDetailScreen> createState() => _PatientMeasureDetailScreenState();
}

class _PatientMeasureDetailScreenState extends State<PatientMeasureDetailScreen> {
  final MedicalNoteRepository _repository = MedicalNoteRepository();
  MedicalNote? _note;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args.containsKey('noteId')) {
      final noteId = args['noteId'] as String;
      final note = await _repository.getMedicalNote(noteId);

      if (mounted) {
        setState(() {
          _note = note;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: const Center(child: Text('Mesure non trouvée')),
      );
    }

    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(_note!.date);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMeasure(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date et heure
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Carte principale des mesures
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Valeurs tension
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPressureValue(
                        _note!.systolic.toString(),
                        'Systolique',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '/',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.greyMedium,
                          ),
                        ),
                      ),
                      _buildPressureValue(
                        _note!.diastolic.toString(),
                        'Diastolique',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pouls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '💓',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_note!.heartRate} bpm',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatus(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Contexte
            if (_note!.context.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('📋', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'Contexte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _note!.context,
                      style: const TextStyle(
                        color: AppTheme.greyMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Bouton partager avec docteur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _shareWithDoctor(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PARTAGER AVEC DR.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getStatus() {
    if (_note!.systolic >= 18 || _note!.diastolic >= 11) {
      return 'Hypertension élevée';
    } else if (_note!.systolic >= 16 || _note!.diastolic >= 10) {
      return 'Hypertension modérée';
    } else if (_note!.systolic >= 14 || _note!.diastolic >= 9) {
      return 'Tension élevée-normale';
    } else if (_note!.systolic >= 12 || _note!.diastolic >= 8) {
      return 'Normal';
    } else {
      return 'Tension basse';
    }
  }

  Color _getStatusColor() {
    if (_note!.systolic >= 18 || _note!.diastolic >= 11) {
      return AppTheme.secondaryRed;
    } else if (_note!.systolic >= 16 || _note!.diastolic >= 10) {
      return AppTheme.warningOrange;
    } else if (_note!.systolic >= 14 || _note!.diastolic >= 9) {
      return Colors.yellow.shade700;
    } else if (_note!.systolic >= 12 || _note!.diastolic >= 8) {
      return AppTheme.successGreen;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildPressureValue(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.greyMedium.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _editMeasure(BuildContext context) async {
    final systolicController = TextEditingController(text: _note!.systolic.toString());
    final diastolicController = TextEditingController(text: _note!.diastolic.toString());
    final pulseController = TextEditingController(text: _note!.heartRate.toString());
    final contextController = TextEditingController(text: _note!.context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la mesure'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Systolique (mmHg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diastolique (mmHg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pulseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pouls (bpm)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contextController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Contexte'),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final updatedNote = _note!.copyWith(
          systolic: int.parse(systolicController.text),
          diastolic: int.parse(diastolicController.text),
          heartRate: int.parse(pulseController.text),
          context: contextController.text,
        );

        await _repository.updateMedicalNote(updatedNote);

        setState(() {
          _note = updatedNote;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Mesure modifiée avec succès'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la mesure'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette mesure? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.secondaryRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.deleteMedicalNote(_note!.id);

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Mesure supprimée'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _shareWithDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('📨', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(child: Text('Partager avec votre médecin')),
          ],
        ),
        content: const Text(
          'Cette mesure sera partagée avec votre cardiologue. Il pourra la consulter dans votre dossier médical et vous contacter si nécessaire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Mesure partagée avec succès'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }
}
