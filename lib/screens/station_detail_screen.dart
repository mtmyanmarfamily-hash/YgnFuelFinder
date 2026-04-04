import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fuel_station.dart';
import '../providers/fuel_provider.dart';
import '../services/firebase_service.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationId;
  const StationDetailScreen({super.key, required this.stationId});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FuelStatus _selectedStatus = FuelStatus.open;
  int _queueMinutes = 0;
  final TextEditingController _noteController = TextEditingController();
  Map<String, bool> _fuelAvailability = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'ယခုလေးတင်';
  }

  @override
  Widget build(BuildContext context) {
    final station = Provider.of<FuelProvider>(context).getStationById(widget.stationId);
    if (station == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('ရှာမတွေ့ပါ')));

    return Scaffold(
      appBar: AppBar(
        title: Text(station.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          tabs: const [Tab(text: 'အခြေအနေ'), Tab(text: 'သတင်းများ')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStatusTab(station), _buildReportsTab()],
      ),
    );
  }

  Widget _buildStatusTab(FuelStation station) {
    // 🔥 Default Checked Logic: ဆိုင်မှာရှိတဲ့ဆီကို အလိုအလျောက် အမှန်ခြစ်ထားခြင်း
    if (_fuelAvailability.isEmpty) {
      _fuelAvailability = Map<String, bool>.fromIterables(
        station.availableFuels.keys,
        List.filled(station.availableFuels.length, true),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📢 ယခုအခြေအနေ သတင်းပို့ရန်', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('ဘယ်ဆီတွေ ရနိုင်သလဲ?'),
          Wrap(
            spacing: 8,
            children: station.availableFuels.keys.map((f) => FilterChip(
              label: Text(f),
              selected: _fuelAvailability[f] ?? false,
              onSelected: (val) => setState(() => _fuelAvailability[f] = val),
            )).toList(),
          ),
          const Divider(height: 32),
          ...FuelStatus.values.where((s) => s != FuelStatus.unknown).map((s) => RadioListTile<FuelStatus>(
            title: Text('${s.emoji} ${s.label}'),
            value: s,
            groupValue: _selectedStatus,
            onChanged: (val) => setState(() => _selectedStatus = val!),
          )),
          const SizedBox(height: 16),
          Text('တန်းစီချိန်: ~$_queueMinutes မိနစ်'),
          Slider(
            value: _queueMinutes.toDouble(),
            min: 0, max: 120, divisions: 12,
            onChanged: (v) => setState(() => _queueMinutes = v.toInt()),
          ),
          TextField(controller: _noteController, decoration: const InputDecoration(hintText: 'မှတ်ချက်', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : () async {
                setState(() => _submitting = true);
                await FirebaseService.submitReport(
                  stationId: widget.stationId,
                  status: _selectedStatus,
                  queueMinutes: _queueMinutes,
                  fuelAvailability: _fuelAvailability,
                  note: _noteController.text,
                );
                setState(() => _submitting = false);
                _tabController.animateTo(1); // သတင်းပို့ပြီးရင် ဒုတိယ Tab ကို ပြောင်းရန်
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('သတင်းပို့မည်', style: TextStyle(color: Colors.white)),
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
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('သတင်းများ မရှိသေးပါ'));
        
        final reports = snapshot.data!;
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(r.userName?[0] ?? 'U')),
                title: Text(r.userName ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${r.status.emoji} ${r.status.label} (${r.queueMinutes}m queue)\n${r.note ?? ""}'),
                trailing: Text(_timeAgo(r.reportedAt), style: const TextStyle(fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }
}
