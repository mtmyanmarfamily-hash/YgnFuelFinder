import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';
import 'station_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  // 🔥 Build Error ကင်းဝေးစေရန် Status အားလုံးကို Case ထည့်သွင်းထားပါသည်
  Color _statusColor(FuelStatus s) {
    switch (s) {
      case FuelStatus.open:
      case FuelStatus.available:
        return Colors.green;
      case FuelStatus.busy:
        return Colors.orange;
      case FuelStatus.closed:
      case FuelStatus.unavailable:
        return Colors.red;
      case FuelStatus.unknown:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ စိတ်ကြိုက်ဆိုင်များ'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FuelProvider>(
        builder: (context, provider, _) {
          final favs = provider.favouriteStations;

          if (favs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: favs.length,
            itemBuilder: (context, i) {
              final s = favs[i];
              return _buildFavouriteCard(context, s, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavouriteCard(BuildContext context, FuelStation s, FuelProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StationDetailScreen(stationId: s.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ၁။ ဘယ်ဘက် Status Icon
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _statusColor(s.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(s.status.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),

              // ၂။ အချက်အလက်များ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      s.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // ဆီအမျိုးအစားများ
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: s.fuelTypes.map((f) {
                        final isAvail = s.availableFuels[f] ?? false;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAvail ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isAvail ? Colors.green[200]! : Colors.red[200]!,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAvail ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // ၃။ ညာဘက် Action Button
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber, size: 28),
                    onPressed: () => provider.toggleFavourite(s.id),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'စိတ်ကြိုက်ဆိုင် မရှိသေးပါ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'ဆီဆိုင်အသေးစိတ်စာမျက်နှာရှိ ⭐ ကိုနှိပ်ပြီး စိတ်ကြိုက်ဆိုင်များကို သိမ်းဆည်းနိုင်ပါသည်',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
