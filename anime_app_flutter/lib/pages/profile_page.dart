// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // Dark mode state
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            //  TOP HEADER
            Stack(
              clipBehavior: Clip.none,
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  color: Color.fromARGB(255, 125, 125, 255),
                
                  child: Column(
                    children: const [
                
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                
                      SizedBox(height: 10),
                
                      Text(
                        'Anime Fan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                
                      SizedBox(height: 5),
                
                      Text(
                        'anime.fan@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔷 STATS CARD
                Positioned(
                  bottom: -60,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.black12),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatItem(
                          icon: Icons.star,
                          value: '8.7',
                          label: 'Avg Rating',
                        ),
                        _StatItem(
                          icon: Icons.access_time,
                          value: '248h',
                          label: 'Watch Time',
                        ),
                        _StatItem(
                          icon: Icons.emoji_events,
                          value: '42',
                          label: 'Completed',
                        ),
                        _StatItem(
                          icon: Icons.trending_up,
                          value: '7d',
                          label: 'Streak',
                        ),
                      ],
                    ),
                  ),
                ),
 

              ],
            ),

 
            const SizedBox(height: 60),

            // 🔷 WATCHLIST CARD
            _buildCard(
              icon: Icons.bookmark,
              title: 'My Watchlist',
              subtitle: '0 anime saved',
              trailing: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  '0', 
                  style: TextStyle(color: Colors.blue)),
              ),
            ),

            // 🔷 DARK MODE SWITCH
            _buildCard(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
                activeColor: Colors.white,
                activeThumbColor: Color.fromARGB(255, 125, 125, 255),
              ),
            ),

            // menu items
            _buildCard(icon: Icons.person, title: 'Edit Profile', subtitle: 'Update your personal information'),
            _buildCard(icon: Icons.notifications, title: 'Notifications', subtitle: 'Manage notification preferences'),
            _buildCard(icon: Icons.settings, title: 'Settings', subtitle: 'App preferences and privacy'),

            // about
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    'About',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version'),
                      Text('1.0.0'),
                    ],
                  ),

                  SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Anime'),
                      Text('8'),
                    ],
                  ),
                ],
              ),
            ),

            // logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Log Out'),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }


  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        )
      ],
    );
  }
}


//  stat widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color outlineColor = Colors.blue;
    if (icon == Icons.star) {
      outlineColor = Colors.yellow;
    } else if (icon == Icons.emoji_events) {
      outlineColor = Colors.green;
    }
    return Column(
      children: [
        Icon(icon, color: outlineColor),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  
  }
}