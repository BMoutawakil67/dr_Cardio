import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class DoctorNotificationsSettingsScreen extends StatefulWidget {
  const DoctorNotificationsSettingsScreen({super.key});

  @override
  State<DoctorNotificationsSettingsScreen> createState() =>
      _DoctorNotificationsSettingsScreenState();
}

class _DoctorNotificationsSettingsScreenState
    extends State<DoctorNotificationsSettingsScreen> {
  // États des switches
  bool _notificationsEnabled = true;
  bool _newPatientsEnabled = true;
  bool _urgentMessagesEnabled = true;
  bool _criticalAlertsEnabled = true;
  bool _appointmentRemindersEnabled = true;
  bool _patientMeasuresEnabled = true;
  bool _systemNotificationsEnabled = false;
  bool _marketingEnabled = false;

  // Horaires de disponibilité pour les notifications
  final List<AvailabilitySlot> _availabilitySlots = [
    AvailabilitySlot(
        day: 'Lundi - Vendredi', start: '08:00', end: '18:00', enabled: true),
    AvailabilitySlot(
        day: 'Samedi', start: '08:00', end: '12:00', enabled: true),
    AvailabilitySlot(
        day: 'Dimanche', start: 'Fermé', end: '', enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Activer notifications
          _buildSection(
            icon: '🔔',
            title: 'Activer notifications',
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              title: Text(_notificationsEnabled ? 'Activé' : 'Désactivé'),
              subtitle: Text(
                _notificationsEnabled
                    ? 'Vous recevez toutes les notifications'
                    : 'Aucune notification ne sera envoyée',
                style: const TextStyle(fontSize: 12),
              ),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Nouveaux patients
          _buildSection(
            title: '👥 Nouveaux patients',
            child: SwitchListTile(
              value: _newPatientsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _newPatientsEnabled = value;
                      });
                    }
                  : null,
              title: Text(_newPatientsEnabled ? 'Activé' : 'Désactivé'),
              subtitle: const Text(
                'Notification lorsqu\'un nouveau patient s\'inscrit',
                style: TextStyle(fontSize: 12),
              ),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Messages urgents
          _buildSection(
            title: '🚨 Messages urgents',
            child: Column(
              children: [
                SwitchListTile(
                  value: _urgentMessagesEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _urgentMessagesEnabled = value;
                          });
                        }
                      : null,
                  title: Text(_urgentMessagesEnabled ? 'Activé' : 'Désactivé'),
                  subtitle: const Text(
                    'Messages marqués comme urgents par vos patients',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeTrackColor: AppTheme.secondaryRed,
                ),
                if (_urgentMessagesEnabled && _notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.secondaryRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.priority_high,
                              color: AppTheme.secondaryRed, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ces notifications contournent les horaires de disponibilité',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Alertes critiques
          _buildSection(
            title: '⚠️ Alertes critiques',
            child: Column(
              children: [
                SwitchListTile(
                  value: _criticalAlertsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _criticalAlertsEnabled = value;
                          });
                        }
                      : null,
                  title: Text(_criticalAlertsEnabled ? 'Activé' : 'Désactivé'),
                  subtitle: const Text(
                    'Mesures hors normes détectées chez vos patients',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeTrackColor: AppTheme.warningOrange,
                ),
                if (_criticalAlertsEnabled && _notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Types d\'alertes:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAlertType(
                            '• Hypertension sévère (≥18/11)', Colors.red),
                        _buildAlertType(
                            '• Hypotension (≤9/6)', Colors.orange),
                        _buildAlertType('• Rythme cardiaque anormal',
                            AppTheme.warningOrange),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Mesures patients
          _buildSection(
            title: '📊 Mesures des patients',
            child: SwitchListTile(
              value: _patientMeasuresEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _patientMeasuresEnabled = value;
                      });
                    }
                  : null,
              title: Text(_patientMeasuresEnabled ? 'Activé' : 'Désactivé'),
              subtitle: const Text(
                'Nouvelles mesures enregistrées par vos patients',
                style: TextStyle(fontSize: 12),
              ),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Rappels de rendez-vous
          _buildSection(
            title: '📅 Rappels de rendez-vous',
            child: Column(
              children: [
                SwitchListTile(
                  value: _appointmentRemindersEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _appointmentRemindersEnabled = value;
                          });
                        }
                      : null,
                  title: Text(
                      _appointmentRemindersEnabled ? 'Activé' : 'Désactivé'),
                  subtitle: const Text(
                    'Consultations et téléconsultations à venir',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeTrackColor: AppTheme.primaryBlue,
                ),
                if (_appointmentRemindersEnabled && _notificationsEnabled) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Text('Rappel: '),
                        Text(
                          '30 min avant',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Horaires de disponibilité
          _buildSection(
            title: '🕐 Horaires de disponibilité',
            subtitle: 'Ne pas déranger en dehors de ces horaires',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: _availabilitySlots.map((slot) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                slot.day,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                slot.start == 'Fermé'
                                    ? 'Fermé'
                                    : '${slot.start} - ${slot.end}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: slot.enabled
                                      ? AppTheme.successGreen
                                      : AppTheme.secondaryRed,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: slot.enabled,
                              onChanged: slot.start != 'Fermé'
                                  ? (value) {
                                      setState(() {
                                        slot.enabled = value ?? false;
                                      });
                                    }
                                  : null,
                              activeColor: AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.primaryBlue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Les messages urgents et alertes critiques ignorent ces horaires',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Notifications système
          _buildSection(
            title: '⚙️ Notifications système',
            child: SwitchListTile(
              value: _systemNotificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _systemNotificationsEnabled = value;
                      });
                    }
                  : null,
              title:
                  Text(_systemNotificationsEnabled ? 'Activé' : 'Désactivé'),
              subtitle: const Text(
                'Mises à jour de l\'application et informations système',
                style: TextStyle(fontSize: 12),
              ),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Marketing
          _buildSection(
            title: '📰 Actualités médicales',
            child: SwitchListTile(
              value: _marketingEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _marketingEnabled = value;
                      });
                    }
                  : null,
              title: Text(_marketingEnabled ? 'Activé' : 'Désactivé'),
              subtitle: const Text(
                'Articles, études et nouveautés en cardiologie',
                style: TextStyle(fontSize: 12),
              ),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const SizedBox(height: 24),

          // Statistiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Statistiques',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('Cette semaine', '47 notifications'),
                    const SizedBox(height: 8),
                    _buildStatRow('Messages urgents', '3 reçus'),
                    const SizedBox(height: 8),
                    _buildStatRow('Alertes critiques', '1 reçue'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton Enregistrer
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'ENREGISTRER LES PARAMÈTRES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    String? icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null)
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildAlertType(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    if (!mounted) return;
    // TODO: Enregistrer les paramètres dans le stockage local ou API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Paramètres de notifications enregistrés'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Aide - Notifications'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Types de notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '🚨 Messages urgents et ⚠️ Alertes critiques ignorent toujours les horaires de disponibilité pour garantir la sécurité de vos patients.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '📊 Mesures patients: Recevez une notification chaque fois qu\'un patient enregistre une nouvelle mesure de tension.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '👥 Nouveaux patients: Soyez informé lorsqu\'un nouveau patient s\'inscrit et vous choisit comme cardiologue.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

class AvailabilitySlot {
  String day;
  String start;
  String end;
  bool enabled;

  AvailabilitySlot({
    required this.day,
    required this.start,
    required this.end,
    required this.enabled,
  });
}
