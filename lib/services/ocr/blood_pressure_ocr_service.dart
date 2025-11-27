import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dr_cardio/config.dart';

/// Représente le résultat structuré du processus OCR.
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

  factory BloodPressureOcrResult.fromOcrResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return BloodPressureOcrResult(
        rawText: responseBody,
        systolic: data['systolic'] as int?,
        diastolic: data['diastolic'] as int?,
        pulse: data['pulse'] as int?,
      );
    } catch (e) {
      return BloodPressureOcrResult(
        rawText: responseBody,
        error: 'Erreur de parsing JSON: $e',
      );
    }
  }

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
    if (error != null) {
      return 'BloodPressureOcrResult(error: $error)';
    }
    return 'BloodPressureOcrResult(sys: $systolic, dia: $diastolic, pulse: $pulse, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Service pour extraire les données de tension artérielle à partir d'une image.
class BloodPressureOcrService {
  static const String _openAiApiUrl = 'https://api.openai.com/v1/responses';

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
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.deepsee-ocr.ai/v1/ocr'));
      request.headers['Authorization'] = 'Bearer $deepSeekApiKey';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', 'png'),
      ));
      request.fields['prompt'] = 'Extraire systole, diastol et pouls';

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // parser les valeurs systole, diastol et pouls selon la réponse
        return BloodPressureOcrResult(
          systolic: json["systol"],
          diastolic: json["diastol"],
          pulse: json["pouls"],
        );
      } else {
        return BloodPressureOcrResult(
          error: 'Erreur DeepSeek: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return BloodPressureOcrResult(
        error: "Erreur lors de l'appel à DeepSeek: $e",
      );
    }
  }

  /// Convertit un fichier image en une chaîne Base64.
  Future<String> _imageToBase64(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    return base64Encode(imageBytes);
  }

  BloodPressureOcrResult _parseResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      final content = decoded['choices'][0]['message']['content'] as String;

      final jsonContent = jsonDecode(content) as Map<String, dynamic>;

      final systolic = jsonContent['systolic'] as int?;
      final diastolic = jsonContent['diastolic'] as int?;
      final pulse = jsonContent['pulse'] as int?;

      final bool isValid =
          systolic != null && diastolic != null && pulse != null;

      return BloodPressureOcrResult(
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        rawText: content,
        isValid: isValid,
        confidence: isValid ? 0.95 : 0.5,
      );
    } catch (e) {
      return BloodPressureOcrResult(
        error: 'Erreur de parsing: ${e.toString()}',
        rawText:
            responseBody, // En cas d'erreur, le texte brut est le corps de la réponse
      );
    }
  }

  void dispose() {
    // Rien à libérer pour l'instant.
  }
}
