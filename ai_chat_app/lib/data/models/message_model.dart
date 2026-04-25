class MessageModel {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;

  const MessageModel({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}
