import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'role_reveal_screen.dart';
import '../ui/base_basescaffold.dart';

class SceneIntroScreen extends StatelessWidget {
  final GameController controller;
  const SceneIntroScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scene = controller.currentScene!;
    return BaseScaffold(
      appBar: AppBar(title: const Text('Сцена')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              scene.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(scene.description,
                style: const TextStyle(color: Colors.white70)),
            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RoleRevealScreen(controller: controller),
                  ),
                );
              },
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Text('Роздати ролі'),
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: controller.skipsLeft > 0
                  ? () async {
                      await controller.skipScene();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SceneIntroScreen(
                              controller: controller),
                        ),
                      );
                    }
                  : null,
              child: Text('Пропустити (${controller.skipsLeft})'),
            ),
          ],
        ),
      ),
    );
  }
}
