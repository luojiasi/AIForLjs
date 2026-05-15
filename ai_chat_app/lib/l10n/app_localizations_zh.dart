// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get helloWorld => '你好，世界！';

  @override
  String get settingsPageBackButton => '返回';

  @override
  String get settingsPageTitle => '设置';

  @override
  String get settingsPageDarkMode => '深色';

  @override
  String get settingsPageLightMode => '浅色';

  @override
  String get settingsPageSystemMode => '跟随系统';

  @override
  String get settingsPageWarningMessage => '部分服务未配置，某些功能可能不可用';

  @override
  String get settingsPageGeneralSection => '通用设置';

  @override
  String get settingsPageColorMode => '颜色模式';

  @override
  String get settingsPageDisplay => '显示设置';

  @override
  String get settingsPageDisplaySubtitle => '界面主题与字号等外观设置';

  @override
  String get settingsPageAssistant => '助手';

  @override
  String get settingsPageAssistantSubtitle => '默认助手与对话风格';

  @override
  String get settingsPageModelsServicesSection => '模型与服务';

  @override
  String get settingsPageDefaultModel => '默认模型';

  @override
  String get settingsPageProviders => '供应商';

  @override
  String get settingsPageHotkeys => '快捷键';

  @override
  String get settingsPageSearch => '搜索服务';

  @override
  String get settingsPageTts => '语音服务';

  @override
  String get settingsPageMcp => 'MCP';

  @override
  String get settingsPageQuickPhrase => '快捷短语';

  @override
  String get settingsPageInstructionInjection => '指令注入';

  @override
  String get settingsPageDataSection => '数据设置';

  @override
  String get settingsPageBackup => '数据备份';

  @override
  String get settingsPageChatStorage => '聊天记录存储';

  @override
  String get settingsPageCalculating => '统计中…';

  @override
  String settingsPageFilesCount(int count, String size) {
    return '共 $count 个文件 · $size';
  }

  @override
  String get storageSpacePageTitle => '存储空间';

  @override
  String get storageSpaceRefreshTooltip => '刷新';

  @override
  String get storageSpaceLoadFailed => '加载失败';

  @override
  String get storageSpaceTotalLabel => '已用空间';

  @override
  String storageSpaceClearableLabel(String size) {
    return '可清理：$size';
  }

  @override
  String storageSpaceClearableHint(String size) {
    return '共发现可清理空间 $size';
  }

  @override
  String get storageSpaceCategoryImages => '图片';

  @override
  String get storageSpaceCategoryFiles => '文件';

  @override
  String get storageSpaceCategoryChatData => '聊天记录';

  @override
  String get storageSpaceCategoryAssistantData => '助手';

  @override
  String get storageSpaceCategoryCache => '缓存';

  @override
  String get storageSpaceCategoryLogs => '日志';

  @override
  String get storageSpaceCategoryOther => '应用';

  @override
  String storageSpaceFilesCount(int count) {
    return '$count 个文件';
  }

  @override
  String get storageSpaceSafeToClearHint => '可安全清理，不影响聊天记录。';

  @override
  String get storageSpaceNotSafeToClearHint => '可能影响聊天记录，请谨慎删除。';

  @override
  String get storageSpaceBreakdownTitle => '明细';

  @override
  String get storageSpaceSubChatMessages => '消息';

  @override
  String get storageSpaceSubChatConversations => '会话';

  @override
  String get storageSpaceSubChatToolEvents => '工具事件';

  @override
  String get storageSpaceSubAssistantAvatars => '头像';

  @override
  String get storageSpaceSubAssistantImages => '图片';

  @override
  String get storageSpaceSubCacheAvatars => '头像缓存';

  @override
  String get storageSpaceSubCacheOther => '其他缓存';

  @override
  String get storageSpaceSubCacheSystem => '系统缓存';

  @override
  String get storageSpaceSubLogsFlutter => '运行日志';

  @override
  String get storageSpaceSubLogsRequests => '网络日志';

  @override
  String get storageSpaceSubLogsOther => '其他日志';

  @override
  String get storageSpaceClearConfirmTitle => '确认清理';

  @override
  String storageSpaceClearConfirmMessage(String targetName) {
    return '确定要清理 $targetName 吗？';
  }

  @override
  String get storageSpaceClearButton => '清理';

  @override
  String storageSpaceClearDone(String targetName) {
    return '已清理 $targetName';
  }

  @override
  String storageSpaceClearFailed(String error) {
    return '清理失败：$error';
  }

  @override
  String get storageSpaceClearAvatarCacheButton => '清理头像缓存';

  @override
  String get storageSpaceClearCacheButton => '清理缓存';

  @override
  String get storageSpaceClearLogsButton => '清理日志';

  @override
  String get storageSpaceViewLogsButton => '查看日志';

  @override
  String get storageSpaceDeleteConfirmTitle => '确认删除';

  @override
  String storageSpaceDeleteUploadsConfirmMessage(int count) {
    return '删除 $count 个项目？删除后聊天记录中的附件可能无法打开。';
  }

  @override
  String storageSpaceDeletedUploadsDone(int count) {
    return '已删除 $count 个项目';
  }

  @override
  String get storageSpaceNoUploads => '暂无内容';

  @override
  String get storageSpaceSelectAll => '全选';

  @override
  String get storageSpaceClearSelection => '清空选择';

  @override
  String storageSpaceSelectedCount(int count) {
    return '已选 $count 项';
  }

  @override
  String storageSpaceUploadsCount(int count) {
    return '共 $count 项';
  }

  @override
  String get settingsPageAboutSection => '关于';

  @override
  String get settingsPageAbout => '关于';

  @override
  String get settingsPageDocs => '使用文档';

  @override
  String get settingsPageLogs => '日志';

  @override
  String get settingsPageSponsor => '赞助';

  @override
  String get settingsPageShare => '分享';

  @override
  String get sponsorPageMethodsSectionTitle => '赞助方式';

  @override
  String get sponsorPageSponsorsSectionTitle => '赞助用户';

  @override
  String get sponsorPageEmpty => '暂无赞助者';

  @override
  String get sponsorPageAfdianTitle => '爱发电';

  @override
  String get sponsorPageAfdianSubtitle => 'afdian.com/a/SYCTB';

  @override
  String get sponsorPageWeChatTitle => '微信赞助';

  @override
  String get sponsorPageWeChatSubtitle => '微信赞助码';

  @override
  String get sponsorPageScanQrHint => '扫描二维码赞助';

  @override
  String get languageDisplaySimplifiedChinese => '简体中文';

  @override
  String get languageDisplayEnglish => 'English';

  @override
  String get languageDisplayTraditionalChinese => '繁體中文';

  @override
  String get languageDisplayJapanese => '日本語';

  @override
  String get languageDisplayKorean => '한국어';

  @override
  String get languageDisplayFrench => 'Français';

  @override
  String get languageDisplayGerman => 'Deutsch';

  @override
  String get languageDisplayItalian => 'Italiano';

  @override
  String get languageDisplaySpanish => 'Español';

  @override
  String get languageSelectSheetTitle => '选择翻译语言';

  @override
  String get languageSelectSheetClearButton => '清空翻译';

  @override
  String get homePageClearContext => '清空上下文';

  @override
  String homePageClearContextWithCount(String actual, String configured) {
    return '清空上下文 ($actual/$configured)';
  }

  @override
  String get homePageDefaultAssistant => '默认助手';

  @override
  String get mermaidExportPng => '导出 PNG';

  @override
  String get mermaidExportFailed => '导出失败';

  @override
  String get mermaidPreviewOpen => '浏览器预览';

  @override
  String get mermaidPreviewOpenFailed => '无法打开预览';

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
  String get displaySettingsPageLanguageTitle => '应用语言';

  @override
  String get displaySettingsPageLanguageSubtitle => '选择界面语言';

  @override
  String get assistantTagsManageTitle => '管理标签';

  @override
  String get assistantTagsCreateButton => '创建';

  @override
  String get assistantTagsCreateDialogTitle => '创建标签';

  @override
  String get assistantTagsCreateDialogOk => '创建';

  @override
  String get assistantTagsCreateDialogCancel => '取消';

  @override
  String get assistantTagsNameHint => '标签名称';

  @override
  String get assistantTagsRenameButton => '重命名';

  @override
  String get assistantTagsRenameDialogTitle => '重命名标签';

  @override
  String get assistantTagsRenameDialogOk => '重命名';

  @override
  String get assistantTagsDeleteButton => '删除';

  @override
  String get assistantTagsDeleteConfirmTitle => '删除标签';

  @override
  String get assistantTagsDeleteConfirmContent => '确定要删除该标签吗？';

  @override
  String get assistantTagsDeleteConfirmOk => '删除';

  @override
  String get assistantTagsDeleteConfirmCancel => '取消';

  @override
  String get assistantTagsContextMenuEditAssistant => '编辑助手';

  @override
  String get assistantTagsContextMenuManageTags => '管理标签';

  @override
  String get mcpTransportOptionStdio => 'STDIO';

  @override
  String get mcpTransportTagStdio => 'STDIO';

  @override
  String get mcpTransportTagInmemory => '内置';

  @override
  String get mcpTransportTagSse => 'SSE';

  @override
  String get mcpTransportTagHttp => 'HTTP';

  @override
  String get mcpServerEditSheetStdioOnlyDesktop => 'STDIO 仅在桌面端可用';

  @override
  String get mcpServerEditSheetStdioCommandLabel => '命令';

  @override
  String get mcpServerEditSheetStdioArgumentsLabel => '参数';

  @override
  String get mcpServerEditSheetStdioWorkingDirectoryLabel => '工作目录（可选）';

  @override
  String get mcpServerEditSheetStdioEnvironmentTitle => '环境变量';

  @override
  String get mcpServerEditSheetStdioEnvNameLabel => '名称';

  @override
  String get mcpServerEditSheetStdioEnvValueLabel => '值';

  @override
  String get mcpServerEditSheetStdioAddEnv => '添加环境变量';

  @override
  String get mcpServerEditSheetStdioCommandRequired => 'STDIO 需要填写命令';

  @override
  String get assistantTagsContextMenuDeleteAssistant => '删除助手';

  @override
  String get assistantTagsClearTag => '清除标签';

  @override
  String get displaySettingsPageLanguageChineseLabel => '简体中文';

  @override
  String get displaySettingsPageLanguageEnglishLabel => 'English';

  @override
  String get homePagePleaseSelectModel => '请先选择模型';

  @override
  String get homePageAudioAttachmentUnsupported =>
      '当前模型不支持音频附件，请切换到支持音频输入的模型或移除音频文件后重试。';

  @override
  String get homePagePleaseSetupTranslateModel => '请先设置翻译模型';

  @override
  String get homePageTranslating => '翻译中...';

  @override
  String homePageTranslateFailed(String error) {
    return '翻译失败: $error';
  }

  @override
  String get chatServiceDefaultConversationTitle => '新对话';

  @override
  String get userProviderDefaultUserName => '用户';

  @override
  String get homePageDeleteMessage => '删除本版本';

  @override
  String get homePageDeleteMessageConfirm => '确定要删除当前版本吗？此操作不可撤销。';

  @override
  String get homePageDeleteAllVersions => '删除全部版本';

  @override
  String get homePageDeleteAllVersionsConfirm => '确定要删除这条消息的全部版本吗？此操作不可撤销。';

  @override
  String get homePageCancel => '取消';

  @override
  String get homePageDelete => '删除';

  @override
  String get homePageSelectMessagesToShare => '请选择要分享的消息';

  @override
  String get homePageDone => '完成';

  @override
  String get homePageDropToUpload => '将文件拖拽到此处上传';

  @override
  String get assistantEditPageTitle => '助手';

  @override
  String get assistantEditPageNotFound => '助手不存在';

  @override
  String get assistantEditPageBasicTab => '基础设置';

  @override
  String get assistantEditPagePromptsTab => '提示词';

  @override
  String get assistantEditPageMcpTab => 'MCP';

  @override
  String get assistantEditPageQuickPhraseTab => '快捷短语';

  @override
  String get assistantEditPageCustomTab => '自定义请求';

  @override
  String get assistantEditPageRegexTab => '正则替换';

  @override
  String get assistantEditRegexDescription => '为用户/助手消息配置正则规则，可修改或仅调整显示效果。';

  @override
  String get assistantEditAddRegexButton => '添加正则规则';

  @override
  String get assistantRegexAddTitle => '添加正则规则';

  @override
  String get assistantRegexEditTitle => '编辑正则规则';

  @override
  String get assistantRegexNameLabel => '规则名称';

  @override
  String get assistantRegexPatternLabel => '正则表达式';

  @override
  String get assistantRegexReplacementLabel => '替换字符串';

  @override
  String get assistantRegexScopeLabel => '影响范围';

  @override
  String get assistantRegexScopeUser => '用户';

  @override
  String get assistantRegexScopeAssistant => '助手';

  @override
  String get assistantRegexScopeVisualOnly => '仅视觉';

  @override
  String get assistantRegexScopeReplaceOnly => '仅替换';

  @override
  String get assistantRegexAddAction => '添加';

  @override
  String get assistantRegexSaveAction => '保存';

  @override
  String get assistantRegexDeleteButton => '删除';

  @override
  String get assistantRegexValidationError => '请填写名称、正则表达式，并至少选择一个范围。';

  @override
  String get assistantRegexInvalidPattern => '正则表达式无效';

  @override
  String get assistantRegexCancelButton => '取消';

  @override
  String get assistantRegexUntitled => '未命名规则';

  @override
  String get assistantEditCustomHeadersTitle => '自定义 Header';

  @override
  String get assistantEditCustomHeadersAdd => '添加 Header';

  @override
  String get assistantEditCustomHeadersEmpty => '未添加 Header';

  @override
  String get assistantEditCustomBodyTitle => '自定义 Body';

  @override
  String get assistantEditCustomBodyAdd => '添加 Body';

  @override
  String get assistantEditCustomBodyEmpty => '未添加 Body 项';

  @override
  String get assistantEditHeaderNameLabel => 'Header 名称';

  @override
  String get assistantEditHeaderValueLabel => 'Header 值';

  @override
  String get assistantEditBodyKeyLabel => 'Body Key';

  @override
  String get assistantEditBodyValueLabel => 'Body 值 (JSON)';

  @override
  String get assistantEditDeleteTooltip => '删除';

  @override
  String get assistantEditAssistantNameLabel => '助手名称';

  @override
  String get assistantEditUseAssistantAvatarTitle => '使用助手头像';

  @override
  String get assistantEditUseAssistantAvatarSubtitle => '在聊天中使用助手头像替代模型头像';

  @override
  String get assistantEditUseAssistantNameTitle => '使用助手名字';

  @override
  String get assistantEditChatModelTitle => '聊天模型';

  @override
  String get assistantEditChatModelSubtitle => '为该助手设置默认聊天模型（未设置时使用全局默认）';

  @override
  String get assistantEditTemperatureDescription => '控制输出的随机性，范围 0–2';

  @override
  String get assistantEditTopPDescription => '请不要修改此值，除非你知道自己在做什么';

  @override
  String get assistantEditParameterDisabled => '已关闭（使用服务商默认）';

  @override
  String get assistantEditParameterDisabled2 => '已关闭（无限制）';

  @override
  String get assistantEditContextMessagesTitle => '上下文消息数量';

  @override
  String get assistantEditContextMessagesDescription =>
      '多少历史消息会被当作上下文发送给模型，超过数量会忽略，只保留最近 N 条';

  @override
  String get assistantEditStreamOutputTitle => '流式输出';

  @override
  String get assistantEditStreamOutputDescription => '是否启用消息的流式输出';

  @override
  String get assistantEditThinkingBudgetTitle => '思考预算';

  @override
  String get assistantEditConfigureButton => '配置';

  @override
  String get assistantEditMaxTokensTitle => '最大 Token 数';

  @override
  String get assistantEditMaxTokensDescription => '留空表示无限制';

  @override
  String get assistantEditMaxTokensHint => '无限制';

  @override
  String get assistantEditChatBackgroundTitle => '聊天背景';

  @override
  String get assistantEditChatBackgroundDescription => '设置助手聊天页面的背景图片';

  @override
  String get assistantEditChooseImageButton => '选择背景图片';

  @override
  String get assistantEditClearButton => '清除';

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
  String get cameraPermissionDeniedMessage => '未授予相机权限';

  @override
  String get openSystemSettings => '去设置';

  @override
  String get desktopAvatarMenuChangeFromImage => '从图片更换…';

  @override
  String get desktopAvatarMenuReset => '重置头像';

  @override
  String get assistantEditAvatarChooseImage => '选择图片';

  @override
  String get assistantEditAvatarChooseEmoji => '选择表情';

  @override
  String get assistantEditAvatarEnterLink => '输入链接';

  @override
  String get assistantEditAvatarImportQQ => 'QQ头像';

  @override
  String get assistantEditAvatarReset => '重置';

  @override
  String get displaySettingsPageChatMessageBackgroundTitle => '聊天消息背景';

  @override
  String get displaySettingsPageChatMessageBackgroundDefault => '默认';

  @override
  String get displaySettingsPageChatMessageBackgroundFrosted => '模糊';

  @override
  String get displaySettingsPageChatMessageBackgroundSolid => '纯色';

  @override
  String get displaySettingsPageAndroidBackgroundChatTitle => '后台聊天生成';

  @override
  String get androidBackgroundStatusOn => '开启';

  @override
  String get androidBackgroundStatusOff => '关闭';

  @override
  String get androidBackgroundStatusOther => '开启并通知';

  @override
  String get androidBackgroundOptionOn => '开启';

  @override
  String get androidBackgroundOptionOnNotify => '开启并在生成完时发送消息';

  @override
  String get androidBackgroundOptionOff => '关闭';

  @override
  String get notificationChatCompletedTitle => '生成完成';

  @override
  String get notificationChatCompletedBody => '助手回复已生成';

  @override
  String get androidBackgroundNotificationTitle => 'SYCTB 正在运行';

  @override
  String get androidBackgroundNotificationText => '后台保持聊天生成';

  @override
  String get assistantEditEmojiDialogTitle => '选择表情';

  @override
  String get assistantEditEmojiDialogHint => '输入或粘贴任意表情';

  @override
  String get assistantEditEmojiDialogCancel => '取消';

  @override
  String get assistantEditEmojiDialogSave => '保存';

  @override
  String get assistantEditImageUrlDialogTitle => '输入图片链接';

  @override
  String get assistantEditImageUrlDialogHint =>
      '例如: https://example.com/avatar.png';

  @override
  String get assistantEditImageUrlDialogCancel => '取消';

  @override
  String get assistantEditImageUrlDialogSave => '保存';

  @override
  String get assistantEditQQAvatarDialogTitle => '使用QQ头像';

  @override
  String get assistantEditQQAvatarDialogHint => '输入QQ号码（5-12位）';

  @override
  String get assistantEditQQAvatarRandomButton => '随机QQ';

  @override
  String get assistantEditQQAvatarFailedMessage => '获取随机QQ头像失败，请重试';

  @override
  String get assistantEditQQAvatarDialogCancel => '取消';

  @override
  String get assistantEditQQAvatarDialogSave => '保存';

  @override
  String get assistantEditGalleryErrorMessage => '无法打开相册，试试输入图片链接';

  @override
  String get assistantEditGeneralErrorMessage => '发生错误，试试输入图片链接';

  @override
  String get providerDetailPageMultiKeyModeTitle => '多Key模式';

  @override
  String get providerDetailPageManageKeysButton => '多Key管理';

  @override
  String get multiKeyPageTitle => '多Key管理';

  @override
  String get multiKeyPageDetect => '检测';

  @override
  String get multiKeyPageAdd => '添加';

  @override
  String get multiKeyPageAddHint => '请输入API Key（多个用逗号或空格分隔）';

  @override
  String multiKeyPageImportedSnackbar(int n) {
    return '已导入$n个key';
  }

  @override
  String get multiKeyPagePleaseAddModel => '请先添加模型';

  @override
  String get multiKeyPageTotal => '总数';

  @override
  String get multiKeyPageNormal => '正常';

  @override
  String get multiKeyPageError => '错误';

  @override
  String get multiKeyPageAccuracy => '正确率';

  @override
  String get multiKeyPageStrategyTitle => '负载均衡策略';

  @override
  String get multiKeyPageStrategyRoundRobin => '轮询';

  @override
  String get multiKeyPageStrategyPriority => '优先级';

  @override
  String get multiKeyPageStrategyLeastUsed => '最少使用';

  @override
  String get multiKeyPageStrategyRandom => '随机';

  @override
  String get multiKeyPageNoKeys => '暂无Key';

  @override
  String get multiKeyPageStatusActive => '正常';

  @override
  String get multiKeyPageStatusDisabled => '已关闭';

  @override
  String get multiKeyPageStatusError => '错误';

  @override
  String get multiKeyPageStatusRateLimited => '限速';

  @override
  String get multiKeyPageEditAlias => '编辑别名';

  @override
  String get multiKeyPageEdit => '编辑';

  @override
  String get multiKeyPageKey => 'API Key';

  @override
  String get multiKeyPagePriority => '优先级（1–10）';

  @override
  String get multiKeyPageDuplicateKeyWarning => '该 Key 已存在';

  @override
  String get multiKeyPageAlias => '别名';

  @override
  String get multiKeyPageCancel => '取消';

  @override
  String get multiKeyPageSave => '保存';

  @override
  String get multiKeyPageDelete => '删除';

  @override
  String get assistantEditSystemPromptTitle => '系统提示词';

  @override
  String get assistantEditSystemPromptHint => '输入系统提示词…';

  @override
  String get assistantEditSystemPromptImportButton => '从文件导入';

  @override
  String get assistantEditSystemPromptImportSuccess => '已从文件更新系统提示词';

  @override
  String get assistantEditSystemPromptImportFailed => '导入失败';

  @override
  String get assistantEditSystemPromptImportEmpty => '文件内容为空';

  @override
  String get assistantEditAvailableVariables => '可用变量：';

  @override
  String get assistantEditVariableDate => '日期';

  @override
  String get assistantEditVariableTime => '时间';

  @override
  String get assistantEditVariableDatetime => '日期和时间';

  @override
  String get assistantEditVariableModelId => '模型ID';

  @override
  String get assistantEditVariableModelName => '模型名称';

  @override
  String get assistantEditVariableLocale => '语言环境';

  @override
  String get assistantEditVariableTimezone => '时区';

  @override
  String get assistantEditVariableSystemVersion => '系统版本';

  @override
  String get assistantEditVariableDeviceInfo => '设备信息';

  @override
  String get assistantEditVariableBatteryLevel => '电池电量';

  @override
  String get assistantEditVariableNickname => '用户昵称';

  @override
  String get assistantEditVariableAssistantName => '助手名称';

  @override
  String get assistantEditMessageTemplateTitle => '聊天内容模板';

  @override
  String get assistantEditVariableRole => '助手';

  @override
  String get assistantEditVariableMessage => '内容';

  @override
  String get assistantEditPreviewTitle => '预览';

  @override
  String get codeBlockPreviewButton => '预览';

  @override
  String codeBlockCollapsedLines(int n) {
    return '… 已折叠 $n 行';
  }

  @override
  String get htmlPreviewNotSupportedOnLinux => 'Linux 暂不支持 HTML 预览';

  @override
  String get assistantEditSampleUser => '用户';

  @override
  String get assistantEditSampleMessage => '你好啊';

  @override
  String get assistantEditSampleReply => '你好，有什么我可以帮你的吗？';

  @override
  String get assistantEditMcpNoServersMessage => '暂无已启动的 MCP 服务器';

  @override
  String get assistantEditMcpConnectedTag => '已连接';

  @override
  String assistantEditMcpToolsCountTag(String enabled, String total) {
    return '工具: $enabled/$total';
  }

  @override
  String get assistantEditModelUseGlobalDefault => '使用全局默认';

  @override
  String get assistantSettingsPageTitle => '助手设置';

  @override
  String get assistantSettingsDefaultTag => '默认';

  @override
  String get assistantSettingsCopyButton => '复制';

  @override
  String get assistantSettingsCopySuccess => '已复制助手';

  @override
  String get assistantSettingsCopySuffix => '副本';

  @override
  String get assistantSettingsDeleteButton => '删除';

  @override
  String get assistantSettingsEditButton => '编辑';

  @override
  String get assistantSettingsAddSheetTitle => '助手名称';

  @override
  String get assistantSettingsAddSheetHint => '输入助手名称';

  @override
  String get assistantSettingsAddSheetCancel => '取消';

  @override
  String get assistantSettingsAddSheetSave => '保存';

  @override
  String get desktopAssistantsListTitle => '助手列表';

  @override
  String get desktopSidebarTabAssistants => '助手';

  @override
  String get desktopSidebarTabTopics => '话题';

  @override
  String get desktopTrayMenuShowWindow => '显示窗口';

  @override
  String get desktopTrayMenuExit => '退出';

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
  String get assistantEditTemperatureTitle => '温度';

  @override
  String get assistantEditTopPTitle => 'Top-p';

  @override
  String get assistantSettingsDeleteDialogTitle => '删除助手';

  @override
  String get assistantSettingsDeleteDialogContent => '确定要删除该助手吗？此操作不可撤销。';

  @override
  String get assistantSettingsDeleteDialogCancel => '取消';

  @override
  String get assistantSettingsDeleteDialogConfirm => '删除';

  @override
  String get assistantSettingsAtLeastOneAssistantRequired => '至少需要保留一个助手';

  @override
  String get mcpAssistantSheetTitle => 'MCP服务器';

  @override
  String get mcpAssistantSheetSubtitle => '为该助手启用的服务';

  @override
  String get mcpAssistantSheetSelectAll => '全选';

  @override
  String get mcpAssistantSheetClearAll => '全不选';

  @override
  String get backupPageTitle => '备份与恢复';

  @override
  String get backupPageWebDavTab => 'WebDAV 备份';

  @override
  String get backupPageImportExportTab => '导入和导出';

  @override
  String get backupPageWebDavServerUrl => 'WebDAV 服务器地址';

  @override
  String get backupPageUsername => '用户名';

  @override
  String get backupPagePassword => '密码';

  @override
  String get backupPagePath => '路径';

  @override
  String get backupPageChatsLabel => '聊天记录';

  @override
  String get backupPageFilesLabel => '文件';

  @override
  String get backupPageTestDone => '测试完成';

  @override
  String get backupPageTestConnection => '测试连接';

  @override
  String get backupPageRestartRequired => '需要重启应用';

  @override
  String get backupPageRestartContent => '恢复完成，需要重启以完全生效。';

  @override
  String get backupPageOK => '好的';

  @override
  String get backupPageCancel => '取消';

  @override
  String get backupPageSelectImportMode => '选择导入模式';

  @override
  String get backupPageSelectImportModeDescription => '请选择如何导入备份数据：';

  @override
  String get backupPageOverwriteMode => '完全覆盖';

  @override
  String get backupPageOverwriteModeDescription => '清空本地所有数据后恢复';

  @override
  String get backupPageMergeMode => '智能合并';

  @override
  String get backupPageMergeModeDescription => '仅添加不存在的数据（智能去重）';

  @override
  String get backupPageRestore => '恢复';

  @override
  String get backupPageBackupUploaded => '已上传备份';

  @override
  String get backupPageBackup => '立即备份';

  @override
  String get backupPageExporting => '正在导出...';

  @override
  String get backupPageExportToFile => '导出为文件';

  @override
  String get backupPageExportToFileSubtitle => '导出APP数据为文件';

  @override
  String get backupPageImportBackupFile => '备份文件导入';

  @override
  String get backupPageImportBackupFileSubtitle => '导入本地备份文件';

  @override
  String get backupPageImportFromOtherApps => '从其他APP导入';

  @override
  String get backupPageImportFromRikkaHub => '从 RikkaHub 导入';

  @override
  String get backupPageNotSupportedYet => '暂不支持';

  @override
  String get backupPageRemoteBackups => '远端备份';

  @override
  String get backupPageNoBackups => '暂无备份';

  @override
  String get backupPageRestoreTooltip => '恢复';

  @override
  String get backupPageDeleteTooltip => '删除';

  @override
  String get backupPageDeleteConfirmTitle => '确认删除';

  @override
  String backupPageDeleteConfirmContent(Object name) {
    return '确定要删除远程备份“$name”吗？此操作不可撤销。';
  }

  @override
  String get backupPageBackupManagement => '备份管理';

  @override
  String get backupPageWebDavBackup => 'WebDAV 备份';

  @override
  String get backupPageWebDavServerSettings => 'WebDAV 服务器设置';

  @override
  String get backupPageS3Backup => 'S3 备份';

  @override
  String get backupPageS3ServerSettings => 'S3 服务器设置';

  @override
  String get backupPageS3Endpoint => '端点';

  @override
  String get backupPageS3Region => '区域';

  @override
  String get backupPageS3Bucket => 'Bucket';

  @override
  String get backupPageS3AccessKeyId => '访问密钥 ID';

  @override
  String get backupPageS3SecretAccessKey => '秘密访问密钥';

  @override
  String get backupPageS3SessionToken => 'Session Token（可选）';

  @override
  String get backupPageS3Prefix => '前缀（目录）';

  @override
  String get backupPageS3PathStyle => '路径风格（Path-style）';

  @override
  String get backupPageSave => '保存';

  @override
  String get backupPageBackupNow => '立即备份';

  @override
  String get backupPageLocalBackup => '本地备份';

  @override
  String get backupPageImportFromCherryStudio => '从 Cherry Studio 导入';

  @override
  String get backupPageImportFromChatbox => '从 Chatbox 导入';

  @override
  String get chatHistoryPageTitle => '聊天历史';

  @override
  String get chatHistoryPageSearchTooltip => '搜索';

  @override
  String get chatHistoryPageDeleteAllTooltip => '删除未置顶';

  @override
  String get chatHistoryPageDeleteAllDialogTitle => '删除未置顶对话';

  @override
  String get chatHistoryPageDeleteAllDialogContent =>
      '确定要删除所有未置顶的对话吗？已置顶的将会保留。';

  @override
  String get chatHistoryPageCancel => '取消';

  @override
  String get chatHistoryPageDelete => '删除';

  @override
  String get chatHistoryPageDeletedAllSnackbar => '已删除未置顶的对话';

  @override
  String get chatHistoryPageSearchHint => '搜索对话';

  @override
  String get chatHistoryPageNoConversations => '暂无对话';

  @override
  String get chatHistoryPagePinnedSection => '置顶';

  @override
  String get chatHistoryPagePin => '置顶';

  @override
  String get chatHistoryPagePinned => '已置顶';

  @override
  String get messageEditPageTitle => '编辑消息';

  @override
  String get messageEditPageSave => '保存';

  @override
  String get messageEditPageSaveAndSend => '保存并发送';

  @override
  String get messageEditPageHint => '输入消息内容…';

  @override
  String get selectCopyPageTitle => '选择复制';

  @override
  String get selectCopyPageCopyAll => '复制全部';

  @override
  String get selectCopyPageCopiedAll => '已复制全部';

  @override
  String get bottomToolsSheetCamera => '拍照';

  @override
  String get bottomToolsSheetPhotos => '照片';

  @override
  String get bottomToolsSheetUpload => '上传文件';

  @override
  String get bottomToolsSheetClearContext => '清空上下文';

  @override
  String get compressContext => '压缩上下文';

  @override
  String get compressContextDesc => '总结对话并开始新聊天';

  @override
  String get clearContextDesc => '标记上下文分界点';

  @override
  String get contextManagement => '上下文管理';

  @override
  String get compressingContext => '正在压缩上下文...';

  @override
  String get compressContextFailed => '压缩上下文失败';

  @override
  String get compressContextNoMessages => '没有可压缩的消息';

  @override
  String get bottomToolsSheetLearningMode => '学习模式';

  @override
  String get bottomToolsSheetLearningModeDescription => '帮助你循序渐进地学习知识';

  @override
  String get bottomToolsSheetConfigurePrompt => '设置提示词';

  @override
  String get bottomToolsSheetPrompt => '提示词';

  @override
  String get bottomToolsSheetPromptHint => '输入要注入的提示词内容';

  @override
  String get bottomToolsSheetResetDefault => '重置为默认';

  @override
  String get bottomToolsSheetSave => '保存';

  @override
  String get bottomToolsSheetOcr => 'OCR 文字识别';

  @override
  String get messageMoreSheetTitle => '更多操作';

  @override
  String get messageMoreSheetSelectCopy => '选择复制';

  @override
  String get messageMoreSheetRenderWebView => '网页视图渲染';

  @override
  String get messageMoreSheetNotImplemented => '暂未实现';

  @override
  String get messageMoreSheetEdit => '编辑';

  @override
  String get messageMoreSheetShare => '分享';

  @override
  String get messageMoreSheetCreateBranch => '创建分支';

  @override
  String get messageMoreSheetDelete => '删除本版本';

  @override
  String get messageMoreSheetDeleteAllVersions => '删除全部版本';

  @override
  String get reasoningBudgetSheetOff => '关闭';

  @override
  String get reasoningBudgetSheetAuto => '自动';

  @override
  String get reasoningBudgetSheetLight => '轻度推理';

  @override
  String get reasoningBudgetSheetMedium => '中度推理';

  @override
  String get reasoningBudgetSheetHeavy => '重度推理';

  @override
  String get reasoningBudgetSheetXhigh => '极限推理';

  @override
  String get reasoningBudgetSheetTitle => '思维链强度';

  @override
  String reasoningBudgetSheetCurrentLevel(String level) {
    return '当前档位：$level';
  }

  @override
  String get reasoningBudgetSheetOffSubtitle => '关闭推理功能，直接回答';

  @override
  String get reasoningBudgetSheetAutoSubtitle => '由模型自动决定推理级别';

  @override
  String get reasoningBudgetSheetLightSubtitle => '使用少量推理来回答问题';

  @override
  String get reasoningBudgetSheetMediumSubtitle => '使用较多推理来回答问题';

  @override
  String get reasoningBudgetSheetHeavySubtitle => '使用大量推理来回答问题，适合复杂问题';

  @override
  String get reasoningBudgetSheetXhighSubtitle => '使用最大推理深度，适合最复杂的问题';

  @override
  String get reasoningBudgetSheetCustomLabel => '自定义推理预算';

  @override
  String get reasoningBudgetSheetCustomHint => '例如：2048 (-1 自动，0 关闭)';

  @override
  String chatMessageWidgetFileNotFound(String fileName) {
    return '文件不存在: $fileName';
  }

  @override
  String chatMessageWidgetCannotOpenFile(String message) {
    return '无法打开文件: $message';
  }

  @override
  String chatMessageWidgetOpenFileError(String error) {
    return '打开文件失败: $error';
  }

  @override
  String get chatMessageWidgetCopiedToClipboard => '已复制到剪贴板';

  @override
  String get chatMessageWidgetResendTooltip => '重新发送';

  @override
  String get chatMessageWidgetMoreTooltip => '更多';

  @override
  String get chatMessageWidgetThinking => '正在思考...';

  @override
  String get chatMessageWidgetTranslation => '翻译';

  @override
  String get chatMessageWidgetTranslating => '翻译中...';

  @override
  String get chatMessageWidgetCitationNotFound => '未找到引用来源';

  @override
  String chatMessageWidgetCannotOpenUrl(String url) {
    return '无法打开链接: $url';
  }

  @override
  String get chatMessageWidgetOpenLinkError => '打开链接失败';

  @override
  String chatMessageWidgetCitationsTitle(int count) {
    return '引用（共$count条）';
  }

  @override
  String get chatMessageWidgetRegenerateTooltip => '重新生成';

  @override
  String get chatMessageWidgetRegenerateConfirmTitle => '确认重新生成';

  @override
  String get chatMessageWidgetRegenerateConfirmContent =>
      '重新生成只会更新当前消息，不会删除下面的消息。确定要继续吗？';

  @override
  String get chatMessageWidgetRegenerateConfirmCancel => '取消';

  @override
  String get chatMessageWidgetRegenerateConfirmOk => '重新生成';

  @override
  String get chatMessageWidgetStopTooltip => '停止';

  @override
  String get chatMessageWidgetSpeakTooltip => '朗读';

  @override
  String get chatMessageWidgetTranslateTooltip => '翻译';

  @override
  String get chatMessageWidgetBuiltinSearchHideNote => '隐藏内置搜索工具卡片';

  @override
  String get chatMessageWidgetDeepThinking => '深度思考';

  @override
  String get chatMessageWidgetCreateMemory => '创建记忆';

  @override
  String get chatMessageWidgetEditMemory => '编辑记忆';

  @override
  String get chatMessageWidgetDeleteMemory => '删除记忆';

  @override
  String chatMessageWidgetWebSearch(String query) {
    return '联网检索: $query';
  }

  @override
  String get chatMessageWidgetBuiltinSearch => '模型内置搜索';

  @override
  String chatMessageWidgetToolCall(String name) {
    return '调用工具: $name';
  }

  @override
  String chatMessageWidgetToolResult(String name) {
    return '调用工具: $name';
  }

  @override
  String get chatMessageWidgetNoResultYet => '（暂无结果）';

  @override
  String get chatMessageWidgetArguments => '参数';

  @override
  String get chatMessageWidgetResult => '结果';

  @override
  String get chatMessageWidgetImages => '图片';

  @override
  String chatMessageWidgetCitationsCount(int count) {
    return '共$count条引用';
  }

  @override
  String chatSelectionSelectedCountTitle(int count) {
    return '已选择$count条消息';
  }

  @override
  String get chatSelectionExportTxt => 'TXT';

  @override
  String get chatSelectionExportMd => 'MD';

  @override
  String get chatSelectionExportImage => '图片';

  @override
  String get chatSelectionThinkingTools => '思考工具';

  @override
  String get chatSelectionThinkingContent => '思考内容';

  @override
  String get messageExportSheetAssistant => '助手';

  @override
  String get messageExportSheetDefaultTitle => '新对话';

  @override
  String get messageExportSheetExporting => '正在导出…';

  @override
  String messageExportSheetExportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String messageExportSheetExportedAs(String filename) {
    return '已导出为 $filename';
  }

  @override
  String get displaySettingsPageEnableDollarLatexTitle => '启用 \$...\$ 渲染';

  @override
  String get displaySettingsPageEnableDollarLatexSubtitle =>
      '将 \$...\$ 之间的内容按行内数学公式渲染';

  @override
  String get displaySettingsPageEnableMathTitle => '启用数学公式渲染';

  @override
  String get displaySettingsPageEnableMathSubtitle => '渲染 LaTeX 数学公式（行内与块级）';

  @override
  String get displaySettingsPageEnableUserMarkdownTitle => '用户消息 Markdown 渲染';

  @override
  String get displaySettingsPageEnableReasoningMarkdownTitle =>
      '思维链 Markdown 渲染';

  @override
  String get displaySettingsPageEnableAssistantMarkdownTitle =>
      '助手消息 Markdown 渲染';

  @override
  String get displaySettingsPageMobileCodeBlockWrapTitle => '移动端代码块自动换行';

  @override
  String get displaySettingsPageAutoCollapseCodeBlockTitle => '自动折叠代码块';

  @override
  String get displaySettingsPageAutoCollapseCodeBlockLinesTitle => '超过多少行自动折叠';

  @override
  String get displaySettingsPageAutoCollapseCodeBlockLinesUnit => '行';

  @override
  String get messageExportSheetFormatTitle => '导出格式';

  @override
  String get messageExportSheetMarkdown => 'Markdown';

  @override
  String get messageExportSheetSingleMarkdownSubtitle => '将该消息导出为 Markdown 文件';

  @override
  String get messageExportSheetBatchMarkdownSubtitle => '将选中的消息导出为 Markdown 文件';

  @override
  String get messageExportSheetPlainText => '纯文本';

  @override
  String get messageExportSheetSingleTxtSubtitle => '将该消息导出为 TXT 文件';

  @override
  String get messageExportSheetBatchTxtSubtitle => '将选中的消息导出为 TXT 文件';

  @override
  String get messageExportSheetExportImage => '导出为图片';

  @override
  String get messageExportSheetSingleExportImageSubtitle => '将该消息渲染为 PNG 图片';

  @override
  String get messageExportSheetBatchExportImageSubtitle => '将选中的消息渲染为 PNG 图片';

  @override
  String get messageExportSheetShowThinkingAndToolCards => '显示思考卡片和工具卡片';

  @override
  String get messageExportSheetShowThinkingContent => '显示思考内容';

  @override
  String get messageExportThinkingContentLabel => '思考内容';

  @override
  String get messageExportSheetDateTimeWithSecondsPattern =>
      'yyyy年M月d日 HH:mm:ss';

  @override
  String get exportDisclaimerAiGenerated => '内容由 AI 生成，请仔细甄别';

  @override
  String get imagePreviewSheetSaveImage => '保存图片';

  @override
  String get imagePreviewSheetSaveSuccess => '已保存到相册';

  @override
  String imagePreviewSheetSaveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get sideDrawerMenuRename => '重命名';

  @override
  String get sideDrawerMenuPin => '置顶';

  @override
  String get sideDrawerMenuUnpin => '取消置顶';

  @override
  String get sideDrawerMenuRegenerateTitle => '重新生成标题';

  @override
  String get sideDrawerMenuMoveTo => '移动到';

  @override
  String get sideDrawerMenuDelete => '删除';

  @override
  String sideDrawerDeleteSnackbar(String title) {
    return '已删除“$title”';
  }

  @override
  String get sideDrawerRenameHint => '输入新名称';

  @override
  String get sideDrawerCancel => '取消';

  @override
  String get sideDrawerOK => '确定';

  @override
  String get sideDrawerSave => '保存';

  @override
  String get sideDrawerGreetingMorning => '早上好 👋';

  @override
  String get sideDrawerGreetingNoon => '中午好 👋';

  @override
  String get sideDrawerGreetingAfternoon => '下午好 👋';

  @override
  String get sideDrawerGreetingEvening => '晚上好 👋';

  @override
  String get sideDrawerDateToday => '今天';

  @override
  String get sideDrawerDateYesterday => '昨天';

  @override
  String get sideDrawerDateShortPattern => 'M月d日';

  @override
  String get sideDrawerDateFullPattern => 'yyyy年M月d日';

  @override
  String get sideDrawerSearchHint => '搜索当前助手';

  @override
  String get sideDrawerSearchAssistantsHint => '搜索助手';

  @override
  String get sideDrawerTopicSearchModeLabel => '话题模式';

  @override
  String get sideDrawerGlobalSearchModeLabel => '全局模式';

  @override
  String get sideDrawerSearchModeSwipeToTopicHint => '左/右滑搜索栏切换到话题搜索';

  @override
  String get sideDrawerSearchModeSwipeToGlobalHint => '左/右滑搜索栏切换到全局搜索';

  @override
  String get sideDrawerGlobalSearchHint => '搜索全部会话';

  @override
  String get sideDrawerGlobalSearchEmptyHint => '在标题和消息中全局搜索';

  @override
  String get sideDrawerGlobalSearchNoResults => '没有匹配的会话';

  @override
  String sideDrawerGlobalSearchResultCount(int count) {
    return '共 $count 条结果';
  }

  @override
  String sideDrawerUpdateTitle(String version) {
    return '发现新版本：$version';
  }

  @override
  String sideDrawerUpdateTitleWithBuild(String version, int build) {
    return '发现新版本：$version ($build)';
  }

  @override
  String get sideDrawerLinkCopied => '已复制下载链接';

  @override
  String get sideDrawerPinnedLabel => '置顶';

  @override
  String get sideDrawerHistory => '聊天历史';

  @override
  String get sideDrawerSettings => '设置';

  @override
  String get sideDrawerChooseAssistantTitle => '选择助手';

  @override
  String get sideDrawerChooseImage => '选择图片';

  @override
  String get sideDrawerChooseEmoji => '选择表情';

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
  String get sideDrawerNicknameHint => '输入新的昵称';

  @override
  String get sideDrawerRename => '重命名';

  @override
  String get chatInputBarHint => '输入消息与AI聊天';

  @override
  String get chatInputBarSelectModelTooltip => '选择模型';

  @override
  String get chatInputBarOnlineSearchTooltip => '联网搜索';

  @override
  String get chatInputBarReasoningStrengthTooltip => '思维链强度';

  @override
  String get chatInputBarMcpServersTooltip => 'MCP服务器';

  @override
  String get chatInputBarMoreTooltip => '更多';

  @override
  String get chatInputBarQueuedPending => '排队中';

  @override
  String get chatInputBarQueuedCancel => '取消排队';

  @override
  String get chatInputBarInsertNewline => '换行';

  @override
  String get chatInputBarExpand => '展开';

  @override
  String get chatInputBarCollapse => '收起';

  @override
  String get mcpPageBackTooltip => '返回';

  @override
  String get mcpPageAddMcpTooltip => '添加 MCP';

  @override
  String get mcpPageNoServers => '暂无 MCP 服务器';

  @override
  String get mcpPageErrorDialogTitle => '连接错误';

  @override
  String get mcpPageErrorNoDetails => '未提供错误详情';

  @override
  String get mcpPageClose => '关闭';

  @override
  String get mcpPageReconnect => '重新连接';

  @override
  String get mcpPageStatusConnected => '已连接';

  @override
  String get mcpPageStatusConnecting => '连接中…';

  @override
  String get mcpPageStatusDisconnected => '未连接';

  @override
  String get mcpPageStatusDisabled => '已禁用';

  @override
  String mcpPageToolsCount(int enabled, int total) {
    return '工具: $enabled/$total';
  }

  @override
  String get mcpPageConnectionFailed => '连接失败';

  @override
  String get mcpPageDetails => '详情';

  @override
  String get mcpPageDelete => '删除';

  @override
  String get mcpPageConfirmDeleteTitle => '确认删除';

  @override
  String get mcpPageConfirmDeleteContent => '删除后可通过撤销恢复。是否删除？';

  @override
  String get mcpPageServerDeleted => '已删除服务器';

  @override
  String get mcpPageUndo => '撤销';

  @override
  String get mcpPageCancel => '取消';

  @override
  String get mcpConversationSheetTitle => 'MCP服务器';

  @override
  String get mcpConversationSheetSubtitle => '选择在此助手中启用的服务';

  @override
  String get mcpConversationSheetSelectAll => '全选';

  @override
  String get mcpConversationSheetClearAll => '全不选';

  @override
  String get mcpConversationSheetNoRunning => '暂无已启动的 MCP 服务器';

  @override
  String get mcpConversationSheetConnected => '已连接';

  @override
  String mcpConversationSheetToolsCount(int enabled, int total) {
    return '工具: $enabled/$total';
  }

  @override
  String get mcpServerEditSheetEnabledLabel => '是否启用';

  @override
  String get mcpServerEditSheetNameLabel => '名称';

  @override
  String get mcpServerEditSheetTransportLabel => '传输类型';

  @override
  String get mcpServerEditSheetSseRetryHint => '如果SSE连接失败，请多试几次';

  @override
  String get mcpServerEditSheetUrlLabel => '服务器地址';

  @override
  String get mcpServerEditSheetCustomHeadersTitle => '自定义请求头';

  @override
  String get mcpServerEditSheetHeaderNameLabel => '请求头名称';

  @override
  String get mcpServerEditSheetHeaderNameHint => '如 Authorization';

  @override
  String get mcpServerEditSheetHeaderValueLabel => '请求头值';

  @override
  String get mcpServerEditSheetHeaderValueHint => '如 Bearer xxxxxx';

  @override
  String get mcpServerEditSheetRemoveHeaderTooltip => '删除';

  @override
  String get mcpServerEditSheetAddHeader => '添加请求头';

  @override
  String get mcpServerEditSheetTitleEdit => '编辑 MCP';

  @override
  String get mcpServerEditSheetTitleAdd => '添加 MCP';

  @override
  String get mcpServerEditSheetSyncToolsTooltip => '同步工具';

  @override
  String get mcpServerEditSheetTabBasic => '基础设置';

  @override
  String get mcpServerEditSheetTabTools => '工具';

  @override
  String get mcpServerEditSheetNoToolsHint => '暂无工具，点击上方同步';

  @override
  String get mcpServerEditSheetCancel => '取消';

  @override
  String get mcpServerEditSheetSave => '保存';

  @override
  String get mcpServerEditSheetUrlRequired => '请输入服务器地址';

  @override
  String get defaultModelPageBackTooltip => '返回';

  @override
  String get defaultModelPageTitle => '默认模型';

  @override
  String get defaultModelPageChatModelTitle => '聊天模型';

  @override
  String get defaultModelPageChatModelSubtitle => '全局默认的聊天模型';

  @override
  String get defaultModelPageTitleModelTitle => '标题总结模型';

  @override
  String get defaultModelPageTitleModelSubtitle => '用于总结对话标题的模型，推荐使用快速且便宜的模型';

  @override
  String get defaultModelPageSummaryModelTitle => '摘要模型';

  @override
  String get defaultModelPageSummaryModelSubtitle => '用于生成对话摘要的模型，推荐使用快速且便宜的模型';

  @override
  String get assistantEditRecentChatsSummaryFrequencyTitle => '摘要更新频率';

  @override
  String get assistantEditRecentChatsSummaryFrequencyDescription =>
      '累计达到所选条数的新消息后，会更新历史聊天摘要。';

  @override
  String assistantEditRecentChatsSummaryFrequencyOption(int count) {
    return '每 $count 条';
  }

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomButton => '自定义';

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomTitle => '自定义摘要频率';

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomDescription =>
      '输入累计多少条新消息后再更新历史聊天摘要。';

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomLabel => '新消息条数';

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomHint =>
      '请输入大于 0 的整数';

  @override
  String get assistantEditRecentChatsSummaryFrequencyCustomInvalid =>
      '请输入大于 0 的整数';

  @override
  String get defaultModelPageTranslateModelTitle => '翻译模型';

  @override
  String get defaultModelPageTranslateModelSubtitle =>
      '用于翻译消息内容的模型，推荐使用快速且准确的模型';

  @override
  String get defaultModelPageOcrModelTitle => 'OCR 模型';

  @override
  String get defaultModelPageOcrModelSubtitle => '用于对图片执行文字识别的模型';

  @override
  String get defaultModelPagePromptLabel => '提示词';

  @override
  String get defaultModelPageTitlePromptHint => '输入用于标题总结的提示词模板';

  @override
  String get defaultModelPageSummaryPromptHint => '输入用于生成摘要的提示词模板';

  @override
  String get defaultModelPageTranslatePromptHint => '输入用于翻译的提示词模板';

  @override
  String get defaultModelPageOcrPromptHint => '输入用于 OCR 识别的提示词模板';

  @override
  String get defaultModelPageResetDefault => '重置为默认';

  @override
  String get defaultModelPageSave => '保存';

  @override
  String defaultModelPageTitleVars(String contentVar, String localeVar) {
    return '变量: 对话内容: $contentVar, 语言: $localeVar';
  }

  @override
  String defaultModelPageSummaryVars(
    String previousSummaryVar,
    String userMessagesVar,
  ) {
    return '变量：旧摘要：$previousSummaryVar，新消息：$userMessagesVar';
  }

  @override
  String get defaultModelPageCompressModelTitle => '压缩模型';

  @override
  String get defaultModelPageCompressModelSubtitle => '用于压缩对话上下文的模型，推荐使用快速模型';

  @override
  String get defaultModelPageCompressPromptHint => '输入用于上下文压缩的提示词模板';

  @override
  String defaultModelPageCompressVars(String contentVar, String localeVar) {
    return '变量：对话内容：$contentVar，语言：$localeVar';
  }

  @override
  String defaultModelPageTranslateVars(String sourceVar, String targetVar) {
    return '变量：原始文本：$sourceVar，目标语言：$targetVar';
  }

  @override
  String get defaultModelPageUseCurrentModel => '使用当前对话模型';

  @override
  String get translatePagePasteButton => '粘贴';

  @override
  String get translatePageCopyResult => '复制结果';

  @override
  String get translatePageClearAll => '清空全部';

  @override
  String get translatePageInputHint => '输入要翻译的内容…';

  @override
  String get translatePageOutputHint => '翻译结果会显示在这里…';

  @override
  String get modelDetailSheetAddModel => '添加模型';

  @override
  String get modelDetailSheetEditModel => '编辑模型';

  @override
  String get modelDetailSheetBasicTab => '基本设置';

  @override
  String get modelDetailSheetAdvancedTab => '高级设置';

  @override
  String get modelDetailSheetBuiltinToolsTab => '内置工具';

  @override
  String get modelDetailSheetModelIdLabel => '模型 ID';

  @override
  String get modelDetailSheetModelIdHint => '必填，建议小写字母、数字、连字符';

  @override
  String modelDetailSheetModelIdDisabledHint(String modelId) {
    return '$modelId';
  }

  @override
  String get modelDetailSheetModelNameLabel => '模型名称';

  @override
  String get modelDetailSheetModelTypeLabel => '模型类型';

  @override
  String get modelDetailSheetChatType => '聊天';

  @override
  String get modelDetailSheetEmbeddingType => '嵌入';

  @override
  String get modelDetailSheetInputModesLabel => '输入模式';

  @override
  String get modelDetailSheetOutputModesLabel => '输出模式';

  @override
  String get modelDetailSheetAbilitiesLabel => '能力';

  @override
  String get modelDetailSheetTextMode => '文本';

  @override
  String get modelDetailSheetImageMode => '图片';

  @override
  String get modelDetailSheetToolsAbility => '工具';

  @override
  String get modelDetailSheetReasoningAbility => '推理';

  @override
  String get modelDetailSheetProviderOverrideDescription =>
      '供应商重写：允许为特定模型自定义供应商设置。（暂未实现）';

  @override
  String get modelDetailSheetAddProviderOverride => '添加供应商重写';

  @override
  String get modelDetailSheetCustomHeadersTitle => '自定义 Headers';

  @override
  String get modelDetailSheetAddHeader => '添加 Header';

  @override
  String get modelDetailSheetCustomBodyTitle => '自定义 Body';

  @override
  String get modelFetchInvertTooltip => '反选';

  @override
  String get modelDetailSheetSaveFailedMessage => '保存失败，请重试';

  @override
  String get modelDetailSheetAddBody => '添加 Body';

  @override
  String get modelDetailSheetBuiltinToolsDescription => '内置工具仅支持官方 API。';

  @override
  String get modelDetailSheetBuiltinToolsUnsupportedHint => '当前供应商不支持这些内置工具。';

  @override
  String get modelDetailSheetSearchTool => '搜索';

  @override
  String get modelDetailSheetSearchToolDescription => '启用 Google 搜索集成';

  @override
  String get modelDetailSheetUrlContextTool => 'URL 上下文';

  @override
  String get modelDetailSheetUrlContextToolDescription => '启用 URL 内容处理';

  @override
  String get modelDetailSheetCodeExecutionTool => '代码执行';

  @override
  String get modelDetailSheetCodeExecutionToolDescription => '启用代码执行工具';

  @override
  String get modelDetailSheetYoutubeTool => 'YouTube';

  @override
  String get modelDetailSheetYoutubeToolDescription =>
      '启用 YouTube 链接读取（自动识别提示词中的链接）';

  @override
  String get modelDetailSheetOpenaiBuiltinToolsResponsesOnlyHint =>
      '需要启用 OpenAI Responses API。';

  @override
  String get modelDetailSheetOpenaiCodeInterpreterTool => '代码解释器';

  @override
  String get modelDetailSheetOpenaiCodeInterpreterToolDescription =>
      '启用代码解释器工具（容器自动，内存上限 4g）';

  @override
  String get modelDetailSheetOpenaiImageGenerationTool => '图像生成';

  @override
  String get modelDetailSheetOpenaiImageGenerationToolDescription => '启用图像生成工具';

  @override
  String get modelDetailSheetCancelButton => '取消';

  @override
  String get modelDetailSheetAddButton => '添加';

  @override
  String get modelDetailSheetConfirmButton => '确认';

  @override
  String get modelDetailSheetInvalidIdError => '请输入有效的模型 ID（不少于2个字符）';

  @override
  String get modelDetailSheetModelIdExistsError => '模型 ID 已存在';

  @override
  String get modelDetailSheetHeaderKeyHint => 'Header Key';

  @override
  String get modelDetailSheetHeaderValueHint => 'Header Value';

  @override
  String get modelDetailSheetBodyKeyHint => 'Body Key';

  @override
  String get modelDetailSheetBodyJsonHint => 'Body JSON';

  @override
  String get modelSelectSheetSearchHint => '搜索模型或服务商';

  @override
  String get modelSelectSheetFavoritesSection => '收藏';

  @override
  String get modelSelectSheetFavoriteTooltip => '收藏';

  @override
  String get modelSelectSheetChatType => '聊天';

  @override
  String get modelSelectSheetEmbeddingType => '嵌入';

  @override
  String get providerDetailPageShareTooltip => '分享';

  @override
  String get providerDetailPageDeleteProviderTooltip => '删除供应商';

  @override
  String get providerDetailPageDeleteProviderTitle => '删除供应商';

  @override
  String get providerDetailPageDeleteProviderContent => '确定要删除该供应商吗？此操作不可撤销。';

  @override
  String get providerDetailPageCancelButton => '取消';

  @override
  String get providerDetailPageDeleteButton => '删除';

  @override
  String get providerDetailPageProviderDeletedSnackbar => '已删除供应商';

  @override
  String get providerDetailPageConfigTab => '配置';

  @override
  String get providerDetailPageModelsTab => '模型';

  @override
  String get providerDetailPageNetworkTab => '网络代理';

  @override
  String get providerDetailPageEnabledTitle => '是否启用';

  @override
  String get providerDetailPageManageSectionTitle => '管理';

  @override
  String get providerDetailPageNameLabel => '名称';

  @override
  String get providerDetailPageApiKeyHint => '留空则使用上层默认';

  @override
  String get providerDetailPageHideTooltip => '隐藏';

  @override
  String get providerDetailPageShowTooltip => '显示';

  @override
  String get providerDetailPageApiPathLabel => 'API 路径';

  @override
  String get providerDetailPageResponseApiTitle => 'Response API (/responses)';

  @override
  String get providerDetailPageAihubmixAppCodeLabel => '应用 Code（享 10% 优惠）';

  @override
  String get providerDetailPageAihubmixAppCodeHelp =>
      '为请求附加 APP-Code，可享 10% 优惠，仅对 AIhubmix 生效。';

  @override
  String get providerDetailPageVertexAiTitle => 'Vertex AI';

  @override
  String get providerDetailPageLocationLabel => '区域 Location';

  @override
  String get providerDetailPageProjectIdLabel => '项目 ID';

  @override
  String get providerDetailPageServiceAccountJsonLabel => '服务账号 JSON（粘贴或导入）';

  @override
  String get providerDetailPageImportJsonButton => '导入 JSON';

  @override
  String get providerDetailPageImportJsonReadFailedMessage => '读取文件失败';

  @override
  String get providerDetailPageTestButton => '测试';

  @override
  String get providerDetailPageSaveButton => '保存';

  @override
  String get providerDetailPageProviderRemovedMessage => '供应商已删除';

  @override
  String get providerDetailPageNoModelsTitle => '暂无模型';

  @override
  String get providerDetailPageNoModelsSubtitle => '点击下方按钮添加模型';

  @override
  String get providerDetailPageDeleteModelButton => '删除';

  @override
  String get providerDetailPageConfirmDeleteTitle => '确认删除';

  @override
  String get providerDetailPageConfirmDeleteContent => '删除后可通过撤销恢复。是否删除？';

  @override
  String get providerDetailPageModelDeletedSnackbar => '已删除模型';

  @override
  String get providerDetailPageUndoButton => '撤销';

  @override
  String get providerDetailPageAddNewModelButton => '添加新模型';

  @override
  String get providerDetailPageFetchModelsButton => '获取';

  @override
  String get providerDetailPageEnableProxyTitle => '是否启用代理';

  @override
  String get providerDetailPageHostLabel => '主机地址';

  @override
  String get providerDetailPagePortLabel => '端口';

  @override
  String get providerDetailPageUsernameOptionalLabel => '用户名（可选）';

  @override
  String get providerDetailPagePasswordOptionalLabel => '密码（可选）';

  @override
  String get providerDetailPageSavedSnackbar => '已保存';

  @override
  String get providerDetailPageEmbeddingsGroupTitle => '嵌入';

  @override
  String get providerDetailPageOtherModelsGroupTitle => '其他模型';

  @override
  String get providerDetailPageRemoveGroupTooltip => '移除本组';

  @override
  String get providerDetailPageAddGroupTooltip => '添加本组';

  @override
  String get providerDetailPageFilterHint => '输入模型名称筛选';

  @override
  String get providerDetailPageDeleteText => '删除';

  @override
  String get providerDetailPageEditTooltip => '编辑';

  @override
  String get providerDetailPageTestConnectionTitle => '测试连接';

  @override
  String get providerDetailPageSelectModelButton => '选择模型';

  @override
  String get providerDetailPageChangeButton => '更换';

  @override
  String get providerDetailPageUseStreamingLabel => '使用流式';

  @override
  String get providerDetailPageTestingMessage => '正在测试…';

  @override
  String get providerDetailPageTestSuccessMessage => '测试成功';

  @override
  String get providersPageTitle => '供应商';

  @override
  String get providersPageImportTooltip => '导入';

  @override
  String get providersPageAddTooltip => '新增';

  @override
  String get providersPageSearchHint => '搜索供应商或分组';

  @override
  String get providersPageProviderAddedSnackbar => '已添加供应商';

  @override
  String get providerGroupsGroupLabel => '分组';

  @override
  String get providerGroupsOther => '其他';

  @override
  String get providerGroupsOtherUngroupedOption => '其他（未分组）';

  @override
  String get providerGroupsPickerTitle => '选择分组';

  @override
  String get providerGroupsManageTitle => '分组管理';

  @override
  String get providerGroupsManageAction => '管理分组';

  @override
  String get providerGroupsCreateNewGroupAction => '新建分组…';

  @override
  String get providerGroupsCreateDialogTitle => '新建分组';

  @override
  String get providerGroupsNameHint => '输入分组名称';

  @override
  String get providerGroupsCreateDialogCancel => '取消';

  @override
  String get providerGroupsCreateDialogOk => '创建';

  @override
  String get providerGroupsCreateFailedToast => '创建分组失败';

  @override
  String get providerGroupsDeleteConfirmTitle => '删除分组';

  @override
  String get providerGroupsDeleteConfirmContent => '该组内供应商将移动到「其他」';

  @override
  String get providerGroupsDeleteConfirmCancel => '取消';

  @override
  String get providerGroupsDeleteConfirmOk => '删除';

  @override
  String get providerGroupsDeletedToast => '已删除分组';

  @override
  String get providerGroupsEmptyState => '暂无分组';

  @override
  String get providerGroupsExpandToMoveToast => '请先展开分组';

  @override
  String get providersPageSiliconFlowName => '硅基流动';

  @override
  String get providersPageAliyunName => '阿里云千问';

  @override
  String get providersPageZhipuName => '智谱';

  @override
  String get providersPageByteDanceName => '火山引擎';

  @override
  String get providersPageEnabledStatus => '启用';

  @override
  String get providersPageDisabledStatus => '禁用';

  @override
  String get providersPageModelsCountSuffix => ' models';

  @override
  String get providersPageModelsCountSingleSuffix => '个模型';

  @override
  String get addProviderSheetTitle => '添加供应商';

  @override
  String get addProviderSheetEnabledLabel => '是否启用';

  @override
  String get addProviderSheetNameLabel => '名称';

  @override
  String get addProviderSheetApiPathLabel => 'API 路径';

  @override
  String get addProviderSheetVertexAiLocationLabel => '位置';

  @override
  String get addProviderSheetVertexAiProjectIdLabel => '项目ID';

  @override
  String get addProviderSheetVertexAiServiceAccountJsonLabel =>
      '服务账号 JSON（粘贴或导入）';

  @override
  String get addProviderSheetImportJsonButton => '导入 JSON';

  @override
  String get addProviderSheetCancelButton => '取消';

  @override
  String get addProviderSheetAddButton => '添加';

  @override
  String get importProviderSheetTitle => '导入供应商';

  @override
  String get importProviderSheetScanQrTooltip => '扫码导入';

  @override
  String get importProviderSheetFromGalleryTooltip => '从相册导入';

  @override
  String importProviderSheetImportSuccessMessage(int count) {
    return '已导入$count个供应商';
  }

  @override
  String importProviderSheetImportFailedMessage(String error) {
    return '导入失败: $error';
  }

  @override
  String get importProviderSheetDescription =>
      '粘贴分享字符串（可多行，每行一个）或 ChatBox JSON';

  @override
  String get importProviderSheetInputHint => 'ai-provider:v1:...';

  @override
  String get importProviderSheetCancelButton => '取消';

  @override
  String get importProviderSheetImportButton => '导入';

  @override
  String get shareProviderSheetTitle => '分享供应商配置';

  @override
  String get shareProviderSheetDescription => '复制下面的分享字符串，或使用二维码分享。';

  @override
  String get shareProviderSheetCopiedMessage => '已复制';

  @override
  String get shareProviderSheetCopyButton => '复制';

  @override
  String get shareProviderSheetShareButton => '分享';

  @override
  String get desktopProviderContextMenuShare => '分享';

  @override
  String get desktopProviderShareCopyText => '复制文字';

  @override
  String get desktopProviderShareCopyQr => '复制二维码';

  @override
  String get providerDetailPageApiBaseUrlLabel => 'API Base URL';

  @override
  String get providerDetailPageModelsTitle => '模型';

  @override
  String get providerModelsGetButton => '获取';

  @override
  String get providerDetailPageCapsVision => '视觉';

  @override
  String get providerDetailPageCapsImage => '生图';

  @override
  String get providerDetailPageCapsTool => '工具';

  @override
  String get providerDetailPageCapsReasoning => '推理';

  @override
  String get qrScanPageTitle => '扫码导入';

  @override
  String get qrScanPageInstruction => '将二维码对准取景框';

  @override
  String get searchServicesPageBackTooltip => '返回';

  @override
  String get searchServicesPageTitle => '搜索服务';

  @override
  String get searchServicesPageDone => '完成';

  @override
  String get searchServicesPageEdit => '编辑';

  @override
  String get searchServicesPageAddProvider => '添加提供商';

  @override
  String get searchServicesPageSearchProviders => '搜索提供商';

  @override
  String get searchServicesPageGeneralOptions => '通用选项';

  @override
  String get searchServicesPageAutoTestTitle => '启动时自动测试连接';

  @override
  String get searchServicesPageMaxResults => '最大结果数';

  @override
  String get searchServicesPageTimeoutSeconds => '超时时间（秒）';

  @override
  String get searchServicesPageAtLeastOneServiceRequired => '至少需要一个搜索服务';

  @override
  String get searchServicesPageTestingStatus => '测试中…';

  @override
  String get searchServicesPageConnectedStatus => '已连接';

  @override
  String get searchServicesPageFailedStatus => '连接失败';

  @override
  String get searchServicesPageNotTestedStatus => '未测试';

  @override
  String get searchServicesPageEditServiceTooltip => '编辑服务';

  @override
  String get searchServicesPageTestConnectionTooltip => '测试连接';

  @override
  String get searchServicesPageDeleteServiceTooltip => '删除服务';

  @override
  String get searchServicesPageConfiguredStatus => '已配置';

  @override
  String get miniMapTitle => '迷你地图';

  @override
  String get miniMapTooltip => '迷你地图';

  @override
  String get miniMapScrollToBottomTooltip => '滚动到底部';

  @override
  String get searchServicesPageApiKeyRequiredStatus => '需要 API Key';

  @override
  String get searchServicesPageUrlRequiredStatus => '需要 URL';

  @override
  String get searchServicesAddDialogTitle => '添加搜索服务';

  @override
  String get searchServicesAddDialogServiceType => '服务类型';

  @override
  String get searchServicesAddDialogBingLocal => '本地';

  @override
  String get searchServicesAddDialogCancel => '取消';

  @override
  String get searchServicesAddDialogAdd => '添加';

  @override
  String get searchServicesAddDialogApiKeyRequired => 'API Key 必填';

  @override
  String get searchServicesFieldCustomUrlOptional => '自定义 URL（可选）';

  @override
  String get searchServicesAddDialogInstanceUrl => '实例 URL';

  @override
  String get searchServicesAddDialogUrlRequired => 'URL 必填';

  @override
  String get searchServicesAddDialogEnginesOptional => '搜索引擎（可选）';

  @override
  String get searchServicesAddDialogLanguageOptional => '语言（可选）';

  @override
  String get searchServicesAddDialogUsernameOptional => '用户名（可选）';

  @override
  String get searchServicesAddDialogPasswordOptional => '密码（可选）';

  @override
  String get searchServicesAddDialogRegionOptional => '地区（可选，默认 us-en）';

  @override
  String get searchServicesEditDialogEdit => '编辑';

  @override
  String get searchServicesEditDialogCancel => '取消';

  @override
  String get searchServicesEditDialogSave => '保存';

  @override
  String get searchServicesEditDialogBingLocalNoConfig => 'Bing 本地搜索不需要配置。';

  @override
  String get searchServicesEditDialogApiKeyRequired => 'API Key 必填';

  @override
  String get searchServicesEditDialogInstanceUrl => '实例 URL';

  @override
  String get searchServicesEditDialogUrlRequired => 'URL 必填';

  @override
  String get searchServicesEditDialogEnginesOptional => '搜索引擎（可选）';

  @override
  String get searchServicesEditDialogLanguageOptional => '语言（可选）';

  @override
  String get searchServicesEditDialogUsernameOptional => '用户名（可选）';

  @override
  String get searchServicesEditDialogPasswordOptional => '密码（可选）';

  @override
  String get searchServicesEditDialogRegionOptional => '地区（可选，默认 us-en）';

  @override
  String get searchSettingsSheetTitle => '搜索设置';

  @override
  String get searchSettingsSheetBuiltinSearchTitle => '模型内置搜索';

  @override
  String get searchSettingsSheetBuiltinSearchDescription => '是否启用模型内置的搜索功能';

  @override
  String get searchSettingsSheetClaudeDynamicSearchTitle => '模型内置搜索(新)';

  @override
  String get searchSettingsSheetClaudeDynamicSearchDescription =>
      '在支持的 Claude 官方模型上使用 `web_search_20260209`，支持动态过滤能力。';

  @override
  String get searchSettingsSheetWebSearchTitle => '网络搜索';

  @override
  String get searchSettingsSheetWebSearchDescription => '是否启用网页搜索';

  @override
  String get searchSettingsSheetOpenSearchServicesTooltip => '打开搜索服务设置';

  @override
  String get searchSettingsSheetNoServicesMessage => '暂无可用服务，请先在\"搜索服务\"中添加';

  @override
  String get aboutPageEasterEggMessage => '\n（好吧现在还没彩蛋）';

  @override
  String get aboutPageEasterEggButton => '好的';

  @override
  String get aboutPageAppName => 'SYCTB';

  @override
  String get aboutPageAppDescription => '开源AI 助手';

  @override
  String get aboutPageNoQQGroup => '暂无QQ群';

  @override
  String get aboutPageVersion => '版本';

  @override
  String aboutPageVersionDetail(String version, String buildNumber) {
    return '$version / $buildNumber';
  }

  @override
  String get aboutPageSystem => '系统';

  @override
  String get aboutPageLoadingPlaceholder => '...';

  @override
  String get aboutPageUnknownPlaceholder => '-';

  @override
  String get aboutPagePlatformMacos => 'macOS';

  @override
  String get aboutPagePlatformWindows => 'Windows';

  @override
  String get aboutPagePlatformLinux => 'Linux';

  @override
  String get aboutPagePlatformAndroid => 'Android';

  @override
  String get aboutPagePlatformIos => 'iOS';

  @override
  String aboutPagePlatformOther(String os) {
    return '其他（$os）';
  }

  @override
  String get aboutPageWebsite => '官网';

  @override
  String get aboutPageGithub => 'GitHub';

  @override
  String get aboutPageLicense => '许可证';

  @override
  String get aboutPageJoinQQGroup => '加入QQ群';

  @override
  String get aboutPageJoinDiscord => '在 Discord 中加入我们';

  @override
  String get displaySettingsPageShowUserAvatarTitle => '显示用户头像';

  @override
  String get displaySettingsPageShowUserAvatarSubtitle => '是否在聊天消息中显示用户头像';

  @override
  String get displaySettingsPageShowUserNameTimestampTitle => '显示用户名称和时间戳';

  @override
  String get displaySettingsPageShowUserNameTimestampSubtitle =>
      '是否在聊天消息中显示用户名称和时间戳';

  @override
  String get displaySettingsPageShowUserNameTitle => '显示用户名称';

  @override
  String get displaySettingsPageShowUserTimestampTitle => '显示用户时间戳';

  @override
  String get displaySettingsPageShowUserMessageActionsTitle => '显示用户消息操作按钮';

  @override
  String get displaySettingsPageShowUserMessageActionsSubtitle =>
      '在用户消息下方显示复制、重发与更多按钮';

  @override
  String get displaySettingsPageShowModelNameTimestampTitle => '显示模型名称和时间戳';

  @override
  String get displaySettingsPageShowModelNameTimestampSubtitle =>
      '是否在聊天消息中显示模型名称和时间戳';

  @override
  String get displaySettingsPageShowModelNameTitle => '显示模型名称';

  @override
  String get displaySettingsPageShowModelTimestampTitle => '显示模型时间戳';

  @override
  String get displaySettingsPageShowProviderInChatMessageTitle => '模型名称后显示供应商';

  @override
  String get displaySettingsPageShowProviderInChatMessageSubtitle =>
      '在聊天消息的模型名称后面显示供应商名称（如 模型 | 供应商）';

  @override
  String get displaySettingsPageChatModelIconTitle => '聊天列表模型图标';

  @override
  String get displaySettingsPageChatModelIconSubtitle => '是否在聊天消息中显示模型图标';

  @override
  String get displaySettingsPageShowTokenStatsTitle => '显示Token和上下文统计';

  @override
  String get displaySettingsPageShowTokenStatsSubtitle => '显示 token 用量与消息数量';

  @override
  String get displaySettingsPageAutoCollapseThinkingTitle => '自动折叠思考';

  @override
  String get displaySettingsPageAutoCollapseThinkingSubtitle =>
      '思考完成后自动折叠，保持界面简洁';

  @override
  String get displaySettingsPageCollapseThinkingStepsTitle => '折叠思考步骤';

  @override
  String get displaySettingsPageCollapseThinkingStepsSubtitle =>
      '默认只显示最新步骤，展开后查看全部';

  @override
  String get displaySettingsPageShowToolResultSummaryTitle => '显示工具结果摘要';

  @override
  String get displaySettingsPageShowToolResultSummarySubtitle =>
      '在工具步骤下方显示摘要文本';

  @override
  String chainOfThoughtExpandSteps(Object count) {
    return '展开更多 $count 步';
  }

  @override
  String get chainOfThoughtCollapse => '收起';

  @override
  String get displaySettingsPageShowChatListDateTitle => '显示对话列表日期';

  @override
  String get displaySettingsPageShowChatListDateSubtitle => '在左侧对话列表中显示日期分组标签';

  @override
  String get displaySettingsPageKeepSidebarOpenOnAssistantTapTitle =>
      '点选助手时不自动关闭侧边栏';

  @override
  String get displaySettingsPageKeepSidebarOpenOnTopicTapTitle =>
      '点选话题时不自动关闭侧边栏';

  @override
  String get displaySettingsPageKeepAssistantListExpandedOnSidebarCloseTitle =>
      '关闭侧边栏时不折叠助手列表';

  @override
  String get displaySettingsPageShowUpdatesTitle => '显示更新';

  @override
  String get displaySettingsPageShowUpdatesSubtitle => '显示应用更新通知';

  @override
  String get displaySettingsPageMessageNavButtonsTitle => '消息导航按钮';

  @override
  String get displaySettingsPageMessageNavButtonsSubtitle => '滚动时显示快速跳转按钮';

  @override
  String get displaySettingsPageUseNewAssistantAvatarUxTitle => '聊天标题栏显示助手头像';

  @override
  String get displaySettingsPageHapticsOnSidebarTitle => '侧边栏触觉反馈';

  @override
  String get displaySettingsPageHapticsOnSidebarSubtitle => '打开/关闭侧边栏时启用触觉反馈';

  @override
  String get displaySettingsPageHapticsGlobalTitle => '全局触觉反馈';

  @override
  String get displaySettingsPageHapticsIosSwitchTitle => '开关触觉反馈';

  @override
  String get displaySettingsPageHapticsOnListItemTapTitle => '列表项触觉反馈';

  @override
  String get displaySettingsPageHapticsOnCardTapTitle => '卡片触觉反馈';

  @override
  String get displaySettingsPageHapticsOnGenerateTitle => '消息生成触觉反馈';

  @override
  String get displaySettingsPageHapticsOnGenerateSubtitle => '生成消息时启用触觉反馈';

  @override
  String get displaySettingsPageNewChatAfterDeleteTitle => '删除话题后新建对话';

  @override
  String get displaySettingsPageNewChatOnAssistantSwitchTitle => '切换助手时新建对话';

  @override
  String get displaySettingsPageNewChatOnLaunchTitle => '启动时新建对话';

  @override
  String get displaySettingsPageEnterToSendTitle => '回车键发送消息';

  @override
  String get displaySettingsPageSendShortcutTitle => '发送快捷键';

  @override
  String get displaySettingsPageSendShortcutEnter => 'Enter';

  @override
  String get displaySettingsPageSendShortcutCtrlEnter => 'Ctrl/Cmd + Enter';

  @override
  String get displaySettingsPageAutoSwitchTopicsTitle => '自动切换话题';

  @override
  String get desktopDisplaySettingsTopicPositionTitle => '话题位置';

  @override
  String get desktopDisplaySettingsTopicPositionLeft => '左侧';

  @override
  String get desktopDisplaySettingsTopicPositionRight => '右侧';

  @override
  String get displaySettingsPageNewChatOnLaunchSubtitle => '应用启动时自动创建新对话';

  @override
  String get displaySettingsPageChatFontSizeTitle => '聊天字体大小';

  @override
  String get displaySettingsPageAutoScrollEnableTitle => '自动回到底部';

  @override
  String get displaySettingsPageAutoScrollIdleTitle => '自动回到底部延迟';

  @override
  String get displaySettingsPageAutoScrollIdleSubtitle => '用户停止滚动后等待多久再自动回到底部';

  @override
  String get displaySettingsPageAutoScrollDisabledLabel => '已关闭';

  @override
  String get displaySettingsPageChatFontSampleText => '这是一个示例的聊天文本';

  @override
  String get displaySettingsPageChatBackgroundMaskTitle => '背景图片遮罩透明度';

  @override
  String get displaySettingsPageThemeSettingsTitle => '主题设置';

  @override
  String get displaySettingsPageThemeColorTitle => '主题颜色';

  @override
  String get desktopSettingsFontsTitle => '字体设置';

  @override
  String get displaySettingsPageTrayTitle => '托盘';

  @override
  String get displaySettingsPageTrayShowTrayTitle => '显示托盘图标';

  @override
  String get displaySettingsPageTrayMinimizeOnCloseTitle => '关闭时最小化到托盘';

  @override
  String get desktopFontAppLabel => '应用字体';

  @override
  String get desktopFontCodeLabel => '代码字体';

  @override
  String get desktopFontFamilySystemDefault => '系统默认';

  @override
  String get desktopFontFamilyMonospaceDefault => '系统默认';

  @override
  String get desktopFontFilterHint => '输入以过滤字体…';

  @override
  String get displaySettingsPageAppFontTitle => '应用字体';

  @override
  String get displaySettingsPageCodeFontTitle => '代码字体';

  @override
  String get fontPickerChooseLocalFile => '选择本地文件';

  @override
  String get fontPickerGetFromGoogleFonts => '从 Google Fonts 获取';

  @override
  String get fontPickerFilterHint => '输入以过滤字体…';

  @override
  String get desktopFontLoading => '正在加载字体…';

  @override
  String get displaySettingsPageFontLocalFileLabel => '本地文件';

  @override
  String get displaySettingsPageFontResetLabel => '恢复默认';

  @override
  String get displaySettingsPageOtherSettingsTitle => '其他设置';

  @override
  String get themeSettingsPageDynamicColorSection => '动态颜色';

  @override
  String get themeSettingsPageUseDynamicColorTitle => '系统动态配色';

  @override
  String get themeSettingsPageUseDynamicColorSubtitle => '跟随系统取色（Android 12+）';

  @override
  String get themeSettingsPageUsePureBackgroundTitle => '纯色背景';

  @override
  String get themeSettingsPageUsePureBackgroundSubtitle => '仅气泡与强调色随主题变化';

  @override
  String get themeSettingsPageColorPalettesSection => '配色方案';

  @override
  String get ttsServicesPageBackButton => '返回';

  @override
  String get ttsServicesPageTitle => '语音服务';

  @override
  String get ttsServicesPageAddTooltip => '新增';

  @override
  String get ttsServicesPageAddNotImplemented => '新增 TTS 服务暂未实现';

  @override
  String get ttsServicesPageSystemTtsTitle => '系统TTS';

  @override
  String get ttsServicesPageSystemTtsAvailableSubtitle => '使用系统内置语音合成';

  @override
  String ttsServicesPageSystemTtsUnavailableSubtitle(String error) {
    return '不可用：$error';
  }

  @override
  String get ttsServicesPageSystemTtsUnavailableNotInitialized => '未初始化';

  @override
  String get ttsServicesPageTestSpeechText => '你好，这是一次测试语音。';

  @override
  String get ttsServicesPageConfigureTooltip => '配置';

  @override
  String get ttsServicesPageTestVoiceTooltip => '测试语音';

  @override
  String get ttsServicesPageStopTooltip => '停止';

  @override
  String get ttsServicesPageDeleteTooltip => '删除';

  @override
  String get ttsServicesPageSystemTtsSettingsTitle => '系统 TTS 设置';

  @override
  String get ttsServicesPageEngineLabel => '引擎';

  @override
  String get ttsServicesPageAutoLabel => '自动';

  @override
  String get ttsServicesPageLanguageLabel => '语言';

  @override
  String get ttsServicesPageSpeechRateLabel => '语速';

  @override
  String get ttsServicesPagePitchLabel => '音调';

  @override
  String get ttsServicesPageSettingsSavedMessage => '设置已保存。';

  @override
  String get ttsServicesPageDoneButton => '完成';

  @override
  String get ttsServicesPageNetworkSectionTitle => '网络 TTS';

  @override
  String get ttsServicesPageNoNetworkServices => '暂无语音服务';

  @override
  String get ttsServicesDialogAddTitle => '添加语音服务';

  @override
  String get ttsServicesDialogEditTitle => '编辑语音服务';

  @override
  String get ttsServicesDialogProviderType => '服务提供方';

  @override
  String get ttsServicesDialogCancelButton => '取消';

  @override
  String get ttsServicesDialogAddButton => '添加';

  @override
  String get ttsServicesDialogSaveButton => '保存';

  @override
  String get ttsServicesFieldNameLabel => '名称';

  @override
  String get ttsServicesFieldApiKeyLabel => 'API Key';

  @override
  String get ttsServicesFieldBaseUrlLabel => 'API 基址';

  @override
  String get ttsServicesFieldModelLabel => '模型';

  @override
  String get ttsServicesFieldVoiceLabel => '音色';

  @override
  String get ttsServicesFieldVoiceIdLabel => '音色 ID';

  @override
  String get ttsServicesFieldEmotionLabel => '情感';

  @override
  String get ttsServicesFieldSpeedLabel => '语速';

  @override
  String get ttsServicesViewDetailsButton => '查看详情';

  @override
  String get ttsServicesDialogErrorTitle => '错误详情';

  @override
  String get ttsServicesCloseButton => '关闭';

  @override
  String imageViewerPageShareFailedOpenFile(String message) {
    return '无法分享，已尝试打开文件: $message';
  }

  @override
  String imageViewerPageShareFailed(String error) {
    return '分享失败: $error';
  }

  @override
  String get imageViewerPageShareButton => '分享图片';

  @override
  String get imageViewerPageSaveButton => '保存图片';

  @override
  String get imageViewerPageSaveSuccess => '已保存到相册';

  @override
  String imageViewerPageSaveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get settingsShare => 'SYCTB - 开源AI助手';

  @override
  String get searchProviderBingLocalDescription =>
      '使用网络抓取工具获取必应搜索结果。无需 API 密钥，但可能不够稳定。';

  @override
  String get searchProviderDuckDuckGoDescription =>
      '基于 DDGS 的 DuckDuckGo 隐私搜索，无需 API 密钥，支持设置地区。';

  @override
  String get searchProviderBraveDescription => 'Brave 独立搜索引擎。注重隐私，无跟踪或画像。';

  @override
  String get searchProviderExaDescription => '具备语义理解的神经搜索引擎。适合研究与查找特定内容。';

  @override
  String get searchProviderLinkUpDescription =>
      '提供来源可追溯答案的搜索 API，同时提供搜索结果与 AI 摘要。';

  @override
  String get searchProviderMetasoDescription => '秘塔中文搜索引擎。面向中文内容优化并提供 AI 能力。';

  @override
  String get searchProviderSearXNGDescription => '注重隐私的元搜索引擎。需自建实例，无跟踪。';

  @override
  String get searchProviderTavilyDescription =>
      '为大型语言模型（LLMs）优化的 AI 搜索 API，提供高质量、相关的搜索结果。';

  @override
  String get searchProviderZhipuDescription =>
      '智谱 AI 旗下中文 AI 搜索服务，针对中文内容与查询进行了优化。';

  @override
  String get searchProviderOllamaDescription =>
      'Ollama 网络搜索 API。为模型补充最新信息，减少幻觉并提升准确性。';

  @override
  String get searchProviderJinaDescription => '适合开发者和企业用于 AI 搜索应用。支持多语言与多模态。';

  @override
  String get searchServiceNameBingLocal => 'Bing（Local）';

  @override
  String get searchServiceNameDuckDuckGo => 'DuckDuckGo';

  @override
  String get searchServiceNameTavily => 'Tavily';

  @override
  String get searchServiceNameExa => 'Exa';

  @override
  String get searchServiceNameZhipu => '智谱';

  @override
  String get searchServiceNameSearXNG => 'SearXNG';

  @override
  String get searchServiceNameLinkUp => 'LinkUp';

  @override
  String get searchServiceNameBrave => 'Brave';

  @override
  String get searchServiceNameMetaso => '秘塔';

  @override
  String get searchServiceNameOllama => 'Ollama';

  @override
  String get searchServiceNameJina => 'Jina';

  @override
  String get searchServiceNamePerplexity => 'Perplexity';

  @override
  String get searchProviderPerplexityDescription =>
      'Perplexity 搜索 API。提供排序的网页结果，支持区域与域名过滤。';

  @override
  String get searchServiceNameBocha => '博查';

  @override
  String get searchProviderBochaDescription =>
      '博查 AI 全网网页搜索，支持时间范围与摘要，更适合 AI 使用。';

  @override
  String get generationInterrupted => '生成已中断';

  @override
  String get titleForLocale => '新对话';

  @override
  String get quickPhraseBackTooltip => '返回';

  @override
  String get quickPhraseGlobalTitle => '快捷短语';

  @override
  String get quickPhraseAssistantTitle => '助手快捷短语';

  @override
  String get quickPhraseAddTooltip => '添加快捷短语';

  @override
  String get quickPhraseEmptyMessage => '暂无快捷短语';

  @override
  String get quickPhraseAddTitle => '添加快捷短语';

  @override
  String get quickPhraseEditTitle => '编辑快捷短语';

  @override
  String get quickPhraseTitleLabel => '标题';

  @override
  String get quickPhraseContentLabel => '内容';

  @override
  String get quickPhraseCancelButton => '取消';

  @override
  String get quickPhraseSaveButton => '保存';

  @override
  String get instructionInjectionTitle => '指令注入';

  @override
  String get instructionInjectionBackTooltip => '返回';

  @override
  String get instructionInjectionAddTooltip => '添加指令注入';

  @override
  String get instructionInjectionImportTooltip => '从文件导入';

  @override
  String get instructionInjectionEmptyMessage => '暂无指令注入卡片';

  @override
  String get instructionInjectionDefaultTitle => '学习模式';

  @override
  String get instructionInjectionAddTitle => '添加指令注入';

  @override
  String get instructionInjectionEditTitle => '编辑指令注入';

  @override
  String get instructionInjectionNameLabel => '名称';

  @override
  String get instructionInjectionPromptLabel => '提示词';

  @override
  String get instructionInjectionUngroupedGroup => '未分组';

  @override
  String get instructionInjectionGroupLabel => '分组';

  @override
  String get instructionInjectionGroupHint => '可选';

  @override
  String instructionInjectionImportSuccess(int count) {
    return '已导入 $count 个指令注入';
  }

  @override
  String get instructionInjectionSheetSubtitle => '为当前对话选择并应用一条指令提示词';

  @override
  String get mcpJsonEditButtonTooltip => '编辑 JSON';

  @override
  String get mcpJsonEditTitle => '编辑json';

  @override
  String get mcpJsonEditParseFailed => 'JSON 解析失败';

  @override
  String get mcpJsonEditSavedApplied => '已保存并应用';

  @override
  String get mcpTimeoutSettingsTooltip => '设置工具调用超时';

  @override
  String get mcpTimeoutDialogTitle => '工具调用超时';

  @override
  String get mcpTimeoutSecondsLabel => '工具调用超时（秒）';

  @override
  String get mcpTimeoutInvalid => '请输入大于 0 的秒数';

  @override
  String get quickPhraseEditButton => '编辑';

  @override
  String get quickPhraseDeleteButton => '删除';

  @override
  String get quickPhraseMenuTitle => '快捷短语';

  @override
  String get chatInputBarQuickPhraseTooltip => '快捷短语';

  @override
  String get assistantEditQuickPhraseDescription => '管理该助手的快捷短语。点击下方按钮添加短语。';

  @override
  String get assistantEditManageQuickPhraseButton => '管理快捷短语';

  @override
  String get assistantEditPageMemoryTab => '记忆';

  @override
  String get assistantEditMemorySwitchTitle => '记忆';

  @override
  String get assistantEditMemorySwitchDescription => '允许助手主动存储并在对话间引用用户相关信息';

  @override
  String get assistantEditRecentChatsSwitchTitle => '参考历史聊天记录';

  @override
  String get assistantEditRecentChatsSwitchDescription =>
      '在新对话中引用最近的对话标题以增强上下文';

  @override
  String get assistantEditManageMemoryTitle => '管理记忆';

  @override
  String get assistantEditAddMemoryButton => '添加记忆';

  @override
  String get assistantEditMemoryEmpty => '暂无记忆';

  @override
  String get assistantEditMemoryDialogTitle => '记忆';

  @override
  String get assistantEditMemoryDialogHint => '输入记忆内容';

  @override
  String get assistantEditAddQuickPhraseButton => '添加快捷短语';

  @override
  String get multiKeyPageDeleteSnackbarDeletedOne => '已删除 1 个 Key';

  @override
  String get multiKeyPageUndo => '撤回';

  @override
  String get multiKeyPageUndoRestored => '已撤回删除';

  @override
  String get multiKeyPageDeleteErrorsTooltip => '删除错误';

  @override
  String get multiKeyPageDeleteErrorsConfirmTitle => '删除所有错误的 Key？';

  @override
  String get multiKeyPageDeleteErrorsConfirmContent => '这将移除所有状态为错误的 Key。';

  @override
  String multiKeyPageDeletedErrorsSnackbar(int n) {
    return '已删除 $n 个错误 Key';
  }

  @override
  String get providerDetailPageProviderTypeTitle => '供应商类型';

  @override
  String get displaySettingsPageChatItemDisplayTitle => '聊天项显示';

  @override
  String get displaySettingsPageRenderingSettingsTitle => '渲染设置';

  @override
  String get displaySettingsPageBehaviorStartupTitle => '行为与启动';

  @override
  String get displaySettingsPageHapticsSettingsTitle => '触觉反馈';

  @override
  String get assistantSettingsNoPromptPlaceholder => '暂无提示词';

  @override
  String get providersPageMultiSelectTooltip => '多选';

  @override
  String get providersPageDeleteSelectedConfirmContent =>
      '确定要删除选中的供应商吗？该操作不可撤销。';

  @override
  String get providersPageDeleteSelectedSnackbar => '已删除选中的供应商';

  @override
  String providersPageExportSelectedTitle(int count) {
    return '导出 $count 个供应商';
  }

  @override
  String get providersPageExportCopyButton => '复制';

  @override
  String get providersPageExportShareButton => '分享';

  @override
  String get providersPageExportCopiedSnackbar => '已复制导出代码';

  @override
  String get providersPageDeleteAction => '删除';

  @override
  String get providersPageExportAction => '导出';

  @override
  String get assistantEditPresetTitle => '预设对话信息';

  @override
  String get assistantEditPresetAddUser => '添加预设用户信息';

  @override
  String get assistantEditPresetAddAssistant => '添加预设助手信息';

  @override
  String get assistantEditPresetInputHintUser => '输入用户消息…';

  @override
  String get assistantEditPresetInputHintAssistant => '输入助手消息…';

  @override
  String get assistantEditPresetEmpty => '暂无预设消息';

  @override
  String get assistantEditPresetEditDialogTitle => '编辑预设消息';

  @override
  String get assistantEditPresetRoleUser => '用户';

  @override
  String get assistantEditPresetRoleAssistant => '助手';

  @override
  String get desktopTtsPleaseAddProvider => '请先在设置中添加语音服务商';

  @override
  String get settingsPageNetworkProxy => '网络代理';

  @override
  String get networkProxyEnableLabel => '启动代理';

  @override
  String get networkProxySettingsHeader => '代理设置';

  @override
  String get networkProxyType => '代理类型';

  @override
  String get networkProxyTypeHttp => 'HTTP';

  @override
  String get networkProxyTypeHttps => 'HTTPS';

  @override
  String get networkProxyTypeSocks5 => 'SOCKS5';

  @override
  String get networkProxyServerHost => '服务器地址';

  @override
  String get networkProxyPort => '端口';

  @override
  String get networkProxyUsername => '用户名';

  @override
  String get networkProxyPassword => '密码';

  @override
  String get networkProxyBypassLabel => '代理绕过';

  @override
  String get networkProxyBypassHint =>
      '用逗号分隔的主机或 CIDR，例如：localhost,127.0.0.1,192.168.0.0/16,*.local';

  @override
  String get networkProxyOptionalHint => '可选';

  @override
  String get networkProxyTestHeader => '连接测试';

  @override
  String get networkProxyTestUrlHint => '测试地址';

  @override
  String get networkProxyTestButton => '测试';

  @override
  String get networkProxyTesting => '测试中…';

  @override
  String get networkProxyTestSuccess => '连接成功';

  @override
  String networkProxyTestFailed(String error) {
    return '测试失败：$error';
  }

  @override
  String get networkProxyNoUrl => '请输入测试地址';

  @override
  String get networkProxyPriorityNote => '当同时开启全局代理与供应商代理时，将优先使用供应商代理。';

  @override
  String get desktopShowProviderInModelCapsule => '模型胶囊显示供应商';

  @override
  String get messageWebViewOpenInBrowser => '在浏览器中打开';

  @override
  String get messageWebViewConsoleLogs => '控制台日志';

  @override
  String get messageWebViewNoConsoleMessages => '暂无控制台消息';

  @override
  String get messageWebViewRefreshTooltip => '刷新';

  @override
  String get messageWebViewForwardTooltip => '前进';

  @override
  String get chatInputBarOcrTooltip => 'OCR 文字识别';

  @override
  String get providerDetailPageBatchDetectButton => '检测';

  @override
  String get providerDetailPageBatchDetecting => '检测中...';

  @override
  String get providerDetailPageBatchDetectStart => '开始检测';

  @override
  String get providerDetailPageDetectSuccess => '检测成功';

  @override
  String get providerDetailPageDetectFailed => '检测失败';

  @override
  String get providerDetailPageDeleteAllModelsWarning => '此操作不可撤回';

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
  String get logViewerTitle => '请求日志';

  @override
  String get logViewerEmpty => '暂无日志';

  @override
  String get logViewerCurrentLog => '当前日志';

  @override
  String get logViewerExport => '导出';

  @override
  String get logViewerOpenFolder => '打开日志目录';

  @override
  String logViewerRequestsCount(int count) {
    return '$count 条请求';
  }

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
  String get assistantEditManageSummariesTitle => '管理摘要';

  @override
  String get assistantEditSummaryEmpty => '暂无摘要';

  @override
  String get assistantEditSummaryDialogTitle => '编辑摘要';

  @override
  String get assistantEditSummaryDialogHint => '输入摘要内容';

  @override
  String get assistantEditDeleteSummaryTitle => '清除摘要';

  @override
  String get assistantEditDeleteSummaryContent => '确定要清除此摘要吗？';

  @override
  String get homePageProcessingFiles => '正在解析文件……';

  @override
  String get fileUploadDuplicateTitle => '文件已存在';

  @override
  String fileUploadDuplicateContent(String fileName) {
    return '检测到同名文件 $fileName，是否使用已有文件？';
  }

  @override
  String get fileUploadDuplicateUseExisting => '使用已有';

  @override
  String get fileUploadDuplicateUploadNew => '重新上传';

  @override
  String get settingsPageWorldBook => '世界书';

  @override
  String get worldBookTitle => '世界书';

  @override
  String get worldBookAdd => '添加世界书';

  @override
  String get worldBookEmptyMessage => '暂无世界书';

  @override
  String get worldBookUnnamed => '未命名世界书';

  @override
  String get worldBookDisabledTag => '已停用';

  @override
  String get worldBookAlwaysOnTag => '常驻';

  @override
  String get worldBookAddEntry => '添加条目';

  @override
  String get worldBookExport => '分享/导出';

  @override
  String get worldBookConfig => '配置';

  @override
  String get worldBookDeleteTitle => '删除世界书';

  @override
  String worldBookDeleteMessage(String name) {
    return '确定删除「$name」？此操作无法撤销。';
  }

  @override
  String get worldBookCancel => '取消';

  @override
  String get worldBookDelete => '删除';

  @override
  String worldBookExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get worldBookNoEntriesHint => '暂无条目';

  @override
  String get worldBookUnnamedEntry => '未命名条目';

  @override
  String worldBookKeywordsLine(String keywords) {
    return '关键词：$keywords';
  }

  @override
  String get worldBookEditEntry => '编辑条目';

  @override
  String get worldBookDeleteEntry => '删除条目';

  @override
  String get worldBookNameLabel => '名称';

  @override
  String get worldBookDescriptionLabel => '简介';

  @override
  String get worldBookEnabledLabel => '启用';

  @override
  String get worldBookSave => '保存';

  @override
  String get worldBookEntryNameLabel => '条目名称';

  @override
  String get worldBookEntryEnabledLabel => '启用条目';

  @override
  String get worldBookEntryPriorityLabel => '优先级';

  @override
  String get worldBookEntryKeywordsLabel => '关键词';

  @override
  String get worldBookEntryKeywordsHint => '输入关键词后点 + 添加。';

  @override
  String get worldBookEntryKeywordInputHint => '输入关键词';

  @override
  String get worldBookEntryKeywordAddTooltip => '添加关键词';

  @override
  String get worldBookEntryUseRegexLabel => '使用正则';

  @override
  String get worldBookEntryCaseSensitiveLabel => '区分大小写';

  @override
  String get worldBookEntryAlwaysOnLabel => '常驻激活';

  @override
  String get worldBookEntryAlwaysOnHint => '无需匹配也会注入';

  @override
  String get worldBookEntryScanDepthLabel => '扫描深度';

  @override
  String get worldBookEntryContentLabel => '内容';

  @override
  String get worldBookEntryInjectionPositionLabel => '注入位置';

  @override
  String get worldBookEntryInjectionRoleLabel => '注入角色';

  @override
  String get worldBookEntryInjectDepthLabel => '注入深度';

  @override
  String get worldBookInjectionPositionBeforeSystemPrompt => '系统提示前';

  @override
  String get worldBookInjectionPositionAfterSystemPrompt => '系统提示后';

  @override
  String get worldBookInjectionPositionTopOfChat => '对话顶部';

  @override
  String get worldBookInjectionPositionBottomOfChat => '对话底部';

  @override
  String get worldBookInjectionPositionAtDepth => '指定深度';

  @override
  String get worldBookInjectionRoleUser => '用户';

  @override
  String get worldBookInjectionRoleAssistant => '助手';

  @override
  String get mcpToolNeedsApproval => '需要审批';

  @override
  String get toolApprovalPending => '等待审批';

  @override
  String get toolApprovalApprove => '批准';

  @override
  String get toolApprovalDeny => '拒绝';

  @override
  String get toolApprovalDenyTitle => '拒绝工具调用';

  @override
  String get toolApprovalDenyHint => '原因（可选）';

  @override
  String toolApprovalDeniedMessage(Object reason, Object toolName) {
    return '工具调用 \"$toolName\" 已被用户拒绝。原因：$reason';
  }

  @override
  String tokenDetailPromptTokens(int count) {
    return '$count tokens';
  }

  @override
  String tokenDetailPromptTokensWithCache(int count, int cached) {
    return '$count tokens ($cached cached)';
  }

  @override
  String tokenDetailCompletionTokens(int count) {
    return '$count tokens';
  }

  @override
  String tokenDetailSpeed(String value) {
    return '$value tok/s';
  }

  @override
  String tokenDetailDuration(String value) {
    return '${value}s';
  }

  @override
  String tokenDetailTotalTokens(int count) {
    return '$count tokens';
  }

  @override
  String get aboutPageStudyLearning => '学习路径';

  @override
  String get sideDrawerAssistantsTab => '侧边栏触觉反馈';

  @override
  String get sideDrawerTopicsTab => '切换';

  @override
  String get sideDrawerUserName => '用户名字';

  @override
  String get sideDrawerDefaultUser => '默认名字';

  @override
  String get searchPlaceholder => '搜索占位';

  @override
  String get sideDrawerToday => '今日';

  @override
  String get sideDrawerYesterday => '昨日';

  @override
  String sideDrawerDaysAgo(Object number) {
    return '几天前';
  }

  @override
  String get simplen8nAbout => '关于';

  @override
  String get simplen8nNewWorkflow => '新建工作流';

  @override
  String get simplen8nTagline => '可视化工作流自动化引擎';

  @override
  String get simplen8nCreateFirst => '创建你的第一个工作流';

  @override
  String get simplen8nDuplicate => '复制';

  @override
  String get simplen8nDelete => '删除';

  @override
  String get simplen8nLastRunOk => '上次运行成功';

  @override
  String get simplen8nLastRunFailed => '上次运行失败';

  @override
  String get simplen8nDismiss => '关闭';

  @override
  String get simplen8nRun => '运行';

  @override
  String get simplen8nArrange => '整理';

  @override
  String get simplen8nSave => '保存';

  @override
  String get simplen8nLoad => '加载';

  @override
  String get simplen8nImport => '导入';

  @override
  String get simplen8nExport => '导出';

  @override
  String get simplen8nStop => '停止';

  @override
  String get simplen8nActivate => '激活';

  @override
  String get simplen8nHistory => '历史';

  @override
  String get simplen8nLogs => '日志';

  @override
  String get simplen8nRunning => '运行中…';

  @override
  String get simplen8nBuildWorkflow => '构建你的工作流';

  @override
  String get simplen8nDragNodesHint => '从左侧面板拖入节点，或点击面板中的节点添加';

  @override
  String get simplen8nExecuteFromHere => '从此处执行';

  @override
  String get simplen8nCopy => '复制';

  @override
  String get simplen8nCut => '剪切';

  @override
  String get simplen8nExecutionLogs => '执行日志';

  @override
  String get simplen8nWorkflowImported => '工作流导入成功';

  @override
  String simplen8nImportFailed(String error) {
    return '导入失败: $error';
  }

  @override
  String simplen8nExportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String get simplen8nExportWorkflow => '导出工作流';

  @override
  String simplen8nExportedTo(String path) {
    return '已导出至 $path';
  }

  @override
  String get simplen8nLoadWorkflow => '加载工作流';

  @override
  String get simplen8nNoSavedWorkflows => '没有已保存的工作流';

  @override
  String get simplen8nClose => '关闭';

  @override
  String get simplen8nNodesLabel => '节点';

  @override
  String get simplen8nNoNodesFound => '未找到节点';

  @override
  String get simplen8nSearchNodes => '搜索节点…';

  @override
  String get simplen8nSelectNode => '选择一个节点';

  @override
  String get simplen8nSelectNodeHint => '点击画布上的任意节点，即可配置其参数';

  @override
  String get simplen8nNodeName => '节点名称';

  @override
  String get simplen8nEnterNodeName => '输入节点名称…';

  @override
  String get simplen8nNotes => '备注';

  @override
  String get simplen8nAddNotes => '添加备注…';

  @override
  String get simplen8nParameters => '参数';

  @override
  String get simplen8nNoParameters => '无可用参数';

  @override
  String get simplen8nExpression => 'expr';

  @override
  String get simplen8nEnterValue => '输入值…';

  @override
  String get simplen8nEnabled => '已启用';

  @override
  String get simplen8nDisabled => '已禁用';

  @override
  String get simplen8nWorkflowHistory => '工作流历史';

  @override
  String get simplen8nAllExecutionHistory => '所有执行历史';

  @override
  String get simplen8nNoHistory => '暂无执行历史';

  @override
  String get simplen8nUntitled => '未命名';

  @override
  String get simplen8nExecutionDetail => '执行详情';

  @override
  String get simplen8nSuccess => '成功';

  @override
  String get simplen8nFailed => '失败';

  @override
  String simplen8nNodesCount(int count) {
    return '节点 ($count)';
  }

  @override
  String get simplen8nDuration => '耗时';

  @override
  String get simplen8nStarted => '开始时间';

  @override
  String get simplen8nId => 'ID';
}
