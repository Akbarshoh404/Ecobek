import 'package:flutter/material.dart';
import 'package:ekobek/screens/profile/userProfile.dart';
import '../screens/sell_waste_screen.dart';

import '../widgets/custom_floating_nav_bar.dart'; // make sure this is correct

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 2; // default selected page (profile)

  void _onNavTap(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _Placeholder(title: "Home"),
      const _Placeholder(title: "Location"),
      const UserProfilePage(),
      const _Placeholder(title: "Stats"),
      const SellWasteScreen(), // make your sell waste page appear here
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: _index,
        onTap: _onNavTap,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}