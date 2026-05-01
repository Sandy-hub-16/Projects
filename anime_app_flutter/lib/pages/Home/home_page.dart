// ignore_for_file: duplicate_ignore, deprecated_member_use, avoid_print, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/groq_recommendation_service.dart';
import '../../widgets/cross_origin_image.dart';
import '../../main.dart';

import 'anime_details_page.dart';

const List<String> kSmileysPeopleEmojis = [
  '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃',
  '😉','😊','😇','🥰','😍','🤩','😘','😗','😚','😙',
  '🥲','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫',
  '🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄','😬',
  '🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢',
  '🤮','🤧','🥵','🥶','🥴','😵','💫','🤯','🤠','🥳',
  '🥸','😎','🤓','🧐','😕','😟','🙁','☹️','😮','😯',
  '😲','😳','🥺','😦','😧','😨','😰','😥','😢','😭',
  '😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡',
  '😠','🤬','😈','👿','💀','☠️',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List apiAnimeList = [];
  List recentList = [];
  List<Recommendation> recommendationList = [];
  List trendingList = [];
  bool isLoading = false;
  bool isRecommendationLoading = false;

  String? _selectedEmoji;
  bool _isPickerOpen = false;

  Future<void> loadRecommendations(String mood) async {
    setState(() {
      isRecommendationLoading = true;
    });
    try {
      final data = await GroqRecommendationService.fetchRecommendations(mood);
      setState(() {
        recommendationList = data;
      });
      _enrichWithJikan(data); // fire-and-forget, no await
    } catch (e) {
      print('[loadRecommendations] error: $e');
      // Only clear the list if there are no previous results to preserve
      if (recommendationList.isEmpty) {
        setState(() {
          recommendationList = [];
        });
      }
    } finally {
      setState(() {
        isRecommendationLoading = false;
      });
    }
  }

  Future<void> _enrichWithJikan(List<Recommendation> recs) async {
    await GroqRecommendationService.enrichWithJikan(
      recommendations: recs,
      onUpdate: (_) => setState(() {}),
    );
  }

  Future<void> loadAnime() async {
    setState(() {
      isLoading = true;
    });

    try {
      final recent = await ApiService.fetchRecentUpdates();
      final trending = await ApiService.fetchTrending();

      setState(() {
        recentList = recent;
        trendingList = trending;
      });
    } catch (e) {
      print("API Error: $e");

      setState(() {
        recentList = [];
        trendingList = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAnime();
    loadRecommendations("😊");
  }

  Widget _buildFilterButton() {
    const brandColor = Color.fromARGB(255, 125, 125, 255);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openPicker,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: brandColor, width: 1.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedEmoji == null) ...[
                const Icon(Icons.tune, color: brandColor, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Filter',
                  style: TextStyle(
                    color: brandColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else
                Text(
                  _selectedEmoji!,
                  style: const TextStyle(fontSize: 26),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: brandColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker() async {
    setState(() => _isPickerOpen = true);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EmojiPickerSheet(),
    );
    setState(() => _isPickerOpen = false);
    if (result != null) {
      setState(() => _selectedEmoji = result);
      loadRecommendations(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : const Color.fromARGB(255, 129, 126, 126);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0x990d1b4b) : null,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cool To!',
              style: TextStyle(
                color: Color.fromARGB(255, 125, 125, 255),
                fontFamily: 'Naruto',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Discover amazing anime',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications_none, color: textColor),
              onPressed: () {}),
        ],
        shape: Border(
            bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey,
                width: 0.3)),
      ),

      body: SingleChildScrollView(
            child: Column(
              children: [
                //Featured Section (Scrollable)
                SizedBox(
                  height: 220,

                  child: PageView(
                    controller: PageController(
                      viewportFraction: 0.85,
                      initialPage: 1,
                    ),
                    children: [
                      featuredCard(
                        context,
                        'Jujutsu Kaisen',
                        'https://m.media-amazon.com/images/M/MV5BMjBlNTExMDAtMWZjZi00MDc5LWFkMjgtZDU0ZWQ5ODk3YWY5XkEyXkFqcGc@._V1_.jpg',
                        '9.0',
                        'assets/gif/jjk.gif',
                      ),

                      featuredCard(
                        context,
                        'Sakamoto Days',
                        'https://dnm.nflximg.net/api/v6/2DuQlx0fM4wd1nzqm5BFBi6ILa8/AAAAQSHBQVhtjd1LYiSNxPN9bLPFlbDo3swK9G6TivIEAPysUo0_-cJ57S-EcafNC0_0O4vQD7HGMJIUvoPeWmgZfbLDxVyyPdzBx19T8i2cS8YVyaQmeUx7uvrraloCJdNI2SJ4QSMUe9W1oWEqzXm91x57.jpg?r=776',
                        '9.2',
                        'assets/gif/sakamoto-days.gif',
                      ),
                      featuredCard(
                        context,
                        'Solo Leveling Season 2',
                        'https://hobiverse.com.vn/cdn/shop/articles/Solo-Leveling-phan-2_520x500_520x500_1c67bc50-8a89-42ec-9740-ef951b982ffd.jpg?v=1742091242&width=360',
                        '8.9',
                        'assets/gif/solo-leveling.gif',
                      ),
                    ],
                  ),
                ),

                // 🔥 AI Recommendation Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.auto_awesome,
                          color: Color.fromARGB(255, 125, 125, 255),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recommended For You',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Naruto',
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 125, 125, 255),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildFilterButton(),
                    ),
                  ],
                ),

                // Recommendation List
                SizedBox(
                  height: 280,
                  child: isRecommendationLoading
                      ? Center(child: CircularProgressIndicator())
                      : recommendationList.isEmpty
                      ? Center(child: Text("No recommendations"))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          itemCount: recommendationList.length,
                          separatorBuilder: (_, _) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final anime = recommendationList[index];

                            return SizedBox(
                              width: 120,
                              child: trendingCard(
                                anime.title,
                                safeImageUrl(anime.imageUrl),
                                anime.rating,
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
                ),
                //Trending Anime
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),

                        Icon(
                          Icons.trending_up,
                          color: Color.fromARGB(255, 125, 125, 255),
                          size: 24,
                        ),

                        SizedBox(width: 6),

                        Text(
                          'Trending',
                          style: TextStyle(
                            color: Color.fromARGB(255, 125, 125, 255),
                            fontSize: 16,
                            fontFamily: 'Naruto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'See all >',
                      style: TextStyle(
                        fontFamily: 'Naruto',
                        fontWeight: FontWeight(600),
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                //Trending Card List
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: trendingList.length,
                    separatorBuilder: (_, _) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = trendingList[index];

                      return SizedBox(
                        width: 120,
                        child: trendingCard(
                          anime['title'] ?? 'No Title',
                          safeImageUrl(anime['image_url']),
                          anime['rating'].toString(),
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),

                        Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 125, 125, 255),
                          size: 24,
                        ),

                        SizedBox(width: 6),

                        Text(
                          'Recent Updates',
                          style: TextStyle(
                            color: Color.fromARGB(255, 125, 125, 255),
                            fontSize: 16,
                            fontFamily: 'Naruto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'See all >',
                      style: TextStyle(
                        fontFamily: 'Naruto',
                        fontWeight: FontWeight(600),
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: recentList.isEmpty
                              ? [Text("No data from API", style: TextStyle(color: textColor))]
                              : recentList.map((anime) {
                                  return recentUpdateCard(
                                    anime['title'] ?? 'No Title',
                                    anime['japanese_title'] ?? '',
                                    anime['rating'].toString(),
                                    anime['episodes'] != null
                                        ? anime['episodes'].toString()
                                        : "N/A",
                                    anime['image_url'] ?? '',
                                    List<String>.from(anime['genres'] ?? []),
                                    isDark: isDark,
                                  );
                                }).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
  }
}



// ─── Emoji Picker Sheet ───────────────────────────────────────────────────────

class _EmojiPickerSheet extends StatefulWidget {
  const _EmojiPickerSheet();

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  String _searchQuery = '';
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = kSmileysPeopleEmojis;
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filtered = query.isEmpty
          ? kSmileysPeopleEmojis
          : kSmileysPeopleEmojis.where((e) => e.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.55 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search emoji…',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Section label
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Smileys & People',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
          // Emoji grid
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No results',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final emoji = _filtered[index];
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, emoji),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Featured Card Widget
Widget featuredCard(BuildContext context,
  String title,
  String imageUrl,
  String rating,
  String gifPath,
) {
  final ValueNotifier<bool> isHover = ValueNotifier(false);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    width: 320,
    height: 180,

    child: MouseRegion(
      onEnter: (_) => isHover.value = true,
      onExit: (_) => isHover.value = false,

      child: ValueListenableBuilder(
        valueListenable: isHover,
        builder: (context, hovering, child) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CrossOriginImage(
                  imageUrl: safeImageUrl(imageUrl),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 125, 125, 255),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Naruto',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 18),

                        SizedBox(width: 4),

                        Text(
                          rating,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Anime Title and Watch Now Button
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight(600),
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimeDetailsPage(
                              title: title,
                              imageUrl: safeImageUrl(imageUrl),
                              rating: rating,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Watch Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight(600),
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 125, 125, 255),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

//Trending Card Widget
Widget trendingCard(String title, String imageUrl, String rating, {bool isDark = false}) {
  final textColor = isDark ? Colors.white : Colors.black87;
  return Container(
    width: 120,
    margin: EdgeInsets.only(right: 12, top: 10, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: CrossOriginImage(
              imageUrl: safeImageUrl(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 6),

        // TITLE
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
        ),

        SizedBox(height: 4),

        // RATING
        Row(
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 14),
            SizedBox(width: 3),
            Flexible(
              child: Text(
                rating,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

const String _placeholder = "https://placehold.co/300x450/png?text=Image+Unavailable";

/// Returns the image URL directly. The app uses the HTML web renderer on
/// Chrome which renders images via <img> tags, bypassing CORS restrictions.
/// On mobile there are no CORS restrictions either.
String safeImageUrl(dynamic url) {
  if (url == null) return _placeholder;
  final clean = url.toString().trim();
  if (clean.isEmpty || clean == 'N/A') return _placeholder;
  return clean;
}

Widget recentUpdateCard(
  String title,
  String japTitle,
  String rating,
  String episodes,
  String imageUrl,
  List<String> genres, {
  bool isDark = false,
}) {
  final textColor = isDark ? Colors.white : Colors.black87;
  final subtitleColor = isDark ? Colors.white54 : Colors.grey;
  final cardColor = isDark ? const Color(0xFF1a2a5e) : Colors.white;
  final shadowColor = isDark ? Colors.black45 : Colors.black12;

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: cardColor,
      border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12, width: 0.1),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 4)],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CrossOriginImage(
            imageUrl: safeImageUrl(imageUrl),
            width: 90,
            height: 130,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 10),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),

              SizedBox(height: 2),

              Text(
                japTitle,
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),

              SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: const Color.fromARGB(255, 255, 230, 0),
                    size: 14,
                  ),
                  SizedBox(width: 3),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 255, 217, 0),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '• $episodes eps',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),

              SizedBox(height: 6),

              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: genres.map((genre) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 125, 125, 255).withOpacity(
                          isDark ? 0.35 : 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? const Color.fromARGB(255, 180, 180, 255)
                            : const Color.fromARGB(255, 125, 125, 255),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
