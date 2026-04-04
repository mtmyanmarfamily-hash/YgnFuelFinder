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
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    if (diff.inSeconds >= 1) return '${diff.inSeconds}s';
    
    return 'ယခုလေးတင်';
  }

  @override
  Widget build(BuildContext context) {
    final station = Provider.of<FuelProvider>(context).getStationById(widget.stationId);
    if (station == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('ရှာမတွေ့ပါ')));

    if (_fuelAvailability.isEmpty) {
      _fuelAvailability = Map<String, bool>.from(station.availableFuels);
      _selectedStatus = station.status == FuelStatus.unknown ? FuelStatus.open : station.status;
      _queueMinutes = station.queueMinutes;
    }

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
        children: [
          _buildStatusTab(station),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildStatusTab(FuelStation station) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Updated Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'နောက်ဆုံးရရှိထားသော အခြေအနေ',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${station.status.emoji} ${station.status.label}',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: station.status == FuelStatus.open ? Colors.green[700] : 
                               station.status == FuelStatus.busy ? Colors.orange[800] : Colors.red[700],
                      ),
                    ),
                    Text(
                      _timeAgo(station.lastUpdated),
                      style: TextStyle(color: Colors.blueGrey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('တန်းစီချိန်: ~${station.queueMinutes} မိနစ်', style: const TextStyle(fontSize: 15)),
                if (station.availableFuels.isNotEmpty)
                  Padding(
                    // 🔥 FIXED ERROR: EdgeInsets.top(4.0) -> EdgeInsets.only(top: 4.0)
                    padding: const EdgeInsets.only(top: 4.0), 
                    child: Text(
                      'ရရှိနိုင်သောဆီ: ${station.availableFuels.entries.where((e) => e.value).map((e) => e.key).join(", ")}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
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
            activeColor: Colors.green[700],
            onChanged: (v) => setState(() => _queueMinutes = v.toInt()),
          ),
          
          TextField(
            controller: _noteController, 
            decoration: const InputDecoration(
              hintText: 'မှတ်ချက် (ဥပမာ - ဆီကုန်ခါနီးနေပြီ)', 
              border: OutlineInputBorder()
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
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
                _noteController.clear();
                _tabController.animateTo(1); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _submitting 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('သတင်းပို့မည်', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return StreamBuilder<List<UserReport>>(
      stream: FirebaseService.getReportsStream(widget.stationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('သတင်းများ မရှိသေးပါ'));
        
        final reports = snapshot.data!;
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            final fuels = r.fuelAvailability.entries.where((e) => e.value).map((e) => e.key).join(', ');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: r.status == FuelStatus.open ? Colors.green[100] : 
                                  r.status == FuelStatus.busy ? Colors.orange[100] : Colors.red[100],
                  child: Text(r.status.emoji),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.status.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_timeAgo(r.reportedAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fuels.isNotEmpty) Text('ရရှိနိုင်သောဆီ: $fuels'),
                    Text('တန်းစီချိန်: ${r.queueMinutes} မိနစ်'),
                    if (r.note != null && r.note!.isNotEmpty) 
                      Padding(
                        // 🔥 FIXED ERROR: EdgeInsets.top(4.0) -> EdgeInsets.only(top: 4.0)
                        padding: const EdgeInsets.only(top: 4.0), 
                        child: Text('💬 ${r.note}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
