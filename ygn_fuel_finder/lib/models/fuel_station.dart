import 'package:cloud_firestore/cloud_firestore.dart';

enum FuelStatus { open, closed, busy, unknown, available, unavailable }

extension FuelStatusExtension on FuelStatus {
  String get emoji {
    switch (this) {
      case FuelStatus.open: case FuelStatus.available: return '✅';
      case FuelStatus.closed: case FuelStatus.unavailable: return '❌';
      case FuelStatus.busy: return '⏳';
      default: return '❓';
    }
  }

  String get label {
    switch (this) {
      case FuelStatus.open: case FuelStatus.available: return 'ဖွင့်သည်';
      case FuelStatus.closed: case FuelStatus.unavailable: return 'ပိတ်သည်';
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
      id: id,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      fuelTypes: List<String>.from(json['fuelTypes'] ?? []),
      status: (json['status'] != null && json['status'] < FuelStatus.values.length)
          ? FuelStatus.values[json['status']] : FuelStatus.unknown,
      queueMinutes: json['queueMinutes'] ?? 0,
      lastUpdated: (json['last_update'] is Timestamp)
          ? (json['last_update'] as Timestamp).toDate() : DateTime.now(),
      availableFuels: Map<String, bool>.from(json['availableFuels'] ?? {}),
    );
  }
}

class UserReport {
  final String id;
  final String stationId;
  final String? userName; // 🔥 UI က တောင်းဆိုနေသော နာမည်
  final FuelStatus status;
  final int queueMinutes;
  final String? note;
  final String? fuelType;
  final Map<String, bool> fuelAvailability;
  final DateTime reportedAt;

  UserReport({
    required this.id,
    required this.stationId,
    this.userName,
    required this.status,
    required this.queueMinutes,
    this.note,
    this.fuelType,
    required this.fuelAvailability,
    required this.reportedAt,
  });

  factory UserReport.fromFirestore(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'] ?? '',
      stationId: json['stationId'] ?? '',
      userName: json['userName'],
      status: (json['status'] != null && json['status'] < FuelStatus.values.length)
          ? FuelStatus.values[json['status']] : FuelStatus.unknown,
      queueMinutes: json['queueMinutes'] ?? 0,
      note: json['note'],
      fuelType: json['fuelType'],
      fuelAvailability: Map<String, bool>.from(json['fuelAvailability'] ?? json['availableFuels'] ?? {}),
      reportedAt: (json['timestamp'] is Timestamp) 
          ? (json['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}
