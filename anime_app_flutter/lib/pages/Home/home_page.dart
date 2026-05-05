// ignore_for_file: duplicate_ignore, deprecated_member_use, avoid_print, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/groq_recommendation_service.dart';
import '../../widgets/cross_origin_image.dart';
import '../../main.dart';

import 'anime_details_page.dart';

// Each entry: emoji → searchable keywords (lowercase)
const Map<String, String> kEmojiKeywords = {
  '😀': 'grinning happy smile face',
  '😃': 'grinning big eyes happy smile',
  '😄': 'grinning smiling eyes happy',
  '😁': 'beaming grin happy smile',
  '😆': 'laughing grinning squinting happy',
  '😅': 'sweat smile nervous laugh',
  '🤣': 'rolling floor laughing rofl',
  '😂': 'joy tears laughing cry funny',
  '🙂': 'slightly smiling smile',
  '🙃': 'upside down smile sarcastic',
  '😉': 'winking wink smile',
  '😊': 'smiling blush happy warm',
  '😇': 'smiling halo angel innocent',
  '🥰': 'smiling hearts love adore',
  '😍': 'heart eyes love adore',
  '🤩': 'star struck excited wow amazing',
  '😘': 'face blowing kiss love',
  '😗': 'kissing face',
  '😚': 'kissing closed eyes',
  '😙': 'kissing smiling eyes',
  '🥲': 'smiling tear happy cry',
  '😋': 'face savoring food yum delicious',
  '😛': 'face tongue playful',
  '😜': 'winking tongue playful',
  '🤪': 'zany crazy silly',
  '😝': 'squinting tongue silly',
  '🤑': 'money mouth rich greedy',
  '🤗': 'hugging hug warm',
  '🤭': 'face hand giggle secret',
  '🤫': 'shushing quiet secret',
  '🤔': 'thinking hmm pondering',
  '🤐': 'zipper mouth silent quiet',
  '🤨': 'raised eyebrow skeptical suspicious',
  '😐': 'neutral expressionless blank',
  '😑': 'expressionless blank',
  '😶': 'no mouth silent speechless',
  '😏': 'smirking smug',
  '😒': 'unamused unhappy bored',
  '🙄': 'eye roll annoyed',
  '😬': 'grimacing awkward nervous',
  '🤥': 'lying pinocchio',
  '😌': 'relieved peaceful calm',
  '😔': 'pensive sad thoughtful',
  '😪': 'sleepy tired droopy',
  '🤤': 'drooling hungry',
  '😴': 'sleeping zzz tired',
  '😷': 'mask sick ill medical',
  '🤒': 'thermometer sick fever ill',
  '🤕': 'bandage hurt injured',
  '🤢': 'nauseated sick gross',
  '🤮': 'vomiting sick disgusted',
  '🤧': 'sneezing sick cold',
  '🥵': 'hot flushed overheated',
  '🥶': 'cold freezing blue',
  '🥴': 'woozy dizzy drunk',
  '😵': 'dizzy spiral eyes',
  '💫': 'dizzy star sparkle',
  '🤯': 'exploding head mind blown shocked',
  '🤠': 'cowboy hat western',
  '🥳': 'partying celebration birthday',
  '🥸': 'disguised glasses nose',
  '😎': 'sunglasses cool smug',
  '🤓': 'nerd glasses smart',
  '🧐': 'monocle curious inspect',
  '😕': 'confused worried',
  '😟': 'worried concerned',
  '🙁': 'slightly frowning sad',
  '☹️': 'frowning sad unhappy',
  '😮': 'open mouth surprised',
  '😯': 'hushed surprised quiet',
  '😲': 'astonished shocked wow',
  '😳': 'flushed embarrassed shocked',
  '🥺': 'pleading puppy eyes sad',
  '😦': 'frowning open mouth worried',
  '😧': 'anguished distressed',
  '😨': 'fearful scared anxious',
  '😰': 'anxious sweat nervous',
  '😥': 'sad relieved disappointed',
  '😢': 'crying sad tear',
  '😭': 'loudly crying sob sad',
  '😱': 'screaming fear shocked horror',
  '😖': 'confounded frustrated',
  '😣': 'persevering struggling',
  '😞': 'disappointed sad',
  '😓': 'downcast sweat sad',
  '😩': 'weary tired exhausted',
  '😫': 'tired exhausted',
  '🥱': 'yawning bored tired',
  '😤': 'triumph steam angry proud',
  '😡': 'pouting angry red mad',
  '😠': 'angry mad',
  '🤬': 'cursing swearing angry symbols',
  '😈': 'smiling devil evil mischievous',
  '👿': 'angry devil evil',
  '💀': 'skull death dead',
  '☠️': 'skull crossbones danger poison',
};

List<String> get kSmileysPeopleEmojis => kEmojiKeywords.keys.toList();

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

  String _selectedEmoji = '😊';
  bool _isPickerOpen = false;
  final LayerLink _filterLayerLink = LayerLink();
  OverlayEntry? _pickerOverlay;

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
    return CompositedTransformTarget(
      link: _filterLayerLink,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _togglePicker,
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
                Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isPickerOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: brandColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePicker() {
    if (_isPickerOpen) {
      _closePicker();
    } else {
      _showPicker();
    }
  }

  void _showPicker() {
    setState(() => _isPickerOpen = true);
    _pickerOverlay = OverlayEntry(
      builder: (context) => _EmojiPickerOverlay(
        link: _filterLayerLink,
        onSelect: (emoji) {
          _closePicker();
          setState(() => _selectedEmoji = emoji);
          loadRecommendations(emoji);
        },
        onDismiss: _closePicker,
      ),
    );
    Overlay.of(context).insert(_pickerOverlay!);
  }

  void _closePicker() {
    _pickerOverlay?.remove();
    _pickerOverlay = null;
    if (mounted) setState(() => _isPickerOpen = false);
  }

  @override
  void dispose() {
    _closePicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : const Color.fromARGB(255, 129, 126, 126);

    // Responsive breakpoint: wide = maximized browser / large screen
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    // Scale factors for wide screens
    final double featuredHeight = isWide ? 300 : 220;
    final double cardListHeight = isWide ? 360 : 280;
    final double cardWidth = isWide ? 160.0 : 120.0;

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
                  height: featuredHeight,

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
                        isWide: isWide,
                      ),

                      featuredCard(
                        context,
                        'Sakamoto Days',
                        'https://dnm.nflximg.net/api/v6/2DuQlx0fM4wd1nzqm5BFBi6ILa8/AAAAQSHBQVhtjd1LYiSNxPN9bLPFlbDo3swK9G6TivIEAPysUo0_-cJ57S-EcafNC0_0O4vQD7HGMJIUvoPeWmgZfbLDxVyyPdzBx19T8i2cS8YVyaQmeUx7uvrraloCJdNI2SJ4QSMUe9W1oWEqzXm91x57.jpg?r=776',
                        '9.2',
                        'assets/gif/sakamoto-days.gif',
                        isWide: isWide,
                      ),
                      featuredCard(
                        context,
                        'Solo Leveling Season 2',
                        'https://hobiverse.com.vn/cdn/shop/articles/Solo-Leveling-phan-2_520x500_520x500_1c67bc50-8a89-42ec-9740-ef951b982ffd.jpg?v=1742091242&width=360',
                        '8.9',
                        'assets/gif/solo-leveling.gif',
                        isWide: isWide,
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
                  height: cardListHeight,
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
                              width: cardWidth,
                              child: trendingCard(
                                anime.title,
                                safeImageUrl(anime.imageUrl),
                                anime.rating,
                                isDark: isDark,
                                isWide: isWide,
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
                  height: cardListHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: trendingList.length,
                    separatorBuilder: (_, _) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = trendingList[index];

                      return SizedBox(
                        width: cardWidth,
                        child: trendingCard(
                          anime['title'] ?? 'No Title',
                          safeImageUrl(anime['image_url']),
                          anime['rating'].toString(),
                          isDark: isDark,
                          isWide: isWide,
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
                                    isWide: isWide,
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



// ─── Emoji Picker Overlay (Facebook/Messenger tooltip style) ─────────────────

class _EmojiPickerOverlay extends StatefulWidget {
  final LayerLink link;
  final ValueChanged<String> onSelect;
  final VoidCallback onDismiss;

  const _EmojiPickerOverlay({
    required this.link,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  State<_EmojiPickerOverlay> createState() => _EmojiPickerOverlayState();
}

class _EmojiPickerOverlayState extends State<_EmojiPickerOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> _filtered = kSmileysPeopleEmojis;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = kSmileysPeopleEmojis;
      } else {
        _filtered = kEmojiKeywords.entries
            .where((e) => e.value.contains(q) || e.key.contains(q))
            .map((e) => e.key)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Popup dimensions
    const double popupWidth = 300;
    const double popupHeight = 320;
    const double arrowSize = 8.0;

    return Stack(
      children: [
        // Transparent barrier to dismiss on outside tap
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),
        // The popup itself, anchored above the filter button
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          // Shift left so popup aligns to the right edge of the button,
          // and up so it sits above the button with a small gap + arrow
          offset: Offset(-(popupWidth - 10), -(popupHeight + arrowSize + 8)),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── Popup card ──────────────────────────────────────────
                    Container(
                      width: popupWidth,
                      height: popupHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e1e2e),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: false,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search emoji…',
                                hintStyle: const TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white38, size: 18),
                                filled: true,
                                fillColor: Colors.white12,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          // Section label
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _searchCtrl.text.isEmpty
                                    ? 'Emojis'
                                    : 'Results',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ),
                          ),
                          // Emoji grid
                          Expanded(
                            child: _filtered.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No results',
                                      style:
                                          TextStyle(color: Colors.white38),
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: _filtered.length,
                                    itemBuilder: (_, i) {
                                      final emoji = _filtered[i];
                                      return GestureDetector(
                                        onTap: () =>
                                            widget.onSelect(emoji),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(
                                                  fontSize: 22),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    // ── Arrow pointing down toward the button ───────────────
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CustomPaint(
                        size: Size(arrowSize * 2, arrowSize),
                        painter: _ArrowPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a downward-pointing triangle arrow for the tooltip tail.
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1e1e2e)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}

// Featured Card Widget
Widget featuredCard(BuildContext context,
  String title,
  String imageUrl,
  String rating,
  String gifPath, {
  bool isWide = false,
}) {
  final ValueNotifier<bool> isHover = ValueNotifier(false);
  final double cardHeight = isWide ? 260.0 : 180.0;
  final double titleFontSize = isWide ? 26.0 : 22.0;

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    width: isWide ? 420 : 320,
    height: cardHeight,

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
                        fontSize: titleFontSize,
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
Widget trendingCard(String title, String imageUrl, String rating, {bool isDark = false, bool isWide = false}) {
  final textColor = isDark ? Colors.white : Colors.black87;
  final double cardWidth = isWide ? 160.0 : 120.0;
  final double titleFontSize = isWide ? 13.0 : 12.0;
  final double ratingFontSize = isWide ? 13.0 : 12.0;
  return Container(
    width: cardWidth,
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
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600, color: textColor),
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
                style: TextStyle(fontSize: ratingFontSize, fontWeight: FontWeight.bold, color: textColor),
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
  bool isWide = false,
}) {
  final textColor = isDark ? Colors.white : Colors.black87;
  final subtitleColor = isDark ? Colors.white54 : Colors.grey;
  final cardColor = isDark ? const Color(0xFF1a2a5e) : Colors.white;
  final shadowColor = isDark ? Colors.black45 : Colors.black12;

  // Responsive image and font sizes
  final double imgWidth = isWide ? 110.0 : 90.0;
  final double imgHeight = isWide ? 160.0 : 130.0;
  final double titleFontSize = isWide ? 16.0 : 14.0;
  final double subFontSize = isWide ? 12.0 : 11.0;
  final double metaFontSize = isWide ? 13.0 : 12.0;
  final double genreFontSize = isWide ? 11.0 : 10.0;

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
            width: imgWidth,
            height: imgHeight,
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
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),

              SizedBox(height: 2),

              Text(
                japTitle,
                style: TextStyle(fontSize: subFontSize, color: subtitleColor),
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
                      fontSize: metaFontSize,
                      color: const Color.fromARGB(255, 255, 217, 0),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '• $episodes eps',
                    style: TextStyle(fontSize: metaFontSize, color: subtitleColor),
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
                        fontSize: genreFontSize,
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
