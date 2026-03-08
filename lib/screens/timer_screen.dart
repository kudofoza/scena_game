import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/game_controller.dart';
import 'voting_screen.dart';
import '../ui/base_basescaffold.dart';

class TimerScreen extends StatefulWidget {
  final GameController controller;
  const TimerScreen({super.key, required this.controller});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  late int _secondsLeft;
  bool _finished = false;
  bool _extraUsed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.controller.minutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VotingScreen(controller: widget.controller),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: const Text('Сцена триває')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Spacer(),
            const Text('Імпровізуйте 👀',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Text(
              _timeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),

            OutlinedButton(
              onPressed: _extraUsed
                  ? null
                  : () {
                      setState(() {
                        _secondsLeft += 30;
                        _extraUsed = true;
                      });
                    },
              child: const Text('+30 сек'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _finish,
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Text('Закінчити раніше'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
