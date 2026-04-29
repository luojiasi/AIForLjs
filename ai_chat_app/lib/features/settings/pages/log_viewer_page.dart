import 'dart:io';

import 'package:flutter/material.dart';

class LogViewerPage extends StatefulWidget{
  const LogViewerPage({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage>{
  static const String _activeRequestLog = 'logs.txt';
  static const String _activeAppLog = 'flutter_logs.txt';
  bool _loading = true;
  List<File> _requestLogFiles = <File>[];
  List<File> _appLogFiles = <File>[];

  @override
  void initState(){
    super.initState();
  }

  // String _formatFileSize(int bytes){

  // }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}


