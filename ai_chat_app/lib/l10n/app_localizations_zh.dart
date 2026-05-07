// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '欢迎来到SYCTB';

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
  String get aboutPageStudyLearning => '学习路径';

  @override
  String get aboutPageEasterEggButton => '完美';

  @override
  String get aboutPageAppName => '多功能软件应用';

  @override
  String get requestLogSettingTitle => '请求日志打印';

  @override
  String get requestLogSettingSubtitle => '开启后会将请求/响应详情写入 logs/logs.txt';

  @override
  String get flutterLogSettingTitle => '应用日志打印';

  @override
  String get flutterLogSettingSubtitle =>
      '开启后会将 Flutter 错误与 print 输出写入 logs/flutter_logs.txt';

  @override
  String get logViewerCurrentLog => '当前日志';

  @override
  String get logViewerExport => '导出';

  @override
  String get logViewerEmpty => '暂无日志';

  @override
  String get logSettingsTitle => '日志设置';

  @override
  String get logSettingsSaveOutput => '保存响应输出';

  @override
  String get logSettingsSaveOutputSubtitle => '记录响应体内容（可能占用较多存储空间）';

  @override
  String get logSettingsAutoDelete => '自动删除';

  @override
  String get logSettingsAutoDeleteSubtitle => '删除超过指定天数的日志';

  @override
  String get logSettingsAutoDeleteDisabled => '不启用';

  @override
  String logSettingsAutoDeleteDays(int count) {
    return '$count 天';
  }

  @override
  String get logSettingsMaxSize => '日志大小上限';

  @override
  String get logSettingsMaxSizeSubtitle => '超出后将删除最早的日志';

  @override
  String get logSettingsMaxSizeUnlimited => '不限制';

  @override
  String get storageSpaceSubLogsFlutter => '运行日志';

  @override
  String get storageSpaceSubLogsRequests => '网络日志';

  @override
  String get storageSpaceSubLogsOther => '其他日志';

  @override
  String get storageSpaceCategoryLogs => '日志';

  @override
  String get logViewerTitle => '请求日志';

  @override
  String logViewerRequestsCount(int count) {
    return '$count 条请求';
  }

  @override
  String get chatMessageWidgetCopiedToClipboard => '已复制到剪贴板';

  @override
  String get logViewerFieldId => 'ID';

  @override
  String get logViewerFieldMethod => '方法';

  @override
  String get logViewerFieldStatus => '状态';

  @override
  String get logViewerFieldStarted => '开始';

  @override
  String get logViewerFieldEnded => '结束';

  @override
  String get logViewerFieldDuration => '耗时';

  @override
  String get logViewerSectionSummary => '概览';

  @override
  String get logViewerSectionParameters => '参数';

  @override
  String get logViewerSectionRequestHeaders => '请求头';

  @override
  String get logViewerSectionRequestBody => '请求体';

  @override
  String get logViewerSectionResponseHeaders => '响应头';

  @override
  String get logViewerSectionResponseBody => '响应体';

  @override
  String get logViewerSectionWarnings => '警告';

  @override
  String get logViewerErrorTitle => '错误';

  @override
  String logViewerMoreCount(int count) {
    return '+$count 条更多';
  }

  @override
  String get hotkeyToggleAppVisibility => '显示/隐藏应用';

  @override
  String get hotkeyCloseWindow => '关闭窗口';

  @override
  String get hotkeyOpenSettings => '打开设置';

  @override
  String get hotkeyNewTopic => '新建话题';

  @override
  String get hotkeySwitchModel => '切换模型';

  @override
  String get hotkeyToggleAssistantPanel => '切换助手显示';

  @override
  String get hotkeyToggleTopicPanel => '切换话题显示';

  @override
  String get hotkeysPressShortcut => '按下快捷键';

  @override
  String get hotkeysResetDefault => '重置为默认';

  @override
  String get hotkeysClearShortcut => '清除快捷键';

  @override
  String get hotkeysResetAll => '重置所有快捷键为默认';

  @override
  String get androidBackgroundNotificationTitle => 'SYCTB 正在运行';

  @override
  String get androidBackgroundNotificationText => '后台软件持续工作';

  @override
  String get desktopTrayMenuShowWindow => '显示窗口';

  @override
  String get desktopTrayMenuExit => '退出';

  @override
  String get desktopNavChatTooltip => '聊天';

  @override
  String get desktopNavTranslateTooltip => '翻译';

  @override
  String get desktopNavStorageTooltip => '存储';

  @override
  String get desktopNavGlobalSearchTooltip => '全局搜索';

  @override
  String get desktopNavThemeToggleTooltip => '主题切换';

  @override
  String get desktopNavSettingsTooltip => '设置';

  @override
  String get desktopAvatarMenuUseEmoji => '使用表情符号';

  @override
  String get backupPageUsername => '用户名';

  @override
  String get backupPagePassword => '密码';

  @override
  String get sideDrawerNicknameHint => '输入新的昵称';

  @override
  String get sideDrawerRename => '重命名';

  @override
  String get sideDrawerEnterLink => '输入链接';

  @override
  String get sideDrawerImportFromQQ => 'QQ头像';

  @override
  String get sideDrawerReset => '重置';

  @override
  String get sideDrawerEmojiDialogTitle => '选择表情';

  @override
  String get sideDrawerEmojiDialogHint => '输入或粘贴任意表情';

  @override
  String get sideDrawerImageUrlDialogTitle => '输入图片链接';

  @override
  String get sideDrawerImageUrlDialogHint =>
      '例如: https://example.com/avatar.png';

  @override
  String get sideDrawerQQAvatarDialogTitle => '使用QQ头像';

  @override
  String get sideDrawerQQAvatarInputHint => '输入QQ号码（5-12位）';

  @override
  String get sideDrawerQQAvatarFetchFailed => '获取随机QQ头像失败，请重试';

  @override
  String get sideDrawerRandomQQ => '随机QQ';

  @override
  String get sideDrawerGalleryOpenError => '无法打开相册，试试输入图片链接';

  @override
  String get sideDrawerGeneralImageError => '发生错误，试试输入图片链接';

  @override
  String get sideDrawerSetNicknameTitle => '设置昵称';

  @override
  String get sideDrawerNicknameLabel => '昵称';

  @override
  String get desktopAvatarMenuReset => '重置头像';

  @override
  String get sideDrawerCancel => '取消';

  @override
  String get sideDrawerOK => '确定';

  @override
  String get sideDrawerSave => '保存';

  @override
  String get assistantEditEmojiDialogTitle => '选择表情';

  @override
  String get assistantEditEmojiDialogHint => '输入或粘贴任意表情';

  @override
  String get assistantEditEmojiDialogCancel => '取消';

  @override
  String get assistantEditEmojiDialogSave => '保存';

  @override
  String get desktopAvatarMenuChangeFromImage => '从图片更换…';

  @override
  String get homePageCancel => '取消';

  @override
  String get homePageDelete => '删除';

  @override
  String get homePageDone => '完成';

  @override
  String get assistantProviderDefaultAssistantName => '默认助手';

  @override
  String get assistantProviderSampleAssistantName => '示例助手';

  @override
  String get assistantProviderNewAssistantName => '新助手';

  @override
  String assistantProviderSampleAssistantSystemPrompt(
    String model_name,
    String cur_datetime,
    String locale,
    String timezone,
    String device_info,
    String system_version,
  ) {
    return '你是$model_name, 一个人工智能助手，乐意为用户提供准确，有益的帮助。现在时间是$cur_datetime，用户设备语言为$locale，时区为$timezone，用户正在使用$device_info，版本$system_version。如果用户没有明确说明，请使用用户设备语言进行回复。';
  }

  @override
  String get assistantSettingsCopySuffix => '副本';

  @override
  String get homePageDefaultAssistant => '默认助手';

  @override
  String get sideDrawerPinnedLabel => '📌 已置顶';

  @override
  String get sideDrawerAssistantsTab => '助手';

  @override
  String get sideDrawerTopicsTab => '话题';

  @override
  String get sideDrawerToday => '今天';

  @override
  String get sideDrawerYesterday => '昨天';

  @override
  String sideDrawerDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String get sideDrawerDefaultUser => '用户';

  @override
  String get sideDrawerUserName => '用户名称';
}
