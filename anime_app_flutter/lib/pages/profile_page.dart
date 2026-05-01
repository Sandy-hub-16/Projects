// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final isDark = appState.isDarkMode;
    final theme = Theme.of(context);

    final cardColor = isDark ? const Color(0xFF1a2a5e) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey;
    final shadowColor = isDark ? Colors.black45 : Colors.black12;
    final iconBgColor = isDark
        ? const Color.fromARGB(255, 125, 125, 255).withOpacity(0.25)
        : Colors.blue.withOpacity(0.1);
    final iconColor = isDark ? const Color.fromARGB(255, 160, 160, 255) : Colors.blue;

    BoxDecoration cardDecoration() => BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
        );

    Widget buildCard({
      required IconData icon,
      required String title,
      required String subtitle,
      Widget? trailing,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBgColor,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: textColor)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: subtitleColor)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios, size: 16, color: subtitleColor),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── TOP HEADER ──────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 60, bottom: 40, left: 16, right: 16),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2a1a6e),
                              Color.fromARGB(255, 125, 125, 255),
                            ],
                          )
                        : null,
                    color: isDark
                        ? null
                        : const Color.fromARGB(255, 125, 125, 255),
                  ),
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Anime Fan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'anime.fan@example.com',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Stats card
                Positioned(
                  bottom: -60,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: shadowColor)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                            icon: Icons.star,
                            value: '8.7',
                            label: 'Avg Rating',
                            textColor: textColor),
                        _StatItem(
                            icon: Icons.access_time,
                            value: '248h',
                            label: 'Watch Time',
                            textColor: textColor),
                        _StatItem(
                            icon: Icons.emoji_events,
                            value: '42',
                            label: 'Completed',
                            textColor: textColor),
                        _StatItem(
                            icon: Icons.trending_up,
                            value: '7d',
                            label: 'Streak',
                            textColor: textColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 75),

            // ── WATCHLIST ────────────────────────────────────────────────────
            buildCard(
              icon: Icons.bookmark,
              title: 'My Watchlist',
              subtitle: '0 anime saved',
              trailing: CircleAvatar(
                backgroundColor: iconBgColor,
                child: Text('0', style: TextStyle(color: iconColor)),
              ),
            ),

            // ── DARK MODE TOGGLE ─────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: cardDecoration(),
              child: Row(
                children: [
                  // Sun / Moon icon
                  CircleAvatar(
                    backgroundColor: isDark
                        ? Colors.indigo.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.15),
                    child: Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny,
                      color: isDark ? Colors.indigo[200] : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dark Mode',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        Text(isDark ? 'Enabled' : 'Disabled',
                            style:
                                TextStyle(fontSize: 12, color: subtitleColor)),
                      ],
                    ),
                  ),
                  // Toggle with moon/sun thumb
                  GestureDetector(
                    onTap: () => appState.toggleTheme(!isDark),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: isDark
                            ? const Color.fromARGB(255, 125, 125, 255)
                            : Colors.grey[300],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: isDark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDark ? Icons.nightlight_round : Icons.wb_sunny,
                            size: 14,
                            color: isDark
                                ? const Color.fromARGB(255, 125, 125, 255)
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── OTHER MENU ITEMS ─────────────────────────────────────────────
            buildCard(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your personal information'),
            buildCard(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences'),
            buildCard(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'App preferences and privacy'),

            // ── ABOUT ────────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version', style: TextStyle(color: textColor)),
                      Text('1.0.0', style: TextStyle(color: subtitleColor)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Anime', style: TextStyle(color: textColor)),
                      Text('8', style: TextStyle(color: subtitleColor)),
                    ],
                  ),
                ],
              ),
            ),

            // ── LOG OUT ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.white70 : theme.colorScheme.primary,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white30
                          : theme.colorScheme.primary,
                    ),
                  ),
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
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color textColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = Colors.blue;
    if (icon == Icons.star) iconColor = Colors.yellow;
    if (icon == Icons.emoji_events) iconColor = Colors.green;
    if (icon == Icons.trending_up) iconColor = Colors.lightBlue;

    return Column(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: 5),
        Text(value,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        Text(label,
            style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.6))),
      ],
    );
  }
}
