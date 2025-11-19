import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';

class MeasureDetailScreen extends StatefulWidget {
  const MeasureDetailScreen({super.key});

  @override
  State<MeasureDetailScreen> createState() => _MeasureDetailScreenState();
}

class _MeasureDetailScreenState extends State<MeasureDetailScreen> {
  Map<String, dynamic>? _measureData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _measureData = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_measureData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détail'),
        ),
        body: const Center(
          child: Text('Mesure non trouvée'),
        ),
      );
    }

    final date = _measureData!['date'] as String? ?? 'Date inconnue';
    final systolic = _measureData!['systolic'] as int? ?? 0;
    final diastolic = _measureData!['diastolic'] as int? ?? 0;
    final pulse = _measureData!['pulse'] as int? ?? 0;
    final status = _measureData!['status'] as String? ?? 'Inconnu';
    final contextInfo = _measureData!['context'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la mesure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partage en cours...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            FadeInSlideUp(
              delay: 0,
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Carte de mesure principale
            FadeInSlideUp(
              delay: 200,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Systolique/Diastolique
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$systolic',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                          ),
                          Text(
                            ' / ',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          Text(
                            '$diastolic',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Systolique / Diastolique (mmHg)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Fréquence cardiaque
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite, color: AppTheme.secondaryRed, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              '$pulse bpm',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Statut
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              color: _getStatusColor(status),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contexte
            if (contextInfo != null && contextInfo.isNotEmpty) ...[
              FadeInSlideUp(
                delay: 400,
                child: _buildSectionTitle('📋 Contexte'),
              ),
              const SizedBox(height: 12),
              FadeInSlideUp(
                delay: 600,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      contextInfo,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recommandations
            FadeInSlideUp(
              delay: 800,
              child: _buildSectionTitle('💡 Recommandations'),
            ),
            const SizedBox(height: 12),
            FadeInSlideUp(
              delay: 1000,
              child: Card(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecommendation(
                        _getRecommendations(systolic, diastolic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton partager
            FadeInSlideUp(
              delay: 1200,
              child: PressableButton(
                onPressed: () {
                  _shareWithDoctor();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _shareWithDoctor();
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('PARTAGER AVEC MON CARDIOLOGUE'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('normal')) {
      return AppTheme.successGreen;
    } else if (status.toLowerCase().contains('élevé') || status.toLowerCase().contains('eleve')) {
      return AppTheme.warningOrange;
    } else if (status.toLowerCase().contains('très') || status.toLowerCase().contains('danger')) {
      return AppTheme.secondaryRed;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(String status) {
    if (status.toLowerCase().contains('normal')) {
      return Icons.check_circle;
    } else if (status.toLowerCase().contains('élevé') || status.toLowerCase().contains('eleve')) {
      return Icons.warning;
    } else if (status.toLowerCase().contains('très') || status.toLowerCase().contains('danger')) {
      return Icons.error;
    }
    return Icons.info;
  }

  String _getRecommendations(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return 'Votre tension est normale. Continuez vos bonnes habitudes : alimentation équilibrée, activité physique régulière et gestion du stress.';
    } else if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return 'Tension légèrement élevée. Surveillez votre alimentation, réduisez le sel et faites de l\'exercice régulièrement.';
    } else if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) {
      return 'Hypertension de stade 1. Consultez votre cardiologue pour un suivi. Adoptez un mode de vie plus sain.';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'Hypertension de stade 2. Consultation médicale recommandée rapidement. Suivez rigoureusement votre traitement.';
    } else if (systolic >= 180 || diastolic >= 120) {
      return 'URGENCE : Tension critique. Contactez immédiatement votre médecin ou les urgences (185).';
    }
    return 'Continuez à surveiller régulièrement votre tension artérielle.';
  }

  void _shareWithDoctor() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Mesure partagée avec votre cardiologue'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la mesure'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette mesure ?'),
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
                SnackBar(
                  content: const Text('Mesure supprimée'),
                  backgroundColor: AppTheme.errorRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondaryRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
