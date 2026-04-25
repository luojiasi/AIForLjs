class Conversation {
  final String id;
  final String title;
  final String modelProviderId;
  final String modelName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.modelProviderId,
    required this.modelName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'modelProviderId': modelProviderId,
        'modelName': modelName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        title: json['title'] as String,
        modelProviderId: json['modelProviderId'] as String,
        modelName: json['modelName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Conversation copyWith({
    String? title,
    String? modelProviderId,
    String? modelName,
    DateTime? updatedAt,
  }) =>
      Conversation(
        id: id,
        title: title ?? this.title,
        modelProviderId: modelProviderId ?? this.modelProviderId,
        modelName: modelName ?? this.modelName,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
