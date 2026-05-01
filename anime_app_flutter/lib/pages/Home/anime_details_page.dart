// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../widgets/cross_origin_image.dart';
import '../../main.dart';
import 'anime_player_page.dart';

class AnimeDetailsPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String rating;

  AnimeDetailsPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rating,
  });

  final Map<String, String> trailerMap = {
    "Jujutsu Kaisen": "https://www.youtube.com/watch?v=MPfZhgLiK6w",
    "Sakamoto Days": "https://www.youtube.com/watch?v=9TbmxbckSjE",
    "Solo Leveling Season 2": "https://www.youtube.com/watch?v=byJ7pxxhaDY",
  };

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyBg = isDark ? const Color(0xFF0d1b4b) : Colors.white;
    final descColor = isDark ? Colors.white60 : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 125, 125, 255),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Stack(
              children: [
                CrossOriginImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  color: Colors.black.withOpacity(0.3),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow),
                      const SizedBox(width: 5),
                      Text(
                        rating,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimePlayerPage(
                              title: title,
                              videoUrl: trailerMap[title] ?? "",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        "Watch Now",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 125, 125, 255),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Description",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This anime is recommended based on your mood. Enjoy watching!",
                    style: TextStyle(color: descColor),
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
