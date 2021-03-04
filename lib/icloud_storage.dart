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

  /// Get an instance of the ICloudStorage class
  ///
  /// [containerId] is the iCloud Container ID created in the apple developer account
  ///
  /// Returns an instance of the ICloudStorage class
  static Future<ICloudStorage> getInstance(String containerId) async {
    await _channel.invokeMethod('initialize', {
      'containerId': containerId,
    });
    return _instance;
  }

  /// Lists files from the iCloud container directory, which lives on the device
  ///
  /// Returns a list of file names
  Future<List<String>> listFiles() async {
    return await _channel
        .invokeListMethod<String>('listFiles', {'watchUpdate': false});
  }

  /// Lists files from the iCloud container directory, which lives on the
  /// device. Also watches for updates.
  ///
  /// Returns a stream of lists of the file names
  Future<Stream<List<String>>> watchFiles() async {
    await _channel.invokeMethod('listFiles', {'watchUpdate': true});
    return _listEventChannel
        .receiveBroadcastStream()
        .where((event) => event is List)
        .map<List<String>>(
            (event) => (event as List).map((item) => item as String).toList());
  }

  /// Start to upload a file from a local path to iCloud
  ///
  /// [filePath] is the full path of the local file
  ///
  /// [destinationFileName] is the name of the file you want to store in iCloud.
  /// If not specified, the name of the local file is used.
  ///
  /// [onProgress] is an optional callback to to track the progress of the
  /// upload. It takes a Stream<double> as input, which is the percentage of
  /// the data being uploaded.
  ///
  /// It does not wait for the file to finish upload to return void
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

  /// Start to download a file from iCloud
  ///
  /// [fileName] is the name of the file on iCloud
  ///
  /// [destinationFilePath] is the full path of the local file you want the
  /// iCloud file to be saved as
  ///
  /// [onProgress] is an optional callback to to track the progress of the
  /// download. It takes a Stream<double> as input, which is the percentage of
  /// the data being downloaded.
  ///
  /// It does not wait for the file to finish download to return void
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

/// An exception class used for development. It's ued when invalid argument
/// is passed to the API
class InvalidArgumentException implements Exception {
  final _message;
  InvalidArgumentException(this._message);

  String toString() => "InvalidArgumentException: $_message";
}

/// A class contains the error code from PlatformException
class PlatformExceptionCode {
  static const String iCloudConnectionOrPermission = 'E_CTR';
  static const String nativeCodeError = 'E_NAT';
}
