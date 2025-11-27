import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class TesseractOcrService {
  Future<String> extractTextFromImage(String imagePath) async {
    // La logique Tesseract est temporairement désactivée pour le débogage.
    print('Tesseract OCR is currently disabled.');
    return '';
    /*
    print('TesseractOcrService.extractTextFromImage called with imagePath: '
        '\033[33m$imagePath\033[0m');
    try {
      final String? extractedText = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'eng',
      );
      print('--- Tesseract OCR Raw Result ---');
      print(extractedText);
      print(
          'Type of result: \u001b[36m\033[36m\033[36m${extractedText?.runtimeType ?? 'null'}\u001b[0m');
      print('-------------------------------');
      if (extractedText == null) {
        print('Tesseract returned null!');
        return '';
      }
      return extractedText;
    } catch (e, stack) {
      print('Error during Tesseract OCR: $e');
      print('Stacktrace: $stack');
      return '';
    }
    */
  }
}
