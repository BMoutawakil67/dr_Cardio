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
  final ImagePreprocessingService _preprocessingService =
      ImagePreprocessingService();
  final OcrSpaceService _ocrSpaceService = OcrSpaceService();

  /// Analyse une image et extrait les valeurs de tension
  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath) async {
    try {
      // Stratégie 1: OCR.space API (Cloud)
      debugPrint('🔥 Stratégie 1: Tentative avec l\'API OCR.space...');
      final ocrSpaceResult = await _ocrSpaceService.extractText(imagePath);
      if (ocrSpaceResult.rawText.isNotEmpty) {
        final parsedResult = _parseBloodPressureValues(ocrSpaceResult.rawText);
        if (parsedResult.isValid) {
          debugPrint(
              '✅ Stratégie 1 (OCR.space) a réussi: ${parsedResult.toString()}');
          logger.i('Stratégie 1 (OCR.space) a réussi: $parsedResult');
          return parsedResult;
        }
      }
      debugPrint(
          '⚠️ Stratégie 1 (OCR.space) a échoué ou n\'a pas trouvé de valeurs valides.');
      logger.w(
          'Stratégie 1 (OCR.space) a échoué. Erreur: ${ocrSpaceResult.error}');

      // Si la stratégie 1 échoue, on retourne une erreur car les autres sont désactivées
      return BloodPressureOcrResult(
        rawText: ocrSpaceResult.rawText,
        error:
            'La stratégie OCR.space a échoué et les stratégies locales sont désactivées. (Erreur: ${ocrSpaceResult.error})',
      );

/*
      // Stratégie 2: Google ML Kit (Local) - Image originale
      debugPrint(
          '🔥 Stratégie 2: Tentative avec Google ML Kit sur l\'image originale...');
      var result = await _tryOcrOnImage(imagePath, 'Original');
      if (result.isValid) {
        debugPrint('✅ Stratégie 2 (Original) a réussi: ${result.toString()}');
        return result;
      }
      debugPrint('⚠️ Stratégie 2 (Original) a échoué.');

      // Stratégie 3: Google ML Kit (Local) - Prétraitement pour écran LCD
      debugPrint(
          '🔥 Stratégie 3: Tentative avec prétraitement pour écran LCD...');
      final lcdImagePath =
          await _preprocessingService.preprocessForLcdDisplay(imagePath);
      if (lcdImagePath != null) {
        result = await _tryOcrOnImage(lcdImagePath, 'LCD Preprocessed');
        _cleanupTempFile(lcdImagePath);
        if (result.isValid) {
          debugPrint('✅ Stratégie 3 (LCD) a réussi: ${result.toString()}');
          return result;
        }
        debugPrint('⚠️ Stratégie 3 (LCD) a échoué.');
      }

      // Stratégie 4: Google ML Kit (Local) - Prétraitement avec seuillage adaptatif
      debugPrint('🔥 Stratégie 4: Tentative avec seuillage adaptatif...');
      final adaptiveImagePath =
          await _preprocessingService.preprocessWithAdaptiveThreshold(imagePath);
      if (adaptiveImagePath != null) {
        result = await _tryOcrOnImage(adaptiveImagePath, 'Adaptive Threshold');
        _cleanupTempFile(adaptiveImagePath);
        if (result.isValid) {
          debugPrint('✅ Stratégie 4 (Adaptive) a réussi: ${result.toString()}');
          return result;
        }
        debugPrint('⚠️ Stratégie 4 (Adaptive) a échoué.');
      }

      // Stratégie 5: Google ML Kit (Local) - Isolation de l'écran LCD
      debugPrint('🔥 Stratégie 5: Tentative avec isolation de l\'écran LCD...');
      final isolatedLcdPath =
          await _preprocessingService.preprocessWithLcdIsolation(imagePath);
      if (isolatedLcdPath != null) {
        result = await _tryOcrOnImage(isolatedLcdPath, 'LCD Isolation');
        _cleanupTempFile(isolatedLcdPath);
        if (result.isValid) {
          debugPrint(
              '✅ Stratégie 5 (LCD Isolation) a réussi: ${result.toString()}');
          return result;
        }
        debugPrint('⚠️ Stratégie 5 (LCD Isolation) a échoué.');
      }
*/
      // debugPrint('❌ Toutes les stratégies OCR ont échoué.');
      // return BloodPressureOcrResult(
      //   rawText: '', // On pourrait retourner le dernier texte brut ici
      //   error: 'Toutes les stratégies OCR ont échoué.',
      // );
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
  Future<BloodPressureOcrResult> _tryOcrOnImage(
      String imagePath, String strategyName) async {
    try {
      debugPrint('🔍 OCR [$strategyName]: Analyse...');

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      debugPrint(
          '📝 OCR [$strategyName]: Texte brut: "${recognizedText.text}"');
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

  /// Valide que les valeurs de tension sont médicalement plausibles
  bool _isValidBloodPressure(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return false;

    // Vérifier les plages médicales normales
    // Systolique: 70-200 mmHg (on accepte large pour couvrir hypo et hypertension)
    if (systolic < 70 || systolic > 200) {
      debugPrint('⚠️ Validation: Systolique $systolic hors plage [70-200]');
      return false;
    }

    // Diastolique: 40-130 mmHg
    if (diastolic < 40 || diastolic > 130) {
      debugPrint('⚠️ Validation: Diastolique $diastolic hors plage [40-130]');
      return false;
    }

    // Le systolique doit être > diastolique
    if (systolic <= diastolic) {
      debugPrint(
          '⚠️ Validation: Systolique ($systolic) <= Diastolique ($diastolic)');
      return false;
    }

    // Pression pulsée (différence) devrait être raisonnable (minimum 20, maximum 100)
    final pulsePressure = systolic - diastolic;
    if (pulsePressure < 20 || pulsePressure > 100) {
      debugPrint(
          '⚠️ Validation: Pression pulsée $pulsePressure hors plage [20-100]');
      return false;
    }

    debugPrint('✅ Validation: $systolic/$diastolic est médicalement valide');
    return true;
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
    sysMatch ??= labelRightPatterns['SYS']!.firstMatch(cleanText);
    diaMatch ??= labelRightPatterns['DIA']!.firstMatch(cleanText);
    pulMatch ??= labelRightPatterns['PUL']!.firstMatch(cleanText);

    if (sysMatch != null && diaMatch != null) {
      final tempSys = int.parse(sysMatch.group(1)!);
      final tempDia = int.parse(diaMatch.group(1)!);

      if (_isValidBloodPressure(tempSys, tempDia)) {
        systolic = tempSys;
        diastolic = tempDia;
        if (pulMatch != null) {
          pulse = int.parse(pulMatch.group(1)!);
        }
        confidence = 0.95;
        debugPrint(
            '✅ Pattern avec labels détecté: SYS=$systolic DIA=$diastolic PUL=$pulse');
      } else {
        debugPrint(
            '⚠️ Pattern avec labels invalide médicalement: SYS=$tempSys DIA=$tempDia');
      }
    }

    // Stratégie 2: Chercher un pattern "XXX/YY" ou "XXX/YY/ZZ"
    if (systolic == null) {
      final slashPattern =
          RegExp(r'(\d{2,3})\s*[/\\]\s*(\d{2,3})(?:\s*[/\\]\s*(\d{2,3}))?');
      final slashMatch = slashPattern.firstMatch(cleanText);
      if (slashMatch != null) {
        final tempSys = int.parse(slashMatch.group(1)!);
        final tempDia = int.parse(slashMatch.group(2)!);

        if (_isValidBloodPressure(tempSys, tempDia)) {
          systolic = tempSys;
          diastolic = tempDia;
          if (slashMatch.group(3) != null) {
            pulse = int.parse(slashMatch.group(3)!);
          }
          confidence = 0.9;
          debugPrint('✅ Pattern "/" détecté: $systolic/$diastolic/$pulse');
        } else {
          debugPrint('⚠️ Pattern "/" invalide médicalement: $tempSys/$tempDia');
        }
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

      final systoleMatches = systoleRegex
          .allMatches(cleanText)
          .map((m) => int.parse(m.group(0)!))
          .toList();
      final diastoleMatches = diastoleRegex
          .allMatches(cleanText)
          .map((m) => int.parse(m.group(0)!))
          .toList();
      final pulseMatches = pulseRegex
          .allMatches(cleanText)
          .map((m) => int.parse(m.group(0)!))
          .toList();

      debugPrint(
          '🔍 Regex spécifiques - Systole: $systoleMatches, Diastole: $diastoleMatches, Pouls: $pulseMatches');

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
        if (_isValidBloodPressure(systolic, diastolic)) {
          confidence = 0.75;
          debugPrint(
              '✅ Regex spécifiques: sys=$systolic, dia=$diastolic, pulse=$pulse');
        } else {
          debugPrint(
              '⚠️ Regex spécifiques invalide médicalement: sys=$systolic, dia=$diastolic');
          systolic = null;
          diastolic = null;
        }
      }
    }

    // Stratégie 4: Fallback - Prendre les nombres par ordre décroissant
    if (systolic == null && numbers.length >= 2) {
      // Trier par ordre décroissant
      final sorted = List<int>.from(numbers)..sort((a, b) => b.compareTo(a));

      final tempSys = sorted[0]; // Le plus grand
      final tempDia = sorted[1]; // Le deuxième plus grand

      if (_isValidBloodPressure(tempSys, tempDia)) {
        systolic = tempSys;
        diastolic = tempDia;

        if (numbers.length >= 3) {
          pulse = sorted[2];
        }

        confidence = 0.6;
        debugPrint(
            '✅ Fallback - tri par magnitude: sys=$systolic, dia=$diastolic, pulse=$pulse');
      } else {
        debugPrint(
            '⚠️ Fallback invalide médicalement: sys=$tempSys, dia=$tempDia - REJETÉ');
      }
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
  /// Exemples: "8:30", "08:30 AM", "10.08", "10/08/2024", "30"" (secondes), etc.
  String _filterDateTimePatterns(String text) {
    debugPrint('🔍 Texte avant filtrage date/heure: "$text"');

    var filtered = text;

    // Pattern 1: Heures avec : (8:30, 08:30, 12:45, etc.)
    // Remplacer par un espace pour ne pas coller les mots
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}:\d{2}\b'), ' ');

    // Pattern 2: Heures avec AM/PM (8:30 AM, 12:45 PM, etc.)
    filtered = filtered.replaceAll(
        RegExp(r'\b\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)\b'), ' ');

    // Pattern 3: Heures avec 'h' (8h30, 12h45, etc.)
    filtered = filtered.replaceAll(
        RegExp(r'\b\d{1,2}h\d{2}\b', caseSensitive: false), ' ');

    // Pattern 4: Durée en secondes (30", 45", etc.)
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}"'), ' ');

    // Pattern 5: Nombres isolés suivis de point (08., 10., etc.) - souvent des dates
    filtered = filtered.replaceAll(RegExp(r'\b\d{1,2}\.(?!\d)'), ' ');

    // Pattern 6: Dates avec points (10.08, 10.08., 10.08.2024, etc.)
    filtered = filtered.replaceAll(
        RegExp(r'\b\d{1,2}\.\d{1,2}\.?(?:\d{2,4})?\b'), ' ');

    // Pattern 7: Dates avec slashes (10/08, 10/08/24, 10/08/2024, etc.)
    // ATTENTION: On doit éviter de supprimer les patterns de tension comme 120/80
    // On vérifie que les nombres sont petits (<= 31 pour jours/mois)
    filtered = filtered.replaceAll(
        RegExp(r'\b([0-2]?\d|3[01])/([0-1]?\d|1[0-2])(?:/\d{2,4})?\b'), ' ');

    // Pattern 8: Dates avec tirets (10-08, 10-08-24, etc.)
    filtered = filtered.replaceAll(
        RegExp(r'\b([0-2]?\d|3[01])-([0-1]?\d|1[0-2])(?:-\d{2,4})?\b'), ' ');

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
