import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../main.dart';
import '../../services/api_service.dart';

class AnimePlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String? synopsis;

  const AnimePlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
    this.synopsis,
  });

  @override
  State<AnimePlayerPage> createState() => _AnimePlayerPageState();
}

class _AnimePlayerPageState extends State<AnimePlayerPage> {
  late YoutubePlayerController ytController;
  bool isControllerReady = false;
  bool _trailerUnavailable = false;

  List episodes = [];
  bool isLoading = true;

  int? _activeEpisodeIndex;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
    initPlayer();
  }

  void initPlayer() {
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

    if (videoId == null) {
      debugPrint("Invalid YouTube URL: ${widget.videoUrl}");
      setState(() {
        isControllerReady = false;
        _trailerUnavailable = true;
      });
      return;
    }

    ytController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: true, // REQUIRED for web autoplay
      ),
    );

    ytController.loadVideoById(videoId: videoId);

    setState(() {
      isControllerReady = true;
    });
  }

  @override
  void dispose() {
    if (isControllerReady) {
      ytController.close();
    }
    super.dispose();
  }

  Future<void> loadEpisodes() async {
    final data = await ApiService.fetchEpisodes(widget.title);

    setState(() {
      episodes = data;
      isLoading = false;
    });
  }

  /// Opens [url] in the device browser.
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  /// Handles episode tap: highlights the row, then opens the appropriate URL.
  Future<void> _onEpisodeTap(int index, dynamic episode) async {
    setState(() => _activeEpisodeIndex = index);

    final watchUrl = episode['watch_url'] as String? ?? '';

    if (watchUrl.isNotEmpty) {
      await _launchUrl(watchUrl);
      return;
    }

    // No direct watch URL — fall back to streaming site search
    final streamUrl =
        '${ApiService.kStreamingSiteBaseUrl}/browser?keyword=${Uri.encodeComponent(widget.title)}';

    final launched = await launchUrl(
      Uri.parse(streamUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open streaming site')),
      );
    }
  }

  /// Builds a Crunchyroll search URL for the current anime title.
  String get _crunchyrollSearchUrl {
    final query = Uri.encodeComponent(widget.title);
    return "https://www.crunchyroll.com/search?q=$query";
  }

  @override
  Widget build(BuildContext context) {
    // ── Dark-mode theming ────────────────────────────────────────────────────
    final isDark = MyApp.of(context).isDarkMode;
    final contentBg = isDark ? const Color(0xFF0D1B4B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    const brandColor = Color.fromARGB(255, 125, 125, 255);

    final screenHeight = MediaQuery.of(context).size.height;
    final maxVideoHeight = screenHeight * 0.45;

    // About text: use synopsis if provided, otherwise a generic fallback
    final aboutText = widget.synopsis?.isNotEmpty == true
        ? widget.synopsis!
        : 'Watch official trailer and explore episodes.';

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// 🌐 FULL PAGE SCROLL
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                /// 🎬 VIDEO SECTION — always black background
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxVideoHeight),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: isControllerReady
                          ? YoutubePlayerScaffold(
                              controller: ytController,
                              builder: (context, player) {
                                return SizedBox.expand(child: player);
                              },
                            )
                          : _trailerUnavailable
                              ? const Center(
                                  child: Text(
                                    'Trailer unavailable',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                    ),
                  ),
                ),

                /// 📺 CONTENT SECTION
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: contentBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ▶ WATCH ON CRUNCHYROLL BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(_crunchyrollSearchUrl),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text("Watch on Crunchyroll"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // About heading
                        Text(
                          "About this anime",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Synopsis / about body
                        Text(
                          aboutText,
                          style: TextStyle(color: descColor),
                        ),

                        const SizedBox(height: 20),

                        // Episodes heading
                        Text(
                          "Episodes",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : episodes.isEmpty
                                ? Text(
                                    "No episodes available",
                                    style: TextStyle(color: descColor),
                                  )
                                : Column(
                                    children: episodes
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final ep = entry.value;
                                      final isActive =
                                          _activeEpisodeIndex == index;

                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        tileColor: isActive
                                            ? brandColor.withOpacity(0.15)
                                            : Colors.transparent,
                                        leading: Icon(
                                          Icons.play_circle_fill,
                                          color: isActive
                                              ? brandColor
                                              : textColor,
                                        ),
                                        title: Text(
                                          ep['title'] ??
                                              'Episode ${index + 1}',
                                          style: TextStyle(
                                            color: isActive
                                                ? brandColor
                                                : textColor,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.open_in_new,
                                          color: Colors.grey[500],
                                          size: 16,
                                        ),
                                        onTap: () => _onEpisodeTap(index, ep),
                                      );
                                    }).toList(),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ◀ BACK BUTTON — always dark overlay regardless of theme
          Positioned(
            top: 0,
            left: 10,
            child: SafeArea(
              child: PointerInterceptor(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
