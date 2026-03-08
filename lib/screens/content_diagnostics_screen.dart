import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/base_basescaffold.dart';

class ContentDiagnosticsScreen extends StatefulWidget {
  const ContentDiagnosticsScreen({super.key});

  @override
  State<ContentDiagnosticsScreen> createState() =>
      _ContentDiagnosticsScreenState();
}

class _ContentDiagnosticsScreenState extends State<ContentDiagnosticsScreen> {
  bool _loading = true;
  final List<_DiagResult> _results = [];

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _loading = true;
      _results.clear();
    });

    for (int players = 3; players <= 12; players++) {
      final path = 'assets/scenes/scenes_$players.json';

      try {
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw);

        if (decoded is! List) {
          _results.add(
            _DiagResult(
              players: players,
              file: path,
              totalScenes: 0,
              validScenes: 0,
              errors: [
                'Файл не є JSON-масивом (має починатися з [ ... ])',
              ],
            ),
          );
          continue;
        }

        int ok = 0;
        final errors = <String>[];

        for (int i = 0; i < decoded.length; i++) {
          final item = decoded[i];

          if (item is! Map<String, dynamic>) {
            errors.add('Сцена #${i + 1}: не обʼєкт');
            continue;
          }

          final title = (item['title'] ?? 'Без назви').toString();
          final roles = item['roles'];

          if (roles is! List) {
            errors.add('“$title”: поле roles не є списком');
            continue;
          }

          if (roles.length != players) {
            errors.add(
              '“$title”: ролей ${roles.length}, а потрібно $players',
            );
            continue;
          }

          ok++;
        }

        _results.add(
          _DiagResult(
            players: players,
            file: path,
            totalScenes: decoded.length,
            validScenes: ok,
            errors: errors,
          ),
        );
      } catch (e) {
        _results.add(
          _DiagResult(
            players: players,
            file: path,
            totalScenes: 0,
            validScenes: 0,
            errors: ['Не вдалося прочитати файл: $e'],
          ),
        );
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Діагностика контенту'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _runDiagnostics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final r = _results[i];
                final hasErrors = r.errors.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.players} гравців — ${r.file}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Сцен: ${r.totalScenes} | Валідні: ${r.validScenes} | Помилок: ${r.errors.length}',
                        style: TextStyle(
                          color: hasErrors
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                        ),
                      ),
                      if (hasErrors) ...[
                        const SizedBox(height: 10),
                        ...r.errors.take(8).map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $e',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                        if (r.errors.length > 8)
                          Text(
                            '…і ще ${r.errors.length - 8} помилок',
                            style: const TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _DiagResult {
  final int players;
  final String file;
  final int totalScenes;
  final int validScenes;
  final List<String> errors;

  _DiagResult({
    required this.players,
    required this.file,
    required this.totalScenes,
    required this.validScenes,
    required this.errors,
  });
}
