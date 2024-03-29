import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'convert/convert_image_to_webp.dart';
import 'convert/convert_json.dart';
import 'generator/assets_generator.dart';
import 'list_duplicates/list_duplicates.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addCommand('cwebp')
    ..addCommand('list-cwebp-original')
    ..addCommand('list-duplicates')
    ..addCommand('cjson')
    ..addCommand('djson');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart gen_assets.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('gen_assets version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }

    final yaml = loadGenAssetsYaml();
    // listOriginalImages(yaml);

    if (results.command?.name == 'cwebp') {
      converToWebp(yaml);
    } else if (results.command?.name == 'list-cwebp-original') {
      listOriginalImages(yaml);
    } else if (results.command?.name == 'list-duplicates') {
      await DuplicateFileDetector().listDuplicates();
    } else if (results.command?.name == 'cjson') {
      removeAllJsonWhitespace();
    } else if (results.command?.name == 'djson') {
      formatAllJsonWithWhitespace();
    } else {
      generateAssets(yaml);
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

dynamic loadGenAssetsYaml() {
  final configsPath = join(Directory.current.path, 'gen_assets.yaml');
  final configFile = File(configsPath);
  if (!configFile.existsSync()) {
    print('No gen_assets.yaml file found in the current directory.');
    return;
  }
  return loadYaml(configFile.readAsStringSync());
}
