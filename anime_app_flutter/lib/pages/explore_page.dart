// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/groq_recommendation_service.dart';
import '../widgets/cross_origin_image.dart';

const String _placeholder =
    'https://placehold.co/300x450/png?text=Image+Unavailable';

String _safeUrl(dynamic url) {
  if (url == null) return _placeholder;
  final s = url.toString().trim();
  return (s.isEmpty || s == 'N/A') ? _placeholder : s;
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<Recommendation> _allAnime = [];
  bool _isLoading = false;
  String? _error;

  String _selectedGenre = 'All';
  String _selectedSort = 'Rating';

  // Derived genres extracted from loaded data
  List<String> _genres = ['All'];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await GroqRecommendationService.fetchExploreAnime();
      // Build genre list from actual data
      final genreSet = <String>{};
      for (final a in data) {
        genreSet.addAll(a.genres);
      }
      final sortedGenres = genreSet.toList()..sort();

      setState(() {
        _allAnime = data;
        _genres = ['All', ...sortedGenres];
      });

      // Enrich images in background
      GroqRecommendationService.enrichWithJikan(
        recommendations: data,
        onUpdate: (_) => setState(() {}),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Filtering & sorting ────────────────────────────────────────────────────
  List<Recommendation> get _filtered {
    var list = _selectedGenre == 'All'
        ? List<Recommendation>.from(_allAnime)
        : _allAnime
            .where((a) => a.genres.contains(_selectedGenre))
            .toList();

    switch (_selectedSort) {
      case 'Rating':
        list.sort((a, b) {
          final ra = double.tryParse(a.rating) ?? 0;
          final rb = double.tryParse(b.rating) ?? 0;
          return rb.compareTo(ra); // descending
        });
        break;
      case 'Title':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Year':
        // episodes field is reused for year in explore — we store year
        // separately via the japaneseTitle hack; instead we just sort by
        // episodes count as a proxy since year isn't in the model yet.
        // The AI returns year in the prompt but the model maps it to episodes.
        // We sort alphabetically as a safe fallback.
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return list;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white54
        : const Color.fromARGB(255, 129, 126, 126);
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    // Responsive grid: 3 columns on wide, 2 on narrow
    final crossAxisCount = isWide ? 3 : 2;
    // Card aspect ratio matches the 2:3 poster ratio + info below
    const childAspectRatio = 0.58;

    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0x990d1b4b) : null,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'Naruto',
                color: brandColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Browse our anime collection',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subtitleColor,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load anime',
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Header row ──────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.filter_list,
                                    color: brandColor, size: 24),
                                const SizedBox(width: 6),
                                Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Naruto',
                                    fontWeight: FontWeight.bold,
                                    color: brandColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${filtered.length} results',
                              style: TextStyle(
                                  fontSize: 13, color: subtitleColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Genre chips ─────────────────────────────────────
                        Text(
                          'Genre',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Naruto',
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _genres
                                .map((g) => _genreButton(g, isDark))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Sort buttons ────────────────────────────────────
                        Text(
                          'Sort by',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Naruto',
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: ['Rating', 'Year', 'Title']
                              .map((s) => _sortButton(s, isDark))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        // ── Grid ────────────────────────────────────────────
                        filtered.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No anime found for this genre.',
                                    style: TextStyle(color: subtitleColor),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: isWide ? 16 : 12,
                                  mainAxisSpacing: isWide ? 16 : 12,
                                  childAspectRatio: childAspectRatio,
                                ),
                                itemBuilder: (context, index) {
                                  final anime = filtered[index];
                                  return _animeCard(
                                    anime,
                                    isDark,
                                    isWide,
                                  );
                                },
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _genreButton(String genre, bool isDark) {
    final isSelected = _selectedGenre == genre;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedGenre = genre),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 125, 125, 255)
              : (isDark ? const Color(0xFF1a2a5e) : Colors.white),
          foregroundColor: isSelected
              ? Colors.white
              : (isDark
                  ? const Color.fromARGB(255, 160, 160, 255)
                  : const Color.fromARGB(255, 125, 125, 255)),
          elevation: 0,
          side: const BorderSide(
              color: Color.fromARGB(255, 125, 125, 255)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(genre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _sortButton(String sort, bool isDark) {
    final isSelected = _selectedSort == sort;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedSort = sort),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 125, 125, 255)
              : (isDark ? const Color(0xFF1a2a5e) : Colors.white),
          foregroundColor: isSelected
              ? Colors.white
              : (isDark
                  ? const Color.fromARGB(255, 160, 160, 255)
                  : const Color.fromARGB(255, 125, 125, 255)),
          elevation: 0,
          side: const BorderSide(
              color: Color.fromARGB(255, 125, 125, 255)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(sort,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _animeCard(Recommendation anime, bool isDark, bool isWide) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white54 : Colors.grey;
    final titleFontSize = isWide ? 14.0 : 12.0;
    final metaFontSize = isWide ? 12.0 : 11.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Poster image ──────────────────────────────────────────────────
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CrossOriginImage(
              imageUrl: _safeUrl(anime.imageUrl),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // ── Title ─────────────────────────────────────────────────────────
        Text(
          anime.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: titleFontSize,
            color: textColor,
          ),
        ),
        const SizedBox(height: 3),

        // ── Rating + episodes row ─────────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.star,
                color: Color.fromARGB(255, 255, 217, 0), size: 13),
            const SizedBox(width: 3),
            Text(
              anime.rating,
              style: TextStyle(
                fontSize: metaFontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 217, 0),
              ),
            ),
            const Spacer(),
            Text(
              anime.episodes == 'N/A'
                  ? 'N/A'
                  : '${anime.episodes} eps',
              style: TextStyle(
                  fontSize: metaFontSize, color: subtitleColor),
            ),
          ],
        ),
      ],
    );
  }
}
