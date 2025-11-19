import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class PatientMeasureDetailScreen extends StatelessWidget {
  const PatientMeasureDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ces données viendraient normalement des arguments de navigation
    final measureData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMeasure(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date et heure
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Text(
                measureData['date'] ?? '27 Octobre 2025, 18:30',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Carte principale des mesures
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Valeurs tension
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPressureValue(
                        measureData['systolic']?.toString() ?? '14',
                        'Systolique',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '/',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.greyMedium,
                          ),
                        ),
                      ),
                      _buildPressureValue(
                        measureData['diastolic']?.toString() ?? '9',
                        'Diastolique',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pouls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '💓',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${measureData['pulse'] ?? '72'} bpm',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Statut
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          measureData['status'] ?? 'Normal',
                          style: const TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Contexte
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('📋', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Contexte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Médicaments
                  _buildContextItem(
                    icon: '💊',
                    title: 'Médicaments:',
                    content: '• Losartan 50mg (pris)',
                  ),

                  const SizedBox(height: 12),

                  // Poids
                  _buildContextItem(
                    icon: '⚖️',
                    title: 'Poids:',
                    content: '75 kg',
                  ),

                  const SizedBox(height: 12),

                  // Activité
                  _buildContextItem(
                    icon: '🏃',
                    title: 'Activité:',
                    content: 'Marche légère\n🚶 5,247 pas',
                  ),

                  const SizedBox(height: 12),

                  // Notes
                  _buildContextItem(
                    icon: '📝',
                    title: 'Notes:',
                    content: 'Journée stressante au travail, léger mal de tête',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Comparaison
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('📊', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Comparaison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonRow('Vs moyenne:', '-0.5/-0.5', Colors.green),
                  const SizedBox(height: 8),
                  _buildComparisonRow('Vs hier:', '+1/+1', Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Analyse IA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Analyse IA:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    measureData['aiAnalysis'] ??
                        'Votre tension est stable. Continuez vos médicaments et l\'activité physique.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton partager avec docteur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _shareWithDoctor(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PARTAGER AVEC DR.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureValue(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.greyMedium.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildContextItem({
    required String icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  color: AppTheme.greyMedium.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.greyMedium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _editMeasure(BuildContext context) {
    final measureData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final systolicController =
        TextEditingController(text: measureData['systolic']?.toString() ?? '');
    final diastolicController =
        TextEditingController(text: measureData['diastolic']?.toString() ?? '');
    final pulseController =
        TextEditingController(text: measureData['pulse']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la mesure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Systolique'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diastolique'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: pulseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pouls'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Sauvegarder (mock)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mesure modifiée')),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la mesure'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette mesure? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mesure supprimée'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.secondaryRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _shareWithDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('📨', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Partager avec votre médecin'),
          ],
        ),
        content: const Text(
          'Cette mesure sera partagée avec Dr. Koné. Il pourra la consulter dans votre dossier médical et vous contacter si nécessaire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mesure partagée avec succès'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }
}
