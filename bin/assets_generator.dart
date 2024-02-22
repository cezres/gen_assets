import 'dart:io';

import 'package:path/path.dart';

final class AssetsGenerator {
  AssetsGenerator({
    required this.rootName,
    required this.rootDirectory,
  });

  final String rootName;

  final AssetDirectory rootDirectory;

  factory AssetsGenerator.fromPath(String path, {String? rootName}) {
    final rootPath = Directory(path).parent.path;

    final rootDirectory = AssetDirectory.fromPath(path, rootPath, '');
    return AssetsGenerator(
      rootName: rootName ?? rootDirectory.name,
      rootDirectory: rootDirectory,
    );
  }

  String generator() {
    return '''
    final class ${rootName.upperFirst} {
      ${rootName.upperFirst}._();
    }
    ''';
  }
}

class AssetDirectory {
  AssetDirectory({
    required this.name,
    required this.directories,
    required this.files,
    required this.className,
  });

  final String name;
  final List<AssetDirectory> directories;
  final List<AssetFile> files;
  final String className;

  Set<AssetType> get types {
    final Set<AssetType> types = <AssetType>{};
    for (final AssetFile file in files) {
      types.add(file.type);
    }
    for (final AssetDirectory directory in directories) {
      types.addAll(directory.types);
    }
    return types;
  }

  factory AssetDirectory.fromPath(
    String path,
    String rootPath,
    String baseClassName,
  ) {
    final String name = basename(path);
    final String className = baseClassName + name.upperFirst;
    final List<FileSystemEntity> entities = Directory(path).listSync();
    final List<AssetDirectory> directories = <AssetDirectory>[];
    final List<AssetFile> files = <AssetFile>[];
    for (final FileSystemEntity entity in entities) {
      if (entity.path.endsWith('.DS_Store')) {
        continue;
      } else if (entity is Directory) {
        directories
            .add(AssetDirectory.fromPath(entity.path, rootPath, className));
      } else if (entity is File) {
        files.add(AssetFile.fromPath(entity.path, rootPath));
      }
    }
    return AssetDirectory(
        name: name,
        directories: directories,
        files: files,
        className: className);
  }

  String generator(String baseName) {
    String child = '';
    for (final AssetDirectory directory in directories) {
      child += "AssetsFonts get ${directory.name} => AssetsFonts();";
      child += '\n';
    }
    return '''
    final class $baseName$name {
      ImageAsset get logo => ImageAsset('assets/images/logo.png');
    }
    ''';
  }
}

class AssetFile {
  AssetFile({required this.path, required this.name, required this.type});

  final String path;
  final String name;
  final AssetType type;

  factory AssetFile.fromPath(String path, String rootPath) {
    final String name = basenameWithoutExtension(path);
    final String relativePath = path.replaceFirst(rootPath, '');
    return AssetFile(
      path: relativePath,
      name: name,
      type: assetTypeFromExtension(extension(path)),
    );
  }

  String generator() {
    return "${type.className} get $name => ${type.className}('$path');";
  }
}

AssetType assetTypeFromExtension(String ext) {
  switch (ext) {
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'webp':
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

  String get code {
    switch (this) {
      case AssetType.image:
        return '''
        extension type ImageAsset(String name) {
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
        return '''
        ''';
    }
  }
}

extension UpperFirst on String {
  String get upperFirst => this[0].toUpperCase() + substring(1);
}
