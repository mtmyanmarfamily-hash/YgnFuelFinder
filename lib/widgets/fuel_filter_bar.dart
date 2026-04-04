import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';

class FuelFilterBar extends StatelessWidget {
  const FuelFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, provider, _) => Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Fuel type filters
            ...['92', '95', 'PD', 'D'].map((type) {
              final selected = provider.selectedFuelTypes.contains(type);
              return GestureDetector(
                onTap: () => provider.toggleFuelType(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.green[700] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? Colors.green[700]!
                            : Colors.grey[400]!),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // Status filter
            PopupMenuButton<FuelStatus?>(
              icon: Icon(Icons.filter_list, color: Colors.green[700]),
              onSelected: provider.setStatusFilter,
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('အားလုံး')),
                const PopupMenuItem(
                    value: FuelStatus.available, child: Text('✅ ဆီရသည်')),
                const PopupMenuItem(
                    value: FuelStatus.busy, child: Text('⚠️ တန်းစီရှည်')),
                const PopupMenuItem(
                    value: FuelStatus.unavailable, child: Text('❌ ဆီမရဘူး')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
