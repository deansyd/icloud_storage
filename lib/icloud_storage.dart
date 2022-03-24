import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'exceptions.dart';
export 'exceptions.dart';
import 'icloud_file.dart';
export 'icloud_file.dart';

/// A function-type alias takes a stream as argument and returns void
typedef StreamHandler<T> = void Function(Stream<T>);

/// The main class for the plugin. Contains all the API's needed for listing,
/// uploading, downloading and deleting files.
class ICloudStorage {
  ICloudStorage._();
  static final ICloudStorage _instance = ICloudStorage._();
  static const MethodChannel _channel = const MethodChannel('icloud_storage');

  /// Get an instance of the ICloudStorage class
  ///
  /// [containerId] is the iCloud Container ID created in the apple developer
  /// account
  ///
  /// Returns a future completing with an instance of the ICloudStorage class
  static Future<ICloudStorage> getInstance(String containerId) async {
    await _channel.invokeMethod('initialize', {
      'containerId': containerId,
    });
    return _instance;
  }

  /// Get all the files' meta data from iCloud container
  ///
  /// [onUpdate] is an optional paramater can be used as a call back every time
  /// when the list of files are updated. It won't be triggered when the
  /// function initially returns the list of files
  ///
  /// The function returns a future of list of ICloudFile
  Future<List<ICloudFile>> gatherFiles({
    StreamHandler<List<ICloudFile>>? onUpdate,
  }) async {
    final eventChannelName =
        onUpdate == null ? '' : 'icloud_storage/event/gather';

    if (onUpdate != null) {
      await _channel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});
      final gatherEventChannel = EventChannel(eventChannelName);
      final stream = gatherEventChannel
          .receiveBroadcastStream()
          .where((event) => event is List)
          .map<List<ICloudFile>>((event) => _mapFilesFromDynamicList(
              List<Map<dynamic, dynamic>>.from(event)));
      onUpdate(stream);
    }

    final mapList = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'gatherFiles', {'eventChannelName': eventChannelName});

    return _mapFilesFromDynamicList(mapList);
  }

  /// Lists files from the iCloud container directory, which lives on the device
  ///
  /// Returns a future completing with a list of file names
  @Deprecated('Use [GatherFiles]')
  Future<List<String>> listFiles() async {
    final files = await _channel
        .invokeListMethod<String>('listFiles', {'eventChannelName': ''});
    return files ?? [];
  }

  /// Lists files from the iCloud container directory, which lives on the
  /// device. Also watches for updates.
  ///
  /// Returns a future completing with a stream of lists of the file names
  @Deprecated('Use [GatherFiles]')
  Future<Stream<List<String>>> watchFiles() async {
    final eventChannelName = 'icloud_storage/event/list';
    await _channel.invokeMethod(
        'createEventChannel', {'eventChannelName': eventChannelName});
    final watchFileEventChannel = EventChannel(eventChannelName);
    _channel.invokeMethod('listFiles', {'eventChannelName': eventChannelName});
    return watchFileEventChannel
        .receiveBroadcastStream()
        .where((event) => event is List)
        .map<List<String>>(
            (event) => (event as List).map((item) => item as String).toList());
  }

  /// Start to upload a file from a local path to iCloud
  ///
  /// [filePath] is the full path of the local file
  ///
  /// [destinationRelativePath] is the relative path of the file you want to
  /// store in iCloud. If not specified, the name of the local file name is
  /// used.
  ///
  /// [onProgress] is an optional callback to track the progress of the
  /// upload. It takes a Stream<double> as input, which is the percentage of
  /// the data being uploaded.
  ///
  /// The returned future completes without waiting for the file to be uploaded
  /// to iCloud
  Future<void> startUpload({
    required String filePath,
    String? destinationRelativePath,
    StreamHandler<double>? onProgress,
  }) async {
    if (filePath.trim().isEmpty) {
      throw InvalidArgumentException('invalid filePath');
    }

    final cloudFileName = destinationRelativePath ?? filePath.split('/').last;

    if (!_validateRelativePath(cloudFileName)) {
      throw InvalidArgumentException('invalid destination relative path');
    }

    var eventChannelName = '';

    if (onProgress != null) {
      eventChannelName =
          'icloud_storage/event/upload/$cloudFileName${_getChannelNameSuffix()}';
      await _channel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});
      final uploadEventChannel = EventChannel(eventChannelName);
      final stream = uploadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);
      onProgress(stream);
    }

    await _channel.invokeMethod('upload', {
      'localFilePath': filePath,
      'cloudFileName': cloudFileName,
      'eventChannelName': eventChannelName
    });
  }

  /// Start to download a file from iCloud
  ///
  /// [relativePath] is the relative path of the file on iCloud, such as myfile1
  /// or myfolder/myfile2
  ///
  /// [destinationFilePath] is the full path of the local file you want the
  /// iCloud file to be saved as
  ///
  /// [onProgress] is an optional callback to track the progress of the
  /// download. It takes a Stream<double> as input, which is the percentage of
  /// the data being downloaded.
  ///
  /// The returned future completes without waiting for the file to be
  /// downloaded
  Future<void> startDownload({
    required String relativePath,
    required String destinationFilePath,
    StreamHandler<double>? onProgress,
  }) async {
    if (!_validateRelativePath(relativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }
    if (destinationFilePath.trim().isEmpty ||
        destinationFilePath[destinationFilePath.length - 1] == '/') {
      throw InvalidArgumentException('invalid destinationFilePath');
    }

    var eventChannelName = '';

    if (onProgress != null) {
      eventChannelName =
          'icloud_storage/event/download/$relativePath${_getChannelNameSuffix()}';
      await _channel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});
      final downloadEventChannel = EventChannel(eventChannelName);
      final stream = downloadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);
      onProgress(stream);
    }

    await _channel.invokeMethod('download', {
      'cloudFileName': relativePath,
      'localFilePath': destinationFilePath,
      'eventChannelName': eventChannelName
    });
  }

  /// Delete a file from iCloud container directory, whether it is been
  /// downloaded or not
  ///
  /// [relativePath] is the relative path of the file on iCloud, such as myfile1
  /// or myfolder/myfile2
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  Future<void> delete(String relativePath) async {
    if (!_validateRelativePath(relativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    await _channel.invokeMethod('delete', {'cloudFileName': relativePath});
  }

  /// Move a file from one location to another in the iCloud container
  ///
  /// [fromRelativePath] is the relative path of the file to be moved, such as
  /// folder1/file
  ///
  /// [toRelativePath] is the relative path to move to, such as folder2/file
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  Future<void> move({
    required String fromRelativePath,
    required String toRelativePath,
  }) async {
    if (!_validateRelativePath(fromRelativePath) ||
        !_validateRelativePath(toRelativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    await _channel.invokeMethod('move', {
      'atRelativePath': fromRelativePath,
      'toRelativePath': toRelativePath,
    });
  }

  /// Rename a file in the iCloud container
  ///
  /// [relativePath] is the relative path of the file to be renamed, such as
  /// file1 or folder/file1
  ///
  /// [newName] is the name of the file to be renamed to. It is not a relative
  /// path.
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  Future<void> rename({
    required String relativePath,
    required String newName,
  }) async {
    if (!_validateRelativePath(relativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    if (!_validateFileName(newName)) {
      throw InvalidArgumentException('invalid newName');
    }

    await move(
      fromRelativePath: relativePath,
      toRelativePath:
          relativePath.substring(0, relativePath.lastIndexOf('/') + 1) +
              newName,
    );
  }

  /// Private method to convert the list of maps from platform code to a list of
  /// ICloudFile object
  List<ICloudFile> _mapFilesFromDynamicList(
      List<Map<dynamic, dynamic>>? mapList) {
    List<ICloudFile> files = [];
    if (mapList != null) {
      for (final map in mapList) {
        try {
          files.add(ICloudFile.fromMap(map));
        } catch (ex) {
          print(
              'WARNING: icloud_storange plugin gatherFiles method has to omit a file as it could not map $map to iCloudFile; Exception: $ex');
        }
      }
    }
    return files;
  }

  /// Private method to validate relative path; each part must be valid name
  bool _validateRelativePath(String path) {
    final fileOrDirNames = path.split('/');
    if (fileOrDirNames.length == 0) return false;

    return fileOrDirNames.every((name) => _validateFileName(name));
  }

  /// Private method to validate file name. It shall not contain '/' or ':', and
  /// it shall not start with '.', and the length shall be greater than 0 and
  /// less than 255.
  bool _validateFileName(String name) => !(name.length == 0 ||
      name.length > 255 ||
      RegExp(r"([:/]+)|(^[.].*$)").hasMatch(name));

  /// Private method to generate a channel name for communication with platform
  /// code
  String _getChannelNameSuffix() =>
      '-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
}
