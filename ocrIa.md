Utiliser l’API OCR DeepSeek dans Flutter
1. Obtenir et configurer l’accès à DeepSeek-OCR
DeepSeek-OCR est disponible via des plateformes tierces (par ex. Clarifai ou DeepInfra) qui fournissent un endpoint compatible OpenAI
clarifai.com
. Inscrivez-vous sur la plateforme de votre choix et récupérez un jeton d’accès (PAT/API token). Par exemple, sur Clarifai créez un Personal Access Token dans Settings > Secrets
docs.clarifai.com
. Sur DeepInfra (qui héberge le modèle DeepSeek-OCR), votre token se trouve dans le tableau de bord utilisateur
deepinfra.com
. Stockez ce jeton dans votre application Flutter (en tant que variable d’environnement ou dans le code) : il sera utilisé dans l’en-tête HTTP Authorization: Bearer VOTRE_TOKEN.
Astuce : l’API étant compatible OpenAI, l’URL de base pour DeepInfra est https://api.deepinfra.com/v1/openai/chat/completions 
deepinfra.com
. Sur Clarifai elle est similaire, par ex. https://api.deepseek.com/chat/completions. Dans tous les cas, incluez votre jeton dans l’en-tête Authorization.
2. Envoyer une image depuis Flutter vers l’API
Il faut envoyer l’image (ou son URL) dans le corps JSON de la requête. DeepSeek-OCR attend un format “chat” OpenAI : on passe un message de rôle user dont le contenu est l’image. La façon la plus simple est de convertir l’image en base64 et de la placer dans un champ image_url. Par exemple, avec le package http en Flutter :
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> sendImage(File imageFile) async {
  // Lire l’image et encoder en base64
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  final apiUrl = Uri.parse('https://api.deepinfra.com/v1/openai/chat/completions');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer VOTRE_TOKEN',
  };
  final body = jsonEncode({
    "model": "deepseek-ai/DeepSeek-OCR",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "image_url",
            "image_url": {"url": "data:image/png;base64,$base64Image"}
          }
        ]
      }
    ]
  });

  final response = await http.post(apiUrl, headers: headers, body: body);
  if (response.statusCode == 200) {
    print("Réponse de l’API : ${response.body}");
  } else {
    print("Erreur HTTP : ${response.statusCode}");
  }
}
Ce code lit le fichier image, le convertit en chaîne Base64 puis l’envoie dans le JSON selon le format DeepInfra
deepinfra.com
deepinfra.com
. Vous pouvez bien sûr utiliser dio ou tout autre client HTTP Flutter de la même manière, en encodant le corps JSON (voir exemple cURL dans les docs DeepInfra
deepinfra.com
deepinfra.com
). Si l’image est déjà accessible via une URL publique, vous pouvez alternativement passer "url": "https://monimage.png" sans base64.
3. Parser la réponse JSON pour extraire les valeurs
L’API retourne une réponse JSON de type chat completion. En Flutter on la récupère avec jsonDecode(response.body)
docs.flutter.dev
. Le texte OCR extrait se trouve dans choices[0].message.content (une chaîne de caractères). Par exemple :
final result = jsonDecode(response.body) as Map<String, dynamic>;
final content = result['choices'][0]['message']['content'] as String;
Ce content contient normalement les valeurs de pression et de pouls (par ex. "Tension : 120/80 mmHg, Pouls : 70 bpm"). Pour en extraire les nombres, on peut utiliser des expressions régulières en Dart. Par exemple :
// Exemple d’extraction numérique à partir du texte OCR
final systoleMatch  = RegExp(r'(\d+)\s*/').firstMatch(content);
final diastoleMatch = RegExp(r'/\s*(\d+)').firstMatch(content);
final poulsMatch    = RegExp(r'(\d+)\s*bpm').firstMatch(content);

if (systoleMatch != null && diastoleMatch != null) {
  int systole  = int.parse(systoleMatch.group(1)!);
  int diastole = int.parse(diastoleMatch.group(1)!);
  int pouls    = int.parse(poulsMatch?.group(1) ?? '0');
  print('Systole: $systole, Diastole: $diastole, Pouls: $pouls');
}
Cette approche utilise jsonDecode pour obtenir le champ texte OCR
docs.flutter.dev
, puis RegExp pour isoler les nombres associés à la systole, diastole et pouls. Adaptez le motif selon le format exact renvoyé (on peut chercher mmHg ou bpm).
4. Prétraitements d’image côté Flutter
Pour de meilleurs résultats, vous pouvez prétraiter l’image avant envoi :
Compression : réduisez la taille/qualité de l’image (par ex. avec le package flutter_image_compress) afin de limiter la latence réseau et respecter les limites de l’API.
Orientation : corrigez l’orientation si nécessaire (par ex. avec autoCorrectionAngle: true de flutter_image_compress) pour éviter que l’API lise l’image de biais
stackoverflow.com
.
Format/Redimensionnement : assurez-vous d’envoyer un format supporté (PNG/JPEG) et ajustez la résolution (par ex. 1024×1024 max) pour de bonnes performances.
Conversion en Base64 : comme montré ci-dessus, utilisez file.readAsBytes() puis base64Encode(bytes)
geeksforgeeks.org
 pour encoder l’image dans le JSON.
En-tête Flutter : n’oubliez pas d’ajouter la permission Internet dans AndroidManifest.xml (et entitlements pour iOS/macOS) pour les requêtes réseau
docs.flutter.dev
.
Ces étapes de prétraitement améliorent la vitesse et la fiabilité de l’OCR avant d’envoyer l’image à l’API DeepSeek. En résumé, prenez l’image (via un plugin comme image_picker), compressez/ajustez-la, encodez en base64, puis appelez l’API comme décrit ci-dessus. Les exemples de code fournis illustrent chaque étape clé.