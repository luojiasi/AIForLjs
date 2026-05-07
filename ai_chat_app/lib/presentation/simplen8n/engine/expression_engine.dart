import 'dart:math';

/// 表达式 Token 类型
enum TokenType {
  // 字面量
  stringLiteral,
  numberLiteral,
  boolLiteral,
  nullLiteral,
  // 标识符 + 特殊变量
  identifier,
  dollar,
  // 分隔符
  dot,
  comma,
  colon,
  question,
  openParen,
  closeParen,
  openBracket,
  closeBracket,
  openBrace,
  closeBrace,
  // 运算符
  plus,
  minus,
  multiply,
  divide,
  modulo,
  equal,
  notEqual,
  greater,
  less,
  greaterEqual,
  lessEqual,
  and,
  or,
  not,
  nullCoalescing,
  // EOF
  eof,
}

/// Token 数据结构
class Token {
  final TokenType type;
  final String lexeme;
  final dynamic literal;

  const Token(this.type, {this.lexeme = '', this.literal});
}

/// 表达式词法分析器
class ExpressionLexer {
  final String _source;
  int _pos = 0;

  ExpressionLexer(this._source);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < _source.length) {
      final ch = _peek();
      if (ch == null) break;

      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
        _advance();
        continue;
      }

      // 数字
      if (ch == '0' || ch == '1' || ch == '2' || ch == '3' || ch == '4' ||
          ch == '5' || ch == '6' || ch == '7' || ch == '8' || ch == '9') {
        tokens.add(_readNumber());
        continue;
      }

      // 字符串
      if (ch == "'") {
        tokens.add(_readString("'"));
        continue;
      }
      if (ch == '"') {
        tokens.add(_readString('"'));
        continue;
      }

      // 运算符 + 分隔符
      switch (ch) {
        case '.':
          _advance();
          tokens.add(const Token(TokenType.dot, lexeme: '.'));
          break;
        case ',':
          _advance();
          tokens.add(const Token(TokenType.comma, lexeme: ','));
          break;
        case ':':
          _advance();
          tokens.add(const Token(TokenType.colon, lexeme: ':'));
          break;
        case '?':
          _advance();
          if (_peek() == '?') {
            _advance();
            tokens.add(const Token(TokenType.nullCoalescing, lexeme: '??'));
          } else {
            tokens.add(const Token(TokenType.question, lexeme: '?'));
          }
          break;
        case '(':
          _advance();
          tokens.add(const Token(TokenType.openParen, lexeme: '('));
          break;
        case ')':
          _advance();
          tokens.add(const Token(TokenType.closeParen, lexeme: ')'));
          break;
        case '[':
          _advance();
          tokens.add(const Token(TokenType.openBracket, lexeme: '['));
          break;
        case ']':
          _advance();
          tokens.add(const Token(TokenType.closeBracket, lexeme: ']'));
          break;
        case '+':
          _advance();
          tokens.add(const Token(TokenType.plus, lexeme: '+'));
          break;
        case '-':
          _advance();
          tokens.add(const Token(TokenType.minus, lexeme: '-'));
          break;
        case '*':
          _advance();
          tokens.add(const Token(TokenType.multiply, lexeme: '*'));
          break;
        case '/':
          _advance();
          tokens.add(const Token(TokenType.divide, lexeme: '/'));
          break;
        case '%':
          _advance();
          tokens.add(const Token(TokenType.modulo, lexeme: '%'));
          break;
        case '!':
          _advance();
          if (_peek() == '=') {
            _advance();
            tokens.add(const Token(TokenType.notEqual, lexeme: '!='));
          } else {
            tokens.add(const Token(TokenType.not, lexeme: '!'));
          }
          break;
        case '=':
          _advance();
          if (_peek() == '=') {
            _advance();
            tokens.add(const Token(TokenType.equal, lexeme: '=='));
          } else {
            // 单 = 暂不支持，抛异常
            throw FormatException('Unexpected "=" at $_pos');
          }
          break;
        case '>':
          _advance();
          if (_peek() == '=') {
            _advance();
            tokens.add(const Token(TokenType.greaterEqual, lexeme: '>='));
          } else {
            tokens.add(const Token(TokenType.greater, lexeme: '>'));
          }
          break;
        case '<':
          _advance();
          if (_peek() == '=') {
            _advance();
            tokens.add(const Token(TokenType.lessEqual, lexeme: '<='));
          } else {
            tokens.add(const Token(TokenType.less, lexeme: '<'));
          }
          break;
        case '&':
          _advance();
          if (_peek() == '&') {
            _advance();
            tokens.add(const Token(TokenType.and, lexeme: '&&'));
          }
          break;
        case '|':
          _advance();
          if (_peek() == '|') {
            _advance();
            tokens.add(const Token(TokenType.or, lexeme: '||'));
          }
          break;
        case '\$':
          _advance();
          tokens.add(const Token(TokenType.dollar, lexeme: '\$'));
          break;
        default:
          if (_isAlpha(ch)) {
            tokens.add(_readIdentifier());
          } else {
            throw FormatException(
                'Unexpected character "$ch" at position $_pos');
          }
      }
    }
    tokens.add(const Token(TokenType.eof));
    return tokens;
  }

  Token _readNumber() {
    final start = _pos;
    while (_peek() != null && (_isDigit(_peek()!) || _peek() == '.')) {
      _advance();
    }
    final lexeme = _source.substring(start, _pos);
    final num = double.tryParse(lexeme) ?? int.tryParse(lexeme) ?? 0;
    return Token(TokenType.numberLiteral, lexeme: lexeme, literal: num);
  }

  Token _readString(String quote) {
    _advance(); // skip opening quote
    final start = _pos;
    while (_peek() != null && _peek() != quote) {
      if (_peek() == '\\') _advance();
      _advance();
    }
    final lexeme = _source.substring(start, _pos);
    if (_peek() == quote) _advance(); // skip closing quote
    return Token(TokenType.stringLiteral, lexeme: lexeme, literal: lexeme);
  }

  Token _readIdentifier() {
    final start = _pos;
    while (_peek() != null && (_isAlphaNum(_peek()!) || _peek() == '_')) {
      _advance();
    }
    final lexeme = _source.substring(start, _pos);
    switch (lexeme) {
      case 'true':
        return Token(TokenType.boolLiteral, lexeme: lexeme, literal: true);
      case 'false':
        return Token(TokenType.boolLiteral, lexeme: lexeme, literal: false);
      case 'null':
        return Token(TokenType.nullLiteral, lexeme: lexeme);
      default:
        return Token(TokenType.identifier, lexeme: lexeme);
    }
  }

  String? _peek() => _pos < _source.length ? _source[_pos] : null;
  void _advance() => _pos++;
  bool _isDigit(String s) =>
      s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  bool _isAlpha(String s) {
    final c = s.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }

  bool _isAlphaNum(String s) => _isAlpha(s) || _isDigit(s);
}

// ============================================================================
// AST 节点
// ============================================================================

abstract class AstNode {
  dynamic evaluate(Map<String, dynamic> context);
}

class LiteralNode extends AstNode {
  final dynamic value;
  LiteralNode(this.value);

  @override
  dynamic evaluate(Map<String, dynamic> context) => value;
}

class VariableNode extends AstNode {
  final String path;

  VariableNode(this.path);

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    final parts = path.split('.');
    dynamic current = context;
    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final idx = int.parse(part);
        if (idx < current.length) {
          current = current[idx];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }
}

class BinaryOpNode extends AstNode {
  final AstNode left;
  final TokenType op;
  final AstNode right;

  BinaryOpNode(this.left, this.op, this.right);

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    final l = left.evaluate(context);
    final r = right.evaluate(context);
    switch (op) {
      case TokenType.plus:
        if (l is String || r is String) return '${l ?? ''}${r ?? ''}';
        return _num(l) + _num(r);
      case TokenType.minus:
        return _num(l) - _num(r);
      case TokenType.multiply:
        return _num(l) * _num(r);
      case TokenType.divide:
        return _num(l) / _num(r);
      case TokenType.modulo:
        return _num(l) % _num(r);
      case TokenType.equal:
        return l == r;
      case TokenType.notEqual:
        return l != r;
      case TokenType.greater:
        return _num(l) > _num(r);
      case TokenType.less:
        return _num(l) < _num(r);
      case TokenType.greaterEqual:
        return _num(l) >= _num(r);
      case TokenType.lessEqual:
        return _num(l) <= _num(r);
      case TokenType.and:
        return _bool(l) && _bool(r);
      case TokenType.or:
        return _bool(l) || _bool(r);
      case TokenType.nullCoalescing:
        return l ?? r;
      default:
        return null;
    }
  }

  num _num(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '0') ?? 0;
  }

  bool _bool(dynamic v) {
    if (v is bool) return v;
    return v != null && v != false && v != 0 && v != '';
  }
}

class UnaryOpNode extends AstNode {
  final TokenType op;
  final AstNode operand;

  UnaryOpNode(this.op, this.operand);

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    final v = operand.evaluate(context);
    switch (op) {
      case TokenType.minus:
        return -(num.tryParse(v?.toString() ?? '0') ?? 0);
      case TokenType.not:
        return !(v is bool ? v : (v != null && v != false));
      default:
        return null;
    }
  }
}

class TernaryNode extends AstNode {
  final AstNode condition;
  final AstNode thenExpr;
  final AstNode elseExpr;

  TernaryNode(this.condition, this.thenExpr, this.elseExpr);

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    final cond = condition.evaluate(context);
    return (cond == true || cond != null && cond != false)
        ? thenExpr.evaluate(context)
        : elseExpr.evaluate(context);
  }
}

class FunctionCallNode extends AstNode {
  final String name;
  final List<AstNode> args;

  FunctionCallNode(this.name, this.args);

  @override
  dynamic evaluate(Map<String, dynamic> context) {
    final evaluatedArgs = args.map((a) => a.evaluate(context)).toList();
    switch (name) {
      case 'now':
        return DateTime.now().toIso8601String();
      case 'randomInt':
        final min = (evaluatedArgs.isNotEmpty ? evaluatedArgs[0] : 0) as int? ?? 0;
        final max = (evaluatedArgs.length > 1 ? evaluatedArgs[1] : 100) as int? ?? 100;
        return min + Random().nextInt(max - min + 1);
      case 'len':
        final val = evaluatedArgs.isNotEmpty ? evaluatedArgs[0] : null;
        if (val is List) return val.length;
        if (val is String) return val.length;
        return 0;
      case 'upper':
        return (evaluatedArgs.isNotEmpty ? evaluatedArgs[0]?.toString() : '')?.toUpperCase() ?? '';
      case 'lower':
        return (evaluatedArgs.isNotEmpty ? evaluatedArgs[0]?.toString() : '')?.toLowerCase() ?? '';
      case 'round':
        return (double.tryParse(evaluatedArgs.isNotEmpty ? evaluatedArgs[0]?.toString() ?? '0' : '0') ?? 0).round();
      default:
        throw Exception('Unknown function: $name()');
    }
  }
}

// ============================================================================
// 表达式解析器（递归下降）
// ============================================================================

class ExpressionParser {
  final List<Token> _tokens;
  int _pos = 0;

  ExpressionParser(this._tokens);

  AstNode parse() {
    final node = _ternary();
    if (_current().type != TokenType.eof) {
      throw FormatException(
          'Unexpected token "${_current().lexeme}" at position $_pos');
    }
    return node;
  }

  Token _current() => _tokens[_pos];
  Token _advance() => _tokens[_pos++];

  void _expect(TokenType type, String msg) {
    if (_current().type != type) throw FormatException(msg);
    _advance();
  }

  // ternary → expression ('?' expression ':' expression)?
  AstNode _ternary() {
    final node = _nullCoalescing();
    if (_current().type == TokenType.question) {
      _advance();
      final thenBranch = _ternary();
      _expect(TokenType.colon, 'Expected ":" in ternary');
      final elseBranch = _ternary();
      return TernaryNode(node, thenBranch, elseBranch);
    }
    return node;
  }

  // nullCoalescing → comparison ('??' comparison)*
  AstNode _nullCoalescing() {
    var node = _comparison();
    while (_current().type == TokenType.nullCoalescing) {
      _advance();
      node = BinaryOpNode(node, TokenType.nullCoalescing, _comparison());
    }
    return node;
  }

  // comparison → addition (('==' | '!=' | '>' | '<' | '>=' | '<=' | '&&' | '||') addition)*
  AstNode _comparison() {
    var node = _addition();
    while (const {
      TokenType.equal,
      TokenType.notEqual,
      TokenType.greater,
      TokenType.less,
      TokenType.greaterEqual,
      TokenType.lessEqual,
      TokenType.and,
      TokenType.or,
    }.contains(_current().type)) {
      final op = _current().type;
      _advance();
      node = BinaryOpNode(node, op, _addition());
    }
    return node;
  }

  // addition → multiplication (('+' | '-') multiplication)*
  AstNode _addition() {
    var node = _multiplication();
    while (_current().type == TokenType.plus ||
        _current().type == TokenType.minus) {
      final op = _current().type;
      _advance();
      node = BinaryOpNode(node, op, _multiplication());
    }
    return node;
  }

  // multiplication → unary (('*' | '/' | '%') unary)*
  AstNode _multiplication() {
    var node = _unary();
    while (_current().type == TokenType.multiply ||
        _current().type == TokenType.divide ||
        _current().type == TokenType.modulo) {
      final op = _current().type;
      _advance();
      node = BinaryOpNode(node, op, _unary());
    }
    return node;
  }

  // unary → ('-' | '!') unary | primary
  AstNode _unary() {
    if (_current().type == TokenType.minus ||
        _current().type == TokenType.not) {
      final op = _current().type;
      _advance();
      return UnaryOpNode(op, _unary());
    }
    return _primary();
  }

  // primary → literal | '$' identifier ('.' identifier)* | identifier '(' args ')' | '(' expression ')' | identifier
  AstNode _primary() {
    final token = _current();

    switch (token.type) {
      case TokenType.stringLiteral:
      case TokenType.numberLiteral:
      case TokenType.boolLiteral:
      case TokenType.nullLiteral:
        _advance();
        return LiteralNode(token.literal);

      case TokenType.dollar:
        _advance();
        return _variablePath();

      case TokenType.openParen:
        _advance();
        final node = _ternary();
        _expect(TokenType.closeParen, 'Expected ")"');
        return node;

      case TokenType.identifier:
        _advance();
        // 函数调用？
        if (_current().type == TokenType.openParen) {
          _advance();
          final args = <AstNode>[];
          if (_current().type != TokenType.closeParen) {
            args.add(_ternary());
            while (_current().type == TokenType.comma) {
              _advance();
              args.add(_ternary());
            }
          }
          _expect(TokenType.closeParen, 'Expected ")" after function args');
          return FunctionCallNode(token.lexeme, args);
        }
        // 简单标识符
        return VariableNode(token.lexeme);

      default:
        throw FormatException(
            'Unexpected token "${token.lexeme}" at position $_pos');
    }
  }

  // $json.field.nested → VariableNode('json.field.nested')
  AstNode _variablePath() {
    final parts = <String>[];
    _expect(TokenType.identifier, 'Expected variable name after \$');
    parts.add(_tokens[_pos - 1].lexeme);

    while (_current().type == TokenType.dot) {
      _advance();
      if (_current().type == TokenType.identifier) {
        _advance();
        parts.add(_tokens[_pos - 1].lexeme);
      } else {
        throw FormatException('Expected field name after "."');
      }
    }

    // 数组索引：$json.items[0].name
    while (_current().type == TokenType.openBracket) {
      _advance();
      if (_current().type == TokenType.numberLiteral) {
        parts.add(_current().literal.toString());
        _advance();
        _expect(TokenType.closeBracket, 'Expected "]"');
      } else {
        throw FormatException('Expected number inside [...]');
      }
    }

    // 可能还有 .field 继续
    while (_current().type == TokenType.dot) {
      _advance();
      if (_current().type == TokenType.identifier) {
        _advance();
        parts.add(_tokens[_pos - 1].lexeme);
      } else {
        throw FormatException('Expected field name after "."');
      }
    }

    return VariableNode(parts.join('.'));
  }
}

// ============================================================================
// 表达式求值器（对外 API）
// ============================================================================

class ExpressionEvaluator {
  /// 求值模板字符串，替换所有 {{ expression }} 占位
  String evaluateTemplate(String template, Map<String, dynamic> context) {
    final regex = RegExp(r'\{\{(.+?)\}\}');
    return template.replaceAllMapped(regex, (match) {
      final expression = match.group(1)!.trim();
      try {
        final result = evaluate(expression, context);
        return result?.toString() ?? '';
      } catch (_) {
        return match.group(0)!; // 保留原样
      }
    });
  }

  /// 求值单个表达式
  dynamic evaluate(String expression, Map<String, dynamic> context) {
    final lexer = ExpressionLexer(expression);
    final tokens = lexer.tokenize();
    final parser = ExpressionParser(tokens);
    final ast = parser.parse();
    return ast.evaluate(context);
  }
}
