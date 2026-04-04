import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<FuelStation>> getStationsStream() {
    return _db.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FuelStation.fromJson(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> submitReport({
    required String stationId,
    required FuelStatus status,
    required int queueMinutes,
    required Map<String, bool> fuelAvailability,
    String? userName,
    String? note,
  }) async {
    final reportData = {
      'stationId': stationId,
      'status': status.index,
      'queueMinutes': queueMinutes,
      'fuelAvailability': fuelAvailability,
      'timestamp': FieldValue.serverTimestamp(), // 🔥 Server timestamp
      'userName': userName ?? 'Anonymous',
      'note': note,
    };

    await _db.collection('reports').add(reportData);
    
    await _db.collection('stations').doc(stationId).update({
      'status': status.index,
      'queueMinutes': queueMinutes,
      'availableFuels': fuelAvailability,
      'last_update': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<UserReport>> getReportsStream(String stationId) {
    // 🔥 metadataChanges ကို နားထောင်ခြင်းဖြင့် server timestamp အစစ်မကျခင် estimate ကို ရယူခြင်း
    return _db.collection('reports')
        .where('stationId', isEqualTo: stationId)
        .snapshots(includeMetadataChanges: true) 
        .map((snapshot) {
          final reports = snapshot.docs
              .map((doc) => UserReport.fromFirestore(doc.data(), doc.id))
              .toList();
          
          // 🔥 အချိန်အလိုက် နောက်ဆုံးပို့တာအရင်ပြရန် စီခြင်း
          reports.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
          return reports;
        });
  }
}
