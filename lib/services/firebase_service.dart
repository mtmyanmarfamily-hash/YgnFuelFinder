import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<FuelStation>> getStationsStream() {
    return _db.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FuelStation.fromJson(doc.data(), doc.id)).toList();
    });
  }

  // 🔥 Error Fix: suggestNewStation method ထည့်သွင်းခြင်း
  static Future<void> suggestNewStation(Map<String, dynamic> data) async {
    await _db.collection('suggestions').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> submitReport(UserReport report) async {
    await _db.collection('reports').add({
      'stationId': report.stationId,
      'status': report.status.index,
      'queueMinutes': report.queueMinutes,
      'fuelAvailability': report.fuelAvailability,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': report.userName,
      'note': report.note,
    });
    
    await _db.collection('stations').doc(report.stationId).update({
      'status': report.status.index,
      'queueMinutes': report.queueMinutes,
      'availableFuels': report.fuelAvailability,
      'last_update': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<UserReport>> getReportsStream(String stationId) {
    return _db.collection('reports')
        .where('stationId', isEqualTo: stationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserReport.fromFirestore(doc.data())).toList());
  }
}
