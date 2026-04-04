import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_station.dart';
import '../services/firebase_service.dart';

class FuelProvider extends ChangeNotifier {
  List<FuelStation> _stations = [];
  Set<String> _favouriteIds = {};
  List<String> _selectedFuelTypes = ['92', '95', 'PD', 'D'];
  String _searchQuery = '';
  bool _isLoading = true;
  FuelStatus? _statusFilter;
  StreamSubscription? _firestoreSubscription;

  List<FuelStation> get stations => _filteredStations();
  bool get isLoading => _isLoading;
  List<FuelStation> get favouriteStations => 
      _stations.where((s) => _favouriteIds.contains(s.id)).toList();

  FuelProvider() { _init(); }

  Future<void> _init() async {
    await _loadPrefs();
    _listenToFirestore();
  }

  void _listenToFirestore() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseService.getStationsStream().listen((data) {
      _stations = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  // 🔥 Error ပြင်ရန်: getStation method ထည့်သွင်းခြင်း
  FuelStation? getStation(String id) {
    try {
      return _stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FuelStation> _filteredStations() {
    return _stations.where((s) {
      final searchMatch = _searchQuery.isEmpty || 
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final statusMatch = _statusFilter == null || s.status == _statusFilter;
      if (_selectedFuelTypes.isEmpty) return searchMatch && statusMatch;
      final fuelMatch = s.availableFuels.entries.any((e) => 
          _selectedFuelTypes.contains(e.key) && e.value == true);
      return searchMatch && statusMatch && fuelMatch;
    }).toList();
  }

  bool isFavourite(String id) => _favouriteIds.contains(id);

  Future<void> toggleFavourite(String id) async {
    if (_favouriteIds.contains(id)) { _favouriteIds.remove(id); } 
    else { _favouriteIds.add(id); }
    notifyListeners();
    await _savePrefs();
  }

  void toggleFuelType(String type) {
    _selectedFuelTypes.contains(type) ? _selectedFuelTypes.remove(type) : _selectedFuelTypes.add(type);
    notifyListeners();
  }

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
  void setStatusFilter(FuelStatus? s) { _statusFilter = (_statusFilter == s) ? null : s; notifyListeners(); }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _favouriteIds = Set.from(p.getStringList('favourites') ?? []);
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favourites', _favouriteIds.toList());
  }

  @override
  void dispose() { _firestoreSubscription?.cancel(); super.dispose(); }
}
