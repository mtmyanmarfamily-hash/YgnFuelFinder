import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Services & Providers
import 'services/firebase_service.dart'; 
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/fuel_provider.dart';

// Screens
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ၁။ Notification Service ကို Initialize လုပ်ခြင်း
  await NotificationService.init();

  try {
    // ၂။ Firebase ကို Initialize လုပ်ခြင်း
    await Firebase.initializeApp();
    
    // ၃။ 🔥 Firebase ထဲသို့ ဆိုင်အချက်အလက် (၄၁) ဆိုင်လုံး တင်ရန် (တစ်ကြိမ်သာ Run ရန်)
    // Firestore ထဲမှာ Data တွေ ပေါ်လာပြီဆိုလျှင် နောက်တစ်ကြိမ် Build မလုပ်မီ ဤ line ကို ပြန်ပိတ် (//) ထားပါ။
    //await FirebaseService.uploadAllStationsFromLocal(); 
    
    print("Firebase initialized and stations upload successful.");
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => FuelProvider(),
      child: const YgnFuelApp(),
    ),
  );
}

class YgnFuelApp extends StatelessWidget {
  const YgnFuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ရန်ကုန် ဆီဌာန',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Login ဝင်ထားခြင်း ရှိ/မရှိ အပေါ်မူတည်ပြီး Screen ပြောင်းလဲခြင်း
      home: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const LoginScreen();
          }
          return const MainNavigation();
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const ListScreen(),
    const FavouriteScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'မြေပုံ'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'စာရင်း'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'စိတ်ကြိုက်'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'သတိပေး'),
          BottomNavigationBarItem(
            icon: _buildProfileIcon(),
            label: 'ကျွန်တော်'),
        ],
      ),
    );
  }

  // Profile ပုံရှိလျှင် ပုံပြရန်၊ မရှိလျှင် Icon ပြရန်
  Widget _buildProfileIcon() {
    final photo = AuthService.photoUrl;
    if (photo != null) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(photo),
      );
    }
    return const Icon(Icons.person);
  }
}
