import 'dart:convert';
import 'dart:io';

import '../utils/directory_utils.dart';

void removeAllJsonWhitespace() {
  final length = listTotalAssetFiles()
      .whereType<File>()
      .where((element) => element.path.endsWith('.json'))
      .where(_isJsonFileToConvert)
      .toList()
      .fold(
          0,
          (previousValue, element) =>
              previousValue + _removeJsonWhitespace(element));
  print('Total reduction of ${(length / 1024 / 1024).toStringAsFixed(4)} MB');
}

void formatAllJsonWithWhitespace() {
  listTotalAssetFiles()
      .whereType<File>()
      .where((element) => element.path.endsWith('.json'))
      .where((element) => !_isJsonFileToConvert(element))
      .toList()
      .forEach(_formatJsonWithWhitespace);
}

int _removeJsonWhitespace(File file) {
  final oldLength = file.lengthSync();
  final data = jsonDecode(file.readAsStringSync());
  file.writeAsStringSync(JsonEncoder().convert(data));
  final newLength = file.lengthSync();
  print(
      '$oldLength --> $newLength -- ${file.path.replaceFirst(Directory.current.path, '')}');
  return oldLength - newLength;
}

void _formatJsonWithWhitespace(File file) {
  final data = jsonDecode(file.readAsStringSync());
  file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  print(
      'Formatted whitespace from ${file.path.replaceFirst(Directory.current.path, '')}');
}

bool _isJsonFileToConvert(File file) {
  final RandomAccessFile accessFile = file.openSync();
  final buffer = List<int>.filled(10, 0);
  accessFile.readIntoSync(buffer, 0, 4);
  accessFile.closeSync();

  if ((buffer[0] == 123 || buffer[0] == 91) &&
      buffer[1] == 10 &&
      buffer[2] == 32 &&
      buffer[3] == 32) {
    return true;
  }

  return false;
}
