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

      // 1. Agrandir l'image (upscale 2x) pour améliorer la détection des petits chiffres LCD
      debugPrint('🔄 Agrandissement 2x de l\'image...');
      image = img.copyResize(image,
        width: image.width * 2,
        height: image.height * 2,
        interpolation: img.Interpolation.cubic // Interpolation de qualité
      );

      // 2. Niveaux de gris
      debugPrint('🔄 Conversion en niveaux de gris...');
      image = img.grayscale(image);

      // 3. Netteté (sharpening) pour renforcer les bords des segments LCD
      debugPrint('🔄 Augmentation de la netteté...');
      image = _applySharpen(image);

      // 4. Augmentation agressive du contraste et luminosité pour LCD
      debugPrint('🔄 Ajustement contraste/luminosité...');
      image = img.adjustColor(image,
        contrast: 1.6,    // Augmente le contraste de 60%
        brightness: 1.2,  // Augmente la luminosité de 20%
        saturation: 0     // Désaturation complète
      );

      // 5. Inversion si l'image a un fond sombre (segments clairs sur fond sombre)
      final avgLuminance = _getAverageLuminance(image);
      debugPrint('📊 Luminance moyenne: $avgLuminance');

      if (avgLuminance < 100) {
        debugPrint('🔄 Inversion des couleurs (fond sombre détecté)');
        image = img.invert(image);
      }

      // 6. Binarisation optimisée pour LCD (seuil plus strict)
      debugPrint('🔄 Binarisation...');
      image = _applyThreshold(image, threshold: 110);

      // 7. Morphologie: Dilate pour renforcer les segments (optionnel)
      debugPrint('🔄 Renforcement des segments LCD...');
      image = _applyDilate(image, iterations: 1);

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

  /// Applique un filtre de netteté (sharpening) à l'image
  img.Image _applySharpen(img.Image image) {
    // Implémentation manuelle du sharpening avec noyau 3x3
    // [  0, -1,  0 ]
    // [ -1,  5, -1 ]
    // [  0, -1,  0 ]
    final result = img.Image.from(image);

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        // Récupérer le pixel central et ses voisins
        final center = image.getPixel(x, y);
        final top = image.getPixel(x, y - 1);
        final bottom = image.getPixel(x, y + 1);
        final left = image.getPixel(x - 1, y);
        final right = image.getPixel(x + 1, y);

        // Appliquer le noyau de sharpening
        final centerLum = img.getLuminance(center);
        final topLum = img.getLuminance(top);
        final bottomLum = img.getLuminance(bottom);
        final leftLum = img.getLuminance(left);
        final rightLum = img.getLuminance(right);

        // Formule: 5*center - top - bottom - left - right
        final newLum = (5 * centerLum - topLum - bottomLum - leftLum - rightLum).clamp(0, 255).toInt();

        // Appliquer la nouvelle luminance
        result.setPixel(x, y, img.ColorRgb8(newLum, newLum, newLum));
      }
    }

    return result;
  }

  /// Applique une dilatation morphologique pour renforcer les segments
  img.Image _applyDilate(img.Image image, {int iterations = 1}) {
    for (int i = 0; i < iterations; i++) {
      final result = img.Image.from(image);

      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          // Vérifier les 8 voisins
          bool hasWhiteNeighbor = false;

          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              final pixel = image.getPixel(x + dx, y + dy);
              if (img.getLuminance(pixel) > 128) {
                hasWhiteNeighbor = true;
                break;
              }
            }
            if (hasWhiteNeighbor) break;
          }

          if (hasWhiteNeighbor) {
            result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
          }
        }
      }

      image = result;
    }

    return image;
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
