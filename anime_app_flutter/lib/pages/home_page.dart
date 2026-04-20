import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List apiAnimeList = [];
  List recentList = [];
  List recommendationList = [];
  List trendingList = [];
  bool isLoading = false;
  bool isRecommendationLoading = false;

  String selectedMood = "happy";

  final List<Map<String, String>> moods = [
    {"label": "happy", "emoji": "😊"},
    {"label": "sad", "emoji": "😢"},
    {"label": "angry", "emoji": "😡"},
    {"label": "relaxed", "emoji": "😌"},
  ];

  Future<void> loadRecommendations(String mood) async {
    setState(() {
      isRecommendationLoading = true;
      selectedMood = mood;
    });
    try {
      final data = await ApiService.fetchRecommendations(mood);

      setState(() {
        recommendationList = data;
      });
    } catch (e) {
      print("Recommendation Error: $e");
      setState(() {
        recommendationList = [];
      });
    }

    setState(() {
      isRecommendationLoading = false;
    });
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
    loadRecommendations("happy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
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
                color: const Color.fromARGB(255, 129, 126, 126),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
        ],

        shape: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
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
                        'Jujutsu Kaisen',
                        'https://m.media-amazon.com/images/M/MV5BMjBlNTExMDAtMWZjZi00MDc5LWFkMjgtZDU0ZWQ5ODk3YWY5XkEyXkFqcGc@._V1_.jpg',
                        '9.0',
                        'assets/gif/jjk.gif',
                      ),

                      featuredCard(
                        'Sakamoto Days',
                        'https://dnm.nflximg.net/api/v6/2DuQlx0fM4wd1nzqm5BFBi6ILa8/AAAAQSHBQVhtjd1LYiSNxPN9bLPFlbDo3swK9G6TivIEAPysUo0_-cJ57S-EcafNC0_0O4vQD7HGMJIUvoPeWmgZfbLDxVyyPdzBx19T8i2cS8YVyaQmeUx7uvrraloCJdNI2SJ4QSMUe9W1oWEqzXm91x57.jpg?r=776',
                        '9.2',
                        'assets/gif/sakamoto-days.gif',
                      ),
                      featuredCard(
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
                  children: [
                    SizedBox(width: 10),
                    Icon(
                      Icons.auto_awesome,
                      color: Color.fromARGB(255, 125, 125, 255),
                    ),
                    SizedBox(width: 6),
                    Text(
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

                SizedBox(height: 10),

                // Mood Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: moods.map((mood) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () => loadRecommendations(mood["label"]!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedMood == mood["label"]!
                                ? Color.fromARGB(255, 125, 125, 255)
                                : Colors.white,
                            foregroundColor: selectedMood == mood["label"]!
                                ? Colors.white
                                : Color.fromARGB(255, 125, 125, 255),
                          ),
                          child: Text(mood["emoji"]!),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 10),

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
                          separatorBuilder: (_, __) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final anime = recommendationList[index];

                            return SizedBox(
                              width: 120,
                              child: trendingCard(
                                anime['title'] ?? 'No Title',
                                safeImageUrl(anime['image_url']),
                                anime['rating'].toString(),
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
                    separatorBuilder: (_, __) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = trendingList[index];

                      return SizedBox(
                        width: 120,
                        child: trendingCard(
                          anime['title'] ?? 'No Title',
                          safeImageUrl(anime['image_url']),
                          anime['rating'].toString(),
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
                              ? [Text("No data from API")]
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
                                  );
                                }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Featured Card Widget
Widget featuredCard(
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

                child: CachedNetworkImage(
                  imageUrl: safeImageUrl(imageUrl),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,

                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),

                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image),
                  ),
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
                      onPressed: () {},
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
Widget trendingCard(String title, String imageUrl, String rating) {
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
            aspectRatio: 2 / 3, // 🔥 FIXED RATIO (important)
            child: CachedNetworkImage(
              imageUrl: safeImageUrl(imageUrl),
              fit: BoxFit.cover,

              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),

              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.broken_image),
              ),
            ),
          ),
        ),

        SizedBox(height: 6),

        // TITLE
        Text(
          title,
          maxLines: 2, // 🔥 allow 2 lines
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        SizedBox(height: 4),

        // RATING
        Row(
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 14),
            SizedBox(width: 3),
            Flexible(
              // 🔥 prevents overflow
              child: Text(
                rating,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String safeImageUrl(dynamic url) {
  if (url == null) {
    return "https://placehold.co/300x450/png?text=Image+Unavailable";
  }

  String clean = url.toString().trim();
  if (clean.isEmpty || clean == "N/A") {
    return "https://placehold.co/300x450/png?text=Image+Unavailable";
  }
  return "${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(clean)}";
}

Widget recentUpdateCard(
  String title,
  String japTitle,
  String rating,
  String episodes,
  String imageUrl,
  List<String> genres,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(width: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: safeImageUrl(imageUrl),
            width: 90,
            height: 130,
            fit: BoxFit.cover,

            placeholder: (context, url) => Container(color: Colors.grey[300]),

            errorWidget: (context, url, error) => Container(
              width: 90,
              height: 130,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image),
            ),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 2),

              Text(
                japTitle,
                style: TextStyle(fontSize: 11, color: Colors.grey),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: 6),

              //Genre/s
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: genres.map((genre) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                        255,
                        125,
                        125,
                        255,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 125, 125, 255),
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
