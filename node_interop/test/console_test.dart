// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'dart:async';
import 'dart:js';

import 'package:node_interop/console.dart';
import 'package:node_interop/stream.dart';
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
  group('console', () {
    test('integration', () {
      var console = createConsole(createPrintStream());
      expect(() {
        console.log('hello world');
      }, prints('hello world\n'));
    });
  });
}

Writable createPrintStream() {
  return createWritable(WritableOptions(
    decodeStrings: false,
    write: allowInterop((String chunk, encoding, Function callback) {
      print(chunk.replaceFirst('\n', ''));
      callback();
    }),
  ));
}
