import 'package:flutter/material.dart';
import 'main.dart';
import 'pages/Home/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/search_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/profile_page.dart';
import 'widgets/night_sky_background.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;

  // Pages are created once and kept alive across rebuilds.
  // Moving them here prevents dark-mode toggles from discarding page state
  // (which caused trending/recent lists to go blank after a theme switch).
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ExplorePage(),
      const SearchPage(),
      WatchlistPage(onTabChange: changeTab),
      const ProfilePage(),
    ];
  }

  void changeTab(int index) {
    setState(() => selectedIndex = index);
  }

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context).isDarkMode;
    final brandColor = const Color.fromARGB(255, 125, 125, 255);

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF0d1b4b) : null,
        selectedItemColor: brandColor,
        unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border), label: 'Watchlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );

    if (isDark) {
      return NightSkyBackground(child: scaffold);
    }
    return scaffold;
  }
}
