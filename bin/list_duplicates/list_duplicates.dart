import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

import '../utils/directory_utils.dart';

final class DuplicateFileDetector {
  Future<void> listDuplicates() async {
    final md5 = await calculateFileMD5();

    final duplicates =
        <String, List<String>>{}; // MD5 -> List<FileRelativePath>
    for (var element in md5.entries) {
      final path = element.key;
      final cache = element.value;
      final md5 = cache['md5'];
      final list = duplicates[md5];
      if (list != null) {
        list.add(path);
      } else {
        duplicates[md5] = [path];
      }
    }

    print('Duplicate Files:');
    duplicates.values.where((element) => element.length > 1).forEach(print);
  }

  Future<Map<String, Map<String, dynamic>>> calculateFileMD5() async {
    final caches = GenAssetsLock.loadMD5Caches();
    final newMd5 = <String, Map<String, dynamic>>{};

    for (var element in listTotalAssetFiles()) {
      if (element is! File) {
        continue;
      }
      final relativePath =
          element.path.replaceFirst(Directory.current.path, '');
      final stat = element.statSync();
      final cache = caches[relativePath];
      if (cache != null) {
        if (stat.size == cache['size'] &&
            stat.modified.millisecondsSinceEpoch == cache['modified']) {
          newMd5[relativePath] = cache;
          continue;
        }
      }

      final hash = await md5.bind(element.openRead()).first;
      final hexHash = base64.encode(hash.bytes);
      newMd5[relativePath] = {
        'size': stat.size,
        'modified': stat.modified.millisecondsSinceEpoch,
        'md5': hexHash
      };
    }

    GenAssetsLock.saveMD5Caches(newMd5);

    return newMd5;
  }
}

final class GenAssetsLock {
  /// FileRelativePath -> MD5Info
  static Map<String, Map<String, dynamic>> loadMD5Caches() {
    final file = File(join(Directory.current.path, 'gen_assets.lock.json'));
    if (!file.existsSync()) {
      return {};
    }

    final string = file.readAsStringSync();
    final json = jsonDecode(string);
    final md5 = json['md5'];
    if (md5 is Map<String, Map<String, dynamic>>) {
      return md5;
    } else {
      return {};
    }
  }

  static void saveMD5Caches(Map<String, Map<String, dynamic>> md5) {
    final string = JsonEncoder.withIndent('    ').convert({'md5': md5});

    final file = File(join(Directory.current.path, 'gen_assets.lock.json'));

    file.writeAsStringSync(string);

    // String prettyJson = jsonEncode(
    //   {},
    //   toEncodable: (object) => object.toString(),
    //   indent: '    ',
    // );
  }
}
