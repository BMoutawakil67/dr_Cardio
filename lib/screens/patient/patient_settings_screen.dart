import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  // États des switches
  bool _notificationsEnabled = true;
  bool _measureRemindersEnabled = true;
  bool _medicationRemindersEnabled = true;
  bool _pressureAlertsEnabled = true;
  bool _doctorMessagesEnabled = true;
  bool _healthNewsEnabled = false;
  bool _appointmentRemindersEnabled = true;

  // Horaires de rappel de mesure
  final List<MeasureReminder> _measureReminders = [
    MeasureReminder(time: '08:00', label: 'Matin', enabled: true),
    MeasureReminder(time: '18:00', label: 'Soir', enabled: true),
  ];

  // Seuils d'alerte
  int _highSystolic = 16;
  int _highDiastolic = 10;
  int _lowSystolic = 10;
  int _lowDiastolic = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
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
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Rappels de mesure
          _buildSection(
            title: 'Rappels de mesure',
            child: Column(
              children: [
                SwitchListTile(
                  value: _measureRemindersEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _measureRemindersEnabled = value;
                          });
                        }
                      : null,
                  title:
                      Text(_measureRemindersEnabled ? 'Activé' : 'Désactivé'),
                  activeTrackColor: AppTheme.primaryBlue,
                ),
                if (_measureRemindersEnabled && _notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⏰ Horaires:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._measureReminders.map((reminder) {
                          return CheckboxListTile(
                            value: reminder.enabled,
                            onChanged: (value) {
                              setState(() {
                                reminder.enabled = value ?? false;
                              });
                            },
                            title: Text('${reminder.label}: ${reminder.time}'),
                            activeColor: AppTheme.primaryBlue,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _addMeasureReminder,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un horaire'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Rappels médicaments
          _buildSection(
            title: 'Rappels médicaments',
            child: Column(
              children: [
                SwitchListTile(
                  value: _medicationRemindersEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _medicationRemindersEnabled = value;
                          });
                        }
                      : null,
                  title: Text(
                      _medicationRemindersEnabled ? 'Activé' : 'Désactivé'),
                  activeTrackColor: AppTheme.primaryBlue,
                ),
                if (_medicationRemindersEnabled && _notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('💊', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text('Losartan: 08:00, 20:00'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _manageMedications,
                          child: const Text('Gérer mes médicaments'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Alertes tension
          _buildSection(
            title: 'Alertes tension',
            child: Column(
              children: [
                SwitchListTile(
                  value: _pressureAlertsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _pressureAlertsEnabled = value;
                          });
                        }
                      : null,
                  title: Text(_pressureAlertsEnabled ? 'Activé' : 'Désactivé'),
                  activeTrackColor: AppTheme.primaryBlue,
                ),
                if (_pressureAlertsEnabled && _notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seuils d\'alerte:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('• Haute:'),
                            Text(
                              '> $_highSystolic/$_highDiastolic',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editThreshold('high'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('• Basse:'),
                            Text(
                              '< $_lowSystolic/$_lowDiastolic',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editThreshold('low'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Messages du médecin
          _buildSection(
            title: 'Messages du médecin',
            child: SwitchListTile(
              value: _doctorMessagesEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _doctorMessagesEnabled = value;
                      });
                    }
                  : null,
              title: Text(_doctorMessagesEnabled ? 'Activé' : 'Désactivé'),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Actualités santé
          _buildSection(
            title: 'Actualités santé',
            child: SwitchListTile(
              value: _healthNewsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _healthNewsEnabled = value;
                      });
                    }
                  : null,
              title: Text(_healthNewsEnabled ? 'Activé' : 'Désactivé'),
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Rappels de rendez-vous
          _buildSection(
            title: 'Rappels de rendez-vous',
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
                  activeTrackColor: AppTheme.primaryBlue,
                ),
                if (_appointmentRemindersEnabled && _notificationsEnabled) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Text('Avant: '),
                        Text(
                          '24h, 1h',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
        ],
      ),
    );
  }

  Widget _buildSection({
    String? icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
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
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }

  void _addMeasureReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _measureReminders.add(
          MeasureReminder(
            time:
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            label: 'Personnalisé',
            enabled: true,
          ),
        );
      });
    }
  }

  void _manageMedications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gérer mes médicaments'),
        content: const Text(
          'Cette fonctionnalité vous permettra de configurer vos rappels de médicaments.\n\n'
          'Vous pourrez:\n'
          '• Ajouter/supprimer des médicaments\n'
          '• Configurer les horaires\n'
          '• Définir la fréquence',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editThreshold(String type) async {
    final isHigh = type == 'high';
    final currentSystolic = isHigh ? _highSystolic : _lowSystolic;
    final currentDiastolic = isHigh ? _highDiastolic : _lowDiastolic;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        int newSystolic = currentSystolic;
        int newDiastolic = currentDiastolic;

        return AlertDialog(
          title: Text('Seuil ${isHigh ? 'haute' : 'basse'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Systolique',
                  suffixText: 'mmHg',
                ),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: currentSystolic.toString()),
                onChanged: (value) {
                  newSystolic = int.tryParse(value) ?? currentSystolic;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Diastolique',
                  suffixText: 'mmHg',
                ),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: currentDiastolic.toString()),
                onChanged: (value) {
                  newDiastolic = int.tryParse(value) ?? currentDiastolic;
                },
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
                Navigator.pop(context, {
                  'systolic': newSystolic,
                  'diastolic': newDiastolic,
                });
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        if (isHigh) {
          _highSystolic = result['systolic'] ?? _highSystolic;
          _highDiastolic = result['diastolic'] ?? _highDiastolic;
        } else {
          _lowSystolic = result['systolic'] ?? _lowSystolic;
          _lowDiastolic = result['diastolic'] ?? _lowDiastolic;
        }
      });
    }
  }

  void _saveSettings() {
    if (!mounted) return;
    // TODO: Enregistrer les paramètres dans le stockage local ou API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres enregistrés avec succès'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class MeasureReminder {
  String time;
  String label;
  bool enabled;

  MeasureReminder({
    required this.time,
    required this.label,
    required this.enabled,
  });
}
