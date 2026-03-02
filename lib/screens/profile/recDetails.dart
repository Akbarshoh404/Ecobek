import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RecDetailsPage extends StatelessWidget {
  const RecDetailsPage({super.key});

  String _fmtDob(int? dobMs) {
    if (dobMs == null) return "N/A";
    final d = DateTime.fromMillisecondsSinceEpoch(dobMs);
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${d.day.toString().padLeft(2, '0')} - ${months[d.month - 1]} - ${d.year}";
  }

  String _val(dynamic v) {
    if (v == null) return "N/A";
    if (v is String) {
      final t = v.trim();
      return t.isEmpty ? "N/A" : t;
    }
    return v.toString();
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF86C340);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          "Recurring Details",
          style: TextStyle(color: green, fontWeight: FontWeight.w800),
        ),
      ),
      body: uid == null
          ? const Center(child: Text("Not signed in"))
          : StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('users/$uid').onValue,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Error: ${snap.error}"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final value = snap.data!.snapshot.value;
          final Map<String, dynamic> data = value is Map
              ? Map<String, dynamic>.from(value as Map)
              : <String, dynamic>{};

          final dobMs = _asInt(data['dateMs']);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _field("Full Name", _val(data['name'])),
                const SizedBox(height: 12),
                _field("Email", _val(data['email'])),
                const SizedBox(height: 12),
                _field("Business Name", _val(data['businessName'])),
                const SizedBox(height: 12),
                _field("GST No (optional)", _val(data['gstNo'])),
                const SizedBox(height: 12),
                _field("Date of Birth", _fmtDob(dobMs)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Register your business (TODO)")),
                      );
                    },
                    child: const Text("Register your business"),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: value,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
