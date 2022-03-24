import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icloud_storage/icloud_storage.dart';

void main() {
  const MethodChannel channel = MethodChannel('icloud_storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodCall _methodCall;

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      _methodCall = methodCall;
      switch (methodCall.method) {
        case 'listFiles':
          return ['a', 'b'];
        case 'gatherFiles':
          return [];
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('gatherFiles', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    final files = await iCloudStorage.gatherFiles();
    expect(files, []);
    expect((_methodCall.arguments['eventChannelName'] as String).length == 0,
        true);

    await iCloudStorage.gatherFiles(onUpdate: (strem) {});
    expect(
        (_methodCall.arguments['eventChannelName'] as String).length > 0, true);
  });

  test('listFiles', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    // ignore: deprecated_member_use_from_same_package
    final files = await iCloudStorage.listFiles();
    expect(files, ['a', 'b']);
  });

  test('watchFiles', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    // ignore: deprecated_member_use_from_same_package
    await iCloudStorage.watchFiles();
    expect(
        (_methodCall.arguments['eventChannelName'] as String).length > 0, true);
  });

  test('startUpload', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.startUpload(filePath: '/dir/file');
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'file',
      'eventChannelName': ''
    });

    await iCloudStorage.startUpload(
        filePath: '/dir/file', destinationRelativePath: 'newFile');
    expect(_methodCall.arguments, {
      'localFilePath': '/dir/file',
      'cloudFileName': 'newFile',
      'eventChannelName': ''
    });

    expect(
      () async => await iCloudStorage.startUpload(filePath: ''),
      throwsException,
    );

    expect(
      () async => await iCloudStorage.startUpload(
          filePath: '/dir/file', destinationRelativePath: '/destFile'),
      throwsException,
    );

    expect(
      () async => await iCloudStorage.startUpload(
          filePath: '/dir/file', destinationRelativePath: 'path//file'),
      throwsException,
    );

    expect(
      () async => await iCloudStorage.startUpload(
          filePath: '/dir/file', destinationRelativePath: '..file'),
      throwsException,
    );

    expect(
      () async => await iCloudStorage.startUpload(
          filePath: '/dir/file', destinationRelativePath: 'file:file'),
      throwsException,
    );
  });

  test('startDownload', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.startDownload(
      relativePath: 'file',
      destinationFilePath: '/dir/file',
    );
    expect(_methodCall.arguments, {
      'cloudFileName': 'file',
      'localFilePath': '/dir/file',
      'eventChannelName': ''
    });

    expect(
      () async => await iCloudStorage.startDownload(
        relativePath: 'file/',
        destinationFilePath: 'dir/file',
      ),
      throwsException,
    );

    expect(
      () async => await iCloudStorage.startDownload(
        relativePath: ' ',
        destinationFilePath: 'dir/file/',
      ),
      throwsException,
    );
  });

  test('delete', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.delete('file');
    expect(_methodCall.arguments, {'cloudFileName': 'file'});
  });

  test('move', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.move(
      fromRelativePath: 'fromRelativePath',
      toRelativePath: 'toRelativePath',
    );
    expect(_methodCall.arguments, {
      'atRelativePath': 'fromRelativePath',
      'toRelativePath': 'toRelativePath',
    });
  });

  test('rename', () async {
    final iCloudStorage = await ICloudStorage.getInstance('containerId');
    await iCloudStorage.rename(
      relativePath: 'path/file',
      newName: 'file1',
    );
    expect(_methodCall.arguments, {
      'atRelativePath': 'path/file',
      'toRelativePath': 'path/file1',
    });
  });
}
