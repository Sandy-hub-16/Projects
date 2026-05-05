import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Backend is only needed for episodes now.
  static const String baseUrl = "https://YOUR-APP-NAME.onrender.com";

  static Future<List> fetchEpisodes(String title) async {
    final response = await http.get(
      Uri.parse('$baseUrl/episodes?title=$title'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  /// Fetches currently airing anime directly from Jikan — no backend needed.
  static Future<List> fetchRecentUpdates() async {
    final response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/seasons/now'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = (data['data'] as List?)?.take(10).toList() ?? [];
      return items.map(_formatJikan).toList();
    } else {
      throw Exception('Failed to load recent updates');
    }
  }

  /// Fetches top anime directly from Jikan — no backend needed.
  static Future<List> fetchTrending() async {
    final response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/top/anime'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = (data['data'] as List?)?.take(10).toList() ?? [];
      return items.map(_formatJikan).toList();
    } else {
      throw Exception('Failed to load trending');
    }
  }

  /// Normalises a raw Jikan anime object into the shape the UI expects.
  static Map<String, dynamic> _formatJikan(dynamic item) {
    final images = item['images'] as Map<String, dynamic>?;
    final webp = images?['webp'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;
    final imageUrl = webp?['large_image_url'] as String? ??
        jpg?['large_image_url'] as String? ??
        '';

    return {
      'title': item['title'] ?? '',
      'japanese_title': item['title_japanese'] ?? '',
      'rating': item['score'],
      'episodes': item['episodes'],
      'image_url': imageUrl,
      'genres': ((item['genres'] as List?) ?? [])
          .map((g) => g['name'] as String)
          .toList(),
    };
  }
}
