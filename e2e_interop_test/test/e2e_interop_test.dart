@TestOn('vm')
import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:logging/logging.dart';

void main() {
  late StreamSubscription<LogRecord> logSubscription;
  setUp(() {
    Logger.root.level = Level.ALL;
    logSubscription = Logger.root.onRecord.listen((r) => printOnFailure('$r'));
  });

  tearDown(() {
    logSubscription.cancel();
  });

  group('dartdevc', () {
    setUpAll(() {
      final compile = Process.runSync('dart', [
        'run',
        'build_runner',
        'build',
        '--define',
        'build_node_compilers|entrypoint=compiler=dartdevc',
        '--output',
        'build',
      ]);
      expect(compile.exitCode, 0, reason: compile.stdout);
    });
    tearDownAll(() {
      final buildDir = new Directory('build');
      if (buildDir.existsSync()) {
        buildDir.deleteSync(recursive: true);
      }
    });

    test('compile', () {
      final run = Process.runSync('node', ['build/node/hello_world.dart.js'],
          runInShell: true);
      expect(run.exitCode, 0);
      expect(run.stdout, 'Hello world\n');
      // 3.1514934010709914
    }, skip: 'dartdevc support is very fragile');

    test('exports', () {
      final run =
          Process.runSync('node', ['build/node/slow_pi.js'], runInShell: true);
      expect(run.exitCode, 0);
      expect(run.stdout, contains('slowPi(100): 3.1514934010709914\n'));
      expect(run.stdout, contains('fastPi: 3.1514934010709914\n'));
      expect(run.stdout, contains('defaultAccuracy: 100\n'));
    }, skip: 'dartdevc support is very fragile');
  });

  group('dart2js', () {
    setUpAll(() {
      final compile = Process.runSync('dart', [
        'run',
        'build_runner',
        'build',
        // '--define',
        // 'build_node_compilers|entrypoint=compiler=dart2js',
        '--output',
        'build',
      ]);
      expect(compile.exitCode, 0, reason: compile.stdout);
    });

    tearDownAll(() {
      final buildDir = new Directory('build');
      if (buildDir.existsSync()) {
        buildDir.deleteSync(recursive: true);
      }
    });

    test('compile', () {
      final run = Process.runSync('node', ['build/node/hello_world.dart.js'],
          runInShell: true);
      expect(run.exitCode, 0);
      expect(run.stdout, 'Hello world\n');
    });

    test('exports', () {
      final run =
          Process.runSync('node', ['build/node/slow_pi.js'], runInShell: true);
      expect(run.exitCode, 0);
      expect(run.stdout, contains('slowPi(100): 3.1514934010709914\n'));
      expect(run.stdout, contains('fastPi: 3.1514934010709914\n'));
      expect(run.stdout, contains('defaultAccuracy: 100\n'));
    });
  });
}
