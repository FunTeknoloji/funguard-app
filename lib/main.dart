import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'ui/pages/dashboard_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..init(),
      child: const FunGuardApp(),
    ),
  );
}

class FunGuardApp extends StatelessWidget {
  const FunGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4B0082), // Indigo/Deep Purple
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B1FA2),
          secondary: Color(0xFF6A1B9A),
          surface: Color(0xFF121212),
          background: Colors.black,
          error: Colors.redAccent,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
