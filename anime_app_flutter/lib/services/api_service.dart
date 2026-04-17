import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://localhost:8000";
  static Future<List> fetchRecommendations(String mood) async {
    final response = await http
        .get(Uri.parse('$baseUrl/recommend?mood=$mood'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List> fetchRecentUpdates() async {
    final response = await http
        .get(Uri.parse('$baseUrl/recent'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load recent updates');
    }
  }

  static Future<List> fetchTrending() async {
    final response = await http
        .get(Uri.parse('$baseUrl/trending'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load trending');
    }
  }
}
