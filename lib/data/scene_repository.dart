import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scene_model.dart';

class SceneRepository {
  Future<List<SceneModel>> loadScenesForPlayerCount(int players) async {
    final path = 'assets/scenes/scenes_$players.json';
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => SceneModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
