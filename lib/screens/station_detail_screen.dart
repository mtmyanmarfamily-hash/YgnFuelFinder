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

  Future<void> _submitReport() async {
    setState(() => _submitting = true);
    try {
      await FirebaseService.submitReport(
        stationId: widget.stationId,
        status: _selectedStatus,
        queueMinutes: _queueMinutes,
        fuelAvailability: _fuelAvailability,
        note: _noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('သတင်းပို့ပြီးပါပြီ။ ကျေးဇူးတင်ပါတယ်!')),
        );
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final station = Provider.of<FuelProvider>(context).getStationById(widget.stationId);

    if (station == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('ဆိုင်အချက်အလက် ရှာမတွေ့ပါ')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(station.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // 🔥 အခြေအနေ/သတင်းများ စာသားကို အဖြူရောင် အတောက်ဆုံးထားခြင်း
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          tabs: const [
            Tab(text: 'အခြေအနေ'),
            Tab(text: 'သတင်းများ'),
          ],
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
          const Text('📢 ယခုအခြေအနေ သတင်းပို့ရန်', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
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
          ...FuelStatus.values.map((s) => RadioListTile<FuelStatus>(
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
            label: '$_queueMinutes မိနစ်',
            onChanged: (v) => setState(() => _queueMinutes = v.toInt()),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'မှတ်ချက် (ဥပမာ- ဆီကားရောက်နေသည်)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _submitting 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('သတင်းပို့မည်', style: TextStyle(color: Colors.white, fontSize: 16)),
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
            Color statusColor;
            switch (r.status) {
              case FuelStatus.open: statusColor = Colors.green[600]!; break;
              case FuelStatus.busy: statusColor = Colors.orange[600]!; break;
              case FuelStatus.closed: statusColor = Colors.red[600]!; break;
              default: statusColor = Colors.grey[600]!;
            }

            final availableFuels = r.fuelAvailability.entries
                .where((e) => e.value == true)
                .map((e) => e.key)
                .join(', ');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${r.status.emoji} ${r.status.label}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(_timeAgo(r.reportedAt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (availableFuels.isNotEmpty)
                          Text('ရရှိနိုင်သောဆီ: $availableFuels', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('တန်းစီချိန်: ${r.queueMinutes} မိနစ်'),
                        if (r.note != null && r.note!.isNotEmpty)
                          Text('💬 ${r.note!}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
