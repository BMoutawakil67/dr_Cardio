import 'package:flutter/material.dart';

class AddContextScreen extends StatefulWidget {
  const AddContextScreen({super.key});

  @override
  State<AddContextScreen> createState() => _AddContextScreenState();
}

class _AddContextScreenState extends State<AddContextScreen> {
  final Map<String, bool> _medications = {
    'Amlodipine 5mg': false,
    'Losartan 50mg': true,
    'Aspirine 100mg': false,
  };
  String _activity = 'Légère (marche)';
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '75',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('🏃 Activité physique'),
            const SizedBox(height: 10),
            _buildActivityList(),
            const SizedBox(height: 20),
            _buildSectionTitle('🚶 Pas aujourd\'hui'),
            const SizedBox(height: 10),
            _buildSteps(),
            const SizedBox(height: 20),
            _buildSectionTitle('📝 Notes (optionnel)'),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ressenti stress...',
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
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

  Widget _buildSteps() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 5,247 pas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('Objectif: 10,000'),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: 0.5247,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
