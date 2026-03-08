import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'loser_screen.dart';
import '../ui/base_basescaffold.dart';

class VotingScreen extends StatefulWidget {
  final GameController controller;
  const VotingScreen({super.key, required this.controller});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selected;
  bool _loading = false;

  Future<void> _next() async {
    if (_loading) return;

    final c = widget.controller;

    // треба вибрати когось
    if (_selected == null) return;

    // записати голос
    c.voteFor(_selected!);

    // якщо це останній голосуючий — рахуємо програвшого і переходимо
    if (c.isLastVoter) {
      setState(() => _loading = true);

      final loser = await c.resolveRoundLoser(); // ✅ ОЦЕ ГОЛОВНИЙ ФІКС

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoserScreen(
            controller: c,
            loser: loser,
          ),
        ),
      );
      return;
    }

    // інакше — наступний голосуючий
    setState(() {
      _selected = null;
      c.nextVoter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final voter = c.currentVoter;
    final candidates = c.candidatesForCurrentVoter;

    return BaseScaffold(
      appBar: AppBar(title: const Text('Голосування')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Голосує: $voter',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'Обери, хто відіграв найгірше (за себе голосувати не можна).',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (_, i) {
                  final name = candidates[i];
                  final selected = _selected == name;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: selected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(selected ? 0.35 : 0.12)),
                    ),
                    child: ListTile(
                      title: Text(name, style: const TextStyle(color: Colors.white)),
                      trailing: selected
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : const Icon(Icons.circle_outlined, color: Colors.white54),
                      onTap: _loading
                          ? null
                          : () {
                              setState(() => _selected = name);
                            },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selected == null || _loading) ? null : _next,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(_loading ? 'Рахую…' : 'Далі'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
