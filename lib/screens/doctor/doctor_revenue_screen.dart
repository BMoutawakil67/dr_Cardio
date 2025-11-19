import 'package:flutter/material.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';

class DoctorRevenueScreen extends StatelessWidget {
  const DoctorRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenus & Statistiques'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRevenueSummary(),
          const SizedBox(height: 24),
          _buildRecentTransactions(),
        ],
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 3),
    );
  }

  Widget _buildRevenueSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé des revenus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRevenueItem('Aujourd\'hui', '150 €'),
                _buildRevenueItem('7 derniers jours', '850 €'),
                _buildRevenueItem('30 derniers jours', '3 250 €'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(String title, String amount) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions récentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildTransactionItem(
                  'Téléconsultation', 'Jean Dupont', '+ 50 €', '10/07/2024'),
              const Divider(height: 1),
              _buildTransactionItem(
                  'Analyse de rapport', 'Marie Martin', '+ 30 €', '09/07/2024'),
              const Divider(height: 1),
              _buildTransactionItem(
                  'Téléconsultation', 'Paul Bernard', '+ 50 €', '09/07/2024'),
              const Divider(height: 1),
              _buildTransactionItem(
                  'Abonnement patient', 'Laura Petit', '+ 20 €', '08/07/2024'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
      String type, String patient, String amount, String date) {
    return ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text(type),
      subtitle: Text(patient),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
