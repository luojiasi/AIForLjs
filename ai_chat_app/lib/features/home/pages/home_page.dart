import 'package:ai_chat_app/core/providers/settings_provider.dart';
import 'package:ai_chat_app/features/home/pages/home_mobile_layout.dart';
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:ai_chat_app/shared/responsive/breakpoints.dart';
import 'package:ai_chat_app/shared/widgets/interactive_drawer.dart';
// import 'package:ai_chat_app/shared/widgets/interactive_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState()=>_HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  
  // //  控制 Scaffold（打开抽屉、SnackBar 等）
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // //  控制侧边抽屉的打开/关闭动画值
  final InteractiveDrawerController _drawerController =InteractiveDrawerController();
  // // 每次自增时通知关闭助手选择器（用于侧栏关闭时自动收起
  final ValueNotifier<int> _assistantPickerCloseTick = ValueNotifier<int>(0);
  // //  管理输入框焦点
  final FocusNode _inputFocus = FocusNode();
  // // 控制输入框文本内容和光标位置
  final TextEditingController _inputController = TextEditingController();
  // // 管理输入栏中的媒体附件（图片/文件预览等）
  // // final ChatInputBarController _mediaController = ChatInputBarController();
  // // 自定义滚动控制器，支持自动跟随（流式输出时自动滚到底
  final ScrollController _scrollController = ScrollController();
  // final scroll_ctrl.ChatAutoFollowScrollController _scrollController =scroll_ctrl.ChatAutoFollowScrollController();
  // // 用于 BackdropGroup 组件，标记消息列表的背景层
  final BackdropKey _messageListBackdropKey = BackdropKey();
  // // 输入栏的 GlobalKey，用于获取其 RenderBox 计算位置/尺寸
  final GlobalKey _inputBarKey = GlobalKey();
  // // │ 选择模式下迷你地图弹出框的锚点 Key
  final GlobalKey _selectionMiniMapKey = GlobalKey();
  // // Android 进程文本流订阅（接收其他 App 分享的文本）
  final GlobalKey _selectionExportBarKey = GlobalKey();


  // ============================================================================
  // Page Controller (manages all business logic and state)
  // 核心控制器，管理所有聊天状态、消息列表、会话切换、流式输出、选择模式等业务逻
  // late HomePageController _controller;
  // ============================================================================
  
  // ============================================================================
  // Lifecycle
  // ============================================================================

  //   初始化流程：
  // 1. 注册 WidgetsBindingObserver 监听应用前后台
  // 2. 创建 HomePageController，注入所有 UI 控制器（ScaffoldKey、FocusNode、TextEditingController 等）
  // 3. 注册 controller 和 drawer 的监听器
  // 4. 调用 _controller.initChat() 初始化聊天
  // 5. 调用 _initProcessText() 设置 Android 进程文本
  // 6. 在下一帧执行：测量输入栏高度 + 初始化 WorldBookProvider
  // @override
  // void initState() {
  //   super.initState();
  //   try {
  //     // WidgetsBinding.instance.addObserver(this);
  //   } catch (_) {}

  // }


  // 有新页面 push 到当前页面之上时调用，委托给 controller（如暂停音频播放）
  // @override
  // void didPushNext() {
  //   _controller.onDidPushNext();
  // }
  // 上层页面被 pop 后恢复时调用，委托给 controller（如恢复音频播放）
  // @override
  // void didPopNext() {
  //   _controller.onDidPopNext();
  // }

  // 依次释放所有资源：移除 Observer → 取消订阅 → 移除监听器 → disposeFocusNode/TextEditingController/ScrollController/Controller → 取消路由订阅。
  // @override
  // void dispose() {
  //   try {
  //     WidgetsBinding.instance.removeObserver(this);
  //   } catch (_) {}
  //   _processTextSub?.cancel();
  //   _controller.removeListener(_onControllerChanged);
  //   _drawerController.removeListener(_onDrawerValueChanged);
  //   _inputFocus.dispose();
  //   _inputController.dispose();
  //   _scrollController.dispose();
  //   _controller.dispose();
  //   routeObserver.unsubscribe(this);
  //   super.dispose();
  // }
  // Controller 状态变化时调用 setState 触发重建。所有 UI 更新的入口
  // void _onControllerChanged() {
  //   if (mounted) setState(() {});
  // }

  // 抽屉动画值变化回调：
  // - 通知 controller 抽屉值变化（用于计算侧栏宽度等）
  // - 当抽屉值 < 0.95 时（接近关闭），根据设置决定是否关闭助手选择器

  // void _onDrawerValueChanged() {
  //   _controller.onDrawerValueChanged(_drawerController.value);
  //   // Close assistant picker when drawer closes
  //   if (_drawerController.value < 0.95) {
  //     final sp = context.read<SettingsProvider>();
  //     if (!sp.keepAssistantListExpandedOnSidebarClose) {
  //       _assistantPickerCloseTick.value++;
  //     }
  //   }
  // }
  //  Android 专属：初始化 AndroidProcessText，监听其他 App 分享文本到本应用的流，并获取初始文本（冷启动时传入的文本）
  // void _initProcessText() {
  //   if (!PlatformUtils.isAndroid) return;
  //   AndroidProcessText.ensureInitialized();
  //   _processTextSub = AndroidProcessText.stream.listen(_handleProcessText);
  //   AndroidProcessText.getInitialText().then((text) {
  //     if (text != null) {
  //       _handleProcessText(text);
  //     }
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cs = Theme.of(context).colorScheme;
    final title ='asist';
    if(width >= AppBreakpoints.tablet){
      return _buildTabletLayout();
    }
    return _buildMobileLayout(
      context,
      title: title,
      cs: cs,
    );

  }
  //  移动端布局入口
  Widget _buildMobileLayout(
    BuildContext context,{
      required ColorScheme cs,
      required String title,
    }) {
    return HomeMobileScaffold(
      scaffoldKey: _scaffoldKey,
      drawerController: _drawerController,
      title: title,
      onToggleDrawer: () => _drawerController.toggle(),
      body: _buildBody(),
    );
  }


  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 10,
      itemBuilder: (_, i) => ListTile(title: Text('Message $i')),
    );
  }
  // 移动端主体内容
  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top:kToolbarHeight+MediaQuery.paddingOf(context).top,
            ),
            child: Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
          ),
      ],
    );
  }
  

  
  // 平板/桌面布局入口
  Widget _buildTabletLayout() {
      return Scaffold(
      body: Row(
        children: [
          // 左侧嵌入侧栏
          SizedBox(
            width: 280,
          ),
          // 分隔线
          const VerticalDivider(width: 1),
          // 主内容区 — 复用移动端的 body
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
  // // 平板端主体内容
    Widget _buildTabletBody() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top:kToolbarHeight+MediaQuery.paddingOf(context).top,
            ),
            child: Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
          ),
      ],
    );
  }
  // // 与 _buildMobileBody 的区别：

  // // 移动端：                              平板端：
  // // Column                               Column(crossAxisAlignment: stretch)
  // // ├── Expanded                          ├── Expanded
  // // │   └── KeyedSubtree                  │   └── KeyedSubtree
  // // │       └── MessageListView           │       └── MessageListView
  // // │       + [条件] fadeIn               │       + [始终] fadeIn 200ms
  // // │       + [条件] FadeTransition       │       + [始终] FadeTransition
  // // ├── ExportBar (全宽)                  ├── ExportBar → Center → ConstrainedBox(最大860)
  // // └── InputBar (全宽)                   └── InputBar → Center → ConstrainedBox(最大860)

  // // ============================================================================
  // // UI Component Builders
  // // ============================================================================
  // // 选择模式迷你地图
  // Widget _buildChatBackground(BuildContext context, ColorScheme cs){

  // }
  // // 聊天背景图
  // Widget _buildAssistantBackground(BuildContext context){

  // }
  // // 消息列表
  // Widget _buildMessageListView(BuildContext context, {required EdgeInsetsGeometry dividerPadding,}){

  // }
  
  // //  输入栏
  // Widget _buildChatInputBar(BuildContext context, {required bool isTablet}){

  // }
  Widget _buildInputBar(){
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child:TextField(
              controller: _inputController,
              focusNode: _inputFocus,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
  // // 助手侧栏背景
  // Widget _buildAssistantBackground(BuildContext context){

  // }
  // // 滚动导航按钮
  // Widget _buildScrollButtons(){

  // }
  // // 桌面拖拽上传  仅桌面端生效（!_controller.isDesktopPlatform 直接返回 child）
  // Widget _wrapWithDropTarget(Widget child){

  // }

  // int _computeTruncCollapsedIndex(){

  // }

  // ============================================================================
  // 交互处理方法
  // ============================================================================


}
