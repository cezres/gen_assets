final class Assets {
  const Assets();
  static AssetsImages get images => const AssetsImages();
  static AssetsFonts get fonts => const AssetsFonts();
}

final class AssetsImages {
  const AssetsImages();
  ImageAsset get download => const ImageAsset('/assets/images/download.png');
  ImageAsset get share => const ImageAsset('/assets/images/share.png');
  ImageAsset get refresh => const ImageAsset('/assets/images/refresh.png');
}

final class AssetsFonts {
  const AssetsFonts();
  UnknownAsset get robotoRegular =>
      const UnknownAsset('/assets/fonts/Roboto-Regular.ttf');
}

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

final class UnknownAsset {
  const UnknownAsset(this.name);

  final String name;
}
