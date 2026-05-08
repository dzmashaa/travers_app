import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/competitions/screens/competitions.dart';
import 'package:travers_app/features/auth/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travers_app/features/navigation/main_shell.dart';
import 'package:travers_app/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  final savedRole = await StorageService.getRole();
  final user = FirebaseAuth.instance.currentUser;
  Widget initialScreen;
  if (user != null && savedRole != null) {
    if (savedRole == UserRole.participant) {
      initialScreen = const CompetitionsScreen();
    } else {
      initialScreen = MainShell();
    }
  } else {
    initialScreen = const HomeScreen();
  }
  runApp(ProviderScope(child: TraversCoreApp(startScreen: initialScreen)));
}

class TraversCoreApp extends StatelessWidget {
  final Widget startScreen;
  const TraversCoreApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: startScreen);
  }
}
