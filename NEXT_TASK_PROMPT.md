# 🎯 TÂCHE : Connecter l'Interface Utilisateur aux Repositories Hive

## 📋 Contexte

L'application **Dr. Cardio** dispose d'un **système Hive fonctionnel** avec des données mock persistées et des repositories optimisés. Cependant, les écrans de l'interface utilisateur utilisent encore des **données en dur (hardcodées)** au lieu des repositories.

### État Actuel de l'Infrastructure

✅ **INFRASTRUCTURE PRÊTE** :
- Modèles de données immutables : `Patient`, `Doctor`, `MedicalNote`
- 3 Repositories avec cache optimisé : `PatientRepository`, `DoctorRepository`, `MedicalNoteRepository`
- Données mock persistées dans Hive (2 patients, 1 docteur, 3 notes médicales)
- Gestion d'erreurs robuste avec try-catch
- Architecture suivant le pattern Repository

❌ **UI NON CONNECTÉE** :
- Les écrans affichent des listes statiques
- Aucune persistance des modifications
- Les repositories ne sont pas utilisés dans l'UI

---

## 🎯 Objectif de la Tâche

**Remplacer les données en dur dans les écrans par des appels aux repositories Hive.**

Cela permettra :
1. ✅ Affichage des vraies données persistées
2. ✅ Persistance des ajouts/modifications/suppressions
3. ✅ Synchronisation automatique entre les écrans
4. ✅ Base solide pour la future API backend

---

## 📁 Fichiers à Modifier

### PRIORITÉ 1 - Écrans Critiques

#### 1. Liste des Patients (Docteur)
**Fichier** : `lib/screens/doctor/doctor_patients_screen.dart`

**Problème actuel** :
```dart
// Ligne ~20-50 : Liste en dur
final List<Map<String, dynamic>> _allPatients = [
  {'name': 'Jean Dupont', 'age': 45, ...},
  {'name': 'Marie Koffi', 'age': 52, ...},
  // ...
];
```

**Solution attendue** :
- Utiliser `PatientRepository().getAllPatients()` dans un `FutureBuilder`
- Afficher les 2 patients mock (Jean Dupont, Marie Curie)
- Permettre la navigation vers le dossier patient avec l'ID

**Données mock disponibles** :
- 2 patients : Jean Dupont (45 ans), Marie Curie (50 ans)
- Champs : `firstName`, `lastName`, `email`, `phoneNumber`, `address`, `birthDate`, `gender`

---

#### 2. Dossier Patient (Docteur)
**Fichier** : `lib/screens/doctor/doctor_patient_file_screen.dart`

**Problème actuel** :
```dart
// Ligne ~30-36 : Utilise SharedPreferences (JSON)
final prefs = await SharedPreferences.getInstance();
final notesJson = prefs.getString('medical_notes_$_patientId');
_medicalNotes = notesList.map((note) => MedicalNote.fromMap(note)).toList();
```

**Solution attendue** :
- Remplacer SharedPreferences par `MedicalNoteRepository().getMedicalNotesByPatient(patientId)`
- Utiliser `StreamBuilder` ou `FutureBuilder` pour l'affichage
- Les méthodes `_saveNote()`, `_editNote()`, `_deleteNote()` doivent utiliser le repository

**Données mock disponibles** :
- 3 notes médicales avec mesures cardiaques (systolic, diastolic, heartRate, context)
- Note 1 : Jean Dupont - 120/80, 70 bpm
- Note 2 : Jean Dupont - 130/85, 75 bpm
- Note 3 : Marie Curie - 140/90, 80 bpm

---

#### 3. Historique Patient
**Fichier** : `lib/screens/patient/patient_history_screen.dart`

**Problème actuel** :
```dart
// Pas de données affichées, juste des widgets vides
// Les graphiques ne sont pas alimentés
```

**Solution attendue** :
- Utiliser `MedicalNoteRepository().getMedicalNotesByPatient(currentPatientId)`
- Afficher les mesures dans une liste chronologique
- Générer le graphique avec les vraies données
- Filtrer par période (7J, 1M, 3M, etc.)

**Données mock disponibles** :
- Notes avec dates différentes (aujourd'hui, -30 jours, -10 jours)
- Possibilité de calculer des moyennes et tendances

---

### PRIORITÉ 2 - Dashboards

#### 4. Dashboard Docteur
**Fichier** : `lib/screens/doctor/doctor_dashboard_screen.dart`

**Solution attendue** :
- Statistiques basées sur `PatientRepository().getAllPatients()`
- Alertes basées sur `MedicalNoteRepository().getAllMedicalNotes()`
- Nombre de patients actifs, mesures critiques, etc.

---

#### 5. Dashboard Patient
**Fichier** : `lib/screens/patient/patient_dashboard_screen.dart`

**Solution attendue** :
- Dernière mesure via `MedicalNoteRepository().getMedicalNotesByPatient()`
- Tendance (amélioration/dégradation) basée sur l'historique
- Graphique de la semaine avec vraies données

---

## 🛠️ Repositories Disponibles

### PatientRepository
**Localisation** : `lib/repositories/patient_repository.dart`

**Méthodes disponibles** :
```dart
// Récupérer tous les patients
Future<List<Patient>> getAllPatients() async

// Récupérer un patient par ID
Future<Patient?> getPatient(String id) async

// Ajouter un patient
Future<int> addPatient(Patient patient) async

// Modifier un patient
Future<bool> updatePatient(Patient patient) async

// Supprimer un patient
Future<bool> deletePatient(String id) async
```

**Utilisation typique** :
```dart
// Dans un FutureBuilder
FutureBuilder<List<Patient>>(
  future: PatientRepository().getAllPatients(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Erreur: ${snapshot.error}');
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('Aucun patient trouvé');
    }

    final patients = snapshot.data!;
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return ListTile(
          title: Text('${patient.firstName} ${patient.lastName}'),
          subtitle: Text(patient.email),
          onTap: () => _navigateToPatientFile(patient.id),
        );
      },
    );
  },
)
```

---

### MedicalNoteRepository
**Localisation** : `lib/repositories/medical_note_repository.dart`

**Méthodes disponibles** :
```dart
// Récupérer toutes les notes
Future<List<MedicalNote>> getAllMedicalNotes() async

// Récupérer une note par ID
Future<MedicalNote?> getMedicalNote(String id) async

// Récupérer les notes d'un patient spécifique
Future<List<MedicalNote>> getMedicalNotesByPatient(String patientId) async

// Ajouter une note
Future<int> addMedicalNote(MedicalNote note) async

// Modifier une note
Future<bool> updateMedicalNote(MedicalNote note) async

// Supprimer une note
Future<bool> deleteMedicalNote(String id) async
```

**Utilisation typique** :
```dart
// Récupérer les notes d'un patient
final notes = await MedicalNoteRepository().getMedicalNotesByPatient('patient-001');

// Ajouter une nouvelle note
final newNote = MedicalNote(
  id: Uuid().v4(),
  patientId: 'patient-001',
  doctorId: 'doctor-001',
  date: DateTime.now(),
  systolic: 120,
  diastolic: 80,
  heartRate: 70,
  context: 'Consultation de routine',
);
await MedicalNoteRepository().addMedicalNote(newNote);

// Modifier une note (immutable, donc utiliser copyWith)
final updatedNote = existingNote.copyWith(
  systolic: 125,
  context: 'Mesure mise à jour',
);
await MedicalNoteRepository().updateMedicalNote(updatedNote);
```

---

### DoctorRepository
**Localisation** : `lib/repositories/doctor_repository.dart`

**Méthodes disponibles** :
```dart
Future<List<Doctor>> getAllDoctors() async
Future<Doctor?> getDoctor(String id) async
Future<int> addDoctor(Doctor doctor) async
Future<bool> updateDoctor(Doctor doctor) async
Future<bool> deleteDoctor(String id) async
```

---

## 📊 Données Mock Actuelles

### Patients (2)
```dart
Patient(
  id: 'patient-001',
  firstName: 'Jean',
  lastName: 'Dupont',
  email: 'jean.dupont@example.com',
  phoneNumber: '0123456789',
  address: '123 Rue de la Paix, 75001 Paris',
  birthDate: DateTime(1980, 5, 15), // 45 ans
  gender: 'Homme',
)

Patient(
  id: 'patient-002',
  firstName: 'Marie',
  lastName: 'Curie',
  email: 'marie.curie@example.com',
  phoneNumber: '0987654321',
  address: '456 Avenue des Champs-Élysées, 75008 Paris',
  birthDate: DateTime(1975, 8, 22), // 50 ans
  gender: 'Femme',
)
```

### Docteur (1)
```dart
Doctor(
  id: 'doctor-001',
  firstName: 'Alain',
  lastName: 'Martin',
  email: 'alain.martin@example.com',
  phoneNumber: '0123456789',
  specialty: 'Cardiologue',
  address: '789 Boulevard Saint-Germain, 75006 Paris',
)
```

### Notes Médicales (3)
```dart
MedicalNote(
  id: 'note-001',
  patientId: 'patient-001',
  doctorId: 'doctor-001',
  date: DateTime.now(),
  systolic: 120,
  diastolic: 80,
  heartRate: 70,
  context: 'Consultation de routine',
)

MedicalNote(
  id: 'note-002',
  patientId: 'patient-001',
  doctorId: 'doctor-001',
  date: DateTime.now().subtract(Duration(days: 30)),
  systolic: 130,
  diastolic: 85,
  heartRate: 75,
  context: 'Suivi mensuel',
)

MedicalNote(
  id: 'note-003',
  patientId: 'patient-002',
  doctorId: 'doctor-001',
  date: DateTime.now().subtract(Duration(days: 10)),
  systolic: 140,
  diastolic: 90,
  heartRate: 80,
  context: 'Première consultation',
)
```

---

## ✅ Checklist de Réalisation

### Pour chaque écran :

- [ ] **Importer le repository nécessaire**
  ```dart
  import 'package:dr_cardio/repositories/patient_repository.dart';
  import 'package:dr_cardio/repositories/medical_note_repository.dart';
  ```

- [ ] **Remplacer les données statiques par FutureBuilder/StreamBuilder**
  ```dart
  FutureBuilder<List<Patient>>(
    future: PatientRepository().getAllPatients(),
    builder: (context, snapshot) { ... }
  )
  ```

- [ ] **Gérer les états de chargement**
  - Loading : `CircularProgressIndicator`
  - Error : Message d'erreur clair
  - Empty : Message "Aucune donnée"
  - Success : Affichage des données

- [ ] **Implémenter les opérations CRUD via repositories**
  - Ajout : `repository.add(item)`
  - Modification : `repository.update(item.copyWith(...))`
  - Suppression : `repository.delete(id)`

- [ ] **Rafraîchir l'UI après modification**
  - Appeler `setState()` après les opérations
  - Ou utiliser un `StreamBuilder` pour refresh automatique

- [ ] **Tester avec les données mock**
  - Vérifier que les 2 patients s'affichent
  - Vérifier que les 3 notes apparaissent
  - Tester l'ajout/modification/suppression

---

## 🧪 Tests de Validation

### Après modification, vérifier :

1. **Au démarrage de l'app** :
   - [ ] Les logs affichent "Generated and saved mock patients/doctors/notes"
   - [ ] La liste des patients montre Jean Dupont et Marie Curie
   - [ ] Le dossier de Jean Dupont montre 2 notes
   - [ ] Le dossier de Marie Curie montre 1 note

2. **Ajout d'une nouvelle mesure** :
   - [ ] La mesure est persistée (visible après redémarrage de l'app)
   - [ ] Elle apparaît dans l'historique
   - [ ] Le dashboard patient se met à jour

3. **Modification d'une mesure** :
   - [ ] Les changements sont sauvegardés
   - [ ] Visible après redémarrage

4. **Suppression d'une mesure** :
   - [ ] La mesure disparaît de l'historique
   - [ ] Pas de crash, gestion propre

5. **Persistance** :
   - [ ] Redémarrer l'application
   - [ ] Les données mock sont toujours là
   - [ ] Les modifications ajoutées manuellement sont conservées

---

## 🎨 Considérations UI/UX

### Gestion du Loading
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Chargement des données...'),
      ],
    ),
  );
}
```

### Gestion des Erreurs
```dart
if (snapshot.hasError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text('Erreur lors du chargement'),
        SizedBox(height: 8),
        Text('${snapshot.error}', style: TextStyle(fontSize: 12)),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() {}), // Reload
          child: Text('Réessayer'),
        ),
      ],
    ),
  );
}
```

### Données Vides
```dart
if (!snapshot.hasData || snapshot.data!.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 48, color: Colors.grey),
        SizedBox(height: 16),
        Text('Aucun patient trouvé'),
        SizedBox(height: 8),
        Text('Les patients apparaîtront ici',
          style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
```

---

## 📚 Ressources et Références

### Documentation Interne
- `monHistoriqueDeModification.md` : Historique complet des modifications
- `lib/models/` : Définition des modèles de données
- `lib/repositories/` : Implémentation des repositories
- `lib/services/mock/mock_service.dart` : Génération des données mock

### Patterns à Suivre
1. **Immutabilité** : Utiliser `copyWith()` pour modifier les objets
2. **Async/Await** : Toutes les opérations repository sont asynchrones
3. **Error Handling** : Try-catch dans les repositories, vérifier les erreurs dans l'UI
4. **Cache** : Les repositories ont un cache automatique, pas besoin de gestion manuelle

---

## 🚀 Ordre d'Implémentation Recommandé

1. **JOUR 1** : Liste des patients (doctor_patients_screen.dart)
   - Le plus simple, bonne introduction
   - Permet de valider que les repositories fonctionnent

2. **JOUR 2** : Dossier patient (doctor_patient_file_screen.dart)
   - Plus complexe (CRUD complet)
   - Migration depuis SharedPreferences

3. **JOUR 3** : Historique patient (patient_history_screen.dart)
   - Filtrage par patient
   - Génération de graphiques

4. **JOUR 4** : Dashboards (doctor + patient)
   - Calculs de statistiques
   - Affichage des tendances

5. **JOUR 5** : Tests et polish
   - Validation complète
   - Gestion des cas limites
   - Amélioration UX

---

## ⚠️ Points d'Attention

1. **ID Patient** : Les écrans patient doivent connaître l'ID du patient connecté
   - Option 1 : Passer l'ID via les routes (arguments)
   - Option 2 : Créer un service d'authentification simple
   - Pour les tests : Utiliser 'patient-001' en dur temporairement

2. **Dates** : Les notes mock utilisent `DateTime.now()` et des soustractions
   - Elles seront donc relatives au moment du démarrage
   - Parfait pour tester les graphiques de tendance

3. **Immutabilité** : Ne pas oublier d'utiliser `copyWith()` pour les modifications
   ```dart
   // ❌ INCORRECT
   note.systolic = 125; // Erreur : final field

   // ✅ CORRECT
   final updatedNote = note.copyWith(systolic: 125);
   await repository.updateMedicalNote(updatedNote);
   ```

4. **Cache** : Les repositories ont un cache qui se reconstruit automatiquement
   - Pas besoin de vider manuellement
   - Reconstruction sur `_box.watch().listen()`

---

## 💡 Exemple Complet : Migration d'un Écran

### AVANT (Données en dur)
```dart
class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final List<Map<String, dynamic>> _allPatients = [
    {'name': 'Jean Dupont', 'age': 45, ...},
    {'name': 'Marie Koffi', 'age': 52, ...},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _allPatients.length,
      itemBuilder: (context, index) {
        final patient = _allPatients[index];
        return ListTile(
          title: Text(patient['name']),
          subtitle: Text('${patient['age']} ans'),
        );
      },
    );
  }
}
```

### APRÈS (Avec Repository)
```dart
import 'package:dr_cardio/repositories/patient_repository.dart';

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final _repository = PatientRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Patient>>(
      future: _repository.getAllPatients(),
      builder: (context, snapshot) {
        // État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Erreur
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        // Pas de données
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun patient'));
        }

        // Affichage des données
        final patients = snapshot.data!;
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            final age = DateTime.now().year - patient.birthDate.year;

            return ListTile(
              title: Text('${patient.firstName} ${patient.lastName}'),
              subtitle: Text('$age ans - ${patient.email}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.patientFile,
                  arguments: {'patientId': patient.id},
                );
              },
            );
          },
        );
      },
    );
  }
}
```

---

## 📞 En Cas de Blocage

Si vous rencontrez des difficultés :

1. **Vérifier les logs** : Les repositories loggent les erreurs
2. **Consulter** `monHistoriqueDeModification.md` pour l'architecture
3. **Tester les repositories directement** : Ajouter du code de test temporaire
4. **Vérifier que Hive est initialisé** : `HiveDatabase.init()` dans main.dart

---

## ✅ Critères de Succès

La tâche sera considérée comme réussie quand :

- [ ] Les 5 écrans affichent les données des repositories Hive
- [ ] Aucune donnée en dur ne subsiste
- [ ] Les opérations CRUD fonctionnent (ajout/modif/suppr de notes)
- [ ] Les données persistent après redémarrage de l'app
- [ ] Pas de régression (l'app compile et fonctionne)
- [ ] Les logs montrent bien le chargement des mocks au démarrage
- [ ] Tests manuels validés (checklist ci-dessus)

---

**Bonne chance ! L'infrastructure est solide, il ne reste plus qu'à connecter l'UI ! 🚀**
