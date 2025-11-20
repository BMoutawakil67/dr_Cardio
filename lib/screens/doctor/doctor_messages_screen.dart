import 'package:dr_cardio/models/conversation_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/conversation_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';
import 'package:intl/intl.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  final ConversationRepository _conversationRepository =
      ConversationRepository();
  final PatientRepository _patientRepository = PatientRepository();

  late Stream<List<Conversation>> _conversationsStream;
  final Map<String, Patient> _patientsCache = {};

  @override
  void initState() {
    super.initState();
    final doctorId = AuthService().currentUserId ?? 'doctor-001';
    _conversationsStream =
        _conversationRepository.watchConversationsByDoctor(doctorId);
  }

  Future<Patient?> _getPatient(String patientId) async {
    if (_patientsCache.containsKey(patientId)) {
      return _patientsCache[patientId];
    }

    final patient = await _patientRepository.getPatient(patientId);
    if (patient != null) {
      _patientsCache[patientId] = patient;
    }
    return patient;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Messagerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final conversations = snapshot.data ?? [];

          // Filtrer les conversations système
          final userConversations =
              conversations.where((c) => !c.isSystem).toList();

          if (userConversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: userConversations.length,
            itemBuilder: (context, index) {
              final conversation = userConversations[index];
              return FutureBuilder<Patient?>(
                future: _getPatient(conversation.patientId),
                builder: (context, patientSnapshot) {
                  if (!patientSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final patient = patientSnapshot.data!;
                  return _buildConversationCard(context, conversation, patient);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun message',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Les conversations avec vos patients apparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(
      BuildContext context, Conversation conversation, Patient patient) {
    final isUnread = conversation.unreadCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isUnread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: patient.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        patient.profileImageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 32, color: AppTheme.primaryBlue);
                        },
                      ),
                    )
                  : const Icon(Icons.person,
                      size: 32, color: AppTheme.primaryBlue),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          '${patient.firstName} ${patient.lastName}',
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            conversation.lastMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnread ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: isUnread ? AppTheme.primaryBlue : Colors.grey.shade500,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isUnread) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.fiber_manual_record,
                size: 12,
                color: AppTheme.primaryBlue,
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.doctorChat,
            arguments: {
              'name': '${patient.firstName} ${patient.lastName}',
              'avatar': Icons.person,
              'patientId': patient.id,
              'conversationId': conversation.id,
            },
          );
        },
      ),
    );
  }
}
