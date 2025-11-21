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

    // Stratégie 1: Chercher des patterns avec labels (SYS: XXX, DIA: XX, PUL: XX)
    // Cas 1: Label à gauche (SYS: 120 ou SYS 120)
    final labelLeftPatterns = {
      'SYS': RegExp(r'SYS[:\s]*(\d{2,3})', caseSensitive: false),
      'DIA': RegExp(r'DIA[:\s]*(\d{2,3})', caseSensitive: false),
      'PUL': RegExp(r'PUL[:\s]*(\d{2,3})', caseSensitive: false),
    };

    // Cas 2: Label à droite (120 SYS ou 120 mmHg SYS)
    final labelRightPatterns = {
      'SYS': RegExp(r'(\d{2,3})\s*(?:mmHg)?\s*SYS', caseSensitive: false),
      'DIA': RegExp(r'(\d{2,3})\s*(?:mmHg)?\s*DIA', caseSensitive: false),
      'PUL': RegExp(r'(\d{2,3})\s*(?:bpm)?\s*PUL', caseSensitive: false),
    };

    var sysMatch = labelLeftPatterns['SYS']!.firstMatch(cleanText);
    var diaMatch = labelLeftPatterns['DIA']!.firstMatch(cleanText);
    var pulMatch = labelLeftPatterns['PUL']!.firstMatch(cleanText);

    // Si pas trouvé à gauche, chercher à droite
    if (sysMatch == null) {
      sysMatch = labelRightPatterns['SYS']!.firstMatch(cleanText);
    }
    if (diaMatch == null) {
      diaMatch = labelRightPatterns['DIA']!.firstMatch(cleanText);
    }
    if (pulMatch == null) {
      pulMatch = labelRightPatterns['PUL']!.firstMatch(cleanText);
    }

    if (sysMatch != null && diaMatch != null) {
      systolic = int.parse(sysMatch.group(1)!);
      diastolic = int.parse(diaMatch.group(1)!);
      if (pulMatch != null) {
        pulse = int.parse(pulMatch.group(1)!);
      }
      confidence = 0.95;
      debugPrint('✅ Pattern avec labels détecté: SYS=$systolic DIA=$diastolic PUL=$pulse');
    }

    // Stratégie 2: Chercher un pattern "XXX/YY" ou "XXX/YY/ZZ"
    if (systolic == null) {
      final slashPattern = RegExp(r'(\d{2,3})\s*[/\\]\s*(\d{2,3})(?:\s*[/\\]\s*(\d{2,3}))?');
      final slashMatch = slashPattern.firstMatch(cleanText);
      if (slashMatch != null) {
        systolic = int.parse(slashMatch.group(1)!);
        diastolic = int.parse(slashMatch.group(2)!);
        if (slashMatch.group(3) != null) {
          pulse = int.parse(slashMatch.group(3)!);
        }
        confidence = 0.9;
        debugPrint('✅ Pattern "/" détecté: $systolic/$diastolic/$pulse');
      }
    }

    // Stratégie 3: Utiliser des regex spécifiques pour systole, diastole, pouls
    if (systolic == null) {
      // Regex pour systole: 100-199 ou 80-99
      final systoleRegex = RegExp(r'\b(1[0-9]{2}|[8-9][0-9])\b');
      // Regex pour diastole: 50-99
      final diastoleRegex = RegExp(r'\b[5-9][0-9]\b');
      // Regex pour pouls: 40-99
      final pulseRegex = RegExp(r'\b[4-9][0-9]\b');

      final systoleMatches = systoleRegex.allMatches(cleanText).map((m) => int.parse(m.group(0)!)).toList();
      final diastoleMatches = diastoleRegex.allMatches(cleanText).map((m) => int.parse(m.group(0)!)).toList();
      final pulseMatches = pulseRegex.allMatches(cleanText).map((m) => int.parse(m.group(0)!)).toList();

      debugPrint('🔍 Regex spécifiques - Systole: $systoleMatches, Diastole: $diastoleMatches, Pouls: $pulseMatches');

      if (systoleMatches.isNotEmpty) {
        systolic = systoleMatches.first;
      }

      if (diastoleMatches.isNotEmpty) {
        // Prendre le diastole qui n'est pas égal au systole
        diastolic = diastoleMatches.firstWhere(
          (d) => d != systolic,
          orElse: () => diastoleMatches.first,
        );
      }

      if (pulseMatches.isNotEmpty) {
        // Prendre le pouls qui n'est pas égal au systole ou diastole
        pulse = pulseMatches.firstWhere(
          (p) => p != systolic && p != diastolic,
          orElse: () => pulseMatches.first,
        );
      }

      if (systolic != null && diastolic != null) {
        confidence = 0.75;
        debugPrint('✅ Regex spécifiques: sys=$systolic, dia=$diastolic, pulse=$pulse');
      }
    }

    // Stratégie 4: Fallback - Prendre les nombres par ordre décroissant
    if (systolic == null && numbers.length >= 2) {
      // Trier par ordre décroissant
      final sorted = List<int>.from(numbers)..sort((a, b) => b.compareTo(a));

      systolic = sorted[0]; // Le plus grand
      diastolic = sorted[1]; // Le deuxième plus grand

      if (numbers.length >= 3) {
        pulse = sorted[2];
      }

      confidence = 0.6;
      debugPrint('✅ Fallback - tri par magnitude: sys=$systolic, dia=$diastolic, pulse=$pulse');
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
