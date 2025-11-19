# 🫀 DocteurCardio - Application Mobile Flutter

Application mobile de suivi de tension artérielle pour patients et cardiologues en Afrique de l'Ouest.

## 📱 Description

DocteurCardio est une application qui permet:
- **Aux patients:** Suivre leur tension artérielle, communiquer avec leur cardiologue, recevoir des alertes
- **Aux cardiologues:** Suivre leurs patients à distance, recevoir des alertes, gérer des consultations

## ✨ Fonctionnalités Implémentées

### ✅ Écrans Opérationnels (10 écrans)

1. **Splash Screen** - Écran de démarrage avec animation
2. **Onboarding** - 3 pages de présentation de l'app
3. **Choix du Profil** - Sélection Patient ou Cardiologue
4. **Connexion Patient** - Formulaire de connexion complet
5. **Dashboard Patient** - Vue d'ensemble avec dernière mesure, actions rapides
6. **Saisie Manuelle** - Enregistrement de la tension artérielle
7. **Historique Patient** - Graphiques et statistiques
8. **Profil Patient** - Informations complètes
9. **Dashboard Cardiologue** - Vue d'ensemble pour le médecin
10. **Écran Placeholder** - Pour les routes futures

### 🚧 Écrans Configurés (18 routes additionnelles)

Toutes les routes du wireframe sont configurées et mènent à des écrans placeholder prêts à être développés.

## 🎨 Design System

### Palette de Couleurs
- **Primaire:** Bleu #2B5B9E
- **Secondaire:** Rouge #E74C3C
- **Succès:** Vert #27AE60
- **Avertissement:** Orange #F39C12

### Composants
- Bottom Navigation (Patient & Cardiologue)
- Cards avec elevation
- Buttons (Elevated, Outlined)
- Input fields avec validation
- Charts placeholders

## 📂 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée + configuration routes
├── config/
│   └── app_theme.dart          # Thème et couleurs
├── routes/
│   └── app_routes.dart         # Définition des routes
├── screens/
│   ├── common/                 # 4 écrans communs
│   ├── patient/                # 4 écrans patient
│   ├── doctor/                 # 1 écran cardiologue
│   └── utils/                  # 1 écran utilitaire
└── widgets/                    # À développer
```

**Total:** 13 fichiers Dart créés

## 🚀 Installation & Lancement

### Prérequis
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio / Xcode (pour émulateurs)

### Étapes

1. **Cloner le projet**
```bash
cd /home/alao/Bureau/drCardio/dr_cardio
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Vérifier l'installation**
```bash
flutter doctor
```

4. **Lancer l'application**
```bash
flutter run
```

## 🗺️ Navigation

### Pour Tester l'App

1. **Démarrage:** Splash Screen → Onboarding (3 pages)
2. **Choix:** Sélectionner "Je suis patient"
3. **Connexion:** Utiliser le formulaire de login
4. **Dashboard:** Explorer les fonctionnalités
   - Mesure manuelle de tension
   - Historique avec graphiques
   - Profil utilisateur

## 📋 Routes Disponibles

### Patient
- `/patient/dashboard` - Tableau de bord
- `/patient/record-manual` - Saisie manuelle
- `/patient/history` - Historique
- `/patient/profile` - Profil
- Et 9 autres routes avec placeholder

### Cardiologue
- `/doctor/dashboard` - Tableau de bord médecin
- Et 7 autres routes avec placeholder

Voir [STRUCTURE.md](STRUCTURE.md) pour la liste complète.

## 📖 Documentation

- **[STRUCTURE.md](STRUCTURE.md)** - Architecture détaillée du projet
- **Wireframe complet** - 28 écrans spécifiés

## 🎯 Prochaines Étapes de Développement

### Phase 1 - Écrans Essentiels
- [ ] Inscription Patient (formulaire multi-étapes)
- [ ] Enregistrement par photo (avec OCR)
- [ ] Système de messagerie
- [ ] Liste et dossiers patients (vue cardiologue)

### Phase 2 - Fonctionnalités Backend
- [ ] API REST (authentification, CRUD)
- [ ] Base de données (patients, mesures, messages)
- [ ] OCR pour lecture automatique des tensiomètres
- [ ] Notifications push

### Phase 3 - Features Avancées
- [ ] Téléconsultation (vidéo)
- [ ] Scanner QR Code
- [ ] Paiement Mobile Money
- [ ] Mode hors ligne avec synchronisation
- [ ] Export PDF des rapports

## 🛠️ Technologies Utilisées

- **Framework:** Flutter 3.x
- **Langage:** Dart
- **UI:** Material Design 3
- **Navigation:** Named Routes
- **Gestion d'état:** StatefulWidget (à migrer vers Provider/Riverpod)

## 📱 Plateformes Supportées

- ✅ Android
- ✅ iOS
- 🚧 Web (future)

## 🧪 Tests

```bash
# Analyser le code
flutter analyze

# Lancer les tests (à développer)
flutter test
```

## 📊 Statistiques du Projet

- **Écrans implémentés:** 10
- **Routes configurées:** 28
- **Fichiers Dart:** 13
- **Wireframes disponibles:** 28
- **Palette de couleurs:** 10 couleurs définies

## 🚦 Guide de Démarrage Rapide

### Test Rapide

```bash
# Lancer l'app
flutter run

# Puis naviguer:
# 1. Attendre le splash screen (3 sec)
# 2. Swiper les 3 pages d'onboarding ou "Passer"
# 3. Choisir "Je suis patient"
# 4. Cliquer "SE CONNECTER" (formulaire pré-rempli)
# 5. Explorer le dashboard patient
```

### Écrans Testables

1. Dashboard → Actions rapides → "Saisie Manuel"
2. Dashboard → Bottom Nav → "Historique"
3. Dashboard → Bottom Nav → "Profil"
4. Retour → Choix profil → "Je suis cardiologue" → Dashboard Médecin

---

**Status:** 🟢 Prêt pour développement
**Version:** 1.0.0 (Structure initiale)
**Dernière mise à jour:** 2025-11-11
