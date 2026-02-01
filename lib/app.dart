import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/sell_waste_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekobek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekobek'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.chat, size: 32),
              label: const Text('Chat', style: TextStyle(fontSize: 20)),
              style: _bigButtonStyle(),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 32),
              label: const Text('Scanner', style: TextStyle(fontSize: 20)),
              style: _bigButtonStyle(),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.storefront, size: 32),
              label: const Text('Marketplace', style: TextStyle(fontSize: 20)),
              style: _bigButtonStyle(),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellWasteScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _bigButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      minimumSize: const Size(260, 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}