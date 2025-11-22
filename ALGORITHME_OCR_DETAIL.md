# 🔬 Algorithme OCR Tesseract - Détail Complet

## 📚 Introduction - Qu'est-ce que Tesseract OCR ?

**Tesseract** est un moteur OCR (Optical Character Recognition) open-source développé par **Google**. C'est l'un des OCR les plus précis au monde pour la reconnaissance de texte.

### Architecture de Tesseract

```
┌──────────────────────────────────────────────────────────┐
│                    TESSERACT OCR v4/v5                   │
├──────────────────────────────────────────────────────────┤
│  1. Image Preprocessing (Prétraitement)                 │
│  2. Layout Analysis (Analyse de la mise en page)         │
│  3. Line & Word Segmentation (Segmentation)              │
│  4. LSTM Neural Network (Réseau de neurones)             │
│  5. Character Recognition (Reconnaissance caractères)    │
│  6. Post-processing (Post-traitement)                    │
└──────────────────────────────────────────────────────────┘
```

### Composants clés

1. **Fichiers .traineddata** : Modèles pré-entraînés (LSTM) pour chaque langue
   - `eng.traineddata` : Anglais (~10MB)
   - Contient les poids du réseau neuronal
   - Requis pour que Tesseract fonctionne

2. **Page Segmentation Mode (PSM)** : Comment Tesseract interprète l'image
   - PSM 6 : Bloc uniforme de texte (pour écrans LCD)
   - PSM 7 : Une seule ligne de texte
   - PSM 11 : Texte épars sans ordre

3. **Whitelist** : Caractères autorisés (filtre)
   - `"0123456789/: "` : Uniquement chiffres et séparateurs
   - Améliore la précision en éliminant les fausses détections

---

## 🔄 Algorithme Complet : Étape par Étape

### Vue d'ensemble

```
┌─────────────────┐
│  Photo capture  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ ÉTAPE 1: Vérification de l'image source                │
│ • Vérifier que le fichier existe                       │
│ • Obtenir la taille du fichier                         │
│ LOG: "✅ Image trouvée - Taille: XX KB"                │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ ÉTAPE 2: Preprocessing de l'image                      │
│                                                         │
│ 2.1 Conversion en niveaux de gris                      │
│     Input: Image RGB couleur                           │
│     Output: Image grayscale (1 canal)                  │
│     LOG: "Conversion en niveaux de gris OK"            │
│                                                         │
│ 2.2 Augmentation du contraste (+150)                   │
│     Input: Image grayscale                             │
│     Output: Image avec contraste amplifié              │
│     LOG: "Augmentation du contraste OK"                │
│                                                         │
│ 2.3 Sharpening (netteté)                               │
│     Technique: Unsharp mask                            │
│     - Créer un flou gaussien (radius=1)                │
│     - Calculer différence (original - flou)            │
│     - Amplifier × 1.5                                  │
│     LOG: "Augmentation de la netteté OK"               │
│                                                         │
│ 2.4 Binarisation (noir/blanc)                          │
│     Seuil: 128 (0-255)                                 │
│     If luminance > 128 → Blanc (255)                   │
│     Else → Noir (0)                                    │
│     LOG: "Binarisation OK"                             │
│                                                         │
│ 2.5 Sauvegarde image prétraitée                        │
│     Path: /tmp/processed_TIMESTAMP.png                 │
│     LOG: "Image sauvegardée à /tmp/..."               │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ ÉTAPE 3: Configuration Tesseract                       │
│                                                         │
│ • Langue: "eng" (English)                              │
│   Fichier requis: assets/tessdata/eng.traineddata      │
│                                                         │
│ • PSM Mode: "6" (bloc uniforme)                        │
│   Optimal pour écrans LCD/LED de tensiomètres          │
│                                                         │
│ • Whitelist: "0123456789/: "                           │
│   Ne reconnaît QUE les chiffres et séparateurs         │
│                                                         │
│ • Preserve spaces: "1"                                 │
│   Garde les espaces entre les nombres                  │
│                                                         │
│ LOG: "⚙️ Configuration: eng, PSM 6, whitelist..."      │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ ÉTAPE 4: Analyse OCR Tesseract                         │
│                                                         │
│ ⏱️ Chronomètre: start                                   │
│                                                         │
│ FlutterTesseractOcr.extractText()                      │
│ ├─ Charge eng.traineddata (modèle LSTM)               │
│ ├─ Analyse l'image prétraitée                         │
│ ├─ Détecte les blocs de texte                         │
│ ├─ Segmente en lignes                                 │
│ ├─ Segmente en caractères                             │
│ ├─ Passe chaque caractère dans le réseau neuronal     │
│ └─ Retourne le texte reconnu                          │
│                                                         │
│ ⏱️ Chronomètre: stop                                    │
│                                                         │
│ Output: "120/80 72" (exemple)                          │
│                                                         │
│ LOG: "✅ Analyse terminée - Durée: XXXms"              │
│ LOG: "📝 Texte reconnu: 120/80 72"                     │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ ÉTAPE 5: Parsing des valeurs                           │
│                                                         │
│ 5.1 Nettoyage du texte                                 │
│     • Supprimer \n → espace                            │
│     • Supprimer espaces doubles                        │
│     LOG: "Texte nettoyé: ..."                          │
│                                                         │
│ 5.2 Extraction des nombres                             │
│     Pattern regex: \b\d{2,3}\b                         │
│     Trouve tous les nombres de 2-3 chiffres            │
│     Ex: "120/80 72" → [120, 80, 72]                    │
│     LOG: "Nombres extraits: [120, 80, 72]"             │
│                                                         │
│ 5.3 Stratégie 1: Pattern XXX/YY                        │
│     Regex: (\d{2,3})\s*[/\\:]\s*(\d{2,3})             │
│     Cherche format "120/80" ou "120:80"                │
│     If trouvé:                                         │
│       • Systolique = val1                              │
│       • Diastolique = val2                             │
│       • Confiance = 95%                                │
│     LOG: "✅ Pattern trouvé: 120/80 (95%)"             │
│                                                         │
│ 5.4 Stratégie 2: Deux nombres consécutifs              │
│     Pattern: (\d{2,3})\s+(\d{2,3})                    │
│     Cherche "120 80"                                   │
│     If trouvé:                                         │
│       • Systolique = val1                              │
│       • Diastolique = val2                             │
│       • Confiance = 85%                                │
│     LOG: "✅ Nombres consécutifs: 120 80 (85%)"        │
│                                                         │
│ 5.5 Stratégie 3: Plages valides                        │
│     Filtrer par plages médicales:                      │
│     • Systolique: 70-250 mmHg                          │
│     • Diastolique: 40-150 mmHg                         │
│     Prendre le plus grand comme systolique             │
│     Confiance = 70%                                    │
│     LOG: "✅ Valeurs par plages: 120/80 (70%)"         │
│                                                         │
│ 5.6 Détection du pouls                                 │
│     Plage: 30-220 bpm                                  │
│     Exclure systolique et diastolique                  │
│     Prendre le plus proche de 75 bpm                   │
│     LOG: "✅ Pouls trouvé: 72 bpm"                     │
│                                                         │
│ 5.7 Ajustement de la confiance finale                  │
│     Bonus +5% si pouls détecté                         │
│     Bonus +5% si différence cohérente (20-80)          │
│     LOG: "📊 Confiance finale: 95%"                    │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ RÉSULTAT FINAL                                          │
│                                                         │
│ BloodPressureOcrResult:                                │
│   • systolic: 120 mmHg                                 │
│   • diastolic: 80 mmHg                                 │
│   • pulse: 72 bpm                                      │
│   • confidence: 0.95 (95%)                             │
│   • rawText: "120/80 72"                               │
│   • isValid: true                                      │
│                                                         │
│ LOG: "═══ RÉSULTAT FINAL ═══"                          │
│ LOG: "💉 Systolique: 120 mmHg"                         │
│ LOG: "💉 Diastolique: 80 mmHg"                         │
│ LOG: "❤️ Pouls: 72 bpm"                                │
│ LOG: "📊 Confiance: 95.0%"                             │
│ LOG: "✓ Valide: Oui"                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Détail du Preprocessing d'Images

### Pourquoi le preprocessing est crucial ?

Les tensiomètres affichent souvent :
- ❌ Chiffres à 7 segments (difficile pour OCR standard)
- ❌ Reflets sur l'écran LCD
- ❌ Contraste faible
- ❌ Éclairage variable
- ❌ Photos floues

Le preprocessing transforme ces défis en avantages !

### Technique 1: Niveaux de gris

**Avant:**
```
Pixel RGB: (245, 247, 250) → 3 canaux
```

**Après:**
```
Pixel Grayscale: 246 → 1 canal
Formule: 0.299*R + 0.587*G + 0.114*B
```

**Avantages:**
- Réduction du bruit de couleur
- Traitement 3× plus rapide
- Focus sur la luminance (intensité)

### Technique 2: Augmentation du contraste

**Formule:**
```
newPixel = ((pixel - 128) × factor) + 128
factor = 1.5 (augmentation de 50%)
```

**Effet:**
```
Avant: Gris clair (180) vs Gris foncé (100) → Différence: 80
Après:  Blanc (245)    vs Noir (20)         → Différence: 225
```

### Technique 3: Sharpening (Unsharp Mask)

**Algorithme:**
```
1. original = Image originale
2. blurred = GaussianBlur(original, radius=1)
3. mask = original - blurred
4. sharpened = original + (mask × 1.5)
```

**Exemple sur un bord:**
```
Original:  [100, 100, 150, 150, 150]
Blurred:   [100, 110, 140, 150, 150]
Mask:      [  0, -10,  10,   0,   0]
Sharpened: [100,  85, 165, 150, 150]
           └─── Bord accentué ───┘
```

### Technique 4: Binarisation

**Seuil fixe à 128:**
```
For each pixel:
  If luminance > 128:
    pixel = 255 (blanc)
  Else:
    pixel = 0 (noir)
```

**Résultat:**
```
Avant: [120, 135, 90, 200, 180, 100]
Après: [  0, 255,  0, 255, 255,   0]
       └── Noir/Blanc pur ──┘
```

---

## 🎯 Stratégies de Parsing - Détail

### Stratégie 1: Pattern avec slash (95% confiance)

```regex
Pattern: (\d{2,3})\s*[/\\:]\s*(\d{2,3})
```

**Exemples reconnus:**
- `120/80` ✅
- `120 / 80` ✅
- `120:80` ✅
- `120\80` ✅

**Code:**
```dart
if (slashMatch != null) {
  val1 = int.parse(slashMatch.group(1)!); // 120
  val2 = int.parse(slashMatch.group(2)!); // 80

  if (_isValidSystolic(val1) && _isValidDiastolic(val2)) {
    systolic = val1;
    diastolic = val2;
    confidence = 0.95; // Très haute confiance
  }
}
```

### Stratégie 2: Nombres consécutifs (85% confiance)

```regex
Pattern: (\d{2,3})\s+(\d{2,3})
```

**Exemples:**
- `120 80` ✅
- `140  90` ✅

### Stratégie 3: Plages valides (70% confiance)

**Règles médicales:**
```dart
_isValidSystolic(value):
  return 70 <= value <= 250

_isValidDiastolic(value):
  return 40 <= value <= 150

_isValidPulse(value):
  return 30 <= value <= 220
```

**Algorithme:**
```dart
1. Filtrer les nombres dans plage systolique
   [85, 120, 200, 72] → [85, 120, 200]

2. Filtrer les nombres dans plage diastolique
   [85, 120, 200, 72] → [85, 72] (120 trop haut)

3. Prendre le plus grand comme systolique
   systolic = max([85, 120, 200]) = 200

4. Prendre le diastolique cohérent
   diastolic = premier où (systolic - 30 > dia > systolic - 80)
   200 - 30 = 170, 200 - 80 = 120
   → diastolic = 85 ✅

5. Vérifier: systolic > diastolic
   200 > 85 ✅
```

---

## 🔍 Comprendre l'erreur actuelle

### L'erreur que vous avez:

```
❌ Unable to load asset: "assets/tessdata/eng.traineddata"
❌ The asset does not exist or has empty data
```

### Cause racine:

```
┌────────────────────────────────────────────────────┐
│ FlutterTesseractOcr.extractText()                 │
│ ├─ 1. Cherche: assets/tessdata/eng.traineddata    │
│ │  ❌ Fichier introuvable !                        │
│ └─ 2. ERREUR: Cannot load asset                   │
│                                                    │
│ Le fichier eng.traineddata (~10MB) n'a pas été    │
│ téléchargé car le proxy bloque GitHub             │
└────────────────────────────────────────────────────┘
```

### Ce qui se passe dans le code:

```dart
// ÉTAPE 3/5: Configuration Tesseract
String text = await FlutterTesseractOcr.extractText(
  processedImagePath,
  language: 'eng',  // ← Cherche eng.traineddata
  args: {...},
);

// En interne, Tesseract fait:
// 1. rootBundle.load('assets/tessdata/eng.traineddata')
// 2. ❌ AssetNotFoundException: File not found
// 3. Throw Exception
```

### Avec les nouveaux logs, vous verrez:

```
═══════════════════════════════════════════════════════════
🚀 DÉBUT ANALYSE OCR TESSERACT
═══════════════════════════════════════════════════════════
📸 Image source: /data/user/0/.../image_picker_xxx.jpg

─────────────────────────────────────────────────────────
📋 ÉTAPE 1/5: Vérification de l'image source
─────────────────────────────────────────────────────────
✅ Image trouvée
   📦 Taille: 245.67 KB
   📁 Chemin: /data/user/0/.../image_picker_xxx.jpg

─────────────────────────────────────────────────────────
📋 ÉTAPE 2/5: Preprocessing de l'image
─────────────────────────────────────────────────────────
🔄 Lancement du preprocessing...
   • Conversion en niveaux de gris
   • Augmentation du contraste
   • Sharpening (netteté)
   • Binarisation (noir/blanc)
✅ Preprocessing terminé
   📁 Image prétraitée: /data/user/0/.../processed_xxx.png

─────────────────────────────────────────────────────────
📋 ÉTAPE 3/5: Configuration Tesseract OCR
─────────────────────────────────────────────────────────
⚙️ Configuration:
   • Langue: eng
   • PSM Mode: 6 (bloc uniforme)
   • Whitelist: 0123456789/:
   • Preserve spaces: Oui

─────────────────────────────────────────────────────────
📋 ÉTAPE 4/5: Analyse OCR Tesseract
─────────────────────────────────────────────────────────
🔍 Lancement de l'analyse Tesseract...
⏳ Ceci peut prendre 1-3 secondes...

❌ ERREUR ICI: eng.traineddata manquant !

═══════════════════════════════════════════════════════════
❌ ERREUR CRITIQUE OCR
═══════════════════════════════════════════════════════════
Type: Exception
Message: Unable to load asset: "assets/tessdata/eng.traineddata"
═══════════════════════════════════════════════════════════
```

---

## ✅ Solution

### Télécharger eng.traineddata manuellement:

**Sur votre ordinateur (hors du conteneur Docker):**

```bash
# Aller dans le répertoire du projet
cd ~/Bureau/gitTub/App_Dr_CardioGithub

# Télécharger le fichier
wget -O assets/tessdata/eng.traineddata \
  https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata

# Ou avec curl
curl -L -o assets/tessdata/eng.traineddata \
  https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata

# Vérifier
ls -lh assets/tessdata/eng.traineddata
# Devrait afficher: ~10MB
```

**Puis relancer:**
```bash
flutter pub get
flutter run
```

---

## 📈 Performance attendue

### Métriques avec logs:

```
ÉTAPE 1: Vérification image      →    < 10ms
ÉTAPE 2: Preprocessing           →   200-500ms
ÉTAPE 3: Configuration           →    < 5ms
ÉTAPE 4: OCR Tesseract           →   200-800ms
ÉTAPE 5: Parsing                 →    10-50ms
─────────────────────────────────
TOTAL                            →   500-1500ms (0.5-1.5s)
```

### Précision attendue:

- **Photos nettes, bon éclairage:** 95-98% ✅
- **Photos avec reflets:** 85-92% ⚡
- **Photos floues:** 60-75% ⚠️
- **Très mauvaise qualité:** 30-50% ❌

---

## 🎓 Résumé

1. **Tesseract** = Moteur OCR avec réseau neuronal LSTM
2. **eng.traineddata** = Modèle pré-entraîné (REQUIS)
3. **Preprocessing** = Optimisation image pour OCR
4. **Parsing intelligent** = 3 stratégies pour extraire les valeurs
5. **Logs détaillés** = Diagnostic facile des problèmes

**L'erreur actuelle est simple:** Le fichier eng.traineddata manque. Téléchargez-le et tout fonctionnera ! 🎉
