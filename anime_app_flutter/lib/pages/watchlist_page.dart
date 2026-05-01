// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../main.dart';

class WatchlistPage extends StatelessWidget {
  final Function(int)? onTabChange;

  const WatchlistPage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : const Color.fromARGB(255, 129, 126, 126);
    final iconBg = isDark
        ? const Color.fromARGB(255, 125, 125, 255).withOpacity(0.2)
        : Colors.blue.withOpacity(0.1);
    final iconColor = isDark ? const Color.fromARGB(255, 160, 160, 255) : Colors.blue;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0x990d1b4b) : null,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Watchlist',
              style: TextStyle(
                fontFamily: 'Naruto',
                color: const Color.fromARGB(255, 125, 125, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '0 anime saved',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey,
            width: 0.3,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bookmark_border, size: 45, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Your watchlist is empty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon to save anime',
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onTabChange?.call(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 125, 125, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Explore Anime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
