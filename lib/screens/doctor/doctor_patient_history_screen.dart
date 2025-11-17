import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class DoctorPatientHistoryScreen extends StatefulWidget {
  const DoctorPatientHistoryScreen({super.key});

  @override
  State<DoctorPatientHistoryScreen> createState() =>
      _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState
    extends State<DoctorPatientHistoryScreen> {
  String _selectedPeriod = '30j';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique complet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChart(),
                  _buildMeasureList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '7j', label: Text('7j')),
              ButtonSegment(value: '30j', label: Text('30j')),
              ButtonSegment(value: '90j', label: Text('90j')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Graphique de l\'historique'),
      ),
    );
  }

  Widget _buildMeasureList() {
    final measures = List.generate(
        15,
        (index) => {
              'date': 'Aujourd\'hui',
              'time': '${18 - index}:00',
              'systole': 120 + index,
              'diastole': 80 + (index % 5),
              'pulse': 70 + index,
            });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measures.length,
      itemBuilder: (context, index) {
        final measure = measures[index];
        return ListTile(
          leading:
              const Icon(Icons.favorite_border, color: AppTheme.primaryBlue),
          title: Text('${measure['systole']}/${measure['diastole']} mmHg'),
          subtitle: Text('Pouls: ${measure['pulse']} bpm'),
          trailing: Text('${measure['date']} à ${measure['time']}'),
        );
      },
    );
  }
}
