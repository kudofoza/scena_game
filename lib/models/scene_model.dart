class SceneModel {
  final String title;
  final String description;
  final List<String> roles;

  SceneModel({
    required this.title,
    required this.description,
    required this.roles,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      roles: (json['roles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
