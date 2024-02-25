final class Assets {
  const Assets();
  static AssetsImages get images => const AssetsImages();
  static AssetsFonts get fonts => const AssetsFonts();
}

final class AssetsImages {
  const AssetsImages();

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/download.png)
  ImageAsset get download => const ImageAsset('/assets/images/download.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/download_1.png)
  ImageAsset get download_1 =>
      const ImageAsset('/assets/images/download_1.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/share.png)
  ImageAsset get share => const ImageAsset('/assets/images/share.png');

  /// ![](/Users/cezres/Documents/GitHub/gen_assets/assets/images/refresh.png)
  ImageAsset get refresh => const ImageAsset('/assets/images/refresh.png');
}

final class AssetsFonts {
  const AssetsFonts();

  FontAsset get robotoRegular => const FontAsset('Roboto-Regular');
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
      name,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }
}

final class FontAsset {
  const FontAsset(Sring name);
  final String name;
}
