// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'navigation.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  // ── Auth state ─────────────────────────────────────────────────────────────
  AppUser? get currentUser => AuthService.instance.currentUser;
  bool get isLoggedIn => AuthService.instance.isLoggedIn;

  void notifyAuthChanged() => setState(() {});

  void toggleTheme(bool value) {
    setState(() => isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cool To!',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color.fromARGB(255, 125, 125, 255),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromARGB(255, 125, 125, 255),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const BottomNav(),
    );
  }
}
