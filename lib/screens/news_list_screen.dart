import 'package:ekobek/screens/sell_waste_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import '../widgets/custom_floating_nav_bar.dart';
import '../constants/colors.dart' hide kPrimaryGreen;
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  int _currentIndex = 3;

  final TextEditingController _searchController = TextEditingController();

  List<NewsModel> _news = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNewsOnce();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadNewsOnce() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('news').get();

      if (!snapshot.exists || snapshot.value == null) {
        setState(() {
          _isLoading = false;
          _error = 'No news found in database';
        });
        return;
      }

      final data = snapshot.value;

      List<NewsModel> loaded = [];

      if (data is List) {
        loaded = data
            .whereType<Map>()
            .map((item) => NewsModel.fromMap(item))
            .where((n) => n.title.isNotEmpty)
            .toList();
      } else if (data is Map) {
        loaded = data.values
            .whereType<Map>()
            .map((item) => NewsModel.fromMap(item))
            .where((n) => n.title.isNotEmpty)
            .toList();
      }

      if (mounted) {
        setState(() {
          _news = loaded;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<NewsModel> get _filteredNews {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _news;
    return _news.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SellWasteScreen()),
                    );
                  },
                ),
                title: const Text(
                  'Eco News',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded, color: kPrimaryGreen),
                    onPressed: () {},
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Eco News...',
                    prefixIcon: const Icon(Icons.search, color: kPrimaryGreen),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
                    : _news.isEmpty
                    ? const Center(child: Text('No news found'))
                    : _filteredNews.isEmpty
                    ? const Center(child: Text('No matching news'))
                    : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).padding.bottom + 100,
                  ),
                  itemCount: _filteredNews.length,
                  itemBuilder: (context, index) {
                    final news = _filteredNews[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailScreen(
                              news: news,
                              currentIndex: _currentIndex,
                            ),
                          ),
                        );
                      },
                      child: NewsCard(news: news),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomFloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}