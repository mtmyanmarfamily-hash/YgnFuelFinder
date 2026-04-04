import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _notifyAvailable = true;
  bool _notifyBusy = false;
  bool _notifyAll = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifyAvailable = prefs.getBool('notify_available') ?? true;
      _notifyBusy = prefs.getBool('notify_busy') ?? false;
      _notifyAll = prefs.getBool('notify_all') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_available', _notifyAvailable);
    await prefs.setBool('notify_busy', _notifyBusy);
    await prefs.setBool('notify_all', _notifyAll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 သတိပေးချက် ဆက်တင်'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('✅ ဆီရသည် သတိပေး'),
                  subtitle: const Text('ဆီဌာနနှင့် ဆီရကြောင်း တင်သောအခါ'),
                  value: _notifyAvailable,
                  activeColor: Colors.green[700],
                  onChanged: (v) {
                    setState(() => _notifyAvailable = v);
                    _savePrefs();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('⚠️ တန်းစီရှည်လျှင် သတိပေး'),
                  subtitle: const Text('တန်းစီချိန် ၃၀ မိနစ်ကျော်သောအခါ'),
                  value: _notifyBusy,
                  activeColor: Colors.orange,
                  onChanged: (v) {
                    setState(() => _notifyBusy = v);
                    _savePrefs();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('📢 အားလုံး သတိပေး'),
                  subtitle: const Text('ဆီဌာန status ပြောင်းလဲမှုများ'),
                  value: _notifyAll,
                  activeColor: Colors.blue,
                  onChanged: (v) {
                    setState(() => _notifyAll = v);
                    _savePrefs();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await NotificationService.showAvailableAlert(
                  'New Day ဆီဌာန (စမ်းသပ်)');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ စမ်းသပ် notification ပို့လိုက်ပြီ')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Notification စမ်းသပ်ကြည့်ရန်'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
