import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState()=>_DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage>{
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Text(
          l10n.newConversation,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
