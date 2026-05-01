// ignore_for_file: unused_field, unused_element
import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// A single anime recommendation returned by the Groq / OpenRouter AI model
/// and optionally enriched with a cover image from the Jikan API.
///
/// [imageUrl] is intentionally non-final so the Jikan enricher can update it
/// in place and trigger a targeted setState in the UI.
class Recommendation {
  final String title;
  final String japaneseTitle;
  final String rating;
  final String episodes;
  String imageUrl; // mutable — updated by Jikan enrichment
  final List<String> genres;

  Recommendation({
    required this.title,
    required this.japaneseTitle,
    required this.rating,
    required this.episodes,
    required this.imageUrl,
    required this.genres,
  });

  /// Constructs a [Recommendation] from a raw JSON map, applying safe defaults
  /// for any absent or null fields.
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      title: (map['title'] as String?) ?? 'Unknown Anime',
      japaneseTitle: (map['japanese_title'] as String?) ?? '',
      rating: map['rating']?.toString() ?? 'N/A',
      episodes: map['episodes']?.toString() ?? 'N/A',
      imageUrl: (map['image_url'] as String?) ?? '',
      genres:
          (map['genres'] as List?)?.whereType<String>().toList() ?? <String>[],
    );
  }
}

// ---------------------------------------------------------------------------
// Typed exception
// ---------------------------------------------------------------------------

/// Thrown by [GroqRecommendationService] when both the Groq API and the
/// OpenRouter fallback fail, or when a configuration error is detected.
class RecommendationException implements Exception {
  final String message;
  const RecommendationException(this.message);

  @override
  String toString() => 'RecommendationException: $message';
}

// ---------------------------------------------------------------------------
// Service (stub — implementation added in subsequent tasks)
// ---------------------------------------------------------------------------

/// Handles AI-powered anime recommendations by calling the Groq API directly
/// from Dart, with an OpenRouter fallback, in-memory caching, and async Jikan
/// image enrichment.
///
/// All methods are static; no instance is required.
class GroqRecommendationService {
  // Compile-time API keys — supplied via --dart-define at build/run time.
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY');

  // In-memory cache: emoji → recommendation list.
  static final Map<String, List<Recommendation>> _cache = {};

  // Private constructor — this class is not meant to be instantiated.
  GroqRecommendationService._();

  // -------------------------------------------------------------------------
  // Public API (stubs — filled in by subsequent tasks)
  // -------------------------------------------------------------------------

  /// Returns a list of anime recommendations for the given mood [emoji].
  ///
  /// Results are cached in memory; repeated calls with the same emoji return
  /// the cached list without making a new network request.
  static Future<List<Recommendation>> fetchRecommendations(
      String emoji) async {
    if (_groqApiKey.isEmpty) {
      throw ArgumentError(
          'GROQ_API_KEY is not configured. Supply it via --dart-define=GROQ_API_KEY=<value>.');
    }

    if (_cache.containsKey(emoji)) {
      return _cache[emoji]!;
    }

    final prompt = _buildPrompt(emoji);

    late final Object e1;
    try {
      final response = await _callGroq(prompt);
      final recommendations = _parseResponse(response.body);
      _cache[emoji] = recommendations;
      return recommendations;
    } catch (groqError) {
      e1 = groqError;
    }

    // Groq failed — try OpenRouter fallback
    if (_openRouterApiKey.isEmpty) {
      throw e1;
    }

    try {
      final response = await _callOpenRouter(prompt);
      final recommendations = _parseResponse(response.body);
      _cache[emoji] = recommendations;
      return recommendations;
    } catch (e2) {
      throw RecommendationException(
          'Both Groq and OpenRouter failed: $e1 / $e2');
    }
  }

  /// Asynchronously enriches [recommendations] with cover images from the
  /// Jikan API. Calls [onUpdate] with the index of each recommendation whose
  /// [Recommendation.imageUrl] was successfully updated so the UI can repaint
  /// only the affected card.
  ///
  /// This method is fire-and-forget from the caller's perspective — it never
  /// throws; individual failures are silently swallowed.
  static Future<void> enrichWithJikan({
    required List<Recommendation> recommendations,
    required void Function(int index) onUpdate,
  }) async {
    // Counter-based semaphore: tracks the number of in-flight requests.
    // At most 2 requests may be in-flight simultaneously.
    int inFlight = 0;
    const int maxConcurrent = 2;

    final futures = <Future<void>>[];

    for (var i = 0; i < recommendations.length; i++) {
      final recommendation = recommendations[i];
      final index = i;

      // Skip items that already have an image URL.
      if (recommendation.imageUrl.isNotEmpty) continue;

      // Wait until a slot is available (semaphore acquire).
      await Future.doWhile(() async {
        if (inFlight < maxConcurrent) return false; // slot available — stop waiting
        await Future.delayed(const Duration(milliseconds: 50));
        return true; // still at limit — keep waiting
      });

      inFlight++;

      // Dispatch the fetch without awaiting it here so we can continue the loop.
      final future = () async {
        try {
          final encodedTitle = Uri.encodeComponent(recommendation.title);
          final uri = Uri.parse(
              'https://api.jikan.moe/v4/anime?q=$encodedTitle&limit=1');
          final response = await http.get(uri);

          if (response.statusCode == 200) {
            final body = json.decode(response.body) as Map<String, dynamic>;
            final data = body['data'] as List<dynamic>?;
            if (data != null && data.isNotEmpty) {
              final first = data[0] as Map<String, dynamic>;
              final images = first['images'] as Map<String, dynamic>?;
              final jpg = images?['jpg'] as Map<String, dynamic>?;
              final imageUrl = jpg?['image_url'] as String?;
              if (imageUrl != null && imageUrl.isNotEmpty) {
                recommendation.imageUrl = imageUrl;
                onUpdate(index);
              }
            }
          }
        } catch (_) {
          // Leave imageUrl as "" and continue.
        } finally {
          inFlight--;
        }
      }();

      futures.add(future);

      // 200ms delay between each request dispatch.
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Wait for all in-flight requests to complete.
    await Future.wait(futures);
  }

  // -------------------------------------------------------------------------
  // Private helpers (stubs — filled in by subsequent tasks)
  // -------------------------------------------------------------------------

  static String _buildPrompt(String emoji) {
    return '''My current mood is: $emoji

Recommend exactly 6 to 8 anime titles that match this mood.

Respond with ONLY a raw JSON array. No markdown, no code fences, no explanation, no extra text — just the JSON array itself.

Each item in the array must follow this exact schema:
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

Important:
- "image_url" must always be an empty string "".
- "rating" must be a number (e.g. 8.5) or the string "N/A".
- "episodes" must be an integer (e.g. 12) or the string "N/A".
- "genres" must be an array of strings.
- Output nothing except the JSON array.''';
  }

  static Future<http.Response> _callGroq(String prompt) async {
    Future<http.Response> attempt() async {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
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
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return response;
      throw Exception(
          'Groq API error: ${response.statusCode} ${response.body}');
    }

    try {
      return await attempt();
    } catch (_) {
      // Single unconditional retry
      return await attempt();
    }
  }

  static Future<http.Response> _callOpenRouter(String prompt) async {
    final response = await http
        .post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_openRouterApiKey',
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
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) return response;
    throw Exception(
        'OpenRouter API error: ${response.statusCode} ${response.body}');
  }

  /// Extracts and returns the first JSON array substring from [content].
  ///
  /// Pipeline:
  /// 1. Strip leading/trailing whitespace.
  /// 2. If content starts with a markdown code fence (` ``` `), remove the
  ///    opening fence line and the closing ` ``` `.
  /// 3. Find the index of the first `[` and the last `]`.
  /// 4. Return the substring between them (inclusive).
  /// 5. If no `[` or `]` is found, throw [FormatException].
  static String _extractJsonArray(String content) {
    var trimmed = content.trim();

    // Strip markdown code fences if present.
    if (trimmed.startsWith('```')) {
      // Remove the opening fence line (everything up to and including the
      // first newline after the backticks).
      final firstNewline = trimmed.indexOf('\n');
      if (firstNewline != -1) {
        trimmed = trimmed.substring(firstNewline + 1);
      }
      // Remove the closing ``` (last occurrence).
      final closingFence = trimmed.lastIndexOf('```');
      if (closingFence != -1) {
        trimmed = trimmed.substring(0, closingFence);
      }
      trimmed = trimmed.trim();
    }

    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');

    if (start == -1 || end == -1) {
      throw const FormatException('No JSON array found in response');
    }

    return trimmed.substring(start, end + 1);
  }

  /// Decodes the Groq/OpenRouter [responseBody] envelope and returns a list
  /// of at most 8 [Recommendation] objects.
  ///
  /// Pipeline:
  /// 1. Decode the outer JSON envelope and extract `choices[0].message.content`.
  /// 2. Call [_extractJsonArray] to strip fences and isolate the JSON array.
  /// 3. `json.decode` the extracted string; throw [FormatException] if the
  ///    result is not a [List].
  /// 4. Filter to keep only `Map<String, dynamic>` items; silently skip others.
  /// 5. Map each item through [Recommendation.fromMap].
  /// 6. Take at most 8 items.
  static List<Recommendation> _parseResponse(String responseBody) {
    final envelope = json.decode(responseBody) as Map<String, dynamic>;
    final choices = envelope['choices'] as List<dynamic>;
    final content =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;

    final extracted = _extractJsonArray(content);

    final decoded = json.decode(extracted);
    if (decoded is! List) {
      throw const FormatException(
          'Expected a JSON array but got a different type');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Recommendation.fromMap)
        .take(8)
        .toList();
  }
}
