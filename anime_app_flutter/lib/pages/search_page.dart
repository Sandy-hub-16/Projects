import 'package:flutter/material.dart';
import '../main.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : const Color.fromARGB(255, 129, 126, 126);
    final searchBg = isDark ? const Color(0xFF1a2a5e) : Colors.grey[200]!;
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0x990d1b4b) : null,
        toolbarHeight: 70,
        title: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: searchBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Search anime...',
              hintStyle: TextStyle(color: subtitleColor),
              prefixIcon: Icon(Icons.search, color: subtitleColor),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            ),
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey,
            width: 0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.trending_up, color: brandColor, size: 24),
                const SizedBox(width: 6),
                Text(
                  'Popular Searches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                'Action', 'Adventure', 'Sci-Fi', 'Fantasy', 'Comedy', 'Romance',
              ].map((g) => _genreButton(g, isDark)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genreButton(String genre, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1a2a5e) : Colors.white,
          foregroundColor: isDark ? Colors.white70 : Colors.black87,
          elevation: 0,
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey,
            width: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(genre, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
