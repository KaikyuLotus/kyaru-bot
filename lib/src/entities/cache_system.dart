import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

class CachedResult {
  final Map<String, dynamic> current;
  final Map<String, dynamic>? previous;

  CachedResult({required this.current, required this.previous});

  Map toJson() {
    return {
      'current': current,
      'previous': previous,
    };
  }
}

class CacheEntry {
  final DateTime insertTime;
  final dynamic value;
  final bool isException;

  CacheEntry({
    required this.insertTime,
    required this.value,
    this.isException = false,
  });

  static CacheEntry fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      insertTime: DateTime.fromMillisecondsSinceEpoch(json['insert_time']),
      value: json['value'],
      isException: json['is_exception'],
    );
  }

  Map toJson() {
    return {
      'insert_time': insertTime.millisecondsSinceEpoch,
      'value': value,
      'is_exception': isException,
    };
  }
}

class CacheSystem {
  static const cacheDir = 'caches';

  final String systemKey;

  final Duration timeout;

  late final Map<String, CacheEntry> _cache;

  File get _file => File(join(cacheDir, '$systemKey.kyarc'));

  CacheSystem({
    required this.systemKey,
    this.timeout = const Duration(hours: 1),
  }) {
    _cache = _loadFileCache();
  }

  Map<String, CacheEntry> _loadFileCache() {
    Directory(cacheDir).createSync(recursive: true);
    if (!_file.existsSync()) {
      _file.writeAsStringSync('{}');
    }
    return Map<String, CacheEntry>.from(
      json
          .decode(_file.readAsStringSync())
          .map((key, value) => MapEntry(key, CacheEntry.fromJson(value))),
    );
  }

  Future _updateCacheFile() async {
    _file.writeAsStringSync(json.encode(_cache));
  }

  Future<CachedResult> cacheOutput<T>({
    required String key,
    required Future<Map<String, dynamic>> Function() function,
  }) async {
    try {
      Map<String, dynamic>? previous;
      if (_cache.containsKey(key)) {
        if (_cache[key]!.insertTime.add(timeout).isBefore(DateTime.now())) {
          if (!_cache[key]!.isException) {
            previous = _cache.remove(key)!.value;
          }
        } else {
          var entry = _cache[key]!;
          if (entry.isException) {
            throw entry.value;
          }
          return CachedResult(current: entry.value, previous: null);
        }
      }
      final output = await function();
      _cache[key] = CacheEntry(
        insertTime: DateTime.now(),
        value: output,
      );
      return CachedResult(current: output, previous: previous);
    } catch (e) {
      _cache[key] = CacheEntry(
        insertTime: DateTime.now(),
        value: <String, dynamic>{'Exception': '$e'},
        isException: true,
      );
      rethrow;
    } finally {
      _updateCacheFile();
    }
  }
}
