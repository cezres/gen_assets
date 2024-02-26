import 'dart:convert';

import 'package:flutter/services.dart';

class UnknownAsset {
  const UnknownAsset(this.path);

  final String path;

  Future<ByteData> load({bool cache = false}) =>
      AssetsCache.instance.putIfAbsent('$path-load', cache, () async {
        final data = await rootBundle.load(path);
        return (data, data.lengthInBytes);
      });

  Future<String> loadString({bool cache = false}) =>
      AssetsCache.instance.putIfAbsent('$path-loadString', cache, () async {
        final data = await load();
        return (utf8.decode(Uint8List.sublistView(data)), data.lengthInBytes);
      });
}
