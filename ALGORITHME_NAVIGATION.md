# ALGORITHME - Navigation et Ajout de Pages
## Projet DocteurCardio - Guide pour IA

---

## TABLE DES MATIÈRES

1. [Vue d'ensemble de l'architecture](#1-vue-densemble-de-larchitecture)
2. [Étape 1: Ajouter une route](#2-étape-1-ajouter-une-route)
3. [Étape 2: Créer l'écran](#3-étape-2-créer-lécran)
4. [Étape 3: Enregistrer la route](#4-étape-3-enregistrer-la-route)
5. [Étape 4: Implémenter la navigation](#5-étape-4-implémenter-la-navigation)
6. [Étape 5: Récupérer les arguments](#6-étape-5-récupérer-les-arguments)
7. [Étape 6: Vérification et tests](#7-étape-6-vérification-et-tests)
8. [Architecture du code](#8-architecture-du-code)
9. [Conventions et bonnes pratiques](#9-conventions-et-bonnes-pratiques)
10. [Checklist finale](#10-checklist-finale)

---

## 1. VUE D'ENSEMBLE DE L'ARCHITECTURE

### Structure du projet

```
dr_cardio/
├── lib/
│   ├── main.dart                           # Point d'entrée, enregistrement routes
│   ├── config/
│   │   └── app_theme.dart                 # Thème et couleurs globales
│   ├── routes/
│   │   └── app_routes.dart                # Définition des constantes de routes
│   └── screens/
│       ├── common/                         # Écrans partagés (splash, onboarding, login)
│       ├── patient/                        # Écrans spécifiques patient
│       ├── doctor/                         # Écrans spécifiques cardiologue
│       └── utils/
│           └── placeholder_screen.dart     # Écran temporaire pour routes non implémentées
```

### Flux général d'ajout d'une nouvelle page

```
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 1: Définir la route dans app_routes.dart                │
│  static const String nomRoute = '/categorie/nom-page';          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 2: Créer l'écran dans /screens/[categorie]/             │
│  class NomScreen extends StatelessWidget { ... }                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 3: Enregistrer la route dans main.dart                  │
│  import + routes: { AppRoutes.nom: (context) => NomScreen() }  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 4: Implémenter la navigation depuis un bouton           │
│  Navigator.pushNamed(context, AppRoutes.nomRoute)              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 5 (optionnel): Récupérer les arguments                  │
│  final args = ModalRoute.of(context)?.settings.arguments        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 6: Tester et vérifier                                   │
│  flutter analyze + flutter clean + flutter run                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. ÉTAPE 1: AJOUTER UNE ROUTE

### Fichier concerné
`/lib/routes/app_routes.dart`

### Algorithme

```
FONCTION AjouterRoute(nomPage: String, categorie: String)
DÉBUT
  1. Ouvrir le fichier: /lib/routes/app_routes.dart

  2. Déterminer la catégorie:
     SI categorie = "Patient" ALORS
       section ← "// Routes Patient"
     SINON SI categorie = "Cardiologue" ALORS
       section ← "// Routes Cardiologue"
     SINON SI categorie = "Commune" ALORS
       section ← "// Routes communes"
     FIN SI

  3. Construire le nom de la constante:
     nomConstante ← categorieNomPage (camelCase)
     Exemples:
       - "patient" + "settings" → patientSettings
       - "doctor" + "profile" → doctorProfile
       - "payment" → payment

  4. Construire le chemin de la route:
     SI categorie = "Commune" ALORS
       chemin ← "/nom-page"
     SINON
       chemin ← "/categorie/nom-page"
     FIN SI
     Exemples:
       - Patient + settings → "/patient/settings"
       - Cardiologue + profile → "/doctor/profile"
       - payment → "/payment"

  5. Ajouter la ligne dans la section appropriée:
     Format: static const String nomConstante = 'chemin';
     Exemple: static const String patientSettings = '/patient/settings';

  6. Sauvegarder le fichier

  RETOURNER nomConstante
FIN
```

### Exemple de code

```dart
class AppRoutes {
  // Routes communes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String payment = '/payment';

  // Routes Patient
  static const String patientDashboard = '/patient/dashboard';
  static const String patientSettings = '/patient/settings';         // ← NOUVELLE ROUTE
  static const String patientDocuments = '/patient/documents';       // ← NOUVELLE ROUTE
  static const String patientProfile = '/patient/profile';

  // Routes Cardiologue
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorProfile = '/doctor/profile';             // ← NOUVELLE ROUTE
  static const String doctorPatients = '/doctor/patients';
}
```

### Règles de nommage

| Élément | Format | Exemple |
|---------|--------|---------|
| Constante | camelCase | `patientSettings` |
| Chemin route | kebab-case avec / | `/patient/settings` |
| Catégorie patient | `/patient/...` | `/patient/settings` |
| Catégorie doctor | `/doctor/...` | `/doctor/profile` |
| Catégorie commune | `/...` | `/payment` |

---

## 3. ÉTAPE 2: CRÉER L'ÉCRAN

### Fichiers concernés
- Patient: `/lib/screens/patient/[nom]_screen.dart`
- Cardiologue: `/lib/screens/doctor/[nom]_screen.dart`
- Commune: `/lib/screens/common/[nom]_screen.dart`

### Algorithme

```
FONCTION CreerEcran(nomPage: String, categorie: String, avecEtat: Boolean)
DÉBUT
  1. Déterminer le dossier de destination:
     SI categorie = "Patient" ALORS
       dossier ← "/lib/screens/patient/"
     SINON SI categorie = "Cardiologue" ALORS
       dossier ← "/lib/screens/doctor/"
     SINON SI categorie = "Commune" ALORS
       dossier ← "/lib/screens/common/"
     FIN SI

  2. Construire le nom du fichier:
     SI categorie = "Commune" ALORS
       nomFichier ← "nom_page_screen.dart"
     SINON
       nomFichier ← "categorie_nom_page_screen.dart"
     FIN SI
     Exemples:
       - Patient + settings → "patient_settings_screen.dart"
       - Cardiologue + profile → "doctor_profile_screen.dart"
       - payment → "payment_screen.dart"

  3. Construire le nom de la classe:
     nomClasse ← CategoriNomPageScreen (PascalCase)
     Exemples:
       - Patient + settings → "PatientSettingsScreen"
       - Cardiologue + profile → "DoctorProfileScreen"
       - payment → "PaymentScreen"

  4. Choisir le type de widget:
     SI avecEtat = VRAI ALORS
       typeWidget ← StatefulWidget
       Créer aussi: _NomClasseState extends State<NomClasse>
     SINON
       typeWidget ← StatelessWidget
     FIN SI

  5. Créer le fichier avec la structure de base:
     - Imports obligatoires
     - Déclaration de la classe
     - Méthode build avec Scaffold

  6. Sauvegarder le fichier

  RETOURNER cheminComplet
FIN
```

### Template StatelessWidget

```dart
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';  // Si navigation nécessaire

class NomScreen extends StatelessWidget {
  const NomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titre de la page'),
        // Actions optionnelles
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(  // Pour contenu scrollable
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenu ici
            Text(
              'Contenu de la page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Template StatefulWidget

```dart
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class NomScreen extends StatefulWidget {
  const NomScreen({super.key});

  @override
  State<NomScreen> createState() => _NomScreenState();
}

class _NomScreenState extends State<NomScreen> {
  // Variables d'état
  bool _isEnabled = true;
  String _selectedValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titre de la page'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Widgets avec état
          SwitchListTile(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
            title: const Text('Activer'),
            activeColor: AppTheme.primaryBlue,
          ),

          // Bouton d'action
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Logique de sauvegarde
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres enregistrés'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
```

### Décision: StatelessWidget vs StatefulWidget

```
FONCTION ChoisirTypeWidget(caractéristiques: List<String>)
DÉBUT
  avecEtat ← FAUX

  POUR CHAQUE caracteristique DANS caractéristiques FAIRE
    SI caracteristique DANS [
      "formulaire avec saisie",
      "switch/checkbox",
      "sélection multiple",
      "compteur/timer",
      "animation",
      "état qui change"
    ] ALORS
      avecEtat ← VRAI
      SORTIR DE LA BOUCLE
    FIN SI
  FIN POUR

  SI avecEtat = VRAI ALORS
    RETOURNER "StatefulWidget"
  SINON
    RETOURNER "StatelessWidget"
  FIN SI
FIN
```

**Exemples:**
- Écran de profil (affichage simple) → StatelessWidget
- Écran de paramètres (switches) → StatefulWidget
- Liste de patients (affichage) → StatelessWidget
- Formulaire d'inscription → StatefulWidget

---

## 4. ÉTAPE 3: ENREGISTRER LA ROUTE

### Fichier concerné
`/lib/main.dart`

### Algorithme

```
FONCTION EnregistrerRoute(nomEcran: String, nomClasse: String, categorie: String)
DÉBUT
  1. Ouvrir le fichier: /lib/main.dart

  2. SECTION IMPORTS:
     a) Localiser la section d'imports selon la catégorie:
        - "// Écrans Patient" (lignes ~15-26)
        - "// Écrans Cardiologue" (lignes ~28-32)
        - "// Écrans communs" (lignes ~5-13)

     b) Construire la ligne d'import:
        cheminImport ← "package:dr_cardio/screens/categorie/nom_fichier.dart"
        Exemple: "package:dr_cardio/screens/patient/patient_settings_screen.dart"

     c) Ajouter la ligne d'import dans la section appropriée:
        import 'cheminImport';

  3. SECTION ROUTES:
     a) Localiser le Map routes: { ... } dans la méthode build
        (aux alentours de la ligne 53)

     b) Localiser le commentaire de catégorie approprié:
        - "// Routes Patient"
        - "// Routes Cardiologue"
        - "// Routes communes"

     c) Ajouter l'entrée de route:
        Format: AppRoutes.nomRoute: (context) => const NomClasse(),
        Exemple: AppRoutes.patientSettings: (context) => const PatientSettingsScreen(),

     d) IMPORTANT: Vérifier la virgule finale

  4. Sauvegarder le fichier

  RETOURNER succès
FIN
```

### Exemple avant/après

**AVANT:**

```dart
// Écrans Patient
import 'package:dr_cardio/screens/patient/patient_dashboard_screen.dart';
import 'package:dr_cardio/screens/patient/patient_profile_screen.dart';

// ...

routes: {
  // Routes Patient
  AppRoutes.patientDashboard: (context) => const PatientDashboardScreen(),
  AppRoutes.patientProfile: (context) => const PatientProfileScreen(),

  // Routes Cardiologue
  AppRoutes.doctorDashboard: (context) => const DoctorDashboardScreen(),
}
```

**APRÈS:**

```dart
// Écrans Patient
import 'package:dr_cardio/screens/patient/patient_dashboard_screen.dart';
import 'package:dr_cardio/screens/patient/patient_profile_screen.dart';
import 'package:dr_cardio/screens/patient/patient_settings_screen.dart';      // ← NOUVEAU
import 'package:dr_cardio/screens/patient/patient_documents_screen.dart';     // ← NOUVEAU

// Écrans Cardiologue
import 'package:dr_cardio/screens/doctor/doctor_dashboard_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_profile_screen.dart';         // ← NOUVEAU

// ...

routes: {
  // Routes Patient
  AppRoutes.patientDashboard: (context) => const PatientDashboardScreen(),
  AppRoutes.patientProfile: (context) => const PatientProfileScreen(),
  AppRoutes.patientSettings: (context) => const PatientSettingsScreen(),      // ← NOUVEAU
  AppRoutes.patientDocuments: (context) => const PatientDocumentsScreen(),    // ← NOUVEAU

  // Routes Cardiologue
  AppRoutes.doctorDashboard: (context) => const DoctorDashboardScreen(),
  AppRoutes.doctorProfile: (context) => const DoctorProfileScreen(),          // ← NOUVEAU
}
```

### Points d'attention

1. **Ordre des imports**: Respecter l'ordre alphabétique dans chaque section
2. **Virgule finale**: Toujours mettre une virgule après chaque entrée de route
3. **const**: Toujours utiliser `const` pour les constructeurs d'écrans
4. **Cohérence**: Le nom dans AppRoutes doit correspondre à la constante définie à l'Étape 1

---

## 5. ÉTAPE 4: IMPLÉMENTER LA NAVIGATION

### Fichier concerné
N'importe quel écran existant (écran source)

### Algorithme

```
FONCTION ImplementerNavigation(
  ecranSource: String,
  typeElement: String,
  routeDestination: String,
  arguments: Map<String, dynamic>?
)
DÉBUT
  1. Ouvrir l'écran source

  2. VÉRIFIER L'IMPORT:
     SI "import 'package:dr_cardio/routes/app_routes.dart';" NON présent ALORS
       Ajouter l'import en haut du fichier
     FIN SI

  3. Localiser ou créer l'élément de navigation:
     SELON typeElement FAIRE
       CAS "ListTile":
         widget ← ListTile avec onTap
       CAS "ElevatedButton":
         widget ← ElevatedButton avec onPressed
       CAS "IconButton":
         widget ← IconButton avec onPressed
       CAS "BottomNavigationBar":
         widget ← BottomNavigationBar avec onTap
       CAS "GestureDetector":
         widget ← GestureDetector avec onTap
       DEFAUT:
         widget ← ElevatedButton avec onPressed
     FIN SELON

  4. Choisir le type de navigation:
     SI "navigation simple (peut revenir)" ALORS
       methodNavigation ← "pushNamed"
     SINON SI "remplacement (ne peut pas revenir)" ALORS
       methodNavigation ← "pushReplacementNamed"
     SINON SI "vider pile (déconnexion)" ALORS
       methodNavigation ← "pushNamedAndRemoveUntil"
     FIN SI

  5. Implémenter l'action:
     SI arguments = NULL ALORS
       // Navigation simple sans arguments
       onPressed/onTap: () {
         Navigator.methodNavigation(context, AppRoutes.routeDestination);
       }
     SINON
       // Navigation avec arguments
       onPressed/onTap: () {
         Navigator.pushNamed(
           context,
           AppRoutes.routeDestination,
           arguments: arguments,
         );
       }
     FIN SI

  6. Sauvegarder le fichier

  RETOURNER succès
FIN
```

### Types de navigation

#### 1. Navigation simple (push)

```dart
// L'utilisateur peut revenir en arrière
onPressed: () {
  Navigator.pushNamed(context, AppRoutes.patientSettings);
}
```

**Utilisation:**
- Accès aux paramètres
- Voir les détails d'un élément
- Ouvrir une page secondaire

**Pile de navigation:**
```
[Dashboard] → [Settings]  ← Bouton retour disponible
```

#### 2. Navigation avec remplacement (pushReplacement)

```dart
// Remplace l'écran actuel, pas de retour vers l'écran précédent
onPressed: () {
  Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
}
```

**Utilisation:**
- Navigation entre onglets de bottom bar
- Redirection après connexion
- Changement de section principale

**Pile de navigation:**
```
[Login] → [Dashboard]  ← Login supprimé de la pile
```

#### 3. Navigation qui vide la pile (pushNamedAndRemoveUntil)

```dart
// Supprime tous les écrans précédents
onPressed: () {
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.splash,
    (route) => false,  // false = supprimer tous les écrans
  );
}
```

**Utilisation:**
- Déconnexion
- Retour à l'écran d'accueil
- Réinitialisation de l'application

**Pile de navigation:**
```
[Dashboard] → [Profile] → [Splash]  ← Tous les écrans précédents supprimés
```

#### 4. Navigation avec arguments

```dart
onPressed: () {
  Navigator.pushNamed(
    context,
    AppRoutes.measureDetail,
    arguments: {
      'systolic': 120,
      'diastolic': 80,
      'pulse': 72,
      'date': '15 Oct 2024',
      'status': 'normal',
    },
  );
}
```

**Utilisation:**
- Passer des données à l'écran suivant
- Afficher des détails spécifiques
- Pré-remplir un formulaire

### Exemples par type d'élément

#### ListTile

```dart
ListTile(
  leading: const Icon(Icons.settings),
  title: const Text('Paramètres'),
  subtitle: const Text('Gérer les notifications et rappels'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.pushNamed(context, AppRoutes.patientSettings);
  },
)
```

#### ElevatedButton

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.patientDocuments);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryBlue,
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: const Text('MES DOCUMENTS'),
)
```

#### IconButton

```dart
IconButton(
  icon: const Icon(Icons.notifications),
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.patientNotifications);
  },
)
```

#### TextButton

```dart
TextButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      AppRoutes.measureDetail,
      arguments: {
        'systolic': systolic,
        'diastolic': diastolic,
      },
    );
  },
  child: const Text('Voir détails >'),
)
```

#### BottomNavigationBar

```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  type: BottomNavigationBarType.fixed,
  selectedItemColor: AppTheme.primaryBlue,
  onTap: (index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.patientHistory);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.recordPressurePhoto);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.patientMessages);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.patientProfile);
        break;
    }
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Historique',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined),
      activeIcon: Icon(Icons.camera_alt),
      label: 'Mesure',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
      label: 'Messages',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ],
)
```

#### Card cliquable (GestureDetector)

```dart
GestureDetector(
  onTap: () {
    Navigator.pushNamed(
      context,
      AppRoutes.patientFile,
      arguments: {
        'patientId': patient.id,
        'patientName': patient.name,
      },
    );
  },
  child: Card(
    child: ListTile(
      title: Text(patient.name),
      subtitle: Text(patient.condition),
    ),
  ),
)
```

---

## 6. ÉTAPE 5: RÉCUPÉRER LES ARGUMENTS

### Fichier concerné
Écran de destination (qui reçoit les arguments)

### Algorithme

```
FONCTION RecupererArguments(ecranDestination: String)
DÉBUT
  1. Dans la méthode build() de l'écran de destination:

  2. Récupérer les arguments depuis la route:
     arguments ← ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?

  3. POUR CHAQUE clé attendue FAIRE
     a) Extraire la valeur avec une valeur par défaut:
        valeur ← arguments?['clé'] ?? valeurParDefaut

     b) OU vérifier le type:
        SI arguments != NULL ET arguments.containsKey('clé') ALORS
          valeur ← arguments['clé']
        SINON
          valeur ← valeurParDefaut
        FIN SI
  FIN POUR

  4. Utiliser les valeurs dans le widget

  5. Sauvegarder le fichier

  RETOURNER succès
FIN
```

### Exemple complet

#### Écran source (envoi)

```dart
// patient_history_screen.dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      AppRoutes.measureDetail,
      arguments: {
        'date': '15 Oct 2024',
        'systolic': 120,
        'diastolic': 80,
        'pulse': 72,
        'status': 'normal',
        'context': 'Repos après repas',
      },
    );
  },
  child: const Text('Voir détails'),
)
```

#### Écran destination (réception)

```dart
// patient_measure_detail_screen.dart
class PatientMeasureDetailScreen extends StatelessWidget {
  const PatientMeasureDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer les arguments
    final arguments = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;

    // Extraire les valeurs avec valeurs par défaut
    final date = arguments?['date'] ?? 'Date inconnue';
    final systolic = arguments?['systolic'] ?? 0;
    final diastolic = arguments?['diastolic'] ?? 0;
    final pulse = arguments?['pulse'] ?? 0;
    final status = arguments?['status'] ?? 'unknown';
    final measureContext = arguments?['context'] ?? '';

    // Déterminer la couleur selon le statut
    Color statusColor;
    switch (status) {
      case 'normal':
        statusColor = AppTheme.successGreen;
        break;
      case 'high':
        statusColor = AppTheme.secondaryRed;
        break;
      case 'low':
        statusColor = AppTheme.warningOrange;
        break;
      default:
        statusColor = AppTheme.greyMedium;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la mesure'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            const SizedBox(height: 16),
            Text(
              'Tension: $systolic/$diastolic mmHg',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Pouls: $pulse bpm'),
            if (measureContext.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Contexte: $measureContext'),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Validation des arguments

```
FONCTION ValiderArguments(arguments: Map?, clefsAttendues: List<String>)
DÉBUT
  SI arguments = NULL ALORS
    RETOURNER FAUX
  FIN SI

  POUR CHAQUE clef DANS clefsAttendues FAIRE
    SI NON arguments.containsKey(clef) ALORS
      RETOURNER FAUX
    FIN SI
  FIN POUR

  RETOURNER VRAI
FIN
```

**Exemple d'utilisation:**

```dart
final arguments = ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>?;

// Vérifier que tous les arguments requis sont présents
final requiredKeys = ['systolic', 'diastolic', 'date'];
final isValid = arguments != null &&
    requiredKeys.every((key) => arguments.containsKey(key));

if (!isValid) {
  // Retourner à l'écran précédent ou afficher une erreur
  Navigator.pop(context);
  return const SizedBox(); // Widget vide temporaire
}

// Continuer avec les arguments valides
final systolic = arguments!['systolic'] as int;
final diastolic = arguments!['diastolic'] as int;
```

---

## 7. ÉTAPE 6: VÉRIFICATION ET TESTS

### Algorithme de vérification

```
FONCTION VerifierEtTester()
DÉBUT
  1. PHASE 1: Vérification statique
     a) EXÉCUTER: flutter analyze
     b) SI erreurs présentes ALORS
        POUR CHAQUE erreur FAIRE
          Identifier le fichier et la ligne
          Corriger l'erreur
        FIN POUR
        RÉPÉTER la vérification
     FIN SI
     c) SI warnings présents ALORS
        Examiner les warnings
        Corriger si nécessaire (ex: prefer_const)
     FIN SI

  2. PHASE 2: Nettoyage et compilation
     a) Arrêter l'application en cours (Ctrl+C ou q)
     b) EXÉCUTER: flutter clean
     c) EXÉCUTER: flutter pub get
     d) Attendre la fin (vérifier "Got dependencies!")

  3. PHASE 3: Redémarrage complet
     a) EXÉCUTER: flutter run
     b) Attendre le build complet
     c) SI erreurs de build ALORS
        Examiner les logs
        Corriger les erreurs
        RETOUR à l'étape 3.a
     FIN SI
     d) Application lancée avec succès

  4. PHASE 4: Tests manuels
     a) Naviguer jusqu'au bouton/élément source
     b) Cliquer sur l'élément
     c) VÉRIFIER:
        - La nouvelle page s'affiche correctement
        - Le contenu est visible
        - Pas de page blanche
        - Pas d'erreur dans les logs
     d) Tester le bouton retour (<-)
     e) VÉRIFIER qu'on revient bien à l'écran précédent

  5. PHASE 5: Tests des cas limites
     SI navigation avec arguments ALORS
       a) Tester avec arguments valides
       b) Tester avec arguments manquants (si géré)
       c) Tester avec arguments invalides (si géré)
     FIN SI

     SI navigation depuis BottomNavigationBar ALORS
       a) Tester chaque onglet
       b) Vérifier l'onglet actif (surbrillance)
       c) Tester la navigation répétée
     FIN SI

  6. PHASE 6: Tests de régression
     a) Vérifier que les autres pages fonctionnent toujours
     b) Tester la navigation arrière depuis plusieurs écrans
     c) Tester le cycle complet de l'application

  7. SI toutes les phases passent ALORS
     RETOURNER succès
  SINON
     RETOURNER échec avec détails
  FIN SI
FIN
```

### Commandes de vérification

#### 1. Analyse statique

```bash
flutter analyze
```

**Résultat attendu:**
```
Analyzing dr_cardio...
No issues found! (ran in X.Xs)
```

**Si erreurs:**
```
Analyzing dr_cardio...
error • Undefined name 'AppRoutes' • lib/screens/patient/patient_profile_screen.dart:186:25
info • The private field _amount could be 'final' • lib/screens/common/payment_screen.dart:16:7
```

**Actions:**
- Erreurs (error): **DOIVENT** être corrigées
- Avertissements (warning): **DEVRAIENT** être corrigés
- Infos (info): **PEUVENT** être ignorées (style)

#### 2. Nettoyage complet

```bash
flutter clean && flutter pub get
```

**Résultat attendu:**
```
Deleting build...
Deleting .dart_tool...
Resolving dependencies...
Got dependencies!
```

#### 3. Redémarrage de l'application

```bash
flutter run
```

**Résultat attendu:**
```
Launching lib/main.dart on Chrome in debug mode...
Building...
Syncing files to device Chrome...
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

**⚠️ IMPORTANT:**
- Pour les changements dans `main.dart`: **REDÉMARRAGE COMPLET requis**
- Hot Reload (r) **NE SUFFIT PAS** pour les routes
- Hot Restart (R) **NE SUFFIT PAS** pour les routes
- Seul `flutter run` après `flutter clean` fonctionne

### Checklist de test

```
☐ flutter analyze passe sans erreur
☐ Application démarre sans erreur
☐ Navigation vers la nouvelle page fonctionne
☐ Contenu de la page s'affiche correctement
☐ Bouton retour fonctionne
☐ Arguments reçus correctement (si applicable)
☐ Pas de page blanche
☐ Pas d'erreur dans les logs
☐ Navigation répétée fonctionne
☐ Autres pages non impactées
☐ BottomNavigationBar fonctionne (si modifié)
```

### Debugging en cas d'erreur

#### Page blanche

```
PROBLÈME: Page blanche au lieu du contenu
CAUSES POSSIBLES:
  1. Route non enregistrée dans main.dart
  2. Application non redémarrée après modification de main.dart
  3. Erreur dans le build() de l'écran
  4. Arguments manquants et non gérés

SOLUTION:
  1. Vérifier que la route existe dans main.dart
  2. FAIRE: flutter clean && flutter run
  3. Appuyer sur 'l' dans le terminal pour voir les logs
  4. Chercher les lignes avec "Error" ou "Exception"
  5. Corriger l'erreur identifiée
```

#### Erreur MouseTracker

```
PROBLÈME: Assertion failed: MouseTracker
CAUSES POSSIBLES:
  1. Problème avec les callbacks inline complexes
  2. Conflit lors du Hot Reload

SOLUTION:
  1. Simplifier les callbacks (mettre la logique inline)
  2. FAIRE: flutter clean && flutter run (redémarrage complet)
  3. Si persiste, refactoriser les fonctions helper
```

#### Route non trouvée

```
PROBLÈME: Could not find a generator for route RouteSettings("/patient/settings")
CAUSES POSSIBLES:
  1. Constante mal nommée dans AppRoutes
  2. Route non enregistrée dans main.dart
  3. Faute de frappe dans le nom de route

SOLUTION:
  1. Vérifier app_routes.dart: la constante existe ?
  2. Vérifier main.dart: import et entrée routes: { } ?
  3. Vérifier la cohérence des noms
  4. Redémarrer l'application
```

---

## 8. ARCHITECTURE DU CODE

### Structure détaillée

```
dr_cardio/
├── lib/
│   ├── main.dart                                    # Point d'entrée
│   │   ├── void main() → runApp(MyApp())
│   │   └── class MyApp extends StatelessWidget
│   │       └── MaterialApp(
│   │           ├── theme: AppTheme.lightTheme
│   │           ├── darkTheme: AppTheme.darkTheme
│   │           ├── initialRoute: AppRoutes.splash
│   │           └── routes: { ... }                  # Map des routes
│   │
│   ├── config/
│   │   └── app_theme.dart                          # Configuration thème
│   │       └── class AppTheme
│   │           ├── static ThemeData lightTheme
│   │           ├── static ThemeData darkTheme
│   │           ├── static const Color primaryBlue
│   │           ├── static const Color secondaryRed
│   │           ├── static const Color successGreen
│   │           ├── static const Color warningOrange
│   │           ├── static const Color greyLight
│   │           ├── static const Color greyMedium
│   │           └── static const Color textColor
│   │
│   ├── routes/
│   │   └── app_routes.dart                         # Définition routes
│   │       └── class AppRoutes
│   │           ├── // Routes communes
│   │           ├── static const String splash = '/'
│   │           ├── static const String onboarding = '/onboarding'
│   │           ├── // Routes Patient
│   │           ├── static const String patientDashboard = '/patient/dashboard'
│   │           ├── static const String patientSettings = '/patient/settings'
│   │           ├── // Routes Cardiologue
│   │           ├── static const String doctorDashboard = '/doctor/dashboard'
│   │           └── static const String doctorProfile = '/doctor/profile'
│   │
│   └── screens/
│       ├── common/                                  # Écrans partagés
│       │   ├── splash_screen.dart
│       │   ├── onboarding_screen.dart
│       │   ├── profile_choice_screen.dart
│       │   ├── patient_login_screen.dart
│       │   ├── doctor_login_screen.dart
│       │   ├── patient_register_screen.dart        # 4 étapes
│       │   ├── payment_screen.dart
│       │   └── notifications_screen.dart
│       │
│       ├── patient/                                 # Écrans patient
│       │   ├── patient_dashboard_screen.dart       # Tableau de bord
│       │   ├── record_pressure_photo_screen.dart   # Scan OCR
│       │   ├── record_pressure_manual_screen.dart  # Saisie manuelle
│       │   ├── add_context_screen.dart             # Ajouter contexte
│       │   ├── patient_history_screen.dart         # Historique mesures
│       │   ├── patient_measure_detail_screen.dart  # Détail d'une mesure
│       │   ├── patient_messages_screen.dart        # Liste conversations
│       │   ├── patient_chat_screen.dart            # Conversation 1-1
│       │   ├── patient_profile_screen.dart         # Profil patient
│       │   ├── patient_settings_screen.dart        # Paramètres
│       │   └── patient_documents_screen.dart       # Documents médicaux
│       │
│       ├── doctor/                                  # Écrans cardiologue
│       │   ├── doctor_dashboard_screen.dart        # Tableau de bord
│       │   ├── doctor_patients_screen.dart         # Liste patients
│       │   ├── doctor_patient_file_screen.dart     # Dossier patient
│       │   └── doctor_profile_screen.dart          # Profil cardiologue
│       │
│       └── utils/
│           └── placeholder_screen.dart             # Écran temporaire
```

### Flux de navigation de l'application

```
┌─────────────┐
│   Splash    │  (/)
│  (3 sec)    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Onboarding  │  (/onboarding)
│  (3 pages)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Choix     │  (/profile-choice)
│   Profil    │  ┌─────────────────┐
│             │  │  Patient  │  Dr │
└──────┬──────┘  └─────┬─────────┬─┘
       │               │         │
       ├───────────────┘         │
       │                         │
       ▼                         ▼
┌─────────────┐         ┌─────────────┐
│   Patient   │         │ Cardiologue │
│    Login    │         │    Login    │
└──────┬──────┘         └──────┬──────┘
       │                       │
       │ (new user)            │
       ▼                       │
┌─────────────┐                │
│   Patient   │                │
│ Register    │                │
│  (4 étapes) │                │
└──────┬──────┘                │
       │                       │
       ▼                       ▼
┌─────────────┐         ┌─────────────┐
│  Paiement   │         │  Dashboard  │
│ (Abonnement)│         │ Cardiologue │
└──────┬──────┘         └──────┬──────┘
       │                       │
       ▼                       │
┌─────────────┐                │
│  Dashboard  │                │
│   Patient   │                │
│             │                │
│ ┌─────────┐ │                │
│ │  Home   │ │                │
│ │History  │ │                │
│ │ Mesure  │ │                │
│ │Messages │ │                │
│ │ Profil  │ │                │
│ └─────────┘ │                │
└─────────────┘                │
       │                       │
       │ Profil                │ Profil
       ▼                       ▼
┌─────────────┐         ┌─────────────┐
│   Patient   │         │ Cardiologue │
│   Profile   │         │   Profile   │
│             │         │             │
│ • Info      │         │ • QR Code   │
│ • Settings  │         │ • Info prof │
│ • Documents │         │ • Horaires  │
│ • Logout    │         │ • Stats     │
└─────────────┘         │ • Settings  │
                        │ • Abonnement│
                        │ • Logout    │
                        └─────────────┘
```

### Principes de conception

#### 1. Séparation des responsabilités

```
PRINCIPE: Chaque fichier a une responsabilité unique

app_routes.dart
  → Définir les constantes de routes uniquement

main.dart
  → Configuration de l'application + enregistrement des routes

[nom]_screen.dart
  → Affichage et logique d'UN SEUL écran

app_theme.dart
  → Définir les couleurs et le thème uniquement
```

#### 2. Navigation déclarative

```
PRINCIPE: Routes déclarées au démarrage, navigation par nom

AVANTAGES:
  • Code centralisé (main.dart)
  • Facile à maintenir
  • Type-safe avec constantes
  • Pas de couplage fort entre écrans

EXEMPLE:
  ✓ Navigator.pushNamed(context, AppRoutes.patientSettings)
  ✗ Navigator.push(context, MaterialPageRoute(builder: (context) => PatientSettingsScreen()))
```

#### 3. Immutabilité

```
PRINCIPE: Utiliser const partout où possible

AVANTAGES:
  • Meilleures performances
  • Moins de rebuilds inutiles
  • Code plus prévisible

EXEMPLE:
  ✓ const Text('Titre')
  ✓ const SizedBox(height: 16)
  ✓ const Icon(Icons.home)
  ✗ Text('Titre')  // Sans const
```

#### 4. Type de widget approprié

```
DÉCISION: StatelessWidget vs StatefulWidget

StatelessWidget:
  • Pas d'état qui change
  • Affichage simple
  • Performance optimale
  • Exemples: Profil, Détails, Liste statique

StatefulWidget:
  • État qui change (formulaire, switch, etc.)
  • Interactions utilisateur
  • Animations
  • Exemples: Settings, Formulaire, Timer
```

---

## 9. CONVENTIONS ET BONNES PRATIQUES

### Nommage

| Élément | Convention | Exemple |
|---------|------------|---------|
| Fichier | snake_case | `patient_settings_screen.dart` |
| Classe | PascalCase | `PatientSettingsScreen` |
| Variable | camelCase | `_notificationsEnabled` |
| Constante route | camelCase | `patientSettings` |
| Chemin route | kebab-case | `/patient/settings` |
| Fonction privée | _camelCase | `_saveSettings()` |
| Dossier | snake_case | `screens/patient/` |

### Structure d'un écran

```dart
// 1. IMPORTS (ordre alphabétique)
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:flutter/material.dart';

// 2. CLASSE PRINCIPALE
class NomScreen extends StatelessWidget {
  const NomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. RÉCUPÉRATION ARGUMENTS (si nécessaire)
    final arguments = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;

    // 4. SCAFFOLD avec structure claire
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titre'),
        actions: [ /* ... */ ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenu organisé en sections
          ],
        ),
      ),
      floatingActionButton: /* ... */,  // Optionnel
      bottomNavigationBar: /* ... */,   // Optionnel
    );
  }

  // 5. WIDGETS HELPER (privés)
  Widget _buildSection() {
    return Container(/* ... */);
  }

  // 6. FONCTIONS D'ACTION (privées)
  void _handleAction() {
    // Logique
  }
}

// 7. CLASSES HELPER (si nécessaire)
class _CustomWidget extends StatelessWidget {
  /* ... */
}
```

### Gestion des couleurs

```dart
// ✓ CORRECT: Utiliser AppTheme
Container(
  color: AppTheme.primaryBlue,
  child: Text(
    'Titre',
    style: TextStyle(color: Colors.white),
  ),
)

// ✓ CORRECT: Utiliser le thème
Text(
  'Titre',
  style: Theme.of(context).textTheme.headlineMedium,
)

// ✗ INCORRECT: Hardcoder les couleurs
Container(
  color: Color(0xFF0066CC),  // Ne pas faire
)
```

### Gestion de l'espacement

```dart
// ✓ CORRECT: Multiples de 4 ou 8
const SizedBox(height: 8)
const SizedBox(height: 16)
const SizedBox(height: 24)
const EdgeInsets.all(16)
const EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// ✗ INCORRECT: Valeurs arbitraires
const SizedBox(height: 13)
const EdgeInsets.all(17)
```

### Gestion des textes

```dart
// ✓ CORRECT: Utiliser les styles du thème
Text(
  'Titre principal',
  style: Theme.of(context).textTheme.headlineMedium,
)

Text(
  'Sous-titre',
  style: Theme.of(context).textTheme.titleMedium,
)

Text(
  'Corps de texte',
  style: Theme.of(context).textTheme.bodyMedium,
)

// ✓ CORRECT: Style personnalisé si nécessaire
Text(
  'Texte spécial',
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryBlue,
  ),
)
```

### Gestion des icônes

```dart
// ✓ CORRECT: Utiliser Icons de Material
Icon(Icons.home)
Icon(Icons.settings_outlined)  // Version outlined
Icon(Icons.person, size: 24, color: AppTheme.primaryBlue)

// ✓ CORRECT: Dans IconButton
IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () { /* action */ },
)

// ✓ CORRECT: Dans BottomNavigationBarItem
BottomNavigationBarItem(
  icon: Icon(Icons.home_outlined),
  activeIcon: Icon(Icons.home),  // Version pleine quand actif
  label: 'Accueil',
)
```

### Gestion des listes

```dart
// ✓ CORRECT: ListView pour liste scrollable
ListView(
  padding: const EdgeInsets.all(16),
  children: [
    _buildItem1(),
    _buildItem2(),
    const SizedBox(height: 16),
    _buildItem3(),
  ],
)

// ✓ CORRECT: ListView.builder pour liste dynamique
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return _buildItem(items[index]);
  },
)

// ✓ CORRECT: Column dans SingleChildScrollView
SingleChildScrollView(
  child: Column(
    children: [
      _buildSection1(),
      _buildSection2(),
    ],
  ),
)
```

### Gestion des formulaires

```dart
// ✓ CORRECT: StatefulWidget avec GlobalKey
class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();  // Important!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Traiter le formulaire
      final name = _nameController.text;
      // ...
    }
  }
}
```

---

## 10. CHECKLIST FINALE

### Avant de commencer

```
☐ Comprendre le besoin utilisateur
☐ Identifier la catégorie (Patient/Cardiologue/Commune)
☐ Choisir le type de widget (Stateless/Stateful)
☐ Lister les fonctionnalités nécessaires
☐ Identifier les navigations nécessaires
```

### Phase développement

```
☐ Étape 1: Route ajoutée dans app_routes.dart
☐ Étape 2: Écran créé dans le bon dossier
☐ Étape 3: Import ajouté dans main.dart
☐ Étape 3: Route enregistrée dans routes: {}
☐ Étape 4: Navigation implémentée depuis l'écran source
☐ Étape 5: Arguments gérés (si applicable)
```

### Phase vérification

```
☐ flutter analyze → 0 errors
☐ Imports corrects et organisés
☐ const utilisé partout où possible
☐ Couleurs depuis AppTheme
☐ Pas de hardcoding de valeurs
☐ Nommage cohérent
☐ Code commenté si nécessaire
```

### Phase test

```
☐ flutter clean exécuté
☐ flutter pub get exécuté
☐ flutter run → app démarre
☐ Navigation vers nouvelle page fonctionne
☐ Contenu s'affiche correctement
☐ Bouton retour fonctionne
☐ Arguments transmis correctement (si applicable)
☐ Pas de page blanche
☐ Pas d'erreur dans les logs
☐ Navigation répétée fonctionne
☐ Autres pages non impactées
☐ BottomNavigationBar fonctionne (si modifié)
☐ Test sur différentes tailles d'écran
```

### Phase finalisation

```
☐ Code nettoyé (pas de code commenté inutile)
☐ Warnings corrigés si possibles
☐ Backup créé (si modifications importantes)
☐ Documentation mise à jour (si nécessaire)
☐ Changements validés par l'utilisateur
```

---

## ANNEXES

### A. Résumé des commandes Flutter

```bash
# Analyser le code
flutter analyze

# Nettoyer le projet
flutter clean

# Récupérer les dépendances
flutter pub get

# Lancer l'application
flutter run

# Lancer sur un device spécifique
flutter run -d chrome
flutter run -d <device-id>

# Lister les devices
flutter devices

# Hot reload (dans terminal flutter run)
r

# Hot restart (dans terminal flutter run)
R

# Afficher les logs détaillés (dans terminal flutter run)
l

# Quitter l'application (dans terminal flutter run)
q
```

### B. Codes couleur AppTheme

```dart
AppTheme.primaryBlue      // #0066CC - Bleu principal
AppTheme.secondaryRed     // #DC143C - Rouge (alertes, dangers)
AppTheme.successGreen     // #28A745 - Vert (succès, validations)
AppTheme.warningOrange    // #FF8C00 - Orange (avertissements)
AppTheme.greyLight        // #F5F5F5 - Gris clair (arrière-plans)
AppTheme.greyMedium       // #9E9E9E - Gris moyen (bordures)
AppTheme.textColor        // #212121 - Texte principal
```

### C. Erreurs communes et solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| Undefined name 'AppRoutes' | Import manquant | Ajouter `import 'package:dr_cardio/routes/app_routes.dart';` |
| Page blanche | Route non enregistrée | Vérifier main.dart + redémarrage complet |
| Could not find route | Nom de route incorrect | Vérifier cohérence AppRoutes vs main.dart |
| MouseTracker assertion | Problème callback/rebuild | Simplifier callbacks + redémarrage complet |
| BuildContext async gap | Context utilisé après async | Ajouter `if (!mounted) return;` |
| withOpacity deprecated | API obsolète | Utiliser `withValues(alpha: 0.5)` |

### D. Glossaire

| Terme | Définition |
|-------|------------|
| Route | Chemin de navigation ("/patient/settings") |
| Screen | Un écran/page de l'application |
| Widget | Élément d'interface (bouton, texte, etc.) |
| Scaffold | Structure de base d'un écran (AppBar + Body) |
| StatelessWidget | Widget sans état changeant |
| StatefulWidget | Widget avec état changeant |
| Navigator | Gestionnaire de navigation |
| Context | Contexte d'exécution d'un widget |
| Hot Reload | Recharger le code sans redémarrer |
| Hot Restart | Redémarrer en gardant l'état |
| AppBar | Barre supérieure d'un écran |
| BottomNavigationBar | Barre de navigation inférieure |
| MaterialApp | Widget racine de l'application |

---

**FIN DU DOCUMENT**

Ce fichier doit être utilisé comme référence complète pour ajouter de nouvelles pages et implémenter la navigation dans le projet DocteurCardio.

Pour toute question ou clarification, se référer à l'architecture du code et aux exemples fournis.

Version: 1.0
Date: 2025-11-13
Projet: DocteurCardio
