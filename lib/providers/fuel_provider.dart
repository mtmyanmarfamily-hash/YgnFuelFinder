import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_station.dart';
import '../models/fuel_alert.dart'; 
import '../services/firebase_service.dart';

class FuelProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<FuelStation> _stations = [];
  Set<String> _favouriteIds = {};
  
  // အစပိုင်းမှာ ဆီအမျိုးအစားအားလုံးကို ရွေးထားမည်
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

  void _listenToFirestore() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseService.getStationsStream().listen(
      (updatedStations) {
        _stations = updatedStations;
        _isLoading = false;
        notifyListeners(); 
      }, 
      onError: (e) {
        _isLoading = false;
        debugPrint('Firestore stream error: $e');
        notifyListeners();
      }
    );
  }

  /// 🛑 Filter Logic ကို အသစ်ပြန်ပြင်ထားပါသည်
  List<FuelStation> _filteredStations() {
    return _stations.where((s) {
      // ၁။ ရှာဖွေမှု (Search) စစ်ဆေးခြင်း
      final searchMatch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.address.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!searchMatch) return false;

      // ၂။ ဆီဆိုင် အခြေအနေ (Status) စစ်ဆေးခြင်း
      final statusMatch = _statusFilter == null || s.status == _statusFilter;
      if (!statusMatch) return false;

      // ၃။ ဆီအမျိုးအစား (Fuel Type) စစ်ဆေးခြင်း
      // User က Filter မှာ ဘာမှမရွေးထားရင် (Empty ဖြစ်နေရင်) ဆိုင်အားလုံးကို ပြပေးရပါမယ်
      if (_selectedFuelTypes.isEmpty) return true;

      // ရွေးထားသော ဆီအမျိုးအစားတစ်ခုခုသည် ဆိုင်တွင် ရနိုင်နေရမည်
      final fuelMatch = s.availableFuels.entries.any((entry) => 
          _selectedFuelTypes.contains(entry.key) && entry.value == true);
          
      return fuelMatch;
    }).toList();
  }

  // === FILTER UI မပျောက်စေရန် ပြင်ဆင်ချက် ===
  void toggleFuelType(String type) {
    if (_selectedFuelTypes.contains(type)) {
      _selectedFuelTypes.remove(type); // အကုန်ဖြုတ်ခွင့်ပေးလိုက်ပါပြီ
    } else {
      _selectedFuelTypes.add(type);
    }
    notifyListeners();
  }

  // === FAVOURITES ===
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

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setStatusFilter(FuelStatus? s) {
    _statusFilter = (_statusFilter == s) ? null : s;
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final favList = p.getStringList('favourites') ?? [];
      _favouriteIds = Set.from(favList);
      notifyListeners();
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
