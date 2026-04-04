import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
// Added the language filter import here
import '../utils/language_filter.dart';

class SuggestStationScreen extends StatefulWidget {
  const SuggestStationScreen({super.key});

  @override
  State<SuggestStationScreen> createState() => _SuggestStationScreenState();
}

class _SuggestStationScreenState extends State<SuggestStationScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final List<String> _selectedFuelTypes = [];
  bool _submitting = false;
  bool _submitted = false;

  final List<String> _allFuelTypes = ['92', '95', 'PD', 'D'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဆိုင်အသစ် အကြံပြုရန်'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _submitted ? _buildSuccessView() : _buildForm(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text('အကြံပြုချက် ပို့ပြီးပါပြီ!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('စစ်ဆေးပြီးနောက် app ထဲ ထည့်သွင်းပေးပါမည်',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('ပြန်သွားမည်'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),
          _buildTextField('ဆိုင်အမည် *', _nameController, 'ဥပမာ - Star High ဆီဆိုင်', Icons.local_gas_station),
          const SizedBox(height: 16),
          _buildTextField('လိပ်စာ / ရပ်ကွက် *', _addressController, 'ဥပမာ - စက်ဆန်းလမ်း၊ မင်္ဂလာဒုံ', Icons.location_on, maxLines: 2),
          const SizedBox(height: 16),
          const Text('ဘာဆီတွေ ရသည် *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildFuelChips(),
          const SizedBox(height: 16),
          _buildLocationHint(),
          const SizedBox(height: 16),
          _buildTextField('မှတ်ချက် / Coordinates', _noteController, 'ဥပမာ - 16.9163, 96.1623', null, maxLines: 3),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 8),
          const Center(child: Text('* စစ်ဆေးပြီးမှ app ထဲ ထည့်ပေးပါမည်', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
      child: Row(children: [
        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
        const SizedBox(width: 8),
        const Expanded(child: Text('ဆိုင်တည်နေရာ Google Maps မှ latitude/longitude ကူးယူပေးနိုင်ပါသည်', style: TextStyle(fontSize: 12))),
      ]),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, IconData? icon, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ]);
  }

  Widget _buildFuelChips() {
    return Wrap(
      spacing: 8,
      children: _allFuelTypes.map((f) {
        final sel = _selectedFuelTypes.contains(f);
        return FilterChip(
          label: Text(f, style: TextStyle(fontWeight: FontWeight.bold, color: sel ? Colors.green[800] : null)),
          selected: sel,
          onSelected: (v) => setState(() => v ? _selectedFuelTypes.add(f) : _selectedFuelTypes.remove(f)),
        );
      }).toList(),
    );
  }

  Widget _buildLocationHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📍 Google Maps မှ နေရာပေးနည်း', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('1. Maps ဖွင့်၊ ဆိုင်နေရာကို ဖိနှိပ်ပါ။\n2. ပေါ်လာသော ဂဏန်းအတွဲကို ကူးပါ။ (16.xx, 96.xx)\n3. မှတ်ချက်ထဲတွင် ထည့်ပေးပါ။', style: TextStyle(fontSize: 12, height: 1.5)),
      ]),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canSubmit() && !_submitting ? _submit : null,
        icon: _submitting
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send),
        label: Text(_submitting ? 'ပို့နေသည်...' : 'အကြံပြုချက် တင်မည်'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  bool _canSubmit() => _nameController.text.trim().isNotEmpty && _addressController.text.trim().isNotEmpty && _selectedFuelTypes.isNotEmpty;

  Future<void> _submit() async {
    // --- Added Language Filter Check ---
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final note = _noteController.text.trim();

    // Check all three text fields for profanity
    if (MyanmarLanguageFilter.containsProfanity(name) || 
        MyanmarLanguageFilter.containsProfanity(address) || 
        MyanmarLanguageFilter.containsProfanity(note)) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('မဆီလျော်သော စကားလုံးများ ပါဝင်နေပါသည်။ ကျေးဇူးပြု၍ ယဉ်ကျေးစွာ ရေးသားပေးပါ။'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop the function here
    }
    // -----------------------------------

    setState(() => _submitting = true);
    try {
      await FirebaseService.suggestNewStation({
        'name': name,
        'address': address,
        'fuelTypes': _selectedFuelTypes,
        'coordinates': note, 
      });

      if (mounted) setState(() { _submitting = false; _submitted = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e. အင်တာနက် စစ်ဆေးပါ')),
        );
      }
    }
  }
}
