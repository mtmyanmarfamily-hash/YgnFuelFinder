import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fuel_station.dart';
import '../providers/fuel_provider.dart';
import '../services/firebase_service.dart';
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
  
  // 🔥 Error Fix: available အစား open ကို သုံးထားပါသည်
  FuelStatus _selectedStatus = FuelStatus.open; 
  int _queueMinutes = 0;
  bool _submitting = false;

  final Map<String, bool> _fuelAvailability = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Tab ကို ၂ ခုပဲ အရင်ထားပါမည်
    
    // 🔥 Error Fix: FuelProvider ထဲက getStation ကို ခေါ်ယူခြင်း
    final station = context.read<FuelProvider>().getStation(widget.stationId);
    if (station != null) {
      for (final f in station.fuelTypes) {
        _fuelAvailability[f] = station.availableFuels[f] ?? true;
      }
      _selectedStatus = station.status;
      _queueMinutes = station.queueMinutes;
    }
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
              tabs: const [Tab(text: 'အခြေအနေ'), Tab(text: 'သတင်းများ')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(station),
              _buildReportsTab(),
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
          // 🔥 Status ရွေးချယ်မှု (ပွားနေသော status များ မပါတော့ပါ)
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
            decoration: const InputDecoration(
              hintText: 'မှတ်ချက် (ဥပမာ- ဆီကားရောက်နေသည်)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700], 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _submitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('သတင်းပို့မည်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
  Widget _buildReportsTab() {
  return StreamBuilder<List<UserReport>>(
    stream: FirebaseService.getReportsStream(widget.stationId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('သတင်းများ မရှိသေးပါ'));
      
      final reports = snapshot.data!;
      return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, i) {
          final r = reports[i];
          
          // 🔥 ရနိုင်သော ဆီအမျိုးအစားများကို List လုပ်ခြင်း
          final availableFuels = r.fuelAvailability.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .join(', ');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // နာမည်အစား အခြေအနေကို ပိုကြီးကြီးပြပါမည်
                      Text('${r.status.emoji} ${r.status.label}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      // သတင်းပို့ခဲ့သည့် အချိန် (မိနစ်)
                      Text(_timeAgo(r.reportedAt), 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 🔥 ရနိုင်သော ဆီအမျိုးအစားများကို ပြသခြင်း
                  if (availableFuels.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('ရရှိနိုင်သောဆီ: $availableFuels', 
                        style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  const SizedBox(height: 8),
                  // တန်းစီချိန်နှင့် မှတ်ချက်
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('တန်းစီချိန်: ${r.queueMinutes} မိနစ်', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  if (r.note != null && r.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('💬 ${r.note!}', style: const TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  Future<void> _submitReport() async {
    final note = _noteController.text.trim();
    if (note.isNotEmpty && MyanmarLanguageFilter.containsProfanity(note)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မယဉ်ကျေးသော စကားလုံးများ ပါဝင်နေပါသည်')));
      return;
    }

    setState(() => _submitting = true);
    
    final user = FirebaseAuth.instance.currentUser;

    // 🔥 Error Fix: UserReport constructor ကို Model နှင့် ကိုက်ညီအောင် ပြင်ဆင်ထားပါသည်
    final report = UserReport(
      id: '', // Firebase မှာ ID auto ထွက်ပါမည်
      stationId: widget.stationId,
      userName: user?.displayName ?? 'Anonymous', 
      status: _selectedStatus,
      queueMinutes: _queueMinutes,
      reportedAt: DateTime.now(),
      note: note.isEmpty ? null : note,
      fuelAvailability: Map<String, bool>.from(_fuelAvailability),
    );
    
    try {
      await FirebaseService.submitReport(report);
      if (mounted) {
        setState(() => _submitting = false);
        _tabController.animateTo(1);
        _noteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('သတင်းပို့ပြီးပါပြီ')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
