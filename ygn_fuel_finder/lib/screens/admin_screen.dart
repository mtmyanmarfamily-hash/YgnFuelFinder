import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdmin = false;
  bool _checkingAdmin = true;

  @override
  void initState() {
    super.initState();
    // FIXED: changed 'vync' to 'vsync' to fix the build error
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final doc = await _firestore.collection('admins').doc(user.email).get();
      if (doc.exists && doc.data()?['isAdmin'] == true) {
        if (mounted) {
          setState(() {
            _isAdmin = true;
            _checkingAdmin = false;
          });
        }
        return;
      }
    }
    
    if (mounted) {
      setState(() => _checkingAdmin = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🛑 Admin သာ ဝင်ရောက်ခွင့်ရှိသည်'))
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAdmin) return const Scaffold(body: Center(child: Text('Access Denied')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Admin Panel'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.add_location), text: 'အကြံပြုချက်များ'),
            Tab(icon: Icon(Icons.history), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSuggestionsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  // --- ဆိုင်အသစ် အကြံပြုချက်များကို ကြည့်ရန် ---
  Widget _buildSuggestionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('suggestions').orderBy('submittedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text("အကြံပြုချက် မရှိသေးပါ"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['name'] ?? 'Unknown Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['address']}\n${data['coordinates'] ?? ''}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteDocument('suggestions', docId),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // --- အသုံးပြုသူများ ပို့ထားသော Report များ ကြည့်ရန် ---
  Widget _buildReportsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').orderBy('reportedAt', descending: true).limit(50).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text("Reports မရှိသေးပါ"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final date = (data['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.orange),
                title: Text(data['note'] ?? 'No Note'),
                subtitle: Text("Time: ${DateFormat('dd/MM hh:mm a').format(date)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _deleteDocument('reports', docId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDocument(String collection, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: const Text('ဤအချက်အလက်ကို ဖျက်ပစ်မလား?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('မဖျက်ပါ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ဖျက်မည်', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection(collection).doc(id).delete();
    }
  }
}
