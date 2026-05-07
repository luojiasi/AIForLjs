import 'models/node_type.dart';
import 'nodes/node_registry.dart';

/// 初始化 simplen8n — 注册所有节点类型
void initSimplen8n() {
  final registry = NodeRegistry.instance;

  // 只在空注册表时初始化
  if (registry.all.isNotEmpty) return;

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
  ]);
}
