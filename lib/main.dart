import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/architecture_screen.dart';

void main() {
  runApp(const ClubRushTrackerApp());
}

class ClubRushTrackerApp extends StatelessWidget {
  const ClubRushTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Rush Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const ArchitectureScreen(),
    );
  }
}
