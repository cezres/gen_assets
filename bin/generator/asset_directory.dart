import 'dart:io';

import 'package:path/path.dart';

import 'asset_file.dart';
import 'asset_types.dart';
import 'assets_generator.dart';

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
    final String className = baseClassName + name.formatClassName;
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
    String append = '';

    final prefix = baseName.isEmpty ? 'static ' : '';
    for (final AssetDirectory directory in directories) {
      child +=
          "$prefix ${directory.className} get ${directory.name} => const ${directory.className}();\n";

      append += "${directory.generator(baseName + name.upperFirst)}\n";
    }
    for (final AssetFile file in files) {
      child += '$prefix ${file.generator()}\n';
    }
    return '''
    final class $baseName${name.upperFirst} {
      const $baseName${name.upperFirst}();
      $child
    }

    $append
    ''';
  }
}
