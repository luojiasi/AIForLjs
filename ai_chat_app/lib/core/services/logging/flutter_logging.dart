

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ai_chat_app/utils/app_directories.dart';
import 'package:flutter/foundation.dart';

class FlutterLogger{
  // 私有构造，禁止实例化，全是静态方法
  FlutterLogger._();
  static const String _activeFileName = 'Flutter_logs.txt';//当前日志文件名
  static const String _rotatedFilePrefix = 'Flutter_logs_';//轮转文件前缀

  static bool _enabled = false;
  static bool get enabled => _enabled;
  static bool _writeErrorReported = false; //写入失败标记，首次失败报错后设为 true，防止刷屏
  static IOSink? _sink;//文件写入器，指向当前打开的日志文件 
  static DateTime? _sinkData;// 记录 _sink 打开时的日期，用于判断是否需要轮转
  static Future<void> _writeQueue = Future<void>.value();//串行写入队列  
  /// 开关日志
  static Future<void> setEnabled(bool v) async{
    if(_enabled == v) return;
    _enabled = v;
    if (!v) {
      try {
        await _sink?.flush();
      } catch (_) {}
      try {
        await _sink?.close();
      } catch (_) {}
      _sink =null;
      _sinkData =null;
    } else {
      _writeErrorReported = false;
    }
  }

  static bool _installed = false;//全局错误处理器是否已安装，防止重复安装
  static FlutterExceptionHandler? _originalFlutterOnError;//保存原始的 Flutter 错误处理器，用于链式调用 
  static bool Function(Object,StackTrace)? _originalPlatformOnError;//保存原始的 PlatformDispatcher 错误处理器
  ///安装两个全局错误拦截器
  static void installGlobalHandlers(){
    if(_installed) return;
    _installed = true;


    // 先记日志，再继续传递
    
    // 第一个是Flutter的错误拦截
    _originalFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details){
      try {
        log(details.toString().trimRight(),tag:'FlutterError');
      } catch (_) {}
      final original = _originalFlutterOnError;
      if (original!=null) {
        original(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // 第二个是Dart的错误拦截
    _originalPlatformOnError = ui.PlatformDispatcher.instance.onError;
    ui.PlatformDispatcher.instance.onError = (Object error,StackTrace stack){
      try{
        log('$error\n$stack',tag:'Uncaught');
      }catch(_){}
      final original = _originalPlatformOnError;
      if(original!=null)return original(error,stack);
      return false;
    };
  }


  ///格式化日期
  static DateTime _dayOf(DateTime dt) => DateTime(dt.year,dt.month,dt.day);
  static String _two(int v) => v.toString().padLeft(2,'0');
  static String _formatDate(DateTime dt) => '${dt.year}-${_two(dt.month)}-${_two(dt.day)}';
  static String _formatTs(DateTime dt){return '${_formatDate(dt)} ${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}.${dt.millisecond.toString().padLeft(3,'0')}';}
  /// 确保 _sink 指向今天的日志文件
  static Future<IOSink> _ensureSink() async{
    final now = DateTime.now();
    final today = _dayOf(now);
    if (_sink !=null && _sinkData==today) return _sink!;
    try{
      await _sink?.flush();
    }catch(_){}
    try{
      await _sink?.close();
    }catch(_){}
    _sink=null;
    _sinkData =today; 
    final dir  = await AppDirectories.getAppDataDirectory();
    final logsDir = Directory('${dir.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    final active = File('${logsDir.path}/$_activeFileName');
    if(await active.exists()){
      try{
        final stat = await active.stat();
        final fileDay = _dayOf(stat.modified.toLocal());
        if (fileDay!=today){
          final suffix = _formatDate(fileDay);
          var rotated =File('${logsDir.path}/$_rotatedFilePrefix$suffix.txt');
          if (await rotated.exists()){
            int i =1;
            while(await File('${logsDir.path}/$_rotatedFilePrefix${suffix}_$i.txt').exists()){
              i++;
            }
            rotated = File('${logsDir.path}/$_rotatedFilePrefix${suffix}_$i.txt',);
          }
          await active.rename(rotated.path);
        }
      }catch(_){}
    }
    _sink = active.openWrite(mode: FileMode.append);
    return _sink!;
  }

  /// 核心写日志方法
  static void log(String message,{String? tag}){
    if (!_enabled) return;
    final now = DateTime.now();
    final prefix = '[${_formatTs(now)}]${tag==null?'':'[$tag]'}';
    final normalized = message.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final buffer = StringBuffer();
    for(final line in lines){
      buffer.writeln('$prefix$line');
    }
    final text = buffer.toString();
    // 排队写入
    _writeQueue = _writeQueue.then((_) async{
      if (!_enabled) return ;
      try{
        final sink = await _ensureSink();
        sink.write(text);
        await sink.flush();
      }catch(_){
        try{
          await _sink?.flush();
        }catch(_){}
        try{
          await _sink?.close();
        }catch(_){}
        _sink=null;
        _sinkData=null;
        if(!_writeErrorReported){
          _writeErrorReported=true;
          try{
            stderr.writeln('[FlutterLogger] write failed; further write errors will be suppressed.',);
          }catch(_){}
        }
      }
    });
  }
  static void logPrint(String line) {log(line, tag: 'print');}
}