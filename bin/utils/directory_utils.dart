import 'dart:io';

import 'package:path/path.dart';

import '../gen_assets.dart';

List<FileSystemEntity> listTotalAssetFiles() {
  final yaml = loadGenAssetsYaml();

  final inputDir = yaml['input_dir'];
  if (inputDir == null) {
    throw Exception('input_dir is not defined in gen_assets.yaml');
  }

  final directory = Directory(join(Directory.current.path, inputDir));

  if (!directory.existsSync()) {
    throw Exception('input_dir is not found: ${directory.path}');
  }

  return directory
      .listSync(recursive: true)
      .where((event) => !event.path.endsWith('.DS_Store'))
      .toList();
}
