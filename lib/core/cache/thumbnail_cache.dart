import 'dart:typed_data';

import 'package:photos/core/cache/lru_map.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/models/ente_file.dart';

class ThumbnailLruCache {
  static final LRUMap<String, Uint8List> _map = LRUMap(1000);

  static Uint8List get(EnteFile enteFile, [int size]) {
    return _map.get(
      enteFile.cacheKey() +
          "_" +
          (size != null ? size.toString() : kThumbnailLargeSize.toString()),
    );
  }

  static void put(
    EnteFile enteFile,
    Uint8List imageData, [
    int size,
  ]) {
    _map.put(
      enteFile.cacheKey() +
          "_" +
          (size != null ? size.toString() : kThumbnailLargeSize.toString()),
      imageData,
    );
  }

  static void clearCache(EnteFile enteFile) {
    _map.remove(
      enteFile.cacheKey() + "_" + kThumbnailLargeSize.toString(),
    );
    _map.remove(
      enteFile.cacheKey() + "_" + kThumbnailSmallSize.toString(),
    );
  }
}
