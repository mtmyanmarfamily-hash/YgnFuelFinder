import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/fuel_station.dart';      
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_station.dart';
import 'station_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Provider ထဲက ဆီဆိုင်ဒေတာများကို ယူသည်
    final provider = context.watch<FuelProvider>();
    final stations = provider.stations;
    final isLoading = provider.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          // ⚠️ ဒီနေရာမှာ const လုံးဝ မသုံးရပါ (LatLng ကြောင့် ဖြစ်သည်)
          initialCenter: LatLng(16.842, 96.173), 
          initialZoom: 12.0,
        ),
        children: [
          // မြေပုံ Tiles (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ygn_fuel_finder',
          ),
          
          // ဆီဆိုင် Marker များ
          MarkerLayer(
            markers: stations.map((station) {
              return Marker(
                point: LatLng(station.lat, station.lng),
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () {
                    // ဆီဆိုင်အသေးစိတ် screen သို့ သွားရန်
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StationDetailScreen(stationId: station.id),
                      ),
                    );
                  },
                  child: _buildMarkerIcon(station.status),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ဆီဆိုင် Status အလိုက် အရောင်ပြောင်းပေးသော Icon
  Widget _buildMarkerIcon(FuelStatus status) {
    Color color;
    switch (status) {
      case FuelStatus.open:
        color = Colors.green;
        break;
      case FuelStatus.busy:
        color = Colors.orange;
        break;
      case FuelStatus.closed:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, color: color, size: 45),
        const Positioned(
          top: 8,
          child: Icon(Icons.local_gas_station, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}
