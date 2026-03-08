import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import '../data/scene_repository.dart';
import '../data/task_repository.dart';
import 'setup_screen.dart';
import 'all_sessions_screen.dart';
import 'continue_session_screen.dart';
import '../ui/base_basescaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GameController controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    controller = GameController(
      sceneRepo: SceneRepository(),
      taskRepo: TaskRepository(),
    );

    controller.initAssets().then((_) {
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = controller.hasActiveSession;
    final hasSessions = controller.archivedSessions.isNotEmpty;

    return BaseScaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 380,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 36),

                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SetupScreen(controller: controller),
                        ),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      child: Text('Грати'),
                    ),
                  ),


                  const SizedBox(height: 16),

                  /// -------- ПРОДОВЖИТИ --------
                  ElevatedButton(
                    onPressed: canContinue
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContinueSessionScreen(
                                  controller: controller,
                                ),
                              ),
                            );
                            if (!mounted) return;
                            setState(() {});
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Column(
                        children: [
                          const Text(
                            'Продовжити поточну сесію',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (!canContinue) const SizedBox(height: 4),
                          if (!canContinue)
                            const Text(
                              'Немає активної сесії',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// -------- ВСІ СЕСІЇ --------
                  OutlinedButton(
                    onPressed: hasSessions
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllSessionsScreen(
                                  controller: controller,
                                ),
                              ),
                            );
                            if (!mounted) return;
                            setState(() {});
                          }
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      child: Text('Всі сесії'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hasSessions
                        ? 'Збережено сесій: ${controller.archivedSessions.length}'
                        : 'Поки немає завершених сесій',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
    );
  }
}
