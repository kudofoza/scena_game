import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'scene_intro_screen.dart';
import '../ui/base_basescaffold.dart';

class PlayersScreen extends StatefulWidget {
  final GameController controller;
  const PlayersScreen({super.key, required this.controller});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final left = c.playersCount - c.players.length;

    return BaseScaffold(
      appBar: AppBar(title: const Text('Імена гравців')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Залишилось: $left', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Введи імʼя',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              onSubmitted: (_) => _addName(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addName, child: const Text('Додати')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: c.players.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(c.players[i], style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => setState(() => c.players.removeAt(i)),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (c.players.length == c.playersCount)
                  ? () async {
                      await c.startNewRound();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SceneIntroScreen(controller: c)),
                      );
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Text('Почати раунд'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addName() {
    final c = widget.controller;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    if (c.players.length >= c.playersCount) return;
    setState(() {
      c.players.add(name);
      _nameCtrl.clear();
    });
  }
}
