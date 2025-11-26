import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  /// Crée une copie de ce résultat avec les champs donnés remplacés.
  BloodPressureOcrResult copyWith({
    int? systolic,
    int? diastolic,
    int? pulse,
    double? confidence,
    String? rawText,
    String? error,
    bool clearError = false,
  }) {
    return BloodPressureOcrResult(
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      confidence: confidence ?? this.confidence,
      rawText: rawText ?? this.rawText,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'BloodPressureOcrResult(sys: $systolic, dia: $diastolic, pulse: $pulse, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Service OCR pour extraire les valeurs de tension artérielle depuis une image

class BloodPressureOcrService {
  // --- AJOUT IMPORTANT : Votre clé d'API ---
  // Remplacez "VOTRE_TOKEN_ICI" par votre vraie clé d'API DeepSeek/DeepInfra
  final String _apiKey = 'JEGxnMEtfC56EzXtv1FS8U5IYlWfmK9G';

  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath) async {
    debugPrint(
        'ℹ️ BloodPressureOcrService: Image reçue à l\'adresse : $imagePath');

    // --- Sécurité : Vérification de la clé API ---
    if (_apiKey == 'VOTRE_TOKEN_ICI') {
      debugPrint('❌ ERREUR : La clé d\'API n\'a pas été configurée.');
      return BloodPressureOcrResult(
        error: 'Clé API non configurée dans blood_pressure_ocr_service.dart',
      );
    }

    try {
      // 1. Préparer l'image (déjà fait)
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      debugPrint('✅ Image encodée en Base64.');

      // --- DÉBUT DE LA CONSTRUCTION DE LA REQUÊTE ---

      // 2. Définir l'URL de l'API (la destination)
      final apiUrl =
          Uri.parse('https://api.deepinfra.com/v1/openai/chat/completions');

      // 3. Préparer les en-têtes (votre "badge d'identification")
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // 4. Préparer le corps de la requête (votre "lettre" avec l'image)
      final body = jsonEncode({
        "model": "deepseek-ai/DeepSeek-OCR",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
              },
              {
                "type": "text",
                "text":
                    "Extrais uniquement les valeurs numériques pour la systole (SYS), la diastole (DIA) et le pouls (PUL) de cette image. Réponds uniquement avec les chiffres, sans texte supplémentaire."
              }
            ]
          }
        ]
      });

      // --- FIN DE LA CONSTRUCTION DE LA REQUÊTE ---

      debugPrint('🚀 Envoi de la requête à l\'API DeepSeek...');

      // 5. Envoyer la requête et attendre la réponse
      final response = await http.post(apiUrl, headers: headers, body: body);

      // 6. Afficher le résultat pour le test
      debugPrint('✅ Réponse reçue ! Statut: ${response.statusCode}');
      debugPrint('📦 Corps de la réponse: ${response.body}');

      // Pour l'instant, nous retournons un résultat simple
      return BloodPressureOcrResult(
        rawText: 'Réponse de l\'API: ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'appel API: $e');
      return BloodPressureOcrResult(
        rawText: 'Erreur d\'appel API.',
        error: e.toString(),
      );
    }
  }

  /// Libère les ressources.
  void dispose() {
    // Rien à faire ici pour l'instant
  }
}
