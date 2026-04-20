import 'package:flutter/material.dart';
import 'pages/Home/home_page.dart'; 
import 'pages/explore_page.dart';
import 'pages/search_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/profile_page.dart';

// Dummy pages (you can replace later)




class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;
  
   void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

      final List<Widget> pages = [
      HomePage(),
      ExplorePage(),
      SearchPage(),
      WatchlistPage(onTabChange: changeTab),
      ProfilePage(),
    ];

  
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Color.fromARGB(255, 125, 125, 255),
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}