import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10)
          ),

          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search anime...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10)
            ),
          ),
        ),

        
        shape: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.3
              )
            )
      ),
      
      body: SingleChildScrollView(
        
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                 SizedBox(width: 10),

                Icon(
                  Icons.trending_up,
                  color: Color.fromARGB(255, 125, 125, 255),
                  size: 24,
                ),

                SizedBox(width: 6,),
 
                Text(
                  'Popular Searches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),

            GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 2.2, // Adjust for height/width ratio
              shrinkWrap: true, // Use if inside a ScrollView/Column
              physics: NeverScrollableScrollPhysics(),
              children: [

                genreButton('Action'),
                genreButton('Adventure'),
                genreButton('Sci-Fi'),
                genreButton('Fantasy'),
                genreButton('Comedy'),
                genreButton('Romance')
              ]
            )
          ],
        ),
      ),
    );
  }
}

  Widget genreButton(String genre) {
      return Container(
        margin: EdgeInsets.only(right: 10,top: 10, bottom: 10),

        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor:Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            side: BorderSide(
              color: Colors.grey,
              width: 0.1
              ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
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
