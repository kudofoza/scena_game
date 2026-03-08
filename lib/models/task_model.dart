class TaskModel {
  final String text;

  TaskModel({required this.text});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(text: (json['text'] ?? '').toString());
  }
}
