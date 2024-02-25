import 'package:path/path.dart';

import 'asset_file.dart';

AssetType assetTypeFromExtension(String ext) {
  switch (ext) {
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.webp':
      return AssetType.image;
    case '.ttf':
      return AssetType.font;
    default:
      return AssetType.unknown;
  }
}

enum AssetType {
  image,
  font,
  unknown;

  String get className {
    switch (this) {
      case AssetType.image:
        return 'ImageAsset';
      case AssetType.font:
        return 'FontAsset';
      case AssetType.unknown:
        return 'UnknownAsset';
    }
  }

  String generatorImport() {
    switch (this) {
      case AssetType.image:
        return "import 'package:flutter/widgets.dart';";
      case AssetType.font:
      case AssetType.unknown:
        return '';
    }
  }

  String generatorComment(AssetFile file) {
    switch (this) {
      case AssetType.image:
        return '/// ![](${file.path})';
      case AssetType.unknown:
      case AssetType.font:
        return '';
    }
  }

  String generatorConstruct(AssetFile file) {
    switch (this) {
      case AssetType.image:
      case AssetType.unknown:
        return 'const $className(\'${file.relativePath}\')';
      case AssetType.font:
        final basename = basenameWithoutExtension(file.relativePath);
        return 'const $className(\'$basename\')';
    }
  }

  String get generatorClass {
    switch (this) {
      case AssetType.image:
        // extension type ImageAsset(String name) {
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
      case AssetType.unknown:
        // extension type UnknownAsset(String name) {}
        return '''
        final class UnknownAsset {
          const UnknownAsset(this.path);

          final String path;
        }
        ''';
    }
  }
}
