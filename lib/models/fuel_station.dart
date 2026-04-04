import 'package:cloud_firestore/cloud_firestore.dart';

enum FuelStatus { open, busy, closed, unknown }

extension FuelStatusExtension on FuelStatus {
  String get label {
    switch (this) {
      case FuelStatus.open: return 'ဖွင့်သည်';
      case FuelStatus.busy: return 'တန်းစီနေသည်';
      case FuelStatus.closed: return 'ပိတ်သည်';
      case FuelStatus.unknown: return 'မသိရပါ';
    }
  }

  String get emoji {
    switch (this) {
      case FuelStatus.open: return '✅';
      case FuelStatus.busy: return '⏳';
      case FuelStatus.closed: return '❌';
      case FuelStatus.unknown: return '❓';
    }
  }
}

class FuelStation {
  final String id;
  final String name;
  final String address;
  final FuelStatus status;
  final Map<String, bool> availableFuels;
  final int queueMinutes;
  final DateTime lastUpdated;
  final double lat; // 🔥 Added
  final double lng; // 🔥 Added

  FuelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.availableFuels,
    required this.queueMinutes,
    required this.lastUpdated,
    required this.lat,
    required this.lng,
  });

  List<String> get fuelTypes => availableFuels.keys.toList();

  factory FuelStation.fromJson(Map<String, dynamic> json, String id) {
    return FuelStation(
      id: id,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      status: FuelStatus.values[json['status'] ?? 3],
      availableFuels: Map<String, bool>.from(json['availableFuels'] ?? {}),
      queueMinutes: (json['queueMinutes'] ?? 0).toInt(),
      lastUpdated: (json['last_update'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lat: (json['lat'] ?? 16.8661).toDouble(), // Default to Yangon if null
      lng: (json['lng'] ?? 96.1951).toDouble(),
    );
  }
}

class UserReport {
  final String id;
  final String stationId;
  final String? userName;
  final FuelStatus status;
  final int queueMinutes;
  final DateTime reportedAt;
  final String? note;
  final Map<String, bool> fuelAvailability;

  UserReport({
    required this.id,
    required this.stationId,
    this.userName,
    required this.status,
    required this.queueMinutes,
    required this.reportedAt,
    this.note,
    required this.fuelAvailability,
  });

  factory UserReport.fromFirestore(Map<String, dynamic> json) {
    return UserReport(
      id: '',
      stationId: json['stationId'] ?? '',
      userName: json['userName'],
      status: FuelStatus.values[json['status'] ?? 0],
      queueMinutes: (json['queueMinutes'] ?? 0).toInt(),
      reportedAt: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: json['note'],
      fuelAvailability: Map<String, bool>.from(json['fuelAvailability'] ?? {}),
    );
  }
}
