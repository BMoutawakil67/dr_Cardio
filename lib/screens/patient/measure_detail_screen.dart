import 'package:flutter/material.dart';

class MeasureDetailScreen extends StatefulWidget {
  const MeasureDetailScreen({super.key});

  @override
  State<MeasureDetailScreen> createState() => _MeasureDetailScreenState();
}

class _MeasureDetailScreenState extends State<MeasureDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              '27 Octobre 2025, 18:30',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            _buildMeasurementCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('📋 Contexte'),
            const SizedBox(height: 10),
            _buildContextInfo(),
            const SizedBox(height: 20),
            _buildSectionTitle('📊 Comparaison'),
            const SizedBox(height: 10),
            _buildComparisonInfo(),
            const SizedBox(height: 20),
            _buildSectionTitle('🤖 Analyse IA'),
            const SizedBox(height: 10),
            _buildAiAnalysis(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('PARTAGER AVEC DR.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMeasurementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('14 / 9',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Systolique  Diastolique'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('💓 72 bpm', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('🟢 Normal',
                style: TextStyle(fontSize: 18, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildContextInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💊 Médicaments:'),
        Text('• Losartan 50mg (pris)'),
        SizedBox(height: 10),
        Text('⚖️ Poids: 75 kg'),
        SizedBox(height: 10),
        Text('🏃 Activité: Marche légère'),
        Text('🚶 5,247 pas'),
        SizedBox(height: 10),
        Text('📝 Notes:'),
        Text('Journée stressante au travail, léger mal de tête'),
      ],
    );
  }

  Widget _buildComparisonInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• Vs moyenne: -0.5/-0.5'),
        Text('• Vs hier: +1/+1'),
      ],
    );
  }

  Widget _buildAiAnalysis() {
    return const Text(
        'Votre tension est stable. Continuez vos médicaments et l\'activité physique.');
  }
}
