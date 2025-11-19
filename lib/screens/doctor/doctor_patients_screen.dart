import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  late Future<List<Patient>> _patientsFuture;

  String _selectedFilter = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _patientsFuture = _patientRepository.getAllPatients();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> _filterAndSortPatients(List<Patient> allPatients) {
    List<Patient> patients = allPatients.where((patient) {
      final fullName = '${patient.firstName} ${patient.lastName}'.toLowerCase();
      final nameMatches = fullName.contains(_searchQuery);
      if (!nameMatches) return false;

      // NOTE: La logique de statut n'est pas encore implémentée dans le modèle Patient.
      // Nous allons donc la laisser en commentaire pour l'instant.
      // final isStatusFilter =
      //     _selectedFilter == '🔴 Alertes' || _selectedFilter == '🟢 Stables';
      // if (!isStatusFilter) {
      //   return true;
      // }
      // if (_selectedFilter == '🔴 Alertes') {
      //   return patient.status == 'critical' || patient.status == 'high';
      // }
      // if (_selectedFilter == '🟢 Stables') {
      //   return patient.status == 'normal';
      // }

      return true;
    }).toList();

    if (_selectedFilter == '🔤 A-Z') {
      patients.sort((patientA, patientB) {
        final nameA = '${patientA.firstName} ${patientA.lastName}'.toLowerCase();
        final nameB = '${patientB.firstName} ${patientB.lastName}'.toLowerCase();
        return nameA.compareTo(nameB);
      });
    }

    return patients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _addNewPatient(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Section filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtres:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tous', null),
                    _buildFilterChip('🔴 Alertes', AppTheme.secondaryRed),
                    _buildFilterChip('🟢 Stables', AppTheme.successGreen),
                    _buildFilterChip('📅 Récents', null),
                    _buildFilterChip('🔤 A-Z', null),
                  ],
                ),
              ],
            ),
          ),

          // Compteur et Liste des patients
          Expanded(
            child: FutureBuilder<List<Patient>>(
              future: _patientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun patient trouvé'));
                }

                final allPatients = snapshot.data!;
                final filteredPatients = _filterAndSortPatients(allPatients);

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: AppTheme.greyLight,
                      child: Text(
                        '${filteredPatients.length} patients correspondants',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _PatientCard(
                              patient: patient,
                              onTap: () => _openPatientFile(patient.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? color) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'Tous';
        });
      },
      selectedColor: color?.withAlpha(50) ?? AppTheme.primaryBlue.withAlpha(50),
      checkmarkColor: color ?? AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color:
            isSelected ? (color ?? AppTheme.primaryBlue) : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? (color ?? AppTheme.primaryBlue)
              : AppTheme.greyMedium,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un patient'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nom du patient...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _addNewPatient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Partagez ce code avec votre patient'),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.greyMedium),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code, size: 150), // Placeholder
            ),
            const SizedBox(height: 16),
            const Text(
              'Dr. Mamadou KOUASSI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Cardiologue',
              style: TextStyle(color: AppTheme.greyMedium),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Share.share(
                  'Rejoignez-moi sur DocteurCardio: https://drcardio.ci/add/kouassi');
            },
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _openPatientFile(String patientId) {
    Navigator.pushNamed(
      context,
      AppRoutes.patientFile,
      arguments: {'patientId': patientId},
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().year - patient.birthDate.year;
    // TODO: Implement status logic based on medical notes
    const status = 'normal';
    final statusColor = status == 'critical'
        ? AppTheme.secondaryRed
        : status == 'high'
            ? AppTheme.warningOrange
            : AppTheme.successGreen;
    final statusIcon = status == 'critical'
        ? '🔴'
        : status == 'high'
            ? '🟠'
            : '🟢';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '👤',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${patient.firstName} ${patient.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    statusIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Âge:', '$age ans'),
            const SizedBox(height: 4),
            _buildInfoRow('Dernière:', 'N/A'), // TODO: Get from medical notes
            const SizedBox(height: 4),
            _buildInfoRow(
                'Abonnement:', 'Standard'), // TODO: Add to patient model
            const SizedBox(height: 4),
            _buildInfoRow('Statut:', status),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OUVRIR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.greyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}