import 'dart:math';
import 'package:flutter/material.dart';
import '../state/game_controller.dart';
import 'timer_screen.dart';
import '../ui/base_basescaffold.dart';

class RoleRevealScreen extends StatefulWidget {
  final GameController controller;
  const RoleRevealScreen({super.key, required this.controller});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _flip;
  bool _isFront = true; // показуємо ім'я
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _flip = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Future<void> _toggleCard() async {
    if (_locked) return;
    setState(() => _locked = true);

    if (_isFront) {
      await _ac.forward();
      setState(() => _isFront = false);
    } else {
      await _ac.reverse();
      setState(() => _isFront = true);
    }

    setState(() => _locked = false);
  }

  void _nextPlayer() async {
    final c = widget.controller;

    // якщо роль ще показується — спочатку повертаємо карту на "ім'я"
    if (!_isFront) {
      await _ac.reverse();
      if (!mounted) return;
      setState(() => _isFront = true);
    }

    if (c.isLastReveal) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TimerScreen(controller: c)),
      );
      return;
    }

    setState(() {
      c.nextReveal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final player = c.currentRevealPlayer;
    final role = c.getRoleForPlayer(player);

    return BaseScaffold(
      appBar: AppBar(title: const Text('Ролі')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Передай телефон гравцю:',
                style: TextStyle(color: Colors.white.withOpacity(0.75)),
              ),
              const SizedBox(height: 6),
              Text(
                player,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),

              // Карта
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleCard,
                    child: AnimatedBuilder(
                      animation: _flip,
                      builder: (_, __) {
                        final angle = _flip.value * pi;
                        final isFrontSide = angle <= (pi / 2);

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(angle),
                          child: _RoleCard(
                            isFront: isFrontSide,
                            frontText: player,
                            backText: role,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Text(
                _isFront
                    ? 'Натисни на карту, щоб побачити роль'
                    : 'Запамʼятай роль. Потім натисни “Далі”',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleCard,
                      child: Text(_isFront ? 'Показати роль' : 'Сховати роль'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPlayer,
                      child: Text(c.isLastReveal ? 'Почати' : 'Далі'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool isFront;
  final String frontText;
  final String backText;

  const _RoleCard({
    required this.isFront,
    required this.frontText,
    required this.backText,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    // Щоб текст на "задній" стороні не був дзеркальним, коли крутиться
    final child = isFront
        ? _CardFace(
            title: 'Твоє імʼя',
            big: frontText,
            hint: 'Натисни, щоб перевернути',
          )
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(pi),
            child: _CardFace(
              title: 'Твоя роль',
              big: backText,
              hint: 'Не кажи її вголос 😉',
            ),
          );

    return Container(
      width: 320,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.9),
            Colors.black.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String title;
  final String big;
  final String hint;

  const _CardFace({
    required this.title,
    required this.big,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.75)),
          ),
        ),
        const Spacer(),
        Text(
          big,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const Spacer(),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }
}
