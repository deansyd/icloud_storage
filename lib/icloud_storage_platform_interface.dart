import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'icloud_storage_method_channel.dart';
import 'models/icloud_file.dart';

/// A function-type alias takes a stream as argument and returns void
typedef StreamHandler<T> = void Function(Stream<T>);

abstract class ICloudStoragePlatform extends PlatformInterface {
  /// Constructs a IcloudStoragePlatform.
  ICloudStoragePlatform() : super(token: _token);

  static final Object _token = Object();

  static ICloudStoragePlatform _instance = MethodChannelICloudStorage();

  /// The default instance of [ICloudStoragePlatform] to use.
  ///
  /// Defaults to [MethodChannelICloudStorage].
  static ICloudStoragePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ICloudStoragePlatform] when
  /// they register themselves.
  static set instance(ICloudStoragePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gather all the files' meta data from iCloud container.
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [onUpdate] is an optional paramater can be used as a call back every time
  /// when the list of files are updated. It won't be triggered when the
  /// function initially returns the list of files.
  ///
  /// The function returns a future of list of ICloudFile.
  Future<List<ICloudFile>> gather({
    required String containerId,
    StreamHandler<List<ICloudFile>>? onUpdate,
  }) async {
    throw UnimplementedError('gather() has not been implemented.');
  }


  Future<String?> getContainerPath({
    required String containerId,
  }) async {
    throw UnimplementedError('getContainerPath() has not been implemented.');
  }

  /// Upload a local file to iCloud.
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [filePath] is the full path of the local file.
  ///
  /// [destinationRelativePath] is the relative path of the file to be stored in
  /// iCloud.
  ///
  /// [onProgress] is an optional callback to track the progress of the
  /// upload. It takes a Stream<double> as input, which is the percentage of
  /// the data being uploaded.
  ///
  /// The returned future completes without waiting for the file to be uploaded
  /// to iCloud.
  Future<void> upload({
    required String containerId,
    required String filePath,
    required String destinationRelativePath,
    StreamHandler<double>? onProgress,
  }) async {
    throw UnimplementedError('upload() has not been implemented.');
  }

  /// Download a file from iCloud.
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [relativePath] is the relative path of the file on iCloud, such as file1
  /// or folder/file2.
  ///
  /// [destinationFilePath] is the full path of the local file to be saved as.
  ///
  /// [onProgress] is an optional callback to track the progress of the
  /// download. It takes a Stream<double> as input, which is the percentage of
  /// the data being downloaded.
  ///
  /// The returned future completes without waiting for the file to be
  /// downloaded.
  Future<bool> download({
    required String containerId,
    required String relativePath,
    StreamHandler<double>? onProgress,
  }) async {
    throw UnimplementedError('download() has not been implemented.');
  }

  /// Delete a file from iCloud container directory, whether it is been
  /// downloaded or not
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [relativePath] is the relative path of the file on iCloud, such as file1
  /// or folder/file2
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  Future<void> delete({
    required String containerId,
    required String relativePath,
  }) async {
    throw UnimplementedError('delete() has not been implemented.');
  }

  /// Move a file from one location to another in the iCloud container
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [fromRelativePath] is the relative path of the file to be moved, such as
  /// folder1/file
  ///
  /// [toRelativePath] is the relative path to move to, such as folder2/file
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  Future<void> move({
    required String containerId,
    required String fromRelativePath,
    required String toRelativePath,
  }) async {
    throw UnimplementedError('move() has not been implemented.');
  }
}
