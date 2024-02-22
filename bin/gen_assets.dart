import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:dart_style/dart_style.dart';

import 'assets_generator.dart';

const String version = '0.0.1';

void generateAssets() {
  // final directory = Directory.current;
  final directory = Directory('/Users/cezres/Desktop/gen_assets');

  /// configs
  final configsPath = join(directory.path, 'gen_assets.yaml');
  final configFile = File(configsPath);
  if (!configFile.existsSync()) {
    print('No gen_assets.yaml file found in the current directory.');
    return;
  }
  final configs = loadYaml(configFile.readAsStringSync());

  final input = configs['input_dir'];
  final output = configs['output_dir'];
  if (input == null || output == null) {
    print('Invalid gen_assets.yaml file.');
    return;
  }

  final inputPath = join(directory.path, input);
  final outputPath = join(directory.path, output, 'assets.g.dart');

  final assets = AssetsGenerator.fromPath(inputPath);
  final formatter = DartFormatter();
  final outputString = formatter.format(assets.generator());

  File(outputPath).writeAsStringSync(outputString);
}

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
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart gen_assets.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  generateAssets();

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

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
