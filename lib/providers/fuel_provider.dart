import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';
import '../models/fuel_alert.dart'; // UserReport အတွက် လိုအပ်ပါက
import '../services/firebase_service.dart';

class FuelProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firestore မှ ရရှိလာသော station အစစ်အမှန်များ သိမ်းဆည်းရန် List
  List<FuelStation> _stations = [];
  Set<String> _favouriteIds = {};
  List<String> _selectedFuelTypes = ['92', '95', 'PD', 'D'];
  String _searchQuery = '';
  bool _isLoading = true;
  FuelStatus? _statusFilter;
  StreamSubscription? _firestoreSubscription;

  // Getters
  List<FuelStation> get stations        => _filteredStations();
  List<FuelStation> get allStations     => _stations;
  List<String>      get selectedFuelTypes => _selectedFuelTypes;
  bool              get isLoading        => _isLoading;
  FuelStatus?       get statusFilter     => _statusFilter;
  String            get searchQuery      => _searchQuery;
  Set<String>       get favouriteIds     => _favouriteIds;

  List<FuelStation> get favouriteStations =>
      _stations.where((s) => _favouriteIds.contains(s.id)).toList();

  FuelProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadPrefs();
    _listenToFirestore();
  }

  /// Firestore မှ Data များကို Real-time နားထောင်ခြင်း
  void _listenToFirestore() {
    // အရင်ရှိနေတဲ့ subscription ကို cancel လုပ်ပါ
    _firestoreSubscription?.cancel();

    // FirebaseService တွင် ရေးထားသော getStationsStream ကို တိုက်ရိုက် သုံးနိုင်သည်
    _firestoreSubscription = FirebaseService.getStationsStream().listen(
      (updatedStations) {
        _stations = updatedStations;
        _isLoading = false;
        notifyListeners(); // UI ကို Data အသစ်ရောက်ကြောင်း အကြောင်းကြားရန်
      }, 
      onError: (e) {
        _isLoading = false;
        debugPrint('Firestore stream error: $e');
        notifyListeners();
      }
    );
  }

  /// Station တစ်ခုချင်းစီ၏ Report များကို Firebase မှ Stream အနေဖြင့် ရယူခြင်း
  Stream<List<UserReport>> getStationReports(String stationId) =>
      FirebaseService.getReportsStream(stationId);

  FuelStation? getStation(String id) {
    try {
      return _stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ရှာဖွေမှုနှင့် Filter များအရ ဆီဆိုင်စာရင်းကို စစ်ထုတ်ခြင်း
  List<FuelStation> _filteredStations() {
    return _stations.where((s) {
      // ၁။ အမည် သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေခြင်း (Search Match)
      final searchMatch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.address.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!searchMatch) return false;

      // ၂။ ဆီဆိုင် အခြေအနေ (Status) ကိုက်ညီမှု ရှိ၊ မရှိ စစ်ဆေးခြင်း
      final statusMatch = _statusFilter == null || s.status == _statusFilter;
      if (!statusMatch) return false;

      // ၃။ ဆီအမျိုးအစား ကိုက်ညီမှု ရှိ၊ မရှိ စစ်ဆေးခြင်း (Fuel Type Match)
      // availableFuels Map ထဲတွင် true ဖြစ်နေသော အမျိုးအစားများကို စစ်သည်
      final fuelMatch = s.availableFuels.entries.any((entry) => 
          _selectedFuelTypes.contains(entry.key) && entry.value == true);
          
      return fuelMatch;
    }).toList();
  }

  // === FAVOURITES (အကြိုက်ဆုံး ဆီဆိုင်များ) ===
  bool isFavourite(String id) => _favouriteIds.contains(id);

  Future<void> toggleFavourite(String id) async {
    if (_favouriteIds.contains(id)) {
      _favouriteIds.remove(id);
    } else {
      _favouriteIds.add(id);
    }
    notifyListeners();
    await _savePrefs();
  }

  // === FILTERS (စစ်ထုတ်ကိရိယာများ) ===
  void toggleFuelType(String type) {
    if (_selectedFuelTypes.contains(type)) {
      if (_selectedFuelTypes.length > 1) {
        _selectedFuelTypes.remove(type);
      }
    } else {
      _selectedFuelTypes.add(type);
    }
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setStatusFilter(FuelStatus? s) {
    // နှိပ်ပြီးသား status ကို ပြန်နှိပ်ရင် filter ဖြုတ်ရန်
    _statusFilter = (_statusFilter == s) ? null : s;
    notifyListeners();
  }

  // === PREFS (ဖုန်းထဲတွင် ဒေတာ သိမ်းဆည်းခြင်း) ===
  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final favList = p.getStringList('favourites') ?? [];
      _favouriteIds = Set.from(favList);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _savePrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('favourites', _favouriteIds.toList());
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
