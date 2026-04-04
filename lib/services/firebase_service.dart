import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<FuelStation>> getStationsStream() {
    return _db.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FuelStation.fromJson(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> suggestNewStation(Map<String, dynamic> data) async {
    await _db.collection('suggestions').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 Error Fix: Named parameters ကို သုံးပြီး Argument များလက်ခံနိုင်အောင် ပြင်ဆင်ခြင်း
  static Future<void> submitReport({
    required String stationId,
    required FuelStatus status,
    required int queueMinutes,
    required Map<String, bool> fuelAvailability,
    String? userName,
    String? note,
  }) async {
    final Map<String, dynamic> reportData = {
      'stationId': stationId,
      'status': status.index,
      'queueMinutes': queueMinutes,
      'fuelAvailability': fuelAvailability,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': userName ?? 'Anonymous',
      'note': note,
    };

    // ၁။ Reports Collection ထဲသို့ အသစ်ထည့်ခြင်း
    await _db.collection('reports').add(reportData);
    
    // ၂။ သက်ဆိုင်ရာ ဆီဆိုင်၏ လက်ရှိ Status ကိုပါ တစ်ခါတည်း Update လုပ်ပေးခြင်း
    await _db.collection('stations').doc(stationId).update({
      'status': status.index,
      'queueMinutes': queueMinutes,
      'availableFuels': fuelAvailability,
      'last_update': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<UserReport>> getReportsStream(String stationId) {
    return _db.collection('reports')
        .where('stationId', isEqualTo: stationId)
        .orderBy('timestamp', descending: true) // 🔥 Index ဆောက်ပြီးလျှင် ဒါကို ပြန်သုံးပါ
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserReport.fromFirestore(doc.data()))
            .toList());
  }
}
