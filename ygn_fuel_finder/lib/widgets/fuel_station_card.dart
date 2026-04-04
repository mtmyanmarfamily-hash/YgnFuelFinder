import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fuel_station.dart';
import '../screens/station_detail_screen.dart';

class FuelStationCard extends StatelessWidget {
  final FuelStation station;

  const FuelStationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StationDetailScreen(station: station)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ဆိုင်အမည် နှင့် Status (Emoji)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(station.status),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // လိပ်စာ
              Text(
                station.address,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Divider(height: 20),

              // 🔥 ဆီအမျိုးအစားများ (ရ/မရ စစ်ဆေးပြီး Check သို့မဟုတ် Cross ပြခြင်း)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['92', '95', 'PD', 'D'].where((type) => station.fuelTypes.contains(type)).map((type) {
                  final bool isAvailable = station.availableFuels[type] ?? false;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAvailable ? Colors.green[200]! : Colors.red[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.cancel, // ✅ သို့မဟုတ် ❌
                          size: 14,
                          color: isAvailable ? Colors.green[700] : Colors.red[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type,
                          style: TextStyle(
                            color: isAvailable ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // တန်းစီချိန် နှင့် နောက်ဆုံး Update အချိန်
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'တန်းစီချိန်: ${station.queueMinutes} မိနစ်',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    'Update: ${DateFormat('hh:mm a').format(station.lastUpdated)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Status Badge Logic (✅, ⚠️, ❌)
  Widget _buildStatusBadge(FuelStatus status) {
    Color color;
    switch (status) {
      case FuelStatus.available: color = Colors.green; break;
      case FuelStatus.busy: color = Colors.orange; break;
      case FuelStatus.unavailable: color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${status.emoji} ${status.label}',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
