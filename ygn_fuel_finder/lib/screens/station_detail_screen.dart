import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/fuel_station.dart';
import '../models/fuel_alert.dart'; // 🔥 Import missing model
import '../providers/fuel_provider.dart';
import '../services/firebase_service.dart';
import '../services/alert_service.dart';
import '../utils/language_filter.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationId;
  const StationDetailScreen({super.key, required this.stationId});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteController = TextEditingController();
  
  FuelStatus _selectedStatus = FuelStatus.available;
  int _queueMinutes = 0;
  bool _submitting = false;

  final Map<String, bool> _fuelAvailability = {};
  FuelAlert? _currentAlert;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    final station = context.read<FuelProvider>().getStation(widget.stationId);
    if (station != null) {
      for (final f in station.fuelTypes) {
        _fuelAvailability[f] = station.availableFuels[f] ?? true;
      }
    }
    _loadAlert();
  }

  Future<void> _loadAlert() async {
    final alert = await AlertService.getAlertForStation(widget.stationId);
    if (mounted) setState(() => _currentAlert = alert);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ယခုလေးတင်';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, provider, _) {
        final station = provider.getStation(widget.stationId);
        if (station == null) return const Scaffold(body: Center(child: Text('ဆီဌာနမတွေ့ပါ')));

        return Scaffold(
          appBar: AppBar(
            title: Text(station.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'အခြေအနေ'), Tab(text: 'သတင်းများ'), Tab(text: 'Alert')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(station),
              _buildReportsTab(),
              _buildAlertTab(station),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(FuelStation station) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📢 ယခုအခြေအနေ သတင်းပို့ရန်', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text('ဘယ်ဆီတွေ ရနိုင်သလဲ?', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            children: station.fuelTypes.map((f) {
              return FilterChip(
                label: Text(f),
                selected: _fuelAvailability[f] ?? false,
                onSelected: (v) => setState(() => _fuelAvailability[f] = v),
              );
            }).toList(),
          ),
          const Divider(height: 30),
          ...FuelStatus.values.where((s) => s != FuelStatus.unknown).map((s) => 
            RadioListTile<FuelStatus>(
              value: s,
              groupValue: _selectedStatus,
              title: Text('${s.emoji} ${s.label}'),
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
          ),
          const SizedBox(height: 16),
          Text('တန်းစီချိန်: ~$_queueMinutes မိနစ်', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _queueMinutes.toDouble(),
            min: 0, max: 120, divisions: 12,
            activeColor: Colors.orange,
            onChanged: (v) => setState(() => _queueMinutes = v.round()),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'မှတ်ချက် (ဥပမာ- ဆီကားရောက်နေသည်)'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('သတင်းပို့မည်'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return StreamBuilder<List<UserReport>>(
      stream: FirebaseService.getReportsStream(widget.stationId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data!;
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(child: Text(r.userName?[0] ?? 'U')),
                title: Text(r.userName ?? 'အမည်မသိ', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.status.emoji} ${r.status.label}'),
                    if (r.note != null) Text(r.note!, style: const TextStyle(color: Colors.blueGrey)),
                  ],
                ),
                trailing: Text(_timeAgo(r.reportedAt), style: const TextStyle(fontSize: 10)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlertTab(FuelStation station) => const Center(child: Text('Alert settings here')); 

  Future<void> _submitReport() async {
    if (MyanmarLanguageFilter.containsProfanity(_noteController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မယဉ်ကျေးသော စကားလုံးများ ပါဝင်နေပါသည်')));
      return;
    }

    setState(() => _submitting = true);
    
    // 🔥 Current User info from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    final report = UserReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 🔥 Unique ID added
      stationId: widget.stationId,
      userName: user?.displayName ?? 'Anonymous', // 🔥 UserName added
      status: _selectedStatus,
      queueMinutes: _queueMinutes,
      fuelType: 'Multiple', 
      reportedAt: DateTime.now(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      fuelAvailability: Map.from(_fuelAvailability),
    );
    
    try {
      await FirebaseService.submitReport(report);
      setState(() => _submitting = false);
      _tabController.animateTo(1);
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('သတင်းပို့ပြီးပါပြီ')));
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
