import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'icloud_storage_platform_interface.dart';
import 'models/icloud_file.dart';

/// An implementation of [ICloudStoragePlatform] that uses method channels.
class MethodChannelICloudStorage extends ICloudStoragePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('icloud_storage');

  @override
  Future<List<ICloudFile>> gather({
    required String containerId,
    StreamHandler<List<ICloudFile>>? onUpdate,
  }) async {
    final eventChannelName = onUpdate == null
        ? ''
        : _generateEventChannelName('gather', containerId);

    if (onUpdate != null) {
      await methodChannel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});

      final gatherEventChannel = EventChannel(eventChannelName);
      final stream = gatherEventChannel
          .receiveBroadcastStream()
          .where((event) => event is List)
          .map<List<ICloudFile>>((event) => _mapFilesFromDynamicList(
              List<Map<dynamic, dynamic>>.from(event)));

      onUpdate(stream);
    }

    final mapList =
        await methodChannel.invokeListMethod<Map<dynamic, dynamic>>('gather', {
      'containerId': containerId,
      'eventChannelName': eventChannelName,
    });

    return _mapFilesFromDynamicList(mapList);
  }

  @override
  Future<String?> getContainerPath({required String containerId}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getContainerPath',
      {'containerId': containerId},
    );
    return result;
  }

  @override
  Future<void> upload({
    required String containerId,
    required String filePath,
    required String destinationRelativePath,
    StreamHandler<double>? onProgress,
  }) async {
    var eventChannelName = '';

    if (onProgress != null) {
      eventChannelName = _generateEventChannelName('upload', containerId);

      await methodChannel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});

      final uploadEventChannel = EventChannel(eventChannelName);
      final stream = uploadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);

      onProgress(stream);
    }

    await methodChannel.invokeMethod('upload', {
      'containerId': containerId,
      'localFilePath': filePath,
      'cloudFileName': destinationRelativePath,
      'eventChannelName': eventChannelName
    });
  }

  @override
  Future<bool> download({
    required String containerId,
    required String relativePath,
    StreamHandler<double>? onProgress,
  }) async {
    var eventChannelName = '';

    if (onProgress != null) {
      eventChannelName = _generateEventChannelName('download', containerId);

      await methodChannel.invokeMethod(
          'createEventChannel', {'eventChannelName': eventChannelName});

      final downloadEventChannel = EventChannel(eventChannelName);
      final stream = downloadEventChannel
          .receiveBroadcastStream()
          .where((event) => event is double)
          .map((event) => event as double);

      onProgress(stream);
    }

    return await methodChannel.invokeMethod('download', {
      'containerId': containerId,
      'cloudFileName': relativePath,
      'eventChannelName': eventChannelName
    });
  }

  @override
  Future<void> delete({
    required containerId,
    required String relativePath,
  }) async {
    await methodChannel.invokeMethod('delete', {
      'containerId': containerId,
      'cloudFileName': relativePath,
    });
  }

  @override
  Future<void> move({
    required containerId,
    required String fromRelativePath,
    required String toRelativePath,
  }) async {
    await methodChannel.invokeMethod('move', {
      'containerId': containerId,
      'atRelativePath': fromRelativePath,
      'toRelativePath': toRelativePath,
    });
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
          if (kDebugMode) {
            print(
                'WARNING: icloud_storange plugin gatherFiles method has to omit a file as it could not map $map to iCloudFile; Exception: $ex');
          }
        }
      }
    }
    return files;
  }

  /// Private method to generate event channel names
  String _generateEventChannelName(String eventType, String containerId,
          [String? additionalIdentifier]) =>
      [
        'icloud_storage',
        'event',
        eventType,
        containerId,
        ...(additionalIdentifier == null ? [] : [additionalIdentifier]),
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}'
      ].join('/');
}
