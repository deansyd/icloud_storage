import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef StreamHandler<T> = void Function(Stream<T>);

class ICloudStorage {
  ICloudStorage._();
  static final ICloudStorage _instance = ICloudStorage._();
  static const MethodChannel _channel = const MethodChannel('icloud_storage');
  static const EventChannel _listEventChannel =
      const EventChannel('icloud_storage/event/list');

  static Future<ICloudStorage> getInstance(String containerId) async {
    await _channel.invokeMethod('initialize', {
      'containerId': containerId,
    });
    return _instance;
  }

  Future<List<String>> listFiles() async {
    return await _channel
        .invokeListMethod<String>('listFiles', {'watchUpdate': false});
  }

  Future<Stream<List<String>>> watchFiles() async {
    await _channel.invokeMethod('listFiles', {'watchUpdate': true});
    return _listEventChannel
        .receiveBroadcastStream()
        .where((event) => event is List)
        .map<List<String>>(
            (event) => (event as List).map((item) => item as String).toList());
  }

  Future<void> startUpload({
    @required String filePath,
    String destinationFileName,
    StreamHandler<double> onProgress,
  }) async {
    if (filePath == null || filePath.trim().isEmpty) {
      throw InvalidArgumentException('invalid filePath');
    }

    final cloudFileName = destinationFileName ?? filePath.split('/').last;
    await _channel.invokeMethod('upload', {
      'localFilePath': filePath,
      'cloudFileName': cloudFileName,
      'watchUpdate': onProgress != null
    });

    if (onProgress != null) {
      final uploadEventChannel =
          EventChannel('icloud_storage/event/upload/$cloudFileName');
      final stream = uploadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);
      onProgress(stream);
    }
  }

  Future<void> startDownload({
    @required String fileName,
    @required String destinationFilePath,
    StreamHandler<double> onProgress,
  }) async {
    if (fileName == null || fileName.trim().isEmpty || fileName.contains('/')) {
      throw InvalidArgumentException('invalid fileName');
    }
    if (destinationFilePath == null ||
        destinationFilePath.trim().isEmpty ||
        destinationFilePath[destinationFilePath.length - 1] == '/') {
      throw InvalidArgumentException('invalid destinationFilePath');
    }

    await _channel.invokeMethod('download', {
      'cloudFileName': fileName,
      'localFilePath': destinationFilePath,
      'watchUpdate': onProgress != null
    });

    if (onProgress != null) {
      final downloadEventChannel =
          EventChannel('icloud_storage/event/download/$fileName');
      final stream = downloadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);
      onProgress(stream);
    }
  }
}

class InvalidArgumentException implements Exception {
  final _message;
  InvalidArgumentException(this._message);

  String toString() => "InvalidArgumentException: $_message";
}

class PlatformExceptionCode {
  static const String iCloudConnectionOrPermission = 'E_CTR';
  static const String nativeCodeError = 'E_NAT';
}
