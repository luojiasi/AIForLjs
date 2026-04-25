import 'message_model.dart';

class ChatRequest {
  final String modelName;
  final List<MessageModel> messages;
  final int? maxTokens;
  final double? temperature;
  final bool stream;

  const ChatRequest({
    required this.modelName,
    required this.messages,
    this.maxTokens,
    this.temperature,
    this.stream = true,
  });
}
