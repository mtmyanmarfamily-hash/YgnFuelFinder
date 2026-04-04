import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';
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

    _firestoreSubscription = _firestore
        .collection('stations')
        .snapshots()
        .listen((snapshot) {
      
      // Firestore မှ ရလာသော document များကို Model သို့ ပြောင်းလဲခြင်း
      _stations = snapshot.docs.map((doc) {
        final data = doc.data();
        // ကျွန်တော်တို့ ရှေ့မှာ ပြင်ဆင်ခဲ့တဲ့ FuelStation.fromJson ကို အသုံးပြုပါသည်
        // doc.id ကိုပါ တပါတည်း ပို့ပေးရန် လိုအပ်သည်
        return FuelStation.fromJson(data, doc.id);
      }).toList();

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      debugPrint('Firestore stream error: $e');
      notifyListeners();
    });
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
      // ဆီအမျိုးအစား ကိုက်ညီမှု ရှိ၊ မရှိ စစ်ဆေးခြင်း
      final fuelMatch = s.fuelTypes.any((f) => _selectedFuelTypes.contains(f));
      
      // ဆီဆိုင် အခြေအနေ (Status) ကိုက်ညီမှု ရှိ၊ မရှိ စစ်ဆေးခြင်း
      final statusMatch = _statusFilter == null || s.status == _statusFilter;
      
      // အမည် သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေခြင်း
      final searchMatch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.address.toLowerCase().contains(_searchQuery.toLowerCase());
          
      return fuelMatch && statusMatch && searchMatch;
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
      if (_selectedFuelTypes.length > 1) _selectedFuelTypes.remove(type);
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
    _statusFilter = _statusFilter == s ? null : s;
    notifyListeners();
  }

  // === PREFS (ဖုန်းထဲတွင် ဒေတာ သိမ်းဆည်းခြင်း) ===
  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final favList = p.getStringList('favourites') ?? [];
      _favouriteIds = Set.from(favList);
    } catch (_) {
      debugPrint('Error loading preferences');
    }
  }

  Future<void> _savePrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('favourites', _favouriteIds.toList());
    } catch (_) {
      debugPrint('Error saving preferences');
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
