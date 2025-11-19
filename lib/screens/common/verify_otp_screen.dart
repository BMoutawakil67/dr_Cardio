import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String userType;
  const VerifyOtpScreen({super.key, required this.userType});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code OTP invalide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (widget.userType == 'patient') {
      Navigator.pushNamed(context, AppRoutes.patientResetPassword);
    } else {
      Navigator.pushNamed(context, AppRoutes.doctorResetPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final method = arguments['method'];
    final destination = arguments['destination'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérifier le code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.password, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            Text('Un code a été envoyé à $destination par $method.'),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Code OTP',
                hintText: '123456',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }
}
