import 'round_log.dart';

class ArchivedSession {
  final DateTime startedAt;
  final DateTime endedAt;
  final List<String> players;
  final Map<String, int> losesByPlayer;
  final List<RoundLog> roundLogs;

  ArchivedSession({
    required this.startedAt,
    required this.endedAt,
    required this.players,
    required this.losesByPlayer,
    required this.roundLogs,
  });
}
