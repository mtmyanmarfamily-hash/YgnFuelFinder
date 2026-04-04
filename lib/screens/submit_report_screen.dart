import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fuel_station.dart';
import '../services/firebase_service.dart';

class SubmitReportScreen extends StatefulWidget {
  final FuelStation station;

  const SubmitReportScreen({super.key, required this.station});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _noteController = TextEditingController();
  
  FuelStatus _selectedStatus = FuelStatus.available;
  int _queueMinutes = 0; 
  
  late Map<String, bool> _availability;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _availability = Map<String, bool>.from(widget.station.availableFuels);
    if (_availability.isEmpty) {
      _availability = { for (var f in widget.station.fuelTypes) f : true };
    }
    _queueMinutes = widget.station.queueMinutes;
    _selectedStatus = widget.station.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('အခြေအနေ သတင်းပို့ရန်'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text("ဘယ်ဆီတွေ ရနိုင်သလဲ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // ဆီအမျိုးအစားများ
            Wrap(
              spacing: 8,
              children: widget.station.fuelTypes.map((fuel) {
                return FilterChip(
                  label: Text(fuel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  selected: _availability[fuel] ?? false,
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green[700],
                  onSelected: (val) => setState(() => _availability[fuel] = val),
                );
              }).toList(),
            ),

            const Divider(height: 30),

            // ဆိုင်၏ အခြေအနေ
            const Text("ဆိုင်၏ လက်ရှိအခြေအနေ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...FuelStatus.values.where((s) => s != FuelStatus.unknown).map((status) {
              return RadioListTile<FuelStatus>(
                title: Text('${status.emoji} ${status.label}'),
                value: status,
                groupValue: _selectedStatus,
                activeColor: Colors.green[700],
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val!;
                    // ဆီမရပါက Slider အတွက် queue time ကို ၀ သို့ သတ်မှတ်မည်
                    if (_selectedStatus == FuelStatus.unavailable) _queueMinutes = 0;
                  });
                },
              );
            }).toList(),

            // 🔥 Slider အပိုင်း (တန်းစီရှည် ဖြစ်နေမှသာ ပေါ်စေရန်)
            // ကုဒ်ထဲတွင် explicit check လုပ်ထားသဖြင့် Slider မပေါ်သည့်ပြဿနာ ရှင်းသွားပါမည်
            if (_selectedStatus == FuelStatus.longQueue || _selectedStatus == FuelStatus.available) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ခန့်မှန်းတန်းစီချိန်:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("$_queueMinutes မိနစ်", 
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: _queueMinutes.toDouble(),
                      min: 0,
                      max: 120,
                      divisions: 12, // ၁၀ မိနစ် တစ်ကွက်နှုန်း
                      label: "$_queueMinutes မိနစ်",
                      activeColor: Colors.green[700],
                      inactiveColor: Colors.green[100],
                      onChanged: (val) => setState(() => _queueMinutes = val.toInt()),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'မှတ်ချက် (Optional)',
                hintText: 'ဥပမာ- ဆီကားရောက်နေသည်',
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // သတင်းပို့မည် Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _handleReportSubmission,
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('သတင်းပို့မည်', 
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleReportSubmission() async {
    // Validation: ဆီရသည် သို့မဟုတ် တန်းစီရှည်ပါက အနည်းဆုံး ဆီတစ်မျိုး ရွေးရမည်
    if (_selectedStatus != FuelStatus.unavailable && !_availability.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ရရှိနိုင်သော ဆီအမျိုးအစားကို အရင်ရွေးချယ်ပေးပါ'))
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final report = UserReport(
      stationId: widget.station.id,
      status: _selectedStatus,
      queueMinutes: _queueMinutes,
      fuelType: 'Multiple',
      reportedAt: DateTime.now(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      fuelAvailability: _availability,
    );

    try {
      await FirebaseService.submitReport(report);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('သတင်းပို့ပြီးပါပြီ။ ကျေးဇူးတင်ပါတယ်!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
