import 'dart:developer' as developer;

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';
import '../../services/ai_api_client.dart';

class AiChatExecutor implements INodeExecutor {
  final AiApiClient _client;

  AiChatExecutor({AiApiClient? client}) : _client = client ?? AiApiClient();

  @override
  String get nodeType => 'ai_chat';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final provider = node.parameters['provider'] as String? ?? 'openai';
    final modelId = node.parameters['model'] as String? ?? 'gpt-4o';
    final rawSystemPrompt = node.parameters['systemPrompt'] as String? ?? '';
    final rawUserMessage = node.parameters['userMessage'] as String? ?? '';
    final temperature =
        (node.parameters['temperature'] as num?)?.toDouble() ?? 0.7;
    final maxTokens = (node.parameters['maxTokens'] as num?)?.toInt() ?? 4096;
    final apiKey = node.parameters['apiKey'] as String?;
    final baseUrl = node.parameters['baseUrl'] as String?;

    // Evaluate template expressions in prompts
    final systemPrompt = rawSystemPrompt.isNotEmpty
        ? context.evaluateTemplate(rawSystemPrompt)
        : '';
    final userMessage = rawUserMessage.isNotEmpty
        ? context.evaluateTemplate(rawUserMessage)
        : '';

    developer.log('[AI Chat] provider=$provider model=$modelId '
        'temperature=$temperature maxTokens=$maxTokens');

    final response = await _client.chat(
      provider: provider,
      modelId: modelId,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      temperature: temperature,
      maxTokens: maxTokens,
      apiKey: apiKey,
      baseUrl: baseUrl,
    );

    developer.log('[AI Chat] response length: ${response.length}');

    // Merge with current input so downstream nodes can access both
    final output = {
      ...context.currentInput,
      'response': response,
      'model': modelId,
      'provider': provider,
    };

    return [NodeExecutionData(json: output)];
  }
}
