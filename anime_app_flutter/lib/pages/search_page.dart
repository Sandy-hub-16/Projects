import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/search_state.dart';
import '../services/api_service.dart';
import '../widgets/cross_origin_image.dart';
import 'Home/anime_details_page.dart';

class SearchPage extends StatefulWidget {
  final SearchState searchState;
  final void Function(int) onTabChange;

  const SearchPage({
    super.key,
    required this.searchState,
    required this.onTabChange,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  bool _isAIMode = false;
  bool _isAILoading = false;
  String? _aiError;
  String _lastAIQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _removeDropdown();
    _controller.dispose();
    super.dispose();
  }

  // ── Dropdown helpers ────────────────────────────────────────────────────────

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown(List<Map<String, dynamic>> results) {
    _removeDropdown();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 320,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 54),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: MyApp.of(context).isDarkMode
                ? const Color(0xFF1a2a5e)
                : Colors.white,
            child: results.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final anime = results[i];
                      return _DropdownResultTile(
                        anime: anime,
                        isDark: MyApp.of(context).isDarkMode,
                        onTap: () {
                          _removeDropdown();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimeDetailsPage(
                                title: (anime['title'] as String?) ?? '',
                                imageUrl: (anime['image_url'] as String?) ?? '',
                                rating: anime['rating']?.toString() ?? 'N/A',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  // ── Search handlers ─────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      _removeDropdown();
      widget.searchState.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final results = await ApiService.searchAnime(value);
      if (mounted) _showDropdown(results);
    });
  }

  Future<void> _onSubmit() async {
    final query = _controller.text.trim();

    if (query.isEmpty) return;

    // AI SEARCH
    if (_isAIMode) {
      _runAISearch(query);
      return;
    }

    // NORMAL SEARCH → JIKAN
    final results = await ApiService.searchAnime(query);

    if (!mounted) return;

    widget.searchState.activateRealtimeRedirect(query, results);

    widget.onTabChange(1);

    _removeDropdown();
  }

  Future<void> _runAISearch(String query) async {
    if (query.isEmpty) return;
    _lastAIQuery = query;
    setState(() {
      _isAILoading = true;
      _aiError = null;
    });
    try {
      final results = await ApiService.searchAnimeAI(query);
      if (!mounted) return;
      widget.searchState.activateAIRedirect(query, results);
      widget.onTabChange(1);
    } on SearchAIException catch (e) {
      if (mounted) setState(() => _aiError = e.message);
    } catch (e) {
      if (mounted) setState(() => _aiError = e.toString());
    } finally {
      if (mounted) setState(() => _isAILoading = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white54
        : const Color.fromARGB(255, 129, 126, 126);
    final searchBg = isDark ? const Color(0xFF1a2a5e) : Colors.grey[200]!;
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    // Search bar visuals change based on mode
    final String hintText = _isAIMode
        ? 'Describe an anime... (e.g. MC with special powers)'
        : 'Search anime...';
    final IconData prefixIcon = _isAIMode ? Icons.auto_awesome : Icons.search;
    final Color prefixIconColor = _isAIMode ? brandColor : subtitleColor;

    return TapRegion(
      onTapOutside: (_) => _removeDropdown(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0x990d1b4b) : null,
          toolbarHeight: 70,
          title: Row(
            children: [
              // ── Unified search bar (changes behavior based on mode) ────────
              Expanded(
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isAIMode
                          ? brandColor.withOpacity(isDark ? 0.18 : 0.10)
                          : searchBg,
                      borderRadius: BorderRadius.circular(10),
                      border: _isAIMode
                          ? Border.all(color: brandColor.withOpacity(0.5))
                          : null,
                    ),
                    child: _isAILoading
                        ? Row(
                            children: [
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: brandColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'AI is searching...',
                                style: TextStyle(
                                  color: brandColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : TextField(
                            controller: _controller,
                            style: TextStyle(color: textColor),
                            onChanged: _isAIMode ? null : _onSearchChanged,
                            onSubmitted: (_) => _onSubmit(),
                            decoration: InputDecoration(
                              hintText: hintText,
                              hintStyle: TextStyle(color: subtitleColor),
                              prefixIcon: Icon(
                                prefixIcon,
                                color: prefixIconColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isAIMode ? Icons.send : Icons.arrow_forward,
                                  color: _isAIMode ? brandColor : subtitleColor,
                                ),
                                onPressed: _onSubmit,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 10,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── AI toggle button ──────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAIMode = !_isAIMode;
                    _aiError = null;
                    _controller.clear();
                  });
                  _removeDropdown();
                  widget.searchState.clear();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isAIMode ? brandColor : searchBg,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _isAIMode
                        ? [
                            BoxShadow(
                              color: brandColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: _isAIMode ? Colors.white : brandColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: _isAIMode ? Colors.white : brandColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
        body: _aiError != null
            ? _buildErrorBody(textColor, brandColor)
            : _isAIMode
            ? _buildAIIdleBody(isDark, textColor, subtitleColor, brandColor)
            : _buildRealtimeBody(isDark, textColor),
      ),
    );
  }

  // ── Error body ───────────────────────────────────────────────────────────────

  Widget _buildErrorBody(Color textColor, Color brandColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _aiError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _runAISearch(_lastAIQuery),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: brandColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── AI idle body (hint chips while AI mode is on, before submitting) ─────────

  Widget _buildAIIdleBody(
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color brandColor,
  ) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode indicator banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: brandColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: brandColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Search is ON — describe any anime in the search bar above',
                          style: TextStyle(
                            color: brandColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Try searching for:',
                  style: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            'MC with special powers',
                            'girl with blue hair',
                            'school romance',
                            'robot anime',
                            'anime with dogs',
                            'dark fantasy',
                            'time travel',
                            'isekai adventure',
                          ]
                          .map(
                            (hint) => GestureDetector(
                              onTap: () {
                                _controller.text = hint;
                                _controller
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: _controller.text.length),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1a2a5e)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: brandColor.withOpacity(0.35),
                                  ),
                                ),
                                child: Text(
                                  hint,
                                  style: TextStyle(
                                    color: brandColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Real-time body ──────────────────────────────────────────────────────────

  Widget _buildRealtimeBody(bool isDark, Color textColor) {
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                  'Action',
                  'Adventure',
                  'Sci-Fi',
                  'Fantasy',
                  'Comedy',
                  'Romance',
                ].map((g) => _genreButton(g, isDark)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genreButton(String genre, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () async {
          _controller.text = genre;

          final results = await ApiService.searchAnime(genre);

          if (!mounted) return;

          widget.searchState.activateRealtimeRedirect(genre, results);

          widget.onTabChange(1);
        },
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

// ── Private dropdown result tile ─────────────────────────────────────────────

class _DropdownResultTile extends StatelessWidget {
  final Map<String, dynamic> anime;
  final bool isDark;
  final VoidCallback onTap;

  const _DropdownResultTile({
    required this.anime,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey;
    final imageUrl = (anime['image_url'] as String?) ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CrossOriginImage(
                imageUrl: imageUrl.isNotEmpty
                    ? imageUrl
                    : 'https://placehold.co/300x450/png?text=Image+Unavailable',
                width: 40,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (anime['title'] as String?) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ((anime['genres'] as List?)?.take(2).join(', ')) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: subtitleColor, fontSize: 11),
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
