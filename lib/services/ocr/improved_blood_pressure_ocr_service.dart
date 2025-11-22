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
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 DÉBUT ANALYSE OCR TESSERACT');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📸 Image source: $imagePath');

      // ÉTAPE 1: Vérification de l'image source
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 ÉTAPE 1/5: Vérification de l\'image source');
      debugPrint('─────────────────────────────────────────────────────────');

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('❌ ÉCHEC: Image introuvable à $imagePath');
        throw Exception('Image introuvable: $imagePath');
      }

      final imageSize = await imageFile.length();
      debugPrint('✅ Image trouvée');
      debugPrint('   📦 Taille: ${(imageSize / 1024).toStringAsFixed(2)} KB');
      debugPrint('   📁 Chemin: $imagePath');

      // ÉTAPE 2: Preprocessing de l'image
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 ÉTAPE 2/5: Preprocessing de l\'image');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('🔄 Lancement du preprocessing...');
      debugPrint('   • Conversion en niveaux de gris');
      debugPrint('   • Augmentation du contraste');
      debugPrint('   • Sharpening (netteté)');
      debugPrint('   • Binarisation (noir/blanc)');

      final processedImagePath = await _preprocessingService.preprocessForOcr(imagePath);

      debugPrint('✅ Preprocessing terminé');
      debugPrint('   📁 Image prétraitée: $processedImagePath');

      // ÉTAPE 3: Configuration Tesseract
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 ÉTAPE 3/5: Configuration Tesseract OCR');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('⚙️ Configuration:');
      debugPrint('   • Langue: eng');
      debugPrint('   • PSM Mode: 6 (bloc uniforme)');
      debugPrint('   • Whitelist: 0123456789/: + SYS/DIA/PUL');
      debugPrint('   • Preserve spaces: Oui');
      debugPrint('   • Formats supportés: XXX/YY, XXX SYS, SYS XXX');

      // ÉTAPE 4: Analyse OCR avec Tesseract
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 ÉTAPE 4/5: Analyse OCR Tesseract');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('🔍 Lancement de l\'analyse Tesseract...');
      debugPrint('⏳ Ceci peut prendre 1-3 secondes...');

      final startTime = DateTime.now();

      String text = await FlutterTesseractOcr.extractText(
        processedImagePath,
        language: 'eng',
        args: {
          "psm": "6", // Page segmentation mode: bloc uniforme
          "preserve_interword_spaces": "1",
          "tessedit_char_whitelist": "0123456789/: SYSDIAPULsysdiapu", // Chiffres + labels SYS/DIA/PUL
        },
      );

      final duration = DateTime.now().difference(startTime);

      debugPrint('✅ Analyse Tesseract terminée');
      debugPrint('   ⏱️ Durée: ${duration.inMilliseconds}ms');
      debugPrint('   📝 Texte brut reconnu: "${text.isEmpty ? '(vide)' : text}"');
      debugPrint('   📏 Longueur: ${text.length} caractères');

      logger.i('OCR Tesseract Raw Text: $text (${duration.inMilliseconds}ms)');

      // Nettoyer le fichier temporaire si c'est une image prétraitée
      if (processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
          debugPrint('🗑️ Fichier temporaire supprimé: $processedImagePath');
        } catch (e) {
          debugPrint('⚠️ Impossible de supprimer le fichier temp: $e');
        }
      }

      // ÉTAPE 5: Parsing des valeurs
      debugPrint('');
      debugPrint('─────────────────────────────────────────────────────────');
      debugPrint('📋 ÉTAPE 5/5: Parsing des valeurs de tension');
      debugPrint('─────────────────────────────────────────────────────────');

      if (text.trim().isEmpty) {
        debugPrint('⚠️ Aucun texte détecté - tentative avec preprocessing adaptatif...');
        return await _extractWithAdaptivePreprocessing(imagePath);
      }

      debugPrint('🔍 Extraction des nombres et patterns...');
      final result = _parseBloodPressureValues(text);

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
      debugPrint('');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');

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
          "tessedit_char_whitelist": "0123456789/: SYSDIAPULsysdiapu",
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

    // STRATÉGIE PRIORITAIRE: Chercher les labels SYS/DIA/PUL avec les valeurs
    // Format 1: "120 SYS" "80 DIA" "70 PUL"
    // Format 2: "SYS 120" "DIA 80" "PUL 70"
    debugPrint('🔍 Recherche des labels SYS/DIA/PUL...');

    // Pattern pour "120 SYS" ou "SYS 120" (case insensitive)
    final sysPattern = RegExp(r'(?:(\d{2,3})\s*(?:SYS|sys|Sys))|(?:(?:SYS|sys|Sys)\s*(\d{2,3}))', caseSensitive: false);
    final sysMatch = sysPattern.firstMatch(cleanText);

    if (sysMatch != null) {
      final sysValue = sysMatch.group(1) ?? sysMatch.group(2);
      if (sysValue != null) {
        final val = int.parse(sysValue);
        if (_isValidSystolic(val)) {
          systolic = val;
          confidence = 0.98; // Très haute confiance avec label
          debugPrint('✅ Systolique trouvée avec label SYS: $systolic mmHg (98%)');
        }
      }
    }

    // Pattern pour "80 DIA" ou "DIA 80"
    final diaPattern = RegExp(r'(?:(\d{2,3})\s*(?:DIA|dia|Dia))|(?:(?:DIA|dia|Dia)\s*(\d{2,3}))', caseSensitive: false);
    final diaMatch = diaPattern.firstMatch(cleanText);

    if (diaMatch != null) {
      final diaValue = diaMatch.group(1) ?? diaMatch.group(2);
      if (diaValue != null) {
        final val = int.parse(diaValue);
        if (_isValidDiastolic(val)) {
          diastolic = val;
          if (systolic != null) confidence = 0.98; // Très haute confiance avec les deux labels
          debugPrint('✅ Diastolique trouvée avec label DIA: $diastolic mmHg (98%)');
        }
      }
    }

    // Pattern pour "70 PUL" ou "PUL 70" (aussi BPM, HR)
    final pulPattern = RegExp(r'(?:(\d{2,3})\s*(?:PUL|pul|Pul|BPM|bpm|HR|hr))|(?:(?:PUL|pul|Pul|BPM|bpm|HR|hr)\s*(\d{2,3}))', caseSensitive: false);
    final pulMatch = pulPattern.firstMatch(cleanText);

    if (pulMatch != null) {
      final pulValue = pulMatch.group(1) ?? pulMatch.group(2);
      if (pulValue != null) {
        final val = int.parse(pulValue);
        if (_isValidPulse(val)) {
          pulse = val;
          debugPrint('✅ Pouls trouvé avec label PUL: $pulse bpm');
        }
      }
    }

    // Si on a trouvé SYS et DIA avec les labels, on peut retourner directement
    if (systolic != null && diastolic != null) {
      debugPrint('🎯 Détection réussie avec labels SYS/DIA (confiance: ${(confidence * 100).toStringAsFixed(1)}%)');
      return BloodPressureOcrResult(
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        confidence: confidence,
        rawText: cleanText,
      );
    }

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
