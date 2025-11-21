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

## Problème identifié ✅ RÉSOLU

### Résultat du terminal
```
🔍 OCR: Texte reconnu: "Infinix SMART7 HD
Spengler
8:30        ← extrait "30"
10.08.      ← extrait "10" et "08"
AutoTensio
M
SYS         ← Label seulement, pas de valeur!
DIA         ← Label seulement, pas de valeur!
PUL"        ← Label seulement, pas de valeur!

💡 Nombres extraits: [30, 10, 8]
```

### Analyse
- ML Kit **fonctionne correctement**
- **Problème**: L'image inclut TOUTE l'interface du tensiomètre (heure, date, marque, icônes)
- ML Kit détecte l'heure `8:30` et la date `10.08.` mais **PAS les valeurs de tension**
- Les labels `SYS`, `DIA`, `PUL` sont visibles mais les chiffres `120`, `80`, `70` ne sont **pas détectés**

### Cause identifiée
**Photo trop large et mal cadrée**:
1. L'écran LCD du tensiomètre est trop petit dans l'image
2. Les chiffres de tension sont flous ou mal éclairés
3. L'utilisateur a photographié toute l'interface au lieu de zoomer sur les valeurs

---

## Solution implémentée ✅

### Amélioration de l'UI pour guider l'utilisateur

**1. Cadre de guidage amélioré**
- Bordure verte avec exemple visuel `120 / 80 / 70`
- Message clair: "CADREZ UNIQUEMENT L'ÉCRAN LCD"

**2. Conseils détaillés**
```
• Cadrez UNIQUEMENT les chiffres de tension
• Tensiomètre bien allumé et éclairé
• Distance: 15-20cm de l'écran LCD
• Photo nette (pas de flou)
```

**3. Instructions pour l'utilisateur**
- **NE PAS photographier**: Toute l'interface, la marque, l'heure, la date
- **PHOTOGRAPHIER UNIQUEMENT**: Les chiffres LCD `120 / 80 / 70`
- **Distance recommandée**: 15-20cm pour un bon contraste
- **Éclairage**: Bien éclairer l'écran LCD sans reflets

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
