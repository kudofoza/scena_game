import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/scene_repository.dart';
import '../data/task_repository.dart';
import '../models/scene_model.dart';
import '../models/task_model.dart';
import '../models/session_stats.dart';
import '../models/round_log.dart';
import '../models/archived_session.dart';

class GameController {
  static const _storageKey = 'scene_app_state_v1';

  final _rng = Random();
  final SceneRepository sceneRepo;
  final TaskRepository taskRepo;

  GameController({
    required this.sceneRepo,
    required this.taskRepo,
  });

  // -------- SETTINGS --------
  int playersCount = 3;
  int minutes = 2;
  List<String> players = [];

  // -------- SCENE / ROLES --------
  SceneModel? currentScene;
  late Map<String, String> roleByPlayer;
  int roleRevealIndex = 0;

  // -------- VOTING --------
  int voteIndex = 0;
  final Map<String, int> votesForPlayer = {};

  // -------- TASKS --------
  List<TaskModel> tasks = [];

  // -------- SESSION --------
  final SessionStats sessionStats = SessionStats();
  final List<RoundLog> roundLogs = [];
  DateTime? currentSessionStartedAt;
  final List<ArchivedSession> archivedSessions = [];

  // -------- ANTI-REPEAT --------
  final Set<String> usedSceneTitles = {};
  int skipsLeft = 3;

  // -------- INIT --------
  Future<void> initAssets() async {
    tasks = await taskRepo.loadTasks();
    await _loadFromStorage();
  }

  bool get hasActiveSession =>
      currentSessionStartedAt != null && players.isNotEmpty;

  void beginSessionIfNeeded() {
    currentSessionStartedAt ??= DateTime.now();
  }

  // -------- STORAGE --------
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'currentSession': {
        'startedAt': currentSessionStartedAt?.toIso8601String(),
        'playersCount': playersCount,
        'minutes': minutes,
        'players': players,
        'losesByPlayer': sessionStats.losesByPlayer,
        'roundLogs': roundLogs.map(_roundLogToJson).toList(),
        'usedSceneTitles': usedSceneTitles.toList(),
        'skipsLeft': skipsLeft,
      },
      'archivedSessions':
          archivedSessions.map(_archivedToJson).toList(),
    };

    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final current = decoded['currentSession'];

    if (current != null) {
      currentSessionStartedAt = current['startedAt'] == null
          ? null
          : DateTime.tryParse(current['startedAt']);

      playersCount = current['playersCount'] ?? 3;
      minutes = current['minutes'] ?? 2;
      players = List<String>.from(current['players'] ?? []);

      usedSceneTitles
        ..clear()
        ..addAll(List<String>.from(current['usedSceneTitles'] ?? []));

      skipsLeft = current['skipsLeft'] ?? 3;

      sessionStats.losesByPlayer.clear();
      (current['losesByPlayer'] as Map<String, dynamic>?)
          ?.forEach((k, v) {
        sessionStats.losesByPlayer[k] = v;
      });

      roundLogs.clear();
      (current['roundLogs'] as List<dynamic>?)?.forEach((e) {
        roundLogs.add(_roundLogFromJson(e));
      });
    }

    archivedSessions.clear();
    (decoded['archivedSessions'] as List<dynamic>?)?.forEach((e) {
      archivedSessions.add(_archivedFromJson(e));
    });
  }

  // -------- SESSION CONTROL --------
  Future<void> updateCurrentSessionPlayers(List<String> newPlayers) async {
    players = newPlayers;
    playersCount = newPlayers.length.clamp(3, 12);

    sessionStats.losesByPlayer.removeWhere(
        (key, _) => !players.contains(key));
    for (final p in players) {
      sessionStats.losesByPlayer[p] ??= 0;
    }

    await _saveToStorage();
  }

  Future<void> endCurrentSession() async {
    if (players.isNotEmpty) {
      archivedSessions.add(
        ArchivedSession(
          startedAt: currentSessionStartedAt ?? DateTime.now(),
          endedAt: DateTime.now(),
          players: List.from(players),
          losesByPlayer:
              Map.from(sessionStats.losesByPlayer),
          roundLogs: List.from(roundLogs),
        ),
      );
    }

    players.clear();
    usedSceneTitles.clear();
    skipsLeft = 3;
    sessionStats.losesByPlayer.clear();
    roundLogs.clear();
    currentSessionStartedAt = null;

    await _saveToStorage();
  }

  // -------- ROUND --------
  Future<void> startNewRound() async {
    beginSessionIfNeeded();

    final scenes =
        await sceneRepo.loadScenesForPlayerCount(playersCount);
    if (scenes.isEmpty) throw StateError('Немає сцен');

    if (usedSceneTitles.length >= scenes.length) {
      usedSceneTitles.clear();
    }

    final available = scenes
        .where((s) => !usedSceneTitles.contains(s.title))
        .toList();

    available.shuffle(_rng);
    currentScene = available.first;
    usedSceneTitles.add(currentScene!.title);

    final roles = List<String>.from(currentScene!.roles)
      ..shuffle(_rng);

    roleByPlayer = {
      for (int i = 0; i < players.length; i++)
        players[i]: roles[i]
    };

    roleRevealIndex = 0;
    voteIndex = 0;
    votesForPlayer.clear();

    await _saveToStorage();
  }

  Future<void> skipScene() async {
    if (skipsLeft <= 0) return;
    skipsLeft--;
    await startNewRound();
  }

  // -------- ROLE REVEAL --------
  String get currentRevealPlayer => players[roleRevealIndex];
  String getRoleForPlayer(String player) =>
      roleByPlayer[player] ?? '—';
  bool get isLastReveal =>
      roleRevealIndex >= players.length - 1;
  void nextReveal() {
    if (!isLastReveal) roleRevealIndex++;
  }

  // -------- VOTING --------
  String get currentVoter => players[voteIndex];
  List<String> get candidatesForCurrentVoter =>
      players.where((p) => p != currentVoter).toList();

  void voteFor(String candidate) {
    votesForPlayer[candidate] =
        (votesForPlayer[candidate] ?? 0) + 1;
  }

  bool get isLastVoter =>
      voteIndex >= players.length - 1;
  void nextVoter() {
    if (!isLastVoter) voteIndex++;
  }

  Future<String> resolveRoundLoser() async {
    int max = -1;
    final losers = <String>[];

    for (final p in players) {
      final v = votesForPlayer[p] ?? 0;
      if (v > max) {
        max = v;
        losers
          ..clear()
          ..add(p);
      } else if (v == max) {
        losers.add(p);
      }
    }

    final loser = losers[_rng.nextInt(losers.length)];
    sessionStats.addLose(loser);

    roundLogs.add(
      RoundLog(
        sceneTitle: currentScene!.title,
        loser: loser,
        votesSnapshot: Map.from(votesForPlayer),
      ),
    );

    await _saveToStorage();
    return loser;
  }

  // -------- TASK --------
  TaskModel getRandomTask() =>
      tasks[_rng.nextInt(tasks.length)];

  // -------- JSON HELPERS --------
  Map<String, dynamic> _roundLogToJson(RoundLog r) => {
        'sceneTitle': r.sceneTitle,
        'loser': r.loser,
        'votesSnapshot': r.votesSnapshot,
      };

  RoundLog _roundLogFromJson(Map<String, dynamic> j) =>
      RoundLog(
        sceneTitle: j['sceneTitle'],
        loser: j['loser'],
        votesSnapshot:
            Map<String, int>.from(j['votesSnapshot']),
      );

  Map<String, dynamic> _archivedToJson(ArchivedSession s) => {
        'startedAt': s.startedAt.toIso8601String(),
        'endedAt': s.endedAt.toIso8601String(),
        'players': s.players,
        'losesByPlayer': s.losesByPlayer,
        'roundLogs':
            s.roundLogs.map(_roundLogToJson).toList(),
      };

  ArchivedSession _archivedFromJson(Map<String, dynamic> j) =>
      ArchivedSession(
        startedAt: DateTime.parse(j['startedAt']),
        endedAt: DateTime.parse(j['endedAt']),
        players: List<String>.from(j['players']),
        losesByPlayer:
            Map<String, int>.from(j['losesByPlayer']),
        roundLogs: (j['roundLogs'] as List)
            .map((e) => _roundLogFromJson(e))
            .toList(),
      );
}
