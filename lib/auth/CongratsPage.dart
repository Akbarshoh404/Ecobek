import 'package:ekobek/screens/sell_waste_screen.dart';
import 'package:flutter/material.dart';
import '../models/home_shell.dart';

class CongratulationsPage extends StatelessWidget {
  const CongratulationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF86C340);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: green, width: 2),
                ),
                child: const Icon(Icons.check, size: 44, color: green),
              ),
              const SizedBox(height: 18),
              const Text(
                "Congratulation",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: green),
              ),
              const SizedBox(height: 14),
              const Text(
                "Ready to make a positive impact today?\n\n"
                    "Thank you for joining the recycling revolution.\n"
                    "Together, we can make the planet greener and cleaner!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SellWasteScreen()),
                          (_) => false,
                    );
                  },
                  child: const Text("Continue"),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
