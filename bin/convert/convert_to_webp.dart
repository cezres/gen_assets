import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

void converToWebp(dynamic yaml) async {
  final cwebp = yaml['cwebp_path'];
  if (cwebp == null) {
    print('cwebp_path is not defined in gen_assets.yaml');
    return;
  }
  if (File(cwebp).existsSync() == false) {
    print('cwebp_path is not found: $cwebp');
    return;
  }

  final types = (yaml['convert_to_webp'] as YamlList)
      .map((element) => '.$element')
      .cast<String>()
      .toSet();

  final imageFiles = await Directory.current
      .list(recursive: true)
      .where((event) => types.contains(extension(event.path)))
      .toList();

  int newSize = 0;
  for (var i = 0; i < imageFiles.length; i++) {
    final file = imageFiles[i];
    final newPath = file.path.replaceAll(extension(file.path), '.webp');
    final process = await Process.start(cwebp, [file.path, '-o', newPath]);
    await process.exitCode;

    newSize += File(newPath).lengthSync();

    final relativePath = file.path.replaceFirst(Directory.current.path, '');
    final newRelativePath = newPath.replaceFirst(Directory.current.path, '');
    print('${i + 1}/${imageFiles.length} $relativePath --> $newRelativePath');
  }

  final originalSize = imageFiles
      .map((e) => File(e.path).lengthSync())
      .fold(0, (previousValue, element) => previousValue + element);

  print('Original size: ${(originalSize / 1024).toStringAsFixed(3)} KB');
  print('New size: ${(newSize / 1024).toStringAsFixed(3)} KB');
  print(
      'Compression ratio: ${(newSize / originalSize * 100).toStringAsFixed(4)}%');
}
