import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import '../../services/api_service.dart';

class AnimeDetailsPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String rating;

  const AnimeDetailsPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.fromARGB(255, 125, 125, 255),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 COVER IMAGE
            Stack(
              children: [
                CachedNetworkImage(
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ⭐ RATING
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 5),
                      Text(
                        rating,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ▶ WATCH BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 🔥 For now: simulate play
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Play Anime"),
                            content: Text("Streaming feature coming soon 🎬"),
                          ),
                        );
                      },
                      icon: Icon(Icons.play_arrow),
                      label: Text("Watch Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 125, 125, 255),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📖 DESCRIPTION (placeholder)
                  Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "This anime is recommended based on your mood. Enjoy watching!",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}