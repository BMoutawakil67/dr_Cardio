import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dr_cardio/utils/logger.dart';

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
  Future<String?> extractText(
    String imagePath, {
    String language = 'eng',
    bool detectOrientation = true,
    bool scale = true,
    int ocrEngine = 2, // Engine 2 est meilleur pour les chiffres LCD
  }) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🌐 OCR.space API - Début');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📸 Image: $imagePath');
      debugPrint('🔧 Moteur: Engine $ocrEngine (optimisé pour LCD)');

      // Vérifier la connexion internet
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        debugPrint('⚠️ Pas de connexion internet - OCR.space ignoré');
        return null;
      }

      debugPrint('✅ Connexion internet disponible');

      // Lire le fichier image
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('❌ Image introuvable: $imagePath');
        return null;
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugPrint('📦 Image encodée (${(imageBytes.length / 1024).toStringAsFixed(2)} KB)');
      debugPrint('🚀 Envoi de la requête à OCR.space...');

      final startTime = DateTime.now();

      // Préparer la requête
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Headers
      request.headers['apikey'] = _apiKey;

      // Paramètres
      request.fields['language'] = language;
      request.fields['isOverlayRequired'] = 'false';
      request.fields['detectOrientation'] = detectOrientation.toString();
      request.fields['scale'] = scale.toString();
      request.fields['OCREngine'] = ocrEngine.toString();
      request.fields['base64Image'] = 'data:image/jpeg;base64,$base64Image';

      // Envoyer la requête
      final response = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏱️ Timeout OCR.space (15s)');
          throw TimeoutException('OCR.space timeout');
        },
      );

      final duration = DateTime.now().difference(startTime);
      debugPrint('⏱️ Réponse reçue en ${duration.inMilliseconds}ms');

      // Lire la réponse
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        debugPrint('❌ Erreur HTTP ${response.statusCode}');
        debugPrint('Response: $responseBody');
        logger.e('OCR.space HTTP Error: ${response.statusCode}');
        return null;
      }

      // Parser la réponse JSON
      final jsonResponse = json.decode(responseBody);

      debugPrint('📋 Parsing de la réponse JSON...');

      // Vérifier les erreurs
      if (jsonResponse['IsErroredOnProcessing'] == true) {
        final errorMessage = jsonResponse['ErrorMessage']?.join(', ') ?? 'Erreur inconnue';
        debugPrint('❌ Erreur OCR.space: $errorMessage');
        logger.e('OCR.space Processing Error: $errorMessage');
        return null;
      }

      // Extraire le texte
      final parsedResults = jsonResponse['ParsedResults'];
      if (parsedResults == null || parsedResults.isEmpty) {
        debugPrint('⚠️ Aucun résultat retourné par OCR.space');
        return null;
      }

      final extractedText = parsedResults[0]['ParsedText'] as String?;

      if (extractedText == null || extractedText.trim().isEmpty) {
        debugPrint('⚠️ Texte extrait vide');
        return null;
      }

      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ OCR.space - Succès');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📝 Texte extrait: "$extractedText"');
      debugPrint('⏱️ Durée totale: ${duration.inMilliseconds}ms');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');

      logger.i('OCR.space Success: "$extractedText" (${duration.inMilliseconds}ms)');

      return extractedText.trim();

    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout OCR.space: $e');
      logger.w('OCR.space Timeout: $e');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur OCR.space: $e');
      debugPrint('Stack trace: $stackTrace');
      logger.e('OCR.space Error: $e');
      return null;
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
      return await extractText(
        imagePath,
        language: language,
        detectOrientation: true,
        scale: true,
        ocrEngine: 2, // Engine 2 meilleur pour les chiffres
      );
    } catch (e) {
      debugPrint('❌ Erreur preprocessing OCR.space: $e');
      return null;
    }
  }
}
