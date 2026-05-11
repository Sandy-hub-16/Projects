import 'package:flutter/foundation.dart';
import '../services/groq_recommendation_service.dart';

/// Enum representing which search mode is currently active.
enum SearchMode { realtime, ai }

/// Shared mutable state owned by [BottomNav] and passed to both [SearchPage]
/// (writes) and [ExplorePage] (listens). Extends [ChangeNotifier] so
/// [ExplorePage] can call [addListener] in [initState] and rebuild only when
/// search state changes — no [setState] on the parent required.
class SearchState extends ChangeNotifier {
  String _query = '';
  SearchMode _mode = SearchMode.realtime;
  List<Recommendation>? _aiResults; // null = not in AI redirect mode
  bool _isSearchRedirectActive = false;
  List<Map<String, dynamic>> _searchResults = [];

  // ── Getters ──────────────────────────────────────────────────────────────

  String get query => _query;
  SearchMode get mode => _mode;
  List<Recommendation>? get aiResults => _aiResults;
  bool get isSearchRedirectActive => _isSearchRedirectActive;
  List<Map<String, dynamic>> get searchResults => _searchResults;

  // ── Mutators ─────────────────────────────────────────────────────────────

  /// Called by [SearchPage] as the user types (real-time mode).
  /// Updates the query text and notifies listeners.
  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  /// Called by [SearchPage] when the user submits a real-time search.
  /// Activates search-redirect mode on [ExplorePage] with a Jikan-filtered
  /// result set.
  void activateRealtimeRedirect(
    String query,
    List<Map<String, dynamic>> results,
  ) {
    _query = query;
    _mode = SearchMode.realtime;
    _aiResults = null;

    _searchResults = results;

    _isSearchRedirectActive = query.isNotEmpty;

    notifyListeners();
  }

  /// Called by [SearchPage] when the user submits an AI search and results
  /// have been returned from the backend.
  /// Activates search-redirect mode on [ExplorePage] with the provided
  /// AI-matched [results].
  void activateAIRedirect(String query, List<Recommendation> results) {
    _query = query;
    _mode = SearchMode.ai;
    _aiResults = results;
    _isSearchRedirectActive = true;
    notifyListeners();
  }

  /// Resets all fields to their defaults and notifies listeners.
  /// Safe to call multiple times (idempotent).
  void clear() {
    _query = '';
    _mode = SearchMode.realtime;
    _aiResults = null;
    _searchResults = [];
    _isSearchRedirectActive = false;
    notifyListeners();
  }
}
