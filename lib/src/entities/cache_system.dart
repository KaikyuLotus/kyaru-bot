import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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
  final String uuid;

  CacheEntry({
    required this.insertTime,
    this.isException = false,
    String? previousUuid,
  }) : uuid = previousUuid ?? Uuid().v4();

  static CacheEntry fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      insertTime: DateTime.fromMillisecondsSinceEpoch(json['insert_time']),
      previousUuid: json['uuid'],
      isException: json['is_exception'],
    );
  }

  Map toJson() {
    return {
      'insert_time': insertTime.millisecondsSinceEpoch,
      'is_exception': isException,
      'uuid': uuid,
    };
  }
}

class CacheSystem {
  static const cacheDir = 'caches';

  final String systemKey;

  final Duration timeout;

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
    return File(join(cacheDir, systemKey, key));
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
    String? previousUuid;
    bool cacheChanged = false;
    try {
      Map<String, dynamic>? previous;
      if (_cache.containsKey(key)) {
        if (_cache[key]!.insertTime.add(timeout).isBefore(DateTime.now())) {
          final cacheEntry = _cache.remove(key);
          cacheChanged = true;
          previousUuid = cacheEntry!.uuid;
          if (!cacheEntry.isException) {
            previous = await readCacheFile(key);
          }
        } else {
          var entry = _cache[key]!;
          final content = await readCacheFile(entry.uuid);
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
      _cache[key] = CacheEntry(
        insertTime: DateTime.now(),
        previousUuid: previousUuid,
      );
      cacheChanged = true;
      await writeCacheFile(_cache[key]!.uuid, output);
      return CachedResult(current: output, previous: previous);
    } catch (e) {
      _cache[key] = CacheEntry(
        insertTime: DateTime.now(),
        isException: true,
        previousUuid: previousUuid,
      );
      rethrow;
    } finally {
      if (cacheChanged) {
        _updateCacheFile();
      }
    }
  }
}
