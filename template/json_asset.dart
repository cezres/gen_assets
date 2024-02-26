import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

final class JsonAsset extends UnknownAsset {
  const JsonAsset(super.path, this.backgroud);

  final bool backgroud;

  Future<Map<String, dynamic>> json({bool cache = false}) async {
    return AssetsCache.instance.putIfAbsent('$path-json', cache, () async {
      final data = await load();
      final Map<String, dynamic> result;
      if (backgroud) {
        result = await compute(
          (message) {
            return _parseToJson(message.materialize().asUint8List());
          },
          TransferableTypedData.fromList([data]),
        );
      } else {
        result = _parseToJson(data.buffer.asUint8List());
      }
      return (result, data.lengthInBytes);
    });
  }

  Future<T> parse<T>(
      FutureOr<T> Function(Map<String, dynamic> value) parser) async {
    final data = await load();
    if (backgroud) {
      return compute(
        (message) {
          final bytes = message.materialize().asUint8List();
          return parser(_parseToJson(bytes));
        },
        TransferableTypedData.fromList([data]),
      );
    } else {
      return parser(_parseToJson(data.buffer.asUint8List()));
    }
  }

  static Map<String, dynamic> _parseToJson(Uint8List bytes) {
    final string = utf8.decode(bytes);
    return jsonDecode(string);
  }
}
