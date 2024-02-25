import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import 'asset_directory.dart';

void generateAssets(dynamic yaml) {
  final directory = Directory.current;
  final input = yaml['input_dir'];
  final output = yaml['output'];
  if (input == null || output == null) {
    print('Invalid gen_assets.yaml file.');
    return;
  }

  final inputPath = join(directory.path, input);
  final outputPath = join(directory.path, output);
  final assets = AssetsGenerator.fromPath(inputPath);
  final formatter = DartFormatter();
  final outputString = formatter.format(assets.generator());

  File(outputPath).writeAsStringSync(outputString);
}

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
    String text = rootDirectory.generator('');
    final types = rootDirectory.types;

    for (var element in types) {
      text += element.generatorClass;
      text += '\n';
    }

    return text;
  }
}

extension UpperFirst on String {
  String get upperFirst => this[0].toUpperCase() + substring(1);
}

extension LowerFirst on String {
  String get lowerFirst => this[0].toLowerCase() + substring(1);

  String get formatVariableName {
    return replaceAll('-', '').lowerFirst;
  }
}

String formatVariableName() {
  return '';
}
