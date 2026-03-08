import 'package:flutter/material.dart';
import 'ui/app_background.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ScenaApp());
}

class ScenaApp extends StatelessWidget {
  const ScenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Фон на всі екрани
      builder: (context, child) {
        return AppBackground(
          child: child ?? const SizedBox(),
        );
      },

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,

        // =========================
        // 🔠 ОДИН ШРИФТ НА ВСЕ
        // =========================
        fontFamily: 'AppFont',

        // =========================
        // 🔘 ELEVATED BUTTON
        // =========================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0, // 🔥 трохи ширші букви
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFF2A2A33);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF3A2A5E);
              }
              return const Color(0xFF4B2E83);
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            overlayColor:
                WidgetStateProperty.all(Colors.white.withOpacity(0.06)),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return 0;
              if (states.contains(WidgetState.pressed)) return 1;
              return 4;
            }),
            shadowColor:
                WidgetStateProperty.all(Colors.black.withOpacity(0.35)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),

        // =========================
        // 🔘 OUTLINED BUTTON
        // =========================
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.white.withOpacity(0.25);
              }
              return Colors.white.withOpacity(0.85);
            }),
            side: WidgetStateProperty.resolveWith((states) {
              final opacity =
                  states.contains(WidgetState.disabled) ? 0.15 : 0.28;
              return BorderSide(
                color: Colors.white.withOpacity(opacity),
                width: 1,
              );
            }),
            overlayColor:
                WidgetStateProperty.all(Colors.white.withOpacity(0.06)),
            backgroundColor:
                WidgetStateProperty.all(Colors.black.withOpacity(0.18)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),

        // =========================
        // 📌 APP BAR
        // =========================
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
