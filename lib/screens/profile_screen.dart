import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await AuthService.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.displayName;
    final email = AuthService.email;
    final photo = AuthService.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ကျွန်တော့် Account'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.green[100],
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            Text(name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 10),

            // Role badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _isAdmin ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _isAdmin ? Colors.red[200]! : Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAdmin ? Icons.admin_panel_settings : Icons.person,
                    size: 16,
                    color: _isAdmin ? Colors.red[700] : Colors.green[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isAdmin ? 'Admin' : 'User',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isAdmin ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Admin panel button (admin only)
            if (_isAdmin) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminScreen()),
                  ),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Panel ဖွင့်မည်',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.email, 'Email', email),
                    const Divider(),
                    _infoRow(Icons.verified_user, 'Login နည်း', 'Google Account'),
                    if (_isAdmin) ...[
                      const Divider(),
                      _infoRow(Icons.shield, 'Permission',
                          'ဆိုင်အကြံပြုချက် approve / reject'),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Logout လုပ်မည်လား?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('မလုပ်ဘူး'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) await AuthService.signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
