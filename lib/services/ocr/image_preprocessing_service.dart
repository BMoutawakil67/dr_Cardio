import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service de preprocessing d'images pour améliorer la détection OCR des affichages LCD
class ImagePreprocessingService {
  /// Prétraite une image pour améliorer la détection des chiffres LCD à 7 segments
  ///
  /// Optimisations appliquées :
  /// - Conversion en niveaux de gris
  /// - Augmentation du contraste (pour faire ressortir les chiffres LCD)
  /// - Augmentation de la netteté (sharpening)
  /// - Binarisation adaptative (noir/blanc)
  ///
  /// Retourne le chemin du fichier image prétraitée
  Future<String> preprocessForOcr(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing: Chargement de l\'image...');

      // 1. Charger l'image
      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('❌ Preprocessing: Échec du décodage de l\'image');
        return imagePath; // Retourner l'image originale en cas d'échec
      }

      debugPrint('✅ Preprocessing: Image chargée (${image.width}x${image.height})');

      // 2. Conversion en niveaux de gris
      debugPrint('🔄 Preprocessing: Conversion en niveaux de gris...');
      image = img.grayscale(image);

      // 3. Augmentation du contraste et luminosité (pour faire ressortir les chiffres LCD)
      debugPrint('🔄 Preprocessing: Augmentation du contraste et luminosité...');
      image = img.adjustColor(image,
        contrast: 1.2,  // Augmente le contraste de 20%
        brightness: 1.1, // Augmente la luminosité de 10%
        saturation: 0    // Désaturation complète pour le N&B
      );

      // 6. Binarisation (seuil adaptatif pour LCD)
      debugPrint('🔄 Preprocessing: Binarisation...');
      // Pour les LCD, on applique un seuil qui garde les segments lumineux
      image = _applyThreshold(image, threshold: 110);

      // 7. Sauvegarder l'image prétraitée
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/ocr_preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      debugPrint('💾 Preprocessing: Sauvegarde de l\'image prétraitée...');
      await File(processedPath).writeAsBytes(img.encodeJpg(image, quality: 95));

      debugPrint('✅ Preprocessing terminé: $processedPath');
      return processedPath;
    } catch (e) {
      debugPrint('❌ Erreur preprocessing: $e');
      return imagePath; // Retourner l'image originale en cas d'erreur
    }
  }

  /// Applique un seuil de binarisation à l'image
  img.Image _applyThreshold(img.Image image, {int threshold = 128}) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        // Si le pixel est plus clair que le seuil, le rendre blanc, sinon noir
        final newColor = luminance > threshold ?
          img.ColorRgb8(255, 255, 255) :
          img.ColorRgb8(0, 0, 0);

        image.setPixel(x, y, newColor);
      }
    }
    return image;
  }

  /// Prétraitement avec seuil adaptatif pour des conditions difficiles
  Future<String> preprocessWithAdaptiveThreshold(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing adaptatif: Chargement...');

      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      // Conversion en niveaux de gris
      image = img.grayscale(image);

      // Contraste et luminosité plus agressifs
      image = img.adjustColor(image,
        contrast: 1.5,    // Augmente le contraste de 50%
        brightness: 1.2,  // Augmente la luminosité de 20%
        saturation: 0
      );

      // Seuil plus bas pour capturer les segments LCD sombres
      image = _applyThreshold(image, threshold: 90);

      // Sauvegarde
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/ocr_adaptive_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(processedPath).writeAsBytes(img.encodeJpg(image, quality: 95));

      debugPrint('✅ Preprocessing adaptatif terminé');
      return processedPath;
    } catch (e) {
      debugPrint('❌ Erreur preprocessing adaptatif: $e');
      return imagePath;
    }
  }

  /// Prétraitement optimisé spécifiquement pour les affichages LCD à 7 segments
  /// Utilise des techniques avancées pour faire ressortir les segments LCD
  Future<String> preprocessForLcdDisplay(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing LCD: Début...');

      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      debugPrint('✅ Image chargée: ${image.width}x${image.height}');

      // 1. Niveaux de gris
      image = img.grayscale(image);

      // 2. Augmentation agressive du contraste et luminosité pour LCD
      image = img.adjustColor(image,
        contrast: 1.4,    // Augmente le contraste de 40%
        brightness: 1.15, // Augmente la luminosité de 15%
        saturation: 0     // Désaturation complète
      );

      // 5. Inversion si l'image a un fond sombre (segments clairs sur fond sombre)
      final avgLuminance = _getAverageLuminance(image);
      debugPrint('📊 Luminance moyenne: $avgLuminance');

      if (avgLuminance < 100) {
        debugPrint('🔄 Inversion des couleurs (fond sombre détecté)');
        image = img.invert(image);
      }

      // 6. Binarisation optimisée pour LCD
      image = _applyThreshold(image, threshold: 100);

      // Sauvegarde
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/ocr_lcd_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(processedPath).writeAsBytes(img.encodeJpg(image, quality: 95));

      debugPrint('✅ Preprocessing LCD terminé: $processedPath');
      return processedPath;
    } catch (e) {
      debugPrint('❌ Erreur preprocessing LCD: $e');
      return imagePath;
    }
  }

  /// Calcule la luminance moyenne de l'image
  double _getAverageLuminance(img.Image image) {
    double total = 0;
    int count = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        total += img.getLuminance(pixel);
        count++;
      }
    }

    return count > 0 ? total / count : 128;
  }
}
