import 'package:flutter/material.dart';

class WatchlistPage extends StatelessWidget {
  final Function(int)? onTabChange;

  const WatchlistPage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Watchlist',
              style: TextStyle(                   
                fontFamily: 'Naruto'
              ),
            ),
            SizedBox(height: 2),
            Text(
              '0 anime saved',
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 45,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 20,),

            Text(
              'Your watchlist is empty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 8,),
            
            Text(
              'Tap the bookmark icon to save anime',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                onTabChange?.call(1); // switch to explore_page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              child: Text(
                'Explore Anime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
          ),
        ),
  
    );
  }
}