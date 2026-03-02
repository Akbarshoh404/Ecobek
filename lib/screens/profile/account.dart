import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'editProfile.dart';
import 'recDetails.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  String _ageText(int? dobMs) {
    if (dobMs == null) return "Age - N/A year";
    final d = DateTime.fromMillisecondsSinceEpoch(dobMs);
    final now = DateTime.now();
    int age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
      age--;
    }
    if (age < 0) age = 0;
    return "Age - $age year";
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
        title: const Text("Account", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: uid == null
          ? const Center(child: Text("Not signed in"))
          : StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('users/$uid').onValue,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snap.data!.snapshot.value;
          final Map<String, dynamic> data = value is Map
              ? Map<String, dynamic>.from(value as Map)
              : <String, dynamic>{};

          final name = (data['name'] as String?)?.trim();
          final photo = data['photo'] as String?;
          final gender = (data['gender'] as String?)?.trim();

          // We store DOB as milliseconds in Realtime DB: dateMs
          final dobMsRaw = data['dateMs'];
          final int? dobMs = dobMsRaw is int
              ? dobMsRaw
              : (dobMsRaw is num ? dobMsRaw.toInt() : null);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: (photo != null && photo.isNotEmpty)
                            ? NetworkImage(photo)
                            : null,
                        child: (photo == null || photo.isEmpty)
                            ? const Icon(Icons.person, size: 30, color: Colors.black54)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name?.isNotEmpty == true ? name! : "N/A",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Gender - ${gender?.isNotEmpty == true ? gender! : "N/A"}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _ageText(dobMs),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _item(
                  icon: Icons.info_outline,
                  title: "General info",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecDetailsPage()),
                  ),
                ),
                const Divider(height: 1),
                _item(
                  icon: Icons.edit_outlined,
                  title: "Edit Profile",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
