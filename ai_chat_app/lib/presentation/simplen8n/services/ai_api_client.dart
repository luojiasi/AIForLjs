import 'dart:convert';

import 'package:http/http.dart' as http;

/// Generic LLM API client supporting OpenAI-compatible and Anthropic-compatible
/// chat completion endpoints.
class AiApiClient {
  static const _defaultOpenAiBase = 'https://api.openai.com/v1';
  static const _defaultAnthropicBase = 'https://api.anthropic.com/v1';

  /// Send a chat completion request and return the assistant's text response.
  ///
  /// [provider] — `'openai'`, `'anthropic'`, `'deepseek'`, or a custom API kind.
  /// [modelId] — the model identifier (e.g. `'gpt-4o'`, `'claude-opus-4-7'`).
  /// [systemPrompt] — system-level instructions.
  /// [userMessage] — the user message text.
  /// [temperature] — 0.0–2.0 sampling temperature.
  /// [apiKey] — optional API key; when null or empty, no Authorization header is sent.
  /// [baseUrl] — override the provider's default base URL.
  /// [extraHeaders] — additional HTTP headers.
  Future<String> chat({
    required String provider,
    required String modelId,
    String systemPrompt = '',
    required String userMessage,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? apiKey,
    String? baseUrl,
    Map<String, String> extraHeaders = const {},
  }) async {
    final lowered = provider.toLowerCase();

    if (lowered == 'anthropic' || lowered == 'claude') {
      return _anthropicChat(
        modelId: modelId,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        temperature: temperature,
        maxTokens: maxTokens,
        apiKey: apiKey,
        baseUrl: baseUrl ?? _defaultAnthropicBase,
        extraHeaders: extraHeaders,
      );
    }

    // Default: OpenAI-compatible (openai, deepseek, custom, etc.)
    return _openAiCompatibleChat(
      modelId: modelId,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      temperature: temperature,
      maxTokens: maxTokens,
      apiKey: apiKey,
      baseUrl: baseUrl ?? _defaultOpenAiBase,
      extraHeaders: extraHeaders,
    );
  }

  // -- OpenAI-compatible (chat/completions) --

  Future<String> _openAiCompatibleChat({
    required String modelId,
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? apiKey,
    String? baseUrl,
    Map<String, String> extraHeaders = const {},
  }) async {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    messages.add({'role': 'user', 'content': userMessage});

    final body = {
      'model': modelId,
      'messages': messages,
      'temperature': temperature,
      if (maxTokens > 0) 'max_tokens': maxTokens,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    headers.addAll(extraHeaders);

    final uri = Uri.parse('$baseUrl/chat/completions');
    final response = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode >= 400) {
      throw AiApiException(
        'API returned status ${response.statusCode}: ${_truncate(response.body)}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiApiException('No choices in response: ${_truncate(response.body)}');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    return message?['content'] as String? ?? '';
  }

  // -- Anthropic-compatible (messages) --

  Future<String> _anthropicChat({
    required String modelId,
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? apiKey,
    String? baseUrl,
    Map<String, String> extraHeaders = const {},
  }) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'user', 'content': userMessage},
    ];

    final body = {
      'model': modelId,
      'messages': messages,
      'max_tokens': maxTokens > 0 ? maxTokens : 4096,
      'temperature': temperature,
    };
    if (systemPrompt.isNotEmpty) {
      body['system'] = systemPrompt;
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': apiKey ?? '',
      'anthropic-version': '2023-06-01',
    };
    headers.addAll(extraHeaders);

    final uri = Uri.parse('$baseUrl/messages');
    final response = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode >= 400) {
      throw AiApiException(
        'API returned status ${response.statusCode}: ${_truncate(response.body)}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) {
      throw AiApiException('No content in response: ${_truncate(response.body)}');
    }

    // Anthropic returns list of content blocks; extract text from the first one
    for (final block in content) {
      if (block is Map<String, dynamic> && block['type'] == 'text') {
        return block['text'] as String? ?? '';
      }
    }
    return content.first is Map ? (content.first as Map)['text']?.toString() ?? '' : '';
  }

  String _truncate(String s) => s.length > 300 ? '${s.substring(0, 300)}...' : s;
}

/// Exception thrown when the AI API returns an error.
class AiApiException implements Exception {
  final String message;
  final int? statusCode;

  const AiApiException(this.message, {this.statusCode});

  @override
  String toString() => 'AiApiException: $message';
}
