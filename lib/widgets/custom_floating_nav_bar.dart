import 'package:ekobek/models/home_shell.dart';
import 'package:ekobek/screens/news_list_screen.dart';
import 'package:ekobek/screens/profile/userProfile.dart';
import 'package:ekobek/screens/scanner_screen.dart';
import 'package:ekobek/screens/sell_waste_screen.dart';
import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

typedef ValueChanged<T> = void Function(T value);

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIconButton(
                  icon: Icons.home_outlined,
                  isSelected: currentIndex == 5,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SellWasteScreen(),
                      ),
                    );
                  },
                ),
                _NavIconButton(
                  icon: Icons.person,
                  isSelected: currentIndex == 1,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HomeShell(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 72),
                _NavIconButton(
                  icon: Icons.newspaper,
                  isSelected: currentIndex == 3,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NewsListScreen(),
                      ),
                    );
                  },
                ),
                _NavIconButton(
                  icon: Icons.chat,
                  isSelected: currentIndex == 4,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
          Positioned(
            top: -28,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ScannerScreen(),
                  ),
                );
              },
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGreen.withOpacity(0.5),
                      blurRadius: 18,
                      spreadRadius: 3,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: kSurfaceWhite,
                  size: 36,
                ),
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

  const _NavIconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? kPrimaryGreen : kTextHint,
        size: 28,
      ),
      onPressed: onTap,
    );
  }
}
