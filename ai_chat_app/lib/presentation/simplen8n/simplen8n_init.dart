import 'models/node_type.dart';
import 'nodes/node_registry.dart';
import 'engine/executor_registry.dart';
import 'engine/executors/manual_trigger_executor.dart';
import 'engine/executors/http_request_executor.dart';
import 'engine/executors/set_executor.dart';
import 'engine/executors/if_executor.dart';
import 'engine/executors/merge_executor.dart';
import 'engine/executors/ai_chat_executor.dart';
import 'engine/executors/webhook_trigger_executor.dart';
import 'engine/executors/cron_trigger_executor.dart';
import 'engine/executors/error_trigger_executor.dart';
import 'engine/executors/execute_workflow_executor.dart';

/// 初始化 simplen8n — 注册所有节点类型和 executor
void initSimplen8n() {
  final registry = NodeRegistry.instance;
  final execRegistry = ExecutorRegistry.instance;

  // 只在空注册表时初始化
  if (registry.all.isNotEmpty) return;

  // 注册 executor
  execRegistry.registerAll([
    ManualTriggerExecutor(),
    HttpRequestExecutor(),
    SetExecutor(),
    IfExecutor(),
    MergeExecutor(),
    AiChatExecutor(),
    WebhookTriggerExecutor(),
    CronTriggerExecutor(),
    ErrorTriggerExecutor(),
    ExecuteWorkflowExecutor(),
  ]);

  // Phase 0: 注册 3 个核心节点类型
  registry.registerAll([
    // Manual Trigger
    const NodeTypeDefinition(
      type: 'manual_trigger',
      displayName: 'Manual Trigger',
      category: NodeCategory.trigger,
      inputs: [],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [],
      description: 'Manually start the workflow execution.',
    ),

    // HTTP Request
    const NodeTypeDefinition(
      type: 'http_request',
      displayName: 'HTTP Request',
      category: NodeCategory.action,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'method',
          displayName: 'Method',
          type: ParameterType.select,
          defaultValue: 'GET',
          options: [
            ParameterOption(label: 'GET', value: 'GET'),
            ParameterOption(label: 'POST', value: 'POST'),
            ParameterOption(label: 'PUT', value: 'PUT'),
            ParameterOption(label: 'DELETE', value: 'DELETE'),
            ParameterOption(label: 'PATCH', value: 'PATCH'),
          ],
        ),
        ParameterSchema(
          name: 'url',
          displayName: 'URL',
          type: ParameterType.string,
          required: true,
          description: 'The URL to send the request to',
        ),
        ParameterSchema(
          name: 'headers',
          displayName: 'Headers',
          type: ParameterType.json,
          defaultValue: '{}',
          description: 'HTTP headers as JSON object',
        ),
        ParameterSchema(
          name: 'body',
          displayName: 'Body',
          type: ParameterType.multiline,
          defaultValue: '',
          description: 'Request body (for POST/PUT/PATCH)',
        ),
      ],
      description: 'Send an HTTP request to any URL.',
    ),

    // Set
    const NodeTypeDefinition(
      type: 'set',
      displayName: 'Set',
      category: NodeCategory.data,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'values',
          displayName: 'Values',
          type: ParameterType.json,
          defaultValue: '{}',
          description: 'Key-value pairs to set. Values support {{ \$json.field }} expressions.',
        ),
      ],
      description: 'Set or modify JSON fields.',
    ),

    // IF — Conditional branch
    const NodeTypeDefinition(
      type: 'if',
      displayName: 'IF',
      category: NodeCategory.logic,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [
        PortDefinition(id: 'true', name: 'True'),
        PortDefinition(id: 'false', name: 'False'),
      ],
      parameterSchema: [
        ParameterSchema(
          name: 'condition',
          displayName: 'Condition',
          type: ParameterType.expression,
          required: true,
          description: 'Expression to evaluate. Use \$json.field, \$vars.*, etc.',
        ),
      ],
      description: 'Branch workflow execution based on a condition.',
    ),

    // Merge — Multi-input aggregation
    const NodeTypeDefinition(
      type: 'merge',
      displayName: 'Merge',
      category: NodeCategory.utility,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'mode',
          displayName: 'Mode',
          type: ParameterType.select,
          defaultValue: 'combine',
          options: [
            ParameterOption(label: 'Combine', value: 'combine'),
            ParameterOption(label: 'Pass Through', value: 'passThrough'),
          ],
          description: 'How to merge multiple inputs.',
        ),
      ],
      description: 'Merge multiple branches into one. Waits for all inputs then combines them.',
    ),

    // AI Chat
    const NodeTypeDefinition(
      type: 'ai_chat',
      displayName: 'AI Chat',
      category: NodeCategory.ai,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'provider',
          displayName: 'Provider',
          type: ParameterType.select,
          defaultValue: 'openai',
          options: [
            ParameterOption(label: 'OpenAI', value: 'openai'),
            ParameterOption(label: 'Anthropic', value: 'anthropic'),
            ParameterOption(label: 'DeepSeek', value: 'deepseek'),
            ParameterOption(label: 'Custom', value: 'custom'),
          ],
          description: 'AI API provider type.',
        ),
        ParameterSchema(
          name: 'model',
          displayName: 'Model ID',
          type: ParameterType.string,
          defaultValue: 'gpt-4o',
          required: true,
          description: 'Model identifier (e.g. gpt-4o, claude-sonnet-4-6, deepseek-chat).',
        ),
        ParameterSchema(
          name: 'systemPrompt',
          displayName: 'System Prompt',
          type: ParameterType.multiline,
          defaultValue: '',
          description: 'System-level instructions. Supports {{ \$json.field }} expressions.',
        ),
        ParameterSchema(
          name: 'userMessage',
          displayName: 'User Message',
          type: ParameterType.multiline,
          defaultValue: '',
          required: true,
          description: 'The user message to send. Supports {{ \$json.field }} expressions.',
        ),
        ParameterSchema(
          name: 'temperature',
          displayName: 'Temperature',
          type: ParameterType.number,
          defaultValue: 0.7,
          description: 'Sampling temperature (0.0–2.0).',
        ),
        ParameterSchema(
          name: 'maxTokens',
          displayName: 'Max Tokens',
          type: ParameterType.number,
          defaultValue: 4096,
          description: 'Maximum tokens in the response.',
        ),
        ParameterSchema(
          name: 'apiKey',
          displayName: 'API Key',
          type: ParameterType.string,
          defaultValue: '',
          description: 'API key. Leave empty for local models or to use env-configured keys.',
        ),
        ParameterSchema(
          name: 'baseUrl',
          displayName: 'Base URL',
          type: ParameterType.string,
          defaultValue: '',
          description: 'Custom API base URL. Leave empty to use the provider default.',
        ),
      ],
      description: 'Send a chat message to an AI model and get its response. Supports OpenAI, Anthropic, and DeepSeek.',
    ),

    // Webhook Trigger
    const NodeTypeDefinition(
      type: 'webhook_trigger',
      displayName: 'Webhook',
      category: NodeCategory.trigger,
      inputs: [],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'httpMethod',
          displayName: 'HTTP Method',
          type: ParameterType.select,
          defaultValue: 'POST',
          options: [
            ParameterOption(label: 'GET', value: 'GET'),
            ParameterOption(label: 'POST', value: 'POST'),
            ParameterOption(label: 'PUT', value: 'PUT'),
            ParameterOption(label: 'DELETE', value: 'DELETE'),
            ParameterOption(label: 'ANY', value: 'ANY'),
          ],
          description: 'HTTP method to listen for.',
        ),
        ParameterSchema(
          name: 'port',
          displayName: 'Port',
          type: ParameterType.number,
          defaultValue: 5678,
          required: true,
          description: 'Local port to listen on (127.0.0.1).',
        ),
        ParameterSchema(
          name: 'responseData',
          displayName: 'Response Body',
          type: ParameterType.multiline,
          defaultValue: '{"ok":true}',
          description: 'JSON response body sent back to the caller.',
        ),
      ],
      description: 'Listen for incoming HTTP requests on a local port. Activates the workflow on each request.',
    ),

    // Cron Trigger
    const NodeTypeDefinition(
      type: 'cron_trigger',
      displayName: 'Cron',
      category: NodeCategory.trigger,
      inputs: [],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'cronExpression',
          displayName: 'Cron Expression',
          type: ParameterType.string,
          defaultValue: '*/5 * * * *',
          required: true,
          description: 'Standard 5-field cron: minute hour dayOfMonth month dayOfWeek. E.g. "0 9 * * 1-5" for weekdays at 9am.',
        ),
      ],
      description: 'Run the workflow on a repeating schedule via cron expression.',
    ),

    // Error Trigger
    const NodeTypeDefinition(
      type: 'error_trigger',
      displayName: 'Error Trigger',
      category: NodeCategory.trigger,
      inputs: [],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'errorTypes',
          displayName: 'Error Types',
          type: ParameterType.select,
          defaultValue: 'all',
          options: [
            ParameterOption(label: 'All Errors', value: 'all'),
            ParameterOption(label: 'Workflow Errors Only', value: 'workflow'),
            ParameterOption(label: 'Node Errors Only', value: 'node'),
          ],
          description: 'Which error types will trigger this workflow.',
        ),
      ],
      description: 'Triggers when another workflow fails. The failed execution data is passed as input.',
    ),

    // Execute Workflow
    const NodeTypeDefinition(
      type: 'execute_workflow',
      displayName: 'Execute Workflow',
      category: NodeCategory.action,
      inputs: [PortDefinition(id: 'input', name: 'Input')],
      outputs: [PortDefinition(id: 'output', name: 'Output')],
      parameterSchema: [
        ParameterSchema(
          name: 'workflowId',
          displayName: 'Target Workflow',
          type: ParameterType.select,
          required: true,
          options: [], // populated from saved workflows in the UI
          description: 'The child workflow to execute.',
        ),
        ParameterSchema(
          name: 'mode',
          displayName: 'Mode',
          type: ParameterType.select,
          defaultValue: 'waitForResult',
          options: [
            ParameterOption(label: 'Wait for Result', value: 'waitForResult'),
            ParameterOption(label: 'Fire and Forget', value: 'fireAndForget'),
          ],
          description: 'Whether to wait for the child workflow result or fire and continue.',
        ),
      ],
      description: 'Call another saved workflow and receive its output. Enables workflow composition.',
    ),
  ]);
}
