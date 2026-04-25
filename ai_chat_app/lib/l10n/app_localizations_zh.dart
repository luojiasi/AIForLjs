// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'AI 聊天';

  @override
  String get newConversation => '新建对话';

  @override
  String get sendMessage => '发送';

  @override
  String get inputHint => '输入消息...';

  @override
  String get settings => '设置';

  @override
  String get themeMode => '主题模式';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '跟随系统';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get model => '模型';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get loading => '加载中...';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get noMessages => '暂无消息，开始一段对话吧！';

  @override
  String get deleteConversation => '确定删除此对话？';

  @override
  String get searchPlaceholder => '搜索对话...';
}
