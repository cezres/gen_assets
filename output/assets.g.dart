import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

final class Assets {
  const Assets._();

  static AssetsFonts get fonts => const AssetsFonts();

  static AssetsImages get images => const AssetsImages();

  static AssetsJson get json => const AssetsJson();

  static AssetsLottie get lottie => const AssetsLottie();
}

final class AssetsFonts {
  const AssetsFonts();

  FontAsset get robotoRegular => const FontAsset('Roboto-Regular');
}

final class AssetsImages {
  const AssetsImages();

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/download.png)
  ImageAsset get download => const ImageAsset('assets/images/download.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/download_1.png)
  ImageAsset get download1 => const ImageAsset('assets/images/download_1.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/refresh.png)
  ImageAsset get refresh => const ImageAsset('assets/images/refresh.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/share.png)
  ImageAsset get share => const ImageAsset('assets/images/share.png');
}

final class AssetsJson {
  const AssetsJson();

  JsonAsset get test1 => const JsonAsset('assets/json/test1.json', true);
}

final class AssetsLottie {
  const AssetsLottie();

  LottieAsset get test1 => const LottieAsset('assets/lottie/test1.json');

  LottieAsset get test2 => const LottieAsset('assets/lottie/test2.json');
}

final class FontAsset {
  const FontAsset(this.name);

  final String name;
}

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

final class JsonAsset extends UnknownAsset {
  const JsonAsset(super.path, this.backgroud);

  final bool backgroud;

  Future<Map<String, dynamic>> json() async {
    final data = await load();
    if (backgroud) {
      return compute(
        (message) {
          return _parseToJson(message.materialize().asUint8List());
        },
        TransferableTypedData.fromList([data.buffer.asUint8List()]),
      );
    } else {
      return _parseToJson(data.buffer.asUint8List());
    }
  }

  Future<T> parse<T>(
      FutureOr<T> Function(Map<String, dynamic> json) parser) async {
    final data = await load();
    if (backgroud) {
      return compute(
        (message) {
          final bytes = message.materialize().asUint8List();
          return parser(_parseToJson(bytes));
        },
        TransferableTypedData.fromList([data.buffer.asUint8List()]),
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
