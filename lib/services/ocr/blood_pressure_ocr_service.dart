import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:dr_cardio/services/ocr/image_preprocessing_service.dart';
import 'package:dr_cardio/services/ocr/ocr_space_service.dart';
import 'dart:io';

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
  final ImagePreprocessingService _preprocessingService = ImagePreprocessingService();
  final OcrSpaceService _ocrSpaceService = OcrSpaceService();

  /// Analyse une image et extrait les valeurs de tension
  /// Utilise plusieurs stratégies OCR pour maximiser la détection LCD
  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 DÉBUT ANALYSE OCR');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📸 Image source: $imagePath');

      // STRATÉGIE 1: OCR.space API (si internet disponible)
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 TENTATIVE 1/4: OCR.space API Cloud');
      debugPrint('─────────────────────────────────────────────────────────');

      final ocrSpaceText = await _ocrSpaceService.extractText(imagePath);

      if (ocrSpaceText != null && ocrSpaceText.isNotEmpty) {
        debugPrint('✅ OCR.space a retourné du texte');
        final ocrSpaceResult = _parseBloodPressureValues(ocrSpaceText);
        debugPrint('📊 Résultat OCR.space: $ocrSpaceResult');

        if (ocrSpaceResult.isValid && ocrSpaceResult.confidence >= 0.75) {
          debugPrint('✅ Détection réussie avec OCR.space !');
          return ocrSpaceResult;
        }

        debugPrint('⚠️ OCR.space: Confiance insuffisante (${(ocrSpaceResult.confidence * 100).toStringAsFixed(1)}%)');
      } else {
        debugPrint('⚠️ OCR.space indisponible ou aucun texte détecté');
      }

      // STRATÉGIE 2: Google ML Kit avec image originale
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 TENTATIVE 2/4: Google ML Kit (image originale)');
      debugPrint('─────────────────────────────────────────────────────────');

      var result = await _tryOcrOnImage(imagePath, 'ML Kit Originale');

      if (result.isValid && result.confidence >= 0.85) {
        debugPrint('✅ Détection réussie avec l\'image originale !');
        return result;
      }

      debugPrint('⚠️ Détection insuffisante (confiance: ${(result.confidence * 100).toStringAsFixed(1)}%)');
      debugPrint('   Passage au preprocessing LCD optimisé...');

      // STRATÉGIE 3: Preprocessing optimisé pour LCD
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 TENTATIVE 3/4: Preprocessing LCD optimisé');
      debugPrint('─────────────────────────────────────────────────────────');

      final lcdProcessedPath = await _preprocessingService.preprocessForLcdDisplay(imagePath);
      final lcdResult = await _tryOcrOnImage(lcdProcessedPath, 'LCD Optimisé');

      // Nettoyer le fichier temporaire
      if (lcdProcessedPath != imagePath) {
        _cleanupTempFile(lcdProcessedPath);
      }

      // Comparer avec le résultat précédent et garder le meilleur
      if (lcdResult.confidence > result.confidence ||
          (lcdResult.isValid && !result.isValid)) {
        result = lcdResult;
      }

      if (result.isValid && result.confidence >= 0.75) {
        debugPrint('✅ Détection réussie avec preprocessing LCD !');
        return result;
      }

      debugPrint('⚠️ Détection encore insuffisante (confiance: ${(result.confidence * 100).toStringAsFixed(1)}%)');
      debugPrint('   Passage au preprocessing adaptatif...');

      // STRATÉGIE 4: Preprocessing adaptatif (plus agressif)
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 TENTATIVE 4/4: Preprocessing adaptatif');
      debugPrint('─────────────────────────────────────────────────────────');

      final adaptiveProcessedPath = await _preprocessingService.preprocessWithAdaptiveThreshold(imagePath);
      final adaptiveResult = await _tryOcrOnImage(adaptiveProcessedPath, 'Adaptatif');

      // Nettoyer le fichier temporaire
      if (adaptiveProcessedPath != imagePath) {
        _cleanupTempFile(adaptiveProcessedPath);
      }

      // Garder le meilleur résultat des 3 tentatives
      if (adaptiveResult.confidence > result.confidence ||
          (adaptiveResult.isValid && !result.isValid)) {
        result = adaptiveResult;
      }

      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ RÉSULTAT FINAL');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('   💉 Systolique: ${result.systolic ?? "non détecté"} mmHg');
      debugPrint('   💉 Diastolique: ${result.diastolic ?? "non détecté"} mmHg');
      debugPrint('   ❤️ Pouls: ${result.pulse ?? "non détecté"} bpm');
      debugPrint('   📊 Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%');
      debugPrint('   ✓ Valide: ${result.isValid ? "Oui" : "Non"}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');

      return result;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ ERREUR CRITIQUE OCR');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Message: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════');

      logger.e('Erreur OCR: $e');
      return BloodPressureOcrResult(
        rawText: '',
        error: e.toString(),
      );
    }
  }

  /// Tente l'OCR sur une image et retourne le résultat
  Future<BloodPressureOcrResult> _tryOcrOnImage(String imagePath, String strategyName) async {
    try {
      debugPrint('🔍 OCR [$strategyName]: Analyse...');

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      debugPrint('📝 OCR [$strategyName]: Texte brut: "${recognizedText.text}"');
      logger.i('OCR [$strategyName] Raw Text: ${recognizedText.text}');

      if (recognizedText.text.trim().isEmpty) {
        debugPrint('⚠️ OCR [$strategyName]: Aucun texte détecté');
        return BloodPressureOcrResult(
          rawText: '(aucun texte détecté)',
          error: 'Aucun texte détecté dans l\'image avec $strategyName',
        );
      }

      final result = _parseBloodPressureValues(recognizedText.text);
      debugPrint('📊 OCR [$strategyName]: Résultat: $result');

      return result;
    } catch (e) {
      debugPrint('❌ OCR [$strategyName] Erreur: $e');
      return BloodPressureOcrResult(
        rawText: '',
        error: 'Erreur OCR [$strategyName]: $e',
      );
    }
  }

  /// Nettoie un fichier temporaire
  void _cleanupTempFile(String filePath) {
    try {
      File(filePath).deleteSync();
      debugPrint('🗑️ Fichier temporaire supprimé: $filePath');
    } catch (e) {
      debugPrint('⚠️ Impossible de supprimer le fichier temp: $e');
    }
  }

  /// Parse le texte reconnu pour extraire les valeurs de tension
  BloodPressureOcrResult _parseBloodPressureValues(String text) {
    // Nettoyer le texte
    var cleanText = text.replaceAll('\n', ' ').replaceAll('  ', ' ');

    // Filtrer les patterns de date/heure pour éviter les interférences
    cleanText = _filterDateTimePatterns(cleanText);

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

  /// Filtre et supprime les patterns de date/heure qui peuvent interférer avec la détection
  /// Exemples: "8:30", "08:30 AM", "10.08", "10/08/2024", etc.
  String _filterDateTimePatterns(String text) {
    debugPrint('🔍 Texte avant filtrage date/heure: "$text"');

    var filtered = text;

    // Pattern 1: Heures avec : (8:30, 08:30, 12:45, etc.)
    // Remplacer par un espace pour ne pas coller les mots
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}:\d{2}\b'), ' ');

    // Pattern 2: Heures avec AM/PM (8:30 AM, 12:45 PM, etc.)
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)\b'), ' ');

    // Pattern 3: Heures avec 'h' (8h30, 12h45, etc.)
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}h\d{2}\b', caseSensitive: false), ' ');

    // Pattern 4: Dates avec points (10.08, 10.08., 10.08.2024, etc.)
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}\.\d{1,2}\.?(?:\d{2,4})?\b'), ' ');

    // Pattern 5: Dates avec slashes (10/08, 10/08/24, 10/08/2024, etc.)
    // ATTENTION: On doit éviter de supprimer les patterns de tension comme 120/80
    // On vérifie que les nombres sont petits (<= 31 pour jours/mois)
    filtered = filtered.replaceAll(RegExp(r'\b([0-2]?\d|3[01])/([0-1]?\d|1[0-2])(?:/\d{2,4})?\b'), ' ');

    // Pattern 6: Dates avec tirets (10-08, 10-08-24, etc.)
    filtered = filtered.replaceAll(RegExp(r'\b([0-2]?\d|3[01])-([0-1]?\d|1[0-2])(?:-\d{2,4})?\b'), ' ');

    // Nettoyer les espaces multiples créés par les remplacements
    filtered = filtered.replaceAll(RegExp(r'\s+'), ' ').trim();

    debugPrint('✅ Texte après filtrage date/heure: "$filtered"');

    return filtered;
  }

  /// Libérer les ressources
  void dispose() {
    _textRecognizer.close();
  }
}
