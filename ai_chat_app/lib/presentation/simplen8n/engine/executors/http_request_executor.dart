import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';
import '../exceptions.dart';

class HttpRequestExecutor implements INodeExecutor {
  @override
  String get nodeType => 'http_request';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final method = node.parameters['method'] as String? ?? 'GET';
    final rawUrl = node.parameters['url'] as String? ?? '';
    final url = context.evaluateTemplate(rawUrl);

    Map<String, String> headers = {};
    try {
      final raw = node.parameters['headers'] as String? ?? '{}';
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      headers = parsed.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {}

    String? body;
    if (node.parameters['body'] is String &&
        (node.parameters['body'] as String).isNotEmpty) {
      body = context.evaluateTemplate(node.parameters['body'] as String);
    }

    final uri = Uri.parse(url);
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: body);
          break;
        default:
          throw NodeExecutionException(
            'Unsupported HTTP method: $method',
            nodeId: node.id,
            nodeType: node.type,
          );
      }
    } catch (e) {
      if (e is NodeExecutionException) rethrow;
      throw HttpRequestException(
        'HTTP request failed: $e',
        nodeId: node.id,
        nodeType: node.type,
      );
    }

    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = response.body;
    }

    return [
      NodeExecutionData(json: {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
      }),
    ];
  }
}
