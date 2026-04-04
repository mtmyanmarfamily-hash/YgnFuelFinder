import 'package:cloud_firestore/cloud_firestore.dart';

// 🛑 ပွားနေသော status များကို ဖယ်ရှားပြီး ရှင်းလင်းအောင် ထားပါသည်
enum FuelStatus { open, closed, busy, unknown }

extension FuelStatusExtension on FuelStatus {
  String get emoji {
    switch (this) {
      case FuelStatus.open: return '✅';
      case FuelStatus.closed: return '❌';
      case FuelStatus.busy: return '⏳';
      default: return '❓';
    }
  }

  String get label {
    switch (this) {
      case FuelStatus.open: return 'ဖွင့်သည်';
      case FuelStatus.closed: return 'ပိတ်သည်';
      case FuelStatus.busy: return 'တန်းစီနေသည်';
      default: return 'မသိရပါ';
    }
  }
}

class FuelStation {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List<String> fuelTypes;
  final FuelStatus status;
  final int queueMinutes;
  final DateTime lastUpdated;
  final Map<String, bool> availableFuels;

  FuelStation({
    required this.id, required this.name, required this.address,
    required this.lat, required this.lng, required this.fuelTypes,
    required this.status, required this.queueMinutes,
    required this.lastUpdated, required this.availableFuels,
  });

  factory FuelStation.fromJson(Map<String, dynamic> json, String id) {
    return FuelStation(
      id: id, // Firestore Document ID ကို တိုက်ရိုက်ယူသည်
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      fuelTypes: List<String>.from(json['fuelTypes'] ?? []),
      // Status index စစ်ဆေးခြင်း
      status: (json['status'] != null && json['status'] < FuelStatus.values.length)
          ? FuelStatus.values[json['status']] : FuelStatus.unknown,
      queueMinutes: json['queueMinutes'] ?? 0,
      lastUpdated: (json['last_update'] is Timestamp)
          ? (json['last_update'] as Timestamp).toDate() : DateTime.now(),
      availableFuels: Map<String, bool>.from(json['availableFuels'] ?? {}),
    );
  }
}
