import 'package:flutter/material.dart';

class TeleconsultationScreen extends StatefulWidget {
  const TeleconsultationScreen({super.key});

  @override
  State<TeleconsultationScreen> createState() => _TeleconsultationScreenState();
}

class _TeleconsultationScreenState extends State<TeleconsultationScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          _buildRemoteVideoView(),
          _buildLocalVideoView(),
          _buildAppBar(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'Dr. Bernard', // Nom du médecin ou patient
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 48), // Pour l'alignement
        ],
      ),
    );
  }

  Widget _buildRemoteVideoView() {
    // Vue de la vidéo du correspondant
    return Center(
      child: Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.person, size: 100, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildLocalVideoView() {
    // Vue de la vidéo de l'utilisateur local
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: _isCameraOff
            ? const Icon(Icons.videocam_off, color: Colors.white54, size: 40)
            : const Icon(Icons.person, color: Colors.white54, size: 40),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),
          _buildEndCallButton(),
          _buildControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            onPressed: () {
              setState(() {
                _isCameraOff = !_isCameraOff;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white24,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEndCallButton() {
    return CircleAvatar(
      radius: 35,
      backgroundColor: Colors.red,
      child: IconButton(
        icon: const Icon(Icons.call_end, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
