import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';

class Monitoring {
  static void init() {
    FlutterError.onError = (details) {
      AppLogger().error(
        'Flutter framework error',
        details.exception,
        details.stack,
      );
      FlutterError.presentError(details);
    };
  }

  static Interceptor get dioInterceptor => _LoggingInterceptor();

  static ProviderObserver get providerObserver => _LoggingProviderObserver();
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger().info('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger().info(
      '← ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger().error(
      '✕ ${err.message}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }
}

class _LoggingProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (previousValue != newValue) {
      AppLogger().debug(
        '[Provider] ${provider.name ?? provider.runtimeType} changed',
      );
    }
  }

}
