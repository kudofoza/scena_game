import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'scene_intro_screen.dart';
import '../ui/base_basescaffold.dart';

class ContinueSessionScreen extends StatefulWidget {
  final GameController controller;
  const ContinueSessionScreen({super.key, required this.controller});

  @override
  State<ContinueSessionScreen> createState() => _ContinueSessionScreenState();
}

class _ContinueSessionScreenState extends State<ContinueSessionScreen> {
  late List<TextEditingController> ctrls;

  @override
  void initState() {
    super.initState();
    ctrls = widget.controller.players
        .map((p) => TextEditingController(text: p))
        .toList();
  }

  @override
  void dispose() {
    for (final c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (ctrls.length >= 12) return;
    setState(() {
      ctrls.add(TextEditingController());
    });
  }

  void _removeAt(int index) {
    setState(() {
      ctrls[index].dispose();
      ctrls.removeAt(index);
    });
  }

  List<String> _collectPlayers() {
    return ctrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final players = _collectPlayers();

    return BaseScaffold(
      appBar: AppBar(title: const Text('Поточна сесія')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Хто грав у поточній сесії?',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Можеш додати/видалити гравців перед продовженням.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                itemCount: ctrls.length,
                itemBuilder: (_, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrls[i],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Гравець ${i + 1}',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          onPressed: ctrls.length > 3 ? () => _removeAt(i) : null,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addPlayer,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Додати гравця'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: (players.length >= 3 && players.length <= 12)
                  ? () async {
                      await widget.controller.updateCurrentSessionPlayers(players);
                      await widget.controller.startNewRound();
                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SceneIntroScreen(controller: widget.controller),
                        ),
                      );
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Продовжити'),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              'Гравців: ${players.length} (потрібно 3–12)',
              style: TextStyle(color: Colors.white.withOpacity(0.55)),
            ),
          ],
        ),
      ),
    );
  }
}
