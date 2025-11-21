import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';

/// Résultat de l'extraction OCR des valeurs de tension
class BloodPressureOcrResult {
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final double confidence;
  final String rawText;
  final String? error;

  BloodPressureOcrResult({
    this.systolic,
    this.diastolic,
    this.pulse,
    this.confidence = 0.0,
    this.rawText = '',
    this.error,
  });

  bool get isValid => systolic != null && diastolic != null;

  @override
  String toString() {
    return 'BloodPressureOcrResult(sys: $systolic, dia: $diastolic, pulse: $pulse, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Service OCR pour extraire les valeurs de tension artérielle depuis une image
class BloodPressureOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Analyse une image et extrait les valeurs de tension
  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath) async {
    try {
      debugPrint('🔍 OCR: Analyse de $imagePath');

      final inputImage = InputImage.fromFilePath(imagePath);
      debugPrint('🔍 OCR: Image chargée');

      final recognizedText = await _textRecognizer.processImage(inputImage);
      debugPrint('🔍 OCR: Texte reconnu: "${recognizedText.text}"');

      logger.i('OCR Raw Text: ${recognizedText.text}');

      if (recognizedText.text.isEmpty) {
        return BloodPressureOcrResult(
          rawText: '(aucun texte détecté)',
          error: 'Aucun texte détecté dans l\'image',
        );
      }

      return _parseBloodPressureValues(recognizedText.text);
    } catch (e, stackTrace) {
      debugPrint('❌ OCR Erreur: $e');
      debugPrint('❌ Stack: $stackTrace');
      logger.e('Erreur OCR: $e');
      return BloodPressureOcrResult(
        rawText: '',
        error: e.toString(),
      );
    }
  }

  /// Parse le texte reconnu pour extraire les valeurs de tension
  BloodPressureOcrResult _parseBloodPressureValues(String text) {
    // Nettoyer le texte
    final cleanText = text.replaceAll('\n', ' ').replaceAll('  ', ' ');

    // Extraire tous les nombres du texte
    final numbers = _extractNumbers(cleanText);
    logger.i('Nombres extraits: $numbers');

    if (numbers.isEmpty) {
      return BloodPressureOcrResult(rawText: cleanText, confidence: 0.0);
    }

    int? systolic;
    int? diastolic;
    int? pulse;
    double confidence = 0.5;

    // Stratégie 1: Chercher un pattern "SYS/DIA" ou "XXX/YY"
    final slashPattern = RegExp(r'(\d{2,3})\s*[/\\]\s*(\d{2,3})');
    final slashMatch = slashPattern.firstMatch(cleanText);
    if (slashMatch != null) {
      final val1 = int.parse(slashMatch.group(1)!);
      final val2 = int.parse(slashMatch.group(2)!);
      if (_isValidSystolic(val1) && _isValidDiastolic(val2)) {
        systolic = val1;
        diastolic = val2;
        confidence = 0.9;
      }
    }

    // Stratégie 2: Si pas trouvé, chercher les nombres dans les plages valides
    if (systolic == null || diastolic == null) {
      // Filtrer les nombres dans les plages de tension
      final systolicCandidates = numbers.where(_isValidSystolic).toList();
      final diastolicCandidates = numbers.where(_isValidDiastolic).toList();

      if (systolicCandidates.isNotEmpty && diastolicCandidates.isNotEmpty) {
        // Prendre le plus grand comme systolique, le plus petit comme diastolique
        systolic = systolicCandidates.reduce((a, b) => a > b ? a : b);
        diastolic = diastolicCandidates.reduce((a, b) => a < b ? a : b);

        // Vérifier la cohérence (systolique > diastolique)
        if (systolic <= diastolic) {
          // Inverser si nécessaire
          final temp = systolic;
          systolic = diastolic;
          diastolic = temp;
        }
        confidence = 0.7;
      }
    }

    // Stratégie 3: Chercher le pouls (généralement entre 40 et 200)
    final pulseCandidates = numbers.where(_isValidPulse).toList();
    // Exclure systolic et diastolic des candidats pulse
    pulseCandidates.removeWhere((n) => n == systolic || n == diastolic);
    if (pulseCandidates.isNotEmpty) {
      // Prendre la valeur la plus probable (souvent la plus proche de 60-100)
      pulse = pulseCandidates.reduce((a, b) {
        final diffA = (a - 75).abs();
        final diffB = (b - 75).abs();
        return diffA < diffB ? a : b;
      });
    }

    return BloodPressureOcrResult(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      confidence: confidence,
      rawText: cleanText,
    );
  }

  /// Extrait tous les nombres d'une chaîne
  List<int> _extractNumbers(String text) {
    final numberPattern = RegExp(r'\d{2,3}');
    return numberPattern
        .allMatches(text)
        .map((m) => int.parse(m.group(0)!))
        .toList();
  }

  /// Vérifie si une valeur est une systolique valide (70-250 mmHg)
  bool _isValidSystolic(int value) {
    return value >= 70 && value <= 250;
  }

  /// Vérifie si une valeur est une diastolique valide (40-150 mmHg)
  bool _isValidDiastolic(int value) {
    return value >= 40 && value <= 150;
  }

  /// Vérifie si une valeur est un pouls valide (30-220 bpm)
  bool _isValidPulse(int value) {
    return value >= 30 && value <= 220;
  }

  /// Libérer les ressources
  void dispose() {
    _textRecognizer.close();
  }
}
