import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favStations = context.watch<FuelProvider>().favouriteStations;

    return Scaffold(
      appBar: AppBar(title: const Text("စိတ်ကြိုက်ဆီဆိုင်များ")),
      body: favStations.isEmpty
          ? const Center(child: Text("စိတ်ကြိုက်ဆိုင် မရှိသေးပါ"))
          : ListView.builder(
              itemCount: favStations.length,
              itemBuilder: (context, index) {
                final station = favStations[index];
                // StationCard မရှိသေးရင် ListTile နဲ့ အရင်ပြထားပါမယ်
                return ListTile(
                  title: Text(station.name),
                  subtitle: Text(station.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail
                  },
                );
              },
            ),
    );
  }
}
