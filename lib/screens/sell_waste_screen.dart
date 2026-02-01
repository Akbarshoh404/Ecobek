import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/waste_item.dart';

const Color kPrimaryGreen     = Color(0xFF4CAF50);
const Color kDarkGreen        = Color(0xFF2E7D32);
const Color kLightGreenBg     = Color(0xFFE8F5E9);
const Color kTextDark         = Color(0xFF212121);
const Color kTextHint         = Color(0xFF757575);
const Color kSurfaceWhite     = Colors.white;
const Color kBorderGreen      = Color(0xFF81C784);

class SellWasteScreen extends StatefulWidget {
  const SellWasteScreen({super.key});

  @override
  State<SellWasteScreen> createState() => _SellWasteScreenState();
}

class _SellWasteScreenState extends State<SellWasteScreen> {
  int _selectedIndex = 2;
  String _selectedCategory = '';

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onCategoryTapped(String category) {
    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          backgroundColor: kSurfaceWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 40, 8, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kPrimaryGreen, size: 30),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Sell your Waste',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_rounded, color: kPrimaryGreen, size: 38),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: kSurfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderGreen, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search scrap rate',
                  hintStyle: TextStyle(color: kTextHint, fontSize: 16.5),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Icon(Icons.search_rounded, color: kPrimaryGreen, size: 28),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 94,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterCategoryButton(
                  icon: Icons.grid_view_rounded,
                  label: 'view all',
                  selected: _selectedCategory == '',
                  onTap: () => _onCategoryTapped(''),
                ),
                _FilterCategoryButton(
                  icon: Icons.local_drink_outlined,
                  label: 'Plastic',
                  selected: _selectedCategory == 'Plastic',
                  onTap: () => _onCategoryTapped('Plastic'),
                ),
                _FilterCategoryButton(
                  icon: Icons.recycling_outlined,
                  label: 'Metal',
                  selected: _selectedCategory == 'Metal',
                  onTap: () => _onCategoryTapped('Metal'),
                ),
                _FilterCategoryButton(
                  icon: Icons.wine_bar_outlined,
                  label: 'Glass',
                  selected: _selectedCategory == 'Glass',
                  onTap: () => _onCategoryTapped('Glass'),
                ),
                _FilterCategoryButton(
                  icon: Icons.bolt_outlined,
                  label: 'Electronic',
                  selected: _selectedCategory == 'Electronic',
                  onTap: () => _onCategoryTapped('Electronic'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('waste_items').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                if (data == null) {
                  return const Center(child: Text('No products found'));
                }

                List<WasteItem> items = data.entries.map((e) {
                  return WasteItem.fromMap(e.value as Map<dynamic, dynamic>, e.key as String);
                }).toList();

                if (_selectedCategory.isNotEmpty) {
                  items = items.where((item) => item.type == _selectedCategory).toList();
                }

                items.sort((a, b) => a.name.compareTo(b.name));

                if (items.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _WasteItemCard(item: items[index]),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _WasteItemCard extends StatelessWidget {
  final WasteItem item;

  const _WasteItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderGreen, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: CachedNetworkImage(
                      imageUrl: item.img,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, size: 38, color: kPrimaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kTextDark)),
                      const SizedBox(height: 4),
                      Text('₹${item.price} / ${item.unit}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkGreen)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                    onPressed: () {},
                    constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterCategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterCategoryButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: selected ? kDarkGreen : kLightGreenBg,
        borderRadius: BorderRadius.circular(12),
        elevation: selected ? 3 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 82,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 34, color: selected ? kSurfaceWhite : kPrimaryGreen),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? kSurfaceWhite : kTextDark,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFloatingNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: kSurfaceWhite,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 16, offset: const Offset(0, 8)),
                BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIconButton(icon: Icons.home_outlined, isSelected: currentIndex == 0, onTap: () => onTap(0)),
                _NavIconButton(icon: Icons.location_on_outlined, isSelected: currentIndex == 1, onTap: () => onTap(1)),
                const SizedBox(width: 72),
                _NavIconButton(icon: Icons.bar_chart_outlined, isSelected: currentIndex == 3, onTap: () => onTap(3)),
                _NavIconButton(icon: Icons.storefront_outlined, isSelected: currentIndex == 4, onTap: () => onTap(4)),
              ],
            ),
          ),
          Positioned(
            top: -28,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: kPrimaryGreen.withOpacity(0.5), blurRadius: 18, spreadRadius: 3, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: kSurfaceWhite, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: isSelected ? kPrimaryGreen : kTextHint, size: 28),
      onPressed: onTap,
    );
  }
}