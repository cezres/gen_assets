import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import 'asset_file.dart';

AssetType assetTypeFromFilePath(String path) {
  final ext = extension(path);
  switch (ext) {
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.webp':
    case '.gif':
      return AssetType.image;
    case '.ttf':
      return AssetType.font;
    case '.json':
      final data = jsonDecode(File(path).readAsStringSync());
      if (data is Map<String, dynamic>) {
        if (data['v'] != null && data['nm'] != null && data['layers'] != null) {
          return AssetType.lottie;
        }
      }
      return AssetType.json;
    default:
      return AssetType.unknown;
  }
}

enum AssetType {
  image,
  font,
  lottie,
  json,
  unknown;

  String get className {
    switch (this) {
      case AssetType.image:
        return 'ImageAsset';
      case AssetType.font:
        return 'FontAsset';
      case AssetType.lottie:
        return 'LottieAsset';
      case AssetType.json:
        return 'JsonAsset';
      case AssetType.unknown:
        return 'UnknownAsset';
    }
  }

  List<String> generatorImport() {
    switch (this) {
      case AssetType.image:
        return ['package:flutter/widgets.dart'];
      case AssetType.lottie:
        return ['package:lottie/lottie.dart'];
      case AssetType.font:
        return [];
      case AssetType.json:
        return ['dart:convert', 'dart:isolate'];
      case AssetType.unknown:
        return ['package:flutter/services.dart'];
    }
  }

  String generatorComment(AssetFile file) {
    switch (this) {
      case AssetType.image:
        return '/// ![](${file.path})';
      case AssetType.unknown:
      case AssetType.font:
      case AssetType.lottie:
      case AssetType.json:
        return '';
    }
  }

  String generatorConstruct(AssetFile file) {
    switch (this) {
      case AssetType.image:
      case AssetType.unknown:
      case AssetType.lottie:
        return 'const $className(\'${file.relativePath}\')';
      case AssetType.font:
        final basename = basenameWithoutExtension(file.relativePath);
        return 'const $className(\'$basename\')';
      case AssetType.json:
        return 'const $className(\'${file.relativePath}\', true)';
    }
  }

  String get generatorClass {
    switch (this) {
      case AssetType.image:
        return '''
         final class ImageAsset { 
          const ImageAsset(this.path);

          final String path;

          Widget image({
            double? width,
            double? height,
            BoxFit? fit,
            Color? color,
          }) {
            return Image.asset(
              path,
              width: width,
              height: height,
              fit: fit,
              color: color,
            );
          }
        }
        ''';
      case AssetType.font:
        return '''
        final class FontAsset {
          const FontAsset(this.name);

          final String name;
        }
        ''';
      case AssetType.lottie:
        return '''
        final class LottieAsset {
          const LottieAsset(this.path);

          final String path;

          LottieProvider get provider => AssetLottie(path);

          Widget lottie({
            Key? key,
            Animation<double>? controller,
            FrameRate? frameRate,
            bool? animate,
            bool? reverse,
            bool? repeat,
            LottieDelegates? delegates,
            LottieOptions? options,
            void Function(LottieComposition)? onLoaded,
            Widget Function(BuildContext, Widget, LottieComposition?)? frameBuilder,
            Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
            double? width,
            double? height,
            BoxFit? fit,
            AlignmentGeometry? alignment,
            bool? addRepaintBoundary,
            FilterQuality? filterQuality,
            void Function(String)? onWarning,
            RenderCache? renderCache,
          }) {
            return LottieBuilder(
              key: key,
              lottie: provider,
              controller: controller,
              frameRate: frameRate,
              animate: animate,
              reverse: reverse,
              repeat: repeat,
              delegates: delegates,
              options: options,
              onLoaded: onLoaded,
              frameBuilder: frameBuilder,
              errorBuilder: errorBuilder,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              addRepaintBoundary: addRepaintBoundary,
              filterQuality: filterQuality,
              onWarning: onWarning,
              renderCache: renderCache,
            );
          }
        }
        ''';
      case AssetType.unknown:
        return '''
        class UnknownAsset {
          const UnknownAsset(this.path);

          final String path;

          Future<ByteData> load({bool cache = false}) =>
              AssetsCache.instance.putIfAbsent('\$path-load', cache, () async {
                final data = await rootBundle.load(path);
                return (data, data.lengthInBytes);
              });

          Future<String> loadString({bool cache = false}) =>
              AssetsCache.instance.putIfAbsent('\$path-loadString', cache, () async {
                final data = await load();
                return (utf8.decode(Uint8List.sublistView(data)), data.lengthInBytes);
              });
        }


        final class AssetsCache {
          AssetsCache._();

          static AssetsCache instance = AssetsCache._();

          final _cache = LruCache<String, dynamic>();

          Future<T> putIfAbsent<T>(
              String key, bool cache, FutureOr<(T, int)> Function() ifAbsent) async {
            if (!cache) {
              return (await ifAbsent()).\$1;
            }
            return _cache.putIfAbsent(key, ifAbsent).then((value) => value as T);
          }

          void evict(String key) {
            _cache.evict(key);
          }

          void clear() {
            _cache.clear();
          }
        }

        class LruCache<K, V> {
          LruCache({int countLimit = 100, int totalCostLimit = 1024 * 1024 * 50})
              : _countLimit = countLimit,
                _totalCostLimit = totalCostLimit;

          int get countLimit => _countLimit;
          int get totalCostLimit => _totalCostLimit;

          set countLimit(int value) {
            _countLimit = value;
            _checkLimit();
          }

          set totalCostLimit(int value) {
            _totalCostLimit = value;
            _checkLimit();
          }

          final Map<K, V> _map = {};
          final Map<K, int> _costMap = {};
          final List<K> _keys = [];
          int _totalCost = 0;
          int _countLimit;
          int _totalCostLimit;

          Future<V> putIfAbsent(K key, FutureOr<(V, int)> Function() ifAbsent) async {
            if (_map.containsKey(key)) {
              _keys.remove(key);
              _keys.add(key);
              return _map[key]!;
            }

            final (value, cost) = await ifAbsent();
            _map[key] = value;
            _costMap[key] = cost;
            _keys.add(key);
            _checkLimit();
            return value;
          }

          void clear() {
            _map.clear();
          }

          void evict(K key) {
            _map.remove(key);
            _costMap.remove(key);
            _keys.remove(key);
          }

          void _checkLimit() {
            while (_map.length > countLimit || _totalCost > totalCostLimit) {
              final key = _keys.removeAt(0);
              final cost = _costMap.remove(key) ?? 0;
              _map.remove(key);
              _totalCost -= cost;
            }
          }
        }
        ''';
      case AssetType.json:
        return """
        final class JsonAsset extends UnknownAsset {
          const JsonAsset(super.path, this.backgroud);

          final bool backgroud;

          Future<Map<String, dynamic>> json({bool cache = false}) async {
            return AssetsCache.instance.putIfAbsent('\$path-json', cache, () async {
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
        """;
    }
  }
}
