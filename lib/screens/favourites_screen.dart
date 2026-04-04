import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../widgets/station_card.dart'; // သင့် Card Widget အမည်

class FavouriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("စိတ်ကြိုက်ဆီဆိုင်များ")),
      body: Consumer<FuelProvider>(
        builder: (context, provider, child) {
          final favs = provider.favouriteStations;

          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (favs.isEmpty) return Center(child: Text("စိတ်ကြိုက်ဆိုင် မရှိသေးပါ"));

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, index) => StationCard(station: favs[index]),
          );
        },
      ),
    );
  }
}
