class Message {
  final String id;
  final String conversationId;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime createdAt;
  final bool isStreaming;
  final String? errorMessage;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isStreaming': isStreaming,
        'errorMessage': errorMessage,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isStreaming: json['isStreaming'] as bool? ?? false,
        errorMessage: json['errorMessage'] as String?,
      );

  Message copyWith({
    String? content,
    bool? isStreaming,
    String? errorMessage,
  }) =>
      Message(
        id: id,
        conversationId: conversationId,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        isStreaming: isStreaming ?? this.isStreaming,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
