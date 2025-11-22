import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service de preprocessing d'images pour optimiser l'OCR
class ImagePreprocessingService {
  /// Prétraite une image pour améliorer la reconnaissance OCR
  /// Applique: niveaux de gris, contraste, netteté, binarisation
  Future<String> preprocessForOcr(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing: Chargement de $imagePath');

      // Charger l'image
      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      debugPrint('🖼️ Preprocessing: Image chargée (${image.width}x${image.height})');

      // Étape 1: Conversion en niveaux de gris
      image = _convertToGrayscale(image);
      debugPrint('🖼️ Preprocessing: Conversion en niveaux de gris OK');

      // Étape 2: Augmentation du contraste
      image = _enhanceContrast(image);
      debugPrint('🖼️ Preprocessing: Augmentation du contraste OK');

      // Étape 3: Augmentation de la netteté (sharpening)
      image = _sharpenImage(image);
      debugPrint('🖼️ Preprocessing: Augmentation de la netteté OK');

      // Étape 4: Binarisation (noir/blanc)
      image = _binarize(image);
      debugPrint('🖼️ Preprocessing: Binarisation OK');

      // Sauvegarder l'image traitée
      final processedPath = await _saveProcessedImage(image, imagePath);
      debugPrint('🖼️ Preprocessing: Image sauvegardée à $processedPath');

      return processedPath;
    } catch (e, stackTrace) {
      debugPrint('❌ Preprocessing Erreur: $e');
      debugPrint('❌ Stack: $stackTrace');
      // En cas d'erreur, retourner l'image originale
      return imagePath;
    }
  }

  /// Convertit l'image en niveaux de gris
  img.Image _convertToGrayscale(img.Image image) {
    return img.grayscale(image);
  }

  /// Augmente le contraste de l'image
  img.Image _enhanceContrast(img.Image image, {int amount = 150}) {
    // Augmentation du contraste pour mieux distinguer les chiffres
    return img.contrast(image, contrast: amount);
  }

  /// Augmente la netteté de l'image
  img.Image _sharpenImage(img.Image image) {
    // Application d'un filtre de netteté pour améliorer les contours
    // Matrice de convolution pour le sharpening:
    // [ 0, -1,  0]
    // [-1,  5, -1]
    // [ 0, -1,  0]
    return img.convolution(image, [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0
    ]);
  }

  /// Binarise l'image (conversion en noir et blanc pur)
  img.Image _binarize(img.Image image, {int threshold = 128}) {
    // Parcourir chaque pixel et le convertir en noir ou blanc
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        // Si la luminance est supérieure au seuil, blanc, sinon noir
        final newColor = luminance > threshold
            ? img.ColorRgb8(255, 255, 255)
            : img.ColorRgb8(0, 0, 0);

        image.setPixel(x, y, newColor);
      }
    }

    return image;
  }

  /// Sauvegarde l'image traitée dans un fichier temporaire
  Future<String> _saveProcessedImage(img.Image image, String originalPath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.png';
    final processedPath = '${tempDir.path}/$fileName';

    // Encoder en PNG
    final pngBytes = img.encodePng(image);

    // Sauvegarder
    final file = File(processedPath);
    await file.writeAsBytes(pngBytes);

    return processedPath;
  }

  /// Prétraitement alternatif avec seuil adaptatif
  /// Meilleur pour les conditions d'éclairage variables
  Future<String> preprocessWithAdaptiveThreshold(String imagePath) async {
    try {
      debugPrint('🖼️ Preprocessing adaptatif: Chargement de $imagePath');

      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Conversion en niveaux de gris
      image = img.grayscale(image);

      // Augmentation du contraste
      image = img.contrast(image, contrast: 150);

      // Réduction du bruit avec un flou gaussien léger
      image = img.gaussianBlur(image, radius: 1);

      // Binarisation avec seuil adaptatif par régions
      image = _adaptiveBinarize(image);

      // Sauvegarder
      final processedPath = await _saveProcessedImage(image, imagePath);
      debugPrint('🖼️ Preprocessing adaptatif: Image sauvegardée à $processedPath');

      return processedPath;
    } catch (e) {
      debugPrint('❌ Preprocessing adaptatif Erreur: $e');
      return imagePath;
    }
  }

  /// Binarisation adaptative par régions
  img.Image _adaptiveBinarize(img.Image image, {int blockSize = 11}) {
    // Pour chaque pixel, calculer le seuil basé sur la région locale
    final output = image.clone();
    final halfBlock = blockSize ~/ 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        // Calculer la moyenne des pixels dans la région locale
        int sum = 0;
        int count = 0;

        for (int dy = -halfBlock; dy <= halfBlock; dy++) {
          for (int dx = -halfBlock; dx <= halfBlock; dx++) {
            final px = x + dx;
            final py = y + dy;

            if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
              final pixel = image.getPixel(px, py);
              sum += img.getLuminance(pixel).toInt();
              count++;
            }
          }
        }

        final localThreshold = sum ~/ count;
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        final newColor = luminance > localThreshold
            ? img.ColorRgb8(255, 255, 255)
            : img.ColorRgb8(0, 0, 0);

        output.setPixel(x, y, newColor);
      }
    }

    return output;
  }
}
