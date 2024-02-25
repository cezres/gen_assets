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
    final String name = basename(path).formatName;
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
    directories.sort((a, b) => a.name.compareTo(b.name));
    files.sort((a, b) => a.name.compareTo(b.name));
    return AssetDirectory(
        name: name,
        directories: directories,
        files: files,
        className: className);
  }

  String generator(String parent) {
    String childText = '';
    String appendText = '';

    Map<String, List<String>> filePathsOfVariableName = {};
    for (var element in directories) {
      if (filePathsOfVariableName.containsKey(element.name)) {
        filePathsOfVariableName[element.name]!.add(element.name);
      } else {
        filePathsOfVariableName[element.name] = [element.name];
      }
    }
    for (var element in files) {
      if (filePathsOfVariableName.containsKey(element.name)) {
        filePathsOfVariableName[element.name]!.add(element.name);
      } else {
        filePathsOfVariableName[element.name] = [element.name];
      }
    }

    final prefix = parent.isEmpty ? 'static ' : '';
    for (final AssetDirectory directory in directories) {
      childText +=
          "$prefix ${directory.className} get ${directory.name} => const ${directory.className}();\n\n";

      appendText += "${directory.generator(parent + name.upperFirst)}\n";
    }
    for (final AssetFile file in files) {
      childText +=
          '$prefix ${file.generator(hasExtVariableName: (filePathsOfVariableName[file.name]?.length ?? 1) > 1)}\n';
    }
    return '''
    final class $parent${name.upperFirst} {
      const $parent${name.upperFirst}${parent.isEmpty ? "._" : ""}();

      $childText
    }

    $appendText
    ''';
  }
}
