class SessionStats {
  final Map<String, int> losesByPlayer = {};

  void addLose(String playerName) {
    losesByPlayer[playerName] = (losesByPlayer[playerName] ?? 0) + 1;
  }

  String? getTopLoser() {
    if (losesByPlayer.isEmpty) return null;
    String top = losesByPlayer.keys.first;
    for (final k in losesByPlayer.keys) {
      if ((losesByPlayer[k] ?? 0) > (losesByPlayer[top] ?? 0)) top = k;
    }
    return top;
  }
}
