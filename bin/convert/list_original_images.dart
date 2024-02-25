import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

void listOriginalImages(dynamic yaml) async {
  final types = (yaml['convert_to_webp'] as YamlList)
      .map((element) => '.$element')
      .cast<String>()
      .toList();

  final files = await Directory.current
      .list(recursive: true)
      .where((event) => extension(event.path) == '.webp')
      .map((event) => _checkOriginalImagePath(event.path, types))
      .where((event) => event != null)
      .cast<String>()
      .toList();
  if (files.isEmpty) {
    print('No original images found.');
    return;
  }

  for (var i = 0; i < files.length; i++) {
    print('${i + 1}. ${files[i].replaceFirst(Directory.current.path, '')}');
  }
  print('Total original images: ${files.length}');
  print('Enter \'Y\' to delete all original images:');

  final input = stdin.readLineSync();
  if (input?.toLowerCase() == 'y') {
    for (var file in files) {
      File(file).deleteSync();
    }
    print('All original images deleted.');
  } else {
    print('No original images deleted.');
  }
}

String? _checkOriginalImagePath(String webpPath, List<String> types) {
  for (var element in types) {
    final original = webpPath.replaceFirst('.webp', element);
    if (File(original).existsSync()) {
      return original;
    }
  }
  return null;
}
