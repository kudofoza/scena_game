import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎆 ФОН
        Positioned.fill(
          child: Image.asset(
            'assets/design/background.png',
            fit: BoxFit.cover,
          ),
        ),

        // 🖤 затемнення для читабельності
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.45),
          ),
        ),

        // 🌈 контент
        child,
      ],
    );
  }
}
