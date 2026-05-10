// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/cross_origin_image.dart';
import '../../services/api_service.dart';
import '../../main.dart';
import 'anime_player_page.dart';

class AnimeDetailsPage extends StatefulWidget {
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
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  // Fallback trailer map for titles not yet indexed by Jikan
  final Map<String, String> _trailerMap = {
    "Jujutsu Kaisen": "https://www.youtube.com/watch?v=MPfZhgLiK6w",
    "Sakamoto Days": "https://www.youtube.com/watch?v=9TbmxbckSjE",
    "Solo Leveling Season 2": "https://www.youtube.com/watch?v=byJ7pxxhaDY",
  };

  Map<String, dynamic> _animeData = {};
  bool _isLoading = true;
  bool _synopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await ApiService.fetchAnimeDetails(widget.title);
      setState(() {
        _animeData = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  /// Returns the YouTube watch URL from fetched data.
  /// Priority: Jikan trailer_youtube_id → YouTube search URL as fallback
  /// so there is always something to play.
  String get _trailerUrl {
    final youtubeId = _animeData['trailer_youtube_id'] as String?;
    if (youtubeId != null && youtubeId.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$youtubeId';
    }
    // Fallback 1: hardcoded map for known titles
    final mapped = _trailerMap[widget.title];
    if (mapped != null && mapped.isNotEmpty) return mapped;
    // Fallback 2: YouTube search — always returns results
    return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent('${widget.title} official trailer')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final bgColor = isDark ? const Color(0xFF0D1B4B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.white60 : Colors.grey[700]!;
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 125, 125, 255),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image with gradient overlay ──────────────────────────
            Stack(
              children: [
                // Clip to fixed height, align to top so character faces show
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CrossOriginImage(
                        imageUrl: widget.imageUrl,
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Gradient: transparent → black, covering the bottom 40%
                Container(
                  height: 320,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.55, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black),
                      ],
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
                  // ── Genre chips ─────────────────────────────────────────
                  _buildGenreChips(textColor, brandColor),

                  const SizedBox(height: 12),

                  // ── Info row ────────────────────────────────────────────
                  _buildInfoRow(textColor, brandColor),

                  const SizedBox(height: 20),

                  // ── Synopsis ────────────────────────────────────────────
                  Text(
                    'Synopsis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _animeData['synopsis']?.isNotEmpty == true
                        ? _animeData['synopsis']
                        : 'Details unavailable',
                    maxLines: _synopsisExpanded ? null : 3,
                    overflow: _synopsisExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(color: descColor),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _synopsisExpanded = !_synopsisExpanded);
                    },
                    child: Text(
                      _synopsisExpanded ? 'Show less' : 'Show more',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Watch Now button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Watch Now',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimePlayerPage(
                              title: widget.title,
                              videoUrl: _trailerUrl,
                              synopsis: _animeData['synopsis'] as String?,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Watch on Crunchyroll button ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Watch on Crunchyroll'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: brandColor,
                        side: const BorderSide(color: brandColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            'https://www.crunchyroll.com/search?q=${Uri.encodeComponent(widget.title)}',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChips(Color textColor, Color brandColor) {
    if (_isLoading) {
      // Placeholder chips while loading
      return Row(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              backgroundColor: Colors.grey[700],
              label: const Text(''),
            ),
          ),
        ),
      );
    }

    final genres = _animeData['genres'];
    final genreList = genres is List ? genres : null;
    if (_animeData.isEmpty || genreList == null || genreList.isEmpty) {
      return const Chip(label: Text('Details unavailable'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: genreList.map<Widget>((genre) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                genre.toString(),
                style: TextStyle(color: textColor),
              ),
              side: BorderSide(color: brandColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(Color textColor, Color brandColor) {
    if (_isLoading) {
      // Grey placeholder containers while loading
      return Row(
        children: [
          Container(width: 60, height: 16, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Container(width: 60, height: 16, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Container(width: 80, height: 16, color: Colors.grey[700]),
        ],
      );
    }

    final status = _animeData['status'] as String? ?? '';
    final isAiring = status == 'Currently Airing';

    return Row(
      children: [
        Icon(Icons.star, color: Colors.yellow, size: 16),
        const SizedBox(width: 4),
        Text(
          _animeData['rating']?.toString() ?? '—',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(width: 16),
        Icon(Icons.movie, color: brandColor, size: 16),
        const SizedBox(width: 4),
        Text(
          '${_animeData['episodes'] ?? '—'} eps',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.circle,
          color: isAiring ? Colors.green : Colors.grey,
          size: 10,
        ),
        const SizedBox(width: 4),
        Text(
          status.isNotEmpty ? status : '—',
          style: TextStyle(color: textColor),
        ),
      ],
    );
  }
}
