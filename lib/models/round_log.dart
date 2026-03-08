class RoundLog {
  final String sceneTitle;
  final String loser;
  final Map<String, int> votesSnapshot;

  RoundLog({
    required this.sceneTitle,
    required this.loser,
    required this.votesSnapshot,
  });
}
