import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineModeScreen extends StatefulWidget {
  final int pendingDataCount;

  const OfflineModeScreen({
    super.key,
    this.pendingDataCount = 0,
  });

  @override
  State<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      // Connection restored
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate connection restored
      }
    } else {
      // Still offline
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toujours hors ligne'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocteurCardio'),
        actions: [
          Icon(
            Icons.signal_wifi_off,
            color: AppTheme.errorRed,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off,
                  size: 80,
                  color: AppTheme.warningOrange,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'MODE HORS LIGNE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Vous n\'êtes pas connecté à Internet',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Available Features Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fonctionnalités disponibles:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.check_circle,
                        text: 'Enregistrer tension',
                        isAvailable: true,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: Icons.check_circle,
                        text: 'Consulter historique',
                        isAvailable: true,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: Icons.check_circle,
                        text: 'Voir graphiques',
                        isAvailable: true,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.cancel,
                        text: 'Messages',
                        isAvailable: false,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: Icons.cancel,
                        text: 'Téléconsultation',
                        isAvailable: false,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: Icons.cancel,
                        text: 'Synchronisation',
                        isAvailable: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pending Data
              if (widget.pendingDataCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.save,
                        color: AppTheme.primaryBlue,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Données en attente:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.pendingDataCount} mesure(s) à synchroniser',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Info Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Les données seront automatiquement synchronisées dès la connexion rétablie',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkConnection,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isChecking ? 'Vérification...' : 'Réessayer connexion'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continuer hors ligne'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool isAvailable,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isAvailable ? AppTheme.successGreen : AppTheme.greyMedium,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isAvailable ? AppTheme.textColor : AppTheme.greyMedium,
          ),
        ),
      ],
    );
  }
}
