import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';

class FuelFilterBar extends StatelessWidget {
  const FuelFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FuelProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.white,
      child: Column(
        children: [
          // ဆီအမျိုးအစား Filter
          Row(
            children: ['92', '95', 'PD', 'D'].map((type) {
              final isSelected = provider.selectedFuelTypes.contains(type);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) => provider.toggleFuelType(type),
                ),
              );
            }).toList(),
          ),
          const Divider(),
          // 🔥 Error ပြင်ရန်: Status Filter ကို FuelStatus.open/closed သို့ ပြောင်းခြင်း
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(status: FuelStatus.open, label: 'ဖွင့်သည်'),
                _StatusChip(status: FuelStatus.busy, label: 'တန်းစီနေသည်'),
                _StatusChip(status: FuelStatus.closed, label: 'ပိတ်သည်'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final FuelStatus status;
  final String label;
  const _StatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FuelProvider>();
    final isSelected = provider.statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Text(status.emoji),
        label: Text(label),
        backgroundColor: isSelected ? Colors.green[100] : null,
        onPressed: () => provider.setStatusFilter(status),
      ),
    );
  }
}
