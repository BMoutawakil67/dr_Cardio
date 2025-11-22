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

  /// Prétraitement avec isolation de la zone LCD uniquement
  /// Détecte et recadre automatiquement la zone d'affichage LCD
  Future<String> preprocessWithLcdIsolation(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing avec isolation LCD: Début...');

      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      debugPrint('✅ Image chargée: ${image.width}x${image.height}');

      // 1. Détecter et recadrer la zone LCD
      final croppedLcd = _detectAndCropLcdRegion(image);

      if (croppedLcd == null) {
        debugPrint('⚠️ Pas de zone LCD détectée, traitement sur image complète');
        // Si pas de zone détectée, continuer avec l'image complète
      } else {
        image = croppedLcd;
        debugPrint('✅ Zone LCD isolée: ${image.width}x${image.height}');
      }

      // 2. Niveaux de gris
      image = img.grayscale(image);

      // 3. Augmenter l'image pour améliorer la détection
      if (image.width < 800) {
        debugPrint('🔄 Agrandissement 2x de la zone LCD...');
        image = img.copyResize(image,
          width: image.width * 2,
          height: image.height * 2,
          interpolation: img.Interpolation.cubic
        );
      }

      // 4. Netteté
      debugPrint('🔄 Augmentation de la netteté...');
      image = _applySharpen(image);

      // 5. Contraste et luminosité agressifs
      debugPrint('🔄 Ajustement contraste/luminosité...');
      image = img.adjustColor(image,
        contrast: 1.8,    // Contraste très élevé
        brightness: 1.3,  // Luminosité élevée
        saturation: 0
      );

      // 6. Inversion si nécessaire
      final avgLuminance = _getAverageLuminance(image);
      debugPrint('📊 Luminance moyenne: $avgLuminance');

      if (avgLuminance < 100) {
        debugPrint('🔄 Inversion des couleurs (fond sombre détecté)');
        image = img.invert(image);
      }

      // 7. Binarisation stricte
      debugPrint('🔄 Binarisation...');
      image = _applyThreshold(image, threshold: 120);

      // 8. Dilatation pour renforcer les segments
      debugPrint('🔄 Renforcement des segments...');
      image = _applyDilate(image, iterations: 2); // Plus de dilatation

      // Sauvegarde
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/ocr_lcd_isolated_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(processedPath).writeAsBytes(img.encodeJpg(image, quality: 95));

      debugPrint('✅ Preprocessing LCD isolé terminé: $processedPath');
      return processedPath;
    } catch (e) {
      debugPrint('❌ Erreur preprocessing LCD isolé: $e');
      return imagePath;
    }
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

      // 1. Redimensionner intelligemment l'image pour optimiser OCR et mémoire
      final maxDimension = image.width > image.height ? image.width : image.height;
      final minDimension = image.width < image.height ? image.width : image.height;

      if (maxDimension < 800) {
        // Image petite : upscaler 2x pour améliorer la détection
        debugPrint('🔄 Image petite ($maxDimension px) - Agrandissement 2x...');
        image = img.copyResize(image,
          width: image.width * 2,
          height: image.height * 2,
          interpolation: img.Interpolation.cubic
        );
      } else if (maxDimension > 1600) {
        // Image trop grande : réduire pour économiser la mémoire
        final scale = 1600 / maxDimension;
        debugPrint('🔄 Image grande ($maxDimension px) - Réduction à 1600px (${(scale * 100).toStringAsFixed(0)}%)...');
        image = img.copyResize(image,
          width: (image.width * scale).toInt(),
          height: (image.height * scale).toInt(),
          interpolation: img.Interpolation.average
        );
      } else {
        debugPrint('✅ Taille optimale ($maxDimension px) - Pas de redimensionnement');
      }

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

  /// Détecte et isole la zone d'affichage LCD (rectangles sombres contenant les chiffres)
  /// Retourne l'image recadrée sur la zone LCD ou l'image originale si non trouvée
  img.Image? _detectAndCropLcdRegion(img.Image image) {
    debugPrint('🔍 Détection de la zone LCD...');

    // Convertir en niveaux de gris si ce n'est pas déjà fait
    final grayImage = img.grayscale(image);

    // Diviser l'image en grille et trouver les zones sombres
    final blockSize = 50; // Taille des blocs pour l'analyse
    final width = grayImage.width;
    final height = grayImage.height;

    // Liste des régions sombres potentielles (zones LCD)
    final List<Rectangle> darkRegions = [];

    // Analyser l'image par blocs
    for (int y = 0; y < height - blockSize; y += blockSize ~/ 2) {
      for (int x = 0; x < width - blockSize; x += blockSize ~/ 2) {
        final avgLum = _getBlockAverageLuminance(grayImage, x, y, blockSize, blockSize);

        // Détecter les zones sombres (écran LCD a fond sombre/gris)
        if (avgLum < 130) { // Seuil pour zones sombres
          darkRegions.add(Rectangle(x, y, blockSize, blockSize));
        }
      }
    }

    if (darkRegions.isEmpty) {
      debugPrint('⚠️ Aucune zone LCD détectée');
      return null;
    }

    // Fusionner les régions adjacentes et trouver la plus grande zone
    final mergedRegion = _mergeDarkRegions(darkRegions);

    if (mergedRegion == null) {
      debugPrint('⚠️ Impossible de fusionner les régions LCD');
      return null;
    }

    // Ajouter une marge autour de la zone détectée
    final margin = 20;
    final cropX = (mergedRegion.x - margin).clamp(0, width - 1);
    final cropY = (mergedRegion.y - margin).clamp(0, height - 1);
    final cropWidth = (mergedRegion.width + margin * 2).clamp(1, width - cropX);
    final cropHeight = (mergedRegion.height + margin * 2).clamp(1, height - cropY);

    debugPrint('✅ Zone LCD détectée: x=$cropX, y=$cropY, w=$cropWidth, h=$cropHeight');

    // Recadrer l'image sur la zone LCD
    return img.copyCrop(image,
      x: cropX.toInt(),
      y: cropY.toInt(),
      width: cropWidth.toInt(),
      height: cropHeight.toInt()
    );
  }

  /// Calcule la luminance moyenne d'un bloc de l'image
  double _getBlockAverageLuminance(img.Image image, int startX, int startY, int blockWidth, int blockHeight) {
    double total = 0;
    int count = 0;

    final endX = (startX + blockWidth).clamp(0, image.width);
    final endY = (startY + blockHeight).clamp(0, image.height);

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final pixel = image.getPixel(x, y);
        total += img.getLuminance(pixel);
        count++;
      }
    }

    return count > 0 ? total / count : 128;
  }

  /// Fusionne les régions sombres adjacentes pour trouver la zone LCD principale
  Rectangle? _mergeDarkRegions(List<Rectangle> regions) {
    if (regions.isEmpty) return null;

    // Trouver les limites englobantes de toutes les régions
    double minX = regions.first.x;
    double minY = regions.first.y;
    double maxX = regions.first.x + regions.first.width;
    double maxY = regions.first.y + regions.first.height;

    for (final region in regions) {
      if (region.x < minX) minX = region.x;
      if (region.y < minY) minY = region.y;
      if (region.x + region.width > maxX) maxX = region.x + region.width;
      if (region.y + region.height > maxY) maxY = region.y + region.height;
    }

    return Rectangle(minX, minY, maxX - minX, maxY - minY);
  }
}

/// Classe helper pour représenter un rectangle
class Rectangle {
  final double x;
  final double y;
  final double width;
  final double height;

  Rectangle(this.x, this.y, this.width, this.height);
}
