import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Backend is only needed for episodes now.
  static const String baseUrl = "https://anime-ai-backend.onrender.com";

  // 🔁 STREAMING SITE — Update this single constant if the streaming site changes or goes down.
  // Current site: HiAnime (https://hianime.ws)
  static const String kStreamingSiteBaseUrl = 'https://anikai.to';

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

  /// Maps a raw Jikan anime object to the full details shape the details page expects.
  static Map<String, dynamic> _formatJikanDetails(dynamic item) {
    final images = item['images'] as Map<String, dynamic>?;
    final webp = images?['webp'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;
    final imageUrl = webp?['large_image_url'] as String? ??
        jpg?['large_image_url'] as String? ??
        '';

    final trailer = item['trailer'] as Map<String, dynamic>?;
    final youtubeId = trailer?['youtube_id'] as String? ?? '';

    return {
      'title': item['title'] ?? '',
      'synopsis': item['synopsis'] ?? '',
      'genres': ((item['genres'] as List?) ?? [])
          .map((g) => g['name'] as String)
          .toList(),
      'rating': item['score'],
      'episodes': item['episodes'],
      'status': item['status'] ?? '',
      'year': item['year'],
      'image_url': imageUrl,
      'trailer_youtube_id': youtubeId,
    };
  }

  /// Fetches full anime metadata from Jikan v4 for the given title.
  /// Returns a map with keys: title, synopsis, genres, rating, episodes,
  /// status, year, image_url, trailer_youtube_id.
  /// Returns {} on empty results or network errors.
  static Future<Map<String, dynamic>> fetchAnimeDetails(String title) async {
    try {
      final encoded = Uri.encodeComponent(title);
      final response = await http
          .get(Uri.parse('https://api.jikan.moe/v4/anime?q=$encoded&limit=1'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List?;
        if (list == null || list.isEmpty) return {};
        return _formatJikanDetails(list[0]);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Calls the backend's /anime/enrich endpoint for enriched Jikan metadata.
  /// Returns {} on failure or if the response contains an "error" key.
  static Future<Map<String, dynamic>> fetchAnimeEnrich(String title) async {
    try {
      final encoded = Uri.encodeComponent(title);
      final response = await http
          .get(Uri.parse('$baseUrl/anime/enrich?title=$encoded'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && !data.containsKey('error')) {
          return data;
        }
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}
