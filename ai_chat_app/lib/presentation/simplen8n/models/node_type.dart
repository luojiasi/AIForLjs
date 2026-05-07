import 'package:flutter/material.dart';

/// 节点分类
enum NodeCategory {
  trigger,
  action,
  logic,
  data,
  ai,
  database,
  notification,
  code,
  file,
  utility,
}

extension NodeCategoryExtension on NodeCategory {
  String get displayName {
    switch (this) {
      case NodeCategory.trigger:
        return 'Trigger';
      case NodeCategory.action:
        return 'Action';
      case NodeCategory.logic:
        return 'Logic';
      case NodeCategory.data:
        return 'Data';
      case NodeCategory.ai:
        return 'AI';
      case NodeCategory.database:
        return 'Database';
      case NodeCategory.notification:
        return 'Notification';
      case NodeCategory.code:
        return 'Code';
      case NodeCategory.file:
        return 'File';
      case NodeCategory.utility:
        return 'Utility';
    }
  }

  Color get color {
    switch (this) {
      case NodeCategory.trigger:
        return const Color(0xFF0066FF);
      case NodeCategory.action:
        return const Color(0xFF6B46EF);
      case NodeCategory.logic:
        return const Color(0xFFF59E0B);
      case NodeCategory.data:
        return const Color(0xFF10B981);
      case NodeCategory.ai:
        return const Color(0xFFEC4899);
      case NodeCategory.database:
        return const Color(0xFF06B6D4);
      case NodeCategory.notification:
        return const Color(0xFFEF4444);
      case NodeCategory.code:
        return const Color(0xFF6366F1);
      case NodeCategory.file:
        return const Color(0xFF8B5CF6);
      case NodeCategory.utility:
        return const Color(0xFF6B7280);
    }
  }

  IconData get icon {
    switch (this) {
      case NodeCategory.trigger:
        return Icons.flash_on;
      case NodeCategory.action:
        return Icons.play_arrow;
      case NodeCategory.logic:
        return Icons.account_tree;
      case NodeCategory.data:
        return Icons.transform;
      case NodeCategory.ai:
        return Icons.auto_awesome;
      case NodeCategory.database:
        return Icons.storage;
      case NodeCategory.notification:
        return Icons.notifications;
      case NodeCategory.code:
        return Icons.code;
      case NodeCategory.file:
        return Icons.folder;
      case NodeCategory.utility:
        return Icons.build;
    }
  }
}

/// 端口定义
class PortDefinition {
  final String id;
  final String name;
  final String? description;

  const PortDefinition({
    required this.id,
    required this.name,
    this.description,
  });
}

/// 节点参数 Schema
enum ParameterType {
  string,
  number,
  boolean,
  select,
  code,
  credential,
  expression,
  multiline,
  json,
}

class ParameterOption {
  final String label;
  final String value;

  const ParameterOption({required this.label, required this.value});
}

class ParameterSchema {
  final String name;
  final String displayName;
  final ParameterType type;
  final dynamic defaultValue;
  final bool required;
  final String? description;
  final List<ParameterOption>? options;
  final List<ParameterSchema>? fields;

  const ParameterSchema({
    required this.name,
    required this.displayName,
    this.type = ParameterType.string,
    this.defaultValue,
    this.required = false,
    this.description,
    this.options,
    this.fields,
  });
}

/// 节点类型定义 — 描述一个可注册的节点
class NodeTypeDefinition {
  final String type;
  final String displayName;
  final NodeCategory category;
  final List<PortDefinition> inputs;
  final List<PortDefinition> outputs;
  final List<ParameterSchema> parameterSchema;
  final String? description;

  const NodeTypeDefinition({
    required this.type,
    required this.displayName,
    required this.category,
    this.inputs = const [],
    this.outputs = const [],
    this.parameterSchema = const [],
    this.description,
  });

  Color get color => category.color;
  IconData get icon => category.icon;
}
