import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import '../models/archived_session.dart';
import 'scene_intro_screen.dart';
import '../ui/base_basescaffold.dart';

class SessionStatsScreen extends StatelessWidget {
  final GameController controller;

  // якщо не null — показуємо архівну сесію
  final ArchivedSession? archivedSession;

  const SessionStatsScreen({
    super.key,
    required this.controller,
    this.archivedSession,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived = archivedSession != null;

    final players = isArchived ? archivedSession!.players : controller.players;
    final loses = isArchived
        ? Map<String, int>.from(archivedSession!.losesByPlayer)
        : controller.sessionStats.losesByPlayer;

    // щоб гравці з 0 теж показувались
    for (final p in players) {
      loses[p] = loses[p] ?? 0;
    }

    final sorted = loses.entries.toList()
      ..sort((a, b) => (b.value).compareTo(a.value));

    final topLoser = _getTopLoser(loses);

    final logs = isArchived ? archivedSession!.roundLogs : controller.roundLogs;

    return BaseScaffold(
      appBar: AppBar(title: Text(isArchived ? 'Статистика сесії (архів)' : 'Статистика сесії')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (topLoser != null) ...[
              const SizedBox(height: 8),
              const Text('Лузер:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                topLoser,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Випий склянку алкогольного напою 🍻',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Скільки разів програвали:',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final e = sorted[i];
                  final isTop = e.key == topLoser;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(isTop ? 0.10 : 0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: TextStyle(
                            color: isTop ? Colors.redAccent : Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Історія раундів:',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (_, i) {
                  final log = logs[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
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
                          log.sceneTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text('Програв: ${log.loser}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(
                          'Голоси: ${_prettyVotes(log.votesSnapshot)}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ✅ кнопки внизу:
            if (!isArchived) ...[
              // Якщо це статистика поточної сесії — даємо "Грати далі"
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Назад'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
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
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Грати далі'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                child: const Text('На головну'),
              ),
            ] else ...[
              // Якщо це архів — просто "Назад"
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Text('Назад'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _prettyVotes(Map<String, int> m) {
    if (m.isEmpty) return '—';
    final entries = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => '${e.key}:${e.value}').join(', ');
  }

  static String? _getTopLoser(Map<String, int> loses) {
    if (loses.isEmpty) return null;
    String top = loses.keys.first;
    for (final k in loses.keys) {
      if ((loses[k] ?? 0) > (loses[top] ?? 0)) top = k;
    }
    return top;
  }
}
