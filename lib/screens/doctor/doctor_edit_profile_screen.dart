import 'package:dr_cardio/models/doctor_model.dart';
import 'package:flutter/material.dart';

class DoctorEditProfileScreen extends StatefulWidget {
  const DoctorEditProfileScreen({super.key});

  @override
  State<DoctorEditProfileScreen> createState() =>
      _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState extends State<DoctorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _orderNumberController;
  late TextEditingController _specialtyController;
  late TextEditingController _officeController;

  late Doctor _doctor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _doctor = ModalRoute.of(context)!.settings.arguments as Doctor;
    _nameController = TextEditingController(text: _doctor.name);
    _emailController = TextEditingController(text: _doctor.email);
    _phoneController = TextEditingController(text: _doctor.phone);
    _orderNumberController = TextEditingController(text: _doctor.orderNumber);
    _specialtyController = TextEditingController(text: _doctor.specialty);
    _officeController = TextEditingController(text: _doctor.office);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orderNumberController.dispose();
    _specialtyController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _doctor.name = _nameController.text;
      _doctor.email = _emailController.text;
      _doctor.phone = _phoneController.text;
      _doctor.orderNumber = _orderNumberController.text;
      _doctor.specialty = _specialtyController.text;
      _doctor.office = _officeController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré avec succès !')),
      );
      Navigator.pop(context, _doctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderNumberController,
                decoration: const InputDecoration(labelText: 'Numéro d\'ordre'),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Spécialité'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _officeController,
                decoration: const InputDecoration(labelText: 'Cabinet'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
