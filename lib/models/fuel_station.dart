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
  final double lat;
  final double lng;

  FuelStation({
    required this.id, required this.name, required this.address,
    required this.status, required this.availableFuels,
    required this.queueMinutes, required this.lastUpdated,
    required this.lat, required this.lng,
  });

  // 🔥 suggest_station_screen မှာ သုံးဖို့အတွက် fuelTypes ပြန်ထည့်ထားပါတယ်
  List<String> get fuelTypes => availableFuels.keys.toList();

  factory FuelStation.fromJson(Map<String, dynamic> json, String id) {
    return FuelStation(
      id: id,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status'] != null 
          ? FuelStatus.values[(json['status'] as num).toInt() % FuelStatus.values.length] 
          : FuelStatus.unknown,
      availableFuels: json['availableFuels'] != null 
          ? Map<String, bool>.from(json['availableFuels']) 
          : {},
      queueMinutes: (json['queueMinutes'] as num? ?? 0).toInt(),
      lastUpdated: (json['last_update'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lat: (json['lat'] as num? ?? 16.8661).toDouble(),
      lng: (json['lng'] as num? ?? 96.1951).toDouble(),
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
    required this.id, required this.stationId, this.userName,
    required this.status, required this.queueMinutes,
    required this.reportedAt, this.note, required this.fuelAvailability,
  });

  factory UserReport.fromFirestore(Map<String, dynamic> json, String docId) {
    // 🔥 Firestore က 'reportedAt' ကို သုံးရပါမယ်
    final dynamic ts = json['reportedAt']; 
    final DateTime date = (ts is Timestamp) 
        ? ts.toDate() 
        : DateTime.now().subtract(const Duration(seconds: 1));

    return UserReport(
      id: docId,
      stationId: json['stationId']?.toString() ?? '',
      userName: json['userName']?.toString(),
      status: json['status'] != null 
          ? FuelStatus.values[(json['status'] as num).toInt() % FuelStatus.values.length] 
          : FuelStatus.open,
      queueMinutes: (json['queueMinutes'] as num? ?? 0).toInt(),
      reportedAt: date,
      note: json['note']?.toString(),
      fuelAvailability: json['fuelAvailability'] != null 
          ? Map<String, bool>.from(json['fuelAvailability']) 
          : {},
    );
  }
}
