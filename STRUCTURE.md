# Structure du Projet DocteurCardio

## 📁 Architecture des Dossiers

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── config/
│   └── app_theme.dart                 # Configuration du thème (couleurs, styles)
├── routes/
│   └── app_routes.dart                # Définition de toutes les routes
├── screens/
│   ├── common/                        # Écrans communs aux deux profils
│   │   ├── splash_screen.dart         # ✅ Écran de démarrage
│   │   ├── onboarding_screen.dart     # ✅ Onboarding (3 pages)
│   │   ├── profile_choice_screen.dart # ✅ Choix Patient/Cardiologue
│   │   └── patient_login_screen.dart  # ✅ Connexion patient
│   │
│   ├── patient/                       # Écrans pour les patients
│   │   ├── patient_dashboard_screen.dart        # ✅ Dashboard patient
│   │   ├── record_pressure_manual_screen.dart   # ✅ Saisie manuelle tension
│   │   ├── patient_history_screen.dart          # ✅ Historique & graphiques
│   │   └── patient_profile_screen.dart          # ✅ Profil patient
│   │
│   ├── doctor/                        # Écrans pour les cardiologues
│   │   └── doctor_dashboard_screen.dart         # ✅ Dashboard cardiologue
│   │
│   └── utils/                         # Écrans utilitaires
│       └── placeholder_screen.dart    # ✅ Écran placeholder pour routes futures
│
└── widgets/                           # Widgets réutilisables (à développer)
```

## 🎨 Design System

### Couleurs
```dart
Primaire (Bleu):    #2B5B9E
Secondaire (Rouge): #E74C3C
Succès (Vert):      #27AE60
Avertissement:      #F39C12
Erreur:             #E74C3C

Gris clair:         #ECF0F1
Gris moyen:         #95A5A6
Gris foncé:         #2C3E50
Fond:               #FFFFFF
Texte:              #2C3E50
```

## 🗺️ Routes Configurées

### Routes Communes
- `/` - Splash Screen
- `/onboarding` - Onboarding
- `/profile-choice` - Choix du profil

### Routes Authentification
- `/patient/login` - Connexion patient ✅
- `/patient/register` - Inscription patient 🚧
- `/doctor/login` - Connexion cardiologue 🚧
- `/doctor/register` - Inscription cardiologue 🚧
- `/payment` - Paiement 🚧

### Routes Patient
- `/patient/dashboard` - Dashboard ✅
- `/patient/record-photo` - Enregistrement photo 🚧
- `/patient/record-manual` - Enregistrement manuel ✅
- `/patient/add-context` - Ajouter contexte 🚧
- `/patient/history` - Historique ✅
- `/patient/measure-detail` - Détail mesure 🚧
- `/patient/messages` - Messages 🚧
- `/patient/chat` - Conversation 🚧
- `/patient/documents` - Documents 🚧
- `/patient/teleconsultation` - Téléconsultation 🚧
- `/patient/profile` - Profil ✅
- `/patient/notifications` - Notifications 🚧
- `/patient/settings` - Paramètres 🚧

### Routes Cardiologue
- `/doctor/dashboard` - Dashboard ✅
- `/doctor/patients` - Liste patients 🚧
- `/doctor/patient-file` - Dossier patient 🚧
- `/doctor/patient-history` - Historique patient 🚧
- `/doctor/messages` - Messages 🚧
- `/doctor/chat` - Conversation 🚧
- `/doctor/revenue` - Revenus 🚧
- `/doctor/profile` - Profil 🚧

### Routes Utilitaires
- `/qr-scanner` - Scanner QR 🚧
- `/alert` - Alerte 🚧
- `/offline` - Mode hors ligne 🚧

**Légende:**
- ✅ Écran implémenté avec UI
- 🚧 Route configurée avec placeholder

## 🚀 Comment Démarrer

### 1. Vérifier l'installation
```bash
flutter doctor
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Lancer l'application
```bash
flutter run
```

## 📱 Flux de Navigation

### Flux Patient
```
Splash → Onboarding → Choix Profil → Login Patient → Dashboard Patient
                                                            ├─→ Mesure Tension
                                                            ├─→ Historique
                                                            ├─→ Messages
                                                            └─→ Profil
```

### Flux Cardiologue
```
Splash → Onboarding → Choix Profil → Login Cardiologue → Dashboard Cardiologue
                                                               ├─→ Patients
                                                               ├─→ Messages
                                                               ├─→ Statistiques
                                                               └─→ Profil
```

## 📝 Écrans Implémentés

### ✅ Écrans Fonctionnels

1. **SplashScreen** - Animation heartbeat + navigation automatique
2. **OnboardingScreen** - 3 pages avec swipe + skip
3. **ProfileChoiceScreen** - Choix Patient/Cardiologue
4. **PatientLoginScreen** - Formulaire complet avec validation
5. **PatientDashboardScreen** - Dashboard avec dernière mesure, actions rapides, mini-graphique
6. **RecordPressureManualScreen** - Saisie manuelle avec pickers
7. **PatientHistoryScreen** - Graphiques, statistiques, liste mesures
8. **PatientProfileScreen** - Profil complet avec infos, cardiologue, abonnement
9. **DoctorDashboardScreen** - Dashboard médecin avec alertes, stats, revenus
10. **PlaceholderScreen** - Écran générique pour routes futures

## 🎯 Prochaines Étapes

### Phase 1 - Compléter les Écrans Essentiels
- [ ] Inscription Patient (multi-étapes)
- [ ] Enregistrement par photo (OCR)
- [ ] Messagerie Patient
- [ ] Liste Patients (Cardiologue)
- [ ] Dossier Patient (Vue Cardiologue)

### Phase 2 - Fonctionnalités Avancées
- [ ] Scanner QR Code
- [ ] Téléconsultation
- [ ] Notifications push
- [ ] Mode hors ligne
- [ ] Export PDF

### Phase 3 - Backend & Intégration
- [ ] API REST
- [ ] Authentification Firebase
- [ ] Base de données
- [ ] Paiement Mobile Money
- [ ] OCR pour photos

## 🛠️ Technologies

- **Framework:** Flutter
- **Langage:** Dart
- **Design:** Material Design 3
- **Navigation:** Named Routes
- **État:** StatefulWidget (pour l'instant)

## 📖 Documentation Wireframe

Le wireframe complet est disponible dans:
- [docteurcardio_wireframe (1) (1).md](docteurcardio_wireframe%20(1)%20(1).md)

Il contient les spécifications détaillées de tous les 28 écrans de l'application.

## 💡 Conseils de Développement

1. **Tester chaque écran individuellement** avant de passer au suivant
2. **Utiliser les widgets réutilisables** pour la cohérence
3. **Suivre le design system** pour les couleurs et styles
4. **Ajouter des commentaires TODO** pour les fonctionnalités futures
5. **Tester sur iOS et Android** régulièrement

## 📞 Support

Pour toute question sur la structure du projet, consulter:
- Le wireframe complet
- Le code des écrans existants
- La documentation Flutter officielle
