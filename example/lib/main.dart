import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icloud_storage/icloud_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const iCloudContainerId = '{your icloud container id}';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<List<ICloudFile>>? filesUpdateSub;
  StreamSubscription<double>? uploadProgressSub;
  StreamSubscription<double>? downloadProgressSub;

  Future<void> gatherFiles() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      final fileList = await iCloudStorage.gatherFiles(onUpdate: (stream) {
        filesUpdateSub = stream.listen((updatedFileList) {
          print('FILES UPDATED');
          updatedFileList.forEach((file) => print('-- ${file.relativePath}'));
        });
      });
      print('FILES GATHERED');
      fileList.forEach((file) => print('-- ${file.relativePath}'));
    } catch (err) {
      _handleError(err);
    }
  }

  Future<void> uploadFile() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      await iCloudStorage.startUpload(
        filePath: '/localDir/localFile',
        destinationRelativePath: 'destDir/destFile',
        onProgress: (stream) {
          uploadProgressSub = stream.listen(
            (progress) => print('Upload File Progress: $progress'),
            onDone: () => print('Upload File Done'),
            onError: (err) => print('Upload File Error: $err'),
            cancelOnError: true,
          );
        },
      );
    } catch (err) {
      _handleError(err);
    }
  }

  Future<void> downloadFile() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      await iCloudStorage.startDownload(
        relativePath: 'relativePath',
        destinationFilePath: '/localDir/localFile',
        onProgress: (stream) {
          downloadProgressSub = stream.listen(
            (progress) => print('Download File Progress: $progress'),
            onDone: () => print('Download File Done'),
            onError: (err) => print('Download File Error: $err'),
            cancelOnError: true,
          );
        },
      );
    } catch (err) {
      _handleError(err);
    }
  }

  Future<void> renameFile() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      await iCloudStorage.rename(
        relativePath: 'relativePath',
        newName: 'newName',
      );
    } catch (err) {
      _handleError(err);
    }
  }

  Future<void> moveFile() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      await iCloudStorage.move(
        fromRelativePath: 'dir/file',
        toRelativePath: 'dir/subdir/file',
      );
    } catch (err) {
      _handleError(err);
    }
  }

  Future<void> deleteFile() async {
    try {
      final iCloudStorage =
          await ICloudStorage.getInstance(MyApp.iCloudContainerId);
      await iCloudStorage.delete('relativePath');
    } catch (err) {
      _handleError(err);
    }
  }

  void _handleError(dynamic err) {
    if (err is PlatformException) {
      if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
        print(
            'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
      } else if (err.code == PlatformExceptionCode.fileNotFound) {
        print('File not found');
      } else {
        print('Platform Exception: ${err.message}; Details: ${err.details}');
      }
    } else {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('icloud_storage plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                child: Text('Gather Files'),
                onPressed: gatherFiles,
              ),
              TextButton(
                child: Text('Start Upload'),
                onPressed: uploadFile,
              ),
              TextButton(
                child: Text('Start Download'),
                onPressed: downloadFile,
              ),
              TextButton(
                child: Text('Rename File'),
                onPressed: renameFile,
              ),
              TextButton(
                child: Text('Move File'),
                onPressed: moveFile,
              ),
              TextButton(
                child: Text('Delete File'),
                onPressed: deleteFile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    filesUpdateSub?.cancel();
    uploadProgressSub?.cancel();
    downloadProgressSub?.cancel();
    super.dispose();
  }
}
