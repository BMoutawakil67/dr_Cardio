import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;

  const ForgotPasswordScreen({super.key, required this.userType});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _selectedMethod = 'email';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOTP() async {
    String destination;
    if (_selectedMethod == 'email') {
      if (_emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer votre email')),
        );
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email invalide')),
        );
        return;
      }
      destination = _emailController.text;
    } else {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer votre numéro')),
        );
        return;
      }
      // Basic phone validation for the example
      if (_phoneController.text.length < 9) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro invalide')),
        );
        return;
      }
      destination = _phoneController.text;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (widget.userType == 'patient') {
      Navigator.pushNamed(
        context,
        AppRoutes.patientVerifyOtp,
        arguments: {
          'method': _selectedMethod,
          'destination': destination,
        },
      );
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.doctorVerifyOtp,
        arguments: {
          'method': _selectedMethod,
          'destination': destination,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Choisissez comment recevoir votre code'),
            const SizedBox(height: 24),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'email',
                    label: Text('Email'),
                    icon: Icon(Icons.email)),
                ButtonSegment(
                    value: 'phone',
                    label: Text('Téléphone'),
                    icon: Icon(Icons.phone)),
              ],
              selected: {_selectedMethod},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedMethod = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            if (_selectedMethod == 'email')
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'votre.email@example.com',
                ),
              )
            else
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+225 XX XX XX XX XX',
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOTP,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Envoyer le code'),
            ),
          ],
        ),
      ),
    );
  }
}
