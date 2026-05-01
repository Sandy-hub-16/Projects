// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/cross_origin_image.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedGenre = 'All';
  String selectedSort = 'Rating';

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : const Color.fromARGB(255, 129, 126, 126);
    const brandColor = Color.fromARGB(255, 125, 125, 255);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: brandColor, size: 24),
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
                    '${animeList.length} results',
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                  children: [
                    'All', 'Action', 'Adventure', 'Comedy', 'Drama',
                    'Fantasy', 'Historical', 'Mystery', 'Romance',
                    'Sci-Fi', 'Shonen', 'Slice of Life', 'Supernatural', 'Thriller',
                  ].map((g) => _genreButton(g, isDark)).toList(),
                ),
              ),
              const SizedBox(height: 16),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: animeList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final anime = animeList[index];
                  return _animeCard(
                    anime['title']!,
                    anime['image']!,
                    anime['rating']!,
                    isDark,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genreButton(String genre, bool isDark) {
    final isSelected = selectedGenre == genre;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => selectedGenre = genre),
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
          side: const BorderSide(color: Color.fromARGB(255, 125, 125, 255)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(genre, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _sortButton(String sort, bool isDark) {
    final isSelected = selectedSort == sort;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => selectedSort = sort),
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
          side: const BorderSide(color: Color.fromARGB(255, 125, 125, 255)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(sort, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _animeCard(String title, String imageUrl, String rating, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: CrossOriginImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.yellow, size: 14),
            const SizedBox(width: 4),
            Text(rating, style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  final List<Map<String, String>> animeList = [
    {
      'title': 'One Piece',
      'image': 'https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',
      'rating': '8.4',
    },
    {
      'title': 'Jujutsu Kaisen',
      'image': 'https://upload.wikimedia.org/wikipedia/en/thumb/4/46/Jujutsu_kaisen.jpg/250px-Jujutsu_kaisen.jpg',
      'rating': '9.1',
    },
    {
      'title': 'Oshi No Ko Season 3',
      'image': 'https://static.wikia.nocookie.net/oshi_no_ko/images/6/6e/Season_3_Key_Visual_3.png/revision/latest/scale-to-width-down/250?cb=20250322072719',
      'rating': '7.5',
    },
    {
      'title': "Hell's Paradise",
      'image': 'https://upload.wikimedia.org/wikipedia/en/b/b3/Jigokuraku_Season_2_key_visual.jpg',
      'rating': '9.0',
    },
    {
      'title': 'Sakamoto Days',
      'image': 'https://dnm.nflximg.net/api/v6/2DuQlx0fM4wd1nzqm5BFBi6ILa8/AAAAQSHBQVhtjd1LYiSNxPN9bLPFlbDo3swK9G6TivIEAPysUo0_-cJ57S-EcafNC0_0O4vQD7HGMJIUvoPeWmgZfbLDxVyyPdzBx19T8i2cS8YVyaQmeUx7uvrraloCJdNI2SJ4QSMUe9W1oWEqzXm91x57.jpg?r=776',
      'rating': '9.2',
    },
    {
      'title': 'Dead Account',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRD94KbdLtqrWbq84Fxely3Zg7XIwXjlFm4gA&s',
      'rating': '8.7',
    },
    {
      'title': 'Jack-of-All-Trades, Party of None',
      'image': 'https://upload.wikimedia.org/wikipedia/en/thumb/8/86/Y%C5%ABsha_Party_o_Oidasareta_Kiy%C5%8Dbinb%C5%8D_light_novel_volume_1_cover.jpg/250px-Y%C5%ABsha_Party_o_Oidasareta_Kiy%C5%8Dbinb%C5%8D_light_novel_volume_1_cover.jpg',
      'rating': '6.9',
    },
    {
      'title': "Tamon's B-Side",
      'image': "https://upload.wikimedia.org/wikipedia/en/9/91/Tamon%27s_B-Side_vol._1_cover.jpg",
      'rating': '7.5',
    },
  ];
}
