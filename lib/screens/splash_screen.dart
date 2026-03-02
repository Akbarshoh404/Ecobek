import 'package:ekobek/auth/EntrancePage.dart';
import 'package:ekobek/screens/sell_waste_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// 👉 IMPORT YOUR HOME SCREEN FILE
import '../app.dart';


void main() {
  runApp(const EcoShiftApp());
}

class EcoShiftApp extends StatelessWidget {
  const EcoShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoShift',
      theme: ThemeData(
        primaryColor: const Color(0xFF86B049),
        scaffoldBackgroundColor: const Color(0xFFF9FFF2),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ────────────────────────────────────────────────
// Splash Screen
// ────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco,
                size: 150,
                color: Color(0xFF86B049),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'EcoShift',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E4D2E),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Onboarding Screen
// ────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Join the Green Movement",
      "subtitle":
      "Contribute to sustainability with easy, effective recycling.",
      "image": "assets/images/img.png",
    },
    {
      "title": "Nearby Recycling Stations",
      "subtitle":
      "Find the nearest recycling drop-off points with real-time updates.",
      "image": "assets/images/img1.png",
    },
    {
      "title": "Smart Waste Identification",
      "subtitle":
      "Instantly identify your waste and get proper disposal instructions with AI.",
      "image": "assets/images/img2.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _onboardingData.length,
                itemBuilder: (_, index) => OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  subtitle: _onboardingData[index]["subtitle"]!,
                  imagePath: _onboardingData[index]["image"]!,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _pageController
                        .jumpToPage(_onboardingData.length - 1),
                    child: const Text("Skip"),
                  ),
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == i ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? const Color(0xFF86B049)
                              : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  _currentPage == _onboardingData.length - 1
                      ? ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const EntrancePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF86B049),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Get Started"),
                  )
                      : CircleAvatar(
                    backgroundColor: const Color(0xFF86B049),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward,
                          color: Colors.white),
                      onPressed: () {
                        _pageController.nextPage(
                          duration:
                          const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Onboarding Content Widget
// ────────────────────────────────────────────────
class OnboardingContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height * 0.42,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
