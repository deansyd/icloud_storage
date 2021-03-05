import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icloud_storage/icloud_storage.dart';

void main() {
  const MethodChannel channel = MethodChannel('icloud_storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  MethodCall _methodCall;

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      _methodCall = methodCall;
      switch (methodCall.method) {
        case 'listFiles':
          return ['a', 'b'];
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('listFiles', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    final files = await iCloudStorage.listFiles();
    expect(files, ['a', 'b']);
  });

  test('watchFiles', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.watchFiles();
    expect(_methodCall.arguments, {'watchUpdate': true});
  });

  test('startUpload', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.startUpload(filePath: '/dir/file');
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'file',
      'watchUpdate': false
    });

    await iCloudStorage.startUpload(
        filePath: '/dir/file', destinationFileName: 'newFile');
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'newFile',
      'watchUpdate': false
    });

    await iCloudStorage.startUpload(
      filePath: '/dir/file',
      destinationFileName: 'newFile',
      onProgress: (stream) {},
    );
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'newFile',
      'watchUpdate': true
    });

    expect(() async => await iCloudStorage.startUpload(filePath: ''),
        throwsException);
  });

  test('startDownload', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.startDownload(
      fileName: 'file',
      destinationFilePath: '/dir/file',
    );
    expect(_methodCall.arguments, {
      'cloudFileName': 'file',
      'localFilePath': '/dir/file',
      'watchUpdate': false
    });

    await iCloudStorage.startUpload(
      filePath: '/dir/file',
      destinationFileName: 'newFile',
      onProgress: (stream) {},
    );
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'newFile',
      'watchUpdate': true
    });

    expect(
        () async => await iCloudStorage.startDownload(
              fileName: 'file/',
              destinationFilePath: '/dir/file',
            ),
        throwsException);

    expect(
        () async => await iCloudStorage.startDownload(
              fileName: 'file',
              destinationFilePath: '/dir/file/',
            ),
        throwsException);
  });

  test('delete', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.delete('file');
    expect(_methodCall.arguments, {'cloudFileName': 'file'});

    expect(() async => await iCloudStorage.delete('dir/file'), throwsException);
  });
}
