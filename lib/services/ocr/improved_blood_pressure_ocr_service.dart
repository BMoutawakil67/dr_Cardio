import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:dr_cardio/services/ocr/image_preprocessing_service.dart';
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

/// Service OCR amélioré avec Tesseract + preprocessing pour extraire les valeurs de tension artérielle
class ImprovedBloodPressureOcrService {
  final ImagePreprocessingService _preprocessingService = ImagePreprocessingService();

  /// Analyse une image et extrait les valeurs de tension avec Tesseract
  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath) async {
    try {
      debugPrint('🔍 OCR Amélioré: Analyse de $imagePath');

      // Vérifier que l'image existe
      if (!await File(imagePath).exists()) {
        throw Exception('Image introuvable: $imagePath');
      }

      // Étape 1: Preprocessing de l'image
      debugPrint('🔍 OCR: Preprocessing de l\'image...');
      final processedImagePath = await _preprocessingService.preprocessForOcr(imagePath);

      // Étape 2: OCR avec Tesseract
      debugPrint('🔍 OCR: Analyse Tesseract en cours...');

      // Configurer Tesseract pour reconnaître uniquement les chiffres
      // PSM 7 = Traiter l'image comme une seule ligne de texte
      // PSM 6 = Assumer un bloc uniforme de texte
      String text = await FlutterTesseractOcr.extractText(
        processedImagePath,
        language: 'eng',
        args: {
          "psm": "6", // Page segmentation mode: bloc uniforme
          "preserve_interword_spaces": "1",
          "tessedit_char_whitelist": "0123456789/: ", // Uniquement chiffres et séparateurs
        },
      );

      debugPrint('🔍 OCR Tesseract: Texte reconnu: "$text"');
      logger.i('OCR Tesseract Raw Text: $text');

      // Nettoyer le fichier temporaire si c'est une image prétraitée
      if (processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
        } catch (e) {
          debugPrint('⚠️ Impossible de supprimer le fichier temp: $e');
        }
      }

      if (text.trim().isEmpty) {
        // Essayer avec preprocessing adaptatif
        debugPrint('🔍 OCR: Tentative avec preprocessing adaptatif...');
        return await _extractWithAdaptivePreprocessing(imagePath);
      }

      return _parseBloodPressureValues(text);
    } catch (e, stackTrace) {
      debugPrint('❌ OCR Erreur: $e');
      debugPrint('❌ Stack: $stackTrace');
      logger.e('Erreur OCR Tesseract: $e');
      return BloodPressureOcrResult(
        rawText: '',
        error: e.toString(),
      );
    }
  }

  /// Tentative avec preprocessing adaptatif en cas d'échec
  Future<BloodPressureOcrResult> _extractWithAdaptivePreprocessing(String imagePath) async {
    try {
      debugPrint('🔍 OCR: Preprocessing adaptatif...');
      final processedImagePath = await _preprocessingService.preprocessWithAdaptiveThreshold(imagePath);

      String text = await FlutterTesseractOcr.extractText(
        processedImagePath,
        language: 'eng',
        args: {
          "psm": "7", // Ligne unique
          "tessedit_char_whitelist": "0123456789/: ",
        },
      );

      debugPrint('🔍 OCR Adaptatif: Texte reconnu: "$text"');

      // Nettoyer le fichier temporaire
      if (processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
        } catch (e) {
          debugPrint('⚠️ Impossible de supprimer le fichier temp: $e');
        }
      }

      if (text.trim().isEmpty) {
        return BloodPressureOcrResult(
          rawText: '(aucun texte détecté)',
          error: 'Aucun texte détecté dans l\'image après preprocessing',
        );
      }

      return _parseBloodPressureValues(text);
    } catch (e) {
      debugPrint('❌ OCR Adaptatif Erreur: $e');
      return BloodPressureOcrResult(
        rawText: '',
        error: 'Échec du preprocessing adaptatif: $e',
      );
    }
  }

  /// Parse le texte reconnu pour extraire les valeurs de tension
  BloodPressureOcrResult _parseBloodPressureValues(String text) {
    // Nettoyer le texte
    final cleanText = text.replaceAll('\n', ' ').replaceAll('  ', ' ').trim();

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

    // Stratégie 1: Chercher un pattern "SYS/DIA" ou "XXX/YY" ou "XXX YY"
    // Format typique: "120/80" ou "120 80" ou "120 / 80"
    final slashPattern = RegExp(r'(\d{2,3})\s*[/\\:]\s*(\d{2,3})');
    final slashMatch = slashPattern.firstMatch(cleanText);

    if (slashMatch != null) {
      final val1 = int.parse(slashMatch.group(1)!);
      final val2 = int.parse(slashMatch.group(2)!);
      if (_isValidSystolic(val1) && _isValidDiastolic(val2)) {
        systolic = val1;
        diastolic = val2;
        confidence = 0.95;
        debugPrint('✅ Pattern trouvé: $systolic/$diastolic (confiance: ${confidence * 100}%)');
      }
    }

    // Stratégie 2: Chercher deux nombres consécutifs sans séparateur
    if (systolic == null || diastolic == null) {
      final consecutivePattern = RegExp(r'(\d{2,3})\s+(\d{2,3})');
      final consecutiveMatch = consecutivePattern.firstMatch(cleanText);

      if (consecutiveMatch != null) {
        final val1 = int.parse(consecutiveMatch.group(1)!);
        final val2 = int.parse(consecutiveMatch.group(2)!);
        if (_isValidSystolic(val1) && _isValidDiastolic(val2)) {
          systolic = val1;
          diastolic = val2;
          confidence = 0.85;
          debugPrint('✅ Nombres consécutifs trouvés: $systolic $diastolic (confiance: ${confidence * 100}%)');
        }
      }
    }

    // Stratégie 3: Si pas trouvé, chercher les nombres dans les plages valides
    if (systolic == null || diastolic == null) {
      // Filtrer les nombres dans les plages de tension
      final systolicCandidates = numbers.where(_isValidSystolic).toList();
      final diastolicCandidates = numbers.where(_isValidDiastolic).toList();

      if (systolicCandidates.isNotEmpty && diastolicCandidates.isNotEmpty) {
        // Prendre le plus grand comme systolique
        systolic = systolicCandidates.reduce((a, b) => a > b ? a : b);

        // Pour la diastolique, chercher une valeur cohérente avec la systolique
        // (généralement systolique - 30 à systolique - 60)
        diastolic = diastolicCandidates.firstWhere(
          (d) => d < systolic! && d > (systolic - 80),
          orElse: () => diastolicCandidates.reduce((a, b) => a < b ? a : b),
        );

        // Vérifier la cohérence (systolique > diastolique)
        if (systolic <= diastolic) {
          // Inverser si nécessaire
          final temp = systolic;
          systolic = diastolic;
          diastolic = temp;
        }
        confidence = 0.7;
        debugPrint('✅ Valeurs trouvées par plages: $systolic/$diastolic (confiance: ${confidence * 100}%)');
      }
    }

    // Stratégie 4: Chercher le pouls (généralement entre 40 et 200)
    final pulseCandidates = numbers.where(_isValidPulse).toList();
    // Exclure systolic et diastolic des candidats pulse
    pulseCandidates.removeWhere((n) => n == systolic || n == diastolic);

    if (pulseCandidates.isNotEmpty) {
      // Prendre la valeur la plus proche de 75 bpm (pouls moyen)
      pulse = pulseCandidates.reduce((a, b) {
        final diffA = (a - 75).abs();
        final diffB = (b - 75).abs();
        return diffA < diffB ? a : b;
      });
      debugPrint('✅ Pouls trouvé: $pulse bpm');
    }

    // Ajuster la confiance finale
    if (systolic != null && diastolic != null) {
      // Bonus de confiance si on a aussi le pouls
      if (pulse != null) {
        confidence = (confidence + 0.05).clamp(0.0, 1.0);
      }

      // Bonus si les valeurs sont cohérentes (différence typique)
      final diff = systolic - diastolic;
      if (diff >= 20 && diff <= 80) {
        confidence = (confidence + 0.05).clamp(0.0, 1.0);
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

  /// Extrait tous les nombres d'une chaîne (2-3 chiffres)
  List<int> _extractNumbers(String text) {
    final numberPattern = RegExp(r'\b\d{2,3}\b');
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

  /// Libérer les ressources (si nécessaire)
  void dispose() {
    // Tesseract ne nécessite pas de cleanup explicite
    debugPrint('🔍 OCR Service: Ressources libérées');
  }
}
