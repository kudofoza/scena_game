import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'scene_intro_screen.dart';
import 'session_stats_screen.dart';
import '../ui/base_basescaffold.dart';

class LoserScreen extends StatelessWidget {
  final GameController controller;
  final String loser;

  const LoserScreen({
    super.key,
    required this.controller,
    required this.loser,
  });

  @override
  Widget build(BuildContext context) {
    final task = controller.getRandomTask();

    return BaseScaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Програв:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              loser,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              task.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionStatsScreen(controller: controller),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Статистика'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // старт наступного раунду в тій же поточній сесії
                      await controller.startNewRound();
                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SceneIntroScreen(controller: controller),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Ще раунд'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            TextButton(
              onPressed: () {
                // ✅ ОЦЕ ВАЖЛИВО: завершити поточну сесію
                controller.endCurrentSession();

                // Повертаємось на головну (перший маршрут)
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text('Закінчити сесію (на головну)'),
            ),
          ],
        ),
      ),
    );
  }
}
