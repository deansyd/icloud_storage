import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'gather.dart';
import 'upload.dart';
import 'download.dart';
import 'delete.dart';
import 'move.dart';
import 'rename.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Write gibberish files to simulate a real-world scenario
  final supportDir = await getApplicationSupportDirectory();
  supportDir.createSync(recursive: true);

  for (int i = 0; i < 10; i++) {
    final file = File(path.join(supportDir.path, 'f$i'));
    file.writeAsStringSync('This is a test file $i');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: ((settings) {
        final args = settings.arguments;
        Widget page = const Gather();
        switch (settings.name) {
          case '/upload':
            page = Upload(containerId: args as String);
            break;
          case '/download':
            page = Download(containerId: args as String);
            break;
          case '/delete':
            page = Delete(containerId: args as String);
            break;
          case '/move':
            page = Move(containerId: args as String);
            break;
          case '/rename':
            page = Rename(containerId: args as String);
            break;
        }
        return MaterialPageRoute(builder: (_) => page);
      }),
    );
  }
}
