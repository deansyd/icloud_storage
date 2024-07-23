import 'dart:async';
import 'icloud_storage_platform_interface.dart';
import 'models/exceptions.dart';
import 'models/icloud_file.dart';
export 'models/exceptions.dart';
export 'models/icloud_file.dart';

/// The main class for the plugin. Contains all the API's needed for listing,
/// uploading, downloading and deleting files.
class ICloudStorage {
  /// Get all the files' meta data from iCloud container
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [onUpdate] is an optional paramater can be used as a callback when the
  /// list of files are updated. It won't be triggered when the function
  /// initially returns the list of files
  ///
  /// The function returns a future of list of ICloudFile
  static Future<List<ICloudFile>> gather({
    required String containerId,
    StreamHandler<List<ICloudFile>>? onUpdate,
  }) async {
    return await ICloudStoragePlatform.instance.gather(
      containerId: containerId,
      onUpdate: onUpdate,
    );
  }

  static Future<String?> getContainerPath({
    required String containerId,
  }) async {
    return await ICloudStoragePlatform.instance.getContainerPath(
      containerId: containerId,
    );
  }

  

  /// Initiate to upload a file to iCloud
  ///
  /// [containerId] is the iCloud Container Id.
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
  static Future<void> upload({
    required String containerId,
    required String filePath,
    String? destinationRelativePath,
    StreamHandler<double>? onProgress,
  }) async {
    if (filePath.trim().isEmpty) {
      throw InvalidArgumentException('invalid filePath');
    }

    final destination = destinationRelativePath ?? filePath.split('/').last;

    if (!_validateRelativePath(destination)) {
      throw InvalidArgumentException('invalid destination relative path');
    }

    await ICloudStoragePlatform.instance.upload(
      containerId: containerId,
      filePath: filePath,
      destinationRelativePath: destination,
      onProgress: onProgress,
    );
  }

  /// Initiate to download a file from iCloud
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [relativePath] is the relative path of the file on iCloud, such as file1
  /// or folder/myfile2
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
  static Future<bool> download({
    required String containerId,
    required String relativePath,
    StreamHandler<double>? onProgress,
  }) async {
    if (!_validateRelativePath(relativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    return await ICloudStoragePlatform.instance.download(
      containerId: containerId,
      relativePath: relativePath,
      onProgress: onProgress,
    );
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
  static Future<void> delete({
    required String containerId,
    required String relativePath,
  }) async {
    if (!_validateRelativePath(relativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    await ICloudStoragePlatform.instance.delete(
      containerId: containerId,
      relativePath: relativePath,
    );
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
  static Future<void> move({
    required String containerId,
    required String fromRelativePath,
    required String toRelativePath,
  }) async {
    if (!_validateRelativePath(fromRelativePath) ||
        !_validateRelativePath(toRelativePath)) {
      throw InvalidArgumentException('invalid relativePath');
    }

    await ICloudStoragePlatform.instance.move(
      containerId: containerId,
      fromRelativePath: fromRelativePath,
      toRelativePath: toRelativePath,
    );
  }

  /// Rename a file in the iCloud container
  ///
  /// [containerId] is the iCloud Container Id.
  ///
  /// [relativePath] is the relative path of the file to be renamed, such as
  /// file1 or folder/file1
  ///
  /// [newName] is the name of the file to be renamed to. It is not a relative
  /// path.
  ///
  /// PlatformException with code PlatformExceptionCode.fileNotFound will be
  /// thrown if the file does not exist
  static Future<void> rename({
    required String containerId,
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
      containerId: containerId,
      fromRelativePath: relativePath,
      toRelativePath:
          relativePath.substring(0, relativePath.lastIndexOf('/') + 1) +
              newName,
    );
  }

  /// Private method to validate relative path; each part must be valid name
  static bool _validateRelativePath(String path) {
    final fileOrDirNames = path.split('/');
    if (fileOrDirNames.isEmpty) return false;

    return fileOrDirNames.every((name) => _validateFileName(name));
  }

  /// Private method to validate file name. It shall not contain '/' or ':', and
  /// it shall not start with '.', and the length shall be greater than 0 and
  /// less than 255.
  static bool _validateFileName(String name) => !(name.isEmpty ||
      name.length > 255 ||
      RegExp(r"([:/]+)|(^[.].*$)").hasMatch(name));
}
