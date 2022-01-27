import 'package:kyaru_bot/src/entities/cache_system.dart';

class APIResponse<T> {
  final int retcode;
  final String message;
  final T? data;

  APIResponse({
    required this.retcode,
    required this.message,
    required this.data,
  });

  static APIResponse<T> _fromJson<T>(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) converter,
  }) {
    return APIResponse(
      retcode: json['retcode'],
      message: json['message'],
      data: json['retcode'] == 0 ? converter(json['data']) : null,
    );
  }

  Map toJson() {
    return {
      'retcode': retcode,
      'message': message,
      'data': data,
    };
  }
}

class CachedAPIResponse<T> {
  final APIResponse<T> current;
  final APIResponse<T>? previous;

  CachedAPIResponse({required this.current, required this.previous});

  static CachedAPIResponse<T> fromCachedResult<T>(
    CachedResult cachedResult,
    T Function(Map<String, dynamic>) converter,
  ) {
    return CachedAPIResponse(
      current: APIResponse._fromJson(
        cachedResult.current,
        converter: converter,
      ),
      previous: cachedResult.previous != null
          ? APIResponse._fromJson(
              cachedResult.previous!,
              converter: converter,
            )
          : null,
    );
  }

  Map toJson() {
    return {
      'current': current,
      'previous': previous,
    };
  }
}
