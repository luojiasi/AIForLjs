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

  @override
  String get settingsPageBackButton => '返回';

  @override
  String get settingsPageAbout => '关于';

  @override
  String get aboutPageAppDescription => '集成大部分功能软件';

  @override
  String get aboutPageVersion => '版本';

  @override
  String get aboutPageSystem => '系统';

  @override
  String get aboutPageWebsite => '网站';

  @override
  String get aboutPageGithub => 'GitHub';

  @override
  String get aboutPageLicense => '许可证';

  @override
  String get aboutPageJoinQQGroup => '加入QQ群';

  @override
  String get aboutPageJoinDiscord => '在 Discord 中加入我们';

  @override
  String get aboutPageEasterEggButton => '完美';

  @override
  String get requestLogSettingTitle => '请求日志打印';

  @override
  String get requestLogSettingSubtitle => '开启后会将请求/响应详情写入 logs/logs.txt';

  @override
  String get flutterLogSettingTitle => '应用日志打印';

  @override
  String get flutterLogSettingSubtitle =>
      '开启后会将 Flutter 错误与 print 输出写入 logs/flutter_logs.txt';
}
