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
  String _selectedFilter = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock data - Remplacer par une vraie source de données
  final List<Map<String, dynamic>> _allPatients = [
    {
      'name': 'Jean Dupont',
      'age': 45,
      'lastMeasure': '18/11 (15min)',
      'subscription': 'Standard',
      'statusColor': AppTheme.secondaryRed,
      'statusIcon': '🔴',
      'status': 'critical',
    },
    {
      'name': 'Marie Koffi',
      'age': 52,
      'lastMeasure': '16/10 (2h)',
      'subscription': 'Premium',
      'statusColor': AppTheme.warningOrange,
      'statusIcon': '🟠',
      'status': 'high',
    },
    {
      'name': 'Paul Mensah',
      'age': 38,
      'lastMeasure': '13/8 (1j)',
      'subscription': 'Standard',
      'statusColor': AppTheme.successGreen,
      'statusIcon': '🟢',
      'status': 'normal',
    },
    {
      'name': 'Fatou Diallo',
      'age': 60,
      'lastMeasure': '14/9 (1j)',
      'subscription': 'Famille',
      'statusColor': AppTheme.successGreen,
      'statusIcon': '🟢',
      'status': 'normal',
    },
    {
      'name': 'Amadou Traoré',
      'age': 55,
      'lastMeasure': '15/9 (2j)',
      'subscription': 'Premium',
      'statusColor': AppTheme.successGreen,
      'statusIcon': '🟢',
      'status': 'normal',
    },
    {
      'name': 'Aissata Camara',
      'age': 48,
      'lastMeasure': '17/10 (3j)',
      'subscription': 'Standard',
      'statusColor': AppTheme.warningOrange,
      'statusIcon': '🟠',
      'status': 'high',
    },
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    List<Map<String, dynamic>> patients = _allPatients.where((patient) {
      // 1. Filtre par la barre de recherche
      final nameMatches = patient['name'].toLowerCase().contains(_searchQuery);
      if (!nameMatches) return false;

      // 2. Filtre par les statuts (Alertes, Stables)
      final isStatusFilter =
          _selectedFilter == '🔴 Alertes' || _selectedFilter == '🟢 Stables';
      if (!isStatusFilter) {
        return true; // Si le filtre n'est pas un statut, on inclut tout le monde (pour A-Z, Récents, Tous)
      }

      if (_selectedFilter == '🔴 Alertes') {
        return patient['status'] == 'critical' || patient['status'] == 'high';
      }

      if (_selectedFilter == '🟢 Stables') {
        return patient['status'] == 'normal';
      }

      return true;
    }).toList();

    // 3. Tri de la liste résultante
    if (_selectedFilter == '🔤 A-Z') {
      patients.sort(
          (a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
    }

    // TODO: Implémenter le tri pour '📅 Récents'

    return patients;
  }

  @override
  void initState() {
    super.initState();
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

          // Compteur patients
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.greyLight,
            child: Text(
              '${_filteredPatients.length} patients correspondants',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Liste des patients
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _PatientCard(
                    name: patient['name'],
                    age: patient['age'],
                    lastMeasure: patient['lastMeasure'],
                    subscription: patient['subscription'],
                    statusColor: patient['statusColor'],
                    statusIcon: patient['statusIcon'],
                    onTap: () => _openPatientFile(patient['name']),
                    status: patient['status'],
                  ),
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

  void _openPatientFile(String patientName) {
    Navigator.pushNamed(
      context,
      AppRoutes.patientFile,
      arguments: {'patientName': patientName},
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String name;
  final int age;
  final String lastMeasure;
  final String subscription;
  final Color statusColor;
  final String statusIcon;
  final VoidCallback onTap;
  final String status;

  const _PatientCard({
    required this.name,
    required this.age,
    required this.lastMeasure,
    required this.subscription,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
                      name,
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
                    color: statusColor.withValues(alpha: 0.1),
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
            _buildInfoRow('Dernière:', lastMeasure),
            const SizedBox(height: 4),
            _buildInfoRow('Abonnement:', subscription),
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
