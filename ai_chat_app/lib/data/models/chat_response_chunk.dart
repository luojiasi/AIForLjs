class ChatResponseChunk {
  final String deltaContent;
  final String? finishReason;
  final int? inputTokens;
  final int? outputTokens;

  const ChatResponseChunk({
    required this.deltaContent,
    this.finishReason,
    this.inputTokens,
    this.outputTokens,
  });
}
