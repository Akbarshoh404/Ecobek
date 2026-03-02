import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/custom_floating_nav_bar.dart';
import '../constants/colors.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;
  final int currentIndex;

  const NewsDetailScreen({
    super.key,
    required this.news,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAIN CONTENT
          Stack(
            children: [
              Image.network(
                news.imageUrl,
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.65,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF7E6),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: ListView(
                      controller: controller,
                      children: [
                        Text(
                          news.category,
                          style: const TextStyle(
                            color: kPrimaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          news.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          // 🌿 FLOATING NAV BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomFloatingNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                // navigation logic can be added later
              },
            ),
          ),
        ],
      ),
    );
  }
}
