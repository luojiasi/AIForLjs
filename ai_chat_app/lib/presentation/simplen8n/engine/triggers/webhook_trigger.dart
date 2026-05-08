import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/execution_data.dart';
import '../../models/workflow_model.dart';

/// HTTP-server based webhook trigger.
/// Each instance listens on its own port. Configure `port` in node parameters.
class WebhookTrigger {
  final String id;
  final WorkflowNode node;
  final Workflow workflow;
  final Future<void> Function(List<NodeExecutionData>) onFire;

  HttpServer? _server;

  WebhookTrigger({
    required this.id,
    required this.node,
    required this.workflow,
    required this.onFire,
  });

  int get port {
    final p = node.parameters['port'];
    if (p is int) return p;
    if (p is String) return int.tryParse(p) ?? 5678;
    return 5678;
  }

  String get httpMethod {
    final m = node.parameters['httpMethod'] as String? ?? 'POST';
    return m.toUpperCase();
  }

  String get responseData {
    return node.parameters['responseData'] as String? ?? '{"ok":true}';
  }

  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      _server!.listen(_handleRequest);
    } catch (e) {
      // Port may already be in use — that's OK, another trigger may own it.
      // We re-throw so the caller can log it.
      rethrow;
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    // Only match the configured HTTP method (or any if method is 'ANY')
    if (httpMethod != 'ANY' && request.method.toUpperCase() != httpMethod) {
      request.response.statusCode = 405;
      request.response.write('Method Not Allowed');
      await request.response.close();
      return;
    }

    // Parse body
    String bodyStr = '';
    final bodyBytes = await request.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
    if (bodyBytes.isNotEmpty) {
      bodyStr = utf8.decode(bodyBytes);
    }

    // Parse JSON body if possible
    dynamic parsedBody = bodyStr;
    if (bodyStr.isNotEmpty) {
      try {
        parsedBody = jsonDecode(bodyStr);
      } catch (_) {
        // Keep as string
      }
    }

    // Build headers map
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });

    // Build query params
    final queryParams = <String, String>{};
    request.uri.queryParameters.forEach((k, v) {
      queryParams[k] = v;
    });

    final data = NodeExecutionData(json: {
      'trigger': 'webhook',
      'method': request.method,
      'path': request.uri.path,
      'queryParams': queryParams,
      'headers': headers,
      'body': parsedBody,
      'receivedAt': DateTime.now().toIso8601String(),
    });

    // Fire trigger
    await onFire([data]);

    // Send response
    request.response.statusCode = 200;
    request.response.headers.contentType = ContentType.json;
    request.response.write(responseData);
    await request.response.close();
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
