import 'package:http/http.dart' as http;
import 'dart:convert';
import 'groq_recommendation_service.dart';

class ApiService {
  // Backend is only needed for episodes now.
  static const String baseUrl = "https://anime-ai-backend.onrender.com";

  // 🔁 STREAMING SITE — Update this single constant if the streaming site changes or goes down.
  // Current site: HiAnime (https://hianime.ws)
  static const String kStreamingSiteBaseUrl = 'https://anikai.to';

  static Future<List> fetchEpisodes(String title) async {
    try {
      // Fetch episodes directly from Jikan — no backend needed.
      // Step 1: search for the anime to get its MAL ID
      final encoded = Uri.encodeComponent(title);
      final searchResp = await http
          .get(Uri.parse('https://api.jikan.moe/v4/anime?q=$encoded&limit=1'))
          .timeout(const Duration(seconds: 15));

      if (searchResp.statusCode != 200) return [];

      final searchData = json.decode(searchResp.body);
      final results = searchData['data'] as List?;
      if (results == null || results.isEmpty) return [];

      final malId = results[0]['mal_id'];

      // Step 2: fetch the episode list for that MAL ID
      final epsResp = await http
          .get(Uri.parse('https://api.jikan.moe/v4/anime/$malId/episodes'))
          .timeout(const Duration(seconds: 15));

      if (epsResp.statusCode != 200) return [];

      final epsData = json.decode(epsResp.body);
      final episodes = epsData['data'] as List?;
      if (episodes == null || episodes.isEmpty) return [];

      // Step 3: format into the shape the player page expects
      return episodes.map((ep) {
        final epNum = ep['mal_id'] ?? 0;
        final epTitle = ep['title'] as String?;
        return {
          'episode': epNum,
          'title': (epTitle != null && epTitle.isNotEmpty)
              ? epTitle
              : 'Episode $epNum',
          'video_url': '',
          'watch_url': '',
        };
      }).toList();
    } catch (_) {
      return [];
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

  /// Searches Jikan for anime matching [query].
  /// Returns at most 8 results normalised via [_formatJikan].
  /// Returns an empty list on any error or non-200 response.
  static Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      final encoded = Uri.encodeComponent(query);
      final response = await http
          .get(Uri.parse(
              'https://api.jikan.moe/v4/anime?q=$encoded&limit=8'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final items = (data['data'] as List?)?.take(8).toList() ?? [];
      return items
          .map<Map<String, dynamic>>((item) => _formatJikan(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Searches for anime matching [query] using Groq/OpenRouter AI directly
  /// (no backend required). Returns a list of [Recommendation] objects.
  /// Throws [SearchAIException] on failure.
  static Future<List<Recommendation>> searchAnimeAI(String query) async {
    final groqKey = GroqRecommendationService.groqApiKey;
    final orKey = GroqRecommendationService.openRouterApiKey;

    final prompt = _buildSearchPrompt(query);

    late final Object e1;
    try {
      final response = await _callGroqDirect(prompt, groqKey);
      return _parseAISearchResponse(response.body);
    } catch (err) {
      e1 = err;
    }

    if (orKey.isEmpty) throw SearchAIException(e1.toString());

    try {
      final response = await _callOpenRouterDirect(prompt, orKey);
      return _parseAISearchResponse(response.body);
    } catch (e2) {
      throw SearchAIException('Both Groq and OpenRouter failed: $e1 / $e2');
    }
  }

  static String _buildSearchPrompt(String query) {
    return '''You are an anime search assistant.
The user is searching for anime matching this description: "$query"

Return between 5 and 20 anime results depending on how many closely match the query.
Respond with ONLY a raw JSON array. No markdown, no code fences, no explanation.

Each item must follow this exact schema:
[
  {
    "title": "string",
    "japanese_title": "string",
    "rating": number or "N/A",
    "episodes": integer or "N/A",
    "image_url": "",
    "genres": ["string", ...]
  }
]

Rules:
- "image_url" must always be an empty string "".
- "rating" must be a number (e.g. 8.5) or the string "N/A".
- "episodes" must be an integer or the string "N/A".
- "genres" must be an array of genre strings.
- Output nothing except the JSON array.''';
  }

  static Future<http.Response> _callGroqDirect(
      String prompt, String apiKey) async {
    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'model': 'llama-3.1-8b-instant',
            'temperature': 0.7,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode == 200) return response;
    throw Exception('Groq error: ${response.statusCode} ${response.body}');
  }

  static Future<http.Response> _callOpenRouterDirect(
      String prompt, String apiKey) async {
    final response = await http
        .post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'model': 'openai/gpt-4o-mini',
            'temperature': 0.7,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode == 200) return response;
    throw Exception(
        'OpenRouter error: ${response.statusCode} ${response.body}');
  }

  static List<Recommendation> _parseAISearchResponse(String responseBody) {
    final envelope = json.decode(responseBody) as Map<String, dynamic>;
    final choices = envelope['choices'] as List<dynamic>;
    final content =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;

    // Strip markdown fences if present
    var trimmed = content.trim();
    if (trimmed.startsWith('```')) {
      final firstNewline = trimmed.indexOf('\n');
      if (firstNewline != -1) trimmed = trimmed.substring(firstNewline + 1);
      final closingFence = trimmed.lastIndexOf('```');
      if (closingFence != -1) trimmed = trimmed.substring(0, closingFence);
      trimmed = trimmed.trim();
    }
    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');
    if (start == -1 || end == -1) {
      throw const FormatException('No JSON array found in AI response');
    }
    final extracted = trimmed.substring(start, end + 1);

    final decoded = json.decode(extracted);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Recommendation.fromMap)
        .toList();
  }
}

/// Thrown by [ApiService.searchAnimeAI] when the backend returns a non-200
/// response.
class SearchAIException implements Exception {
  final String message;
  const SearchAIException(this.message);

  @override
  String toString() => 'SearchAIException: $message';
}
