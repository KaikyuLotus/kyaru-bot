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
  final bool isException;

  CacheEntry({
    required this.insertTime,
    this.isException = false,
  });

  static CacheEntry fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      insertTime: DateTime.fromMillisecondsSinceEpoch(json['insert_time']),
      isException: json['is_exception'],
    );
  }

  Map toJson() {
    return {
      'insert_time': insertTime.millisecondsSinceEpoch,
      'is_exception': isException,
    };
  }
}

class CacheSystem {
  static const cacheDir = 'caches';

  final String systemKey;

  final Duration timeout;

  final b64Codec = utf8.fuse(base64);

  late final Map<String, CacheEntry> _cache;

  File get _coreFile => File(join(cacheDir, systemKey, '.kyarc'));

  CacheSystem({
    required this.systemKey,
    this.timeout = const Duration(hours: 1),
  }) {
    _cache = _loadFileCache();
  }

  Map<String, CacheEntry> _loadFileCache() {
    Directory(join(cacheDir, systemKey)).createSync(recursive: true);
    if (!_coreFile.existsSync()) {
      _coreFile.writeAsStringSync('{}');
    }
    return Map<String, CacheEntry>.from(
      json
          .decode(_coreFile.readAsStringSync())
          .map((key, value) => MapEntry(key, CacheEntry.fromJson(value))),
    );
  }

  Future _updateCacheFile() async {
    _coreFile.writeAsStringSync(json.encode(_cache));
  }

  File keyToFile(String key) {
    return File(join(cacheDir, systemKey, b64Codec.encode(key)));
  }

  Future<Map<String, dynamic>?> readCacheFile(String key) async {
    final file = keyToFile(key);
    if (await file.exists()) {
      return json.decode(await file.readAsString());
    }
    return null;
  }

  // content must support .toJson
  Future<File> writeCacheFile(String key, dynamic content) {
    final file = keyToFile(key);
    return file.writeAsString(json.encode(content));
  }

  Future<CachedResult> cacheOutput<T>({
    required String key,
    required Future<Map<String, dynamic>> Function() function,
  }) async {
    try {
      Map<String, dynamic>? previous;
      if (_cache.containsKey(key)) {
        if (_cache[key]!.insertTime.add(timeout).isBefore(DateTime.now())) {
          _cache.remove(key);
          if (!_cache[key]!.isException) {
            previous = await readCacheFile(key);
          }
        } else {
          var entry = _cache[key]!;
          final content = await readCacheFile(key);
          if (content != null) {
            if (entry.isException) {
              throw Exception(json.encode(content));
            }
            return CachedResult(
              current: content,
              previous: null,
            );
          }
          // File has been deleted probably manually, re-call the function
        }
      }
      final output = await function();
      await writeCacheFile(key, output);
      _cache[key] = CacheEntry(insertTime: DateTime.now());
      return CachedResult(current: output, previous: previous);
    } catch (e) {
      _cache[key] = CacheEntry(
        insertTime: DateTime.now(),
        isException: true,
      );
      rethrow;
    } finally {
      _updateCacheFile();
    }
  }
}
