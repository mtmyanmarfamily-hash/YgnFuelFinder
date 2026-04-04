import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App အကြောင်း'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('⛽', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ရန်ကုန် ဆီဌာနနေရာ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Version 1.0.0',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _infoCard(
              '📱 App အကြောင်း',
              'ရန်ကုန်မြို့တွင်းရှိ ဆီဌာနနေရာများကို မြေပုံပေါ် ပြသပေးပြီး '
              'အသုံးပြုသူများ ဆီရ/မရ status ကို real-time တင်ဆက်နိုင်သော App',
            ),
            const SizedBox(height: 12),
            _infoCard(
              '🗺️ မြေပုံ',
              'OpenStreetMap (OSM) မြေပုံ အခမဲ့ open-source ကို အသုံးပြုသည်',
            ),
            const SizedBox(height: 12),
            _infoCard(
              '💾 Data',
              'ဒေတာများကို ကိုယ်ပိုင် ဖုန်းထဲတွင်သာ သိမ်းဆည်းသည်။ '
              'Server မလိုဘဲ offline အလုပ်လုပ်သည်',
            ),
            const SizedBox(height: 12),
            _infoCard(
              '🤝 ပူးပေါင်းကူညီရန်',
              'GitHub: github.com/ygn-fuel-finder\n'
              'ဆီဌာနအသစ်များ ထည့်ချင်ပါက PR ပို့နိုင်ပါသည်',
            ),
            const SizedBox(height: 32),
            Text(
              'Made with ❤️ for Yangon',
              style: TextStyle(color: Colors.green[700], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
