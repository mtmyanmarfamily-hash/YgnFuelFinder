import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_station.dart';
import '../models/fuel_alert.dart';
import 'notification_service.dart';

class AlertService {
  static const _key = 'fuel_alerts';

  // Alert များ load လုပ်ရန်
  static Future<List<FuelAlert>> getAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => FuelAlert.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Alert သစ် သိမ်းရန်
  static Future<void> saveAlert(FuelAlert alert) async {
    final alerts = await getAlerts();
    final idx = alerts.indexWhere((a) => a.id == alert.id);
    if (idx >= 0) {
      alerts[idx] = alert;
    } else {
      alerts.add(alert);
    }
    await _persist(alerts);
  }

  // Alert ဖျက်ရန်
  static Future<void> deleteAlert(String alertId) async {
    final alerts = await getAlerts();
    alerts.removeWhere((a) => a.id == alertId);
    await _persist(alerts);
  }

  static Future<void> _persist(List<FuelAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(alerts.map((a) => a.toJson()).toList()));
  }

  // Status ပြောင်းလဲတိုင်း စစ်ဆေးပြီး notification ပို့ရန်
  static Future<void> checkAndNotify({
    required String stationId,
    required String stationName,
    required FuelStatus newStatus,
    required Map<String, bool> fuelAvailability,
  }) async {
    final alerts = await getAlerts();
    for (final alert in alerts) {
      if (!alert.isActive) continue;
      if (alert.stationId != stationId) continue;

      // ဆီအမျိုးအစား စစ်ဆေး
      final matchedFuels = alert.fuelTypes
          .where((f) => fuelAvailability[f] == true)
          .toList();

      if (newStatus == FuelStatus.available && alert.notifyAvailable) {
        final fuelStr = matchedFuels.isEmpty
            ? alert.fuelTypes.join(', ')
            : matchedFuels.join(', ');
        await NotificationService.showFuelAlert(
          stationName: stationName,
          message: '✅ $fuelStr ဆီရနေပြီ! လာယူနိုင်ပါပြီ',
        );
      } else if (newStatus == FuelStatus.unavailable && alert.notifyUnavailable) {
        await NotificationService.showFuelAlert(
          stationName: stationName,
          message: '❌ ${alert.fuelTypes.join(', ')} ဆီမရဘူး',
        );
      } else if (newStatus == FuelStatus.busy && alert.notifyBusy) {
        await NotificationService.showFuelAlert(
          stationName: stationName,
          message: '⚠️ တန်းစီရှည်နေသည်',
        );
      }
    }
  }

  // ဒီ station အတွက် alert ရှိမရှိ
  static Future<FuelAlert?> getAlertForStation(String stationId) async {
    final alerts = await getAlerts();
    try {
      return alerts.firstWhere((a) => a.stationId == stationId);
    } catch (_) {
      return null;
    }
  }
}
