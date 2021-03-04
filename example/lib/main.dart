import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:icloud_storage/icloud_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const iCloudContainerId = '{your icloud container id}';

  void handleError(dynamic err) {
    if (err is PlatformException &&
        err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
      print(
          'Error: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
    } else {
      print(err.toString());
    }
  }

  Future<void> testListFile() async {
    try {
      final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
      final files = await iCloudStorage.listFiles();
      files.forEach((file) => print('--- List Files --- file: $file'));
    } catch (err) {
      handleError(err);
    }
  }

  Future<void> testWatchFile() async {
    try {
      final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
      final fileListStream = await iCloudStorage.watchFiles();
      final fileListSubscription = fileListStream.listen((files) {
        files.forEach((file) => print('--- Watch Files --- file: $file'));
      });

      Future.delayed(Duration(seconds: 10), () {
        fileListSubscription.cancel();
        print('--- Watch Files --- canceled');
      });
    } catch (err) {
      handleError(err);
    }
  }

  Future<void> testUploadFile() async {
    try {
      final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
      StreamSubscription<double> uploadProgressSubcription;
      var isUploadComplete = false;

      await iCloudStorage.startUpload(
        filePath: '{your local file}',
        destinationFileName: 'test_icloud_file',
        onProgress: (stream) {
          uploadProgressSubcription = stream.listen(
            (progress) => print('--- Upload File --- progress: $progress'),
            onDone: () {
              isUploadComplete = true;
              print('--- Upload File --- done');
            },
            onError: (err) => print('--- Upload File --- error: $err'),
            cancelOnError: true,
          );
        },
      );

      Future.delayed(Duration(seconds: 10), () {
        if (!isUploadComplete) {
          uploadProgressSubcription?.cancel();
          print('--- Upload File --- timed out');
        }
      });
    } catch (err) {
      handleError(err);
    }
  }

  Future<void> testDownloadFile() async {
    try {
      final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
      StreamSubscription<double> downloadProgressSubcription;
      var isDownloadComplete = false;

      await iCloudStorage.startDownload(
        fileName: 'test_icloud_file',
        destinationFilePath: '{your destination file path}',
        onProgress: (stream) {
          downloadProgressSubcription = stream.listen(
            (progress) => print('--- Download File --- progress: $progress'),
            onDone: () {
              isDownloadComplete = true;
              print('--- Download File --- done');
            },
            onError: (err) => print('--- Download File --- error: $err'),
            cancelOnError: true,
          );
        },
      );

      Future.delayed(Duration(seconds: 20), () {
        if (!isDownloadComplete) {
          downloadProgressSubcription?.cancel();
          print('--- Download File --- timed out');
        }
      });
    } catch (err) {
      handleError(err);
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
              FlatButton(
                child: Text('List File'),
                onPressed: testListFile,
              ),
              FlatButton(
                child: Text('Watch File'),
                onPressed: testWatchFile,
              ),
              FlatButton(
                child: Text('Start Upload'),
                onPressed: testUploadFile,
              ),
              FlatButton(
                child: Text('Start Download'),
                onPressed: testDownloadFile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
