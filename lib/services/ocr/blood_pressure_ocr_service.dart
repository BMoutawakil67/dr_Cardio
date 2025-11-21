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
      systolic = val1;
      diastolic = val2;
      confidence = 0.9;

      // Chercher un 3ème nombre pour le pouls
      final remainingNumbers = numbers.where((n) => n != val1 && n != val2).toList();
      if (remainingNumbers.isNotEmpty) {
        pulse = remainingNumbers.first;
      }

      debugPrint('✅ Pattern "/" détecté: $systolic/$diastolic pulse: $pulse');
    }

    // Stratégie 2: Prendre les 3 premiers nombres si disponibles
    if (systolic == null && numbers.length >= 2) {
      // Trier par ordre décroissant
      final sorted = List<int>.from(numbers)..sort((a, b) => b.compareTo(a));

      systolic = sorted[0]; // Le plus grand
      diastolic = sorted[1]; // Le deuxième plus grand

      if (numbers.length >= 3) {
        // Prendre un troisième nombre comme pouls
        pulse = sorted[2];
      }

      confidence = 0.6;
      debugPrint('✅ 3 nombres détectés: sys=$systolic, dia=$diastolic, pulse=$pulse');
    }

    return BloodPressureOcrResult(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      confidence: confidence,
      rawText: cleanText,
    );
  }

  /// Extrait tous les nombres d'une chaîne (2 ou 3 chiffres)
  List<int> _extractNumbers(String text) {
    final numberPattern = RegExp(r'\d{2,3}');
    return numberPattern
        .allMatches(text)
        .map((m) => int.parse(m.group(0)!))
        .toList();
  }

  /// Libérer les ressources
  void dispose() {
    _textRecognizer.close();
  }
}
