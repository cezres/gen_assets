import 'package:path/path.dart';

import 'asset_types.dart';
import 'assets_generator.dart';

class AssetFile {
  AssetFile({
    required this.path,
    required this.relativePath,
    required this.name,
    required this.type,
  });

  final String path;
  final String relativePath;
  final String name;
  final AssetType type;

  factory AssetFile.fromPath(String path, String rootPath) {
    final String name = basenameWithoutExtension(path);
    final String relativePath = path.replaceFirst(rootPath, '');
    return AssetFile(
      path: path,
      relativePath: relativePath,
      name: name,
      type: assetTypeFromFilePath(path),
    );
  }

  String generator({bool hasExtVariableName = true}) {
    final String ext;
    if (hasExtVariableName) {
      ext = extension(relativePath).replaceFirst('.', '').upperFirst;
    } else {
      ext = '';
    }
    return """
    ${type.generatorComment(this)}
    ${type.className} get ${name.formatName.lowerFirst}$ext => ${type.generatorConstruct(this)};
    """;
  }
}
