import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dr_cardio/utils/logger.dart';
import 'package:image/image.dart' as img;

/// Service OCR utilisant l'API OCR.space
/// API gratuite avec excellente performance sur les affichages LCD
class OcrSpaceService {
  // Clé API gratuite OCR.space (limite: 25,000 requêtes/mois)
  // Note: Pour la production, utiliser une clé API personnalisée
  static const String _apiKey = 'K87899142388957';
  static const String _apiUrl = 'https://api.ocr.space/parse/image';

  /// Extrait le texte d'une image en utilisant OCR.space API
  ///
  /// Paramètres:
  /// - [imagePath]: Chemin de l'image à analyser
  /// - [language]: Langue du texte (défaut: 'eng' pour anglais)
  /// - [detectOrientation]: Détection automatique de l'orientation (défaut: true)
  /// - [scale]: Mise à l'échelle de l'image pour améliorer la précision (défaut: true)
  /// - [ocrEngine]: Moteur OCR à utiliser (1 ou 2, défaut: 2 - meilleur pour LCD)
  ///
  /// Retourne le texte extrait ou null en cas d'erreur
  Future<({String rawText, String? error})> extractText(
    String imagePath, {
    String language = 'eng',
    bool detectOrientation = true,
    bool scale = true,
    int ocrEngine = 2, // Moteur 2 est souvent meilleur pour les écrans LCD
  }) async {
    if (!await _checkInternetConnection()) {
      const errorMsg = 'Pas de connexion internet pour OCR.space';
      debugPrint('❌ $errorMsg');
      return (rawText: '', error: errorMsg);
    }

    try {
      var imageBytes = await File(imagePath).readAsBytes();
      final imageSizeMB = imageBytes.lengthInBytes / (1024 * 1024);
      debugPrint(
          'Taille initiale de l\\\'image: ${imageSizeMB.toStringAsFixed(2)} Mo');

      // Si l'image est > 500 Ko, on la compresse de manière plus agressive
      if (imageBytes.lengthInBytes > 500 * 1024) {
        debugPrint('Image > 500 Ko, compression agressive en cours...');
        img.Image? image = img.decodeImage(imageBytes);

        if (image != null) {
          // Redimensionner si la largeur est > 1000px
          if (image.width > 1000) {
            image = img.copyResize(image, width: 1000);
            debugPrint('Image redimensionnée à 1000px de large');
          }

          // Compresser en JPEG avec une qualité de 75%
          imageBytes = img.encodeJpg(image, quality: 75);
          final newSizeMB = imageBytes.lengthInBytes / (1024 * 1024);
          debugPrint(
              'Nouvelle taille de l\\\'image après compression: ${newSizeMB.toStringAsFixed(2)} Mo');
        }
      }

      final base64Image = base64Encode(imageBytes);

      final uri = Uri.parse(_apiUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['apikey'] = _apiKey
        ..fields['language'] = language
        ..fields['detectOrientation'] = detectOrientation.toString()
        ..fields['scale'] = scale.toString()
        ..fields['OCREngine'] = ocrEngine.toString()
        ..fields['base64Image'] = 'data:image/jpeg;base64,$base64Image';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['IsErroredOnProcessing'] == true) {
          final errorMsg = 'Erreur OCR.space: ${jsonResponse['ErrorMessage']}';
          debugPrint('❌ $errorMsg');
          logger.e(errorMsg);
          return (rawText: '', error: errorMsg);
        }

        if (jsonResponse['ParsedResults'] != null &&
            jsonResponse['ParsedResults'].isNotEmpty) {
          final rawText =
              jsonResponse['ParsedResults'][0]['ParsedText'] as String;
          debugPrint('✅ Texte extrait par OCR.space: \\\"$rawText\\\"');
          logger.i('Texte brut OCR.space: $rawText');
          return (rawText: rawText, error: null);
        } else {
          const errorMsg = 'Aucun texte détecté par OCR.space';
          debugPrint('⚠️ $errorMsg');
          return (rawText: '', error: errorMsg);
        }
      } else {
        final errorMsg =
            'Erreur API OCR.space (Code: ${response.statusCode}): $responseBody';
        debugPrint('❌ $errorMsg');
        logger.e(errorMsg);
        return (rawText: '', error: errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Exception lors de l\\\'appel à OCR.space: $e';
      debugPrint('❌ $errorMsg\\n$stackTrace');
      logger.e(errorMsg, stackTrace: stackTrace);
      return (rawText: '', error: errorMsg);
    }
  }

  /// Vérifie si une connexion internet est disponible
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('api.ocr.space').timeout(
        const Duration(seconds: 3),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Extrait le texte avec preprocessing de l'image pour améliorer la détection LCD
  ///
  /// Cette méthode applique un preprocessing avant d'envoyer à OCR.space
  /// pour maximiser les chances de détection sur les affichages LCD
  Future<String?> extractTextWithPreprocessing(
    String imagePath, {
    String language = 'eng',
  }) async {
    try {
      debugPrint('🔄 OCR.space avec preprocessing...');

      // Note: Le preprocessing est déjà géré par le service principal
      // Cette méthode est juste un wrapper pour cohérence
      final result = await extractText(
        imagePath,
        language: language,
        detectOrientation: true,
        scale: true,
        ocrEngine: 2, // Engine 2 meilleur pour les chiffres
      );
      return result.rawText;
    } catch (e) {
      debugPrint('❌ Erreur preprocessing OCR.space: $e');
      return null;
    }
  }
}
