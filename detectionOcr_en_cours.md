# Détection OCR - Session en cours

## Statut: 🔧 En cours de développement

---

## Résumé de la session

### Objectif
Implémenter la reconnaissance OCR des valeurs de tension artérielle à partir de photos de tensiomètres.

### Package utilisé
- **google_mlkit_text_recognition: ^0.12.0**
- Fonctionne hors-ligne
- Optimisé pour la reconnaissance de chiffres

---

## Fichiers créés/modifiés

### 1. Service OCR
**`lib/services/ocr/blood_pressure_ocr_service.dart`** (nouveau)

```dart
class BloodPressureOcrResult {
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final double confidence;
  final String rawText;
  final String? error;
}

class BloodPressureOcrService {
  Future<BloodPressureOcrResult> extractBloodPressure(String imagePath);
}
```

### 2. Écran de capture
**`lib/screens/patient/record_pressure_photo_screen.dart`**
- Intégration du service OCR
- Affichage de la progression en temps réel
- Affichage du niveau de confiance
- Debug: affichage du texte brut détecté et des erreurs

### 3. Dépendances
**`pubspec.yaml`**
```yaml
google_mlkit_text_recognition: ^0.12.0
```

---

## Algorithme de détection

### Stratégies de parsing

1. **Stratégie 1: Pattern "/" (confiance 90%)**
   - Cherche le format `XXX/YY` (ex: `120/80`)
   - Regex: `(\d{2,3})\s*[/\\]\s*(\d{2,3})`

2. **Stratégie 2: Analyse par plages (confiance 70%)**
   - Extrait tous les nombres 2-3 chiffres
   - Filtre par plages valides:
     - Systolique: **70-250 mmHg**
     - Diastolique: **40-150 mmHg**
     - Pouls: **30-220 bpm**

3. **Détection du pouls**
   - Nombre restant dans la plage 30-220
   - Préférence pour les valeurs proches de 75 bpm

---

## Problème identifié

### Résultat du terminal
```
💡 Nombres extraits: [30, 10, 8]
```

### Analyse
- L'OCR **fonctionne** et détecte du texte
- Les nombres détectés `[30, 10, 8]` ne passent pas la validation:
  - `30` < 70 (hors plage systolique)
  - `10` < 40 (hors plage diastolique)
  - `8` < 30 (hors plage pouls)

### Causes possibles
1. **Image mal cadrée** - les vrais chiffres de tension ne sont pas visibles
2. **Autres éléments détectés** - batterie, heure, icônes du tensiomètre
3. **Qualité d'image** - chiffres flous ou trop petits
4. **Format d'affichage** - certains tensiomètres affichent `12.0` au lieu de `120`

---

## Pistes d'amélioration

### 1. Élargir la regex pour décimales
```dart
// Détecter "12.0" comme "120"
final decimalPattern = RegExp(r'(\d{1,2})[.,](\d)');
```

### 2. Améliorer l'extraction des nombres
```dart
// Inclure les nombres à 1 chiffre pour reconstituer
final numberPattern = RegExp(r'\d+');
```

### 3. Ajouter des hints visuels
- Guide de cadrage plus précis
- Conseils pour bien positionner le tensiomètre

### 4. Améliorer le parsing
- Reconnaître les formats courants de tensiomètres
- Combiner des chiffres proches (ex: "12" "0" → "120")

---

## Prochaines étapes

- [ ] Analyser les images de test pour comprendre ce que ML Kit détecte réellement
- [ ] Ajuster les stratégies de parsing selon les formats de tensiomètres
- [ ] Ajouter support pour les affichages décimaux (12.0 → 120)
- [ ] Tester avec différents modèles de tensiomètres

---

## Comment tester

1. Lancer l'app: `flutter run`
2. Aller sur "Enregistrer mesure" → "📷 Photo"
3. Prendre une photo d'un tensiomètre
4. Observer:
   - La console pour les logs `🔍 OCR:`
   - L'UI pour le "Texte:" détecté et l'erreur éventuelle

---

*Dernière mise à jour: Session actuelle*
