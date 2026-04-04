import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/fuel_station.dart';
import '../models/fuel_alert.dart';



class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ၁။ 🔥 Firebase မှ ဆိုင်အချက်အလက်များကို Live နားထောင်ခြင်း
  static Stream<List<FuelStation>> getStationsStream() {
    // includeMetadataChanges: true ထည့်ထားခြင်းဖြင့် local update များကိုပါ ချက်ချင်းသိနိုင်သည်
    return _firestore
        .collection('stations')
        .snapshots(includeMetadataChanges: true) 
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        final Map<String, dynamic> fuelsMap = data['availableFuels'] ?? {};
        
        // Map ထဲတွင် true ဖြစ်နေသော ဆီအမျိုးအစားများ
        final List<String> fuelsList = fuelsMap.keys
            .where((k) => fuelsMap[k] == true)
            .toList();

        // 🔥 Timestamp ဖတ်ယူခြင်း (Server side update မပြီးခင် local အချိန်ကို သုံးရန် estimatePostWrite သုံးသည်)
        DateTime updatedTime;
        final timestamp = data['last_update'] as Timestamp?;
        if (timestamp != null) {
          updatedTime = timestamp.toDate();
        } else {
          updatedTime = DateTime.now();
        }

        return FuelStation(
          id: doc.id,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          lat: (data['lat'] as num?)?.toDouble() ?? 0.0, 
          lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
          fuelTypes: List<String>.from(data['fuelTypes'] ?? fuelsList),
          status: FuelStatus.values[data['status'] ?? 3],
          queueMinutes: (data['queueMinutes'] ?? 0).toInt(),
          lastUpdated: updatedTime, 
          availableFuels: Map<String, bool>.from(fuelsMap),
        );
      }).toList();
    });
  }

  // ၂။ 🔥 Report တင်ခြင်း (Batch Update သုံးထားသဖြင့် Atomic ဖြစ်သည်)
  static Future<void> submitReport(UserReport report) async {
    try {
      final batch = _firestore.batch();
      final user = _auth.currentUser;
      final serverNow = FieldValue.serverTimestamp();



      // (က) Reports Collection ထဲသို့ သတင်းအသစ် ထည့်ခြင်း
      final reportRef = _firestore.collection('reports').doc();
      batch.set(reportRef, {
        'stationId': report.stationId,
        'status': report.status.index,
        'queueMinutes': report.queueMinutes,
        'fuelType': report.fuelType,
        'reportedAt': serverNow,
        'note': report.note ?? '',
        'userId': user?.uid,
        'fuelAvailability': report.fuelAvailability,
      });

      // (ခ) Stations Collection ရှိ ဆိုင်၏ အချက်အလက်ကို Update လုပ်ခြင်း
      final stationRef = _firestore.collection('stations').doc(report.stationId);
      batch.update(stationRef, {
        'status': report.status.index,
        'queueMinutes': report.queueMinutes,
        'last_update': serverNow, 
        'availableFuels': report.fuelAvailability,
      });

      await batch.commit();
      debugPrint("Update Successful for Station: ${report.stationId}");
    } catch (e) {
      debugPrint("Submit Report Error: $e");
      rethrow;
    }
  }

  // ၃။ 🔥 သီးသန့် Report Stream (သတင်းများ Tab အတွက်)
  static Stream<List<UserReport>> getReportsStream(String stationId) {
    return _firestore
        .collection('reports')
        .where('stationId', isEqualTo: stationId)
        .orderBy('reportedAt', descending: true)
        .limit(20) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // UserReport model ရှိ factory method သုံး၍ map လုပ်ခြင်း
        return UserReport.fromFirestore(doc.data());
      }).toList();
    });
  }

  // ၄။ ဆိုင်အသစ် အကြံပြုရန်
  static Future<void> suggestNewStation(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('suggestions').add({
        ...data,
        'submittedAt': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser?.uid,
      });
    } catch (e) {
      debugPrint("Suggest Station Error: $e");
      rethrow;
    }
  }
}
