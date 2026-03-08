import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'session_stats_screen.dart';
import '../ui/base_basescaffold.dart';

class AllSessionsScreen extends StatelessWidget {
  final GameController controller;
  const AllSessionsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final sessions = controller.archivedSessions;

    return BaseScaffold(
      appBar: AppBar(title: const Text('Всі сесії')),
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'Поки що немає завершених сесій',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (_, i) {
                // показуємо найновіші зверху
                final s = sessions[sessions.length - 1 - i];

                final duration = s.endedAt.difference(s.startedAt);
                final mins = duration.inMinutes;
                final started = _fmtDateTime(s.startedAt);
                final ended = _fmtDateTime(s.endedAt);

                final topLoser = _topLoser(s.losesByPlayer);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Сесія #${sessions.length - i}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Початок: $started\nКінець:  $ended',
                        style: const TextStyle(color: Colors.white70, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Тривалість: ${mins <= 0 ? "<1" : mins} хв | Раундів: ${s.roundLogs.length} | Гравців: ${s.players.length}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topLoser == null ? 'Лузер: —' : 'Лузер: $topLoser',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // відкриваємо статистику цієї архівної сесії
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SessionStatsScreen(
                                      controller: controller,
                                      archivedSession: s,
                                    ),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Деталі'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  static String _fmtDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
    }

  static String? _topLoser(Map<String, int> loses) {
    if (loses.isEmpty) return null;
    String top = loses.keys.first;
    for (final k in loses.keys) {
      if ((loses[k] ?? 0) > (loses[top] ?? 0)) top = k;
    }
    return top;
  }
}
