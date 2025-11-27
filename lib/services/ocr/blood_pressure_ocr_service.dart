import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dr_cardio/config.dart';

class BloodPressureOcrResult {
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String? error;
  final bool isValid;
  final double confidence;
  final String rawText;

  BloodPressureOcrResult({
    this.systolic,
    this.diastolic,
    this.pulse,
    this.error,
    this.isValid = false,
    this.confidence = 0.0,
    this.rawText = '',
  });

  factory BloodPressureOcrResult.fromJson(Map<String, dynamic> json) {
    return BloodPressureOcrResult(
      systolic: _parseInt(json['systolic']),
      diastolic: _parseInt(json['diastolic']),
      pulse: _parseInt(json['pulse']),
      isValid: json['systolic'] != null && json['diastolic'] != null,
      confidence: 0.95,
      rawText: json.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  String toString() {
    if (error != null) {
      return 'BloodPressureOcrResult(error: $error)';
    }
    return 'BloodPressureOcrResult(sys: $systolic, dia: $diastolic, pulse: $pulse, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

class BloodPressureOcrService {

  /*
  Future<BloodPressureOcrResult> processImageOpenAI(String imagePath) async {
    if (openAiApiKey == 'YOUR_OPENAI_API_KEY') {
      return BloodPressureOcrResult(
        error: 'Clé API OpenAI non configurée dans lib/config.dart',
      );
    }

    try {
      final base64Image = await _imageToBase64(imagePath);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      };

      // Nouveau body compatible OpenAI Responses API
      final body = {
        "model": "gpt-4o-mini",
        "input": [
          {
            "role": "user",
            "content": [
              {
                "type": "input_text",
                "text": "Extraire systol, diastol et pouls de cette image"
              },
              {
                "type": "input_image",
                "image_url": "data:image/png;base64,$base64Image"
              }
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(_openAiApiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return _parseResponse(utf8.decode(response.bodyBytes));
      } else {
        return BloodPressureOcrResult(
          error: 'Erreur API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return BloodPressureOcrResult(
        error: "Erreur lors de l'appel à l'API OpenAI: $e",
      );
    }
  }
*/
  
  Future<BloodPressureOcrResult> processImage(String imagePath) async {
    // Vérifier que la clé API est configurée
    if (deepSeekApiKey.isEmpty || deepSeekApiKey == 'YOUR_DEEPSEEK_API_KEY') {
      return BloodPressureOcrResult(
        error: 'Clé API DeepSeek non configurée dans lib/config.dart',
      );
    }

    try {
      final base64Image = await _imageToBase64(imagePath);
      
      // Détection du type MIME
      final mimeType = _getMimeType(imagePath);

      // Format correct pour DeepSeek - texte seulement avec image en base64 dans le prompt
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $deepSeekApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'user',
              'content': 'Voici une image d\'un tensiomètre: data:$mimeType;base64,$base64Image\n\nExtrayez les valeurs de tension artérielle (systolique, diastolique) et le pouls. Répondez UNIQUEMENT en format JSON: {"systolic": nombre, "diastolic": nombre, "pulse": nombre}. Si une valeur n\'est pas lisible, utilisez null.'
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.1
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return _parseDeepSeekResponse(response.body);
      } else if (response.statusCode == 401) {
        return BloodPressureOcrResult(
          error: 'Clé API DeepSeek invalide ou expirée',
        );
      } else if (response.statusCode == 429) {
        return BloodPressureOcrResult(
          error: 'Quota API dépassé ou limite de requêtes atteinte',
        );
      } else {
        return BloodPressureOcrResult(
          error: 'Erreur API DeepSeek: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Erreur complète: $e');
      return BloodPressureOcrResult(
        error: "Erreur de connexion: ${e.toString()}",
      );
    }
  }

  BloodPressureOcrResult _parseDeepSeekResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      
      // Vérifier la structure de réponse DeepSeek
      if (decoded['choices'] == null || decoded['choices'].isEmpty) {
        return BloodPressureOcrResult(
          error: 'Format de réponse API invalide: pas de choix disponible',
          rawText: responseBody,
        );
      }

      final message = decoded['choices'][0]['message'];
      final content = message['content'] as String;

      // Nettoyer le contenu (enlever les ```json etc.)
      String cleanContent = content.trim();
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();

      // Parser le JSON
      final extractedData = jsonDecode(cleanContent) as Map<String, dynamic>;
      
      return BloodPressureOcrResult.fromJson(extractedData);

    } catch (e) {
      // Si le parsing JSON échoue, essayer d'extraire les nombres du texte
      return _extractNumbersFromText(responseBody);
    }
  }

  BloodPressureOcrResult _extractNumbersFromText(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      final content = decoded['choices'][0]['message']['content'] as String;
      
      // Expressions régulières pour trouver les nombres
      final systolicMatch = RegExp(r'systolic[":\s]+(\d+)').firstMatch(content);
      final diastolicMatch = RegExp(r'diastolic[":\s]+(\d+)').firstMatch(content);
      final pulseMatch = RegExp(r'pulse[":\s]+(\d+)').firstMatch(content);

      return BloodPressureOcrResult(
        systolic: systolicMatch != null ? int.tryParse(systolicMatch.group(1)!) : null,
        diastolic: diastolicMatch != null ? int.tryParse(diastolicMatch.group(1)!) : null,
        pulse: pulseMatch != null ? int.tryParse(pulseMatch.group(1)!) : null,
        rawText: content,
        isValid: systolicMatch != null && diastolicMatch != null,
        confidence: 0.7,
      );
    } catch (e) {
      return BloodPressureOcrResult(
        error: 'Erreur d\'extraction: ${e.toString()}',
        rawText: responseBody,
      );
    }
  }

  /// Convertit un fichier image en Base64
  Future<String> _imageToBase64(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Fichier image non trouvé: $imagePath');
      }
      final imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      throw Exception('Erreur conversion image: $e');
    }
  }

  /// Détermine le type MIME de l'image
  String _getMimeType(String imagePath) {
    final extension = imagePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void dispose() {
    // Rien à libérer
  }
}