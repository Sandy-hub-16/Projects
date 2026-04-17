import 'package:flutter/material.dart';

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
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(                   
                    fontFamily: 'Naruto'
                  ),
                ),

                Text(
                  'Browse our anime collection',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 129, 126, 126)
                  ),
                )
              ],
            ),
            shape: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.3
              )
            )
          ),
  
          body: SingleChildScrollView(
            child: Padding(
            padding:EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    
                    children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Color.fromARGB(255, 125, 125, 255),
                              size: 24,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Filter',
                              style: TextStyle(                              
                                fontSize: 16,
                                fontFamily: 'Naruto',
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
        
                      Text(
                        '8 results',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,

                        ),
                      )
                    ],
                  ),
                
                  
                SizedBox(height: 16),

                Text(
                  'Genre',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Naruto',
                  ),
                ),
                
                SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: [

                      genreButton('All'), genreButton('Action'), genreButton('Adventure'),
                      genreButton('Comedy'), genreButton('Drama'), genreButton('Fantasy'),
                      genreButton('Historical'), genreButton('Mystery'), genreButton('Romance'),
                      genreButton('Sci-Fi'), genreButton('Shonen'), genreButton('Slice of Life'),
                      genreButton('Supernatural'), genreButton('Thriller'),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Naruto',
                  ),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    sortButton('Rating'),
                    sortButton('Year'),
                    sortButton('Title')
                  ],
                ),

                SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: animeList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cards per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7
                  ),

                  itemBuilder: (context, index) {
                    final anime = animeList[index];
                    return animeCard(anime['title']!, anime['image']!, anime['rating']!);
                  },
                ),
              ],
            ),
          ),
      
          ) 
        );
    }

    Widget genreButton(String genre) {
      bool isSelected = selectedGenre == genre;
      return Container(
        margin: EdgeInsets.only(right: 10),

        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedGenre = genre;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Color.fromARGB(255, 125, 125, 255) : Colors.white,
            foregroundColor: isSelected ? Colors.white : Color.fromARGB(255, 125, 125, 255),
            elevation: 0,
            side: BorderSide(
              color: Color.fromARGB(255, 125, 125, 255)
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          ),

            child: Text(
              genre, 
              style: TextStyle(
                fontWeight: FontWeight.w600
              )
            ),
        ),
      );
    }
    Widget sortButton(String sort) {
      bool isSelected = selectedSort == sort;
      return Container(
        margin: EdgeInsets.only(right: 10),

        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedSort = sort;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Color.fromARGB(255, 125, 125, 255) : Colors.white,
            foregroundColor: isSelected ? Colors.white : Color.fromARGB(255, 125, 125, 255),
            elevation: 0,
            side: BorderSide(
              color: Color.fromARGB(255, 125, 125, 255)
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          ),

            child: Text(
              sort, 
              style: TextStyle(
                fontWeight: FontWeight.w600
              )
            ),
        ),
      );
    }

  Widget animeCard(String title, String imageUrl, String rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 280,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        SizedBox(height: 6),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.yellow,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(rating)
          ],
        )
      ],
    );
  }

    // Anime Data (dummy)

 
    List<Map<String, String>> animeList = [
  {
    'title': 'One Piece',
    'image': 'https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',
    'rating': '8.4'
  },
  {
    'title': 'Jujutsu Kaisen',
    'image': 'https://upload.wikimedia.org/wikipedia/en/thumb/4/46/Jujutsu_kaisen.jpg/250px-Jujutsu_kaisen.jpg',
    'rating': '9.1'
  },
  {
    'title': 'Oshi No Ko Season 3',
    'image': 'https://static.wikia.nocookie.net/oshi_no_ko/images/6/6e/Season_3_Key_Visual_3.png/revision/latest/scale-to-width-down/250?cb=20250322072719',
    'rating': '7.5'
  },
  {
    'title': 'Hell\'s Paradise',
    'image': 'https://upload.wikimedia.org/wikipedia/en/b/b3/Jigokuraku_Season_2_key_visual.jpg',
    'rating': '9.0'
  },
  {
    'title': 'Sakamoto Days',
    'image': 'https://dnm.nflximg.net/api/v6/2DuQlx0fM4wd1nzqm5BFBi6ILa8/AAAAQSHBQVhtjd1LYiSNxPN9bLPFlbDo3swK9G6TivIEAPysUo0_-cJ57S-EcafNC0_0O4vQD7HGMJIUvoPeWmgZfbLDxVyyPdzBx19T8i2cS8YVyaQmeUx7uvrraloCJdNI2SJ4QSMUe9W1oWEqzXm91x57.jpg?r=776',
    'rating': '9.2'
  },
  {
    'title': 'Dead Account',
    'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRD94KbdLtqrWbq84Fxely3Zg7XIwXjlFm4gA&s',
    'rating': '8.7'
  },
  {
    'title': 'Jack-of-All-Trades, Party of None',
    'image': 'https://upload.wikimedia.org/wikipedia/en/thumb/8/86/Y%C5%ABsha_Party_o_Oidasareta_Kiy%C5%8Dbinb%C5%8D_light_novel_volume_1_cover.jpg/250px-Y%C5%ABsha_Party_o_Oidasareta_Kiy%C5%8Dbinb%C5%8D_light_novel_volume_1_cover.jpg',
    'rating': '6.9'
  },
  {
    'title': 'Tamon\'s B-Side',
    'image': 'https://upload.wikimedia.org/wikipedia/en/9/91/Tamon%27s_B-Side_vol._1_cover.jpg',
    'rating': '7.5'
  },
];
  }



