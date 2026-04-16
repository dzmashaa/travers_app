import 'package:flutter/material.dart';
import 'package:travers_app/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  useMaterial3: true,
  primaryColor: const Color(0xFF1B5E20),
  scaffoldBackgroundColor: const Color.fromARGB(255, 227, 241, 227),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1B5E20),
    secondary: const Color(0xFFE4704B),
  ),
  textTheme: GoogleFonts.montserratTextTheme(
    TextTheme(
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0D2B11),
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0D2B11),
      ),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
      bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.black54),
      labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: HomeScreen());
  }
}
