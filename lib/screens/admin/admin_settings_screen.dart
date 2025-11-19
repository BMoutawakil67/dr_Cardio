import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de l\'application'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            'Gestion des fonctionnalités',
            [
              _buildSwitchTile('Activer les appels vidéo', true),
              _buildSwitchTile('Activer les appels vocaux', true),
              _buildSwitchTile('Abonnement premium pour les patients', true),
            ],
          ),
          const Divider(),
          _buildSettingsSection(
            'Paramètres financiers',
            [
              _buildTextFieldTile('Frais de service (%)', '10'),
              _buildTextFieldTile(
                  'Prix de l\'abonnement patient (€/mois)', '9.99'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (bool newValue) {
        // Mettre à jour le paramètre
      },
    );
  }

  Widget _buildTextFieldTile(String title, String initialValue) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 80,
        child: TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
