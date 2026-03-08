import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;

  // ВАЖЛИВО: назва саме body, щоб не ламати home_screen.dart
  final Widget body;

  const BaseScaffold({
    super.key,
    this.appBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/design/background.png',
            fit: BoxFit.cover,
          ),

          // легке затемнення для читабельності
          Container(color: Colors.black.withOpacity(0.55)),

          SafeArea(child: body),
        ],
      ),
    );
  }
}
