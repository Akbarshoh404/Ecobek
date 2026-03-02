import 'package:ekobek/screens/sell_waste_screen.dart';
import 'package:flutter/material.dart';
import '/auth/auth_service.dart';
import '/auth/entrancePage.dart';
import 'account.dart';
import 'recDetails.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF86C340);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: green),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SellWasteScreen()),
                  (route) => false,
            );
          },
        ),
        title: const Text(
          "User Profile",
          style: TextStyle(color: green, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _tile(
            icon: Icons.person_outline,
            title: "Account",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            ),
          ),
          _divider(),
          _tile(
            icon: Icons.receipt_long_outlined,
            title: "Recurring Details",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecDetailsPage()),
            ),
          ),
          _divider(),
          _tile(icon: Icons.email_outlined, title: "Contact Us", onTap: () => _comingSoon(context)),
          _divider(),
          _tile(icon: Icons.description_outlined, title: "Terms & Conditions", onTap: () => _comingSoon(context)),
          _divider(),
          _tile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", onTap: () => _comingSoon(context)),
          _divider(),
          _tile(icon: Icons.info_outline, title: "About", onTap: () => _comingSoon(context)),
          _divider(),
          _tile(icon: Icons.location_on_outlined, title: "Location", onTap: () => _comingSoon(context)),
          _divider(),
          _tile(
            icon: Icons.logout,
            title: "Logout",
            onTap: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const EntrancePage()),
                      (_) => false,
                );
              }
            },
          ),
          _divider(),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF86C340)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
