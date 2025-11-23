// lib/features/profile/presentation/pages/profile_page.dart
// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';  // ADD THIS
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_service.dart';  // ADD THIS
import '../../../../core/storage/secure_storage.dart';  // ADD THIS
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/notification_manager.dart';  // ADD THIS at top

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _titleController = TextEditingController(text: 'Test Notification');
  final _bodyController = TextEditingController(text: 'This is a test push notification');
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space4),
        children: [
          // User Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space4),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      'S',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Text(
                    'Saad',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.space1),
                  Text(
                    'saad@example.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.space6),
          
          // Test Push Section
          Text(
            'Test Push Notification',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'Send yourself a test notification to verify push is working',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space4),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Notification title',
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  TextField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Notification body',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.space4),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendTestPush,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(_isSending ? 'Sending...' : 'Send Test Push'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.space6),
          
          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.favorite_outline_rounded,
            title: 'Favorites',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.download_outlined,
            title: 'Downloads',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.history_rounded,
            title: 'Watch History',
            onTap: () {},
          ),
          const Divider(height: AppTheme.space6),
          _buildMenuItem(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: _handleLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space4),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendTestPush() async {
  if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter title and message')),
    );
    return;
  }
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
