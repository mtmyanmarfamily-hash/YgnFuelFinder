import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';
import 'station_detail_screen.dart'; // 🔥 Detail Screen ကို ကူးဖို့ Import လိုအပ်သည်

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ စိတ်ကြိုက်ဆီဆိုင်များ'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<FuelProvider>(
        builder: (context, provider, _) {
          final favs = provider.favouriteStations;

          if (favs.isEmpty) {
            return const Center(
              child: Text('စိတ်ကြိုက်ရွေးချယ်ထားသော ဆိုင်မရှိသေးပါ'),
            );
          }

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final s = favs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Text(s.status.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  // 🔥 ဒီနေရာမှာ onTap ထည့်လိုက်ရင် Detail Screen ကို ကူးသွားပါလိမ့်မယ်
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StationDetailScreen(stationId: s.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
