import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';

class RecordPressurePhotoScreen extends StatefulWidget {
  const RecordPressurePhotoScreen({super.key});

  @override
  State<RecordPressurePhotoScreen> createState() =>
      _RecordPressurePhotoScreenState();
}

class _RecordPressurePhotoScreenState extends State<RecordPressurePhotoScreen> {
  bool _isProcessing = false;
  bool _isValidated = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  final MedicalNoteRepository _repository = MedicalNoteRepository();

  // Valeurs détectées par OCR (simulées)
  final _systolicController = TextEditingController(text: '14');
  final _diastolicController = TextEditingController(text: '9');
  final _pulseController = TextEditingController(text: '72');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _context = '';

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidated) {
      return _buildValidationScreen();
    }

    if (_isProcessing) {
      return _buildProcessingScreen();
    }

    return _buildCameraScreen();
  }

  // Écran de la caméra
  Widget _buildCameraScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('📷 Photo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Aperçu caméra (simulé)
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'APERÇU CAMÉRA',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cadre de guidage
                Center(
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Cadrez les chiffres\ndu tensiomètre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contrôles
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Bouton Capturer
                ElevatedButton(
                  onPressed: _capturePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const CircleBorder(),
                    minimumSize: const Size(80, 80),
                  ),
                  child: const Icon(Icons.camera, size: 40),
                ),
                const SizedBox(height: 24),

                // Conseils
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Conseils:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Bon éclairage',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '• Tensiomètre bien cadré',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '• Image nette',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton Galerie
                OutlinedButton.icon(
                  onPressed: _openGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galerie'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Écran de traitement OCR
  Widget _buildProcessingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Miniature photo
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _capturedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                          width: 200,
                          height: 150,
                        ),
                      )
                    : const Icon(Icons.image, size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Icône analyse
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 24),

              // Texte
              Text(
                '⏳ Analyse en cours...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Barre de progression
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 8),
              const Text('85%'),
              const SizedBox(height: 24),

              Text(
                'Extraction des valeurs...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Écran de validation
  Widget _buildValidationScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isValidated = false;
            });
          },
        ),
        title: const Text('Vérification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo capturée
            if (_capturedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_capturedImage!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

            // Message succès
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Photo analysée avec succès',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Valeurs détectées:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Systolique
            TextFormField(
              controller: _systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Systolique',
                suffixText: 'mmHg',
              ),
            ),
            const SizedBox(height: 16),

            // Diastolique
            TextFormField(
              controller: _diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Diastolique',
                suffixText: 'mmHg',
              ),
            ),
            const SizedBox(height: 16),

            // Pouls
            TextFormField(
              controller: _pulseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pouls (bpm)',
                suffixText: 'bpm',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '📝 Corriger si nécessaire',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),

            // Date et heure
            Text(
              '⏰ Date et heure:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}  ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date == null || !context.mounted) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = time;
                      });
                    }
                  },
                  child: const Text('Modifier'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bouton Ajouter contexte
            OutlinedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.addContext,
                  arguments: {'context': _context},
                );
                if (result != null && result is String) {
                  setState(() {
                    _context = result;
                  });
                }
              },
              child: Text(
                _context.isEmpty
                    ? 'AJOUTER CONTEXTE\n(optionnel)'
                    : '✅ CONTEXTE AJOUTÉ',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: () => _saveMeasure(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeasure() async {
    if (!mounted) return;

    try {
      // Validation des champs
      final systolic = int.tryParse(_systolicController.text);
      final diastolic = int.tryParse(_diastolicController.text);
      final heartRate = int.tryParse(_pulseController.text);

      if (systolic == null || diastolic == null || heartRate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Veuillez entrer des valeurs valides'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      // Combine date et time
      final measurementDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Get patient ID
      final patientId = AuthService().currentUserId ?? 'patient-001';

      // Create medical note
      final note = MedicalNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        doctorId: 'doctor-001', // Default doctor
        date: measurementDate,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        context: _context,
        photoUrl: _capturedImage?.path, // Store image path
      );

      // Save to Hive
      await _repository.addMedicalNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mesure enregistrée avec succès'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
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

  Future<void> _capturePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _isProcessing = true;
        });

        // Simuler le traitement OCR (2 secondes)
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isValidated = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la capture: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _isProcessing = true;
        });

        // Simuler le traitement OCR (2 secondes)
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isValidated = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la sélection: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
