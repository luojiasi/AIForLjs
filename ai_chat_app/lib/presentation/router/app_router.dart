import 'package:go_router/go_router.dart';
import 'package:ai_chat_app/presentation/screens/home_screen.dart';
import 'package:ai_chat_app/presentation/screens/chat_screen.dart';
import 'package:ai_chat_app/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) => ChatScreen(
            conversationId: state.pathParameters['conversationId'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
