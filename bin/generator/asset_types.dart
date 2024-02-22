import 'asset_file.dart';

AssetType assetTypeFromExtension(String ext) {
  switch (ext) {
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.webp':
      return AssetType.image;
    default:
      return AssetType.unknown;
  }
}

enum AssetType {
  image,
  unknown;

  String get className {
    switch (this) {
      case AssetType.image:
        return 'ImageAsset';
      case AssetType.unknown:
        return 'UnknownAsset';
    }
  }

  String generatorComment(AssetFile file) {
    switch (this) {
      case AssetType.image:
        return '/// ![](${file.path})';
      case AssetType.unknown:
        return '';
    }
  }

  String get generator {
    switch (this) {
      case AssetType.image:
        // extension type ImageAsset(String name) {
        return '''
         final class ImageAsset { 
          const ImageAsset(this.name);

          final String name;

          Widget image({
            double? width,
            double? height,
            BoxFit? fit,
            Color? color,
          }) {
            return Image.asset(
              name,
              width: width,
              height: height,
              fit: fit,
              color: color,
            );
          }
        }
        ''';
      case AssetType.unknown:
        // extension type UnknownAsset(String name) {}
        return '''
        final class UnknownAsset {
          const UnknownAsset(this.name);

          final String name;
        }
        ''';
    }
  }
}
