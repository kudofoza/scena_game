import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'players_screen.dart';
import '../ui/base_basescaffold.dart';

class SetupScreen extends StatefulWidget {
  final GameController controller;
  const SetupScreen({super.key, required this.controller});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int players = 3;
  int minutes = 2;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Гравців: $players', style: const TextStyle(color: Colors.white)),
            Slider(
              value: players.toDouble(),
              min: 3,
              max: 12,
              divisions: 9,
              label: '$players',
              onChanged: (v) => setState(() => players = v.round()),
            ),
            const SizedBox(height: 16),
            Text('Хвилин: $minutes', style: const TextStyle(color: Colors.white)),
            Slider(
              value: minutes.toDouble(),
              min: 2,
              max: 5,
              divisions: 3,
              label: '$minutes',
              onChanged: (v) => setState(() => minutes = v.round()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                widget.controller.playersCount = players;
                widget.controller.minutes = minutes;
                widget.controller.players = [];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayersScreen(controller: widget.controller)),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Text('Далі'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
