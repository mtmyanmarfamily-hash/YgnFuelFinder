import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';
import '../widgets/fuel_filter_bar.dart';
import 'station_detail_screen.dart';
import 'suggest_station_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'ယခုလေးတင်';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Color _statusColor(FuelStatus status) {
    switch (status) {
      case FuelStatus.open:
        return Colors.green;
      case FuelStatus.busy:
        return Colors.orange;
      case FuelStatus.closed:
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
        title: const Text('⛽ ဆီဌာနစာရင်း'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuggestStationScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Consumer<FuelProvider>(
              builder: (context, provider, _) => TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ဆီဌာနအမည် သို့မဟုတ် လိပ်စာဖြင့်ရှာရန်...',
                  hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.green[800],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const FuelFilterBar(),
          Expanded(
            child: Consumer<FuelProvider>(
              builder: (context, provider, _) {
                final stations = provider.stations;
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (stations.isEmpty) return _buildEmptyState(context);

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: stations.length + 1,
                  itemBuilder: (context, index) {
                    if (index == stations.length) return _buildSuggestFooter(context);
                    return _buildStationCard(context, stations[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, FuelStation s) {
    final provider = context.read<FuelProvider>();
    final isFav = context.select<FuelProvider, bool>((p) => p.isFavourite(s.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StationDetailScreen(stationId: s.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ၁။ ဘယ်ဘက် အိုင်ကွန်
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusColor(s.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(s.status.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              
              // ၂။ အလယ်ရှိ အချက်အလက်များ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 🔥 Favourite Star Icon
                        GestureDetector(
                          onTap: () => provider.toggleFavourite(s.id),
                          child: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.orange : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Text(s.address, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: s.fuelTypes.map((f) {
                        final bool isAvailable = s.availableFuels[f] ?? false;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isAvailable ? Colors.green[200]! : Colors.red[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isAvailable ? Icons.check_circle : Icons.cancel, size: 12, color: isAvailable ? Colors.green[700] : Colors.red[700]),
                              const SizedBox(width: 4),
                              Text(f, style: TextStyle(fontSize: 11, color: isAvailable ? Colors.green[900] : Colors.red[900], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // ၃။ ညာဘက်ရှိ အချိန်ပြသည့်အပိုင်း
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(s.lastUpdated),
                    style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                  if (s.queueMinutes > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                      child: Text('${s.queueMinutes}m queue', style: const TextStyle(fontSize: 9, color: Colors.orange)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_gas_station_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('ဆီဌာန မတွေ့ပါ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuggestFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add_location_alt, color: Colors.green),
        label: const Text('ဆိုင်တည်နေရာ ပေါ်မနေသေးလား?\nဤနေရာတွင် အကြံပြုနိုင်ပါသည်', textAlign: TextAlign.center),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuggestStationScreen())),
      ),
    );
  }
}
