import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/navigation/patient_bottom_navigation.dart';

class PatientMessagesScreen extends StatelessWidget {
  const PatientMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = [
      {
        'name': 'Dr. Kouassi Jean',
        'lastMessage': 'Votre tension est bonne\nContinuez ainsi...',
        'time': '18:45',
        'unread': true,
        'avatar': Icons.person,
      },
      {
        'name': 'DocteurCardio',
        'lastMessage': 'N\'oubliez pas votre\nmesure du soir',
        'time': '08:00',
        'unread': false,
        'avatar': Icons.notifications_active,
        'isSystem': true,
      },
      {
        'name': 'Dr. Kouassi Jean',
        'lastMessage': 'Merci pour votre\ndernière mesure',
        'time': 'Hier',
        'unread': false,
        'avatar': Icons.person,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: conversations.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _buildConversationCard(context, conv);
              },
            ),
      bottomNavigationBar: const PatientBottomNavigation(currentIndex: 2),
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
              'Vos conversations avec votre\ncardiologue apparaîtront ici',
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

  Widget _buildConversationCard(BuildContext context, Map<String, dynamic> conv) {
    final isUnread = conv['unread'] as bool;
    final isSystem = conv['isSystem'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isUnread ? 2 : 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isSystem
                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                  : AppTheme.successGreen.withValues(alpha: 0.2),
              child: Icon(
                conv['avatar'] as IconData,
                color: isSystem ? AppTheme.primaryBlue : AppTheme.successGreen,
                size: 28,
              ),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conv['name'] as String,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              conv['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            conv['lastMessage'] as String,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnread ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          if (!isSystem) {
            Navigator.pushNamed(
              context,
              AppRoutes.patientChat,
              arguments: {
                'name': conv['name'],
                'avatar': conv['avatar'],
              },
            );
          }
        },
      ),
    );
  }
}
