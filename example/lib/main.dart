import 'package:flutter/material.dart';
import 'gather.dart';
import 'upload.dart';
import 'download.dart';
import 'delete.dart';
import 'move.dart';
import 'rename.dart';

void main() {
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
