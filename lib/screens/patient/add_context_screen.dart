import 'package:flutter/material.dart';

class AddContextScreen extends StatefulWidget {
  const AddContextScreen({super.key});

  @override
  State<AddContextScreen> createState() => _AddContextScreenState();
}

class _AddContextScreenState extends State<AddContextScreen> {
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();

  final Map<String, bool> _medications = {
    'Amlodipine 5mg': false,
    'Losartan 50mg': false,
    'Aspirine 100mg': false,
  };
  String _activity = 'Aucune';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get existing context if provided
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('context')) {
      final existingContext = args['context'] as String?;
      if (existingContext != null && existingContext.isNotEmpty) {
        _notesController.text = existingContext;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _buildContextString() {
    final parts = <String>[];

    // Medications
    final selectedMeds = _medications.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedMeds.isNotEmpty) {
      parts.add('Médicaments: ${selectedMeds.join(", ")}');
    }

    // Weight
    if (_weightController.text.isNotEmpty) {
      parts.add('Poids: ${_weightController.text} kg');
    }

    // Activity
    if (_activity != 'Aucune') {
      parts.add('Activité: $_activity');
    }

    // Notes
    if (_notesController.text.isNotEmpty) {
      parts.add('Notes: ${_notesController.text}');
    }

    return parts.isEmpty ? '' : parts.join(' | ');
  }

  void _saveContext() {
    final contextString = _buildContextString();
    Navigator.pop(context, contextString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Ajoutez des informations complémentaires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('💊 Médicaments pris'),
            const SizedBox(height: 10),
            _buildMedicationList(),
            const SizedBox(height: 20),
            _buildSectionTitle('⚖️ Poids (kg) - Optionnel'),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '75',
                labelText: 'Poids',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('🏃 Activité physique'),
            const SizedBox(height: 10),
            _buildActivityList(),
            const SizedBox(height: 20),
            _buildSectionTitle('📝 Notes (optionnel)'),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Ressenti stress, après repas, au repos...',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveContext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildMedicationList() {
    return Column(
      children: _medications.keys.map((String key) {
        return CheckboxListTile(
          title: Text(key),
          value: _medications[key],
          onChanged: (bool? value) {
            setState(() {
              _medications[key] = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Aucune'),
          value: 'Aucune',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Légère (marche)'),
          value: 'Légère (marche)',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Modérée (sport)'),
          value: 'Modérée (sport)',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Intense'),
          value: 'Intense',
          groupValue: _activity,
          onChanged: (String? value) {
            setState(() {
              _activity = value!;
            });
          },
        ),
      ],
    );
  }
}
