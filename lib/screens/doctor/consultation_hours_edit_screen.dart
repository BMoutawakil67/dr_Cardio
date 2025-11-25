import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/models/consultation_hours_model.dart';
import 'package:dr_cardio/repositories/consultation_hours_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';

class ConsultationHoursEditScreen extends StatefulWidget {
  const ConsultationHoursEditScreen({super.key});

  @override
  State<ConsultationHoursEditScreen> createState() =>
      _ConsultationHoursEditScreenState();
}

class _ConsultationHoursEditScreenState
    extends State<ConsultationHoursEditScreen> {
  final ConsultationHoursRepository _repository =
      ConsultationHoursRepository();
  ConsultationHours? _hours;
  bool _isLoading = true;

  final Map<String, String> _dayLabels = {
    'monday': 'Lundi',
    'tuesday': 'Mardi',
    'wednesday': 'Mercredi',
    'thursday': 'Jeudi',
    'friday': 'Vendredi',
    'saturday': 'Samedi',
    'sunday': 'Dimanche',
  };

  @override
  void initState() {
    super.initState();
    _loadHours();
  }

  Future<void> _loadHours() async {
    final doctorId = AuthService().currentUserId ?? '';
    final hours = await _repository.getConsultationHours(doctorId);

    if (mounted) {
      setState(() {
        _hours = hours;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHours() async {
    if (_hours == null) return;

    final updatedHours = _hours!.copyWith(updatedAt: DateTime.now());
    await _repository.updateConsultationHours(updatedHours);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Horaires de consultation mis à jour'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _selectTime(String day, bool isStart) async {
    if (_hours == null) return;

    final schedule = _hours!.schedule[day];
    if (schedule == null) return;

    final currentTime = isStart ? schedule.start : schedule.end;
    TimeOfDay initialTime;

    if (currentTime.isEmpty) {
      initialTime = const TimeOfDay(hour: 8, minute: 0);
    } else {
      final parts = currentTime.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppTheme.primaryBlue,
              dayPeriodTextColor: AppTheme.primaryBlue,
              dialHandColor: AppTheme.primaryBlue,
              dialBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      setState(() {
        final updatedSchedule = isStart
            ? schedule.copyWith(start: timeString)
            : schedule.copyWith(end: timeString);
        _hours = _hours!.copyWith(
          schedule: Map.from(_hours!.schedule)..[day] = updatedSchedule,
        );
      });
    }
  }

  void _toggleDay(String day, bool? value) {
    if (_hours == null || value == null) return;

    final schedule = _hours!.schedule[day];
    if (schedule == null) return;

    setState(() {
      final updatedSchedule = schedule.copyWith(enabled: value);
      _hours = _hours!.copyWith(
        schedule: Map.from(_hours!.schedule)..[day] = updatedSchedule,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horaires de consultation'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hours == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horaires de consultation'),
        ),
        body: const Center(
          child: Text('Erreur lors du chargement des horaires'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horaires de consultation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                      SizedBox(width: 12),
                      Text('Aide'),
                    ],
                  ),
                  content: const Text(
                    'Configurez vos horaires de consultation pour chaque jour de la semaine.\n\n'
                    'Activez ou désactivez chaque jour, puis définissez les heures de début et de fin.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Compris'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: AppTheme.primaryBlue,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Définissez vos heures de disponibilité',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._dayLabels.entries.map((entry) {
            final day = entry.key;
            final label = entry.value;
            final schedule = _hours!.schedule[day];

            if (schedule == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        Switch(
                          value: schedule.enabled,
                          onChanged: (value) => _toggleDay(day, value),
                          activeThumbColor: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                    if (schedule.enabled) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Début',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.greyMedium,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(day, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.greyMedium,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          schedule.start.isEmpty
                                              ? '--:--'
                                              : schedule.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.greyMedium,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(day, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.greyMedium,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          schedule.end.isEmpty
                                              ? '--:--'
                                              : schedule.end,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else
                      ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Fermé',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.errorRed,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveHours,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'ENREGISTRER LES HORAIRES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
