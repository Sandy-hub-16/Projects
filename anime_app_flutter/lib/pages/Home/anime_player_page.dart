import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../services/api_service.dart';

class AnimePlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const AnimePlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<AnimePlayerPage> createState() => _AnimePlayerPageState();
}

class _AnimePlayerPageState extends State<AnimePlayerPage> {
  late YoutubePlayerController ytController;
  bool isControllerReady = false;

  List episodes = [];
  bool isLoading = true;

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
  /// Falls back to a Crunchyroll search if the url is empty.
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  /// Builds a Crunchyroll search URL for the current anime title.
  String get _crunchyrollSearchUrl {
    final query = Uri.encodeComponent(widget.title);
    return "https://www.crunchyroll.com/search?q=$query";
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxVideoHeight = screenHeight * 0.45;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// 🌐 FULL PAGE SCROLL
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                /// 🎬 VIDEO SECTION
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
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),

                /// 📺 CONTENT SECTION
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
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
                              backgroundColor: const Color(
                                0xFFF47521,
                              ), // Crunchyroll orange
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "About this anime",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Watch official trailer and explore episodes based on your mood.",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Episodes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : episodes.isEmpty
                            ? const Text(
                                "No episodes available",
                                style: TextStyle(color: Colors.grey),
                              )
                            : Column(
                                children: episodes.map((ep) {
                                  // If the episode has a direct watch_url, open it
                                  // in the browser. Otherwise fall back to loading
                                  // the YouTube trailer in the player above.
                                  final watchUrl = ep['watch_url'] ?? "";
                                  final videoUrl = ep['video_url'] ?? "";

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      ep['title'] ?? "Untitled",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: watchUrl.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              color: Colors.grey,
                                            ),
                                            tooltip: "Watch on Crunchyroll",
                                            onPressed: () =>
                                                _launchUrl(watchUrl),
                                          )
                                        : null,
                                    onTap: () {
                                      // If there's a direct watch link, open browser
                                      if (watchUrl.isNotEmpty) {
                                        _launchUrl(watchUrl);
                                        return;
                                      }

                                      // Otherwise play the YouTube trailer
                                      final videoId =
                                          YoutubePlayerController.convertUrlToId(
                                            videoUrl,
                                          );

                                      if (videoId != null) {
                                        ytController.loadVideoById(
                                          videoId: videoId,
                                        );
                                      }
                                    },
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

          /// ◀ BACK BUTTON
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
