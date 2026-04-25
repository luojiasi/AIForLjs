import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/presentation/widgets/sidebar/sidebar_drawer.dart';

class HomeScreen extends ConsumerWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(width: 280, child: SidebarDrawer()),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const SidebarDrawer(),
      body: child,
    );
  }
}
