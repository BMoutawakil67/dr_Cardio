# Fix: Filtrage des interférences date/heure dans l'OCR

## Problème identifié

Sur les images de tensiomètres, des informations temporelles comme l'heure et la date peuvent interférer avec la détection des valeurs de tension artérielle.

### Exemple
Sur l'image fournie du tensiomètre AutoTensio :
- **Valeurs de tension** : SYS 120 mmHg, DIA 80 mmHg, PUL 70 /min
- **Informations temporelles** :
  - Heure : `8:30 AM`
  - Date : `10.08.`

Le problème était que l'OCR extrait **tous** les nombres de 2-3 chiffres, ce qui inclut :
- `30` de "8:30"
- `10` et `08` de "10.08"

Ces nombres parasites pouvaient être confondus avec les vraies valeurs de tension.

## Solution implémentée

Ajout d'une fonction `_filterDateTimePatterns()` dans les deux services OCR :
- `lib/services/ocr/improved_blood_pressure_ocr_service.dart` (Tesseract)
- `lib/services/ocr/blood_pressure_ocr_service.dart` (Google ML Kit)

### Patterns filtrés

La fonction détecte et supprime les patterns suivants :

1. **Heures avec deux-points** : `8:30`, `08:30`, `12:45`
   - Pattern : `\b\d{1,2}:\d{2}\b`

2. **Heures avec AM/PM** : `8:30 AM`, `12:45 PM`
   - Pattern : `\b\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)\b`

3. **Heures avec 'h'** : `8h30`, `12h45`
   - Pattern : `\b\d{1,2}h\d{2}\b`

4. **Dates avec points** : `10.08`, `10.08.`, `10.08.2024`
   - Pattern : `\b\d{1,2}\.\d{1,2}\.?(?:\d{2,4})?\b`

5. **Dates avec slashes** : `10/08`, `10/08/24`, `10/08/2024`
   - Pattern : `\b([0-2]?\d|3[01])/([0-1]?\d|1[0-2])(?:/\d{2,4})?\b`
   - ⚠️ **Important** : Ce pattern est conçu pour **ne pas** supprimer les valeurs de tension comme `120/80` (car 120 > 31)

6. **Dates avec tirets** : `10-08`, `10-08-24`
   - Pattern : `\b([0-2]?\d|3[01])-([0-1]?\d|1[0-2])(?:-\d{2,4})?\b`

### Fonctionnement

```dart
String _filterDateTimePatterns(String text) {
  debugPrint('🔍 Texte avant filtrage date/heure: "$text"');

  var filtered = text;

  // Suppression de tous les patterns temporels
  // ... (voir code source)

  // Nettoyage des espaces multiples
  filtered = filtered.replaceAll(RegExp(r'\s+'), ' ').trim();

  debugPrint('✅ Texte après filtrage date/heure: "$filtered"');

  return filtered;
}
```

### Intégration

Le filtrage est appliqué **avant** l'extraction des nombres dans `_parseBloodPressureValues()` :

```dart
BloodPressureOcrResult _parseBloodPressureValues(String text) {
  // Nettoyer le texte
  var cleanText = text.replaceAll('\n', ' ').replaceAll('  ', ' ').trim();

  // 🆕 Filtrer les patterns de date/heure pour éviter les interférences
  cleanText = _filterDateTimePatterns(cleanText);

  // Extraire tous les nombres du texte
  final numbers = _extractNumbers(cleanText);
  // ...
}
```

## Avantages

✅ **Précision améliorée** : Les nombres parasites ne sont plus extraits
✅ **Logs détaillés** : Debug print avant/après filtrage pour diagnostic
✅ **Sécurité** : Les valeurs de tension comme `120/80` sont préservées
✅ **Robustesse** : Gère de nombreux formats de date/heure différents
✅ **Double protection** : Appliqué aux deux services OCR (Tesseract + ML Kit)

## Test recommandé

Avec l'image fournie du tensiomètre AutoTensio, le système devrait maintenant :
- ✅ Détecter : SYS 120, DIA 80, PUL 70
- ❌ Ignorer : 8:30, 10, 08

Les logs afficheront :
```
🔍 Texte avant filtrage date/heure: "120 SYS 80 DIA 70 PUL 8:30 AM 10.08."
✅ Texte après filtrage date/heure: "120 SYS 80 DIA 70 PUL"
```
