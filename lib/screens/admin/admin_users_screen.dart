import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilterChip(label: const Text('Tous'), onSelected: (selected) {}),
          FilterChip(label: const Text('Patients'), onSelected: (selected) {}),
          FilterChip(
              label: const Text('Cardiologues'), onSelected: (selected) {}),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    // Données factices
    final users = [
      {'name': 'Alice Martin', 'type': 'Patient', 'status': 'Actif'},
      {'name': 'Dr. Bernard', 'type': 'Cardiologue', 'status': 'Actif'},
      {'name': 'Charlie Brown', 'type': 'Patient', 'status': 'Inactif'},
    ];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user['name']![0]),
            ),
            title: Text(user['name']!),
            subtitle: Text(user['type']!),
            trailing: Text(
              user['status']!,
              style: TextStyle(
                color: user['status'] == 'Actif' ? Colors.green : Colors.red,
              ),
            ),
            onTap: () {
              // Naviguer vers les détails de l'utilisateur
            },
          ),
        );
      },
    );
  }
}
