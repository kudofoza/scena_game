import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/task_model.dart';

class TaskRepository {
  Future<List<TaskModel>> loadTasks() async {
    final raw = await rootBundle.loadString('assets/tasks/tasks.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
