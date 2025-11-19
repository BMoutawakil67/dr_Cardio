# Guide de Mise en Place d'un Système de Mock Data Persistant pour Flutter

## Table des Matières
1. [Présentation des Solutions](#présentation-des-solutions)
2. [Architecture Recommandée](#architecture-recommandée)
3. [Implémentation avec SharedPreferences](#implémentation-avec-sharedpreferences)
4. [Implémentation avec Hive](#implémentation-avec-hive)
5. [Implémentation avec SQLite](#implémentation-avec-sqlite)
6. [Structure de Mock Data](#structure-de-mock-data)
7. [Exemple de MockRepository](#exemple-de-mockrepository)
8. [Simulation des Requêtes CRUD](#simulation-des-requêtes-crud)
9. [Algorithme d'Implémentation](#algorithme-dimplémentation)

---

## 1. Présentation des Solutions

### Comparaison des Solutions de Stockage Local

| Critère | SharedPreferences | Hive | SQLite |
|---------|-------------------|------|--------|
| **Complexité** | Simple | Moyenne | Élevée |
| **Performance** | Limitée | Excellente | Bonne |
| **Type de données** | Primitives + String | Objets complexes | Relationnelles |
| **Taille max** | ~10 MB | Illimitée | Illimitée |
| **Requêtes** | Non | Limitées | SQL complet |
| **Adaptation backend** | Moyenne | Bonne | Excellente |

### Recommandation pour votre projet Dr. Cardio

**Hive** est recommandé car :
- Stockage d'objets complexes (Patient, Doctor, MedicalNote)
- Performances excellentes
- Facile à remplacer par un backend REST
- Pas de code SQL à écrire

---

## 2. Architecture Recommandée

```
lib/
├── models/                     # Modèles de données
│   ├── patient_model.dart
│   ├── doctor_model.dart
│   └── medical_note_model.dart
├── repositories/               # Couche d'abstraction
│   ├── base_repository.dart    # Interface commune
│   ├── patient_repository.dart
│   ├── doctor_repository.dart
│   └── medical_note_repository.dart
├── services/
│   ├── mock/                   # Implémentation Mock
│   │   ├── mock_patient_service.dart
│   │   ├── mock_doctor_service.dart
│   │   └── mock_medical_note_service.dart
│   └── api/                    # Future implémentation Backend
│       ├── api_patient_service.dart
│       ├── api_doctor_service.dart
│       └── api_medical_note_service.dart
└── data/
    ├── local/                  # Gestion du stockage local
    │   ├── hive_database.dart
    │   └── mock_data_generator.dart
    └── mock_data/              # Données fictives initiales
        └── initial_data.dart
```

**Principes de l'architecture :**
1. **Repository Pattern** : Interface commune pour Mock et API
2. **Dependency Injection** : Basculer facilement entre Mock et API
3. **Séparation des responsabilités** : Modèles, Services, Stockage

---

## 3. Implémentation avec SharedPreferences

### Avantages
- Déjà installé dans votre projet
- Très simple à utiliser
- Parfait pour débuter

### Inconvénients
- Stockage limité (sérialisation JSON)
- Pas de requêtes complexes
- Performance limitée pour grandes listes

### Étapes d'installation
SharedPreferences est déjà dans votre `pubspec.yaml` :
```yaml
dependencies:
  shared_preferences: ^2.2.3
```

### Exemple de Service avec SharedPreferences

```dart
// lib/services/mock/shared_prefs_patient_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient_model.dart';

class SharedPrefsPatientService {
  static const String _patientsKey = 'patients_data';

  // Simuler un délai réseau
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // CREATE - Créer un nouveau patient
  Future<Patient> createPatient(Patient patient) async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final patients = await getAllPatients();

    // Vérifier si l'email existe déjà
    if (patients.any((p) => p.email == patient.email)) {
      throw Exception('Un patient avec cet email existe déjà');
    }

    patients.add(patient);
    await _savePatients(prefs, patients);

    return patient;
  }

  // READ - Récupérer tous les patients
  Future<List<Patient>> getAllPatients() async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final String? patientsJson = prefs.getString(_patientsKey);

    if (patientsJson == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(patientsJson);
    return decoded.map((json) => Patient.fromMap(json)).toList();
  }

  // READ - Récupérer un patient par ID
  Future<Patient?> getPatientById(String id) async {
    await _simulateNetworkDelay();

    final patients = await getAllPatients();
    try {
      return patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // READ - Rechercher des patients par nom
  Future<List<Patient>> searchPatients(String query) async {
    await _simulateNetworkDelay();

    final patients = await getAllPatients();
    return patients
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // UPDATE - Mettre à jour un patient
  Future<Patient> updatePatient(String id, Patient updatedPatient) async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final patients = await getAllPatients();

    final index = patients.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Patient non trouvé');
    }

    patients[index] = updatedPatient;
    await _savePatients(prefs, patients);

    return updatedPatient;
  }

  // DELETE - Supprimer un patient
  Future<void> deletePatient(String id) async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final patients = await getAllPatients();

    patients.removeWhere((p) => p.id == id);
    await _savePatients(prefs, patients);
  }

  // Méthode helper pour sauvegarder
  Future<void> _savePatients(SharedPreferences prefs, List<Patient> patients) async {
    final List<Map<String, dynamic>> jsonList =
        patients.map((p) => p.toMap()).toList();
    await prefs.setString(_patientsKey, json.encode(jsonList));
  }

  // BONUS - Nettoyer toutes les données
  Future<void> clearAllPatients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientsKey);
  }

  // BONUS - Initialiser avec des données de test
  Future<void> initializeMockData() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_patientsKey);

    if (existing == null) {
      final mockPatients = [
        Patient(
          id: 'p1',
          name: 'Jean Dupont',
          email: 'jean.dupont@example.com',
          phone: '0123456789',
          birthDate: DateTime(1980, 5, 15),
          password: 'password123',
          biometricAuthEnabled: false,
          subscriptionType: 'standard',
        ),
        Patient(
          id: 'p2',
          name: 'Marie Martin',
          email: 'marie.martin@example.com',
          phone: '0987654321',
          birthDate: DateTime(1990, 8, 22),
          password: 'password456',
          biometricAuthEnabled: true,
          subscriptionType: 'premium',
        ),
      ];

      await _savePatients(prefs, mockPatients);
    }
  }
}
```

---

## 4. Implémentation avec Hive (Recommandé)

### Avantages
- Très rapide (NoSQL natif)
- Stocke directement des objets Dart
- Facile à utiliser
- Parfait pour des données structurées comme Patient, Doctor

### Installation

Ajoutez dans `pubspec.yaml` :
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

Puis exécutez :
```bash
flutter pub get
```

### Préparation des modèles pour Hive

Modifiez vos modèles existants :

```dart
// lib/models/patient_model.dart
import 'package:hive/hive.dart';

part 'patient_model.g.dart'; // Fichier généré

@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final DateTime birthDate;

  @HiveField(5)
  final String password;

  @HiveField(6)
  final bool biometricAuthEnabled;

  @HiveField(7)
  final String subscriptionType;

  @HiveField(8)
  final String? doctorId;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.password,
    required this.biometricAuthEnabled,
    required this.subscriptionType,
    this.doctorId,
  });

  // Gardez vos méthodes toMap() et fromMap() pour compatibilité
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'biometricAuthEnabled': biometricAuthEnabled,
      'subscriptionType': subscriptionType,
      'doctorId': doctorId,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      birthDate: DateTime.parse(map['birthDate']),
      password: '',
      biometricAuthEnabled: map['biometricAuthEnabled'],
      subscriptionType: map['subscriptionType'],
      doctorId: map['doctorId'],
    );
  }
}
```

Générez le code Hive :
```bash
flutter packages pub run build_runner build
```

### Initialisation de Hive

```dart
// lib/data/local/hive_database.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/patient_model.dart';
import '../../models/doctor_model.dart';

class HiveDatabase {
  static const String patientsBox = 'patients';
  static const String doctorsBox = 'doctors';
  static const String medicalNotesBox = 'medical_notes';

  static Future<void> init() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    Hive.registerAdapter(PatientAdapter());
    // Hive.registerAdapter(DoctorAdapter());
    // Hive.registerAdapter(MedicalNoteAdapter());

    // Ouvrir les boxes
    await Hive.openBox<Patient>(patientsBox);
    // await Hive.openBox<Doctor>(doctorsBox);
    // await Hive.openBox<MedicalNote>(medicalNotesBox);
  }

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<void> clearAll() async {
    await Hive.box<Patient>(patientsBox).clear();
    // await Hive.box<Doctor>(doctorsBox).clear();
    // await Hive.box<MedicalNote>(medicalNotesBox).clear();
  }
}
```

### Service avec Hive

```dart
// lib/services/mock/hive_patient_service.dart
import 'package:hive/hive.dart';
import '../../models/patient_model.dart';
import '../../data/local/hive_database.dart';

class HivePatientService {
  Box<Patient> get _box => Hive.box<Patient>(HiveDatabase.patientsBox);

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // CREATE
  Future<Patient> createPatient(Patient patient) async {
    await _simulateNetworkDelay();

    // Vérifier si l'email existe déjà
    final existing = _box.values.where((p) => p.email == patient.email);
    if (existing.isNotEmpty) {
      throw Exception('Un patient avec cet email existe déjà');
    }

    await _box.put(patient.id, patient);
    return patient;
  }

  // READ - Tous les patients
  Future<List<Patient>> getAllPatients() async {
    await _simulateNetworkDelay();
    return _box.values.toList();
  }

  // READ - Par ID
  Future<Patient?> getPatientById(String id) async {
    await _simulateNetworkDelay();
    return _box.get(id);
  }

  // READ - Recherche
  Future<List<Patient>> searchPatients(String query) async {
    await _simulateNetworkDelay();
    return _box.values
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // UPDATE
  Future<Patient> updatePatient(String id, Patient updatedPatient) async {
    await _simulateNetworkDelay();

    if (!_box.containsKey(id)) {
      throw Exception('Patient non trouvé');
    }

    await _box.put(id, updatedPatient);
    return updatedPatient;
  }

  // DELETE
  Future<void> deletePatient(String id) async {
    await _simulateNetworkDelay();
    await _box.delete(id);
  }

  // BONUS - Initialiser des données
  Future<void> initializeMockData() async {
    if (_box.isEmpty) {
      final mockPatients = [
        Patient(
          id: 'p1',
          name: 'Jean Dupont',
          email: 'jean.dupont@example.com',
          phone: '0123456789',
          birthDate: DateTime(1980, 5, 15),
          password: 'password123',
          biometricAuthEnabled: false,
          subscriptionType: 'standard',
        ),
        Patient(
          id: 'p2',
          name: 'Marie Martin',
          email: 'marie.martin@example.com',
          phone: '0987654321',
          birthDate: DateTime(1990, 8, 22),
          password: 'password456',
          biometricAuthEnabled: true,
          subscriptionType: 'premium',
        ),
      ];

      for (var patient in mockPatients) {
        await _box.put(patient.id, patient);
      }
    }
  }
}
```

---

## 5. Implémentation avec SQLite

### Avantages
- Base de données relationnelle complète
- Requêtes SQL complexes (JOIN, GROUP BY, etc.)
- Idéal si vous avez beaucoup de relations entre entités
- Similaire à un vrai backend SQL

### Inconvénients
- Plus complexe à mettre en place
- Nécessite d'écrire du SQL
- Plus de code boilerplate

### Installation

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

### Service avec SQLite

```dart
// lib/data/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/patient_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dr_cardio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        biometricAuthEnabled INTEGER NOT NULL,
        subscriptionType TEXT NOT NULL,
        doctorId TEXT
      )
    ''');

    // Autres tables...
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

// lib/services/mock/sqlite_patient_service.dart
import '../../data/local/database_helper.dart';
import '../../models/patient_model.dart';

class SQLitePatientService {
  final dbHelper = DatabaseHelper.instance;

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // CREATE
  Future<Patient> createPatient(Patient patient) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    await db.insert('patients', patient.toMap());
    return patient;
  }

  // READ - Tous
  Future<List<Patient>> getAllPatients() async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('patients');
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  // READ - Par ID
  Future<Patient?> getPatientById(String id) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  // READ - Recherche
  Future<List<Patient>> searchPatients(String query) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  // UPDATE
  Future<Patient> updatePatient(String id, Patient updatedPatient) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    await db.update(
      'patients',
      updatedPatient.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    return updatedPatient;
  }

  // DELETE
  Future<void> deletePatient(String id) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // BONUS - Requête SQL personnalisée
  Future<List<Patient>> getPatientsBySubscription(String subscriptionType) async {
    await _simulateNetworkDelay();

    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'subscriptionType = ?',
      whereArgs: [subscriptionType],
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }
}
```

---

## 6. Structure de Mock Data

### Générateur de données fictives

```dart
// lib/data/mock_data/initial_data.dart
import 'package:uuid/uuid.dart';
import '../../models/patient_model.dart';
import '../../models/doctor_model.dart';

class InitialMockData {
  static const _uuid = Uuid();

  static List<Patient> generatePatients() {
    return [
      Patient(
        id: _uuid.v4(),
        name: 'Jean Dupont',
        email: 'jean.dupont@example.com',
        phone: '+33 6 12 34 56 78',
        birthDate: DateTime(1980, 5, 15),
        password: 'patient123',
        biometricAuthEnabled: false,
        subscriptionType: 'standard',
        doctorId: null,
      ),
      Patient(
        id: _uuid.v4(),
        name: 'Marie Martin',
        email: 'marie.martin@example.com',
        phone: '+33 6 98 76 54 32',
        birthDate: DateTime(1990, 8, 22),
        password: 'patient456',
        biometricAuthEnabled: true,
        subscriptionType: 'premium',
        doctorId: null,
      ),
      Patient(
        id: _uuid.v4(),
        name: 'Pierre Bernard',
        email: 'pierre.bernard@example.com',
        phone: '+33 7 11 22 33 44',
        birthDate: DateTime(1975, 12, 3),
        password: 'patient789',
        biometricAuthEnabled: false,
        subscriptionType: 'free',
        doctorId: null,
      ),
      Patient(
        id: _uuid.v4(),
        name: 'Sophie Dubois',
        email: 'sophie.dubois@example.com',
        phone: '+33 6 55 66 77 88',
        birthDate: DateTime(1985, 3, 18),
        password: 'patient000',
        biometricAuthEnabled: true,
        subscriptionType: 'premium',
        doctorId: null,
      ),
    ];
  }

  static List<Doctor> generateDoctors() {
    return [
      Doctor(
        name: 'Dr. Laurent Petit',
        email: 'l.petit@cardio.fr',
        phone: '+33 1 45 67 89 01',
        orderNumber: '12345FR',
        specialty: 'Cardiologie',
        office: 'Cabinet Paris 15e',
      ),
      Doctor(
        name: 'Dr. Catherine Rousseau',
        email: 'c.rousseau@cardio.fr',
        phone: '+33 1 98 76 54 32',
        orderNumber: '67890FR',
        specialty: 'Cardiologie Interventionnelle',
        office: 'Clinique Lyon',
      ),
      Doctor(
        name: 'Dr. Michel Lefebvre',
        email: 'm.lefebvre@cardio.fr',
        phone: '+33 4 12 34 56 78',
        orderNumber: '11223FR',
        specialty: 'Rythmologie',
        office: 'CHU Marseille',
      ),
    ];
  }
}
```

---

## 7. Exemple de MockRepository (Pattern Repository)

### Interface de base

```dart
// lib/repositories/base_repository.dart
abstract class BaseRepository<T> {
  Future<T> create(T item);
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> update(String id, T item);
  Future<void> delete(String id);
  Future<List<T>> search(String query);
}
```

### Repository pour Patient

```dart
// lib/repositories/patient_repository.dart
import '../models/patient_model.dart';
import 'base_repository.dart';

abstract class PatientRepository extends BaseRepository<Patient> {
  Future<Patient?> getByEmail(String email);
  Future<List<Patient>> getBySubscription(String subscriptionType);
  Future<List<Patient>> getByDoctor(String doctorId);
}
```

### Implémentation Mock

```dart
// lib/services/mock/mock_patient_repository.dart
import 'package:hive/hive.dart';
import '../../models/patient_model.dart';
import '../../repositories/patient_repository.dart';
import '../../data/local/hive_database.dart';

class MockPatientRepository implements PatientRepository {
  Box<Patient> get _box => Hive.box<Patient>(HiveDatabase.patientsBox);

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<Patient> create(Patient patient) async {
    await _simulateNetworkDelay();

    final existing = _box.values.where((p) => p.email == patient.email);
    if (existing.isNotEmpty) {
      throw Exception('Email already exists');
    }

    await _box.put(patient.id, patient);
    return patient;
  }

  @override
  Future<List<Patient>> getAll() async {
    await _simulateNetworkDelay();
    return _box.values.toList();
  }

  @override
  Future<Patient?> getById(String id) async {
    await _simulateNetworkDelay();
    return _box.get(id);
  }

  @override
  Future<Patient> update(String id, Patient patient) async {
    await _simulateNetworkDelay();

    if (!_box.containsKey(id)) {
      throw Exception('Patient not found');
    }

    await _box.put(id, patient);
    return patient;
  }

  @override
  Future<void> delete(String id) async {
    await _simulateNetworkDelay();
    await _box.delete(id);
  }

  @override
  Future<List<Patient>> search(String query) async {
    await _simulateNetworkDelay();
    return _box.values
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<Patient?> getByEmail(String email) async {
    await _simulateNetworkDelay();
    try {
      return _box.values.firstWhere((p) => p.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Patient>> getBySubscription(String subscriptionType) async {
    await _simulateNetworkDelay();
    return _box.values
        .where((p) => p.subscriptionType == subscriptionType)
        .toList();
  }

  @override
  Future<List<Patient>> getByDoctor(String doctorId) async {
    await _simulateNetworkDelay();
    return _box.values
        .where((p) => p.doctorId == doctorId)
        .toList();
  }
}
```

### Future implémentation API

```dart
// lib/services/api/api_patient_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/patient_model.dart';
import '../../repositories/patient_repository.dart';

class ApiPatientRepository implements PatientRepository {
  final String baseUrl = 'https://api.dr-cardio.com';

  @override
  Future<Patient> create(Patient patient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patient.toMap()),
    );

    if (response.statusCode == 201) {
      return Patient.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create patient');
    }
  }

  @override
  Future<List<Patient>> getAll() async {
    final response = await http.get(Uri.parse('$baseUrl/patients'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  @override
  Future<Patient?> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/patients/$id'));

    if (response.statusCode == 200) {
      return Patient.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load patient');
    }
  }

  @override
  Future<Patient> update(String id, Patient patient) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patient.toMap()),
    );

    if (response.statusCode == 200) {
      return Patient.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to update patient');
    }
  }

  @override
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/patients/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete patient');
    }
  }

  @override
  Future<List<Patient>> search(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromMap(json)).toList();
    } else {
      throw Exception('Failed to search patients');
    }
  }

  @override
  Future<Patient?> getByEmail(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients/email/$email'),
    );

    if (response.statusCode == 200) {
      return Patient.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load patient');
    }
  }

  @override
  Future<List<Patient>> getBySubscription(String subscriptionType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients?subscription=$subscriptionType'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  @override
  Future<List<Patient>> getByDoctor(String doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients?doctorId=$doctorId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Patient.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }
}
```

---

## 8. Simulation des Requêtes CRUD

### Configuration de Dependency Injection

```dart
// lib/config/service_locator.dart
import 'package:get_it/get_it.dart';
import '../repositories/patient_repository.dart';
import '../services/mock/mock_patient_repository.dart';
// import '../services/api/api_patient_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator({bool useMockData = true}) {
  // Enregistrer le repository selon le mode
  if (useMockData) {
    getIt.registerLazySingleton<PatientRepository>(
      () => MockPatientRepository(),
    );
  } else {
    // À activer quand le backend est prêt
    // getIt.registerLazySingleton<PatientRepository>(
    //   () => ApiPatientRepository(),
    // );
  }
}
```

### Utilisation dans un Widget

```dart
// lib/screens/patient/patient_list_screen.dart
import 'package:flutter/material.dart';
import '../../config/service_locator.dart';
import '../../repositories/patient_repository.dart';
import '../../models/patient_model.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientRepository _repository = getIt<PatientRepository>();
  List<Patient> _patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);

    try {
      final patients = await _repository.getAll();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deletePatient(String id) async {
    try {
      await _repository.delete(id);
      _loadPatients(); // Recharger la liste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient supprimé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return ListTile(
                  title: Text(patient.name),
                  subtitle: Text(patient.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deletePatient(patient.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers écran de création
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Exemples de simulation des opérations CRUD

```dart
// GET - Récupérer tous les patients
final patients = await _repository.getAll();

// GET - Récupérer un patient par ID
final patient = await _repository.getById('p1');

// POST - Créer un nouveau patient
final newPatient = Patient(
  id: const Uuid().v4(),
  name: 'Nouveau Patient',
  email: 'nouveau@example.com',
  phone: '0600000000',
  birthDate: DateTime(1995, 1, 1),
  password: 'password',
  biometricAuthEnabled: false,
  subscriptionType: 'free',
);
await _repository.create(newPatient);

// PUT - Mettre à jour un patient
final updatedPatient = patient.copyWith(name: 'Nom Modifié');
await _repository.update(patient.id, updatedPatient);

// DELETE - Supprimer un patient
await _repository.delete('p1');

// SEARCH - Rechercher des patients
final results = await _repository.search('jean');
```

---

## 9. Algorithme d'Implémentation

### Étape 1 : Préparation de l'environnement

```
DÉBUT
  1. Choisir le système de stockage (SharedPreferences, Hive, SQLite)
  2. Ajouter les dépendances dans pubspec.yaml
  3. Exécuter flutter pub get
FIN
```

### Étape 2 : Préparation des modèles

```
DÉBUT
  POUR chaque modèle (Patient, Doctor, MedicalNote)
    SI stockage == Hive ALORS
      1. Ajouter annotations @HiveType et @HiveField
      2. Générer les adaptateurs avec build_runner
    FIN SI

    3. Vérifier que toMap() et fromMap() existent
    4. Ajouter copyWith() si nécessaire pour modifications
  FIN POUR
FIN
```

### Étape 3 : Création de l'infrastructure de stockage

```
DÉBUT
  SI stockage == Hive ALORS
    1. Créer lib/data/local/hive_database.dart
    2. Initialiser Hive dans main.dart
    3. Enregistrer les adaptateurs
    4. Ouvrir les boxes
  SINON SI stockage == SQLite ALORS
    1. Créer lib/data/local/database_helper.dart
    2. Définir le schéma de la base de données
    3. Créer les tables
  SINON // SharedPreferences
    1. Rien à créer, utilisable directement
  FIN SI
FIN
```

### Étape 4 : Création des Repositories

```
DÉBUT
  1. Créer lib/repositories/base_repository.dart
     - Définir interface générique CRUD

  2. POUR chaque entité (Patient, Doctor, etc.)
     a. Créer lib/repositories/[entité]_repository.dart
        - Étendre BaseRepository
        - Ajouter méthodes spécifiques

     b. Créer lib/services/mock/mock_[entité]_repository.dart
        - Implémenter l'interface
        - Ajouter simulation de délai réseau
        - Gérer les erreurs

     c. Créer lib/services/api/api_[entité]_repository.dart (structure vide)
        - Préparer pour future implémentation
  FIN POUR
FIN
```

### Étape 5 : Génération de données fictives

```
DÉBUT
  1. Créer lib/data/mock_data/initial_data.dart
  2. Créer des méthodes statiques pour générer:
     - generatePatients()
     - generateDoctors()
     - generateMedicalNotes()
  3. Utiliser la bibliothèque uuid pour IDs uniques
FIN
```

### Étape 6 : Configuration du Service Locator

```
DÉBUT
  1. Ajouter get_it dans pubspec.yaml
  2. Créer lib/config/service_locator.dart
  3. Enregistrer les repositories:
     setupServiceLocator(useMockData: bool) {
       SI useMockData ALORS
         Enregistrer MockRepositories
       SINON
         Enregistrer ApiRepositories
       FIN SI
     }
  4. Appeler setupServiceLocator() dans main.dart
FIN
```

### Étape 7 : Initialisation des données

```
DÉBUT
  DANS main.dart, AVANT runApp():
    1. SI stockage == Hive ALORS
         await HiveDatabase.init()
       SINON SI stockage == SQLite ALORS
         await DatabaseHelper.instance.database
       FIN SI

    2. setupServiceLocator(useMockData: true)

    3. Initialiser les données de test:
       final patientRepo = getIt<PatientRepository>()
       SI base de données vide ALORS
         POUR chaque patient mock
           await patientRepo.create(patient)
         FIN POUR
       FIN SI
FIN
```

### Étape 8 : Utilisation dans les Widgets

```
DÉBUT
  DANS un StatefulWidget:
    1. Récupérer le repository:
       final repo = getIt<PatientRepository>()

    2. Charger les données:
       @override
       void initState() {
         _loadData()
       }

       Future<void> _loadData() async {
         setState(() => isLoading = true)
         TRY
           data = await repo.getAll()
         CATCH error
           Afficher message d'erreur
         FINALLY
           setState(() => isLoading = false)
       }

    3. Opérations CRUD:
       - Créer: await repo.create(item)
       - Lire: await repo.getAll() / getById(id)
       - Modifier: await repo.update(id, item)
       - Supprimer: await repo.delete(id)

    4. Après chaque opération:
       - Recharger les données
       - Afficher un feedback utilisateur
FIN
```

### Étape 9 : Tests et validation

```
DÉBUT
  1. Tester chaque opération CRUD:
     - Créer un élément
     - Lire les éléments
     - Modifier un élément
     - Supprimer un élément

  2. Vérifier la persistence:
     - Fermer l'application
     - Rouvrir l'application
     - Vérifier que les données sont toujours là

  3. Tester les cas d'erreur:
     - Créer un doublon
     - Modifier un élément inexistant
     - Supprimer un élément inexistant
FIN
```

### Étape 10 : Préparation pour le backend réel

```
DÉBUT
  QUAND le backend est prêt:
    1. Implémenter les ApiRepositories dans lib/services/api/
    2. Utiliser http ou dio pour les requêtes HTTP
    3. Gérer l'authentification (tokens JWT, etc.)
    4. Dans service_locator.dart:
       setupServiceLocator(useMockData: false)
    5. Aucun changement dans les Widgets nécessaire!
FIN
```

---

## Résumé de l'algorithme complet

```
ALGORITHME MiseEnPlaceMockData

VARIABLES
  stockageChoisi: String  // 'shared_prefs', 'hive', ou 'sqlite'
  entités: Liste[String] = ['Patient', 'Doctor', 'MedicalNote']

DÉBUT
  // PHASE 1: INSTALLATION
  1. AjouterDépendances(stockageChoisi)
  2. ExécuterFlutterPubGet()

  // PHASE 2: PRÉPARATION DES MODÈLES
  POUR CHAQUE entité DANS entités FAIRE
    3. PréparerModèle(entité, stockageChoisi)
  FIN POUR

  // PHASE 3: INFRASTRUCTURE
  4. CréerInfrastructureStockage(stockageChoisi)

  // PHASE 4: REPOSITORIES
  POUR CHAQUE entité DANS entités FAIRE
    5. CréerInterfaceRepository(entité)
    6. CréerMockRepository(entité)
    7. CréerApiRepository(entité) // Vide pour l'instant
  FIN POUR

  // PHASE 5: DONNÉES FICTIVES
  8. CréerGénérateurDonnéesFictives()

  // PHASE 6: DEPENDENCY INJECTION
  9. ConfigurerServiceLocator()

  // PHASE 7: INITIALISATION
  10. InitialiserDansMain()

  // PHASE 8: UTILISATION
  11. ImplémenterdansWidgets()

  // PHASE 9: TESTS
  12. TesterCRUD()
  13. TesterPersistence()

  // PHASE 10: PRÉPARATION FUTURE
  14. DocumenterMigrationVersAPI()
FIN

// TEMPS ESTIMÉ
// - SharedPreferences: 2-3 heures
// - Hive: 3-4 heures
// - SQLite: 4-6 heures
```

---

## Points importants à retenir

1. **Isolation du code métier** : Les widgets ne savent pas s'ils utilisent Mock ou API
2. **Pattern Repository** : Interface unique, implémentations multiples
3. **Simulation réaliste** : Ajouter des délais pour simuler la latence réseau
4. **Gestion d'erreurs** : Prévoir les cas d'échec dès le début
5. **Migration facile** : Un simple changement dans `service_locator.dart` pour passer en mode API

## Recommandation finale pour Dr. Cardio

**Utilisez Hive** car :
- Stockage d'objets complexes (Patient avec toutes ses propriétés)
- Performance excellente pour liste de patients
- Code plus propre que SQLite
- Plus robuste que SharedPreferences
- Facile à remplacer par API REST plus tard

Bonne chance avec votre implémentation !
